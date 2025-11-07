import 'package:flutter/foundation.dart';
import 'dart:io';

import 'package:vcompressor/models/algorithm.dart';
import 'package:vcompressor/utils/format_utils.dart';

enum OutputResolution {
  original('Original'),
  p1080('1080p'),
  p720('720p'),
  p480('480p'),
  p360('360p'),
  p240('240p'),
  p144('144p');

  const OutputResolution(this.label);
  final String label;
}

extension OutputResolutionX on OutputResolution {
  /// Returns FFmpeg scale height keeping aspect ratio (-2 for width)
  String? get scaleHeightArg {
    switch (this) {
      case OutputResolution.original:
        return null;
      case OutputResolution.p1080:
        return '1080';
      case OutputResolution.p720:
        return '720';
      case OutputResolution.p480:
        return '480';
      case OutputResolution.p360:
        return '360';
      case OutputResolution.p240:
        return '240';
      case OutputResolution.p144:
        return '144';
    }
  }
}

enum OutputFormat {
  mp4('MP4'),
  avi('AVI'),
  mov('MOV'),
  mkv('MKV'),
  webm('WebM');

  const OutputFormat(this.label);
  final String label;
}

extension OutputFormatX on OutputFormat {
  String get extension {
    switch (this) {
      case OutputFormat.mp4:
        return '.mp4';
      case OutputFormat.avi:
        return '.avi';
      case OutputFormat.mov:
        return '.mov';
      case OutputFormat.mkv:
        return '.mkv';
      case OutputFormat.webm:
        return '.webm';
    }
  }

  String get briefDescription {
    switch (this) {
      case OutputFormat.mp4:
        return 'Universal. Compatible con todos los dispositivos.';
      case OutputFormat.avi:
        return 'Clásico. Amplia compatibilidad.';
      case OutputFormat.mov:
        return 'Apple. Optimizado para macOS/iOS.';
      case OutputFormat.mkv:
        return 'Flexible. Soporta múltiples pistas.';
      case OutputFormat.webm:
        return 'Web. Optimizado para navegadores.';
    }
  }
}

@immutable
class VideoEditSettings {
  final bool enableVolume;
  final double volumeLevel; // 0.0 - 2.0 (0 = mute, 1 = normal, 2 = doble)
  final bool isMuted;
  final bool enableMirror; // Espejo horizontal
  final bool enableSquareFormat; // Formato cuadrado 1:1
  final double speed; // 0.5x, 1x, 2x
  final bool enableSpeed; // Habilitar cambio de velocidad
  final bool enableFps; // Habilitar cambio de FPS
  final int? targetFps; // FPS objetivo (null = mantener original)
  final bool replaceOriginalFile; // Reemplazar archivo original en DCIM

  const VideoEditSettings({
    this.enableVolume = false,
    this.volumeLevel = 1.0,
    this.isMuted = false,
    this.enableMirror = false,
    this.enableSquareFormat = false,
    this.speed = 1.0,
    this.enableSpeed = false,
    this.enableFps = false,
    this.targetFps,
    this.replaceOriginalFile = false,
  });

  factory VideoEditSettings.defaults() => const VideoEditSettings();

  VideoEditSettings copyWith({
    bool? enableVolume,
    double? volumeLevel,
    bool? isMuted,
    bool? enableMirror,
    bool? enableSquareFormat,
    double? speed,
    bool? enableSpeed,
    bool? enableFps,
    int? targetFps,
    bool? replaceOriginalFile,
  }) {
    return VideoEditSettings(
      enableVolume: enableVolume ?? this.enableVolume,
      volumeLevel: volumeLevel ?? this.volumeLevel,
      isMuted: isMuted ?? this.isMuted,
      enableMirror: enableMirror ?? this.enableMirror,
      enableSquareFormat: enableSquareFormat ?? this.enableSquareFormat,
      speed: speed ?? this.speed,
      enableSpeed: enableSpeed ?? this.enableSpeed,
      enableFps: enableFps ?? this.enableFps,
      targetFps: targetFps ?? this.targetFps,
      replaceOriginalFile: replaceOriginalFile ?? this.replaceOriginalFile,
    );
  }

  double getEffectiveVolume() {
    if (isMuted) return 0.0;
    return volumeLevel;
  }

  // hashCode para detección de cambios en configuración
  @override
  int get hashCode => Object.hash(
    enableVolume,
    volumeLevel,
    isMuted,
    enableMirror,
    enableSquareFormat,
    speed,
    enableSpeed,
    enableFps,
    targetFps,
    replaceOriginalFile,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VideoEditSettings &&
          runtimeType == other.runtimeType &&
          enableVolume == other.enableVolume &&
          volumeLevel == other.volumeLevel &&
          isMuted == other.isMuted &&
          enableMirror == other.enableMirror &&
          enableSquareFormat == other.enableSquareFormat &&
          speed == other.speed &&
          enableSpeed == other.enableSpeed &&
          enableFps == other.enableFps &&
          targetFps == other.targetFps &&
          replaceOriginalFile == other.replaceOriginalFile;
}

@immutable
class VideoSettings {
  final CompressionAlgorithm algorithm;
  final OutputResolution resolution;
  final bool removeAudio;
  final OutputFormat format;
  final VideoEditSettings editSettings;

  const VideoSettings({
    required this.algorithm,
    required this.resolution,
    required this.removeAudio,
    required this.format,
    this.editSettings = const VideoEditSettings(),
  });

  factory VideoSettings.defaults() => const VideoSettings(
    algorithm: CompressionAlgorithm.excelenteCalidad,
    resolution: OutputResolution.original,
    removeAudio: false,
    format: OutputFormat.mp4,
    editSettings: VideoEditSettings(),
  );

  VideoSettings copyWith({
    CompressionAlgorithm? algorithm,
    OutputResolution? resolution,
    bool? removeAudio,
    OutputFormat? format,
    VideoEditSettings? editSettings,
  }) {
    return VideoSettings(
      algorithm: algorithm ?? this.algorithm,
      resolution: resolution ?? this.resolution,
      removeAudio: removeAudio ?? this.removeAudio,
      format: format ?? this.format,
      editSettings: editSettings ?? this.editSettings,
    );
  }

  // GETTER: Obtener configuración de compresión estructurada
  /// Retorna un mapa con la configuración de compresión para FFmpeg.
  Map<String, dynamic> get compressionSettings {
    return {
      'video': {
        'codec': algorithm.name,
        'resolution': resolution.scaleHeightArg,
        'format': format.extension,
        'removeAudio': removeAudio,
      },
      'edit': {
        'enableVolume': editSettings.enableVolume,
        'volumeLevel': editSettings.volumeLevel,
        'isMuted': editSettings.isMuted,
        'enableMirror': editSettings.enableMirror,
        'enableSquareFormat': editSettings.enableSquareFormat,
        'speed': editSettings.speed,
        'enableSpeed': editSettings.enableSpeed,
        'enableFps': editSettings.enableFps,
        'targetFps': editSettings.targetFps,
        'replaceOriginalFile': editSettings.replaceOriginalFile,
      },
    };
  }

  // GETTER: Configuración de video solamente
  /// Extrae solo la configuración relacionada al video.
  Map<String, dynamic> get videoConfig {
    return compressionSettings['video'] as Map<String, dynamic>;
  }

  // GETTER: Configuración de edición solamente
  /// Extrae solo la configuración relacionada a la edición.
  Map<String, dynamic> get editConfig {
    return compressionSettings['edit'] as Map<String, dynamic>;
  }

  // GETTER: Es configuración de alta calidad
  /// Retorna true si el algoritmo es de alta calidad.
  bool get isHighQuality => algorithm == CompressionAlgorithm.excelenteCalidad;

  // GETTER: Es configuración de baja calidad
  /// Retorna true si el algoritmo es de baja calidad.
  bool get isLowQuality => algorithm == CompressionAlgorithm.ultraCompresion;

  // GETTER: Comando FFmpeg generado (simplificado)
  /// Genera un comando FFmpeg básico basado en esta configuración.
  String get ffmpegCommand {
    final editSettings = editConfig;

    final parts = <String>[
      '-c:v ${algorithm.name}',
      if (resolution.scaleHeightArg != null)
        '-vf scale=-2:${resolution.scaleHeightArg}',
      '-f ${format.name}',
      if (removeAudio) '-an',
      if (editSettings['enableSpeed'] as bool)
        '-filter:v "setpts=${1 / (editSettings['speed'] as double)}*PTS"',
      if (editSettings['enableMirror'] as bool) '-vf hflip',
      if (editSettings['enableSquareFormat'] as bool)
        '-vf "crop=min(iw\\,ih):min(iw\\,ih)"',
    ];

    return parts.where((part) => part.isNotEmpty).join(' ');
  }

  // hashCode para detección de cambios en configuración
  @override
  int get hashCode =>
      Object.hash(algorithm, resolution, removeAudio, format, editSettings);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VideoSettings &&
          runtimeType == other.runtimeType &&
          algorithm == other.algorithm &&
          resolution == other.resolution &&
          removeAudio == other.removeAudio &&
          format == other.format &&
          editSettings == other.editSettings;
}

/// Estados posibles de una tarea de video
enum VideoTaskState {
  pending, // En espera - no iniciado
  processing, // Procesando activamente
  completed, // Completado exitosamente
  error, // Error o cancelado
}

@immutable
class VideoTask {
  final int id;
  final String inputPath;
  final String fileName;
  final VideoSettings settings;
  final int? originalSizeBytes;
  final int? compressedSizeBytes;
  final String? outputPath;
  final String? thumbnailPath;
  final int? videoWidth; // Dimensiones del video original
  final int? videoHeight;
  final double? duration; // Duración del video en segundos
  final double? originalFps; // FPS del video original
  final String?
  originalPath; // Ruta original del archivo antes de copiarse al cache
  final String?
  originalContentUri; // URI de MediaStore para reemplazo en DCIM

  // NUEVO: Progreso individual (0.0-1.0) para tracking durante compresión
  final double? progress;

  // NUEVO: Mensaje de error si la compresión falla
  final String? errorMessage;

  const VideoTask({
    required this.id,
    required this.inputPath,
    required this.fileName,
    required this.settings,
    this.originalSizeBytes,
    this.compressedSizeBytes,
    this.outputPath,
    this.thumbnailPath,
    this.videoWidth,
    this.videoHeight,
    this.duration,
    this.originalFps,
    this.originalPath,
    this.originalContentUri,
    this.progress,
    this.errorMessage,
  });

  VideoTask copyWith({
    String? inputPath,
    VideoSettings? settings,
    int? originalSizeBytes,
    int? compressedSizeBytes,
    String? outputPath,
    String? thumbnailPath,
    int? videoWidth,
    int? videoHeight,
    double? duration,
    double? originalFps,
    String? originalPath,
    String? originalContentUri,
    double? progress,
    String? errorMessage,
    bool clearProgress = false,
    bool clearErrorMessage = false,
  }) {
    return VideoTask(
      id: id,
      inputPath: inputPath ?? this.inputPath,
      fileName: fileName,
      settings: settings ?? this.settings,
      originalSizeBytes: originalSizeBytes ?? this.originalSizeBytes,
      compressedSizeBytes: compressedSizeBytes ?? this.compressedSizeBytes,
      outputPath: outputPath ?? this.outputPath,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      videoWidth: videoWidth ?? this.videoWidth,
      videoHeight: videoHeight ?? this.videoHeight,
      duration: duration ?? this.duration,
      originalFps: originalFps ?? this.originalFps,
      originalPath: originalPath ?? this.originalPath,
      originalContentUri: originalContentUri ?? this.originalContentUri,
      progress: clearProgress ? null : (progress ?? this.progress),
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
    );
  }

  double? get compressionRatio {
    if (originalSizeBytes == null || compressedSizeBytes == null) return null;
    if (originalSizeBytes == 0) return null;
    return (originalSizeBytes! - compressedSizeBytes!) /
        originalSizeBytes! *
        100;
  }

  String get originalSizeFormatted {
    if (originalSizeBytes == null) return 'Desconocido';
    return FormatUtils.formatBytes(originalSizeBytes!);
  }

  String get compressedSizeFormatted {
    if (compressedSizeBytes == null) return 'Desconocido';
    return FormatUtils.formatBytes(compressedSizeBytes!);
  }

  String get durationFormatted {
    if (duration == null) return 'Desconocido';
    return FormatUtils.formatDuration(duration!);
  }

  String get compressionRatioFormatted {
    if (compressionRatio == null) return 'Desconocido';
    return FormatUtils.formatCompressionRatio(compressionRatio!);
  }

  // Getters computados para estados (Material 3 pattern)

  /// Determina el estado actual del task basado en sus campos
  ///  KISS: Prioridad simple - processing > error > completed > pending
  VideoTaskState get state {
    // PRIORIDAD 1: Processing activo (reprocesamiento o procesamiento inicial)
    if (progress != null && progress! > 0) {
      return VideoTaskState.processing;
    }

    // PRIORIDAD 2: Error (solo si NO está procesando)
    if (errorMessage != null) {
      return VideoTaskState.error;
    }

    // PRIORIDAD 3: Completado (solo si NO está procesando ni tiene error)
    if (compressedSizeBytes != null) {
      return VideoTaskState.completed;
    }

    // PRIORIDAD 4: Pendiente (default)
    return VideoTaskState.pending;
  }

  bool get isPending => state == VideoTaskState.pending;
  bool get isProcessing => state == VideoTaskState.processing;
  bool get isCompleted => state == VideoTaskState.completed;
  bool get hasError => state == VideoTaskState.error;

  /// Progreso para display (0.0-1.0), default 0.0 si null
  double get displayProgress => progress ?? 0.0;

  // GETTER: Obtener tamaño del archivo en bytes
  /// Retorna el tamaño del archivo de video en bytes.
  /// Si el archivo no existe, retorna 0.
  int get fileSizeBytes {
    try {
      final file = File(inputPath);
      if (file.existsSync()) {
        return file.lengthSync();
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  // GETTER: Tamaño en MB para display
  /// Retorna el tamaño del archivo en megabytes, formateado con 2 decimales.
  String get fileSizeMB {
    final sizeInMB = fileSizeBytes / (1024 * 1024);
    return sizeInMB.toStringAsFixed(2);
  }

  // GETTER: Nombre del archivo sin path (ya existe como campo fileName)
  /// El campo fileName ya contiene el nombre del archivo sin path.

  // GETTER: Estado es en progreso
  /// Retorna true si la compresión está actualmente en progreso.
  bool get isInProgress => state == VideoTaskState.processing;

  // GETTER: Estado es fallido
  /// Retorna true si la compresión falló.
  bool get isFailed => state == VideoTaskState.error;

  // GETTER: Duración de procesamiento (si se puede calcular)
  /// Calcula la duración total de procesamiento si existe información suficiente.
  Duration? get processingDuration {
    // Si tenemos información de progreso, podemos estimar duración
    if (progress != null && progress! > 0 && duration != null) {
      // Estimación básica basada en progreso
      final estimatedTotal = Duration(seconds: (duration! / progress!).round());
      return estimatedTotal;
    }
    return null;
  }

  // GETTER: Tiempo de procesamiento formateado
  /// Retorna el tiempo de procesamiento en formato legible (ej: "2m 30s").
  String get processingTimeFormatted {
    final duration = processingDuration;
    if (duration == null) return '--';

    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes}m ${seconds}s';
  }
}
