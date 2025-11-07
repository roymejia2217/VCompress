import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vcompressor/providers/tasks_provider.dart';
import 'package:vcompressor/models/video_task.dart';

/// Pruebas unitarias para verificar que no hay duplicación de videos
/// en la lista cuando se agrega un solo archivo
void main() {
  group('TasksController - Pruebas de Duplicación', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('agregar un archivo no debe duplicar la tarea', () async {
      // Arrange: Obtener el controller
      final controller = container.read(tasksProvider.notifier);

      // Act: Simular la adición de un archivo (usando paths ficticios para testing)
      final initialTaskCount = container.read(tasksProvider).length;

      // Verificar que inicialmente no hay tareas
      expect(initialTaskCount, 0);

      // Crear una tarea manualmente para simular el comportamiento esperado
      final testTask = VideoTask(
        id: DateTime.now().millisecondsSinceEpoch,
        inputPath: '/test/path/video.mp4',
        fileName: 'video.mp4',
        settings: VideoSettings.defaults(),
        originalSizeBytes: 1000000,
        videoWidth: 1920,
        videoHeight: 1080,
        duration: 60.0,
      );

      // Agregar la tarea una sola vez
      controller.addTask(testTask);

      // Assert: Verificar que solo hay una tarea
      final finalTasks = container.read(tasksProvider);
      expect(
        finalTasks.length,
        1,
        reason: 'Solo debe haber una tarea después de agregar un video',
      );
      expect(finalTasks.first.fileName, 'video.mp4');
    });

    test('agregar múltiples archivos no debe duplicar las tareas', () async {
      // Arrange
      final controller = container.read(tasksProvider.notifier);

      // Act: Agregar 3 tareas diferentes
      final tasks = [
        VideoTask(
          id: 1,
          inputPath: '/test/path/video1.mp4',
          fileName: 'video1.mp4',
          settings: VideoSettings.defaults(),
          originalSizeBytes: 1000000,
          videoWidth: 1920,
          videoHeight: 1080,
          duration: 60.0,
        ),
        VideoTask(
          id: 2,
          inputPath: '/test/path/video2.mp4',
          fileName: 'video2.mp4',
          settings: VideoSettings.defaults(),
          originalSizeBytes: 2000000,
          videoWidth: 1920,
          videoHeight: 1080,
          duration: 120.0,
        ),
        VideoTask(
          id: 3,
          inputPath: '/test/path/video3.mp4',
          fileName: 'video3.mp4',
          settings: VideoSettings.defaults(),
          originalSizeBytes: 3000000,
          videoWidth: 1920,
          videoHeight: 1080,
          duration: 180.0,
        ),
      ];

      for (final task in tasks) {
        controller.addTask(task);
      }

      // Assert: Verificar que hay exactamente 3 tareas
      final finalTasks = container.read(tasksProvider);
      expect(finalTasks.length, 3, reason: 'Debe haber exactamente 3 tareas');

      // Verificar que no hay duplicados por ID
      final ids = finalTasks.map((t) => t.id).toSet();
      expect(ids.length, 3, reason: 'Todos los IDs deben ser únicos');

      // Verificar que no hay duplicados por nombre
      final fileNames = finalTasks.map((t) => t.fileName).toSet();
      expect(fileNames.length, 3, reason: 'Todos los nombres deben ser únicos');
    });

    test('removeTask debe eliminar solo una tarea específica', () async {
      // Arrange: Agregar 2 tareas
      final controller = container.read(tasksProvider.notifier);

      final task1 = VideoTask(
        id: 100,
        inputPath: '/test/path/video1.mp4',
        fileName: 'video1.mp4',
        settings: VideoSettings.defaults(),
        originalSizeBytes: 1000000,
        videoWidth: 1920,
        videoHeight: 1080,
        duration: 60.0,
      );

      final task2 = VideoTask(
        id: 200,
        inputPath: '/test/path/video2.mp4',
        fileName: 'video2.mp4',
        settings: VideoSettings.defaults(),
        originalSizeBytes: 2000000,
        videoWidth: 1920,
        videoHeight: 1080,
        duration: 120.0,
      );

      controller.addTask(task1);
      controller.addTask(task2);

      // Verificar que hay 2 tareas
      expect(container.read(tasksProvider).length, 2);

      // Act: Eliminar una tarea
      controller.removeTask(100);

      // Assert: Verificar que queda solo 1 tarea y es la correcta
      final finalTasks = container.read(tasksProvider);
      expect(finalTasks.length, 1, reason: 'Debe quedar solo una tarea');
      expect(
        finalTasks.first.id,
        200,
        reason: 'Debe quedar la tarea con ID 200',
      );
      expect(finalTasks.first.fileName, 'video2.mp4');
    });
  });
}
