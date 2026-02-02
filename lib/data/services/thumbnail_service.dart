import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:vcompressor/core/logging/app_logger.dart';

/// Servicio centralizado para la gestión robusta de thumbnails
/// Responsabilidades:
/// 1. Generación de thumbnails usando video_thumbnail
/// 2. Almacenamiento persistente en ApplicationSupportDirectory
/// 3. Validación de existencia de archivos
class ThumbnailService {
  // Singleton pattern for global access if needed, but preferably used via DI
  static final ThumbnailService _instance = ThumbnailService._internal();
  factory ThumbnailService() => _instance;
  ThumbnailService._internal();

  /// Directorio cacheado para evitar llamadas repetitivas al sistema de archivos
  Directory? _storageDir;

  /// Obtiene el directorio de almacenamiento persistente para thumbnails
  /// Usa getApplicationSupportDirectory en lugar de getTemporaryDirectory
  /// para evitar que el OS elimine los archivos arbitrariamente.
  Future<Directory> get _directory async {
    if (_storageDir != null) return _storageDir!;
    
    final appDir = await getApplicationSupportDirectory();
    final thumbDir = Directory('${appDir.path}/thumbnails');
    if (!await thumbDir.exists()) {
      await thumbDir.create(recursive: true);
    }
    _storageDir = thumbDir;
    return thumbDir;
  }

  /// Genera un thumbnail para el video especificado
  /// Retorna la ruta del archivo generado o null si falla
  Future<String?> generateThumbnail(String videoPath) async {
    try {
      if (!File(videoPath).existsSync()) {
        AppLogger.warning('Video no encontrado para generar thumbnail: $videoPath', tag: 'ThumbnailService');
        return null;
      }

      final dir = await _directory;
      
      // Generar nombre único basado en ruta y modificación para cache
      // (Podríamos usar hash, pero nombre de archivo simple es más rápido)
      // final fileName = videoPath.split(Platform.pathSeparator).last;
      // final uniqueName = 'thumb_${fileName}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      // Intento de generación
      final resultPath = await VideoThumbnail.thumbnailFile(
        video: videoPath,
        thumbnailPath: dir.path, // El plugin usa esto como base dir
        imageFormat: ImageFormat.JPEG,
        maxHeight: 120, // Optimizado para listas
        quality: 75,
      );

      if (resultPath != null) {
        // Verificar que el archivo realmente existe (paranoia check)
        final file = File(resultPath);
        if (await file.exists()) {
           AppLogger.debug('Thumbnail generado exitosamente: $resultPath', tag: 'ThumbnailService');
           return resultPath;
        }
      }
      
      AppLogger.warning('Plugin retornó null o archivo no creado', tag: 'ThumbnailService');
      return null;

    } catch (e) {
      AppLogger.error('Excepción generando thumbnail: $e', tag: 'ThumbnailService');
      return null;
    }
  }

  /// Verifica si un thumbnail es válido y existe en disco
  bool isValidThumbnail(String? path) {
    if (path == null || path.isEmpty) return false;
    return File(path).existsSync();
  }

  /// Limpia todos los thumbnails generados (útil para "Borrar Cache")
  Future<void> clearAllThumbnails() async {
    try {
      final dir = await _directory;
      if (await dir.exists()) {
        await dir.delete(recursive: true);
        _storageDir = null; // Forzar recarga del directorio
        AppLogger.info('Directorio de thumbnails limpiado', tag: 'ThumbnailService');
      }
    } catch (e) {
      AppLogger.error('Error limpiando thumbnails: $e', tag: 'ThumbnailService');
    }
  }
}
