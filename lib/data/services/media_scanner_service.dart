import 'package:flutter/services.dart';
import 'package:vcompressor/core/logging/app_logger.dart';

/// Servicio para notificar a Android MediaStore sobre nuevos archivos
/// Esto permite que los videos comprimidos aparezcan inmediatamente en la Galería
class MediaScannerService {
  static const _channel = MethodChannel('com.rjmejia.vcompressor/media_scan');

  /// Escanea un archivo para que sea indexado por el MediaStore
  Future<void> scanFile(String filePath) async {
    try {
      AppLogger.info(
        'Solicitando escaneo de medios para: $filePath',
        tag: 'MediaScanner',
      );
      await _channel.invokeMethod('scanFile', {'path': filePath});
    } on PlatformException catch (e) {
      AppLogger.warning(
        'Error al escanear archivo: ${e.message}',
        tag: 'MediaScanner',
      );
    } catch (e) {
      AppLogger.error(
        'Error inesperado en MediaScanner: $e',
        tag: 'MediaScanner',
      );
    }
  }
}
