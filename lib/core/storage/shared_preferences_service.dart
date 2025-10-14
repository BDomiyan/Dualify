import 'package:shared_preferences/shared_preferences.dart';

import '../errors/exceptions.dart';
import '../utils/logger.dart';

/// SharedPreferences service wrapper following Single Responsibility Principle
/// Provides type-safe access to SharedPreferences with proper error handling
class SharedPreferencesService {
  // Keys for different stored values
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _userIdKey = 'user_id';
  static const String _userEmailKey = 'user_email';
  static const String _userDisplayNameKey = 'user_display_name';
  static const String _userPhotoUrlKey = 'user_photo_url';
  static const String _authProviderKey = 'auth_provider';
  static const String _lastSignInKey = 'last_sign_in';
  static const String _sessionIdKey = 'session_id';
  static const String _themeKey = 'theme_mode';
  static const String _onboardingCompleteKey = 'onboarding_complete';
  static const String _firstLaunchKey = 'first_launch';
  static const String _appVersionKey = 'app_version';

  static SharedPreferences? _prefs;

  /// Initializes SharedPreferences instance
  /// Must be called before using any other methods
  static Future<void> init() async {
    try {
      AppLogger.debug('Initializing SharedPreferences...');
      _prefs = await SharedPreferences.getInstance();
      AppLogger.debug('SharedPreferences initialized successfully');
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to initialize SharedPreferences: $e',
        e,
        stackTrace,
      );
      throw StorageException(
        'Failed to initialize SharedPreferences',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Gets SharedPreferences instance with null safety
  /// Throws StorageException if not initialized
  static SharedPreferences get prefs {
    if (_prefs == null) {
      const error = 'SharedPreferences not initialized. Call init() first.';
      AppLogger.error(error);
      throw const StorageException(error, code: 'NOT_INITIALIZED');
    }
    return _prefs!;
  }

  // Authentication state management

  /// Gets the current login status
  /// Returns false if not set or if an error occurs
  static bool get isLoggedIn {
    try {
      return prefs.getBool(_isLoggedInKey) ?? false;
    } catch (e) {
      AppLogger.warning('Error reading login status: $e', e);
      return false;
    }
  }

  /// Sets the login status
  /// Throws StorageException if operation fails
  static Future<void> setLoggedIn(bool value) async {
    try {
      AppLogger.debug('Setting login status to: $value');
      final success = await prefs.setBool(_isLoggedInKey, value);
      if (!success) {
        throw const StorageException('Failed to save login status');
      }
      AppLogger.debug('Login status saved successfully');
    } catch (e, stackTrace) {
      AppLogger.error('Error setting login status: $e', e, stackTrace);
      throw StorageException(
        'Failed to save login status',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Gets the current user ID
  /// Returns null if not set or if an error occurs
  static String? get userId {
    try {
      return prefs.getString(_userIdKey);
    } catch (e) {
      AppLogger.warning('Error reading user ID: $e', e);
      return null;
    }
  }

  /// Sets the user ID
  /// Throws StorageException if operation fails
  static Future<void> setUserId(String value) async {
    try {
      AppLogger.debug('Setting user ID: $value');
      final success = await prefs.setString(_userIdKey, value);
      if (!success) {
        throw const StorageException('Failed to save user ID');
      }
      AppLogger.debug('User ID saved successfully');
    } catch (e, stackTrace) {
      AppLogger.error('Error setting user ID: $e', e, stackTrace);
      throw StorageException(
        'Failed to save user ID',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Gets the current user email
  /// Returns null if not set or if an error occurs
  static String? get userEmail {
    try {
      return prefs.getString(_userEmailKey);
    } catch (e) {
      AppLogger.warning('Error reading user email: $e', e);
      return null;
    }
  }

  /// Sets the user email
  /// Throws StorageException if operation fails
  static Future<void> setUserEmail(String value) async {
    try {
      AppLogger.debug('Setting user email: $value');
      final success = await prefs.setString(_userEmailKey, value);
      if (!success) {
        throw const StorageException('Failed to save user email');
      }
      AppLogger.debug('User email saved successfully');
    } catch (e, stackTrace) {
      AppLogger.error('Error setting user email: $e', e, stackTrace);
      throw StorageException(
        'Failed to save user email',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Gets the current user display name
  /// Returns null if not set or if an error occurs
  static String? get userDisplayName {
    try {
      return prefs.getString(_userDisplayNameKey);
    } catch (e) {
      AppLogger.warning('Error reading user display name: $e', e);
      return null;
    }
  }

  /// Sets the user display name
  /// Throws StorageException if operation fails
  static Future<void> setUserDisplayName(String? value) async {
    try {
      AppLogger.debug('Setting user display name: $value');
      bool success;
      if (value != null) {
        success = await prefs.setString(_userDisplayNameKey, value);
      } else {
        success = await prefs.remove(_userDisplayNameKey);
      }
      if (!success) {
        throw const StorageException('Failed to save user display name');
      }
      AppLogger.debug('User display name saved successfully');
    } catch (e, stackTrace) {
      AppLogger.error('Error setting user display name: $e', e, stackTrace);
      throw StorageException(
        'Failed to save user display name',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Gets the current user photo URL
  /// Returns null if not set or if an error occurs
  static String? get userPhotoUrl {
    try {
      return prefs.getString(_userPhotoUrlKey);
    } catch (e) {
      AppLogger.warning('Error reading user photo URL: $e', e);
      return null;
    }
  }

  /// Sets the user photo URL
  /// Throws StorageException if operation fails
  static Future<void> setUserPhotoUrl(String? value) async {
    try {
      AppLogger.debug('Setting user photo URL: $value');
      bool success;
      if (value != null) {
        success = await prefs.setString(_userPhotoUrlKey, value);
      } else {
        success = await prefs.remove(_userPhotoUrlKey);
      }
      if (!success) {
        throw const StorageException('Failed to save user photo URL');
      }
      AppLogger.debug('User photo URL saved successfully');
    } catch (e, stackTrace) {
      AppLogger.error('Error setting user photo URL: $e', e, stackTrace);
      throw StorageException(
        'Failed to save user photo URL',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Gets the current auth provider
  /// Returns null if not set or if an error occurs
  static String? get authProvider {
    try {
      return prefs.getString(_authProviderKey);
    } catch (e) {
      AppLogger.warning('Error reading auth provider: $e', e);
      return null;
    }
  }

  /// Sets the auth provider
  /// Throws StorageException if operation fails
  static Future<void> setAuthProvider(String value) async {
    try {
      AppLogger.debug('Setting auth provider: $value');
      final success = await prefs.setString(_authProviderKey, value);
      if (!success) {
        throw const StorageException('Failed to save auth provider');
      }
      AppLogger.debug('Auth provider saved successfully');
    } catch (e, stackTrace) {
      AppLogger.error('Error setting auth provider: $e', e, stackTrace);
      throw StorageException(
        'Failed to save auth provider',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Gets the last sign-in timestamp
  /// Returns null if not set or if an error occurs
  static DateTime? get lastSignIn {
    try {
      final timestamp = prefs.getInt(_lastSignInKey);
      return timestamp != null
          ? DateTime.fromMillisecondsSinceEpoch(timestamp)
          : null;
    } catch (e) {
      AppLogger.warning('Error reading last sign-in: $e', e);
      return null;
    }
  }

  /// Sets the last sign-in timestamp
  /// Throws StorageException if operation fails
  static Future<void> setLastSignIn(DateTime value) async {
    try {
      AppLogger.debug('Setting last sign-in: $value');
      final success = await prefs.setInt(
        _lastSignInKey,
        value.millisecondsSinceEpoch,
      );
      if (!success) {
        throw const StorageException('Failed to save last sign-in');
      }
      AppLogger.debug('Last sign-in saved successfully');
    } catch (e, stackTrace) {
      AppLogger.error('Error setting last sign-in: $e', e, stackTrace);
      throw StorageException(
        'Failed to save last sign-in',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Gets the current session ID
  /// Returns null if not set or if an error occurs
  static String? get sessionId {
    try {
      return prefs.getString(_sessionIdKey);
    } catch (e) {
      AppLogger.warning('Error reading session ID: $e', e);
      return null;
    }
  }

  /// Sets the session ID
  /// Throws StorageException if operation fails
  static Future<void> setSessionId(String? value) async {
    try {
      AppLogger.debug('Setting session ID: $value');
      bool success;
      if (value != null) {
        success = await prefs.setString(_sessionIdKey, value);
      } else {
        success = await prefs.remove(_sessionIdKey);
      }
      if (!success) {
        throw const StorageException('Failed to save session ID');
      }
      AppLogger.debug('Session ID saved successfully');
    } catch (e, stackTrace) {
      AppLogger.error('Error setting session ID: $e', e, stackTrace);
      throw StorageException(
        'Failed to save session ID',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  // Onboarding and Profile state management

  /// Gets the onboarding completion status
  /// Returns false if not set or if an error occurs
  static bool get isOnboardingComplete {
    try {
      return prefs.getBool(_onboardingCompleteKey) ?? false;
    } catch (e) {
      AppLogger.warning('Error reading onboarding status: $e', e);
      return false;
    }
  }

  /// Checks if user has completed profile setup
  /// Returns true if onboarding is complete (profile exists)
  static bool get hasProfile {
    return isOnboardingComplete;
  }

  /// Sets the onboarding completion status
  /// Throws StorageException if operation fails
  static Future<void> setOnboardingComplete(bool value) async {
    try {
      AppLogger.debug('Setting onboarding complete to: $value');
      final success = await prefs.setBool(_onboardingCompleteKey, value);
      if (!success) {
        throw const StorageException('Failed to save onboarding status');
      }
      AppLogger.debug('Onboarding status saved successfully');
    } catch (e, stackTrace) {
      AppLogger.error('Error setting onboarding status: $e', e, stackTrace);
      throw StorageException(
        'Failed to save onboarding status',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Gets the first launch status
  /// Returns true if this is the first launch (default), false otherwise
  static bool get isFirstLaunch {
    try {
      return prefs.getBool(_firstLaunchKey) ?? true;
    } catch (e) {
      AppLogger.warning('Error reading first launch status: $e', e);
      return true;
    }
  }

  /// Sets the first launch status
  /// Throws StorageException if operation fails
  static Future<void> setFirstLaunch(bool value) async {
    try {
      AppLogger.debug('Setting first launch to: $value');
      final success = await prefs.setBool(_firstLaunchKey, value);
      if (!success) {
        throw const StorageException('Failed to save first launch status');
      }
      AppLogger.debug('First launch status saved successfully');
    } catch (e, stackTrace) {
      AppLogger.error('Error setting first launch status: $e', e, stackTrace);
      throw StorageException(
        'Failed to save first launch status',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Gets the stored app version
  /// Returns null if not set or if an error occurs
  static String? get appVersion {
    try {
      return prefs.getString(_appVersionKey);
    } catch (e) {
      AppLogger.warning('Error reading app version: $e', e);
      return null;
    }
  }

  /// Sets the app version
  /// Throws StorageException if operation fails
  static Future<void> setAppVersion(String value) async {
    try {
      AppLogger.debug('Setting app version: $value');
      final success = await prefs.setString(_appVersionKey, value);
      if (!success) {
        throw const StorageException('Failed to save app version');
      }
      AppLogger.debug('App version saved successfully');
    } catch (e, stackTrace) {
      AppLogger.error('Error setting app version: $e', e, stackTrace);
      throw StorageException(
        'Failed to save app version',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  // Theme management

  /// Gets the current theme mode
  /// Returns 'system' as default if not set or if an error occurs
  static String get themeMode {
    try {
      return prefs.getString(_themeKey) ?? 'system';
    } catch (e) {
      AppLogger.warning('Error reading theme mode: $e', e);
      return 'system';
    }
  }

  /// Sets the theme mode
  /// Accepts 'light', 'dark', or 'system'
  /// Throws StorageException if operation fails
  static Future<void> setThemeMode(String value) async {
    try {
      // Validate theme mode value
      if (!['light', 'dark', 'system'].contains(value)) {
        throw ArgumentError('Invalid theme mode: $value');
      }

      AppLogger.debug('Setting theme mode to: $value');
      final success = await prefs.setString(_themeKey, value);
      if (!success) {
        throw const StorageException('Failed to save theme mode');
      }
      AppLogger.debug('Theme mode saved successfully');
    } catch (e, stackTrace) {
      AppLogger.error('Error setting theme mode: $e', e, stackTrace);
      throw StorageException(
        'Failed to save theme mode',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  // Utility methods

  /// Clears all stored data (used for sign out)
  /// Throws StorageException if operation fails
  static Future<void> clearAll() async {
    try {
      AppLogger.debug('Clearing all SharedPreferences data...');
      final success = await prefs.clear();
      if (!success) {
        throw const StorageException('Failed to clear SharedPreferences');
      }
      AppLogger.debug('All SharedPreferences data cleared successfully');
    } catch (e, stackTrace) {
      AppLogger.error('Error clearing SharedPreferences: $e', e, stackTrace);
      throw StorageException(
        'Failed to clear stored data',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Removes a specific key from SharedPreferences
  /// Throws StorageException if operation fails
  static Future<void> remove(String key) async {
    try {
      AppLogger.debug('Removing key from SharedPreferences: $key');
      final success = await prefs.remove(key);
      if (!success) {
        throw StorageException('Failed to remove key: $key');
      }
      AppLogger.debug('Key removed successfully: $key');
    } catch (e, stackTrace) {
      AppLogger.error('Error removing key $key: $e', e, stackTrace);
      throw StorageException(
        'Failed to remove key: $key',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Checks if a key exists in SharedPreferences
  /// Returns false if an error occurs
  static bool containsKey(String key) {
    try {
      return prefs.containsKey(key);
    } catch (e) {
      AppLogger.warning('Error checking key existence $key: $e', e);
      return false;
    }
  }

  // Composite authentication methods

  /// Saves complete user authentication data
  /// Throws StorageException if any operation fails
  static Future<void> saveAuthData({
    required String userId,
    required String email,
    required String provider,
    String? displayName,
    String? photoUrl,
    String? sessionId,
  }) async {
    try {
      AppLogger.debug('Saving complete auth data for user: $userId');

      // Save all auth-related data
      await Future.wait([
        setLoggedIn(true),
        setUserId(userId),
        setUserEmail(email),
        setAuthProvider(provider),
        setLastSignIn(DateTime.now()),
        if (displayName != null) setUserDisplayName(displayName),
        if (photoUrl != null) setUserPhotoUrl(photoUrl),
        if (sessionId != null) setSessionId(sessionId),
      ]);

      AppLogger.debug('Complete auth data saved successfully');
    } catch (e, stackTrace) {
      AppLogger.error('Error saving auth data: $e', e, stackTrace);
      throw StorageException(
        'Failed to save authentication data',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Clears all authentication data (for sign out)
  /// Throws StorageException if operation fails
  static Future<void> clearAuthData() async {
    try {
      AppLogger.debug('Clearing authentication data...');

      // Clear all auth-related keys
      await Future.wait([
        remove(_isLoggedInKey),
        remove(_userIdKey),
        remove(_userEmailKey),
        remove(_userDisplayNameKey),
        remove(_userPhotoUrlKey),
        remove(_authProviderKey),
        remove(_lastSignInKey),
        remove(_sessionIdKey),
      ]);

      AppLogger.debug('Authentication data cleared successfully');
    } catch (e, stackTrace) {
      AppLogger.error('Error clearing auth data: $e', e, stackTrace);
      throw StorageException(
        'Failed to clear authentication data',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Gets all stored authentication data as a map
  /// Returns empty map if no auth data or if an error occurs
  static Map<String, dynamic> getAuthData() {
    try {
      return {
        'isLoggedIn': isLoggedIn,
        'userId': userId,
        'userEmail': userEmail,
        'userDisplayName': userDisplayName,
        'userPhotoUrl': userPhotoUrl,
        'authProvider': authProvider,
        'lastSignIn': lastSignIn?.toIso8601String(),
        'sessionId': sessionId,
      };
    } catch (e) {
      AppLogger.warning('Error reading auth data: $e', e);
      return {};
    }
  }

  /// Checks if the user session is valid (signed in within last 30 days)
  /// Returns false if not signed in or session expired
  static bool get isSessionValid {
    try {
      if (!isLoggedIn) return false;

      final lastSignInTime = lastSignIn;
      if (lastSignInTime == null) return false;

      final now = DateTime.now();
      final sessionDuration = now.difference(lastSignInTime);

      // Session expires after 30 days
      return sessionDuration.inDays < 30;
    } catch (e) {
      AppLogger.warning('Error checking session validity: $e', e);
      return false;
    }
  }

  /// Updates the last sign-in timestamp to extend session
  /// Throws StorageException if operation fails
  static Future<void> refreshSession() async {
    try {
      if (isLoggedIn) {
        await setLastSignIn(DateTime.now());
        AppLogger.debug('Session refreshed successfully');
      }
    } catch (e, stackTrace) {
      AppLogger.error('Error refreshing session: $e', e, stackTrace);
      throw StorageException(
        'Failed to refresh session',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Gets storage statistics
  /// Returns map with storage information
  static Map<String, dynamic> getStorageStats() {
    try {
      final keys = prefs.getKeys();
      final authKeys =
          keys
              .where(
                (key) =>
                    key.startsWith('user_') ||
                    key == _isLoggedInKey ||
                    key == _authProviderKey,
              )
              .length;
      final appKeys =
          keys
              .where(
                (key) =>
                    key == _themeKey ||
                    key == _onboardingCompleteKey ||
                    key == _firstLaunchKey,
              )
              .length;

      return {
        'totalKeys': keys.length,
        'authKeys': authKeys,
        'appKeys': appKeys,
        'isInitialized': _prefs != null,
        'hasAuthData': isLoggedIn,
        'sessionValid': isSessionValid,
      };
    } catch (e) {
      AppLogger.warning('Error getting storage stats: $e', e);
      return {'error': e.toString()};
    }
  }
}
