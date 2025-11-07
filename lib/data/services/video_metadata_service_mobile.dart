import 'dart:io';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';

import 'package:vcompressor/core/logging/app_logger.dart';
import 'package:vcompressor/data/services/ffprobe_service.dart';



import 'package:vcompressor/data/services/video_metadata_service.dart';

/// Servicio para la extracción de metadatos de archivos de video
/// Encapsula la lógica de análisis de archivos de video
class VideoMetadataServiceMobile implements VideoMetadataService {
  VideoMetadataServiceMobile();

  /// Extrae metadatos de un archivo de video
  @override
  Future<VideoMetadata> extractMetadata(String videoPath) async {
    try {
      AppLogger.debug(
        'Extrayendo metadatos de: $videoPath',
        tag: 'VideoMetadata',
      );

      final file = File(videoPath);
      final fileSize = await file.length();

      // Extraer dimensiones, duración y FPS
      final dimensions = await _getVideoDimensions(videoPath);
      final duration = await _getVideoDuration(videoPath);
      final fps = await _getVideoFps(videoPath);

      // Generar thumbnail
      final thumbnailPath = await _generateThumbnail(videoPath);

      final metadata = VideoMetadata(
        fileSize: fileSize,
        thumbnailPath: thumbnailPath,
        width: dimensions['width'],
        height: dimensions['height'],
        duration: duration,
        fps: fps,
      );

      AppLogger.debug(
        'Metadatos extraídos: ${dimensions['width']}x${dimensions['height']}, ${duration?.toStringAsFixed(2)}s, ${fps?.toStringAsFixed(2)}fps',
        tag: 'VideoMetadata',
      );

      return metadata;
    } catch (e) {
      AppLogger.error('Error extrayendo metadatos: $e', tag: 'VideoMetadata');
      return const VideoMetadata();
    }
  }

  /// Obtiene las dimensiones del video usando FFprobeService
  /// SOLID: Single Responsibility - solo maneja extracción de dimensiones
  /// DRY: Usa FFprobeService centralizado para máxima precisión
  Future<Map<String, int?>> _getVideoDimensions(String videoPath) async {
    try {
      // SOLID: Usar FFprobeService para extracción precisa
      const ffprobeService = FFprobeService();
      return await ffprobeService.getVideoDimensions(videoPath);
    } catch (e) {
      AppLogger.debug('Error obteniendo dimensiones: $e', tag: 'VideoMetadata');
      return {'width': null, 'height': null};
    }
  }

  /// Obtiene la duración del video usando FFprobeService
  /// SOLID: Single Responsibility - solo maneja extracción de duración
  /// DRY: Usa FFprobeService centralizado para máxima precisión
  Future<double?> _getVideoDuration(String videoPath) async {
    try {
      // SOLID: Usar FFprobeService para extracción precisa
      const ffprobeService = FFprobeService();
      
      // Usar FFprobeService para extracción de duración
      final duration = await ffprobeService.getVideoDuration(videoPath);
      if (duration != null && duration > 0) {
        AppLogger.debug(
          'Duración extraída: ${duration.toStringAsFixed(2)}s (FFprobeService)',
          tag: 'VideoMetadata',
        );
        return duration;
      }

      AppLogger.warning('No se pudo extraer duración del video con FFprobe', tag: 'VideoMetadata');
      return null;
    } catch (e) {
      AppLogger.error('Error crítico extrayendo duración: $e', tag: 'VideoMetadata');
      return null;
    }
  }



  /// Genera un thumbnail del video
  Future<String?> _generateThumbnail(String videoPath) async {
    try {
      final tempDir = await getTemporaryDirectory();

      final result = await VideoThumbnail.thumbnailFile(
        video: videoPath,
        thumbnailPath: tempDir.path,
        imageFormat: ImageFormat.JPEG,
        maxHeight: 120,
        quality: 75,
      );

      AppLogger.debug('Thumbnail generado: $result', tag: 'VideoMetadata');
      return result;
    } catch (e) {
      AppLogger.debug('Error generando thumbnail: $e', tag: 'VideoMetadata');
      return null;
    }
  }

  /// Obtiene el FPS del video usando FFprobeService
  /// SOLID: Single Responsibility - solo maneja extracción de FPS
  /// DRY: Usa FFprobeService centralizado para máxima precisión
  Future<double?> _getVideoFps(String videoPath) async {
    try {
      // SOLID: Usar FFprobeService para extracción precisa
      const ffprobeService = FFprobeService();
      return await ffprobeService.getVideoFps(videoPath);
    } catch (e) {
      AppLogger.debug('Error obteniendo FPS: $e', tag: 'VideoMetadata');
      return null;
    }
  }

}
