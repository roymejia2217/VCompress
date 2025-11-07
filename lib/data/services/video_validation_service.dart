import 'package:vcompressor/core/validation/app_validator.dart';
import 'package:vcompressor/core/logging/app_logger.dart';

/// Resultado de la validación de archivos
class VideoValidationResult {
  final List<String> validFiles;
  final List<String> invalidFiles;
  final int validCount;
  final int invalidCount;

  const VideoValidationResult({
    required this.validFiles,
    required this.invalidFiles,
    required this.validCount,
    required this.invalidCount,
  });

  bool get hasValidFiles => validFiles.isNotEmpty;
  bool get hasInvalidFiles => invalidFiles.isNotEmpty;
}

/// Servicio para la validación de archivos de video
/// Encapsula la lógica de validación de archivos
class VideoValidationService {
  const VideoValidationService();

  /// Valida una lista de archivos de video
  Future<VideoValidationResult> validateFiles(List<String> filePaths) async {
    try {
      AppLogger.debug(
        'Validando ${filePaths.length} archivos',
        tag: 'VideoValidation',
      );

      final validFiles = <String>[];
      final invalidFiles = <String>[];

      for (final filePath in filePaths) {
        final isValid = await _validateFile(filePath);
        if (isValid) {
          validFiles.add(filePath);
        } else {
          invalidFiles.add(filePath);
        }
      }

      final result = VideoValidationResult(
        validFiles: validFiles,
        invalidFiles: invalidFiles,
        validCount: validFiles.length,
        invalidCount: invalidFiles.length,
      );

      AppLogger.info(
        'Validación completada: ${result.validCount} válidos, ${result.invalidCount} inválidos',
        tag: 'VideoValidation',
      );

      return result;
    } catch (e) {
      AppLogger.error('Error en validación: $e', tag: 'VideoValidation');
      return VideoValidationResult(
        validFiles: [],
        invalidFiles: filePaths,
        validCount: 0,
        invalidCount: filePaths.length,
      );
    }
  }

  /// Valida un archivo individual
  Future<bool> _validateFile(String filePath) async {
    try {
      // Validar con el sistema existente
      final validationResult = AppValidator.validateVideoFiles([filePath]);
      return validationResult.hasValidFiles;
    } catch (e) {
      AppLogger.debug(
        'Error validando archivo $filePath: $e',
        tag: 'VideoValidation',
      );
      return false;
    }
  }
}
