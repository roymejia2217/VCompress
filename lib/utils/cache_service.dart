import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:vcompressor/core/constants/app_constants.dart';
import 'package:vcompressor/core/error/app_error.dart';
import 'package:vcompressor/core/logging/app_logger.dart';
import 'package:vcompressor/core/result/result.dart';
import 'package:vcompressor/utils/format_utils.dart';

/// Servicio centralizado para manejo de cache y persistencia
class CacheService {
  CacheService._(); // Constructor privado para singleton

  static CacheService? _instance;
  static CacheService get instance => _instance ??= CacheService._();

  SharedPreferences? _prefs;

  /// Inicializa el servicio de cache
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Asegura que el servicio esté inicializado
  Future<SharedPreferences> get _preferences async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  /// Guarda un string
  Future<bool> setString(String key, String value) async {
    final prefs = await _preferences;
    return prefs.setString(key, value);
  }

  /// Obtiene un string
  Future<String?> getString(String key) async {
    final prefs = await _preferences;
    return prefs.getString(key);
  }

  /// Guarda un boolean
  Future<bool> setBool(String key, bool value) async {
    final prefs = await _preferences;
    return prefs.setBool(key, value);
  }

  /// Obtiene un boolean
  Future<bool?> getBool(String key) async {
    final prefs = await _preferences;
    return prefs.getBool(key);
  }

  /// Guarda un int
  Future<bool> setInt(String key, int value) async {
    final prefs = await _preferences;
    return prefs.setInt(key, value);
  }

  /// Obtiene un int
  Future<int?> getInt(String key) async {
    final prefs = await _preferences;
    return prefs.getInt(key);
  }

  /// Guarda un double
  Future<bool> setDouble(String key, double value) async {
    final prefs = await _preferences;
    return prefs.setDouble(key, value);
  }

  /// Obtiene un double
  Future<double?> getDouble(String key) async {
    final prefs = await _preferences;
    return prefs.getDouble(key);
  }

  /// Guarda una lista de strings
  Future<bool> setStringList(String key, List<String> value) async {
    final prefs = await _preferences;
    return prefs.setStringList(key, value);
  }

  /// Obtiene una lista de strings
  Future<List<String>?> getStringList(String key) async {
    final prefs = await _preferences;
    return prefs.getStringList(key);
  }

  /// Guarda un objeto JSON
  Future<bool> setJson(String key, Map<String, dynamic> value) async {
    final jsonString = json.encode(value);
    return setString(key, jsonString);
  }

  /// Obtiene un objeto JSON
  Future<Map<String, dynamic>?> getJson(String key) async {
    final jsonString = await getString(key);
    if (jsonString == null) return null;

    try {
      return json.decode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  /// Verifica si existe una clave
  Future<bool> containsKey(String key) async {
    final prefs = await _preferences;
    return prefs.containsKey(key);
  }

  /// Elimina una clave
  Future<bool> remove(String key) async {
    final prefs = await _preferences;
    return prefs.remove(key);
  }

  /// Limpia todo el cache
  Future<bool> clear() async {
    final prefs = await _preferences;
    return prefs.clear();
  }

  /// Guarda un objeto con timestamp automático
  Future<bool> setCachedObject(
    String key,
    Map<String, dynamic> value, {
    Duration? expiry,
  }) async {
    final cachedData = {
      'data': value,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'expiryMs': (expiry ?? AppConstants.cacheExpiryDuration).inMilliseconds,
    };
    return setJson(key, cachedData);
  }

  /// Obtiene un objeto con verificación de expiración
  Future<Map<String, dynamic>?> getCachedObject(String key) async {
    try {
      final cachedData = await getJson(key);
      if (cachedData == null) return null;

      final timestamp = cachedData['timestamp'] as int?;
      final expiryMs = cachedData['expiryMs'] as int?;

      if (timestamp != null && expiryMs != null) {
        final now = DateTime.now().millisecondsSinceEpoch;
        final age = now - timestamp;

        if (age > expiryMs) {
          // Cache expirado, eliminar
          await remove(key);
          return null;
        }
      }

      return cachedData['data'] as Map<String, dynamic>?;
    } catch (e) {
      final appError = AppError.fromException(e, StackTrace.current);
      debugPrint('Error obteniendo objeto cacheado: ${appError.message}');
      return null;
    }
  }

  /// Métodos específicos para tipos comunes con prefijos

  // Settings
  Future<bool> setSetting(String key, dynamic value) =>
      _setTypedValue('settings_$key', value);
  Future<T?> getSetting<T>(String key) => _getTypedValue<T>('settings_$key');

  // Hardware
  Future<bool> setHardwareData(String key, dynamic value) =>
      _setTypedValue('hardware_$key', value);
  Future<T?> getHardwareData<T>(String key) =>
      _getTypedValue<T>('hardware_$key');

  // User preferences
  Future<bool> setUserPref(String key, dynamic value) =>
      _setTypedValue('user_$key', value);
  Future<T?> getUserPref<T>(String key) => _getTypedValue<T>('user_$key');

  /// Método interno para guardar valores tipados
  Future<bool> _setTypedValue(String key, dynamic value) async {
    if (value is String) return setString(key, value);
    if (value is bool) return setBool(key, value);
    if (value is int) return setInt(key, value);
    if (value is double) return setDouble(key, value);
    if (value is List<String>) return setStringList(key, value);
    if (value is Map<String, dynamic>) return setJson(key, value);

    // Fallback a JSON para otros tipos
    return setJson(key, {'value': value, 'type': value.runtimeType.toString()});
  }

  /// Método interno para obtener valores tipados
  Future<T?> _getTypedValue<T>(String key) async {
    if (T == String) return await getString(key) as T?;
    if (T == bool) return await getBool(key) as T?;
    if (T == int) return await getInt(key) as T?;
    if (T == double) return await getDouble(key) as T?;
    if (T == List<String>) return await getStringList(key) as T?;

    // Intentar obtener como JSON
    final json = await getJson(key);
    if (json == null) return null;

    // Si es un objeto complejo, devolver el JSON
    if (T.toString().startsWith('Map')) return json as T?;

    // Si es un valor encapsulado, extraerlo
    return json['value'] as T?;
  }

  /// Limpia archivos temporales del directorio de caché de la aplicación
  /// SOLID: Single Responsibility - solo maneja limpieza de archivos temporales
  /// DRY: Centraliza la lógica de limpieza de caché
  Future<Result<CacheCleanupResult, AppError>> cleanupTemporaryFiles({
    String? cacheDirectory,
    List<String>? fileExtensions,
    Duration? maxAge,
  }) async {
    try {
      AppLogger.info(
        'Iniciando limpieza de archivos temporales',
        tag: 'CacheService',
      );

      // Determinar directorio de caché
      final actualCacheDir =
          cacheDirectory ?? await _getDefaultCacheDirectory();
      if (actualCacheDir == null) {
        return Failure(
          AppError.validationError(
            'cache_cleanup',
            'No se pudo determinar el directorio de caché',
          ),
        );
      }

      // Verificar que el directorio existe
      final cacheDir = Directory(actualCacheDir);
      if (!await cacheDir.exists()) {
        AppLogger.info(
          'Directorio de caché no existe: $actualCacheDir',
          tag: 'CacheService',
        );
        return const Success(
          CacheCleanupResult(deletedFiles: 0, deletedSizeBytes: 0, errors: []),
        );
      }

      // Configurar filtros
      final extensions = fileExtensions ?? _getDefaultVideoExtensions();
      final maxFileAge = maxAge ?? const Duration(hours: 1);

      // Escanear y eliminar archivos
      final result = await _cleanupDirectory(cacheDir, extensions, maxFileAge);

      AppLogger.info(
        'Limpieza completada: ${result.deletedFiles} archivos, '
        '${FormatUtils.formatBytes(result.deletedSizeBytes)} liberados',
        tag: 'CacheService',
      );

      return Success(result);
    } catch (e) {
      AppLogger.error('Error en limpieza de caché: $e', tag: 'CacheService');
      return Failure(AppError.processingFailed('Error limpiando caché: $e', e));
    }
  }

  /// Limpia archivos temporales específicos de una lista de rutas
  /// SOLID: Single Responsibility - solo maneja limpieza de archivos específicos
  Future<Result<CacheCleanupResult, AppError>> cleanupSpecificFiles(
    List<String> filePaths,
  ) async {
    try {
      AppLogger.info(
        'Limpiando ${filePaths.length} archivos específicos',
        tag: 'CacheService',
      );

      int deletedFiles = 0;
      int deletedSizeBytes = 0;
      final List<String> errors = [];

      for (final filePath in filePaths) {
        try {
          final file = File(filePath);
          if (await file.exists()) {
            final size = await file.length();
            await file.delete();
            deletedFiles++;
            deletedSizeBytes += size;

            AppLogger.debug(
              'Archivo eliminado: $filePath',
              tag: 'CacheService',
            );
          }
        } catch (e) {
          final errorMsg = 'Error eliminando $filePath: $e';
          errors.add(errorMsg);
          AppLogger.warning(errorMsg, tag: 'CacheService');
        }
      }

      final result = CacheCleanupResult(
        deletedFiles: deletedFiles,
        deletedSizeBytes: deletedSizeBytes,
        errors: errors,
      );

      AppLogger.info(
        'Limpieza específica completada: $deletedFiles archivos, '
        '${FormatUtils.formatBytes(deletedSizeBytes)} liberados',
        tag: 'CacheService',
      );

      return Success(result);
    } catch (e) {
      AppLogger.error('Error en limpieza específica: $e', tag: 'CacheService');
      return Failure(
        AppError.processingFailed('Error en limpieza específica: $e', e),
      );
    }
  }

  /// Obtiene el directorio de caché por defecto
  /// DRY: Centraliza la lógica de determinación de directorio de caché
  Future<String?> _getDefaultCacheDirectory() async {
    try {
      if (kIsWeb) return null;

      // Android: usar directorio de datos de la aplicación
      if (Platform.isAndroid) {
        // Obtener el package name real de la aplicación
        final packageName = await _getPackageName();
        if (packageName != null) {
          return '/data/data/$packageName/cache';
        }

        // Fallback: usar directorio de caché temporal del sistema
        final tempDir = await getTemporaryDirectory();
        return '${tempDir.path}/cache';
      }

      // Otras plataformas: usar directorio de caché del sistema
      final tempDir = await getTemporaryDirectory();
      return '${tempDir.path}/vcompress/cache';
    } catch (e) {
      AppLogger.error(
        'Error obteniendo directorio de caché: $e',
        tag: 'CacheService',
      );
      return null;
    }
  }

  /// Obtiene el package name real de la aplicación
  /// SOLID: Single Responsibility - solo obtiene package name
  Future<String?> _getPackageName() async {
    try {
      // Importar package_info_plus para obtener información de la app
      final packageInfo = await PackageInfo.fromPlatform();
      AppLogger.debug(
        'Package name detectado: ${packageInfo.packageName}',
        tag: 'CacheService',
      );
      return packageInfo.packageName;
    } catch (e) {
      AppLogger.warning(
        'No se pudo obtener package name: $e',
        tag: 'CacheService',
      );
      return null;
    }
  }

  /// Obtiene extensiones de video por defecto
  /// DRY: Usa constantes de la aplicación
  List<String> _getDefaultVideoExtensions() {
    return AppConstants.supportedVideoExtensions;
  }

  /// Limpia un directorio específico
  /// SOLID: Single Responsibility - solo maneja limpieza de un directorio
  Future<CacheCleanupResult> _cleanupDirectory(
    Directory directory,
    List<String> extensions,
    Duration maxAge,
  ) async {
    int deletedFiles = 0;
    int deletedSizeBytes = 0;
    final List<String> errors = [];

    try {
      final now = DateTime.now();
      final cutoffTime = now.subtract(maxAge);

      // Escanear archivos recursivamente
      await for (final entity in directory.list(recursive: true)) {
        if (entity is File) {
          try {
            // Verificar extensión
            final fileName = entity.path.toLowerCase();
            final hasValidExtension = extensions.any(
              (ext) => fileName.endsWith(ext.toLowerCase()),
            );

            if (!hasValidExtension) continue;

            // Verificar edad del archivo
            final stat = await entity.stat();
            if (stat.modified.isAfter(cutoffTime)) continue;

            // Eliminar archivo
            final size = stat.size;
            await entity.delete();
            deletedFiles++;
            deletedSizeBytes += size;

            AppLogger.debug(
              'Archivo temporal eliminado: ${entity.path}',
              tag: 'CacheService',
            );
          } catch (e) {
            final errorMsg = 'Error eliminando ${entity.path}: $e';
            errors.add(errorMsg);
            AppLogger.warning(errorMsg, tag: 'CacheService');
          }
        }
      }
    } catch (e) {
      final errorMsg = 'Error escaneando directorio ${directory.path}: $e';
      errors.add(errorMsg);
      AppLogger.error(errorMsg, tag: 'CacheService');
    }

    return CacheCleanupResult(
      deletedFiles: deletedFiles,
      deletedSizeBytes: deletedSizeBytes,
      errors: errors,
    );
  }
}

/// Resultado de la limpieza de caché
/// SOLID: Single Responsibility - solo representa resultado de limpieza
class CacheCleanupResult {
  final int deletedFiles;
  final int deletedSizeBytes;
  final List<String> errors;

  const CacheCleanupResult({
    required this.deletedFiles,
    required this.deletedSizeBytes,
    required this.errors,
  });

  bool get hasErrors => errors.isNotEmpty;
  bool get isSuccessful => !hasErrors && deletedFiles > 0;

  @override
  String toString() {
    return 'CacheCleanupResult(deletedFiles: $deletedFiles, '
        'deletedSizeBytes: $deletedSizeBytes, errors: ${errors.length})';
  }
}
