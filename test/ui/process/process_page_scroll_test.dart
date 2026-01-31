import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vcompressor/ui/process/process_page.dart';
import 'package:vcompressor/providers/tasks_provider.dart';
import 'package:vcompressor/providers/settings_provider.dart';
import 'package:vcompressor/providers/video_services_provider.dart';
import 'package:vcompressor/providers/loading_provider.dart';
import 'package:vcompressor/providers/hardware_provider.dart';
import 'package:vcompressor/models/video_task.dart';
import 'package:vcompressor/models/algorithm.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:vcompressor/l10n/app_localizations.dart';
import 'package:vcompressor/data/services/video_metadata_service.dart';
import 'package:vcompressor/data/services/video_processor_service.dart';

// Manual Mocks to replace Mockito
class FakeVideoMetadataService implements VideoMetadataService {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeVideoProcessorService implements VideoProcessorService {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// Minimal LoadingController for test
class TestLoadingController extends LoadingController {
  TestLoadingController() : super();
}

// Test Controller
class TestTasksController extends TasksController {
  TestTasksController(super.ref);

  @override
  Future<void> compressAll({
    required String saveDir,
    required void Function(
      int currentIndex,
      int total,
      double percent,
      String currentFileName,
    )
    onProgress,
    void Function(String?)? onTimeEstimate,
  }) async {
    // Simulate processing sequence
    for (int i = 0; i < state.length; i++) {
      // Notify progress to trigger scroll logic in UI
      onProgress(i, state.length, 0.1, state[i].fileName);
      
      // Update state internally so UI widgets (VideoTaskListItem) see the change
      state = [
        for (final t in state)
          if (t.id == state[i].id) t.copyWith(progress: 0.1) else t
      ];

      // Wait to allow test to verify scroll
      await Future.delayed(const Duration(milliseconds: 100));
    }
    // Keep processing state active for verification so the UI doesn't switch to Results view
    await Future.delayed(const Duration(seconds: 5));
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
             saveDirProvider.overrideWith((ref) => Future.value('/tmp')),
             
             // Override services read by TasksController constructor
             videoMetadataServiceProvider.overrideWithValue(FakeVideoMetadataService()), 
             videoProcessorServiceProvider.overrideWithValue(FakeVideoProcessorService()),
             loadingProvider.overrideWith((ref) => TestLoadingController()),
             hardwareReadyProvider.overrideWithValue(true),

             // Override tasksProvider
             tasksProvider.overrideWith((ref) {
               final controller = TestTasksController(ref);
               // Inject initial data manually
               for(var t in tasks) controller.addTask(t);
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
      
      // Wait for async init
      await tester.pump(); 
      await tester.pump(const Duration(milliseconds: 100)); // Start processing

      // Verify initial state: Item 0 is visible
      expect(find.text('video_0.mp4'), findsOneWidget);
      // Item 29 should be off-screen (assumes 30 items don't fit in default test viewport)
      // Standard test screen is 800x600. 30 items * ~80 height = 2400 > 600.
      expect(find.text('video_29.mp4'), findsNothing);

      // Advance time step by step to allow frames to pump and scroll logic to execute
      // This ensures addPostFrameCallback callbacks (triggered by onProgress) actually run
      for (int i = 0; i < 40; i++) { // 40 * 100ms = 4 seconds
        await tester.pump(const Duration(milliseconds: 100));
      }
      
      // Wait for scroll animation (500ms in code)
      await tester.pumpAndSettle();

      // Verify item 29 is now visible
      expect(find.text('video_29.mp4'), findsOneWidget);

      // Advance time to allow the "keep alive" timer in TestTasksController to finish
      await tester.pump(const Duration(seconds: 5));
    });
  });
}