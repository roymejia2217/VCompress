import 'package:ffmpeg_kit_flutter_new/ffprobe_kit.dart';
import 'package:vcompressor/core/logging/app_logger.dart';

/// Servicio dedicado para extracción de metadatos usando FFprobe
/// SOLID: Single Responsibility - solo maneja extracción de metadatos con FFprobe
/// DRY: Centraliza toda la lógica de FFprobe en un solo lugar
class FFprobeService {
  const FFprobeService();

  /// Extrae información completa del video usando MediaInformation API
  /// SOLID: Single Responsibility - extrae toda la información multimedia de una vez
  /// DRY: Centraliza la obtención de metadatos en un solo método robusto
  Future<Map<String, dynamic>?> _getMediaInformation(String videoPath) async {
    try {
      AppLogger.debug(
        'Obteniendo información multimedia: $videoPath',
        tag: 'FFprobeService',
      );

      final session = await FFprobeKit.getMediaInformation(videoPath);
      final information = session.getMediaInformation();

      if (information == null) {
        // Verificar errores de sesión
        final state = await session.getState();
        final returnCode = await session.getReturnCode();
        final output = await session.getOutput();

        AppLogger.warning(
          'MediaInformation falló - Estado: $state, Código: $returnCode, Output: $output',
          tag: 'FFprobeService',
        );
        return null;
      }

      // Extraer información general
      final durationMs = information.getDuration();
      final duration = durationMs != null ? double.parse(durationMs) : null;

      // Extraer información de streams
      final streams = information.getStreams();
      String? fps;
      int? width, height;

      for (var stream in streams) {
        if (stream.getType() == 'video') {
          fps = stream.getAverageFrameRate();
          width = stream.getWidth();
          height = stream.getHeight();
          break;
        }
      }

      final result = {
        'duration': duration,
        'fps': fps,
        'width': width,
        'height': height,
        'bitrate': information.getBitrate(),
        'format': information.getFormat(),
        'size_bytes': information.getSize(),
      };

      AppLogger.debug(
        'Información extraída: ${width}x$height, ${duration?.toStringAsFixed(2)}s, ${fps}fps',
        tag: 'FFprobeService',
      );

      return result;
    } catch (e) {
      AppLogger.error(
        'Error obteniendo MediaInformation: $e',
        tag: 'FFprobeService',
      );
      return null;
    }
  }

  /// Extrae la duración del video usando MediaInformation API
  /// SOLID: Single Responsibility - solo extrae duración
  /// DRY: Reutiliza _getMediaInformation para máxima eficiencia
  Future<double?> getVideoDuration(String videoPath) async {
    try {
      AppLogger.debug('Extrayendo duración: $videoPath', tag: 'FFprobeService');

      final info = await _getMediaInformation(videoPath);
      if (info == null) return null;

      final duration = info['duration'] as double?;
      if (duration != null && _isValidDuration(duration)) {
        AppLogger.debug(
          'Duración extraída: ${duration.toStringAsFixed(2)}s',
          tag: 'FFprobeService',
        );
        return duration;
      }

      AppLogger.warning(
        'No se pudo extraer duración válida',
        tag: 'FFprobeService',
      );
      return null;
    } catch (e) {
      AppLogger.error('Error extrayendo duración: $e', tag: 'FFprobeService');
      return null;
    }
  }

  /// Extrae dimensiones del video usando MediaInformation API
  /// SOLID: Single Responsibility - solo extrae dimensiones
  /// DRY: Reutiliza _getMediaInformation para máxima eficiencia
  Future<Map<String, int?>> getVideoDimensions(String videoPath) async {
    try {
      AppLogger.debug(
        'Extrayendo dimensiones: $videoPath',
        tag: 'FFprobeService',
      );

      final info = await _getMediaInformation(videoPath);
      if (info == null) return {'width': null, 'height': null};

      final width = info['width'] as int?;
      final height = info['height'] as int?;

      if (width != null && height != null) {
        AppLogger.debug(
          'Dimensiones extraídas: ${width}x$height',
          tag: 'FFprobeService',
        );
        return {'width': width, 'height': height};
      }

      return {'width': null, 'height': null};
    } catch (e) {
      AppLogger.error(
        'Error extrayendo dimensiones: $e',
        tag: 'FFprobeService',
      );
      return {'width': null, 'height': null};
    }
  }

  /// Extrae FPS del video usando MediaInformation API
  /// SOLID: Single Responsibility - solo extrae FPS
  /// DRY: Reutiliza _getMediaInformation para máxima eficiencia
  Future<double?> getVideoFps(String videoPath) async {
    try {
      AppLogger.debug('Extrayendo FPS: $videoPath', tag: 'FFprobeService');

      final info = await _getMediaInformation(videoPath);
      if (info == null) return null;

      final fpsStr = info['fps'] as String?;
      if (fpsStr == null || fpsStr.isEmpty) return null;

      // Parsear FPS desde string (puede ser fracción o decimal)
      final fps = _parseFpsFromString(fpsStr);
      if (fps != null && fps > 0) {
        AppLogger.debug(
          'FPS extraído: ${fps.toStringAsFixed(2)}fps',
          tag: 'FFprobeService',
        );
        return fps;
      }

      AppLogger.warning(
        'No se pudo extraer FPS válido: $fpsStr',
        tag: 'FFprobeService',
      );
      return null;
    } catch (e) {
      AppLogger.error('Error extrayendo FPS: $e', tag: 'FFprobeService');
      return null;
    }
  }

  /// Parsea FPS desde string (fracción o decimal)
  /// SOLID: Single Responsibility - solo parsea FPS
  /// DRY: Centraliza lógica de parsing de FPS
  double? _parseFpsFromString(String fpsStr) {
    try {
      if (fpsStr.contains('/')) {
        // Formato fracción: 30000/1001
        final parts = fpsStr.split('/');
        if (parts.length == 2) {
          final numerator = double.tryParse(parts[0]);
          final denominator = double.tryParse(parts[1]);
          if (numerator != null && denominator != null && denominator > 0) {
            return numerator / denominator;
          }
        }
      } else {
        // Formato decimal: 30.0
        return double.tryParse(fpsStr);
      }
      return null;
    } catch (e) {
      AppLogger.debug('Error parseando FPS: $e', tag: 'FFprobeService');
      return null;
    }
  }

  /// Valida duración extraída
  /// SOLID: Single Responsibility - solo valida duración
  /// DRY: Reutiliza validación en múltiples lugares
  bool _isValidDuration(double duration) {
    return duration > 0 && duration <= 86400; // 0s - 24h
  }
}
