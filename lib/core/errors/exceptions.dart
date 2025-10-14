/// Base exception class for all application exceptions
/// Follows Open/Closed Principle - open for extension, closed for modification
abstract class AppException implements Exception {
  final String message;
  final String code;
  final dynamic originalError;
  final StackTrace? stackTrace;
  final ExceptionCategory category;

  const AppException(
    this.message, {
    required this.code,
    this.originalError,
    this.stackTrace,
    required this.category,
  });

  /// Returns user-friendly error message
  String get userMessage => message;

  /// Returns technical error details for logging
  String get technicalDetails =>
      'Exception: ${runtimeType.toString()}\n'
      'Code: $code\n'
      'Message: $message\n'
      'Category: ${category.name}\n'
      'Original Error: ${originalError?.toString() ?? 'None'}\n'
      'Stack Trace: ${stackTrace?.toString() ?? 'None'}';

  @override
  String toString() => '${runtimeType.toString()}: $message (Code: $code)';
}

/// Exception categories for error handling and user experience
enum ExceptionCategory {
  /// User input or validation errors - usually recoverable
  validation('Validation'),

  /// Authentication and authorization errors - may require re-login
  authentication('Authentication'),

  /// Database and storage errors - may require retry
  storage('Storage'),

  /// Data processing and transformation errors - usually indicates bug
  data('Data Processing'),

  /// Network connectivity errors - may require retry
  network('Network'),

  /// App configuration and setup errors - usually fatal
  configuration('Configuration'),

  /// Unknown or unexpected errors - usually indicates bug
  unknown('Unknown');

  const ExceptionCategory(this.displayName);
  final String displayName;
}

/// Database-related exceptions
/// Used for SQLite operations, schema issues, and data persistence errors
class DatabaseException extends AppException {
  const DatabaseException(
    super.message, {
    String? code,
    super.originalError,
    super.stackTrace,
  }) : super(
         code: code ?? DatabaseErrorCodes.general,
         category: ExceptionCategory.storage,
       );

  /// Factory constructors for common database errors
  const DatabaseException.connectionFailed([String? details])
    : super(
        'Failed to connect to database${details != null ? ': $details' : ''}',
        code: DatabaseErrorCodes.connectionFailed,
        category: ExceptionCategory.storage,
      );

  const DatabaseException.queryFailed(String query, [dynamic error])
    : super(
        'Database query failed: $query',
        code: DatabaseErrorCodes.queryFailed,
        originalError: error,
        category: ExceptionCategory.storage,
      );

  const DatabaseException.migrationFailed(String version, [dynamic error])
    : super(
        'Database migration failed for version: $version',
        code: DatabaseErrorCodes.migrationFailed,
        originalError: error,
        category: ExceptionCategory.storage,
      );

  const DatabaseException.constraintViolation(
    String constraint, [
    dynamic error,
  ]) : super(
         'Database constraint violation: $constraint',
         code: DatabaseErrorCodes.constraintViolation,
         originalError: error,
         category: ExceptionCategory.storage,
       );
}

/// Database error codes for specific error identification
class DatabaseErrorCodes {
  static const String general = 'DB_001';
  static const String connectionFailed = 'DB_002';
  static const String queryFailed = 'DB_003';
  static const String migrationFailed = 'DB_004';
  static const String constraintViolation = 'DB_005';
  static const String transactionFailed = 'DB_006';
  static const String tableNotFound = 'DB_007';
  static const String dataCorruption = 'DB_008';
}

/// Authentication-related exceptions
/// Used for sign-in, sign-out, and authentication state errors
class AuthException extends AppException {
  const AuthException(
    super.message, {
    String? code,
    super.originalError,
    super.stackTrace,
  }) : super(
         code: code ?? AuthErrorCodes.general,
         category: ExceptionCategory.authentication,
       );

  /// Factory constructors for common authentication errors
  const AuthException.signInFailed([String? provider])
    : super(
        'Sign-in failed${provider != null ? ' with $provider' : ''}',
        code: AuthErrorCodes.signInFailed,
        category: ExceptionCategory.authentication,
      );

  const AuthException.signOutFailed([dynamic error])
    : super(
        'Sign-out failed',
        code: AuthErrorCodes.signOutFailed,
        originalError: error,
        category: ExceptionCategory.authentication,
      );

  const AuthException.userNotFound()
    : super(
        'User not found or not authenticated',
        code: AuthErrorCodes.userNotFound,
        category: ExceptionCategory.authentication,
      );

  const AuthException.sessionExpired()
    : super(
        'Authentication session has expired',
        code: AuthErrorCodes.sessionExpired,
        category: ExceptionCategory.authentication,
      );

  const AuthException.permissionDenied(String action)
    : super(
        'Permission denied for action: $action',
        code: AuthErrorCodes.permissionDenied,
        category: ExceptionCategory.authentication,
      );
}

/// Authentication error codes for specific error identification
class AuthErrorCodes {
  static const String general = 'AUTH_001';
  static const String signInFailed = 'AUTH_002';
  static const String signOutFailed = 'AUTH_003';
  static const String userNotFound = 'AUTH_004';
  static const String sessionExpired = 'AUTH_005';
  static const String permissionDenied = 'AUTH_006';
  static const String invalidCredentials = 'AUTH_007';
  static const String accountDisabled = 'AUTH_008';
}

/// Validation-related exceptions
/// Used for form validation, input validation, and business rule violations
class ValidationException extends AppException {
  final Map<String, String> fieldErrors;

  const ValidationException(
    super.message, {
    this.fieldErrors = const {},
    String? code,
    super.originalError,
    super.stackTrace,
  }) : super(
         code: code ?? ValidationErrorCodes.general,
         category: ExceptionCategory.validation,
       );

  /// Factory constructors for common validation errors
  const ValidationException.requiredField(String fieldName)
    : fieldErrors = const {},
      super(
        '$fieldName is required',
        code: ValidationErrorCodes.requiredField,
        category: ExceptionCategory.validation,
      );

  const ValidationException.invalidFormat(
    String fieldName,
    String expectedFormat,
  ) : fieldErrors = const {},
      super(
        '$fieldName has invalid format. Expected: $expectedFormat',
        code: ValidationErrorCodes.invalidFormat,
        category: ExceptionCategory.validation,
      );

  const ValidationException.outOfRange(String fieldName, String range)
    : fieldErrors = const {},
      super(
        '$fieldName is out of range. Valid range: $range',
        code: ValidationErrorCodes.outOfRange,
        category: ExceptionCategory.validation,
      );

  const ValidationException.multipleFields(Map<String, String> errors)
    : fieldErrors = errors,
      super(
        'Multiple validation errors occurred',
        code: ValidationErrorCodes.multipleFields,
        category: ExceptionCategory.validation,
      );

  /// Returns true if this exception has field-specific errors
  bool get hasFieldErrors => fieldErrors.isNotEmpty;

  /// Returns error message for a specific field
  String? getFieldError(String fieldName) => fieldErrors[fieldName];
}

/// Validation error codes for specific error identification
class ValidationErrorCodes {
  static const String general = 'VAL_001';
  static const String requiredField = 'VAL_002';
  static const String invalidFormat = 'VAL_003';
  static const String outOfRange = 'VAL_004';
  static const String multipleFields = 'VAL_005';
  static const String invalidEmail = 'VAL_006';
  static const String invalidDate = 'VAL_007';
  static const String invalidLength = 'VAL_008';
}

/// Data processing exceptions
/// Used for JSON parsing, data transformation, and business logic errors
class DataException extends AppException {
  const DataException(
    super.message, {
    String? code,
    super.originalError,
    super.stackTrace,
  }) : super(
         code: code ?? DataErrorCodes.general,
         category: ExceptionCategory.data,
       );

  /// Factory constructors for common data errors
  const DataException.parsingFailed(String dataType, [dynamic error])
    : super(
        'Failed to parse $dataType data',
        code: DataErrorCodes.parsingFailed,
        originalError: error,
        category: ExceptionCategory.data,
      );

  const DataException.transformationFailed(String operation, [dynamic error])
    : super(
        'Data transformation failed: $operation',
        code: DataErrorCodes.transformationFailed,
        originalError: error,
        category: ExceptionCategory.data,
      );

  const DataException.notFound(String dataType, String identifier)
    : super(
        '$dataType not found: $identifier',
        code: DataErrorCodes.notFound,
        category: ExceptionCategory.data,
      );

  const DataException.corrupted(String dataType, [String? details])
    : super(
        'Corrupted $dataType data${details != null ? ': $details' : ''}',
        code: DataErrorCodes.corrupted,
        category: ExceptionCategory.data,
      );
}

/// Data error codes for specific error identification
class DataErrorCodes {
  static const String general = 'DATA_001';
  static const String parsingFailed = 'DATA_002';
  static const String transformationFailed = 'DATA_003';
  static const String notFound = 'DATA_004';
  static const String corrupted = 'DATA_005';
  static const String invalidStructure = 'DATA_006';
  static const String missingRequiredField = 'DATA_007';
}

/// Storage-related exceptions
/// Used for SharedPreferences, file system, and local storage errors
class StorageException extends AppException {
  const StorageException(
    super.message, {
    String? code,
    super.originalError,
    super.stackTrace,
  }) : super(
         code: code ?? StorageErrorCodes.general,
         category: ExceptionCategory.storage,
       );

  /// Factory constructors for common storage errors
  const StorageException.readFailed(String key, [dynamic error])
    : super(
        'Failed to read from storage: $key',
        code: StorageErrorCodes.readFailed,
        originalError: error,
        category: ExceptionCategory.storage,
      );

  const StorageException.writeFailed(String key, [dynamic error])
    : super(
        'Failed to write to storage: $key',
        code: StorageErrorCodes.writeFailed,
        originalError: error,
        category: ExceptionCategory.storage,
      );

  const StorageException.initializationFailed([dynamic error])
    : super(
        'Storage initialization failed',
        code: StorageErrorCodes.initializationFailed,
        originalError: error,
        category: ExceptionCategory.storage,
      );

  const StorageException.permissionDenied(String operation)
    : super(
        'Storage permission denied for: $operation',
        code: StorageErrorCodes.permissionDenied,
        category: ExceptionCategory.storage,
      );
}

/// Storage error codes for specific error identification
class StorageErrorCodes {
  static const String general = 'STOR_001';
  static const String readFailed = 'STOR_002';
  static const String writeFailed = 'STOR_003';
  static const String initializationFailed = 'STOR_004';
  static const String permissionDenied = 'STOR_005';
  static const String keyNotFound = 'STOR_006';
  static const String quotaExceeded = 'STOR_007';
}

/// Network-related exceptions (for future use)
/// Used for connectivity issues and network operations
class NetworkException extends AppException {
  const NetworkException(
    super.message, {
    String? code,
    super.originalError,
    super.stackTrace,
  }) : super(
         code: code ?? NetworkErrorCodes.general,
         category: ExceptionCategory.network,
       );

  /// Factory constructors for common network errors
  const NetworkException.noConnection()
    : super(
        'No internet connection available',
        code: NetworkErrorCodes.noConnection,
        category: ExceptionCategory.network,
      );

  const NetworkException.timeout(String operation)
    : super(
        'Network timeout during: $operation',
        code: NetworkErrorCodes.timeout,
        category: ExceptionCategory.network,
      );

  const NetworkException.serverError(int statusCode, [String? message])
    : super(
        'Server error ($statusCode)${message != null ? ': $message' : ''}',
        code: NetworkErrorCodes.serverError,
        category: ExceptionCategory.network,
      );
}

/// Network error codes for specific error identification
class NetworkErrorCodes {
  static const String general = 'NET_001';
  static const String noConnection = 'NET_002';
  static const String timeout = 'NET_003';
  static const String serverError = 'NET_004';
  static const String badRequest = 'NET_005';
  static const String unauthorized = 'NET_006';
  static const String forbidden = 'NET_007';
  static const String notFound = 'NET_008';
}

/// Configuration-related exceptions
/// Used for app configuration, environment setup, and initialization errors
class ConfigurationException extends AppException {
  const ConfigurationException(
    super.message, {
    String? code,
    super.originalError,
    super.stackTrace,
  }) : super(
         code: code ?? ConfigErrorCodes.general,
         category: ExceptionCategory.configuration,
       );

  /// Factory constructors for common configuration errors
  const ConfigurationException.missingConfiguration(String configKey)
    : super(
        'Missing required configuration: $configKey',
        code: ConfigErrorCodes.missingConfiguration,
        category: ExceptionCategory.configuration,
      );

  const ConfigurationException.invalidConfiguration(
    String configKey,
    String expectedType,
  ) : super(
        'Invalid configuration for $configKey. Expected: $expectedType',
        code: ConfigErrorCodes.invalidConfiguration,
        category: ExceptionCategory.configuration,
      );

  const ConfigurationException.initializationFailed(
    String component, [
    dynamic error,
  ]) : super(
         'Failed to initialize $component',
         code: ConfigErrorCodes.initializationFailed,
         originalError: error,
         category: ExceptionCategory.configuration,
       );
}

/// Configuration error codes for specific error identification
class ConfigErrorCodes {
  static const String general = 'CONF_001';
  static const String missingConfiguration = 'CONF_002';
  static const String invalidConfiguration = 'CONF_003';
  static const String initializationFailed = 'CONF_004';
  static const String environmentNotSet = 'CONF_005';
  static const String dependencyMissing = 'CONF_006';
}
