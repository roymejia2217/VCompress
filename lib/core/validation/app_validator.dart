import 'dart:io';
import 'package:vcompressor/core/error/app_error.dart';
import 'package:vcompressor/core/constants/app_constants.dart';

/// Sistema de validación centralizado
/// Siguiendo las mejores prácticas de Flutter para validación de datos
class AppValidator {
  AppValidator._(); // Constructor privado para clase estática

  /// Valida un archivo de video con validación completa (síncrona, límites conservadores)
  static AppError? validateVideoFile(String filePath) {
    try {
      final file = File(filePath);

      // Verificar que el archivo existe
      if (!file.existsSync()) {
        return AppError.fileNotFound(filePath);
      }

      // Verificar tamaño mínimo
      final fileSize = file.lengthSync();
      if (fileSize < AppConstants.minFileSizeBytes) {
        return AppError.validationError(
          'fileSize',
          'El archivo es demasiado pequeño ($fileSize bytes)',
        );
      }

      // Verificar extensión
      final extension = filePath.toLowerCase().split('.').last;
      final supportedExtensions = AppConstants.supportedVideoExtensions
          .map((ext) => ext.substring(1).toLowerCase())
          .toList();

      if (!supportedExtensions.contains(extension)) {
        return AppError.validationError(
          'fileFormat',
          'Formato no soportado: .$extension',
        );
      }

      return null; // Archivo válido
    } catch (e) {
      return AppError.validationError(
        'fileValidation',
        'Error validando archivo: $e',
      );
    }
  }

  /// Valida múltiples archivos de video
  static VideoValidationResult validateVideoFiles(List<String> filePaths) {
    final validFiles = <String>[];
    final invalidFiles = <String>[];

    for (final filePath in filePaths) {
      final error = validateVideoFile(filePath);
      if (error == null) {
        validFiles.add(filePath);
      } else {
        invalidFiles.add(filePath);
      }
    }

    return VideoValidationResult(
      validFiles: validFiles,
      invalidFiles: invalidFiles,
    );
  }

  /// Valida información de hardware
  static AppError? validateHardwareInfo({
    required int cpuCores,
    required bool hasHwAccel,
    required bool hasH264HwEncoder,
    required bool hasH265HwEncoder,
  }) {
    // Validar número de núcleos
    if (cpuCores < 1 || cpuCores > 32) {
      return AppError.validationError(
        'cpuCores',
        'Número de núcleos inválido: $cpuCores',
      );
    }

    return null; // Hardware válido
  }

  /// Valida número de hilos para procesamiento
  static AppError? validateThreadCount(int threadCount) {
    if (threadCount < 1 || threadCount > 16) {
      return AppError.validationError(
        'threadCount',
        'Número de hilos inválido: $threadCount',
      );
    }

    return null;
  }
}

/// Resultado de validación de archivos de video
class VideoValidationResult {
  final List<String> validFiles;
  final List<String> invalidFiles;

  const VideoValidationResult({
    required this.validFiles,
    required this.invalidFiles,
  });

  bool get hasValidFiles => validFiles.isNotEmpty;
  bool get hasInvalidFiles => invalidFiles.isNotEmpty;
  int get validCount => validFiles.length;
  int get invalidCount => invalidFiles.length;
}
