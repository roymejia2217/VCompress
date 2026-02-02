import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
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

// Provider unificado y reactivo para el directorio de guardado
final saveDirProvider =
    StateNotifierProvider<SaveDirNotifier, AsyncValue<String>>((ref) {
      return SaveDirNotifier();
    });

class SaveDirNotifier extends StateNotifier<AsyncValue<String>> {
  final Future<String?> Function()? _directoryPicker;

  SaveDirNotifier({Future<String?> Function()? directoryPicker})
    : _directoryPicker = directoryPicker,
      super(const AsyncValue.loading()) {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      // 1. Intentar recuperar configuración guardada
      final saved = await CacheService.instance.getSetting<String>('saveDir');

      if (saved != null && saved.isNotEmpty) {
        final dir = Directory(saved);
        if (await dir.exists()) {
          state = AsyncValue.data(saved);
          return;
        }
      }

      // 2. Si no hay guardado o no existe, generar default
      final defaultDir = await _createDefaultSaveDir();
      state = AsyncValue.data(defaultDir);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<String> _createDefaultSaveDir() async {
    try {
      Directory? baseDir;
      if (Platform.isAndroid) {
        // Intenta obtener directorio de descargas público de manera segura
        // Nota: path_provider en Android para getDownloadsDirectory puede ser null
        // Usamos un enfoque híbrido seguro
        baseDir = Directory('/storage/emulated/0/Download');
        if (!await baseDir.exists()) {
           baseDir = await getExternalStorageDirectory();
        }
      } else {
        baseDir = await getDownloadsDirectory();
      }

      final path =
          baseDir != null
              ? '${baseDir.path}/${AppConstants.defaultSaveFolder}'
              : '${Directory.systemTemp.path}/${AppConstants.defaultSaveFolder}';

      final dir = Directory(path);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      // Persistir el default generado
      await CacheService.instance.setSetting('saveDir', path);
      return path;
    } catch (e) {
      // Fallback extremo si todo falla (ej. permisos muy restrictivos)
      return Directory.systemTemp.path;
    }
  }

  Future<void> pickDirectory() async {
    // Preservar estado actual en caso de cancelación
    final previousState = state;
    
    // UI Loading state inmediato
    state = const AsyncValue.loading();

    try {
      final result = _directoryPicker != null 
          ? await _directoryPicker!() 
          : await FilePicker.platform.getDirectoryPath();

      if (result == null || result.isEmpty) {
        // Usuario canceló - restaurar sin error
        state = previousState;
        return;
      }

      // Crear directorio si no existe (robustez)
      final dir = Directory(result);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      // Validar permisos de escritura
      final testFile = File('$result/.vcompress_write_check');
      try {
        await testFile.writeAsString('test');
        await testFile.delete();
      } catch (e) {
        throw const FileSystemException(
          'Sin permisos de escritura en la carpeta seleccionada.',
        );
      }

      // Actualización Optimista: Actualizar estado ANTES de persistir para UI rápida
      state = AsyncValue.data(result);

      // Persistir en segundo plano
      await CacheService.instance.setSetting('saveDir', result);
      
    } catch (e, stack) {
      // Si falla, mostrar error pero mantener estado previo accesible si se recarga
      state = AsyncValue.error(e, stack);
      // Opcional: Podríamos revertir al estado previo tras un delay, 
      // pero mostrar el error es más informativo.
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
