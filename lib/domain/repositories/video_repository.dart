import 'package:vcompressor/models/video_task.dart';

/// Repositorio abstracto para la gestión de tareas de video
/// Define el contrato para operaciones CRUD de VideoTask
abstract class VideoRepository {
  /// Obtiene todas las tareas de video
  Future<List<VideoTask>> getTasks();

  /// Agrega una nueva tarea de video
  Future<void> addTask(VideoTask task);

  /// Actualiza una tarea existente
  Future<void> updateTask(VideoTask task);

  /// Elimina una tarea por ID
  Future<void> removeTask(int id);

  /// Actualiza la configuración de una tarea específica
  Future<void> updateTaskSettings(int id, VideoSettings settings);

  /// Actualiza el thumbnail de una tarea específica
  Future<void> updateTaskThumbnail(int id, String thumbnailPath);
}
