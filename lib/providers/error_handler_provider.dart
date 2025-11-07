import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vcompressor/core/error/app_error.dart';
import 'package:vcompressor/core/logging/app_logger.dart';

/// Estado para manejar errores asíncronos
class ErrorState {
  final AppError? currentError;
  final List<AppError> errorHistory;
  final bool hasError;

  const ErrorState({this.currentError, this.errorHistory = const []})
    : hasError = currentError != null;

  ErrorState copyWith({AppError? currentError, List<AppError>? errorHistory}) {
    return ErrorState(
      currentError: currentError,
      errorHistory: errorHistory ?? this.errorHistory,
    );
  }

  ErrorState clearCurrentError() {
    return copyWith(currentError: null);
  }

  ErrorState addError(AppError error) {
    final newHistory = List<AppError>.from(errorHistory)..add(error);
    return copyWith(currentError: error, errorHistory: newHistory);
  }
}

/// Notifier para manejar errores de manera centralizada
class ErrorHandlerNotifier extends StateNotifier<ErrorState> {
  ErrorHandlerNotifier() : super(const ErrorState());

  /// Maneja un error y lo registra
  void handleError(AppError error, {String? context}) {
    AppLogger.error(
      'Error en ${context ?? 'operación'}: ${error.message}',
      tag: 'ErrorHandler',
    );

    state = state.addError(error);
  }

  /// Maneja un error desde una excepción
  void handleException(
    dynamic exception,
    StackTrace? stackTrace, {
    String? context,
  }) {
    final error = AppError.fromException(exception, stackTrace);
    handleError(error, context: context);
  }

  /// Limpia el error actual
  void clearError() {
    state = state.clearCurrentError();
  }

  /// Limpia todo el historial de errores
  void clearAllErrors() {
    state = const ErrorState();
  }

  /// Ejecuta una operación y maneja automáticamente los errores
  Future<T?> executeWithErrorHandling<T>(
    Future<T> Function() operation, {
    String? context,
    T? defaultValue,
  }) async {
    try {
      return await operation();
    } catch (e, stackTrace) {
      handleException(e, stackTrace, context: context);
      return defaultValue;
    }
  }

  /// Ejecuta una operación asíncrona y maneja errores con retry
  Future<T?> executeWithRetry<T>(
    Future<T> Function() operation, {
    String? context,
    int maxRetries = 3,
    Duration delay = const Duration(seconds: 1),
    T? defaultValue,
  }) async {
    int attempts = 0;

    while (attempts < maxRetries) {
      try {
        return await operation();
      } catch (e, stackTrace) {
        attempts++;

        if (attempts >= maxRetries) {
          handleException(e, stackTrace, context: context);
          return defaultValue;
        }

        AppLogger.warning(
          'Intento $attempts fallido en ${context ?? 'operación'}, reintentando...',
          tag: 'ErrorHandler',
        );

        await Future.delayed(delay * attempts); // Backoff exponencial
      }
    }

    return defaultValue;
  }
}

/// Provider para el manejador de errores
final errorHandlerProvider =
    StateNotifierProvider<ErrorHandlerNotifier, ErrorState>(
      (ref) => ErrorHandlerNotifier(),
    );

/// Provider para obtener solo el error actual
final currentErrorProvider = Provider<AppError?>(
  (ref) => ref.watch(errorHandlerProvider).currentError,
);

/// Provider para verificar si hay un error activo
final hasErrorProvider = Provider<bool>(
  (ref) => ref.watch(errorHandlerProvider).hasError,
);

/// Provider para obtener el historial de errores
final errorHistoryProvider = Provider<List<AppError>>(
  (ref) => ref.watch(errorHandlerProvider).errorHistory,
);

/// Provider para obtener el último error del historial
final lastErrorProvider = Provider<AppError?>((ref) {
  final history = ref.watch(errorHistoryProvider);
  return history.isNotEmpty ? history.last : null;
});

/// Extension para facilitar el manejo de errores en widgets
extension ErrorHandlerExtension on WidgetRef {
  /// Maneja un error de manera conveniente
  void handleError(AppError error, {String? context}) {
    read(errorHandlerProvider.notifier).handleError(error, context: context);
  }

  /// Maneja una excepción de manera conveniente
  void handleException(
    dynamic exception,
    StackTrace? stackTrace, {
    String? context,
  }) {
    read(
      errorHandlerProvider.notifier,
    ).handleException(exception, stackTrace, context: context);
  }

  /// Limpia el error actual
  void clearError() {
    read(errorHandlerProvider.notifier).clearError();
  }

  /// Ejecuta una operación con manejo automático de errores
  Future<T?> executeWithErrorHandling<T>(
    Future<T> Function() operation, {
    String? context,
    T? defaultValue,
  }) async {
    return read(errorHandlerProvider.notifier).executeWithErrorHandling(
      operation,
      context: context,
      defaultValue: defaultValue,
    );
  }

  /// Ejecuta una operación con retry automático
  Future<T?> executeWithRetry<T>(
    Future<T> Function() operation, {
    String? context,
    int maxRetries = 3,
    Duration delay = const Duration(seconds: 1),
    T? defaultValue,
  }) async {
    return read(errorHandlerProvider.notifier).executeWithRetry(
      operation,
      context: context,
      maxRetries: maxRetries,
      delay: delay,
      defaultValue: defaultValue,
    );
  }
}
