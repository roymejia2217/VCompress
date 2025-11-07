import 'package:vcompressor/models/video_task.dart';
import 'package:vcompressor/core/result/result.dart';
import 'package:vcompressor/core/error/app_error.dart';
import 'package:vcompressor/data/services/video_metadata_service.dart';
import 'package:vcompressor/data/services/video_validation_service.dart';

/// Callback de progreso con parámetros: current (1-based), total, fileName
typedef ProgressCallback =
    void Function(int current, int total, String fileName);

/// Resultado de agregar archivos de video
class AddVideoFilesResult {
  final List<VideoTask> addedTasks;
  final List<String> invalidFiles;
  final int validCount;
  final int invalidCount;

  const AddVideoFilesResult({
    required this.addedTasks,
    required this.invalidFiles,
  }) : validCount = addedTasks.length,
       invalidCount = invalidFiles.length;

  bool get hasInvalidFiles => invalidFiles.isNotEmpty;
}

/// Caso de uso para agregar archivos de video
class AddVideoFilesUseCase {
  final VideoValidationService validationService;
  final VideoMetadataService metadataService;

  const AddVideoFilesUseCase({
    required this.validationService,
    required this.metadataService,
  });

  /// Valida y extrae metadatos de cada archivo, reportando progreso mediante callback opcional
  Future<Result<AddVideoFilesResult, AppError>> execute(
    List<String> paths, {
    ProgressCallback? onProgress,
  }) async {
    try {
      final addedTasks = <VideoTask>[];
      final invalidFiles = <String>[];
      final totalFiles = paths.length;

      for (int i = 0; i < paths.length; i++) {
        final path = paths[i];
        final fileName = path.split('/').last;
        final currentIndex = i + 1; // 1-based para UX

        // Validar archivo individual
        final validationResult = await validationService.validateFiles([path]);
        if (!validationResult.hasValidFiles) {
          invalidFiles.add(path);
          // Reporta progreso para archivos inválidos
          onProgress?.call(currentIndex, totalFiles, fileName);
          continue;
        }

        // Reporta progreso antes de operación costosa para feedback inmediato
        onProgress?.call(currentIndex, totalFiles, fileName);

        // Extrae metadatos del video (operación costosa con FFmpeg y generación de thumbnail)
        final metadata = await metadataService.extractMetadata(path);

        // Crea tarea con metadatos extraídos
        final task = VideoTask(
          id:
              DateTime.now().millisecondsSinceEpoch +
              i, // Timestamp único por archivo
          inputPath: path,
          fileName: fileName,
          settings: VideoSettings.defaults(),
          originalSizeBytes: metadata.fileSize,
          thumbnailPath: metadata.thumbnailPath,
          videoWidth: metadata.width,
          videoHeight: metadata.height,
          duration: metadata.duration,
          originalFps: metadata.fps, // Conserva FPS original para configuración
          originalPath:
              path, // Conserva ruta original para regeneración de caché
        );

        addedTasks.add(task);
      }

      final result = AddVideoFilesResult(
        addedTasks: addedTasks,
        invalidFiles: invalidFiles,
      );

      return Success(result);
    } catch (e) {
      return Failure(AppError.fromException(e, StackTrace.current));
    }
  }
}
