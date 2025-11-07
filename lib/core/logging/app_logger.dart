import 'package:logger/logger.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'dart:convert';

/// Categorías de logging para contexto y filtrado
enum LogCategory {
  general,
  compression,
  performance,
  validation,
  hardware,
  cache,
}

/// Sistema de logging avanzado para VCompressor
/// Proporciona logging estructurado con niveles, filtros y persistencia
class AppLogger {
  static final Logger _instance = Logger(
    filter: _DevelopmentFilter(), // Solo debug logs en development
    printer: PrettyPrinter(
      methodCount: 2, // Muestra 2 niveles de call stack
      errorMethodCount: 8, // 8 niveles para errors
      lineLength: 120, // Ancho de línea
      colors: true, // Colores en terminal
      printEmojis: true, // Emojis por nivel
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
    output: _MultiFileOutput(), // Console + File en debug
  );

  // Niveles de severidad con semántica clara
  static void trace(
    dynamic message, {
    LogCategory category = LogCategory.general,
    String? tag,
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? structuredContext,
  }) {
    final categoryTag = tag != null ? '${category.name}:$tag' : category.name;
    final contextStr =
        structuredContext != null ? ' | ${jsonEncode(structuredContext)}' : '';
    final taggedMessage = '[$categoryTag] $message$contextStr';
    _instance.t(taggedMessage, error: error, stackTrace: stackTrace);
  }

  static void debug(
    dynamic message, {
    LogCategory category = LogCategory.general,
    String? tag,
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? structuredContext,
  }) {
    final categoryTag = tag != null ? '${category.name}:$tag' : category.name;
    final contextStr =
        structuredContext != null ? ' | ${jsonEncode(structuredContext)}' : '';
    final taggedMessage = '[$categoryTag] $message$contextStr';
    _instance.d(taggedMessage, error: error, stackTrace: stackTrace);
  }

  static void info(
    dynamic message, {
    LogCategory category = LogCategory.general,
    String? tag,
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? structuredContext,
  }) {
    final categoryTag = tag != null ? '${category.name}:$tag' : category.name;
    final contextStr =
        structuredContext != null ? ' | ${jsonEncode(structuredContext)}' : '';
    final taggedMessage = '[$categoryTag] $message$contextStr';
    _instance.i(taggedMessage, error: error, stackTrace: stackTrace);
  }

  static void warning(
    dynamic message, {
    LogCategory category = LogCategory.general,
    String? tag,
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? structuredContext,
  }) {
    final categoryTag = tag != null ? '${category.name}:$tag' : category.name;
    final contextStr =
        structuredContext != null ? ' | ${jsonEncode(structuredContext)}' : '';
    final taggedMessage = '[$categoryTag] $message$contextStr';
    _instance.w(taggedMessage, error: error, stackTrace: stackTrace);
  }

  static void error(
    dynamic message, {
    LogCategory category = LogCategory.general,
    String? tag,
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? structuredContext,
  }) {
    final categoryTag = tag != null ? '${category.name}:$tag' : category.name;
    final contextStr =
        structuredContext != null ? ' | ${jsonEncode(structuredContext)}' : '';
    final taggedMessage = '[$categoryTag] $message$contextStr';
    _instance.e(taggedMessage, error: error, stackTrace: stackTrace);
  }

  static void fatal(
    dynamic message, {
    LogCategory category = LogCategory.general,
    String? tag,
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? structuredContext,
  }) {
    final categoryTag = tag != null ? '${category.name}:$tag' : category.name;
    final contextStr =
        structuredContext != null ? ' | ${jsonEncode(structuredContext)}' : '';
    final taggedMessage = '[$categoryTag] $message$contextStr';
    _instance.f(taggedMessage, error: error, stackTrace: stackTrace);
  }

  // ============ MÉTODOS ESPECIALIZADOS DE COMPRESIÓN ============

  /// Log de inicio de compresión con contexto completo
  static void compressionStarted({
    required String taskId,
    required String inputPath,
    required int fileSizeBytes,
    required String algorithm,
    required int quality,
    required String outputPath,
  }) {
    info(
      'Compression started: $taskId',
      category: LogCategory.compression,
      structuredContext: {
        'event': 'compression_started',
        'task_id': taskId,
        'input_path': inputPath,
        'file_size_bytes': fileSizeBytes,
        'file_size_mb': (fileSizeBytes / (1024 * 1024)).toStringAsFixed(2),
        'algorithm': algorithm,
        'quality': quality,
        'output_path': outputPath,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Log de progreso de compresión
  static void compressionProgress({
    required String taskId,
    required double percentage,
    required Duration elapsed,
    Duration? estimatedRemaining,
    int? currentFrame,
    int? totalFrames,
  }) {
    debug(
      'Compression progress: $taskId - ${percentage.toStringAsFixed(2)}%',
      category: LogCategory.compression,
      structuredContext: {
        'event': 'compression_progress',
        'task_id': taskId,
        'progress_percentage': percentage.toStringAsFixed(2),
        'elapsed_seconds': elapsed.inSeconds,
        'estimated_remaining_seconds': estimatedRemaining?.inSeconds,
        'current_frame': currentFrame,
        'total_frames': totalFrames,
      },
    );
  }

  /// Log de compresión completada exitosamente
  static void compressionCompleted({
    required String taskId,
    required int originalSizeBytes,
    required int compressedSizeBytes,
    required Duration processingTime,
    String? outputPath,
  }) {
    final reduction = ((1 - compressedSizeBytes / originalSizeBytes) * 100);

    info(
      'Compression completed: $taskId - ${reduction.toStringAsFixed(2)}% reduction',
      category: LogCategory.compression,
      structuredContext: {
        'event': 'compression_completed',
        'task_id': taskId,
        'original_size_bytes': originalSizeBytes,
        'original_size_mb': (originalSizeBytes / (1024 * 1024)).toStringAsFixed(2),
        'compressed_size_bytes': compressedSizeBytes,
        'compressed_size_mb':
            (compressedSizeBytes / (1024 * 1024)).toStringAsFixed(2),
        'reduction_percentage': reduction.toStringAsFixed(2),
        'processing_time_seconds': processingTime.inSeconds,
        'output_path': outputPath,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Log de compresión fallida
  static void compressionFailed({
    required String taskId,
    required Object error,
    StackTrace? stackTrace,
    String? inputPath,
    Map<String, dynamic>? additionalContext,
  }) {
    AppLogger.error(
      'Compression failed for task $taskId',
      category: LogCategory.compression,
      error: error,
      stackTrace: stackTrace,
      structuredContext: {
        'event': 'compression_failed',
        'task_id': taskId,
        'input_path': inputPath,
        ...?additionalContext,
      },
    );
  }

  /// Log de output de FFmpeg (verbose)
  static void ffmpegOutput(String line, {String? taskId}) {
    debug(
      'FFmpeg output',
      category: LogCategory.compression,
      structuredContext: {
        'event': 'ffmpeg_output',
        'task_id': taskId,
        'line': line,
      },
    );
  }

  /// Log de cancelación de tarea
  static void compressionCancelled({required String taskId, String? reason}) {
    warning(
      'Compression cancelled: $taskId',
      category: LogCategory.compression,
      structuredContext: {
        'event': 'compression_cancelled',
        'task_id': taskId,
        'reason': reason ?? 'User cancelled',
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Log de configuraciones subóptimas
  static void compressionConfigWarning({
    required String taskId,
    required String message,
  }) {
    warning(
      'Compression configuration warning: $message',
      category: LogCategory.compression,
      structuredContext: {
        'event': 'compression_warning',
        'task_id': taskId,
        'message': message,
      },
    );
  }

  /// Log de errores críticos del sistema
  static void compressionSystemError({
    required String component,
    required Object error,
    StackTrace? stackTrace,
  }) {
    fatal(
      'Compression system error in $component',
      category: LogCategory.compression,
      error: error,
      stackTrace: stackTrace,
      structuredContext: {
        'event': 'system_error',
        'component': component,
        'error_type': error.runtimeType.toString(),
      },
    );
  }

  // ============ MÉTODOS ESPECIALIZADOS DE PERFORMANCE ============

  static final Map<String, DateTime> _performanceStartTimes = {};
  static final Map<String, int> _memoryUsage = {};
  static final List<Map<String, dynamic>> _performanceEvents = [];

  /// Inicia el monitoreo de una operación
  static void performanceStart(String operationName) {
    _performanceStartTimes[operationName] = DateTime.now();
    debug(
      'Starting operation: $operationName',
      category: LogCategory.performance,
    );
  }

  /// Finaliza el monitoreo de una operación
  static void performanceEnd(String operationName) {
    final startTime = _performanceStartTimes[operationName];
    if (startTime != null) {
      final duration = DateTime.now().difference(startTime);
      info(
        'Operation completed: $operationName (${duration.inMilliseconds}ms)',
        category: LogCategory.performance,
        structuredContext: {
          'event': 'operation_completed',
          'operation': operationName,
          'duration_ms': duration.inMilliseconds,
        },
      );

      if (duration.inMilliseconds > 1000) {
        warning(
          'Slow operation detected: $operationName (${duration.inMilliseconds}ms)',
          category: LogCategory.performance,
        );
      }

      _performanceStartTimes.remove(operationName);
    }
  }

  /// Registra un evento de performance
  static void performanceEvent(String eventName, {Map<String, dynamic>? data}) {
    info(
      'Performance event: $eventName',
      category: LogCategory.performance,
      structuredContext: {
        'event': eventName,
        ...?data,
      },
    );

    _performanceEvents.add({
      'name': eventName,
      'data': data,
      'timestamp': DateTime.now(),
    });
  }

  /// Registra un error de performance
  static void performanceError(
    String errorName,
    String error,
    StackTrace? stackTrace,
  ) {
    AppLogger.error(
      'Performance error: $errorName',
      category: LogCategory.performance,
      error: error,
      stackTrace: stackTrace,
      structuredContext: {
        'event': 'performance_error',
        'error_name': errorName,
      },
    );
  }

  /// Registra uso de memoria
  static void recordMemoryUsage(String context, int bytes) {
    _memoryUsage[context] = bytes;
    final mb = bytes / (1024 * 1024);

    debug(
      'Memory: $context - ${mb.toStringAsFixed(2)} MB',
      category: LogCategory.performance,
      structuredContext: {
        'context': context,
        'bytes': bytes,
        'mb': mb.toStringAsFixed(2),
      },
    );
  }

  /// Limpia eventos de performance antiguos
  static void clearPerformanceEvents({Duration? olderThan}) {
    final cutoff = DateTime.now().subtract(olderThan ?? const Duration(hours: 1));
    _performanceEvents.removeWhere((e) => (e['timestamp'] as DateTime).isBefore(cutoff));
  }
}

///  Filter personalizado: Solo logs relevantes en producción
class _DevelopmentFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    // En production: solo warnings y superiores
    if (kReleaseMode) {
      return event.level.index >= Level.warning.index;
    }
    // En development: todo desde debug
    return event.level.index >= Level.debug.index;
  }
}

///  Output a múltiples destinos
class _MultiFileOutput extends LogOutput {
  final ConsoleOutput _console = ConsoleOutput();
  FileOutput? _file;

  _MultiFileOutput() {
    if (kDebugMode) {
      _file = FileOutput(
        file: File('${Directory.systemTemp.path}/vcompressor.log'),
        overrideExisting: true,
      );
    }
  }

  @override
  void output(OutputEvent event) {
    _console.output(event);
    _file?.output(event);
  }
}
