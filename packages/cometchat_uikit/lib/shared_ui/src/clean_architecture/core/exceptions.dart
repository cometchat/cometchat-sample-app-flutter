/// Base exception for clean architecture
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalException;

  AppException({required this.message, this.code, this.originalException});

  @override
  String toString() => 'AppException: $message (code: $code)';
}

/// Exception from remote API/SDK
class RemoteException extends AppException {
  RemoteException({
    required super.message,
    super.code,
    super.originalException,
  });

  @override
  String toString() => 'RemoteException: $message';
}

/// Exception from local storage
class LocalException extends AppException {
  LocalException({required super.message, super.code, super.originalException});

  @override
  String toString() => 'LocalException: $message';
}

/// Exception from invalid input
class ValidationException extends AppException {
  ValidationException({
    required super.message,
    super.code,
    super.originalException,
  });

  @override
  String toString() => 'ValidationException: $message';
}

/// Unknown/unexpected exception
class UnknownException extends AppException {
  UnknownException({
    required super.message,
    super.code,
    super.originalException,
  });

  @override
  String toString() => 'UnknownException: $message';
}
