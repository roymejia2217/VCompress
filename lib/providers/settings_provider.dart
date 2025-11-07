import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:vcompressor/core/constants/app_constants.dart';
import 'package:vcompressor/utils/cache_service.dart';

final themeModeProvider = StateNotifierProvider<ThemeModeController, ThemeMode>(
  (ref) {
    return ThemeModeController();
  },
);

final amoledProvider = StateNotifierProvider<AmoledController, bool>((ref) {
  return AmoledController();
});

final localeProvider = StateNotifierProvider<LocaleController, Locale>((ref) {
  return LocaleController();
});

// Provider mejorado usando FutureProvider para estado asíncrono
final saveDirProvider = FutureProvider<String>((ref) async {
  try {
    final saved = await CacheService.instance.getSetting<String>('saveDir');

    if (saved != null && saved.isNotEmpty) {
      // Validar que el directorio existe
      final dir = Directory(saved);
      if (await dir.exists()) {
        return saved;
      }
    }

    // Crear directorio por defecto
    return await _createDefaultSaveDir();
  } catch (e) {
    // Log error pero retorna un fallback válido
    debugPrint('Error loading save directory: $e');

    // Fallback seguro para Android
    return '/storage/emulated/0/Download/${AppConstants.defaultSaveFolder}';
  }
});

Future<String> _createDefaultSaveDir() async {
  // Android: usar directorio de descargas externo
  const defaultPath =
      '/storage/emulated/0/Download/${AppConstants.defaultSaveFolder}';

  // Crear directorio si no existe
  final dir = Directory(defaultPath);
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }

  // Guardar en cache
  await CacheService.instance.setSetting('saveDir', defaultPath);
  return defaultPath;
}

// Notifier para cambiar directorio
final saveDirNotifierProvider =
    StateNotifierProvider<SaveDirNotifier, AsyncValue<String>>((ref) {
      return SaveDirNotifier(ref);
    });

class SaveDirNotifier extends StateNotifier<AsyncValue<String>> {
  final Ref _ref;

  SaveDirNotifier(this._ref) : super(const AsyncValue.loading()) {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      final currentDir = await _ref.read(saveDirProvider.future);
      state = AsyncValue.data(currentDir);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> pickDirectory() async {
    state = const AsyncValue.loading();

    try {
      final result = await FilePicker.platform.getDirectoryPath();

      if (result == null || result.isEmpty) {
        // Usuario canceló - restaurar estado anterior
        final currentDir = await _ref.read(saveDirProvider.future);
        state = AsyncValue.data(currentDir);
        return;
      }

      // Validar permisos de escritura
      final testFile = File('$result/.vcompress_test');
      try {
        await testFile.writeAsString('test');
        await testFile.delete();
      } catch (e) {
        throw Exception('No se tienen permisos de escritura en: $result');
      }

      // Crear directorio si no existe
      final dir = Directory(result);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      await CacheService.instance.setSetting('saveDir', result);
      state = AsyncValue.data(result);

      // Invalidar el provider principal para que se actualice
      _ref.invalidate(saveDirProvider);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

class ThemeModeController extends StateNotifier<ThemeMode> {
  ThemeModeController() : super(ThemeMode.system) {
    _load();
  }

  Future<void> _load() async {
    final value = await CacheService.instance.getSetting<String>('themeMode');
    switch (value) {
      case 'light':
        state = ThemeMode.light;
        break;
      case 'dark':
        state = ThemeMode.dark;
        break;
      case 'system':
      default:
        state = ThemeMode.system;
        break;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    final str = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      _ => 'system',
    };
    await CacheService.instance.setSetting('themeMode', str);
  }
}

class AmoledController extends StateNotifier<bool> {
  AmoledController() : super(false) {
    _load();
  }

  Future<void> _load() async {
    state = await CacheService.instance.getSetting<bool>('amoled') ?? false;
  }

  Future<void> setAmoled(bool value) async {
    state = value;
    await CacheService.instance.setSetting('amoled', value);
  }
}

class LocaleController extends StateNotifier<Locale> {
  LocaleController() : super(const Locale('es')) {
    _load();
  }

  Future<void> _load() async {
    final localeCode = await CacheService.instance.getSetting<String>('locale');
    if (localeCode != null) {
      state = Locale(localeCode);
    }
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    await CacheService.instance.setSetting('locale', locale.languageCode);
  }
}

// SaveDirController eliminado - reemplazado por AsyncNotifier
