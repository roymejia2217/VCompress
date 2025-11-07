import 'package:vcompressor/models/video_task.dart';
import 'package:vcompressor/domain/repositories/video_repository.dart';
import 'package:vcompressor/data/services/video_processor_service.dart';
import 'package:vcompressor/data/services/file_replacement_service.dart';
import 'package:vcompressor/data/services/media_store_uri_resolver.dart';
import 'package:vcompressor/data/services/file_system_helper.dart';
import 'package:vcompressor/core/result/result.dart';
import 'package:vcompressor/core/error/app_error.dart';
import 'package:vcompressor/core/logging/app_logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'dart:io';

/// Caso de uso para la compresión de video
/// Encapsula la lógica de negocio para el procesamiento de videos
class CompressVideoUseCase {
  final VideoRepository _repository;
  final VideoProcessorService _processor;
  final FileReplacementService _fileReplacementService;
  final MediaStoreUriResolver _uriResolver;

  // DRY: Helper centralizado para operaciones de filesystem
  static const _fsHelper = FileSystemHelper();

  const CompressVideoUseCase({
    required VideoRepository repository,
    required VideoProcessorService processor,
    required FileReplacementService fileReplacementService,
    required MediaStoreUriResolver uriResolver,
  }) : _repository = repository,
       _processor = processor,
       _fileReplacementService = fileReplacementService,
       _uriResolver = uriResolver;

  /// Ejecuta la compresión de un video específico
  Future<Result<void, AppError>> execute(
    VideoTask task,
    String outputPath,
    void Function(
      int currentIndex,
      int total,
      double percent,
      String currentFileName,
    )
    onProgress, {
    void Function(String?)? onTimeEstimate,
  }) async {
    try {
      // Notificar inicio del procesamiento
      onProgress(0, 1, 0.0, task.fileName);

      // Detectar y regenerar cache si necesario
      final inputPathResult = await _ensureInputPathExists(task);

      if (inputPathResult.isFailure) {
        return inputPathResult;
      }

      final effectiveInputPath = inputPathResult.data!;

      // Crear task con inputPath regenerado si es necesario
      final effectiveTask = effectiveInputPath != task.inputPath
          ? task.copyWith(inputPath: effectiveInputPath)
          : task;

      // Determinar si usar archivo temporal para reemplazo
      final useTemporaryFile = task.settings.editSettings.replaceOriginalFile;

      // Procesar el video
      final result = await _processor.processVideo(
        task: effectiveTask,
        outputPath: outputPath,
        onProgress: (progress) {
          onProgress(0, 1, progress, task.fileName);
        },
        onTimeEstimate: onTimeEstimate ?? (_) {},
        useTemporaryFile: useTemporaryFile,
      );

      if (result.isFailure) {
        return result;
      }

      // Manejar reemplazo de archivo original si está habilitado
      String finalOutputPath = outputPath;
      int? compressedSizeBytes;

      if (useTemporaryFile && task.settings.editSettings.replaceOriginalFile) {
        // Calcular el tamaño del archivo temporal DESPUÉS del procesamiento
        final tempPath = _fsHelper.generateTemporaryPath(outputPath);
        compressedSizeBytes = await _getFileSize(tempPath);

        final replaceResult = await _handleFileReplacement(task, outputPath);
        if (replaceResult.isFailure) {
          return replaceResult;
        }
        // Cuando se reemplaza el archivo original, el video final está en la ubicación original
        // Usar originalPath si está disponible, sino inputPath como fallback
        finalOutputPath = task.originalPath ?? task.inputPath;
      } else {
        // Comportamiento normal: calcular tamaño del archivo de salida
        compressedSizeBytes = await _getFileSize(outputPath);
      }

      // Actualizar la tarea con el resultado
      final updatedTask = task.copyWith(
        outputPath: finalOutputPath,
        compressedSizeBytes: compressedSizeBytes,
      );

      // DEBUG: Log estructurado con contexto completo
      AppLogger.compressionStarted(
        taskId: task.id.toString(),
        inputPath: task.inputPath,
        fileSizeBytes: task.fileSizeBytes,
        algorithm: task.settings.algorithm.name,
        quality: task.settings.compressionSettings['quality'] ?? 80,
        outputPath: finalOutputPath,
      );

      await _repository.updateTask(updatedTask);

      // Notificar completado
      onProgress(1, 1, 1.0, task.fileName);

      return const Success(null);
    } catch (e) {
      return Failure(AppError.fromException(e, StackTrace.current));
    }
  }

  /// Ejecuta la compresión de múltiples videos
  Future<Result<void, AppError>> executeBatch(
    List<VideoTask> tasks,
    String saveDir,
    void Function(
      int currentIndex,
      int total,
      double percent,
      String currentFileName,
    )
    onProgress, {
    void Function(String?)? onTimeEstimate,
  }) async {
    try {
      for (int i = 0; i < tasks.length; i++) {
        final task = tasks[i];
        final outputPath = _fsHelper.buildOutputPath(
          saveDir,
          task.fileName,
          task.settings,
        );

        final result = await execute(task, outputPath, (
          currentIndex,
          total,
          percent,
          fileName,
        ) {
          // Calcular progreso total: archivos completados + progreso del archivo actual
          final completedProgress = i / tasks.length;
          final currentFileProgress = percent / tasks.length;
          final totalProgress = (completedProgress + currentFileProgress).clamp(
            0.0,
            1.0,
          );

          onProgress(i, tasks.length, totalProgress, fileName);
        }, onTimeEstimate: onTimeEstimate);

        if (result.isFailure) {
          return result;
        }
      }

      return const Success(null);
    } catch (e) {
      return Failure(AppError.fromException(e, StackTrace.current));
    }
  }


  /// Obtiene el tamaño de un archivo
  Future<int?> _getFileSize(String filePath) async {
    try {
      // Una sola syscall en lugar de exists() + length()
      final stat = await File(filePath).stat();
      if (stat.type != FileSystemEntityType.notFound) {
        return stat.size;
      }
    } catch (e) {
      // Ignorar errores al obtener el tamaño
    }
    return null;
  }

  /// Reemplaza el archivo original con el video comprimido usando MediaStore URI
  Future<Result<void, AppError>> _handleFileReplacement(
    VideoTask task,
    String outputPath,
  ) async {
    try {
      // Obtener URI del archivo original
      String? contentUri = task.originalContentUri;

      // Si no hay URI, intentar resolverlo
      if (contentUri == null) {
        final uriResult = await _uriResolver.resolveUriFromPath(task.inputPath);
        if (uriResult.isSuccess) {
          contentUri = uriResult.data;
        }
      }

      // Si no se puede obtener URI, fallar
      if (contentUri == null) {
        return Failure(
          AppError.mediaStoreError(
            'No se pudo obtener URI para reemplazar archivo: ${task.fileName}',
          ),
        );
      }

      // Generar ruta temporal usando helper centralizado
      final tempPath = _fsHelper.generateTemporaryPath(outputPath);

      // Verificar que el archivo temporal existe
      final tempFile = File(tempPath);
      if (!await tempFile.exists()) {
        return Failure(
          AppError.fileNotFound('Archivo temporal no encontrado: $tempPath'),
        );
      }

      // Reemplazar archivo usando el servicio
      final replaceResult = await _fileReplacementService.replaceFileAtUri(
        contentUri: contentUri,
        tempFilePath: tempPath,
      );

      if (replaceResult.isSuccess) {
        // Limpiar archivo temporal después del reemplazo exitoso
        try {
          await tempFile.delete();
        } catch (e) {
          // Ignorar errores al limpiar temporal
        }
      }

      return replaceResult;
    } catch (e) {
      return Failure(AppError.replaceFailed(task.fileName, e));
    }
  }


  /// Verifica que inputPath existe, regenerándolo desde originalPath si fue eliminado del caché
  Future<Result<String, AppError>> _ensureInputPathExists(
    VideoTask task,
  ) async {
    final inputFile = File(task.inputPath);

    // Si existe, validar que es accesible
    if (await inputFile.exists()) {
      try {
        // Verificar que se puede leer
        await inputFile.readAsBytes();
        return Success(task.inputPath);
      } catch (e) {
        AppLogger.warning(
          'Archivo de cache corrupto, regenerando: ${task.inputPath}',
          tag: 'CompressVideoUseCase',
        );
        // Continuar a regeneración
      }
    }

    // Si no existe o está corrupto, regenerar desde originalPath
    if (task.originalPath != null) {
      AppLogger.info(
        'Regenerando cache desde original: ${task.originalPath}',
        tag: 'CompressVideoUseCase',
      );

      final result = await _regenerateCache(task.originalPath!);
      if (result.isSuccess) {
        return Success(result.data!);
      } else {
        return Failure(result.error!);
      }
    }

    // Si no hay originalPath, error explícito
    return Failure(
      AppError.fileNotFound(
        'No se puede encontrar el archivo de entrada: ${task.inputPath}',
      ),
    );
  }

  /// Copia archivo original al caché temporal con timestamp, ej: '/cache/cache_1234567890.mp4'
  Future<Result<String, AppError>> _regenerateCache(String originalPath) async {
    try {
      final originalFile = File(originalPath);

      // Verificar que original existe
      if (!await originalFile.exists()) {
        return Failure(AppError.originalFileNotFound(originalPath));
      }

      // Generar nuevo cache path con timestamp
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = path.extension(originalPath);
      final newCachePath = '${tempDir.path}/cache_$timestamp$extension';

      // Copiar archivo a cache usando File.copy() nativo
      await originalFile.copy(newCachePath);

      return Success(newCachePath);
    } catch (e) {
      return Failure(AppError.cacheRegenerationFailed(originalPath));
    }
  }
}
