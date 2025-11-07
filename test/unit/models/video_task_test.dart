import 'package:flutter_test/flutter_test.dart';
import 'package:vcompressor/models/video_task.dart';

void main() {
  group('VideoTask State Logic', () {
    final baseTask = VideoTask(
      id: 1,
      inputPath: '/test.mp4',
      fileName: 'test.mp4',
      settings: VideoSettings.defaults(),
    );

    // Test 1: Processing prioridad sobre completed (REPROCESAMIENTO)
    test(
      'should prioritize processing state over completed during reprocessing',
      () {
        final task = baseTask.copyWith(
          compressedSizeBytes: 1000000, // Existing completed state
          progress: 0.5, // Active reprocessing
        );

        expect(task.state, equals(VideoTaskState.processing));
        expect(task.isProcessing, isTrue);
        expect(task.isCompleted, isFalse);
      },
    );

    // Test 2: Processing prioridad sobre error (RECOVERY)
    test('should prioritize processing state over error during recovery', () {
      final task = baseTask.copyWith(
        errorMessage: 'Previous error',
        progress: 0.3, // Recovery processing
      );

      expect(task.state, equals(VideoTaskState.processing));
      expect(task.isProcessing, isTrue);
      expect(task.hasError, isFalse);
    });

    // Test 3: Progress 0.0 vs null
    test('should treat progress 0.0 as pending, null as pending', () {
      final taskZeroProgress = baseTask.copyWith(progress: 0.0);
      final taskNullProgress = baseTask; // progress es null

      expect(taskZeroProgress.state, equals(VideoTaskState.pending));
      expect(taskNullProgress.state, equals(VideoTaskState.pending));
    });

    // Test 4: Progress > 0 es processing
    test('should be processing when progress > 0', () {
      final task = baseTask.copyWith(progress: 0.01);

      expect(task.state, equals(VideoTaskState.processing));
      expect(task.isProcessing, isTrue);
    });

    // Test 5: Error sin processing
    test('should show error state when not processing', () {
      final task = baseTask.copyWith(
        errorMessage: 'Test error',
        progress: null,
      );

      expect(task.state, equals(VideoTaskState.error));
      expect(task.hasError, isTrue);
    });

    // Test 6: Completed sin processing ni error
    test('should show completed state when done and not processing', () {
      final task = baseTask.copyWith(
        compressedSizeBytes: 1000000,
        progress: null,
        errorMessage: null,
      );

      expect(task.state, equals(VideoTaskState.completed));
      expect(task.isCompleted, isTrue);
    });

    // Test 7: Pending por defecto
    test('should be pending by default', () {
      expect(baseTask.state, equals(VideoTaskState.pending));
      expect(baseTask.isPending, isTrue);
    });

    // Test 8: displayProgress fallback
    test('should return 0.0 for displayProgress when progress is null', () {
      expect(baseTask.displayProgress, equals(0.0));

      final taskWithProgress = baseTask.copyWith(progress: 0.75);
      expect(taskWithProgress.displayProgress, equals(0.75));
    });

    // Test 9: Edge case - progress exactly 0.0
    test('should be pending when progress is exactly 0.0', () {
      final task = baseTask.copyWith(progress: 0.0);

      expect(task.state, equals(VideoTaskState.pending));
      expect(task.isPending, isTrue);
    });

    // Test 10: Edge case - progress 1.0 (completo pero aún processing)
    test('should be processing when progress is 1.0', () {
      final task = baseTask.copyWith(progress: 1.0);

      expect(task.state, equals(VideoTaskState.processing));
      expect(task.isProcessing, isTrue);
    });
  });

  group('VideoTask State Transitions', () {
    // Test 11: Transition pending → processing
    test('pending to processing transition', () {
      var task = VideoTask(
        id: 1,
        inputPath: '/test.mp4',
        fileName: 'test.mp4',
        settings: VideoSettings.defaults(),
      );

      expect(task.state, VideoTaskState.pending);

      task = task.copyWith(progress: 0.01);
      expect(task.state, VideoTaskState.processing);
    });

    // Test 12: Transition processing → completed
    test('processing to completed transition', () {
      var task = VideoTask(
        id: 1,
        inputPath: '/test.mp4',
        fileName: 'test.mp4',
        settings: VideoSettings.defaults(),
        progress: 0.5,
      );

      expect(task.state, VideoTaskState.processing);

      // CORRECTO: Para completar, DEBE limpiar progress
      task = task.copyWith(
        clearProgress: true, // Clear progress - REQUERIDO para estado completed
        compressedSizeBytes: 1000000,
      );

      expect(task.state, VideoTaskState.completed);
    });

    // Test 13: Transition completed → processing (reprocessing)
    test('completed to processing transition for reprocessing', () {
      var task = VideoTask(
        id: 1,
        inputPath: '/test.mp4',
        fileName: 'test.mp4',
        settings: VideoSettings.defaults(),
        compressedSizeBytes: 1000000,
      );

      expect(task.state, VideoTaskState.completed);

      task = task.copyWith(progress: 0.01); // Start reprocessing
      expect(task.state, VideoTaskState.processing);
    });

    // Test 14: Transition error → processing (recovery)
    test('error to processing transition for recovery', () {
      var task = VideoTask(
        id: 1,
        inputPath: '/test.mp4',
        fileName: 'test.mp4',
        settings: VideoSettings.defaults(),
        errorMessage: 'Previous error',
      );

      expect(task.state, VideoTaskState.error);

      task = task.copyWith(progress: 0.01); // Start recovery
      expect(task.state, VideoTaskState.processing);
    });

    // Test 15: Transition processing → error
    test('processing to error transition', () {
      var task = VideoTask(
        id: 1,
        inputPath: '/test.mp4',
        fileName: 'test.mp4',
        settings: VideoSettings.defaults(),
        progress: 0.5,
      );

      expect(task.state, VideoTaskState.processing);

      // CORRECTO: Para error, DEBE limpiar progress
      task = task.copyWith(
        clearProgress: true, // Clear progress - REQUERIDO para estado error
        errorMessage: 'Processing failed',
      );

      expect(task.state, VideoTaskState.error);
    });
  });

  group('VideoTask Edge Cases', () {
    // Test 16: Multiple conditions true - processing wins
    test('should prioritize processing when multiple conditions are true', () {
      final task = VideoTask(
        id: 1,
        inputPath: '/test.mp4',
        fileName: 'test.mp4',
        settings: VideoSettings.defaults(),
        compressedSizeBytes: 1000000, // completed
        errorMessage: 'Previous error', // error
        progress: 0.3, // processing
      );

      expect(task.state, equals(VideoTaskState.processing));
      expect(task.isProcessing, isTrue);
    });

    // Test 17: Error vs completed - error wins
    test('should prioritize error over completed when not processing', () {
      final task = VideoTask(
        id: 1,
        inputPath: '/test.mp4',
        fileName: 'test.mp4',
        settings: VideoSettings.defaults(),
        compressedSizeBytes: 1000000, // completed
        errorMessage: 'Test error', // error
        progress: null, // not processing
      );

      expect(task.state, equals(VideoTaskState.error));
      expect(task.hasError, isTrue);
    });

    // Test 18: Completed vs pending - completed wins
    test('should prioritize completed over pending when not processing', () {
      final task = VideoTask(
        id: 1,
        inputPath: '/test.mp4',
        fileName: 'test.mp4',
        settings: VideoSettings.defaults(),
        compressedSizeBytes: 1000000, // completed
        progress: null, // not processing
      );

      expect(task.state, equals(VideoTaskState.completed));
      expect(task.isCompleted, isTrue);
    });
  });
}
