import 'package:flutter/foundation.dart';
import 'package:vcompressor/models/video_task.dart';
import 'package:vcompressor/models/algorithm.dart';
import 'package:vcompressor/core/logging/app_logger.dart';
import 'package:vcompressor/utils/hardware_detector.dart';

/// Constructor de comandos FFmpeg centralizado
/// SOLID: Single Responsibility - solo construye argumentos FFmpeg
/// DRY: Elimina duplicación entre VideoProcessorServiceMobile y VideoProcessorServiceLinux
class FFmpegCommandBuilder {
  const FFmpegCommandBuilder();

  /// Construye los argumentos completos para FFmpeg
  Future<List<String>> buildFFmpegArgs(
    VideoTask task,
    String outputPath,
    HardwareCapabilities hwCapabilities,
  ) async {
    final args = <String>['-y'];

    // Agregar aceleración por hardware si está disponible
    if (hwCapabilities.canUseHwAccel &&
        defaultTargetPlatform == TargetPlatform.android) {
      args.addAll(['-hwaccel', 'mediacodec']);
      AppLogger.debug(
        'Usando aceleración por hardware: MediaCodec',
        tag: 'FFmpegCommandBuilder',
      );
    }

    // Archivo de entrada
    final escapedPath = _escapePath(task.inputPath);
    args.addAll(['-i', escapedPath]);

    // Filtros de video
    final videoFilters = await _buildVideoFilters(task);
    if (videoFilters.isNotEmpty) {
      args.addAll(['-vf', videoFilters.join(',')]);
      AppLogger.debug(
        'Filtros de video: ${videoFilters.join(', ')}',
        tag: 'FFmpegCommandBuilder',
      );
    }

    // Filtros de audio
    final audioFilters = _buildAudioFilters(task);
    if (audioFilters.isNotEmpty) {
      args.addAll(['-af', audioFilters.join(',')]);
      AppLogger.debug(
        'Filtros de audio: ${audioFilters.join(', ')}',
        tag: 'FFmpegCommandBuilder',
      );
    }

    // Codecs
    final codecs = await _buildCodecArgs(task, hwCapabilities);
    args.addAll(codecs);

    // Configuración de threads
    if (hwCapabilities.optimalThreads > 1) {
      args.addAll(['-threads', '${hwCapabilities.optimalThreads}']);
      AppLogger.debug(
        'Usando ${hwCapabilities.optimalThreads} threads',
        tag: 'FFmpegCommandBuilder',
      );
    }

    // Control de audio
    if (task.settings.editSettings.enableVolume &&
        task.settings.editSettings.isMuted) {
      args.add('-an');
    }

    // Flags específicos del formato
    if (task.settings.format == OutputFormat.mp4) {
      args.addAll(['-movflags', '+faststart']);
    }

    // Archivo de salida
    args.add(outputPath);

    return args;
  }

  /// Construye los filtros de video
  Future<List<String>> _buildVideoFilters(VideoTask task) async {
    final filters = <String>[];
    final editSettings = task.settings.editSettings;

    // Resolución
    final scaleHeight = task.settings.resolution.scaleHeightArg;
    if (scaleHeight != null) {
      filters.add('scale=-2:$scaleHeight');
    }

    // Formato cuadrado 1:1
    if (editSettings.enableSquareFormat) {
      filters.add('crop=min(iw\\,ih):min(iw\\,ih)');
    }

    // Espejo horizontal
    if (editSettings.enableMirror) {
      filters.add('hflip');
      AppLogger.debug(
        'Aplicando filtro de espejo horizontal',
        tag: 'FFmpegCommandBuilder',
      );
    }

    // Velocidad de reproducción
    if (editSettings.enableSpeed && editSettings.speed != 1.0) {
      final factor = (1 / editSettings.speed).toStringAsFixed(3);
      filters.add('setpts=$factor*PTS');
      AppLogger.debug(
        'Aplicando filtro de velocidad: ${editSettings.speed}x',
        tag: 'FFmpegCommandBuilder',
      );
    }

    // FPS objetivo
    if (editSettings.enableFps && editSettings.targetFps != null) {
      filters.add('fps=${editSettings.targetFps}');
      AppLogger.debug(
        'Aplicando filtro de FPS: ${editSettings.targetFps}',
        tag: 'FFmpegCommandBuilder',
      );
    }

    return filters;
  }

  /// Construye los filtros de audio
  List<String> _buildAudioFilters(VideoTask task) {
    final filters = <String>[];
    final editSettings = task.settings.editSettings;

    // Volumen
    if (editSettings.enableVolume) {
      if (editSettings.isMuted) {
        filters.add('volume=0');
      } else if (editSettings.volumeLevel != 1.0) {
        filters.add('volume=${editSettings.volumeLevel}');
      }
    }

    // Velocidad de audio
    if (!editSettings.isMuted &&
        editSettings.enableSpeed &&
        editSettings.speed != 1.0) {
      final audioSpeedFilters = _buildAudioSpeedFilters(editSettings.speed);
      filters.addAll(audioSpeedFilters);
    }

    return filters;
  }

  /// Construye los argumentos de codec
  Future<List<String>> _buildCodecArgs(
    VideoTask task,
    HardwareCapabilities hwCapabilities,
  ) async {
    final algorithm = task.settings.algorithm;
    final format = task.settings.format;

    String videoCodec;
    String audioCodec;

    // Seleccionar codec de video
    try {
      final resolutionHeight =
          int.tryParse(task.settings.resolution.scaleHeightArg ?? '720') ?? 720;
      final outputFormat = format.name;

      final isCompatible = await algorithm.isCompatibleWithResolution(
        resolutionHeight: resolutionHeight,
        outputFormat: outputFormat,
      );

      final useHwCodec =
          hwCapabilities.canUseHwAccel &&
          defaultTargetPlatform == TargetPlatform.android &&
          isCompatible;

      if (useHwCodec) {
        videoCodec = await algorithm.getHardwareCodec(
          resolutionHeight: resolutionHeight,
          outputFormat: outputFormat,
        );
        AppLogger.debug(
          'Usando encoder de hardware: $videoCodec',
          tag: 'FFmpegCommandBuilder',
        );
      } else {
        videoCodec = algorithm.ffmpegCodec;
        AppLogger.debug(
          'Usando encoder de software: $videoCodec',
          tag: 'FFmpegCommandBuilder',
        );
      }
    } catch (e) {
      final useHwCodec =
          hwCapabilities.canUseHwAccel &&
          defaultTargetPlatform == TargetPlatform.android &&
          (format == OutputFormat.mp4 || format == OutputFormat.mov);

      videoCodec = useHwCodec ? algorithm.hwCodec : algorithm.ffmpegCodec;
      AppLogger.debug('Fallback a encoder: $videoCodec', tag: 'FFmpegCommandBuilder');
    }

    // Seleccionar codec de audio
    switch (format) {
      case OutputFormat.webm:
        videoCodec = 'libvpx-vp9';
        audioCodec = 'libopus';
        break;
      case OutputFormat.mkv:
        // No usar copy si hay filtros de audio aplicados
        if (task.settings.editSettings.speed != 1.0) {
          audioCodec = 'aac';
        } else {
          audioCodec = 'copy';
        }
        break;
      default:
        // No usar copy si hay filtros de audio aplicados
        if (task.settings.editSettings.speed != 1.0) {
          audioCodec = 'aac';
        } else {
          audioCodec = 'copy';
        }
        break;
    }

    final args = <String>['-c:v', videoCodec];

    // Parámetros específicos del codec
    if (videoCodec == 'libvpx-vp9') {
      args.addAll(['-crf', '${algorithm.crfValue}', '-b:v', '0']);
    } else if (videoCodec.contains('mediacodec')) {
      args.addAll(['-quality', '${algorithm.crfValue}']);
    } else {
      args.addAll([
        '-preset',
        algorithm.preset,
        '-crf',
        '${algorithm.crfValue}',
      ]);
    }

    // Codec de audio - Solo aplicar si no hay filtros de audio que requieran re-encoding
    final hasAudioFilters =
        task.settings.editSettings.enableSpeed &&
        task.settings.editSettings.speed != 1.0;

    if (hasAudioFilters ||
        !task.settings.editSettings.enableVolume ||
        !task.settings.editSettings.isMuted) {
      args.addAll(['-c:a', audioCodec]);
    }

    return args;
  }

  /// Construye filtros de velocidad de audio
  List<String> _buildAudioSpeedFilters(double speed) {
    final filters = <String>[];

    if (speed == 1.0) return filters;

    if (speed >= 0.5 && speed <= 2.0) {
      filters.add('atempo=${speed.toStringAsFixed(3)}');
    } else if (speed < 0.5) {
      double remainingSpeed = speed;
      while (remainingSpeed < 0.5) {
        final step = remainingSpeed < 0.25 ? 0.5 : remainingSpeed;
        filters.add('atempo=${step.toStringAsFixed(3)}');
        remainingSpeed /= step;
      }
      if (remainingSpeed != 1.0) {
        filters.add('atempo=${remainingSpeed.toStringAsFixed(3)}');
      }
    } else if (speed > 2.0) {
      double remainingSpeed = speed;
      while (remainingSpeed > 2.0) {
        final step = remainingSpeed > 4.0 ? 2.0 : remainingSpeed;
        filters.add('atempo=${step.toStringAsFixed(3)}');
        remainingSpeed /= step;
      }
      if (remainingSpeed != 1.0) {
        filters.add('atempo=${remainingSpeed.toStringAsFixed(3)}');
      }
    }

    return filters;
  }

  /// Escapa correctamente una ruta para uso en comandos FFmpeg
  String _escapePath(String path) {
    return '"$path"';
  }
}
