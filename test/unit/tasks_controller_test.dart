import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vcompressor/providers/tasks_provider.dart';
import 'package:vcompressor/models/video_task.dart';
import 'package:vcompressor/models/algorithm.dart';

void main() {
  group('TasksController - Core Functionality', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('should initialize with empty task list', () {
      // Arrange & Act
      final tasks = container.read(tasksProvider);

      // Assert
      expect(tasks, isEmpty);
    });

    test('should add a single task correctly', () {
      // Arrange
      final controller = container.read(tasksProvider.notifier);
      final testTask = VideoTask(
        id: 1,
        inputPath: '/test/path/video.mp4',
        fileName: 'test_video.mp4',
        settings: VideoSettings.defaults(),
        originalSizeBytes: 100000000,
        videoWidth: 1920,
        videoHeight: 1080,
        duration: 120.0,
      );

      // Act
      controller.addTask(testTask);
      final tasks = container.read(tasksProvider);

      // Assert
      expect(tasks.length, equals(1));
      expect(tasks.first.id, equals(1));
      expect(tasks.first.fileName, equals('test_video.mp4'));
      expect(tasks.first.isPending, isTrue);
    });

    test('should add multiple tasks without duplication', () {
      // Arrange
      final controller = container.read(tasksProvider.notifier);
      final task1 = VideoTask(
        id: 1,
        inputPath: '/test/video1.mp4',
        fileName: 'video1.mp4',
        settings: VideoSettings.defaults(),
      );
      final task2 = VideoTask(
        id: 2,
        inputPath: '/test/video2.mp4',
        fileName: 'video2.mp4',
        settings: VideoSettings.defaults(),
      );

      // Act
      controller.addTask(task1);
      controller.addTask(task2);
      final tasks = container.read(tasksProvider);

      // Assert
      expect(tasks.length, equals(2));
      expect(tasks.map((t) => t.id).toList(), [1, 2]);
    });

    test('should remove a task by ID', () {
      // Arrange
      final controller = container.read(tasksProvider.notifier);
      final task1 = VideoTask(
        id: 1,
        inputPath: '/test/video1.mp4',
        fileName: 'video1.mp4',
        settings: VideoSettings.defaults(),
      );
      final task2 = VideoTask(
        id: 2,
        inputPath: '/test/video2.mp4',
        fileName: 'video2.mp4',
        settings: VideoSettings.defaults(),
      );

      controller.addTask(task1);
      controller.addTask(task2);

      // Act
      controller.removeTask(1);
      final tasks = container.read(tasksProvider);

      // Assert
      expect(tasks.length, equals(1));
      expect(tasks.first.id, equals(2));
    });

    test('should update task settings', () {
      // Arrange
      final controller = container.read(tasksProvider.notifier);
      final originalTask = VideoTask(
        id: 1,
        inputPath: '/test/video.mp4',
        fileName: 'video.mp4',
        settings: VideoSettings.defaults(),
      );

      controller.addTask(originalTask);

      // Act
      final newSettings = VideoSettings.defaults().copyWith(
        algorithm: CompressionAlgorithm.maximaCalidad,
        scale: 0.5,
      );
      controller.updateSettings(1, newSettings);
      final updatedTasks = container.read(tasksProvider);

      // Assert
      expect(updatedTasks.first.settings.algorithm,
          equals(CompressionAlgorithm.maximaCalidad));
      expect(updatedTasks.first.settings.scale,
          equals(0.5));
    });

    test('should update all settings (batch operation)', () {
      // Arrange
      final controller = container.read(tasksProvider.notifier);
      controller.addTask(VideoTask(
        id: 1,
        inputPath: '/test/video1.mp4',
        fileName: 'video1.mp4',
        settings: VideoSettings.defaults(),
      ));
      controller.addTask(VideoTask(
        id: 2,
        inputPath: '/test/video2.mp4',
        fileName: 'video2.mp4',
        settings: VideoSettings.defaults(),
      ));

      // Act
      final newSettings = VideoSettings.defaults().copyWith(
        algorithm: CompressionAlgorithm.ultraCompresion,
      );
      controller.updateAllSettings(newSettings);
      final tasks = container.read(tasksProvider);

      // Assert
      expect(tasks.every((t) => t.settings.algorithm ==
          CompressionAlgorithm.ultraCompresion), isTrue);
    });

    test('should update task progress from 0 to 1', () {
      // Arrange
      final controller = container.read(tasksProvider.notifier);
      final task = VideoTask(
        id: 1,
        inputPath: '/test/video.mp4',
        fileName: 'video.mp4',
        settings: VideoSettings.defaults(),
      );
      controller.addTask(task);

      // Act - Update progress to processing
      controller.updateTaskProgress(1, 0.25);
      var tasks = container.read(tasksProvider);

      // Assert - Should be processing
      expect(tasks.first.progress, equals(0.25));
      expect(tasks.first.isProcessing, isTrue);
      expect(tasks.first.displayProgress, equals(0.25));

      // Act - Update to 75% progress
      controller.updateTaskProgress(1, 0.75);
      tasks = container.read(tasksProvider);

      // Assert
      expect(tasks.first.progress, equals(0.75));
      expect(tasks.first.isProcessing, isTrue);
    });

    test('should mark task as completed with final size and output path', () {
      // Arrange
      final controller = container.read(tasksProvider.notifier);
      final task = VideoTask(
        id: 1,
        inputPath: '/test/video.mp4',
        fileName: 'video.mp4',
        settings: VideoSettings.defaults(),
        originalSizeBytes: 100000000,
      );
      controller.addTask(task);

      // Act
      controller.markTaskCompleted(1, 50000000, '/output/video.mp4');
      final tasks = container.read(tasksProvider);

      // Assert
      expect(tasks.first.isCompleted, isTrue);
      expect(tasks.first.compressedSizeBytes, equals(50000000));
      expect(tasks.first.outputPath, equals('/output/video.mp4'));
      expect(tasks.first.progress, isNull); // Progress cleared
      expect(tasks.first.compressionRatio, closeTo(50.0, 0.1));
    });

    test('should mark task with error and clear progress', () {
      // Arrange
      final controller = container.read(tasksProvider.notifier);
      final task = VideoTask(
        id: 1,
        inputPath: '/test/video.mp4',
        fileName: 'video.mp4',
        settings: VideoSettings.defaults(),
        progress: 0.5,
      );
      controller.addTask(task);

      // Act
      controller.markTaskError(1, 'Encoding failed: insufficient memory');
      final tasks = container.read(tasksProvider);

      // Assert
      expect(tasks.first.hasError, isTrue);
      expect(tasks.first.errorMessage, equals('Encoding failed: insufficient memory'));
      expect(tasks.first.progress, isNull); // Progress cleared
      expect(tasks.first.isProcessing, isFalse);
    });

    test('should update task thumbnail', () {
      // Arrange
      final controller = container.read(tasksProvider.notifier);
      final task = VideoTask(
        id: 1,
        inputPath: '/test/video.mp4',
        fileName: 'video.mp4',
        settings: VideoSettings.defaults(),
      );
      controller.addTask(task);

      // Act
      controller.updateTaskThumbnail(1, '/cache/thumbnail.jpg');
      final tasks = container.read(tasksProvider);

      // Assert
      expect(tasks.first.thumbnailPath, equals('/cache/thumbnail.jpg'));
    });

    test('should handle task update with copyWith', () {
      // Arrange
      final controller = container.read(tasksProvider.notifier);
      final originalTask = VideoTask(
        id: 1,
        inputPath: '/test/video.mp4',
        fileName: 'test.mp4',
        settings: VideoSettings.defaults(),
      );
      controller.addTask(originalTask);

      // Act - Update entire task
      final updatedTask = originalTask.copyWith(
        settings: VideoSettings.defaults().copyWith(
          algorithm: CompressionAlgorithm.buenaCalidad,
        ),
        videoWidth: 1920,
        videoHeight: 1080,
      );
      controller.updateTask(updatedTask);
      final tasks = container.read(tasksProvider);

      // Assert
      expect(tasks.first.videoWidth, equals(1920));
      expect(tasks.first.videoHeight, equals(1080));
      expect(tasks.first.settings.algorithm,
          equals(CompressionAlgorithm.buenaCalidad));
    });

    test('should cancel compression correctly', () {
      // Arrange
      final controller = container.read(tasksProvider.notifier);

      // Act
      expect(controller.isCancelled, isFalse);
      controller.cancelCompression();
      expect(controller.isCancelled, isTrue);

      // Multiple calls should not cause issues
      controller.cancelCompression();
      expect(controller.isCancelled, isTrue);
    });

    test('should handle state transitions: pending -> processing -> completed',
        () {
      // Arrange
      final controller = container.read(tasksProvider.notifier);
      final task = VideoTask(
        id: 1,
        inputPath: '/test/video.mp4',
        fileName: 'video.mp4',
        settings: VideoSettings.defaults(),
        originalSizeBytes: 100000000,
      );
      controller.addTask(task);

      var tasks = container.read(tasksProvider);
      expect(tasks.first.state, equals(VideoTaskState.pending));

      // Act - Transition to processing
      controller.updateTaskProgress(1, 0.1);
      tasks = container.read(tasksProvider);
      expect(tasks.first.state, equals(VideoTaskState.processing));

      // Act - Transition to completed
      controller.markTaskCompleted(1, 50000000, '/output/video.mp4');
      tasks = container.read(tasksProvider);
      expect(tasks.first.state, equals(VideoTaskState.completed));
    });

    test('should handle state transitions: processing -> error recovery',
        () {
      // Arrange
      final controller = container.read(tasksProvider.notifier);
      final task = VideoTask(
        id: 1,
        inputPath: '/test/video.mp4',
        fileName: 'video.mp4',
        settings: VideoSettings.defaults(),
      );
      controller.addTask(task);

      // Act - Start processing
      controller.updateTaskProgress(1, 0.3);
      var tasks = container.read(tasksProvider);
      expect(tasks.first.state, equals(VideoTaskState.processing));

      // Act - Transition to error
      controller.markTaskError(1, 'Encoding error');
      tasks = container.read(tasksProvider);
      expect(tasks.first.state, equals(VideoTaskState.error));

      // Act - Attempt recovery (start processing again)
      controller.updateTaskProgress(1, 0.1);
      tasks = container.read(tasksProvider);
      expect(tasks.first.state, equals(VideoTaskState.processing));
    });

    test('should provide taskByIdProvider for getting a specific task',
        () {
      // Arrange
      final controller = container.read(tasksProvider.notifier);
      final task = VideoTask(
        id: 123,
        inputPath: '/test/video.mp4',
        fileName: 'video.mp4',
        settings: VideoSettings.defaults(),
      );
      controller.addTask(task);

      // Act
      final retrievedTask = container.read(taskByIdProvider('123'));

      // Assert
      expect(retrievedTask, isNotNull);
      expect(retrievedTask?.id, equals(123));
      expect(retrievedTask?.fileName, equals('video.mp4'));
    });

    test('should return null from taskByIdProvider for non-existent task',
        () {
      // Arrange
      final controller = container.read(tasksProvider.notifier);
      final task = VideoTask(
        id: 1,
        inputPath: '/test/video.mp4',
        fileName: 'video.mp4',
        settings: VideoSettings.defaults(),
      );
      controller.addTask(task);

      // Act
      final retrievedTask = container.read(taskByIdProvider('999'));

      // Assert
      expect(retrievedTask, isNull);
    });
  });
}
