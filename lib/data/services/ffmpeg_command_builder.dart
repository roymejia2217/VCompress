import 'package:flutter/foundation.dart';
import 'package:vcompressor/models/video_task.dart';
import 'package:vcompressor/models/algorithm.dart';
import 'package:vcompressor/models/video_codec.dart';
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
    HardwareCapabilities hwCapabilities, {
    bool forceSoftware = false,
  }) async {
    final args = <String>[];

    // Optimización de Logs (Memoria y Performance)
    // Reducir logs innecesarios para evitar overhead en el buffer de FFmpegKit
    // Solo mostramos 'info' en debug, 'warning' en release.
    args.add('-hide_banner');
    if (kDebugMode) {
      args.addAll(['-loglevel', 'info']);
    } else {
      args.addAll(['-loglevel', 'warning']);
    }

    // Sobreescribir archivo de salida si existe
    args.add('-y');

    // Agregar aceleración por hardware si está disponible y no se fuerza software
    if (!forceSoftware &&
        hwCapabilities.canUseHwAccel &&
        defaultTargetPlatform == TargetPlatform.android) {
      args.addAll(['-hwaccel', 'mediacodec']);
      AppLogger.debug(
        'Usando aceleración por hardware: MediaCodec',
        tag: 'FFmpegCommandBuilder',
      );
    } else if (forceSoftware) {
      AppLogger.info(
        'Forzando codificación por software (Retry mode)',
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
    final codecs = await _buildCodecArgs(
      task,
      hwCapabilities,
      forceSoftware: forceSoftware,
    );
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

    // Escala (Resolución) - Punto 4 Optimización
    // Si la escala es menor a 1.0, aplicamos el filtro de escalado
    if (task.settings.scale < 1.0) {
      // Usamos trunc(iw*scale/2)*2 para asegurar dimensiones pares (requerido por muchos codecs)
      final s = task.settings.scale.toStringAsFixed(2);
      filters.add('scale=trunc(iw*$s/2)*2:trunc(ih*$s/2)*2');
    }

    // Formato cuadrado 1:1
    if (editSettings.enableSquareFormat) {
      // Usamos raw string para evitar advertencias de escape innecesario en Dart,
      // pero mantenemos el escape para FFmpeg (coma escapada)
      filters.add(r'crop=min(iw\,ih):min(iw\,ih)');
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
    HardwareCapabilities hwCapabilities, {
    bool forceSoftware = false,
  }) async {
    final algorithm = task.settings.algorithm;
    final format = task.settings.format;
    
    // Si la selección manual de codec no está habilitada, usar H.264 por defecto
    // a menos que sea WebM (que usa VP9 forzado abajo)
    final selectedCodec = task.settings.editSettings.enableCodec 
        ? task.settings.codec 
        : VideoCodec.h264;

    String videoCodecName;
    String audioCodec;
    VideoCodec effectiveCodecModel = selectedCodec; // Para cálculo de bitrate

    // 1. Determinar el codec de video base
    // Si el formato es WebM, forzamos VP9
    if (format == OutputFormat.webm) {
      videoCodecName = 'libvpx-vp9';
      effectiveCodecModel = VideoCodec.vp9;
    } else {
      // Para otros formatos (MP4, MKV, MOV), usamos la selección del usuario
      // Determinar si podemos usar hardware
      bool useHardware = false;
      
      if (!forceSoftware &&
          hwCapabilities.canUseHwAccel &&
          defaultTargetPlatform == TargetPlatform.android) {
        
        switch (selectedCodec) {
          case VideoCodec.h264:
            if (hwCapabilities.hasH264HwEncoder) {
              useHardware = true;
              videoCodecName = 'h264_mediacodec';
              effectiveCodecModel = VideoCodec.h264;
            } else {
              videoCodecName = selectedCodec.ffmpegName;
            }
            break;
            
          case VideoCodec.h265:
            if (hwCapabilities.hasH265HwEncoder) {
              useHardware = true;
              videoCodecName = 'hevc_mediacodec';
              effectiveCodecModel = VideoCodec.h265;
            } else {
              videoCodecName = selectedCodec.ffmpegName;
            }
            break;
            
          default:
            videoCodecName = selectedCodec.ffmpegName;
            effectiveCodecModel = selectedCodec;
            break;
        }
      } else {
        // Forzado software o plataforma no Android
        videoCodecName = selectedCodec.ffmpegName;
        effectiveCodecModel = selectedCodec;
      }
      
      AppLogger.debug(
        'Codec seleccionado: ${selectedCodec.name}, Hardware: $useHardware -> $videoCodecName',
        tag: 'FFmpegCommandBuilder',
      );
    }

    // 2. Seleccionar codec de audio
    switch (format) {
      case OutputFormat.webm:
        audioCodec = 'libopus';
        break;
      case OutputFormat.mkv:
      default:
        // No usar copy si hay filtros de audio aplicados
        // O si necesitamos compatibilidad específica
        if (task.settings.editSettings.speed != 1.0) {
          audioCodec = 'aac';
        } else {
          audioCodec = 'copy';
        }
        break;
    }

    final args = <String>['-c:v', videoCodecName];

    // 3. Parámetros específicos del codec (CRF vs Bitrate)
    if (videoCodecName == 'libvpx-vp9') {
      args.addAll(['-crf', '${algorithm.crfValue}', '-b:v', '0']);
    } else if (videoCodecName.contains('mediacodec')) {
      // FIX: Hardware Encoders (MediaCodec) usan Bitrate (-b:v).
      // Ahora usamos lógica INTELIGENTE de bitrate.
      
      // Calcular altura objetivo basada en la escala
      // Usamos 1080p como base si no tenemos info, o la altura del video si la tenemos
      // Como task.videoHeight puede ser null, usamos un default razonable (720p)
      final baseHeight = task.videoHeight ?? 720;
      final targetHeight = (baseHeight * task.settings.scale).round();
      
      // Determinar FPS efectivos para el cálculo
      final effectiveFps = task.settings.editSettings.enableFps 
          ? (task.settings.editSettings.targetFps?.toDouble() ?? 30.0)
          : (task.originalFps ?? 30.0);

      final bitrate = await algorithm.getRecommendedBitrate(
        resolutionHeight: targetHeight,
        outputFormat: format.name,
        codec: effectiveCodecModel, // Pasamos el codec real (H.264 o H.265)
        fps: effectiveFps, // Pasamos los FPS para ajuste de fluidez
      );
      
      args.addAll(['-b:v', '$bitrate']);
      
      AppLogger.debug(
        'Bitrate Inteligente: ${(bitrate / 1000000).toStringAsFixed(2)} Mbps '
        '(H=${targetHeight}p [Scale ${task.settings.scale}], Codec=${effectiveCodecModel.name}, FPS=${effectiveFps.toStringAsFixed(0)})',
        tag: 'FFmpegCommandBuilder',
      );
    } else {
      // Software encoder (libx264, libx265) usa CRF y Preset
      args.addAll([
        '-preset',
        algorithm.preset,
        '-crf',
        '${algorithm.crfValue}',
      ]);
    }

    // 4. Codec de audio
    // Solo aplicar si no hay filtros de audio que requieran re-encoding
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
        // Usar 0.5 como paso constante para reducir velocidad
        const step = 0.5;
        filters.add('atempo=${step.toStringAsFixed(3)}');
        remainingSpeed /= step;
      }
      if (remainingSpeed != 1.0) {
        filters.add('atempo=${remainingSpeed.toStringAsFixed(3)}');
      }
    } else if (speed > 2.0) {
      double remainingSpeed = speed;
      while (remainingSpeed > 2.0) {
        // Usar 2.0 como paso constante para aumentar velocidad
        const step = 2.0;
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