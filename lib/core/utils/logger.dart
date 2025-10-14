import 'package:logger/logger.dart';

/// Application logger utility
/// Provides structured logging with different levels
class AppLogger {
  static Logger? _logger;

  /// Gets the logger instance
  static Logger get _instance {
    _logger ??= Logger(
      printer: PrettyPrinter(
        methodCount: 2,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
        printTime: true,
      ),
      level: Level.debug, // Can be configured based on build mode
    );
    return _logger!;
  }

  /// Logs a debug message
  static void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    _instance.d(message, error: error, stackTrace: stackTrace);
  }

  /// Logs an info message
  static void info(String message, [dynamic error, StackTrace? stackTrace]) {
    _instance.i(message, error: error, stackTrace: stackTrace);
  }

  /// Logs a warning message
  static void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    _instance.w(message, error: error, stackTrace: stackTrace);
  }

  /// Logs an error message
  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _instance.e(message, error: error, stackTrace: stackTrace);
  }

  /// Logs a fatal error message
  static void fatal(String message, [dynamic error, StackTrace? stackTrace]) {
    _instance.f(message, error: error, stackTrace: stackTrace);
  }

  /// Logs a verbose message
  static void verbose(String message, [dynamic error, StackTrace? stackTrace]) {
    _instance.t(message, error: error, stackTrace: stackTrace);
  }
}
