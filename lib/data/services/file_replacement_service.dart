import 'package:flutter/services.dart';
import 'package:vcompressor/core/result/result.dart';
import 'package:vcompressor/core/error/app_error.dart';
import 'package:vcompressor/core/logging/app_logger.dart';

/// Servicio para reemplazar archivos por URI usando MediaStore/SAF
/// SOLID: Single Responsibility - solo maneja reemplazo de archivos
/// DRY: Centraliza la lógica de reemplazo multiplataforma
class FileReplacementService {
  static const MethodChannel _channel = MethodChannel('file_replacement');

  const FileReplacementService();

  /// Reemplaza un archivo usando su URI de MediaStore (Android)
  /// Usa ContentResolver.openFileDescriptor(uri, "rwt")
  Future<Result<void, AppError>> replaceFileAtUri({
    required String contentUri,
    required String tempFilePath,
  }) async {
    try {
      AppLogger.debug(
        'Iniciando reemplazo de archivo: $contentUri con temporal: $tempFilePath',
        tag: 'FileReplacementService',
      );

      return await _replaceFileAndroid(contentUri, tempFilePath);
    } catch (e) {
      AppLogger.error(
        'Error inesperado en reemplazo de archivo: $e',
        tag: 'FileReplacementService',
      );
      return Failure(
        AppError.processingFailed('Error inesperado en reemplazo: $e', e),
      );
    }
  }

  /// Reemplaza archivo en Android usando MediaStore/SAF
  /// SOLID: Single Responsibility - solo maneja Android
  Future<Result<void, AppError>> _replaceFileAndroid(
    String contentUri,
    String tempFilePath,
  ) async {
    try {
      await _channel.invokeMethod('replaceAtUri', {
        'uri': contentUri,
        'tempPath': tempFilePath,
      });

      AppLogger.info(
        'Archivo reemplazado exitosamente en Android: $contentUri',
        tag: 'FileReplacementService',
      );
      return const Success(null);
    } on PlatformException catch (e) {
      AppLogger.error(
        'Error de plataforma reemplazando archivo: ${e.message}',
        tag: 'FileReplacementService',
      );

      // Manejar errores específicos de Android
      switch (e.code) {
        case 'CONSENT_REQUIRED':
          return Failure(
            AppError.permissionDenied(
              'Se requiere consentimiento del usuario para reemplazar este archivo',
            ),
          );
        case 'REPLACE_FAILED':
          return Failure(
            AppError.processingFailed(
              'Error reemplazando archivo: ${e.message}',
              e,
            ),
          );
        case 'FILE_NOT_FOUND':
          return Failure(
            AppError.fileNotFound(
              'Archivo temporal no encontrado: $tempFilePath',
            ),
          );
        default:
          return Failure(
            AppError.processingFailed('Error de plataforma: ${e.message}', e),
          );
      }
    }
  }


  /// Verifica si un URI es válido para reemplazo (Android)
  /// Comprueba que sea un URI de MediaStore válido
  bool isValidUriForReplacement(String? uri) {
    if (uri == null) return false;

    // Verificar que sea un URI de MediaStore válido
    return uri.startsWith('content://media/external/video/media/') ||
        uri.startsWith('content://media/external/video/thumbnails/');
  }
}
