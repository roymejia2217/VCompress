import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vcompressor/providers/tasks_provider.dart';
import 'package:vcompressor/models/video_task.dart';
import 'package:vcompressor/models/algorithm.dart';

void main() {
  group('Video Tasks Workflow Integration Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('should handle complete workflow: add -> configure -> process -> complete',
        () {
      // Arrange
      final controller = container.read(tasksProvider.notifier);

      // Act 1: Add video
      final task1 = VideoTask(
        id: 1,
        inputPath: '/test/video1.mp4',
        fileName: 'video1.mp4',
        settings: VideoSettings.defaults(),
        originalSizeBytes: 100000000,
        duration: 120.0,
      );
      controller.addTask(task1);

      var tasks = container.read(tasksProvider);
      expect(tasks.length, equals(1));
      expect(tasks.first.isPending, isTrue);

      // Act 2: Configure settings
      final newSettings = VideoSettings.defaults().copyWith(
        algorithm: CompressionAlgorithm.buenaCalidad,
        resolution: OutputResolution.p720,
      );
      controller.updateSettings(1, newSettings);

      tasks = container.read(tasksProvider);
      expect(tasks.first.settings.algorithm,
          equals(CompressionAlgorithm.buenaCalidad));

      // Act 3: Start processing
      controller.updateTaskProgress(1, 0.1);
      tasks = container.read(tasksProvider);
      expect(tasks.first.isProcessing, isTrue);

      // Act 4: Progress through compression
      for (double progress = 0.2; progress <= 0.9; progress += 0.2) {
        controller.updateTaskProgress(1, progress);
        tasks = container.read(tasksProvider);
        expect(tasks.first.displayProgress, closeTo(progress, 0.01));
      }

      // Act 5: Complete compression
      controller.markTaskCompleted(1, 50000000, '/output/video1.mp4');
      tasks = container.read(tasksProvider);

      // Assert final state
      expect(tasks.first.isCompleted, isTrue);
      expect(tasks.first.compressedSizeBytes, equals(50000000));
      expect(tasks.first.compressionRatio, closeTo(50.0, 0.1));
    });

    test('should handle batch processing of multiple videos', () {
      // Arrange
      final controller = container.read(tasksProvider.notifier);
      final videos = [
        VideoTask(
          id: 1,
          inputPath: '/test/video1.mp4',
          fileName: 'video1.mp4',
          settings: VideoSettings.defaults(),
          originalSizeBytes: 100000000,
          duration: 60.0,
        ),
        VideoTask(
          id: 2,
          inputPath: '/test/video2.mp4',
          fileName: 'video2.mp4',
          settings: VideoSettings.defaults(),
          originalSizeBytes: 200000000,
          duration: 120.0,
        ),
        VideoTask(
          id: 3,
          inputPath: '/test/video3.mp4',
          fileName: 'video3.mp4',
          settings: VideoSettings.defaults(),
          originalSizeBytes: 150000000,
          duration: 90.0,
        ),
      ];

      // Act: Add all videos
      for (final video in videos) {
        controller.addTask(video);
      }

      var tasks = container.read(tasksProvider);
      expect(tasks.length, equals(3));

      // Act: Apply batch configuration
      final batchSettings = VideoSettings.defaults().copyWith(
        algorithm: CompressionAlgorithm.ultraCompresion,
        removeAudio: true,
      );
      controller.updateAllSettings(batchSettings);

      tasks = container.read(tasksProvider);
      expect(tasks.every((t) => t.settings.removeAudio == true), isTrue);
      expect(
        tasks.every((t) =>
            t.settings.algorithm == CompressionAlgorithm.ultraCompresion),
        isTrue,
      );

      // Act: Process each video
      for (int i = 0; i < 3; i++) {
        final taskId = i + 1;

        // Start processing
        controller.updateTaskProgress(taskId, 0.1);
        controller.updateTaskProgress(taskId, 0.5);
        controller.updateTaskProgress(taskId, 0.9);

        // Complete
        final expectedCompressed = [50000000, 100000000, 75000000][i];
        controller.markTaskCompleted(
          taskId,
          expectedCompressed,
          '/output/video${i + 1}.mp4',
        );
      }

      // Assert: All completed
      tasks = container.read(tasksProvider);
      expect(tasks.every((t) => t.isCompleted), isTrue);
      expect(tasks.every((t) => t.outputPath != null), isTrue);
    });

    test('should handle error and recovery workflow', () {
      // Arrange
      final controller = container.read(tasksProvider.notifier);
      final task = VideoTask(
        id: 1,
        inputPath: '/test/video.mp4',
        fileName: 'video.mp4',
        settings: VideoSettings.defaults(),
      );
      controller.addTask(task);

      // Act 1: Start processing
      controller.updateTaskProgress(1, 0.3);
      var tasks = container.read(tasksProvider);
      expect(tasks.first.isProcessing, isTrue);

      // Act 2: Encounter error
      controller.markTaskError(1, 'Codec not supported');
      tasks = container.read(tasksProvider);
      expect(tasks.first.hasError, isTrue);
      expect(tasks.first.errorMessage, equals('Codec not supported'));

      // Act 3: Retry with different settings
      final newSettings = VideoSettings.defaults().copyWith(
        algorithm: CompressionAlgorithm.maximaCalidad,
      );
      controller.updateSettings(1, newSettings);

      // Act 4: Resume processing
      controller.updateTaskProgress(1, 0.1);
      tasks = container.read(tasksProvider);
      expect(tasks.first.isProcessing, isTrue);

      // Act 5: Complete successfully
      controller.markTaskCompleted(1, 50000000, '/output/video.mp4');
      tasks = container.read(tasksProvider);

      expect(tasks.first.isCompleted, isTrue);
      expect(tasks.first.errorMessage, isNull);
    });

    test('should handle task removal during workflow', () {
      // Arrange
      final controller = container.read(tasksProvider.notifier);

      // Add multiple tasks
      for (int i = 1; i <= 5; i++) {
        controller.addTask(VideoTask(
          id: i,
          inputPath: '/test/video$i.mp4',
          fileName: 'video$i.mp4',
          settings: VideoSettings.defaults(),
        ));
      }

      var tasks = container.read(tasksProvider);
      expect(tasks.length, equals(5));

      // Act: Remove some tasks while processing
      controller.updateTaskProgress(1, 0.5); // Start processing task 1
      controller.updateTaskProgress(3, 0.3); // Start processing task 3

      controller.removeTask(2); // Remove pending task
      controller.removeTask(4); // Remove pending task

      tasks = container.read(tasksProvider);
      expect(tasks.length, equals(3));

      // Assert: Processing tasks still active
      final task1 = tasks.firstWhere((t) => t.id == 1);
      final task3 = tasks.firstWhere((t) => t.id == 3);
      expect(task1.isProcessing, isTrue);
      expect(task3.isProcessing, isTrue);
    });

    test('should handle different compression algorithms in batch', () {
      // Arrange
      final controller = container.read(tasksProvider.notifier);
      const algorithms = CompressionAlgorithm.values;

      // Act: Add task for each algorithm
      for (int i = 0; i < algorithms.length; i++) {
        final task = VideoTask(
          id: i + 1,
          inputPath: '/test/video${i + 1}.mp4',
          fileName: 'video${i + 1}.mp4',
          settings: VideoSettings.defaults().copyWith(
            algorithm: algorithms[i],
          ),
          originalSizeBytes: 100000000,
        );
        controller.addTask(task);
      }

      var tasks = container.read(tasksProvider);

      // Assert: All algorithms represented
      for (int i = 0; i < algorithms.length; i++) {
        expect(tasks[i].settings.algorithm, equals(algorithms[i]));
      }

      // Act: Process all with their respective algorithms
      for (int i = 0; i < algorithms.length; i++) {
        controller.updateTaskProgress(i + 1, 0.5);
        controller.markTaskCompleted(
          i + 1,
          50000000 - (i * 5000000), // Different compression ratios
          '/output/video${i + 1}.mp4',
        );
      }

      tasks = container.read(tasksProvider);
      expect(tasks.every((t) => t.isCompleted), isTrue);
    });

    test('should track progress correctly across multiple tasks', () {
      // Arrange
      final controller = container.read(tasksProvider.notifier);
      const totalTasks = 3;

      for (int i = 1; i <= totalTasks; i++) {
        controller.addTask(VideoTask(
          id: i,
          inputPath: '/test/video$i.mp4',
          fileName: 'video$i.mp4',
          settings: VideoSettings.defaults(),
          originalSizeBytes: 100000000,
        ));
      }

      // Act: Update progress for each task at different rates
      final progressSteps = [
        [0.2, 0.4, 0.6, 0.8, 1.0],
        [0.1, 0.3, 0.5, 0.7, 0.9],
        [0.15, 0.35, 0.55, 0.75, 0.95],
      ];

      for (int taskIdx = 0; taskIdx < totalTasks; taskIdx++) {
        for (final progress in progressSteps[taskIdx]) {
          controller.updateTaskProgress(taskIdx + 1, progress);
          var tasks = container.read(tasksProvider);

          // Assert: Task progress matches
          expect(
            tasks[taskIdx].displayProgress,
            closeTo(progress, 0.001),
          );
        }

        // Complete task
        controller.markTaskCompleted(
          taskIdx + 1,
          50000000,
          '/output/video${taskIdx + 1}.mp4',
        );
      }

      // Final state: all completed
      var tasks = container.read(tasksProvider);
      expect(tasks.every((t) => t.isCompleted), isTrue);
    });

    test('should handle thumbnail updates during processing', () {
      // Arrange
      final controller = container.read(tasksProvider.notifier);
      final task = VideoTask(
        id: 1,
        inputPath: '/test/video.mp4',
        fileName: 'video.mp4',
        settings: VideoSettings.defaults(),
      );
      controller.addTask(task);

      // Act 1: Add thumbnail during processing
      controller.updateTaskProgress(1, 0.1);
      controller.updateTaskThumbnail(1, '/cache/thumb_1.jpg');

      var tasks = container.read(tasksProvider);
      expect(tasks.first.thumbnailPath, equals('/cache/thumb_1.jpg'));
      expect(tasks.first.isProcessing, isTrue);

      // Act 2: Complete and thumbnail persists
      controller.markTaskCompleted(1, 50000000, '/output/video.mp4');
      tasks = container.read(tasksProvider);

      expect(tasks.first.isCompleted, isTrue);
      expect(tasks.first.thumbnailPath, equals('/cache/thumb_1.jpg'));
    });

    test('should preserve task metadata through complete workflow', () {
      // Arrange
      final controller = container.read(tasksProvider.notifier);
      const int videoWidth = 1920;
      const int videoHeight = 1080;
      const double duration = 150.5;
      const double originalFps = 29.97;

      final task = VideoTask(
        id: 1,
        inputPath: '/test/video.mp4',
        fileName: 'test_video.mp4',
        settings: VideoSettings.defaults(),
        originalSizeBytes: 500000000,
        videoWidth: videoWidth,
        videoHeight: videoHeight,
        duration: duration,
        originalFps: originalFps,
        originalPath: '/original/location/test_video.mp4',
      );
      controller.addTask(task);

      // Act: Process through complete workflow
      controller.updateTaskProgress(1, 0.5);
      controller.markTaskCompleted(1, 250000000, '/output/video.mp4');

      var tasks = container.read(tasksProvider);
      final completed = tasks.first;

      // Assert: All metadata preserved
      expect(completed.fileName, equals('test_video.mp4'));
      expect(completed.videoWidth, equals(videoWidth));
      expect(completed.videoHeight, equals(videoHeight));
      expect(completed.duration, equals(duration));
      expect(completed.originalFps, equals(originalFps));
      expect(completed.originalPath, equals('/original/location/test_video.mp4'));
      expect(completed.originalSizeBytes, equals(500000000));
      expect(completed.compressedSizeBytes, equals(250000000));
      expect(completed.compressionRatio, closeTo(50.0, 0.1));
    });

    test('should handle mixed task states simultaneously', () {
      // Arrange
      final controller = container.read(tasksProvider.notifier);

      // Create different states
      controller.addTask(VideoTask(
        id: 1,
        inputPath: '/test/video1.mp4',
        fileName: 'video1.mp4',
        settings: VideoSettings.defaults(),
      )); // Pending

      controller.addTask(VideoTask(
        id: 2,
        inputPath: '/test/video2.mp4',
        fileName: 'video2.mp4',
        settings: VideoSettings.defaults(),
        progress: 0.5,
      )); // Processing (via constructor)

      controller.addTask(VideoTask(
        id: 3,
        inputPath: '/test/video3.mp4',
        fileName: 'video3.mp4',
        settings: VideoSettings.defaults(),
        compressedSizeBytes: 50000000,
      )); // Completed

      var tasks = container.read(tasksProvider);

      // Act: Verify mixed states
      expect(tasks[0].isPending, isTrue);
      expect(tasks[1].isProcessing, isTrue);
      expect(tasks[2].isCompleted, isTrue);

      // Act: Change state 1 to processing
      controller.updateTaskProgress(1, 0.25);

      tasks = container.read(tasksProvider);
      expect(tasks[0].isProcessing, isTrue);
    });
  });
}
