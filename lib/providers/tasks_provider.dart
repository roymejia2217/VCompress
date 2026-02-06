import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';

import 'package:vcompressor/models/video_task.dart';
import 'package:vcompressor/core/logging/app_logger.dart';
import 'package:vcompressor/domain/usecases/add_video_files_usecase.dart';
import 'package:vcompressor/domain/usecases/compress_video_usecase.dart';
import 'package:vcompressor/domain/repositories/video_repository.dart';
import 'package:vcompressor/data/repositories/video_repository_impl.dart';
import 'package:vcompressor/data/services/video_validation_service.dart';
import 'package:vcompressor/data/services/video_processor_service.dart';
import 'package:vcompressor/data/services/file_replacement_service.dart';
import 'package:vcompressor/data/services/media_store_uri_resolver.dart';
import 'package:vcompressor/data/services/file_system_helper.dart';
import 'package:vcompressor/providers/loading_provider.dart';
import 'package:vcompressor/providers/hardware_provider.dart';
import 'package:vcompressor/providers/video_services_provider.dart';
import 'package:vcompressor/providers/progress_provider.dart'; // Import nuevo provider
import 'package:vcompressor/utils/cache_service.dart';
import 'package:vcompressor/utils/format_utils.dart';
import 'package:vcompressor/data/services/media_scanner_service.dart';

final tasksProvider = StateNotifierProvider<TasksController, List<VideoTask>>((
  ref,
) {
  return TasksController(ref);
});

/// Acceso directo a una tarea por ID, ej: ref.watch(taskByIdProvider('123'))
final taskByIdProvider = Provider.family<VideoTask?, String>((ref, taskId) {
  final tasks = ref.watch(tasksProvider);
  try {
    return tasks.firstWhere((task) => task.id.toString() == taskId);
  } catch (e) {
    return null;
  }
});

/// Provider que indica el índice de la tarea que se está procesando actualmente.
/// Usado por la UI para actualizar títulos y scroll sin re-renderizar toda la lista.
final currentProcessingIndexProvider = StateProvider<int>((ref) => 0);

class TasksController extends StateNotifier<List<VideoTask>> {
  final Ref _ref;

  // Servicios inyectados
  late final VideoRepository _repository;
  late final AddVideoFilesUseCase _addFilesUseCase;
  late final CompressVideoUseCase _compressUseCase;
  late final VideoProcessorService _processorService;
  late final FileReplacementService _fileReplacementService;
  late final MediaStoreUriResolver _uriResolver;
  late final MediaScannerService _mediaScanner;

  // Helper centralizado para operaciones de filesystem
  static const _fsHelper = FileSystemHelper();

  // Controla el estado de cancelación GLOBAL de procesos de compresión
  bool _isGlobalCancelled = false;

  TasksController(this._ref) : super(const []) {
    _initializeServices();
  }

  void _initializeServices() {
    _repository = VideoRepositoryImpl(_ref);

    final metadataService = _ref.read(videoMetadataServiceProvider);
    const validationService = VideoValidationService();
    _processorService = _ref.read(videoProcessorServiceProvider);
    _fileReplacementService = const FileReplacementService();
    _uriResolver = const MediaStoreUriResolver();
    _mediaScanner = MediaScannerService();

    _addFilesUseCase = AddVideoFilesUseCase(
      validationService: validationService,
      metadataService: metadataService,
    );

    _compressUseCase = CompressVideoUseCase(
      repository: _repository,
      processor: _processorService,
      fileReplacementService: _fileReplacementService,
      uriResolver: _uriResolver,
    );
  }

  /// Agrega archivos con URIs de MediaStore, ej: [{'path': '/a/b.mp4', 'uri': 'content://...'}]
  /// onInvalidFiles: callback para mostrar notificación cuando hay archivos inválidos (opcional)
  Future<void> addFilesWithUris(
    List<Map<String, String?>> fileData, {
    void Function(List<String> invalidFiles)? onInvalidFiles,
  }) async {
    // Extraer rutas y URIs
    final paths = fileData.map((data) => data['path']!).toList();
    final uris = fileData.map((data) => data['uri']).toList();
    final originalPaths = fileData.map((data) => data['originalPath']).toList();

    // Extrae nombres de archivos (ej: '/dir/video.mp4' -> 'video.mp4') y inicia indicador de carga
    final fileNames = paths.map((path) => path.split('/').last).toList();
    _ref.read(loadingProvider.notifier).startAddingVideos(fileNames: fileNames);

    try {
      AppLogger.info(
        'Iniciando adición de ${paths.length} archivos con URIs',
        tag: 'TasksController',
      );

      // Ejecuta validación y extracción de metadatos de cada archivo
      final result = await _addFilesUseCase.execute(
        paths,
        onProgress: (current, total, fileName) {
          _ref
              .read(loadingProvider.notifier)
              .updateAddingProgress(current, total, 'Procesando $fileName');
        },
      );

      if (result.isSuccess) {
        final addResult = result.data!;
        AppLogger.info(
          'Archivos agregados: ${addResult.validCount} válidos, ${addResult.invalidCount} inválidos',
          tag: 'TasksController',
        );

        // Agrega tareas validadas al estado, incluyendo URIs de MediaStore y rutas originales
        if (addResult.addedTasks.isNotEmpty) {
          final updated = List<VideoTask>.from(state);
          for (int i = 0; i < addResult.addedTasks.length; i++) {
            final task = addResult.addedTasks[i];
            final uri = i < uris.length ? uris[i] : null;
            final originalPath = i < originalPaths.length
                ? originalPaths[i]
                : null;

            // Asigna URI y ruta original, priorizando el originalPath del parámetro sobre el de la tarea
            final taskWithUri = task.copyWith(
              originalContentUri: uri,
              originalPath: originalPath ?? task.originalPath,
            );
            updated.add(taskWithUri);
          }
          state = updated;
        }

        // Mostrar notificaciones si es necesario
        _showNotifications(addResult, onInvalidFiles);
      } else {
        AppLogger.error(
          'Error agregando archivos: ${result.error?.message}',
          tag: 'TasksController',
        );
      }
    } catch (e) {
      AppLogger.error(
        'Error inesperado agregando archivos: $e',
        tag: 'TasksController',
      );
    } finally {
      // Finaliza el indicador de carga al terminar (éxito o error)
      _ref.read(loadingProvider.notifier).finishAddingVideos();
    }
  }

  /// Agrega archivos con soporte para animaciones staggered
  /// Procesa archivos uno por uno para permitir animaciones fluidas
  Future<void> addFiles(List<String> paths) async {
    // Extrae nombres de archivos (ej: '/dir/video.mp4' -> 'video.mp4') y inicia indicador de carga
    final fileNames = paths.map((path) => path.split('/').last).toList();
    _ref.read(loadingProvider.notifier).startAddingVideos(fileNames: fileNames);

    try {
      AppLogger.info(
        'Iniciando adición de ${paths.length} archivos',
        tag: 'TasksController',
      );

      // Ejecuta validación y extracción de metadatos de cada archivo
      final result = await _addFilesUseCase.execute(
        paths,
        onProgress: (current, total, fileName) {
          // Actualiza progreso durante extracción de metadatos (operación costosa)
          _ref
              .read(loadingProvider.notifier)
              .updateAddingProgress(current, total, 'Procesando $fileName');
        },
      );

      if (result.isSuccess) {
        final addResult = result.data!;
        AppLogger.info(
          'Archivos agregados: ${addResult.validCount} válidos, ${addResult.invalidCount} inválidos',
          tag: 'TasksController',
        );

        // Agrega tareas validadas al estado en un solo lote
        if (addResult.addedTasks.isNotEmpty) {
          final updated = List<VideoTask>.from(state);
          updated.addAll(addResult.addedTasks);
          state = updated;
        }

        // Mostrar notificaciones si es necesario
        _showNotifications(addResult, null);
      } else {
        AppLogger.error(
          'Error agregando archivos: ${result.error?.message}',
          tag: 'TasksController',
        );
      }
    } catch (e) {
      AppLogger.error(
        'Error inesperado agregando archivos: $e',
        tag: 'TasksController',
      );
    } finally {
      // Finaliza el indicador de carga al terminar (éxito o error)
      _ref.read(loadingProvider.notifier).finishAddingVideos();
    }
  }

  void _showNotifications(
    AddVideoFilesResult result,
    void Function(List<String>)? onInvalidFiles,
  ) {
    // Mostrar notificación solo si hay archivos inválidos
    if (result.hasInvalidFiles) {
      AppLogger.warning(
        'Archivos rechazados: ${result.invalidFiles.join(', ')}',
        tag: 'TasksController',
      );
      // Delegar visualización de SnackBar al callback del widget que tiene context
      onInvalidFiles?.call(result.invalidFiles);
    }
  }

  Future<void> compressAll({
    required String saveDir,
    void Function(Duration?)? onTimeEstimate,
  }) async {
    try {
      // Resetea flag de cancelación global
      _isGlobalCancelled = false;
      // Resetea índice de procesamiento
      _ref.read(currentProcessingIndexProvider.notifier).state = 0;

      if (state.isEmpty) {
        AppLogger.warning(
          'No hay videos para procesar',
          tag: 'TasksController',
        );
        return;
      }

      // Verifica que las capacidades de hardware estén disponibles antes de procesar
      final hardwareReady = _ref.read(hardwareReadyProvider);
      if (!hardwareReady) {
        AppLogger.error(
          'Hardware capabilities no están disponibles. Cancelando procesamiento.',
          tag: 'TasksController',
        );
        return;
      }

      // Validar que el directorio de salida existe
      final saveDirectory = Directory(saveDir);
      if (!await saveDirectory.exists()) {
        await saveDirectory.create(recursive: true);
      }

      AppLogger.info(
        'Iniciando compresión de ${state.length} videos',
        tag: 'TasksController',
      );

      // Procesa cada tarea individualmente con actualización de progreso
      for (int i = 0; i < state.length; i++) {
        // 1. Chequeo Global: Si se canceló todo, salir del loop
        if (_isGlobalCancelled) {
          AppLogger.info(
            'Compresión global cancelada por usuario',
            tag: 'TasksController',
          );
          break;
        }

        // Actualizar provider de índice actual para la UI
        _ref.read(currentProcessingIndexProvider.notifier).state = i;

        // Obtener estado actual de la tarea (puede haber cambiado por UI)
        var task = state[i];

        // 2. Chequeo Individual: Si esta tarea fue cancelada, saltar a la siguiente
        if (task.isCancelled) {
           AppLogger.info(
            'Saltando tarea cancelada: ${task.fileName}',
            tag: 'TasksController',
          );
          continue;
        }
        
        // Si ya está completada (ej. reintento), saltar
        if (task.isCompleted) continue;

        // Generar ruta de salida
        final outputPath = _fsHelper.buildOutputPath(
          saveDir,
          task.fileName,
          task.settings,
        );

        // PERFORMANCE FIX: 
        // Actualizamos el estado del Task UNA VEZ a 'Processing' (progress > 0).
        // Los updates subsiguientes (0.02, 0.03...) van al `taskProgressProvider` 
        // para NO disparar rebuilds de la lista entera.
        updateTaskProgress(task.id, 0.001); 

        // Comprimir con callback de progreso individual
        final result = await _compressUseCase.execute(task, outputPath, (
          _,
          _,
          percent,
          fileName,
        ) {
          // PERFORMANCE FIX: 
          // Actualizar SOLO el provider de progreso, NO el estado de la lista.
          // Esto evita notifyListeners() masivos.
          _ref.read(taskProgressProvider(task.id).notifier).state = percent;
        }, onTimeEstimate: onTimeEstimate);

        // Verificar estado post-ejecución
        final taskAfter = state.firstWhere((t) => t.id == task.id);
        
        // Si fue cancelada individualmente durante la ejecución
        if (taskAfter.isCancelled) {
           AppLogger.info(
            'Tarea cancelada durante ejecución: ${task.id}',
            tag: 'TasksController',
          );
          continue;
        }
        
        // Si fue cancelada globalmente
        if (_isGlobalCancelled) {
           break;
        }

        if (result.isSuccess) {
          // Limpieza de provider de progreso (ya no es necesario)
          _ref.read(taskProgressProvider(task.id).notifier).state = 1.0;

          // DETERMINAR RUTA FINAL REAL (Robustez ante fallos de sync de estado)
          String finalPath;
          if (task.settings.editSettings.replaceOriginalFile) {
             finalPath = task.originalPath ?? task.inputPath;
          } else {
             finalPath = outputPath;
          }
          
          // VERIFICAR ARCHIVO
          final file = File(finalPath);
          int finalSize = 0;
          
          if (await file.exists()) {
             finalSize = await file.length();
             
             // Escanear archivo para que aparezca en la galería
             await _mediaScanner.scanFile(finalPath);
             
             markTaskCompleted(task.id, finalSize, finalPath);
          } else {
             // Fallback: Si el archivo no está en la ruta calculada, intentamos recuperar
             // la ruta desde el estado (si el usecase la actualizó)
             final completedTask = state.firstWhere((t) => t.id == task.id);
             
             if (completedTask.outputPath != null && await File(completedTask.outputPath!).exists()) {
                markTaskCompleted(task.id, completedTask.compressedSizeBytes!, completedTask.outputPath!);
             } else {
                AppLogger.error('Archivo de salida NO encontrado: $finalPath', tag: 'TasksController');
                markTaskError(task.id, "Error: Archivo de salida no encontrado.");
             }
          }
        } else {
          // Limpieza de provider de progreso
           _ref.read(taskProgressProvider(task.id).notifier).state = 0.0;

          // Marcar error en la lista
          markTaskError(
            task.id,
            result.error?.userMessage ?? 'Error desconocido',
          );
        }
      }

      AppLogger.info(
        'Compresión completada/finalizada',
        tag: 'TasksController',
      );

      // Limpia archivos temporales del caché después de completar todas las compresiones
      await _cleanupCacheAfterCompression();
    } catch (e) {
      AppLogger.error(
        'Error inesperado en compresión: $e',
        tag: 'TasksController',
      );
      rethrow;
    }
  }

  void removeTask(int id) {
    try {
      AppLogger.debug('Eliminando tarea: $id', tag: 'TasksController');
      state = state.where((t) => t.id != id).toList(growable: false);
      // Limpiar provider asociado si queda algo (buena práctica)
      // Aunque autoDispose se encargaría si se usara, aquí es state explícito
    } catch (e) {
      AppLogger.error('Error eliminando tarea: $e', tag: 'TasksController');
    }
  }

  void updateSettings(int id, VideoSettings settings) {
    try {
      AppLogger.debug(
        'Actualizando configuración de tarea: $id',
        tag: 'TasksController',
      );
      state = state
          .map((t) => t.id == id ? t.copyWith(settings: settings) : t)
          .toList(growable: false);
    } catch (e) {
      AppLogger.error(
        'Error actualizando configuración: $e',
        tag: 'TasksController',
      );
    }
  }

  /// Aplica la misma configuración a todas las tareas (procesamiento en lote)
  void updateAllSettings(VideoSettings settings) {
    try {
      AppLogger.info(
        'Aplicando configuración batch a ${state.length} videos',
        tag: 'TasksController',
      );
      state = state
          .map((t) => t.copyWith(settings: settings))
          .toList(growable: false);
    } catch (e) {
      AppLogger.error(
        'Error actualizando configuración batch: $e',
        tag: 'TasksController',
      );
    }
  }

  void updateTaskThumbnail(int id, String thumbnailPath) {
    try {
      AppLogger.debug(
        'Actualizando thumbnail de tarea: $id',
        tag: 'TasksController',
      );
      state = state
          .map((t) => t.id == id ? t.copyWith(thumbnailPath: thumbnailPath) : t)
          .toList(growable: false);
    } catch (e) {
      AppLogger.error(
        'Error actualizando thumbnail: $e',
        tag: 'TasksController',
      );
    }
  }

  void updateTask(VideoTask task) {
    try {
      AppLogger.debug(
        'Actualizando tarea: ${task.fileName}',
        tag: 'TasksController',
      );
      state = state
          .map((t) => t.id == task.id ? task : t)
          .toList(growable: false);
    } catch (e) {
      AppLogger.error('Error actualizando tarea: $e', tag: 'TasksController');
    }
  }

  /// Actualiza progreso de una tarea específica en el estado principal.
  /// NOTA: Usar SOLO para cambios de estado (0 -> 0.01), no para streams continuos.
  void updateTaskProgress(int taskId, double progress) {
    try {
      state = state
          .map((t) => t.id == taskId ? t.copyWith(progress: progress) : t)
          .toList(growable: false);
    } catch (e) {
      AppLogger.error(
        'Error actualizando progreso de tarea $taskId: $e',
        tag: 'TasksController',
      );
    }
  }

  /// Marca una tarea como completada, asignando tamaño final y ruta de salida
  void markTaskCompleted(int taskId, int compressedSize, String outputPath) {
    try {
      AppLogger.info(
        'Tarea completada: $taskId - $outputPath',
        tag: 'TasksController',
      );
      state = state
          .map(
            (t) => t.id == taskId
                ? t.copyWith(
                    clearProgress:
                        true, // Limpia progreso para marcar como completada
                    compressedSizeBytes: compressedSize,
                    outputPath: outputPath,
                    clearErrorMessage:
                        true, // Limpia mensaje de error previo si existía
                  )
                : t,
          )
          .toList(growable: false);
    } catch (e) {
      AppLogger.error(
        'Error marcando tarea como completada: $e',
        tag: 'TasksController',
      );
    }
  }

  /// Marca una tarea con error, asignando el mensaje de error
  void markTaskError(int taskId, String errorMessage) {
    try {
      AppLogger.error(
        'Tarea con error: $taskId - $errorMessage',
        tag: 'TasksController',
      );
      state = state
          .map(
            (t) => t.id == taskId
                ? t.copyWith(
                    clearProgress:
                        true, // Limpia progreso para marcar como error
                    errorMessage: errorMessage,
                  )
                : t,
          )
          .toList(growable: false);
    } catch (e) {
      AppLogger.error(
        'Error marcando tarea con error: $e',
        tag: 'TasksController',
      );
    }
  }

  void addTask(VideoTask task) {
    try {
      AppLogger.debug(
        'Agregando tarea: ${task.fileName}',
        tag: 'TasksController',
      );
      final updated = List<VideoTask>.from(state);
      updated.add(task);
      state = updated;
    } catch (e) {
      AppLogger.error('Error agregando tarea: $e', tag: 'TasksController');
    }
  }

  /// Cancela TODO el proceso de compresión
  void cancelCompression() {
    if (_isGlobalCancelled) return; // Previene múltiples llamadas

    AppLogger.info('Cancelando TODA la compresión', tag: 'TasksController');
    _isGlobalCancelled = true;
    _processorService.cancelCurrentProcess();
  }

  /// Cancela una tarea específica
  void cancelTask(int taskId) {
    AppLogger.info('Cancelando tarea: $taskId', tag: 'TasksController');
    
    // 1. Marcar tarea como cancelada en el estado
    try {
      final task = state.firstWhere((t) => t.id == taskId);
      
      // Si ya está cancelada o completada, ignorar
      if (task.isCancelled || task.isCompleted) return;

      // Actualizar estado
      state = state.map((t) => 
        t.id == taskId ? t.copyWith(isCancelled: true) : t
      ).toList(growable: false);

      // 2. Si está procesando actualmente, detener el procesador
      if (task.isProcessing) {
        AppLogger.info('Deteniendo proceso activo para tarea: $taskId', tag: 'TasksController');
        _processorService.cancelCurrentProcess();
      }
    } catch (e) {
      AppLogger.warning('Intentando cancelar tarea inexistente: $taskId', tag: 'TasksController');
    }
  }

  /// Verifica si la compresión global está cancelada
  bool get isCancelled => _isGlobalCancelled;

  /// Limpia archivos temporales del caché (inputPath, thumbnailPath en /cache/)
  Future<void> _cleanupCacheAfterCompression() async {
    try {
      AppLogger.info(
        'Iniciando limpieza de caché post-compresión',
        tag: 'TasksController',
      );

      // Obtener rutas de archivos temporales de las tareas procesadas
      final temporaryFilePaths = <String>[];

      for (final task in state) {
        // Agregar inputPath si está en caché temporal
        if (_isCachePath(task.inputPath)) {
          temporaryFilePaths.add(task.inputPath);
        }

        // FIX: No eliminar thumbnails aquí. Los thumbnails deben persistir
        // hasta que la tarea sea explícitamente eliminada o limpiada.
        // Anteriormente esto causaba que los thumbnails desaparecieran después de la compresión.
        /*
        if (task.thumbnailPath != null && _isCachePath(task.thumbnailPath!)) {
          temporaryFilePaths.add(task.thumbnailPath!);
        }
        */
      }

      // Limpiar archivos específicos si hay alguno
      if (temporaryFilePaths.isNotEmpty) {
        final cleanupResult = await CacheService.instance.cleanupSpecificFiles(
          temporaryFilePaths,
        );

        if (cleanupResult.isSuccess) {
          final result = cleanupResult.data!;
          AppLogger.info(
            'Caché limpiado: ${result.deletedFiles} archivos, '
            '${FormatUtils.formatBytes(result.deletedSizeBytes)} liberados',
            tag: 'TasksController',
          );
        } else {
          AppLogger.warning(
            'Error limpiando caché específico: ${cleanupResult.error?.message}',
            tag: 'TasksController',
          );
        }
      }

      // Limpiar caché general (archivos temporales antiguos)
      final generalCleanupResult = await CacheService.instance
          .cleanupTemporaryFiles(
            maxAge: const Duration(
              minutes: 30,
            ), // Limpiar archivos más antiguos de 30 minutos
          );

      if (generalCleanupResult.isSuccess) {
        final result = generalCleanupResult.data!;
        if (result.deletedFiles > 0) {
          AppLogger.info(
            'Caché general limpiado: ${result.deletedFiles} archivos adicionales, '
            '${FormatUtils.formatBytes(result.deletedSizeBytes)} liberados',
            tag: 'TasksController',
          );
        }
      } else {
        AppLogger.warning(
          'Error limpiando caché general: ${generalCleanupResult.error?.message}',
          tag: 'TasksController',
        );
      }
    } catch (e) {
      AppLogger.error(
        'Error inesperado en limpieza de caché: $e',
        tag: 'TasksController',
      );
    }
  }

  /// Verifica si una ruta contiene patrones de caché (ej: '/cache/', '/data/user/0/')
  bool _isCachePath(String path) {
    // Patrones de caché comunes en Android
    final cachePatterns = [
      '/cache/',
      '/data/user/0/',
      '/data/data/',
      '/Android/data/',
      'file_picker',
    ];

    // Verificar si la ruta contiene algún patrón de caché
    return cachePatterns.any((pattern) => path.contains(pattern));
  }
}
