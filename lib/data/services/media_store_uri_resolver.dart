import 'dart:io';
import 'package:flutter/services.dart';
import 'package:vcompressor/core/result/result.dart';
import 'package:vcompressor/core/error/app_error.dart';
import 'package:vcompressor/core/logging/app_logger.dart';

/// Servicio para resolver URIs de MediaStore desde rutas de archivo
/// SOLID: Single Responsibility - solo resuelve URIs de MediaStore
/// DRY: Centraliza la lógica de resolución de URIs
class MediaStoreUriResolver {
  static const MethodChannel _channel = MethodChannel(
    'media_store_uri_resolver',
  );

  const MediaStoreUriResolver();

  /// Resuelve un URI de MediaStore desde la ruta de un archivo
  /// Utiliza el canal nativo Android para consultar MediaStore por DISPLAY_NAME y RELATIVE_PATH
  Future<Result<String?, AppError>> resolveUriFromPath(String filePath) async {
    try {
      // Solo funciona en Android
      if (!Platform.isAndroid) {
        AppLogger.debug(
          'MediaStoreUriResolver solo funciona en Android, ruta: $filePath',
          tag: 'MediaStoreUriResolver',
        );
        return const Success(null);
      }

      AppLogger.debug(
        'Resolviendo URI de MediaStore para: $filePath',
        tag: 'MediaStoreUriResolver',
      );

      final result = await _channel.invokeMethod<String>('resolveUriFromPath', {
        'filePath': filePath,
      });

      if (result != null) {
        AppLogger.info(
          'URI resuelto exitosamente: $result',
          tag: 'MediaStoreUriResolver',
        );
        return Success(result);
      } else {
        AppLogger.warning(
          'No se pudo resolver URI para: $filePath',
          tag: 'MediaStoreUriResolver',
        );
        return const Success(null);
      }
    } on PlatformException catch (e) {
      AppLogger.error(
        'Error de plataforma resolviendo URI: ${e.message}',
        tag: 'MediaStoreUriResolver',
      );
      return Failure(
        AppError.processingFailed(
          'Error resolviendo URI de MediaStore: ${e.message}',
          e,
        ),
      );
    } catch (e) {
      AppLogger.error(
        'Error inesperado resolviendo URI: $e',
        tag: 'MediaStoreUriResolver',
      );
      return Failure(
        AppError.processingFailed('Error inesperado resolviendo URI: $e', e),
      );
    }
  }

  /// Resuelve la ruta original de un archivo desde un URI de MediaStore
  /// Utiliza el canal nativo Android para consultar MediaStore por URI
  Future<Result<String?, AppError>> resolvePathFromUri(String uri) async {
    try {
      // Solo funciona en Android
      if (!Platform.isAndroid) {
        AppLogger.debug(
          'MediaStoreUriResolver solo funciona en Android, URI: $uri',
          tag: 'MediaStoreUriResolver',
        );
        return const Success(null);
      }

      AppLogger.debug(
        'Resolviendo ruta original desde URI: $uri',
        tag: 'MediaStoreUriResolver',
      );

      final result = await _channel.invokeMethod<String>('resolvePathFromUri', {
        'uri': uri,
      });

      if (result != null) {
        AppLogger.info(
          'Ruta original resuelta exitosamente: $result',
          tag: 'MediaStoreUriResolver',
        );
        return Success(result);
      } else {
        AppLogger.warning(
          'No se pudo resolver ruta original para URI: $uri',
          tag: 'MediaStoreUriResolver',
        );
        return const Success(null);
      }
    } on PlatformException catch (e) {
      AppLogger.error(
        'Error de plataforma resolviendo ruta: ${e.message}',
        tag: 'MediaStoreUriResolver',
      );
      return Failure(
        AppError.processingFailed(
          'Error resolviendo ruta original: ${e.message}',
          e,
        ),
      );
    } catch (e) {
      AppLogger.error(
        'Error inesperado resolviendo ruta: $e',
        tag: 'MediaStoreUriResolver',
      );
      return Failure(
        AppError.processingFailed('Error inesperado resolviendo ruta: $e', e),
      );
    }
  }

  /// Verifica si un URI es válido para reemplazo
  /// SOLID: Single Responsibility - solo valida URIs
  bool isValidForReplacement(String? uri) {
    if (uri == null) return false;

    // Verificar que sea un URI de MediaStore válido
    return uri.startsWith('content://media/external/video/media/') ||
        uri.startsWith('content://media/external/video/thumbnails/');
  }

  /// Obtiene el nombre del archivo desde un URI de MediaStore
  /// DRY: Utilidad para extraer información del URI
  String? getFileNameFromUri(String uri) {
    try {
      final uriParts = uri.split('/');
      if (uriParts.length > 1) {
        return uriParts.last;
      }
    } catch (e) {
      AppLogger.warning(
        'Error extrayendo nombre de archivo del URI: $uri',
        tag: 'MediaStoreUriResolver',
      );
    }
    return null;
  }
}
