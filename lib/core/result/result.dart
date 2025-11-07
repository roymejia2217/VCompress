/// Result type para manejo de errores centralizado
/// Proporciona una forma segura de manejar operaciones que pueden fallar
sealed class Result<T, E> {
  const Result();

  /// Verifica si el resultado es exitoso
  bool get isSuccess => this is Success<T, E>;

  /// Verifica si el resultado es un fallo
  bool get isFailure => this is Failure<T, E>;

  /// Obtiene los datos si el resultado es exitoso
  T? get data => isSuccess ? (this as Success<T, E>).data : null;

  /// Obtiene el error si el resultado es un fallo
  E? get error => isFailure ? (this as Failure<T, E>).error : null;

  /// Ejecuta una función si el resultado es exitoso
  Result<U, E> map<U>(U Function(T) transform) {
    if (isSuccess) {
      return Success(transform((this as Success<T, E>).data));
    }
    return Failure((this as Failure<T, E>).error);
  }

  /// Ejecuta una función si el resultado es exitoso
  Result<T, F> mapError<F>(F Function(E) transform) {
    if (isFailure) {
      return Failure(transform((this as Failure<T, E>).error));
    }
    return Success((this as Success<T, E>).data);
  }

  /// Ejecuta una función si el resultado es exitoso, o devuelve un valor por defecto
  R fold<R>(R Function(E) onFailure, R Function(T) onSuccess) {
    if (isSuccess) {
      return onSuccess((this as Success<T, E>).data);
    }
    return onFailure((this as Failure<T, E>).error);
  }
}

/// Resultado exitoso
class Success<T, E> extends Result<T, E> {
  @override
  final T data;
  const Success(this.data);

  @override
  String toString() => 'Success($data)';
}

/// Resultado fallido
class Failure<T, E> extends Result<T, E> {
  @override
  final E error;
  const Failure(this.error);

  @override
  String toString() => 'Failure($error)';
}
