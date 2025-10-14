import 'package:equatable/equatable.dart';

/// Base failure class for use case results
/// Implements Either pattern for functional error handling
abstract class Failure extends Equatable {
  final String message;
  final String? code;
  final dynamic originalError;

  const Failure(this.message, {this.code, this.originalError});

  @override
  List<Object?> get props => [message, code, originalError];

  @override
  String toString() => 'Failure: $message (Code: $code)';
}

/// Authentication failures
/// Used when authentication operations fail
class AuthFailure extends Failure {
  const AuthFailure(super.message, {super.code, super.originalError});
}

/// Database operation failures
/// Used when SQLite operations fail
class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message, {super.code, super.originalError});
}

/// Validation failures
/// Used when input validation or business rules fail
class ValidationFailure extends Failure {
  final Map<String, String> fieldErrors;

  const ValidationFailure(
    super.message, {
    this.fieldErrors = const {},
    super.code,
    super.originalError,
  });

  @override
  List<Object?> get props => [message, code, fieldErrors, originalError];
}

/// Data processing failures
/// Used when data transformation or business logic fails
class DataFailure extends Failure {
  const DataFailure(super.message, {super.code, super.originalError});
}

/// Storage operation failures
/// Used when local storage operations fail
class StorageFailure extends Failure {
  const StorageFailure(super.message, {super.code, super.originalError});
}

/// Network operation failures (for future use)
/// Used when network operations fail
class NetworkFailure extends Failure {
  const NetworkFailure(super.message, {super.code, super.originalError});
}

/// Configuration failures
/// Used when app configuration or initialization fails
class ConfigurationFailure extends Failure {
  const ConfigurationFailure(super.message, {super.code, super.originalError});
}
