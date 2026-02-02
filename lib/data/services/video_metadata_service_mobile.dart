import 'dart:io';
import 'package:vcompressor/core/logging/app_logger.dart';
import 'package:vcompressor/data/services/ffprobe_service.dart';
import 'package:vcompressor/data/services/thumbnail_service.dart';



import 'package:vcompressor/data/services/video_metadata_service.dart';

/// Servicio para la extracción de metadatos de archivos de video
/// Encapsula la lógica de análisis de archivos de video
class VideoMetadataServiceMobile implements VideoMetadataService {
  final _ffprobeService = const FFprobeService();
  
  VideoMetadataServiceMobile();

  /// Extrae metadatos de un archivo de video
  /// OPTIMIZACIÓN: Realiza una sola llamada a FFprobe para obtener todos los datos
  @override
  Future<VideoMetadata> extractMetadata(String videoPath) async {
    try {
      AppLogger.debug(
        'Extrayendo metadatos de: $videoPath',
        tag: 'VideoMetadata',
      );

      final file = File(videoPath);
      final fileSize = await file.length();

      // Generar thumbnail (operación independiente de FFprobe)
      final thumbnailPath = await _generateThumbnail(videoPath);

      // Extraer TODOS los metadatos en una sola ejecución de proceso
      final info = await _ffprobeService.getMediaInformation(videoPath);

      // Mapear resultados con null safety
      final width = info?['width'] as int?;
      final height = info?['height'] as int?;
      final duration = info?['duration'] as double?;
      final fps = info?['fps'] as double?;

      final metadata = VideoMetadata(
        fileSize: fileSize,
        thumbnailPath: thumbnailPath,
        width: width,
        height: height,
        duration: duration,
        fps: fps,
      );

      AppLogger.debug(
        'Metadatos extraídos: ${width}x$height, ${duration?.toStringAsFixed(2)}s, ${fps?.toStringAsFixed(2)}fps',
        tag: 'VideoMetadata',
      );

      return metadata;
    } catch (e) {
      AppLogger.error('Error extrayendo metadatos: $e', tag: 'VideoMetadata');
      return const VideoMetadata();
    }
  }

  /// Genera un thumbnail del video
  Future<String?> _generateThumbnail(String videoPath) async {
    return ThumbnailService().generateThumbnail(videoPath);
  }
}
