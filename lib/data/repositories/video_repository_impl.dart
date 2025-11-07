import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:vcompressor/domain/repositories/video_repository.dart';
import 'package:vcompressor/models/video_task.dart';
import 'package:vcompressor/core/logging/app_logger.dart';
import 'package:vcompressor/providers/tasks_provider.dart';

/// Implementación concreta del repositorio de video
/// Utiliza Riverpod para la gestión de estado
class VideoRepositoryImpl implements VideoRepository {
  final Ref _ref;

  const VideoRepositoryImpl(this._ref);

  @override
  Future<List<VideoTask>> getTasks() async {
    try {
      AppLogger.debug('Obteniendo tareas de video', tag: 'VideoRepository');
      return _ref.read(tasksProvider);
    } catch (e) {
      AppLogger.error('Error obteniendo tareas: $e', tag: 'VideoRepository');
      return [];
    }
  }

  @override
  Future<void> addTask(VideoTask task) async {
    try {
      AppLogger.debug(
        'Agregando tarea: ${task.fileName}',
        tag: 'VideoRepository',
      );
      _ref.read(tasksProvider.notifier).addTask(task);
    } catch (e) {
      AppLogger.error('Error agregando tarea: $e', tag: 'VideoRepository');
      rethrow;
    }
  }

  @override
  Future<void> updateTask(VideoTask task) async {
    try {
      AppLogger.debug(
        'Actualizando tarea: ${task.fileName}',
        tag: 'VideoRepository',
      );
      _ref.read(tasksProvider.notifier).updateTask(task);
    } catch (e) {
      AppLogger.error('Error actualizando tarea: $e', tag: 'VideoRepository');
      rethrow;
    }
  }

  @override
  Future<void> removeTask(int id) async {
    try {
      AppLogger.debug('Eliminando tarea: $id', tag: 'VideoRepository');
      _ref.read(tasksProvider.notifier).removeTask(id);
    } catch (e) {
      AppLogger.error('Error eliminando tarea: $e', tag: 'VideoRepository');
      rethrow;
    }
  }

  @override
  Future<void> updateTaskSettings(int id, VideoSettings settings) async {
    try {
      AppLogger.debug(
        'Actualizando configuración de tarea: $id',
        tag: 'VideoRepository',
      );
      _ref.read(tasksProvider.notifier).updateSettings(id, settings);
    } catch (e) {
      AppLogger.error(
        'Error actualizando configuración: $e',
        tag: 'VideoRepository',
      );
      rethrow;
    }
  }

  @override
  Future<void> updateTaskThumbnail(int id, String thumbnailPath) async {
    try {
      AppLogger.debug(
        'Actualizando thumbnail de tarea: $id',
        tag: 'VideoRepository',
      );
      _ref.read(tasksProvider.notifier).updateTaskThumbnail(id, thumbnailPath);
    } catch (e) {
      AppLogger.error(
        'Error actualizando thumbnail: $e',
        tag: 'VideoRepository',
      );
      rethrow;
    }
  }
}

// Provider para la inyección de dependencias
final videoRepositoryProvider = Provider<VideoRepository>((ref) {
  return VideoRepositoryImpl(ref);
});
