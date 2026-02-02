import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:vcompressor/providers/settings_provider.dart';
import 'package:vcompressor/core/constants/app_constants.dart';
import 'package:vcompressor/utils/cache_service.dart';

// --- Mocks ---

class MockPathProviderPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  String? downloadsPath;
  String? externalStoragePath;

  @override
  Future<String?> getDownloadsPath() async => downloadsPath;

  @override
  Future<String?> getExternalStoragePath() async => externalStoragePath;
}

// --- Test Suite ---

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;
  late MockPathProviderPlatform mockPathProvider;
  late Directory tempTestDir;

  // Mock for directory picker
  Future<String?> Function()? mockDirectoryPicker;

  setUp(() async {
    // 1. Reset SharedPreferences
    SharedPreferences.setMockInitialValues({});
    // Initialize CacheService (singleton) properly by clearing or setting empty
    // Since we can't easily reset the singleton, we rely on SharedPreferences mock being fresh
    // But CacheService might have cached the prefs instance.
    // We will use CacheService.instance.clear() if available or overwrite keys explicitly.
    
    // 2. Mock Path Provider
    mockPathProvider = MockPathProviderPlatform();
    PathProviderPlatform.instance = mockPathProvider;

    // 3. Setup Temp Directory
    tempTestDir = await Directory.systemTemp.createTemp('vcompress_test_');
    mockPathProvider.downloadsPath = '${tempTestDir.path}/Downloads';
    mockPathProvider.externalStoragePath = '${tempTestDir.path}/External';

    // 4. Default mock picker (returns null/cancel)
    mockDirectoryPicker = () async => null;

    // 5. Setup Riverpod Container with Override
    container = ProviderContainer(
      overrides: [
        saveDirProvider.overrideWith(
          (ref) => SaveDirNotifier(directoryPicker: () => mockDirectoryPicker!()),
        ),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    if (await tempTestDir.exists()) {
      await tempTestDir.delete(recursive: true);
    }
  });

  // Helper to wait for AsyncValue data
  Future<String> waitForSaveDir() async {
    // Check if already has data
    var state = container.read(saveDirProvider);
    if (state.hasValue) return state.requireValue;

    // Wait for stream emission
    final stream = container.read(saveDirProvider.notifier).stream;
    await for (final value in stream) {
      if (value.hasValue) return value.requireValue;
      if (value.hasError) throw value.error!;
    }
    throw Exception('Stream closed without value');
  }

  group('SaveDirNotifier Tests', () {
    test('Initialize: Should use default system path when cache is empty',
        () async {
      // Arrange
      final expectedPath =
          '${mockPathProvider.downloadsPath}/${AppConstants.defaultSaveFolder}';

      // Act
      final initValue = await waitForSaveDir();

      // Assert
      expect(initValue, equals(expectedPath));
      expect(await Directory(initValue).exists(), isTrue);
    });

    test('Initialize: Should use fallback if system paths are null', () async {
      // Arrange
      mockPathProvider.downloadsPath = null;
      mockPathProvider.externalStoragePath = null;
      
      // Re-create container to trigger init with new mock values
      container.dispose();
      container = ProviderContainer(
        overrides: [
          saveDirProvider.overrideWith(
            (ref) => SaveDirNotifier(directoryPicker: () => mockDirectoryPicker!()),
          ),
        ],
      );

      // Act
      final initValue = await waitForSaveDir();

      // Assert
      expect(
          initValue,
          contains(
              AppConstants.defaultSaveFolder));
      expect(await Directory(initValue).exists(), isTrue);
    });

    test('Initialize: Should load saved path from CacheService if valid',
        () async {
      // Arrange
      final customDir =
          await Directory('${tempTestDir.path}/CustomSaved').create();
      
      // Use CacheService to set value, ensuring it updates the underlying prefs
      await CacheService.instance.setSetting('saveDir', customDir.path);

      // Re-create container to trigger init
      container.dispose();
      container = ProviderContainer(
        overrides: [
          saveDirProvider.overrideWith(
            (ref) => SaveDirNotifier(directoryPicker: () => mockDirectoryPicker!()),
          ),
        ],
      );

      // Act
      final loadedPath = await waitForSaveDir();

      // Assert
      expect(loadedPath, equals(customDir.path));
    });

    test('PickDirectory: Should update state and cache on success', () async {
      // Arrange
      final newDir = await Directory('${tempTestDir.path}/NewSelected').create();
      mockDirectoryPicker = () async => newDir.path;

      final notifier = container.read(saveDirProvider.notifier);
      await waitForSaveDir(); // Ensure init

      // Act
      await notifier.pickDirectory();

      // Assert
      final currentState = container.read(saveDirProvider);
      expect(currentState.value, equals(newDir.path));

      final cached = await CacheService.instance.getSetting<String>('saveDir');
      expect(cached, equals(newDir.path));
    });

    test('PickDirectory: Should handle user cancellation gracefully', () async {
      // Arrange
      final initialDir =
          await Directory('${tempTestDir.path}/Initial').create();
      await CacheService.instance.setSetting('saveDir', initialDir.path);

      // Re-create container for clean state
      container.dispose();
      container = ProviderContainer(
        overrides: [
          saveDirProvider.overrideWith(
            (ref) => SaveDirNotifier(directoryPicker: () async => null), // Cancel logic
          ),
        ],
      );

      final notifier = container.read(saveDirProvider.notifier);
      await waitForSaveDir(); // Init

      // Act
      await notifier.pickDirectory();

      // Assert
      final currentState = container.read(saveDirProvider);
      expect(currentState.value, equals(initialDir.path));
    });

    test('PickDirectory: Should handle write permission error', () async {
      // Arrange
      final validDir = '${tempTestDir.path}/ValidWrite';
      mockDirectoryPicker = () async => validDir;
      
      final notifier = container.read(saveDirProvider.notifier);
      await waitForSaveDir();
      
      // Act
      await notifier.pickDirectory();
      
      // Assert
      final currentState = container.read(saveDirProvider);
      expect(currentState.value, equals(validDir));
      expect(await Directory(validDir).exists(), isTrue);
    });
  });
}