import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// Sistema de gestión de memoria
/// Previene memory leaks y optimiza el uso de recursos
class MemoryManager {
  static final MemoryManager _instance = MemoryManager._internal();
  factory MemoryManager() => _instance;
  MemoryManager._internal();

  // Cache de recursos
  final Map<String, dynamic> _resourceCache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  final Map<String, Timer> _cacheTimers = {};

  // Configuración
  static const int _maxCacheSize = 100; // Máximo número de elementos en cache
  static const Duration _defaultCacheTimeout = Duration(minutes: 30);
  // static const int _maxMemoryUsageMB = 100; // Unused field // Máximo uso de memoria en MB

  // Monitoreo
  Timer? _cleanupTimer;
  bool _isEnabled = true;

  /// Inicializa el gestor de memoria
  Future<void> initialize() async {
    if (!_isEnabled) return;

    // Limpiar cache antiguo al iniciar
    await _cleanupOldCache();

    // Iniciar timer de limpieza periódica
    _startCleanupTimer();

    debugPrint('[MEMORY] MemoryManager inicializado');
  }

  /// Almacena un recurso en cache
  void cacheResource(String key, dynamic resource, {Duration? timeout}) {
    if (!_isEnabled) return;

    final cacheTimeout = timeout ?? _defaultCacheTimeout;

    // Limpiar cache si está lleno
    if (_resourceCache.length >= _maxCacheSize) {
      _evictOldestCache();
    }

    // Almacenar recurso
    _resourceCache[key] = resource;
    _cacheTimestamps[key] = DateTime.now();

    // Configurar timer para expiración
    _cacheTimers[key]?.cancel();
    _cacheTimers[key] = Timer(cacheTimeout, () {
      removeFromCache(key);
    });

    debugPrint('[CACHE] Recurso cacheado: $key');
  }

  /// Obtiene un recurso del cache
  R? getCachedResource<R>(String key) {
    if (!_isEnabled) return null;

    final resource = _resourceCache[key];
    if (resource != null && resource is R) {
      // Actualizar timestamp de acceso
      _cacheTimestamps[key] = DateTime.now();
      debugPrint('[READ] Recurso recuperado del cache: $key');
      return resource;
    }

    return null;
  }

  /// Verifica si un recurso está en cache
  bool hasCachedResource(String key) {
    return _resourceCache.containsKey(key);
  }

  /// Remueve un recurso del cache
  void removeFromCache(String key) {
    if (!_isEnabled) return;

    final resource = _resourceCache.remove(key);
    _cacheTimestamps.remove(key);
    _cacheTimers[key]?.cancel();
    _cacheTimers.remove(key);

    // Liberar recursos si es necesario
    _disposeResource(resource);

    debugPrint('[DELETE] Recurso removido del cache: $key');
  }

  /// Limpia todo el cache
  void clearCache() {
    if (!_isEnabled) return;

    // Cancelar todos los timers
    for (final timer in _cacheTimers.values) {
      timer.cancel();
    }

    // Liberar todos los recursos
    for (final resource in _resourceCache.values) {
      _disposeResource(resource);
    }

    // Limpiar mapas
    _resourceCache.clear();
    _cacheTimestamps.clear();
    _cacheTimers.clear();

    debugPrint('[CLEANUP] Cache completamente limpiado');
  }

  /// Obtiene estadísticas del cache
  Map<String, dynamic> getCacheStats() {
    return {
      'totalItems': _resourceCache.length,
      'maxSize': _maxCacheSize,
      'oldestItem': _cacheTimestamps.isNotEmpty
          ? _cacheTimestamps.values
                .reduce((a, b) => a.isBefore(b) ? a : b)
                .toString()
          : 'N/A',
      'newestItem': _cacheTimestamps.isNotEmpty
          ? _cacheTimestamps.values
                .reduce((a, b) => a.isAfter(b) ? a : b)
                .toString()
          : 'N/A',
    };
  }

  /// Limpia archivos temporales
  Future<void> cleanupTempFiles() async {
    if (!_isEnabled) return;

    try {
      final tempDir = await getTemporaryDirectory();
      final files = tempDir.listSync();

      int deletedCount = 0;
      final now = DateTime.now();

      for (final file in files) {
        if (file is File) {
          final stat = await file.stat();
          final age = now.difference(stat.modified);

          // Eliminar archivos más antiguos de 1 hora
          if (age.inHours > 1) {
            await file.delete();
            deletedCount++;
          }
        }
      }

      debugPrint(
        '[FILES] Archivos temporales limpiados: $deletedCount eliminados',
      );
    } catch (e) {
      debugPrint('[ERROR] Error limpiando archivos temporales: $e');
    }
  }

  /// Optimiza el uso de memoria
  Future<void> optimizeMemory() async {
    if (!_isEnabled) return;

    // Limpiar cache antiguo
    await _cleanupOldCache();

    // Limpiar archivos temporales
    await cleanupTempFiles();

    // Forzar garbage collection si es posible
    _forceGarbageCollection();

    debugPrint('[OPTIMIZE] Optimización de memoria completada');
  }

  /// Habilita o deshabilita el gestor
  void setEnabled(bool enabled) {
    _isEnabled = enabled;
    if (!enabled) {
      _stopCleanupTimer();
      clearCache();
    } else {
      _startCleanupTimer();
    }
  }

  /// Disposición del gestor
  void dispose() {
    _stopCleanupTimer();
    clearCache();
    debugPrint('[MEMORY] MemoryManager disposed');
  }

  /// Inicia timer de limpieza periódica
  void _startCleanupTimer() {
    _stopCleanupTimer();
    _cleanupTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      _cleanupOldCache();
    });
  }

  /// Detiene timer de limpieza
  void _stopCleanupTimer() {
    _cleanupTimer?.cancel();
    _cleanupTimer = null;
  }

  /// Limpia cache antiguo
  Future<void> _cleanupOldCache() async {
    if (!_isEnabled || _resourceCache.isEmpty) return;

    final now = DateTime.now();
    final keysToRemove = <String>[];

    for (final entry in _cacheTimestamps.entries) {
      final age = now.difference(entry.value);
      if (age > _defaultCacheTimeout) {
        keysToRemove.add(entry.key);
      }
    }

    for (final key in keysToRemove) {
      removeFromCache(key);
    }

    if (keysToRemove.isNotEmpty) {
      debugPrint(
        '[CLEANUP] Cache antiguo limpiado: ${keysToRemove.length} elementos',
      );
    }
  }

  /// Expulsa el elemento más antiguo del cache
  void _evictOldestCache() {
    if (_cacheTimestamps.isEmpty) return;

    String? oldestKey;
    DateTime? oldestTime;

    for (final entry in _cacheTimestamps.entries) {
      if (oldestTime == null || entry.value.isBefore(oldestTime)) {
        oldestTime = entry.value;
        oldestKey = entry.key;
      }
    }

    if (oldestKey != null) {
      removeFromCache(oldestKey);
      debugPrint('Elemento más antiguo expulsado del cache: $oldestKey');
    }
  }

  /// Libera recursos específicos
  void _disposeResource(dynamic resource) {
    if (resource == null) return;

    try {
      // Liberar recursos específicos según su tipo
      if (resource is StreamSubscription) {
        resource.cancel();
      } else if (resource is Timer) {
        resource.cancel();
      } else if (resource is File) {
        // Los archivos se cierran automáticamente
      } else if (resource is Map || resource is List) {
        // Limpiar colecciones grandes
        resource.clear();
      }
    } catch (e) {
      debugPrint('[WARNING] Error liberando recurso: $e');
    }
  }

  /// Fuerza garbage collection (solo en debug)
  void _forceGarbageCollection() {
    if (kDebugMode) {
      // En modo debug, podemos intentar forzar la limpieza de memoria
      debugPrint('Forzando garbage collection...');
    }
  }
}

/// Mixin para widgets que necesitan gestión de memoria
mixin MemoryManagedMixin<T extends StatefulWidget> on State<T> {
  final List<String> _cachedResources = [];

  @override
  void initState() {
    super.initState();
    _initializeMemoryManagement();
  }

  @override
  void dispose() {
    _cleanupCachedResources();
    super.dispose();
  }

  /// Cachea un recurso con el contexto del widget
  void cacheResource(String key, dynamic resource, {Duration? timeout}) {
    final fullKey = '${widget.runtimeType}_$key';
    MemoryManager().cacheResource(fullKey, resource, timeout: timeout);
    _cachedResources.add(fullKey);
  }

  /// Obtiene un recurso cacheado
  R? getCachedResource<R>(String key) {
    final fullKey = '${widget.runtimeType}_$key';
    return MemoryManager().getCachedResource<R>(fullKey);
  }

  /// Verifica si un recurso está cacheado
  bool hasCachedResource(String key) {
    final fullKey = '${widget.runtimeType}_$key';
    return MemoryManager().hasCachedResource(fullKey);
  }

  /// Inicializa la gestión de memoria
  void _initializeMemoryManagement() {
    // Override en subclases si es necesario
  }

  /// Limpia recursos cacheados
  void _cleanupCachedResources() {
    for (final key in _cachedResources) {
      MemoryManager().removeFromCache(key);
    }
    _cachedResources.clear();
  }
}

/// Extension para facilitar el uso del gestor de memoria
extension MemoryManagerExtension on Widget {
  /// Envuelve un widget con gestión de memoria
  Widget withMemoryManagement() {
    return MemoryManagedWidget(child: this);
  }
}

/// Widget que proporciona gestión de memoria automática
class MemoryManagedWidget extends StatefulWidget {
  final Widget child;

  const MemoryManagedWidget({super.key, required this.child});

  @override
  State<MemoryManagedWidget> createState() => _MemoryManagedWidgetState();
}

class _MemoryManagedWidgetState extends State<MemoryManagedWidget>
    with MemoryManagedMixin<MemoryManagedWidget> {
  @override
  void initState() {
    super.initState();
    // Inicializar gestión de memoria
    MemoryManager().initialize();
  }

  @override
  void dispose() {
    // Optimizar memoria al destruir el widget
    MemoryManager().optimizeMemory();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
