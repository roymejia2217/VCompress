import 'package:flutter/foundation.dart';

/// Tipos de errores de la aplicación
enum AppErrorType {
  fileNotFound,
  permissionDenied,
  processingFailed,
  hardwareDetection,
  networkError,
  validationError,
  mediaStoreError,
  consentRequired,
  replaceFailed,
  cacheRegeneration,
  originalFileNotFound,
  dependencyNotAvailable,
  cancelled,
  unknown,
}

/// Clase para manejo centralizado de errores
/// Siguiendo las mejores prácticas de Flutter para error handling
@immutable
class AppError {
  final AppErrorType type;
  final String message;
  final String? details;
  final dynamic originalError;
  final StackTrace? stackTrace;

  const AppError({
    required this.type,
    required this.message,
    this.details,
    this.originalError,
    this.stackTrace,
  });

  /// Factory constructor para operación cancelada
  factory AppError.cancelled() {
    return const AppError(
      type: AppErrorType.cancelled,
      message: 'Operación cancelada por el usuario',
      details: 'El procesamiento fue detenido manualmente',
    );
  }

  /// Factory constructor para errores de archivo no encontrado
  factory AppError.fileNotFound(String filePath) {
    return AppError(
      type: AppErrorType.fileNotFound,
      message: 'Archivo no encontrado: $filePath',
      details: 'Verifique que el archivo existe y tiene permisos de lectura',
    );
  }

  /// Factory constructor para errores de permisos
  factory AppError.permissionDenied(String permission) {
    return AppError(
      type: AppErrorType.permissionDenied,
      message: 'Permiso denegado: $permission',
      details: 'La aplicación necesita permisos para acceder a archivos',
    );
  }

  /// Factory constructor para errores de procesamiento
  factory AppError.processingFailed(String operation, [dynamic originalError]) {
    return AppError(
      type: AppErrorType.processingFailed,
      message: 'Error en el procesamiento: $operation',
      details: 'El procesamiento del video falló',
      originalError: originalError,
    );
  }

  /// Factory constructor para errores de hardware
  factory AppError.hardwareDetection([dynamic originalError]) {
    return AppError(
      type: AppErrorType.hardwareDetection,
      message: 'Error detectando hardware del dispositivo',
      details: 'No se pudo obtener información del hardware',
      originalError: originalError,
    );
  }

  /// Factory constructor para errores de validación
  factory AppError.validationError(String field, String reason) {
    return AppError(
      type: AppErrorType.validationError,
      message: 'Error de validación en $field',
      details: reason,
    );
  }

  /// Factory constructor para errores de MediaStore
  factory AppError.mediaStoreError(String operation, [dynamic originalError]) {
    return AppError(
      type: AppErrorType.mediaStoreError,
      message: 'Error de MediaStore: $operation',
      details: 'Error accediendo a la base de datos de medios',
      originalError: originalError,
    );
  }

  /// Factory constructor para errores de consentimiento requerido
  factory AppError.consentRequired(String operation) {
    return AppError(
      type: AppErrorType.consentRequired,
      message: 'Consentimiento requerido: $operation',
      details: 'El usuario debe otorgar permisos para modificar este archivo',
    );
  }

  /// Factory constructor para errores de reemplazo de archivo
  factory AppError.replaceFailed(String filePath, [dynamic originalError]) {
    return AppError(
      type: AppErrorType.replaceFailed,
      message: 'Error reemplazando archivo: $filePath',
      details: 'No se pudo reemplazar el archivo original',
      originalError: originalError,
    );
  }

  /// Factory constructor para errores de regeneración de cache
  factory AppError.cacheRegenerationFailed(String originalPath) {
    return AppError(
      type: AppErrorType.cacheRegeneration,
      message: 'Error regenerando cache desde: $originalPath',
      details: 'No se pudo copiar el archivo original al cache temporal',
    );
  }

  /// Factory constructor para archivo original no encontrado
  factory AppError.originalFileNotFound(String path) {
    return AppError(
      type: AppErrorType.originalFileNotFound,
      message: 'Archivo original no encontrado: $path',
      details: 'El archivo original no existe o no es accesible',
    );
  }

  /// Factory constructor para errores de dependencias no disponibles
  factory AppError.dependencyNotAvailable(String dependency) {
    return AppError(
      type: AppErrorType.dependencyNotAvailable,
      message: 'Dependencia no disponible: $dependency',
      details: 'Una dependencia crítica no está inicializada correctamente',
    );
  }

  /// Factory constructor para errores de red
  factory AppError.networkError([dynamic originalError]) {
    return AppError(
      type: AppErrorType.networkError,
      message: 'Error de conexión de red',
      details: 'Verifique su conexión a internet',
      originalError: originalError,
    );
  }

  /// Factory constructor para errores desconocidos
  factory AppError.unknown(
    String message, [
    dynamic originalError,
    StackTrace? stackTrace,
  ]) {
    return AppError(
      type: AppErrorType.unknown,
      message: message,
      originalError: originalError,
      stackTrace: stackTrace,
    );
  }

  /// Convierte una excepción en AppError
  factory AppError.fromException(dynamic exception, StackTrace? stackTrace) {
    if (exception is AppError) return exception;

    final message = exception?.toString() ?? 'Error desconocido';

    if (exception is FileSystemException) {
      return AppError.fileNotFound(exception.path);
    } else if (exception is PermissionException) {
      return AppError.permissionDenied(exception.toString());
    } else if (exception is NetworkException) {
      return AppError.networkError(exception);
    } else {
      return AppError.unknown(message, exception, stackTrace);
    }
  }

  /// Obtiene el mensaje de usuario apropiado
  String get userMessage {
    switch (type) {
      case AppErrorType.fileNotFound:
        return 'El archivo no se encontró. Verifique que existe y es accesible.';
      case AppErrorType.permissionDenied:
        return 'Se requieren permisos para acceder a archivos. Configure los permisos en la configuración.';
      case AppErrorType.processingFailed:
        return 'El procesamiento del video falló. Intente con un archivo diferente o ajuste la configuración.';
      case AppErrorType.hardwareDetection:
        return 'No se pudo detectar el hardware. La aplicación funcionará con configuración básica.';
      case AppErrorType.networkError:
        return 'Error de conexión. Verifique su conexión a internet.';
      case AppErrorType.validationError:
        return 'Datos inválidos: $details';
      case AppErrorType.mediaStoreError:
        return 'Error accediendo a la galería de medios. Intente seleccionar el archivo nuevamente.';
      case AppErrorType.consentRequired:
        return 'Se requiere su consentimiento para modificar este archivo. Confirme la operación cuando se le solicite.';
      case AppErrorType.replaceFailed:
        return 'No se pudo reemplazar el archivo original. El archivo comprimido se guardó en la carpeta de destino.';
      case AppErrorType.cacheRegeneration:
        return 'Error regenerando cache del video. Intente nuevamente.';
      case AppErrorType.originalFileNotFound:
        return 'El archivo original no se encontró. Verifique que el archivo existe.';
      case AppErrorType.dependencyNotAvailable:
        return 'Una dependencia crítica no está disponible. Reinicie la aplicación.';
      case AppErrorType.cancelled:
        return 'Operación cancelada.';
      case AppErrorType.unknown:
        return 'Ocurrió un error inesperado. Intente nuevamente.';
    }
  }

  /// Obtiene el icono apropiado para el tipo de error
  String get icon {
    switch (type) {
      case AppErrorType.fileNotFound:
        return '[FILE]';
      case AppErrorType.permissionDenied:
        return '[PERMISSION]';
      case AppErrorType.processingFailed:
        return '[PROCESSING]';
      case AppErrorType.hardwareDetection:
        return '[HARDWARE]';
      case AppErrorType.networkError:
        return '[NETWORK]';
      case AppErrorType.validationError:
        return '[WARNING]';
      case AppErrorType.mediaStoreError:
        return '[MOBILE]';
      case AppErrorType.consentRequired:
        return '[CONSENT]';
      case AppErrorType.replaceFailed:
        return '[REPLACE]';
      case AppErrorType.cacheRegeneration:
        return '[CACHE]';
      case AppErrorType.originalFileNotFound:
        return '[FILE]';
      case AppErrorType.dependencyNotAvailable:
        return '[DEPENDENCY]';
      case AppErrorType.cancelled:
        return '[CANCEL]';
      case AppErrorType.unknown:
        return '[UNKNOWN]';
    }
  }

  /// Verifica si el error es recuperable
  bool get isRecoverable {
    switch (type) {
      case AppErrorType.fileNotFound:
      case AppErrorType.permissionDenied:
      case AppErrorType.validationError:
      case AppErrorType.consentRequired:
        return true;
      case AppErrorType.processingFailed:
      case AppErrorType.hardwareDetection:
      case AppErrorType.networkError:
      case AppErrorType.mediaStoreError:
      case AppErrorType.replaceFailed:
      case AppErrorType.cacheRegeneration:
      case AppErrorType.originalFileNotFound:
      case AppErrorType.dependencyNotAvailable:
      case AppErrorType.unknown:
        return false;
      case AppErrorType.cancelled:
        return true;
    }
  }

  @override
  String toString() {
    return 'AppError(type: $type, message: $message, details: $details)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppError &&
        other.type == type &&
        other.message == message &&
        other.details == details;
  }

  @override
  int get hashCode {
    return Object.hash(type, message, details);
  }
}

/// Excepciones específicas de la aplicación
class PermissionException implements Exception {
  final String permission;
  final String message;

  const PermissionException(this.permission, [this.message = '']);

  @override
  String toString() => 'PermissionException: $permission - $message';
}

class NetworkException implements Exception {
  final String message;

  const NetworkException([this.message = 'Network error']);

  @override
  String toString() => 'NetworkException: $message';
}

class FileSystemException implements Exception {
  final String path;
  final String operation;
  final String message;

  const FileSystemException(this.path, this.operation, [this.message = '']);

  @override
  String toString() => 'FileSystemException: $operation on $path - $message';
}
