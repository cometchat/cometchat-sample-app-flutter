/// Generic Result wrapper for handling success and failure states
/// Following the Either pattern for functional error handling
abstract class Result<T> {
  const Result();

  /// Execute different logic based on result type
  R fold<R>(
    R Function(Failure failure) onFailure,
    R Function(T success) onSuccess,
  );

  /// Check if result is success
  bool get isSuccess => this is Success<T>;

  /// Check if result is failure
  bool get isFailure => this is Failure;
}

/// Failure state that can be returned from any Result<T>
class Failure extends Result<Never> {
  final String message;
  final String? code;
  final Exception? exception;

  const Failure({
    required this.message,
    this.code,
    this.exception,
  });

  @override
  R fold<R>(
    R Function(Failure failure) onFailure,
    R Function(Never success) onSuccess,
  ) {
    return onFailure(this);
  }

  @override
  String toString() => 'Failure(message: $message, code: $code)';
}

/// Success state containing the data
class Success<T> extends Result<T> {
  final T data;

  const Success(this.data);

  @override
  R fold<R>(
    R Function(Failure failure) onFailure,
    R Function(T success) onSuccess,
  ) {
    return onSuccess(data);
  }

  @override
  String toString() => 'Success(data: $data)';
}

/// Helper extension to simplify Result handling
extension ResultExtension<T> on Result<T> {
  /// Get data or null if failure
  T? getOrNull() {
    return fold(
      (_) => null,
      (data) => data,
    );
  }

  /// Execute callback on success
  void onSuccess(void Function(T) callback) {
    fold(
      (_) {},
      (data) => callback(data),
    );
  }

  /// Execute callback on failure
  void onFailure(void Function(Failure) callback) {
    fold(
      (failure) => callback(failure),
      (_) {},
    );
  }

  /// Map success value to another type
  Result<R> map<R>(R Function(T) transform) {
    return fold<Result<R>>(
      (failure) => failure as Result<R>,
      (data) => Success(transform(data)),
    );
  }

  /// Flat map for chaining results
  Result<R> flatMap<R>(Result<R> Function(T) transform) {
    return fold<Result<R>>(
      (failure) => failure as Result<R>,
      (data) => transform(data),
    );
  }
}
