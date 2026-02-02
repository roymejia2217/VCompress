import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';

import 'package:vcompressor/models/video_task.dart';
import 'package:vcompressor/core/result/result.dart';
import 'package:vcompressor/core/error/app_error.dart';
import 'package:vcompressor/core/logging/app_logger.dart';
import 'package:vcompressor/data/services/ffmpeg_progress_service.dart';
import 'package:vcompressor/data/services/ffmpeg_command_builder.dart';
import 'package:vcompressor/providers/hardware_provider.dart';

import 'package:vcompressor/data/services/video_processor_service.dart';

/// Servicio para el procesamiento de video con FFmpeg
/// Encapsula toda la lógica de compresión y edición de video
class VideoProcessorServiceMobile implements VideoProcessorService {
  final Ref _ref;

  VideoProcessorServiceMobile(this._ref);

  // DRY: Servicio simplificado para progreso basado en FFmpeg
  final _progressService = FFmpegProgressService();

  // DRY: Constructor de comandos FFmpeg centralizado
  static const _ffmpegBuilder = FFmpegCommandBuilder();

  // SOLID: Single Responsibility - solo maneja sesión activa
  int? _currentSessionId;

  /// Procesa un video con las configuraciones especificadas
  @override
  Future<Result<void, AppError>> processVideo({
    required VideoTask task,
    required String outputPath,
    required void Function(double) onProgress,
    required void Function(String?) onTimeEstimate,
    bool useTemporaryFile = false,
  }) async {
    try {
      AppLogger.info(
        'Iniciando procesamiento de video: ${task.fileName}',
        tag: 'VideoProcessor',
      );

      // Validar que hardware esté disponible ANTES de procesar
      final hwCapabilitiesAsync = await _ref.read(
        hardwareCapabilitiesProvider.future,
      );

      // Validación explícita de dependencias críticas
      if (hwCapabilitiesAsync.cpuCores <= 0) {
        return Failure(
          AppError.dependencyNotAvailable(
            'Hardware capabilities not properly initialized',
          ),
        );
      }

      // Determinar ruta de salida (temporal o final)
      final actualOutputPath = useTemporaryFile
          ? _generateTemporaryPath(outputPath)
          : outputPath;

      // Construir comando FFmpeg usando builder centralizado (Intento 1: Preferencia Hardware)
      var args = await _ffmpegBuilder.buildFFmpegArgs(
        task,
        actualOutputPath,
        hwCapabilitiesAsync,
      );

      // Ejecutar procesamiento
      var result = await _executeFFmpeg(
        args,
        task,
        onProgress,
        onTimeEstimate,
      );

      // RETRY LOGIC: Si falla y era posible usar hardware, intentar con software
      // CRITICAL: Don't retry if the failure was a user cancellation
      if (result.isFailure &&
          result.error?.type != AppErrorType.cancelled &&
          hwCapabilitiesAsync.canUseHwAccel &&
          defaultTargetPlatform == TargetPlatform.android) {
        
        AppLogger.warning(
          'Fallo en compresión por hardware. Reintentando con software...',
          tag: 'VideoProcessor',
        );

        // Limpiar sesión anterior
        _currentSessionId = null;
        
        // Construir comando forzando software
        args = await _ffmpegBuilder.buildFFmpegArgs(
          task,
          actualOutputPath,
          hwCapabilitiesAsync,
          forceSoftware: true,
        );

        // Reintentar ejecución
        result = await _executeFFmpeg(
          args,
          task,
          onProgress,
          onTimeEstimate,
        );
      }

      if (result.isFailure) {
        return result;
      }

      AppLogger.info(
        'Procesamiento completado: ${task.fileName}',
        tag: 'VideoProcessor',
      );
      return const Success(null);
    } catch (e) {
      AppLogger.error(
        'Error procesando video: ${task.fileName}',
        tag: 'VideoProcessor',
      );
      return Failure(
        AppError.processingFailed('Error procesando video: $e', e),
      );
    }
  }


  /// Ejecuta FFmpeg con seguimiento de progreso simplificado
  /// SOLID: Single Responsibility - solo ejecuta FFmpeg
  /// DRY: Usa FFmpegProgressService para cálculos simples y precisos
  Future<Result<void, AppError>> _executeFFmpeg(
    List<String> args,
    VideoTask task,
    void Function(double) onProgress,
    void Function(String?) onTimeEstimate,
  ) async {
    try {
      final cmd = args.join(' ');

      // SOLID: Iniciar servicio de progreso simplificado
      _progressService.startProgress();

      if (kDebugMode) {
        AppLogger.debug(
          'Iniciando procesamiento: ${task.fileName}',
          tag: 'VideoProcessor',
        );
      }

      final session = await FFmpegKit.executeAsync(
        cmd,
        (session) async {
          // SOLID: Callback de finalización
          final returnCode = await session.getReturnCode();
          if (ReturnCode.isSuccess(returnCode)) {
            onProgress(1.0); // GARANTIZAR 100%
            onTimeEstimate(null); // Limpiar estimación al completar
            
            if (kDebugMode) {
              AppLogger.debug(
                'FFmpeg completed successfully',
                tag: 'VideoProcessor',
              );
            }
          } else if (ReturnCode.isCancel(returnCode)) {
            AppLogger.info('FFmpeg cancelled by user', tag: 'VideoProcessor');
          } else {
            AppLogger.warning(
              'FFmpeg failed with return code: $returnCode',
              tag: 'VideoProcessor',
            );
          }
          // SOLID: Limpiar sesión al finalizar
          _currentSessionId = null;
        },
        (log) {
          // SOLID: Solo usar logs para información de debug
          if (kDebugMode) {
            final logMessage = log.getMessage();
            if (logMessage.contains('Duration:') ||
                logMessage.contains('time=')) {
              AppLogger.debug(
                'FFmpeg log: ${logMessage.substring(0, math.min(100, logMessage.length))}...',
                tag: 'VideoProcessor',
              );
            }
          }
        },
        (statistics) {
          // SOLID: Usar statistics callback para progreso real
          final timeMs = statistics.getTime();
          if (timeMs <= 0) return;

          final currentTimeSeconds = timeMs / 1000.0;

          // DRY: Calcular progreso basado en duración del video de entrada
          final progress = _calculateProgressFromDuration(
            task,
            currentTimeSeconds,
          );

          // SOLID: Actualizar servicio de progreso
          _progressService.updateProgress(progress, currentTimeSeconds);

          // SOLID: Reportar progreso y tiempo estimado
          onProgress(progress);
          onTimeEstimate(_progressService.calculateTimeRemaining());

          // Performance: Logging solo en debug para evitar interpolación costosa en hot loop
          if (kDebugMode) {
            AppLogger.debug(
              'Progreso: ${(progress * 100).toStringAsFixed(1)}% en ${currentTimeSeconds.toStringAsFixed(1)}s',
              tag: 'VideoProcessor',
            );
          }
        },
      );

      // SOLID: Guardar ID de sesión para cancelación
      _currentSessionId = session.getSessionId();

      // DRY: Esperar finalización de la sesión
      return await _waitForSessionCompletion(
        session,
        onProgress,
        onTimeEstimate,
      );
    } catch (e) {
      AppLogger.error('Error ejecutando FFmpeg: $e', tag: 'VideoProcessor');
      return Failure(
        AppError.processingFailed('Error ejecutando FFmpeg: $e', e),
      );
    }
  }

  /// Calcula progreso basado en duración del video de entrada
  /// SOLID: Single Responsibility - solo calcula progreso
  /// DRY: Método simple y directo sin complejidad innecesaria
  double _calculateProgressFromDuration(
    VideoTask task,
    double currentTimeSeconds,
  ) {
    // SOLID: Usar duración del video de entrada como referencia
    final videoDuration = task.duration;
    if (videoDuration == null || videoDuration <= 0) {
      // DRY: Fallback simple basado en tamaño de archivo
      return _calculateProgressFromFileSize(task, currentTimeSeconds);
    }

    // SOLID: Progreso directo basado en duración del video
    final progress = (currentTimeSeconds / videoDuration).clamp(0.0, 0.99);

    if (kDebugMode) {
      AppLogger.debug(
        'Progreso calculado: ${(progress * 100).toStringAsFixed(1)}% '
        '(${currentTimeSeconds.toStringAsFixed(1)}s/${videoDuration.toStringAsFixed(1)}s)',
        tag: 'VideoProcessor',
      );
    }

    return progress;
  }

  /// Fallback: calcula progreso basado en tamaño de archivo
  /// DRY: Método simple para casos sin duración
  double _calculateProgressFromFileSize(
    VideoTask task,
    double currentTimeSeconds,
  ) {
    if (task.originalSizeBytes == null) {
      return 0.0; // Sin datos para estimar
    }

    // DRY: Estimación simple basada en bitrate promedio
    final sizeMB = task.originalSizeBytes! / (1024 * 1024);
    final estimatedBitrateMbps = _estimateBitrateFromSize(sizeMB);
    final estimatedDurationSeconds = (sizeMB * 8) / estimatedBitrateMbps;
    final clampedDuration = estimatedDurationSeconds.clamp(
      10.0,
      3600.0,
    ); // 10s - 1h

    return (currentTimeSeconds / clampedDuration).clamp(0.0, 0.98);
  }

  /// Estima bitrate basado en tamaño de archivo
  /// DRY: Heurística simple y efectiva
  double _estimateBitrateFromSize(double sizeMB) {
    if (sizeMB < 10) return 1.0; // 1 Mbps para videos pequeños
    if (sizeMB < 50) return 2.0; // 2 Mbps para videos medianos
    if (sizeMB < 100) return 3.0; // 3 Mbps para videos grandes
    return 4.0; // 4 Mbps para videos muy grandes
  }

  /// Espera finalización de la sesión FFmpeg
  ///  DRY: Extraído para reutilización y claridad
  Future<Result<void, AppError>> _waitForSessionCompletion(
    dynamic session,
    void Function(double) onProgress,
    void Function(String?) onTimeEstimate,
  ) async {
    while (true) {
      final returnCode = await session.getReturnCode();
      if (returnCode != null) {
        // Check for cancellation FIRST
        if (ReturnCode.isCancel(returnCode)) {
          AppLogger.info('FFmpeg session cancelled', tag: 'VideoProcessor');
          return Failure(AppError.cancelled());
        }

        if (!ReturnCode.isSuccess(returnCode)) {
          final logs = await session.getAllLogsAsString();
          AppLogger.error('FFmpeg error: $logs', tag: 'VideoProcessor');
          return Failure(
            AppError.processingFailed(
              'Fallo en FFmpeg (${returnCode.getValue()})',
            ),
          );
        }

        // Garantizar 100% al final
        onProgress(1.0);
        onTimeEstimate(null); // Limpiar estimación al completar
        break;
      }
      await Future.delayed(const Duration(milliseconds: 100));
    }

    return const Success(null);
  }


  /// Genera una ruta temporal para el archivo de salida
  /// SOLID: Single Responsibility - solo genera rutas temporales
  /// DRY: Centraliza la lógica de generación de temporales
  String _generateTemporaryPath(String originalPath) {
    final directory = originalPath.substring(0, originalPath.lastIndexOf('/'));
    final fileName = originalPath.substring(originalPath.lastIndexOf('/') + 1);
    final nameWithoutExt = fileName.substring(0, fileName.lastIndexOf('.'));
    final extension = fileName.substring(fileName.lastIndexOf('.'));

    return '$directory/.${nameWithoutExt}_temp$extension';
  }

  /// Cancela el proceso de compresión actual
  ///  SOLID: Single Responsibility - solo cancela sesión activa
  ///  DRY: Método simple y directo
  @override
  void cancelCurrentProcess() {
    if (_currentSessionId != null) {
      AppLogger.info(
        'Cancelando proceso de compresión actual (ID: $_currentSessionId)',
        tag: 'VideoProcessor',
      );
      FFmpegKit.cancel(_currentSessionId!);
      _currentSessionId = null;
    }
  }

  /// Verifica si hay un proceso activo
  ///  SOLID: Single Responsibility - solo verifica estado
  @override
  bool get isProcessing => _currentSessionId != null;
}