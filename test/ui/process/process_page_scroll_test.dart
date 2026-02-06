import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vcompressor/ui/process/process_page.dart';
import 'package:vcompressor/providers/tasks_provider.dart';
import 'package:vcompressor/providers/settings_provider.dart';
import 'package:vcompressor/providers/video_services_provider.dart';
import 'package:vcompressor/providers/loading_provider.dart';
import 'package:vcompressor/providers/hardware_provider.dart';
import 'package:vcompressor/providers/progress_provider.dart';
import 'package:vcompressor/models/video_task.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:vcompressor/l10n/app_localizations.dart';
import 'package:vcompressor/data/services/video_metadata_service.dart';
import 'package:vcompressor/data/services/video_processor_service.dart';
import 'package:vcompressor/core/result/result.dart';
import 'package:vcompressor/core/error/app_error.dart';

// Mock robusto para evitar NoSuchMethodError en llamadas void/Future
class FakeVideoMetadataService implements VideoMetadataService {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// Mock robusto que implementa los métodos críticos
class FakeVideoProcessorService implements VideoProcessorService {
  @override
  Future<Result<void, AppError>> processVideo({
    required VideoTask task,
    required String outputPath,
    required void Function(double) onProgress,
    required void Function(Duration?) onTimeEstimate,
    bool useTemporaryFile = false,
  }) async {
    return const Success(null);
  }

  @override
  void cancelCurrentProcess() {
    // No-op for testing
  }

  @override
  bool get isProcessing => false;
  
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// Minimal LoadingController for test
class TestLoadingController extends LoadingController {
  TestLoadingController() : super();
}

// Test Controller
class TestTasksController extends TasksController {
  // FIX: Declaramos explícitamente 'ref' para poder usarlo en esta subclase
  final Ref ref; 

  TestTasksController(this.ref) : super(ref);

  @override
  Future<void> compressAll({
    required String saveDir,
    void Function(Duration?)? onTimeEstimate,
  }) async {
    // Simulate processing sequence
    for (int i = 0; i < state.length; i++) {
      final task = state[i];

      // 1. Trigger Scroll: Update current processing index
      ref.read(currentProcessingIndexProvider.notifier).state = i;
      
      // 2. Trigger UI Progress: Update the specific provider for this task
      ref.read(taskProgressProvider(task.id).notifier).state = 0.5;

      // 3. Update internal state (consistency check)
      state = [
        for (final t in state)
          if (t.id == task.id) t.copyWith(progress: 0.5) else t
      ];

      // Wait to allow test to verify scroll and UI updates
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Clean up progress for this task (simulate completion)
      ref.read(taskProgressProvider(task.id).notifier).state = 1.0;
    }
    // Keep processing state active for verification so the UI doesn't switch to Results view
    await Future.delayed(const Duration(seconds: 5));
  }
}

// Test SaveDirNotifier
class TestSaveDirNotifier extends SaveDirNotifier {
  TestSaveDirNotifier() : super() {
    state = const AsyncValue.data('/tmp');
  }
}

void main() {
  group('ProcessPage Dynamic Scrolling', () {
    testWidgets('should scroll to reveal off-screen task when it becomes active', (
      WidgetTester tester,
    ) async {
      // 1. Setup Data
      final tasks = List.generate(
        30,
        (index) => VideoTask(
          id: index,
          inputPath: '/video_$index.mp4',
          fileName: 'video_$index.mp4',
          settings: VideoSettings.defaults(),
          originalSizeBytes: 1000 * 1024,
        ),
      );

      // 2. Pump Widget with Overrides
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
             saveDirProvider.overrideWith((ref) => TestSaveDirNotifier()),
             
             // Override services read by TasksController constructor
             videoMetadataServiceProvider.overrideWithValue(FakeVideoMetadataService()), 
             videoProcessorServiceProvider.overrideWithValue(FakeVideoProcessorService()),
             loadingProvider.overrideWith((ref) => TestLoadingController()),
             hardwareReadyProvider.overrideWithValue(true),

             // Override tasksProvider
             tasksProvider.overrideWith((ref) {
               // Pasamos 'ref' correctamente al constructor del mock
               final controller = TestTasksController(ref);
               // Inject initial data manually
               for (var t in tasks) {
                 controller.addTask(t);
               }
               return controller;
             }),
          ],
          child: const MaterialApp(
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: ProcessPage(),
          ),
        ),
      );
      
      // Wait for async init and microtask in ProcessPage
      await tester.pump(); 
      await tester.pump(const Duration(milliseconds: 100)); // Start processing loop

      // Verify initial state: Item 0 is visible
      expect(find.text('video_0.mp4'), findsOneWidget);
      // Item 29 should be off-screen (assumes 30 items don't fit in default test viewport)
      expect(find.text('video_29.mp4'), findsNothing);

      // Advance time step by step to allow frames to pump and scroll logic to execute
      for (int i = 0; i < 40; i++) { 
        await tester.pump(const Duration(milliseconds: 100));
      }
      
      // Final settle to ensure scroll animation completes
      await tester.pumpAndSettle();

      // Verify item 29 is now visible (auto-scroll worked)
      expect(find.text('video_29.mp4'), findsOneWidget);

      // Advance time to allow the "keep alive" timer in TestTasksController to finish
      await tester.pump(const Duration(seconds: 5));
    });
  });
}
