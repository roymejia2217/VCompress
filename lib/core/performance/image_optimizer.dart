import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:vcompressor/core/performance/memory_manager.dart';
import 'package:vcompressor/ui/widgets/app_icons.dart';

/// Sistema de optimización de imágenes
/// Proporciona caching, compresión y gestión eficiente de thumbnails
class ImageOptimizer {
  static final ImageOptimizer _instance = ImageOptimizer._internal();
  factory ImageOptimizer() => _instance;
  ImageOptimizer._internal();

  // Cache de imágenes
  final Map<String, Uint8List> _imageCache = {};
  final Map<String, DateTime> _cacheTimestamps = {};

  // Configuración
  static const int _maxCacheSize = 50; // Máximo número de imágenes en cache
  static const Duration _cacheTimeout = Duration(hours: 2);
  // static const int _maxImageSize = 1024; // Tamaño máximo en píxeles - Unused
  // static const int _quality = 85; // Calidad de compresión (0-100) - Unused

  /// Genera un thumbnail optimizado para un video
  Future<Uint8List?> generateThumbnail({
    required String videoPath,
    required int width,
    required int height,
    Duration? position,
  }) async {
    try {
      final cacheKey = _generateCacheKey(videoPath, width, height, position);

      // Verificar cache primero
      final cachedImage = getCachedImage(cacheKey);
      if (cachedImage != null) {
        return cachedImage;
      }

      // Generar thumbnail usando FFmpeg
      final thumbnail = await _generateThumbnailWithFFmpeg(
        videoPath: videoPath,
        width: width,
        height: height,
        position: position ?? const Duration(seconds: 1),
      );

      if (thumbnail != null) {
        // Optimizar y cachear
        final optimizedThumbnail = await _optimizeImage(thumbnail);
        _cacheImage(cacheKey, optimizedThumbnail);
        return optimizedThumbnail;
      }

      return null;
    } catch (e) {
      debugPrint('[ERROR] Error generando thumbnail: $e');
      return null;
    }
  }

  /// Optimiza una imagen existente
  Future<Uint8List> optimizeImage(Uint8List imageData) async {
    try {
      // Redimensionar si es muy grande
      final resizedImage = await _resizeImageIfNeeded(imageData);

      // Comprimir
      final compressedImage = await _compressImage(resizedImage);

      return compressedImage;
    } catch (e) {
      debugPrint('[ERROR] Error optimizando imagen: $e');
      return imageData; // Retornar original si falla
    }
  }

  /// Obtiene una imagen del cache
  Uint8List? getCachedImage(String key) {
    final cached = _imageCache[key];
    if (cached != null) {
      // Actualizar timestamp de acceso
      _cacheTimestamps[key] = DateTime.now();
      return cached;
    }
    return null;
  }

  /// Verifica si una imagen está en cache
  bool hasCachedImage(String key) {
    return _imageCache.containsKey(key);
  }

  /// Limpia el cache de imágenes
  void clearImageCache() {
    _imageCache.clear();
    _cacheTimestamps.clear();
    debugPrint('[IMAGE] Cache de imágenes limpiado');
  }

  /// Obtiene estadísticas del cache de imágenes
  Map<String, dynamic> getImageCacheStats() {
    return {
      'totalImages': _imageCache.length,
      'maxSize': _maxCacheSize,
      'totalSizeBytes': _imageCache.values.fold<int>(
        0,
        (sum, image) => sum + image.length,
      ),
      'oldestImage': _cacheTimestamps.isNotEmpty
          ? _cacheTimestamps.values
                .reduce((a, b) => a.isBefore(b) ? a : b)
                .toString()
          : 'N/A',
    };
  }

  /// Optimiza el uso de memoria del cache
  void optimizeCache() {
    if (_imageCache.length <= _maxCacheSize) return;

    // Ordenar por timestamp (más antiguos primero)
    final sortedEntries = _cacheTimestamps.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    // Remover imágenes más antiguas
    final toRemove = _imageCache.length - _maxCacheSize;
    for (int i = 0; i < toRemove; i++) {
      final key = sortedEntries[i].key;
      _imageCache.remove(key);
      _cacheTimestamps.remove(key);
    }

    debugPrint(
      '[IMAGE] Cache de imágenes optimizado: $toRemove imágenes removidas',
    );
  }

  /// Genera thumbnail usando FFmpeg
  Future<Uint8List?> _generateThumbnailWithFFmpeg({
    required String videoPath,
    required int width,
    required int height,
    required Duration position,
  }) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final outputPath =
          '${tempDir.path}/thumb_${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Comando FFmpeg para generar thumbnail
      final args = [
        '-i', videoPath,
        '-ss', '${position.inMilliseconds / 1000}',
        '-vframes', '1',
        '-vf', 'scale=$width:$height:force_original_aspect_ratio=decrease',
        '-q:v', '2', // Alta calidad
        '-y', // Sobrescribir archivo
        outputPath,
      ];

      // Ejecutar FFmpeg
      final result = await _executeFFmpeg(args);

      if (result) {
        final file = File(outputPath);
        if (await file.exists()) {
          final bytes = await file.readAsBytes();
          await file.delete(); // Limpiar archivo temporal
          return bytes;
        }
      }

      return null;
    } catch (e) {
      debugPrint('[ERROR] Error en FFmpeg thumbnail: $e');
      return null;
    }
  }

  /// Redimensiona imagen si es muy grande
  Future<Uint8List> _resizeImageIfNeeded(Uint8List imageData) async {
    // Por simplicidad, retornamos la imagen original
    // En una implementación real, usaríamos un paquete de procesamiento de imágenes
    return imageData;
  }

  /// Comprime una imagen
  Future<Uint8List> _compressImage(Uint8List imageData) async {
    // Por simplicidad, retornamos la imagen original
    // En una implementación real, usaríamos un paquete de compresión de imágenes
    return imageData;
  }

  /// Optimiza una imagen completa
  Future<Uint8List> _optimizeImage(Uint8List imageData) async {
    // Combinar redimensionado y compresión
    final resized = await _resizeImageIfNeeded(imageData);
    final compressed = await _compressImage(resized);
    return compressed;
  }

  /// Genera una clave única para el cache
  String _generateCacheKey(
    String videoPath,
    int width,
    int height,
    Duration? position,
  ) {
    final positionStr = position?.inMilliseconds.toString() ?? '0';
    final content = '$videoPath${width}x$height$positionStr';
    final bytes = utf8.encode(content);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Cachea una imagen
  void _cacheImage(String key, Uint8List imageData) {
    // Limpiar cache si está lleno
    if (_imageCache.length >= _maxCacheSize) {
      _evictOldestImage();
    }

    _imageCache[key] = imageData;
    _cacheTimestamps[key] = DateTime.now();

    // Cachear también en MemoryManager
    MemoryManager().cacheResource(
      'image_$key',
      imageData,
      timeout: _cacheTimeout,
    );

    debugPrint('[CACHE] Imagen cacheada: $key (${imageData.length} bytes)');
  }

  /// Expulsa la imagen más antigua del cache
  void _evictOldestImage() {
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
      _imageCache.remove(oldestKey);
      _cacheTimestamps.remove(oldestKey);
      MemoryManager().removeFromCache('image_$oldestKey');
      debugPrint('[EVICT] Imagen más antigua expulsada: $oldestKey');
    }
  }

  /// Ejecuta comando FFmpeg
  Future<bool> _executeFFmpeg(List<String> args) async {
    try {
      // En una implementación real, usaríamos ffmpeg_kit_flutter
      // Por ahora, simulamos éxito
      await Future.delayed(const Duration(milliseconds: 100));
      return true;
    } catch (e) {
      debugPrint('[ERROR] Error ejecutando FFmpeg: $e');
      return false;
    }
  }

  /// Limpia imágenes antiguas del cache
  void _cleanupOldImages() {
    final now = DateTime.now();
    final keysToRemove = <String>[];

    for (final entry in _cacheTimestamps.entries) {
      final age = now.difference(entry.value);
      if (age > _cacheTimeout) {
        keysToRemove.add(entry.key);
      }
    }

    for (final key in keysToRemove) {
      _imageCache.remove(key);
      _cacheTimestamps.remove(key);
      MemoryManager().removeFromCache('image_$key');
    }

    if (keysToRemove.isNotEmpty) {
      debugPrint(
        '[CLEANUP] Imágenes antiguas limpiadas: ${keysToRemove.length} removidas',
      );
    }
  }
}

/// Widget optimizado para mostrar imágenes
class OptimizedImage extends StatefulWidget {
  final String imagePath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  const OptimizedImage({
    super.key,
    required this.imagePath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
  });

  @override
  State<OptimizedImage> createState() => _OptimizedImageState();
}

class _OptimizedImageState extends State<OptimizedImage> {
  Uint8List? _imageData;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      // Verificar cache primero
      final cacheKey = _generateCacheKey();
      final cachedImage = ImageOptimizer().getCachedImage(cacheKey);

      if (cachedImage != null) {
        setState(() {
          _imageData = cachedImage;
          _isLoading = false;
        });
        return;
      }

      // Cargar imagen desde archivo
      final file = File(widget.imagePath);
      if (await file.exists()) {
        final bytes = await file.readAsBytes();

        // Optimizar imagen
        final optimizedBytes = await ImageOptimizer().optimizeImage(bytes);

        // Cachear imagen optimizada
        // ImageOptimizer()._cacheImage(cacheKey, optimizedBytes);

        setState(() {
          _imageData = optimizedBytes;
          _isLoading = false;
        });
      } else {
        throw Exception('Archivo no encontrado');
      }
    } catch (e) {
      debugPrint('[ERROR] Error cargando imagen: $e');
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  String _generateCacheKey() {
    final content = '${widget.imagePath}${widget.width}x${widget.height}';
    // Simple hash for cache key
    return content.hashCode.toString();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return widget.placeholder ??
          const Center(child: CircularProgressIndicator());
    }

    if (_hasError || _imageData == null) {
      return widget.errorWidget ??
          const Center(
            child: AppIcon(
              icon: AppIcons.warning,
              config: AppIconConfig.medium(),
            ),
          );
    }

    return Image.memory(
      _imageData!,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      cacheWidth: widget.width?.toInt(),
      cacheHeight: widget.height?.toInt(),
    );
  }
}

/// Extension para facilitar el uso del optimizador
extension ImageOptimizerExtension on Widget {
  /// Envuelve un widget con optimización de imágenes
  Widget withImageOptimization() {
    return ImageOptimizedWidget(child: this);
  }
}

/// Widget que proporciona optimización de imágenes automática
class ImageOptimizedWidget extends StatefulWidget {
  final Widget child;

  const ImageOptimizedWidget({super.key, required this.child});

  @override
  State<ImageOptimizedWidget> createState() => _ImageOptimizedWidgetState();
}

class _ImageOptimizedWidgetState extends State<ImageOptimizedWidget> {
  @override
  void initState() {
    super.initState();
    // Inicializar optimizador de imágenes
    _initializeImageOptimizer();
  }

  void _initializeImageOptimizer() {
    // Configurar limpieza periódica del cache
    Timer.periodic(const Duration(minutes: 10), (timer) {
      ImageOptimizer()._cleanupOldImages();
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
