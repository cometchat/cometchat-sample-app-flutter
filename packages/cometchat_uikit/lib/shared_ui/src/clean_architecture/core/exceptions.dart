/// Base exception for clean architecture
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalException;

  AppException({
    required this.message,
    this.code,
    this.originalException,
  });

  @override
  String toString() => 'AppException: $message (code: $code)';
}

/// Exception from remote API/SDK
class RemoteException extends AppException {
  RemoteException({
    required String message,
    String? code,
    dynamic originalException,
  }) : super(
    message: message,
    code: code,
    originalException: originalException,
  );

  @override
  String toString() => 'RemoteException: $message';
}

/// Exception from local storage
class LocalException extends AppException {
  LocalException({
    required String message,
    String? code,
    dynamic originalException,
  }) : super(
    message: message,
    code: code,
    originalException: originalException,
  );

  @override
  String toString() => 'LocalException: $message';
}

/// Exception from invalid input
class ValidationException extends AppException {
  ValidationException({
    required String message,
    String? code,
    dynamic originalException,
  }) : super(
    message: message,
    code: code,
    originalException: originalException,
  );

  @override
  String toString() => 'ValidationException: $message';
}

/// Unknown/unexpected exception
class UnknownException extends AppException {
  UnknownException({
    required String message,
    String? code,
    dynamic originalException,
  }) : super(
    message: message,
    code: code,
    originalException: originalException,
  );

  @override
  String toString() => 'UnknownException: $message';
}
