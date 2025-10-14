import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../entities/entities.dart';

/// Repository interface for authentication operations
/// Follows Repository Pattern and Dependency Inversion Principle
/// Uses Either type for functional error handling
abstract class IAuthRepository {
  // Authentication State

  /// Gets the current authentication status
  /// Returns the current auth status or a failure
  Future<Either<Failure, AuthStatus>> getAuthStatus();

  /// Gets the currently authenticated user
  /// Returns the user if authenticated, null if not, or a failure
  Future<Either<Failure, AuthUser?>> getCurrentUser();

  /// Checks if a user is currently authenticated
  /// Returns true if authenticated, false otherwise, or a failure
  Future<Either<Failure, bool>> isAuthenticated();

  /// Gets a stream of authentication state changes
  /// Returns a stream of auth users (null when not authenticated) or a failure
  Stream<Either<Failure, AuthUser?>> get authStateChanges;

  // Sign In Operations

  /// Signs in with Google (mock implementation)
  /// Returns the authenticated user or a failure
  Future<Either<Failure, AuthUser>> signInWithGoogle();

  /// Signs in with Apple (mock implementation)
  /// Returns the authenticated user or a failure
  Future<Either<Failure, AuthUser>> signInWithApple();

  /// Signs in with email and password (mock implementation)
  /// Returns the authenticated user or a failure
  Future<Either<Failure, AuthUser>> signInWithEmail(
    String email,
    String password,
  );

  /// Signs in anonymously (mock implementation)
  /// Returns the anonymous user or a failure
  Future<Either<Failure, AuthUser>> signInAnonymously();

  /// Signs in with mock credentials for testing/development
  /// Returns the mock user or a failure
  Future<Either<Failure, AuthUser>> signInWithMock({
    String? email,
    String? displayName,
  });

  // Sign Out Operations

  /// Signs out the current user
  /// Returns success (unit) or a failure
  Future<Either<Failure, Unit>> signOut();

  /// Signs out from all devices (if supported by provider)
  /// Returns success (unit) or a failure
  Future<Either<Failure, Unit>> signOutFromAllDevices();

  // User Management

  /// Updates the current user's profile
  /// Returns the updated user or a failure
  Future<Either<Failure, AuthUser>> updateUserProfile({
    String? displayName,
    String? photoUrl,
  });

  /// Updates the current user's email
  /// Returns the updated user or a failure
  Future<Either<Failure, AuthUser>> updateUserEmail(String newEmail);

  /// Sends email verification to the current user
  /// Returns success (unit) or a failure
  Future<Either<Failure, Unit>> sendEmailVerification();

  /// Reloads the current user's data
  /// Returns the refreshed user or a failure
  Future<Either<Failure, AuthUser>> reloadUser();

  /// Deletes the current user account
  /// Returns success (unit) or a failure
  Future<Either<Failure, Unit>> deleteUser();

  // Session Management

  /// Gets the current user session
  /// Returns the session if active, null if not, or a failure
  Future<Either<Failure, UserSession?>> getCurrentSession();

  /// Refreshes the authentication token
  /// Returns success (unit) or a failure
  Future<Either<Failure, Unit>> refreshToken();

  /// Validates the current session
  /// Returns true if valid, false otherwise, or a failure
  Future<Either<Failure, bool>> validateSession();

  /// Ends the current session
  /// Returns success (unit) or a failure
  Future<Either<Failure, Unit>> endSession();

  // Password Management (for email auth)

  /// Sends password reset email
  /// Returns success (unit) or a failure
  Future<Either<Failure, Unit>> sendPasswordResetEmail(String email);

  /// Confirms password reset with code
  /// Returns success (unit) or a failure
  Future<Either<Failure, Unit>> confirmPasswordReset(
    String code,
    String newPassword,
  );

  /// Changes the current user's password
  /// Returns success (unit) or a failure
  Future<Either<Failure, Unit>> changePassword(
    String currentPassword,
    String newPassword,
  );

  // Account Linking (for future use)

  /// Links an additional auth provider to the current account
  /// Returns the updated user or a failure
  Future<Either<Failure, AuthUser>> linkProvider(AuthProvider provider);

  /// Unlinks an auth provider from the current account
  /// Returns the updated user or a failure
  Future<Either<Failure, AuthUser>> unlinkProvider(AuthProvider provider);

  /// Gets all linked providers for the current user
  /// Returns list of linked providers or a failure
  Future<Either<Failure, List<AuthProvider>>> getLinkedProviders();

  // User Metadata

  /// Updates user metadata
  /// Returns the updated user or a failure
  Future<Either<Failure, AuthUser>> updateUserMetadata(
    Map<String, dynamic> metadata,
  );

  /// Gets user metadata by key
  /// Returns the metadata value or a failure
  Future<Either<Failure, T?>> getUserMetadata<T>(String key);

  /// Removes user metadata by key
  /// Returns the updated user or a failure
  Future<Either<Failure, AuthUser>> removeUserMetadata(String key);

  // Authentication Analytics

  /// Gets authentication statistics
  /// Returns auth statistics or a failure
  Future<Either<Failure, AuthStatistics>> getAuthStatistics();

  /// Records authentication event for analytics
  /// Returns success (unit) or a failure
  Future<Either<Failure, Unit>> recordAuthEvent(AuthEventData event);

  // Cleanup and Maintenance

  /// Clears all authentication data (for testing or reset)
  /// Returns success (unit) or a failure
  Future<Either<Failure, Unit>> clearAuthData();

  /// Performs authentication system cleanup
  /// Returns success (unit) or a failure
  Future<Either<Failure, Unit>> performCleanup();
}

/// Authentication statistics
class AuthStatistics {
  final int totalSignIns;
  final int totalSignOuts;
  final Map<AuthProvider, int> signInsByProvider;
  final DateTime? lastSignIn;
  final DateTime? lastSignOut;
  final Duration totalSessionTime;
  final int failedSignInAttempts;

  const AuthStatistics({
    required this.totalSignIns,
    required this.totalSignOuts,
    required this.signInsByProvider,
    this.lastSignIn,
    this.lastSignOut,
    required this.totalSessionTime,
    required this.failedSignInAttempts,
  });

  /// Gets the most used authentication provider
  AuthProvider? get mostUsedProvider {
    if (signInsByProvider.isEmpty) return null;

    var maxCount = 0;
    AuthProvider? mostUsed;

    for (final entry in signInsByProvider.entries) {
      if (entry.value > maxCount) {
        maxCount = entry.value;
        mostUsed = entry.key;
      }
    }

    return mostUsed;
  }

  /// Gets the average session duration
  Duration get averageSessionDuration {
    if (totalSignIns == 0) return Duration.zero;
    return Duration(
      milliseconds: totalSessionTime.inMilliseconds ~/ totalSignIns,
    );
  }

  /// Gets the success rate for sign-in attempts
  double get signInSuccessRate {
    final totalAttempts = totalSignIns + failedSignInAttempts;
    if (totalAttempts == 0) return 0.0;
    return totalSignIns / totalAttempts;
  }
}

/// Authentication events for analytics
enum AuthEvent {
  signInAttempted('sign_in_attempted'),
  signInSucceeded('sign_in_succeeded'),
  signInFailed('sign_in_failed'),
  signOutAttempted('sign_out_attempted'),
  signOutSucceeded('sign_out_succeeded'),
  signOutFailed('sign_out_failed'),
  tokenRefreshed('token_refreshed'),
  sessionExpired('session_expired'),
  passwordResetRequested('password_reset_requested'),
  emailVerificationSent('email_verification_sent'),
  profileUpdated('profile_updated'),
  accountDeleted('account_deleted');

  const AuthEvent(this.value);
  final String value;

  /// Gets event from string value
  static AuthEvent fromValue(String value) {
    return AuthEvent.values.firstWhere(
      (event) => event.value == value,
      orElse: () => AuthEvent.signInAttempted,
    );
  }
}

/// Authentication event data
class AuthEventData {
  final AuthEvent event;
  final DateTime timestamp;
  final AuthProvider? provider;
  final Map<String, dynamic> metadata;

  const AuthEventData({
    required this.event,
    required this.timestamp,
    this.provider,
    this.metadata = const {},
  });

  /// Creates an event data instance
  factory AuthEventData.create(
    AuthEvent event, {
    AuthProvider? provider,
    Map<String, dynamic> metadata = const {},
  }) {
    return AuthEventData(
      event: event,
      timestamp: DateTime.now(),
      provider: provider,
      metadata: metadata,
    );
  }
}
