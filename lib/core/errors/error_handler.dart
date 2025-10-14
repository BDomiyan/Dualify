import 'dart:async';
import 'dart:io';

import 'package:sqflite/sqflite.dart' as sqflite;

import '../utils/logger.dart';
import 'exceptions.dart' as app_exceptions;
import 'failures.dart';

/// Centralized error handling service
/// Follows Single Responsibility Principle for error processing
class ErrorHandler {
  /// Converts exceptions to appropriate failure types
  /// Provides consistent error mapping across the application
  static Failure handleException(Exception exception) {
    // Log technical details for debugging
    if (exception is app_exceptions.AppException) {
      AppLogger.error('AppException occurred', exception);
      AppLogger.debug('Technical details: ${exception.technicalDetails}');
      return _mapAppExceptionToFailure(exception);
    }

    AppLogger.error('System exception occurred: $exception', exception);

    // Handle SQLite exceptions
    if (exception is sqflite.DatabaseException) {
      return DatabaseFailure(
        'Database operation failed: ${exception.toString()}',
        code: 'DB_SYSTEM_ERROR',
        originalError: exception,
      );
    }

    // Handle file system exceptions
    if (exception is FileSystemException) {
      return StorageFailure(
        'File system error: ${exception.message}',
        code: 'STOR_SYSTEM_ERROR',
        originalError: exception,
      );
    }

    // Handle format exceptions (JSON parsing, etc.)
    if (exception is FormatException) {
      return DataFailure(
        'Data format error: ${exception.message}',
        code: 'DATA_FORMAT_ERROR',
        originalError: exception,
      );
    }

    // Handle argument exceptions (validation)
    if (exception is ArgumentError) {
      return ValidationFailure(
        'Invalid argument: ${exception.toString()}',
        code: 'VAL_SYSTEM_ERROR',
        originalError: exception,
      );
    }

    // Handle state errors
    if (exception is StateError) {
      return DataFailure(
        'Invalid state: ${exception.toString()}',
        code: 'DATA_STATE_ERROR',
        originalError: exception,
      );
    }

    // Handle timeout exceptions
    if (exception is TimeoutException) {
      return NetworkFailure(
        'Operation timed out: ${exception.toString()}',
        code: 'NET_TIMEOUT',
        originalError: exception,
      );
    }

    // Generic error handling
    return DataFailure(
      'An unexpected error occurred: ${exception.toString()}',
      code: 'SYSTEM_UNEXPECTED_ERROR',
      originalError: exception,
    );
  }

  /// Maps custom app exceptions to failure types
  /// Maintains separation between exception and failure domains
  static Failure _mapAppExceptionToFailure(
    app_exceptions.AppException exception,
  ) {
    switch (exception) {
      case app_exceptions.DatabaseException _:
        return DatabaseFailure(
          exception.message,
          code: exception.code,
          originalError: exception.originalError,
        );
      case app_exceptions.AuthException _:
        return AuthFailure(
          exception.message,
          code: exception.code,
          originalError: exception.originalError,
        );
      case app_exceptions.ValidationException _:
        final validationEx = exception;
        return ValidationFailure(
          exception.message,
          fieldErrors: validationEx.fieldErrors,
          code: exception.code,
          originalError: exception.originalError,
        );
      case app_exceptions.DataException _:
        return DataFailure(
          exception.message,
          code: exception.code,
          originalError: exception.originalError,
        );
      case app_exceptions.StorageException _:
        return StorageFailure(
          exception.message,
          code: exception.code,
          originalError: exception.originalError,
        );
      case app_exceptions.NetworkException _:
        return NetworkFailure(
          exception.message,
          code: exception.code,
          originalError: exception.originalError,
        );
      case app_exceptions.ConfigurationException _:
        return ConfigurationFailure(
          exception.message,
          code: exception.code,
          originalError: exception.originalError,
        );
      default:
        return DataFailure(
          exception.message,
          code: exception.code,
          originalError: exception.originalError,
        );
    }
  }

  /// Generates user-friendly error messages
  /// Translates technical errors to user-understandable text
  static String getUserFriendlyMessage(Failure failure) {
    switch (failure) {
      case DatabaseFailure _:
        return _getDatabaseUserMessage(failure.code ?? 'UNKNOWN');
      case AuthFailure _:
        return _getAuthUserMessage(failure.code ?? 'UNKNOWN');
      case ValidationFailure _:
        return _getValidationUserMessage(failure);
      case StorageFailure _:
        return _getStorageUserMessage(failure.code ?? 'UNKNOWN');
      case NetworkFailure _:
        return _getNetworkUserMessage(failure.code ?? 'UNKNOWN');
      case ConfigurationFailure _:
        return _getConfigurationUserMessage(failure.code ?? 'UNKNOWN');
      case DataFailure _:
        return _getDataUserMessage(failure.code ?? 'UNKNOWN');
      default:
        return 'Something went wrong. Please try again.';
    }
  }

  /// Database-specific user messages
  static String _getDatabaseUserMessage(String code) {
    switch (code) {
      case 'DB_002': // connectionFailed
        return 'Unable to connect to the database. Please restart the app.';
      case 'DB_003': // queryFailed
        return 'Unable to retrieve your data. Please try again.';
      case 'DB_004': // migrationFailed
        return 'App update failed. Please reinstall the app.';
      case 'DB_005': // constraintViolation
        return 'Data validation error. Please check your input.';
      default:
        return 'Unable to save your data. Please try again.';
    }
  }

  /// Authentication-specific user messages
  static String _getAuthUserMessage(String code) {
    switch (code) {
      case 'AUTH_002': // signInFailed
        return 'Sign-in failed. Please try again.';
      case 'AUTH_004': // userNotFound
        return 'User account not found. Please sign in.';
      case 'AUTH_005': // sessionExpired
        return 'Your session has expired. Please sign in again.';
      case 'AUTH_006': // permissionDenied
        return 'You don\'t have permission to perform this action.';
      case 'AUTH_007': // invalidCredentials
        return 'Invalid credentials. Please check and try again.';
      default:
        return 'Authentication failed. Please sign in again.';
    }
  }

  /// Validation-specific user messages
  static String _getValidationUserMessage(ValidationFailure failure) {
    if (failure.fieldErrors.isNotEmpty) {
      final firstError = failure.fieldErrors.values.first;
      return firstError;
    }

    switch (failure.code) {
      case 'VAL_002': // requiredField
        return 'Please fill in all required fields.';
      case 'VAL_003': // invalidFormat
        return 'Please check the format of your input.';
      case 'VAL_004': // outOfRange
        return 'Please enter a value within the valid range.';
      case 'VAL_006': // invalidEmail
        return 'Please enter a valid email address.';
      case 'VAL_007': // invalidDate
        return 'Please enter a valid date.';
      default:
        return 'Please check your input and try again.';
    }
  }

  /// Storage-specific user messages
  static String _getStorageUserMessage(String code) {
    switch (code) {
      case 'STOR_002': // readFailed
        return 'Unable to load your settings. Using defaults.';
      case 'STOR_003': // writeFailed
        return 'Unable to save your settings. Please try again.';
      case 'STOR_004': // initializationFailed
        return 'Storage initialization failed. Please restart the app.';
      case 'STOR_005': // permissionDenied
        return 'Storage permission denied. Please check app permissions.';
      case 'STOR_007': // quotaExceeded
        return 'Storage space full. Please free up some space.';
      default:
        return 'Unable to access local storage. Please try again.';
    }
  }

  /// Network-specific user messages
  static String _getNetworkUserMessage(String code) {
    switch (code) {
      case 'NET_002': // noConnection
        return 'No internet connection. Please check your network.';
      case 'NET_003': // timeout
        return 'Request timed out. Please try again.';
      case 'NET_004': // serverError
        return 'Server error. Please try again later.';
      case 'NET_005': // badRequest
        return 'Invalid request. Please contact support.';
      case 'NET_006': // unauthorized
        return 'Authentication required. Please sign in.';
      default:
        return 'Network error. Please check your connection.';
    }
  }

  /// Configuration-specific user messages
  static String _getConfigurationUserMessage(String code) {
    switch (code) {
      case 'CONF_002': // missingConfiguration
        return 'App configuration incomplete. Please reinstall.';
      case 'CONF_004': // initializationFailed
        return 'App initialization failed. Please restart.';
      default:
        return 'Configuration error. Please restart the app.';
    }
  }

  /// Data-specific user messages
  static String _getDataUserMessage(String code) {
    switch (code) {
      case 'DATA_002': // parsingFailed
        return 'Unable to process data. Please contact support.';
      case 'DATA_004': // notFound
        return 'Requested data not found.';
      case 'DATA_005': // corrupted
        return 'Data appears to be corrupted. Please contact support.';
      case 'DATA_FORMAT_ERROR':
        return 'Data format error. Please contact support.';
      default:
        return 'Unable to process data. Please try again.';
    }
  }

  /// Determines if an error is recoverable
  /// Helps UI decide whether to show retry options
  static bool isRecoverable(Failure failure) {
    switch (failure) {
      case DatabaseFailure _:
        return _isDatabaseRecoverable(failure.code ?? 'UNKNOWN');
      case StorageFailure _:
        return _isStorageRecoverable(failure.code ?? 'UNKNOWN');
      case NetworkFailure _:
        return _isNetworkRecoverable(failure.code ?? 'UNKNOWN');
      case AuthFailure _:
        return _isAuthRecoverable(failure.code ?? 'UNKNOWN');
      case ValidationFailure _:
        return false; // User needs to fix input
      case ConfigurationFailure _:
        return _isConfigurationRecoverable(failure.code ?? 'UNKNOWN');
      case DataFailure _:
        return _isDataRecoverable(failure.code ?? 'UNKNOWN');
      default:
        return true;
    }
  }

  /// Database error recoverability
  static bool _isDatabaseRecoverable(String code) {
    switch (code) {
      case 'DB_002': // connectionFailed
      case 'DB_003': // queryFailed
      case 'DB_006': // transactionFailed
        return true;
      case 'DB_004': // migrationFailed
      case 'DB_005': // constraintViolation
      case 'DB_008': // dataCorruption
        return false;
      default:
        return true;
    }
  }

  /// Storage error recoverability
  static bool _isStorageRecoverable(String code) {
    switch (code) {
      case 'STOR_002': // readFailed
      case 'STOR_003': // writeFailed
        return true;
      case 'STOR_004': // initializationFailed
      case 'STOR_005': // permissionDenied
      case 'STOR_007': // quotaExceeded
        return false;
      default:
        return true;
    }
  }

  /// Network error recoverability
  static bool _isNetworkRecoverable(String code) {
    switch (code) {
      case 'NET_002': // noConnection
      case 'NET_003': // timeout
      case 'NET_004': // serverError
        return true;
      case 'NET_005': // badRequest
      case 'NET_006': // unauthorized
      case 'NET_007': // forbidden
        return false;
      default:
        return true;
    }
  }

  /// Authentication error recoverability
  static bool _isAuthRecoverable(String code) {
    switch (code) {
      case 'AUTH_002': // signInFailed
      case 'AUTH_003': // signOutFailed
        return true;
      case 'AUTH_004': // userNotFound
      case 'AUTH_005': // sessionExpired
      case 'AUTH_006': // permissionDenied
      case 'AUTH_007': // invalidCredentials
        return false;
      default:
        return true;
    }
  }

  /// Configuration error recoverability
  static bool _isConfigurationRecoverable(String code) {
    // Most configuration errors require app restart or developer intervention
    return false;
  }

  /// Data error recoverability
  static bool _isDataRecoverable(String code) {
    switch (code) {
      case 'DATA_002': // parsingFailed
      case 'DATA_005': // corrupted
      case 'DATA_FORMAT_ERROR':
        return false;
      case 'DATA_003': // transformationFailed
      case 'DATA_004': // notFound
        return true;
      default:
        return true;
    }
  }

  /// Gets appropriate retry delay based on failure type
  /// Provides exponential backoff for different error types
  static Duration getRetryDelay(Failure failure, int attemptCount) {
    final baseDelay = const Duration(seconds: 1);
    final maxDelay = const Duration(seconds: 30);

    switch (failure) {
      case DatabaseFailure _:
      case StorageFailure _:
        // Quick retry for local operations
        final delay = Duration(milliseconds: 500 * attemptCount);
        return delay > maxDelay ? maxDelay : delay;
      case NetworkFailure _:
        // Exponential backoff for network operations
        final delay = Duration(seconds: (2 * attemptCount).clamp(1, 30));
        return delay;
      case AuthFailure _:
        // Longer delay for auth operations to prevent spam
        final delay = Duration(seconds: (3 * attemptCount).clamp(2, 60));
        return delay;
      default:
        // Standard retry delay
        final delay = Duration(seconds: baseDelay.inSeconds * attemptCount);
        return delay > maxDelay ? maxDelay : delay;
    }
  }

  /// Gets recovery suggestions for the user
  /// Provides actionable steps to resolve the error
  static List<String> getRecoverySuggestions(Failure failure) {
    switch (failure) {
      case DatabaseFailure _:
        return _getDatabaseRecoverySuggestions(failure.code ?? 'UNKNOWN');
      case StorageFailure _:
        return _getStorageRecoverySuggestions(failure.code ?? 'UNKNOWN');
      case NetworkFailure _:
        return _getNetworkRecoverySuggestions(failure.code ?? 'UNKNOWN');
      case AuthFailure _:
        return _getAuthRecoverySuggestions(failure.code ?? 'UNKNOWN');
      case ValidationFailure _:
        return ['Please correct the highlighted fields and try again.'];
      case ConfigurationFailure _:
        return [
          'Please restart the app.',
          'If the problem persists, reinstall the app.',
        ];
      case DataFailure _:
        return _getDataRecoverySuggestions(failure.code ?? 'UNKNOWN');
      default:
        return [
          'Please try again.',
          'If the problem persists, contact support.',
        ];
    }
  }

  /// Database recovery suggestions
  static List<String> _getDatabaseRecoverySuggestions(String code) {
    switch (code) {
      case 'DB_002': // connectionFailed
        return ['Restart the app.', 'Free up device storage space.'];
      case 'DB_003': // queryFailed
        return [
          'Try again in a moment.',
          'Restart the app if the problem persists.',
        ];
      case 'DB_004': // migrationFailed
        return [
          'Reinstall the app.',
          'Contact support if the problem persists.',
        ];
      case 'DB_005': // constraintViolation
        return [
          'Check your input data.',
          'Ensure all required fields are filled.',
        ];
      default:
        return ['Try again.', 'Restart the app if the problem persists.'];
    }
  }

  /// Storage recovery suggestions
  static List<String> _getStorageRecoverySuggestions(String code) {
    switch (code) {
      case 'STOR_005': // permissionDenied
        return [
          'Check app permissions in device settings.',
          'Grant storage access to the app.',
        ];
      case 'STOR_007': // quotaExceeded
        return [
          'Free up device storage space.',
          'Clear app cache in device settings.',
        ];
      default:
        return ['Try again.', 'Restart the app if the problem persists.'];
    }
  }

  /// Network recovery suggestions
  static List<String> _getNetworkRecoverySuggestions(String code) {
    switch (code) {
      case 'NET_002': // noConnection
        return [
          'Check your internet connection.',
          'Try switching between WiFi and mobile data.',
        ];
      case 'NET_003': // timeout
        return [
          'Check your internet connection.',
          'Try again with a better connection.',
        ];
      case 'NET_004': // serverError
        return [
          'Try again later.',
          'The server may be temporarily unavailable.',
        ];
      default:
        return ['Check your internet connection.', 'Try again in a moment.'];
    }
  }

  /// Authentication recovery suggestions
  static List<String> _getAuthRecoverySuggestions(String code) {
    switch (code) {
      case 'AUTH_004': // userNotFound
      case 'AUTH_005': // sessionExpired
        return ['Please sign in again.', 'Your session may have expired.'];
      case 'AUTH_007': // invalidCredentials
        return ['Check your credentials.', 'Try signing in again.'];
      default:
        return [
          'Try signing in again.',
          'Contact support if the problem persists.',
        ];
    }
  }

  /// Data recovery suggestions
  static List<String> _getDataRecoverySuggestions(String code) {
    switch (code) {
      case 'DATA_002': // parsingFailed
      case 'DATA_005': // corrupted
        return [
          'Contact support.',
          'This appears to be a data integrity issue.',
        ];
      case 'DATA_004': // notFound
        return [
          'Try refreshing the data.',
          'The requested information may have been moved.',
        ];
      default:
        return ['Try again.', 'Contact support if the problem persists.'];
    }
  }
}
