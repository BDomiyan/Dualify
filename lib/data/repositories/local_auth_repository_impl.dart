import 'dart:async';

import 'package:dartz/dartz.dart';

import '../../core/errors/error_handler.dart';
import '../../core/errors/failures.dart';
import '../../core/storage/shared_preferences_service.dart';
import '../../core/utils/logger.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/repositories.dart';

/// Implementation of IAuthRepository using SharedPreferences for local storage
/// Provides mock authentication with persistent state management
class LocalAuthRepositoryImpl implements IAuthRepository {
  final StreamController<Either<Failure, AuthUser?>> _authStateController =
      StreamController<Either<Failure, AuthUser?>>.broadcast();

  AuthUser? _currentUser;

  LocalAuthRepositoryImpl() {
    _initializeAuthState();
  }

  /// Initializes authentication state from stored data
  Future<void> _initializeAuthState() async {
    try {
      AppLogger.debug('Initializing authentication state');

      if (SharedPreferencesService.isLoggedIn &&
          SharedPreferencesService.isSessionValid) {
        final authData = SharedPreferencesService.getAuthData();

        if (authData['userId'] != null && authData['userEmail'] != null) {
          _currentUser = AuthUserFactory.fromData(
            id: authData['userId'] as String,
            email: authData['userEmail'] as String,
            displayName: authData['userDisplayName'] as String?,
            photoUrl: authData['userPhotoUrl'] as String?,
            provider: AuthProvider.fromValue(
              authData['authProvider'] as String? ?? 'mock',
            ),
            isEmailVerified: true,
            createdAt: DateTime.now(),
            lastSignInAt:
                authData['lastSignIn'] != null
                    ? DateTime.parse(authData['lastSignIn'] as String)
                    : DateTime.now(),
          );

          AppLogger.info(
            'User authenticated from stored data: ${_currentUser!.email}',
          );
          _authStateController.add(Right(_currentUser));
          return;
        }
      }

      AppLogger.debug('No valid authentication state found');
      _currentUser = null;
      _authStateController.add(const Right(null));
    } catch (e) {
      AppLogger.error('Failed to initialize authentication state', e);
      _currentUser = null;
      _authStateController.add(
        Left(ErrorHandler.handleException(e as Exception)),
      );
    }
  }

  @override
  Future<Either<Failure, AuthStatus>> getAuthStatus() async {
    try {
      AppLogger.debug('Getting authentication status');

      if (_currentUser != null && SharedPreferencesService.isSessionValid) {
        return const Right(AuthStatus.authenticated);
      } else if (SharedPreferencesService.isLoggedIn &&
          !SharedPreferencesService.isSessionValid) {
        // Session expired
        await _clearAuthState();
        return const Right(AuthStatus.unauthenticated);
      } else {
        return const Right(AuthStatus.unauthenticated);
      }
    } catch (e) {
      AppLogger.error('Failed to get authentication status', e);
      return Left(ErrorHandler.handleException(e as Exception));
    }
  }

  @override
  Future<Either<Failure, AuthUser?>> getCurrentUser() async {
    try {
      AppLogger.debug('Getting current user');

      if (_currentUser != null && SharedPreferencesService.isSessionValid) {
        return Right(_currentUser);
      } else {
        return const Right(null);
      }
    } catch (e) {
      AppLogger.error('Failed to get current user', e);
      return Left(ErrorHandler.handleException(e as Exception));
    }
  }

  @override
  Future<Either<Failure, bool>> isAuthenticated() async {
    try {
      final statusResult = await getAuthStatus();
      return statusResult.fold(
        (failure) => Left(failure),
        (status) => Right(status == AuthStatus.authenticated),
      );
    } catch (e) {
      AppLogger.error('Failed to check authentication status', e);
      return Left(ErrorHandler.handleException(e as Exception));
    }
  }

  @override
  Stream<Either<Failure, AuthUser?>> get authStateChanges =>
      _authStateController.stream;

  // Sign In Operations

  @override
  Future<Either<Failure, AuthUser>> signInWithGoogle() async {
    try {
      AppLogger.info('Signing in with Google (mock)');

      await recordAuthEvent(
        AuthEventData.create(
          AuthEvent.signInAttempted,
          provider: AuthProvider.google,
        ),
      );

      // Mock Google sign-in
      final user = AuthUserFactory.create(
        id: 'google_user_${DateTime.now().millisecondsSinceEpoch}',
        email: 'user@gmail.com',
        displayName: 'Test User',
        photoUrl: 'https://via.placeholder.com/150',
        provider: AuthProvider.google,
        isEmailVerified: true,
      );

      // Save authentication data
      await SharedPreferencesService.saveAuthData(
        userId: user.id,
        email: user.email,
        provider: user.provider.value,
        displayName: user.displayName,
        photoUrl: user.photoUrl,
        sessionId: 'session_${DateTime.now().millisecondsSinceEpoch}',
      );

      _currentUser = user;
      _authStateController.add(Right(user));

      await recordAuthEvent(
        AuthEventData.create(
          AuthEvent.signInSucceeded,
          provider: AuthProvider.google,
          metadata: {'userId': user.id, 'email': user.email},
        ),
      );

      AppLogger.info('Google sign-in successful: ${user.email}');
      return Right(user);
    } catch (e) {
      AppLogger.error('Google sign-in failed', e);

      await recordAuthEvent(
        AuthEventData.create(
          AuthEvent.signInFailed,
          provider: AuthProvider.google,
          metadata: {'error': e.toString()},
        ),
      );

      return Left(ErrorHandler.handleException(e as Exception));
    }
  }

  @override
  Future<Either<Failure, AuthUser>> signInWithApple() async {
    try {
      AppLogger.info('Signing in with Apple (mock)');

      await recordAuthEvent(
        AuthEventData.create(
          AuthEvent.signInAttempted,
          provider: AuthProvider.apple,
        ),
      );

      // Mock Apple sign-in
      final user = AuthUserFactory.create(
        id: 'apple_user_${DateTime.now().millisecondsSinceEpoch}',
        email: 'user@icloud.com',
        displayName: 'Apple User',
        provider: AuthProvider.apple,
        isEmailVerified: true,
      );

      // Save authentication data
      await SharedPreferencesService.saveAuthData(
        userId: user.id,
        email: user.email,
        provider: user.provider.value,
        displayName: user.displayName,
        sessionId: 'session_${DateTime.now().millisecondsSinceEpoch}',
      );

      _currentUser = user;
      _authStateController.add(Right(user));

      await recordAuthEvent(
        AuthEventData.create(
          AuthEvent.signInSucceeded,
          provider: AuthProvider.apple,
          metadata: {'userId': user.id, 'email': user.email},
        ),
      );

      AppLogger.info('Apple sign-in successful: ${user.email}');
      return Right(user);
    } catch (e) {
      AppLogger.error('Apple sign-in failed', e);

      await recordAuthEvent(
        AuthEventData.create(
          AuthEvent.signInFailed,
          provider: AuthProvider.apple,
          metadata: {'error': e.toString()},
        ),
      );

      return Left(ErrorHandler.handleException(e as Exception));
    }
  }

  @override
  Future<Either<Failure, AuthUser>> signInWithEmail(
    String email,
    String password,
  ) async {
    try {
      AppLogger.info('Signing in with email (mock): $email');

      await recordAuthEvent(
        AuthEventData.create(
          AuthEvent.signInAttempted,
          provider: AuthProvider.email,
        ),
      );

      // Mock email validation
      if (!email.contains('@') || password.length < 6) {
        await recordAuthEvent(
          AuthEventData.create(
            AuthEvent.signInFailed,
            provider: AuthProvider.email,
            metadata: {'error': 'Invalid credentials'},
          ),
        );

        return const Left(
          AuthFailure('Invalid email or password', code: 'INVALID_CREDENTIALS'),
        );
      }

      // Mock email sign-in
      final user = AuthUserFactory.create(
        id: 'email_user_${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        displayName: email.split('@').first,
        provider: AuthProvider.email,
        isEmailVerified: false,
      );

      // Save authentication data
      await SharedPreferencesService.saveAuthData(
        userId: user.id,
        email: user.email,
        provider: user.provider.value,
        displayName: user.displayName,
        sessionId: 'session_${DateTime.now().millisecondsSinceEpoch}',
      );

      _currentUser = user;
      _authStateController.add(Right(user));

      await recordAuthEvent(
        AuthEventData.create(
          AuthEvent.signInSucceeded,
          provider: AuthProvider.email,
          metadata: {'userId': user.id, 'email': user.email},
        ),
      );

      AppLogger.info('Email sign-in successful: ${user.email}');
      return Right(user);
    } catch (e) {
      AppLogger.error('Email sign-in failed', e);

      await recordAuthEvent(
        AuthEventData.create(
          AuthEvent.signInFailed,
          provider: AuthProvider.email,
          metadata: {'error': e.toString()},
        ),
      );

      return Left(ErrorHandler.handleException(e as Exception));
    }
  }

  @override
  Future<Either<Failure, AuthUser>> signInAnonymously() async {
    try {
      AppLogger.info('Signing in anonymously (mock)');

      await recordAuthEvent(
        AuthEventData.create(
          AuthEvent.signInAttempted,
          provider: AuthProvider.anonymous,
        ),
      );

      // Mock anonymous sign-in
      final user = AuthUserFactory.create(
        id: 'anon_user_${DateTime.now().millisecondsSinceEpoch}',
        email: 'anonymous@dualify.app',
        displayName: 'Anonymous User',
        provider: AuthProvider.anonymous,
        isEmailVerified: false,
      );

      // Save authentication data
      await SharedPreferencesService.saveAuthData(
        userId: user.id,
        email: user.email,
        provider: user.provider.value,
        displayName: user.displayName,
        sessionId: 'session_${DateTime.now().millisecondsSinceEpoch}',
      );

      _currentUser = user;
      _authStateController.add(Right(user));

      await recordAuthEvent(
        AuthEventData.create(
          AuthEvent.signInSucceeded,
          provider: AuthProvider.anonymous,
          metadata: {'userId': user.id},
        ),
      );

      AppLogger.info('Anonymous sign-in successful: ${user.id}');
      return Right(user);
    } catch (e) {
      AppLogger.error('Anonymous sign-in failed', e);

      await recordAuthEvent(
        AuthEventData.create(
          AuthEvent.signInFailed,
          provider: AuthProvider.anonymous,
          metadata: {'error': e.toString()},
        ),
      );

      return Left(ErrorHandler.handleException(e as Exception));
    }
  }

  @override
  Future<Either<Failure, AuthUser>> signInWithMock({
    String? email,
    String? displayName,
  }) async {
    try {
      final mockEmail = email ?? 'test@dualify.app';
      final mockDisplayName = displayName ?? 'Test User';

      AppLogger.info('Signing in with mock credentials: $mockEmail');

      await recordAuthEvent(
        AuthEventData.create(
          AuthEvent.signInAttempted,
          provider: AuthProvider.mock,
        ),
      );

      // Create mock user
      final user = AuthUserFactory.create(
        id: 'mock_user_${DateTime.now().millisecondsSinceEpoch}',
        email: mockEmail,
        displayName: mockDisplayName,
        provider: AuthProvider.mock,
        isEmailVerified: true,
        metadata: {'isMockUser': true},
      );

      // Save authentication data
      await SharedPreferencesService.saveAuthData(
        userId: user.id,
        email: user.email,
        provider: user.provider.value,
        displayName: user.displayName,
        sessionId: 'session_${DateTime.now().millisecondsSinceEpoch}',
      );

      _currentUser = user;
      _authStateController.add(Right(user));

      await recordAuthEvent(
        AuthEventData.create(
          AuthEvent.signInSucceeded,
          provider: AuthProvider.mock,
          metadata: {'userId': user.id, 'email': user.email},
        ),
      );

      AppLogger.info('Mock sign-in successful: ${user.email}');
      return Right(user);
    } catch (e) {
      AppLogger.error('Mock sign-in failed', e);

      await recordAuthEvent(
        AuthEventData.create(
          AuthEvent.signInFailed,
          provider: AuthProvider.mock,
          metadata: {'error': e.toString()},
        ),
      );

      return Left(ErrorHandler.handleException(e as Exception));
    }
  }

  // Sign Out Operations

  @override
  Future<Either<Failure, Unit>> signOut() async {
    try {
      AppLogger.info('Signing out user: ${_currentUser?.email ?? 'unknown'}');

      await recordAuthEvent(
        AuthEventData.create(
          AuthEvent.signOutAttempted,
          provider: _currentUser?.provider,
        ),
      );

      await _clearAuthState();

      await recordAuthEvent(
        AuthEventData.create(
          AuthEvent.signOutSucceeded,
          provider: _currentUser?.provider,
        ),
      );

      AppLogger.info('Sign-out successful');
      return const Right(unit);
    } catch (e) {
      AppLogger.error('Sign-out failed', e);

      await recordAuthEvent(
        AuthEventData.create(
          AuthEvent.signOutFailed,
          metadata: {'error': e.toString()},
        ),
      );

      return Left(ErrorHandler.handleException(e as Exception));
    }
  }

  @override
  Future<Either<Failure, Unit>> signOutFromAllDevices() async {
    // For local implementation, this is the same as regular sign out
    return signOut();
  }

  /// Clears authentication state
  Future<void> _clearAuthState() async {
    await SharedPreferencesService.clearAuthData();
    _currentUser = null;
    _authStateController.add(const Right(null));
  }

  // User Management (Mock implementations)

  @override
  Future<Either<Failure, AuthUser>> updateUserProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    try {
      if (_currentUser == null) {
        return const Left(AuthFailure('No user signed in', code: 'NO_USER'));
      }

      AppLogger.info('Updating user profile: ${_currentUser!.email}');

      final updatedUser = _currentUser!.copyWith(
        displayName: displayName,
        photoUrl: photoUrl,
      );

      // Update stored data
      if (displayName != null) {
        await SharedPreferencesService.setUserDisplayName(displayName);
      }
      if (photoUrl != null) {
        await SharedPreferencesService.setUserPhotoUrl(photoUrl);
      }

      _currentUser = updatedUser;
      _authStateController.add(Right(updatedUser));

      await recordAuthEvent(
        AuthEventData.create(
          AuthEvent.profileUpdated,
          provider: updatedUser.provider,
        ),
      );

      AppLogger.info('User profile updated successfully');
      return Right(updatedUser);
    } catch (e) {
      AppLogger.error('Failed to update user profile', e);
      return Left(ErrorHandler.handleException(e as Exception));
    }
  }

  @override
  Future<Either<Failure, AuthUser>> updateUserEmail(String newEmail) async {
    try {
      if (_currentUser == null) {
        return const Left(AuthFailure('No user signed in', code: 'NO_USER'));
      }

      AppLogger.info(
        'Updating user email: ${_currentUser!.email} -> $newEmail',
      );

      final updatedUser = _currentUser!.copyWith(email: newEmail);

      // Update stored data
      await SharedPreferencesService.setUserEmail(newEmail);

      _currentUser = updatedUser;
      _authStateController.add(Right(updatedUser));

      AppLogger.info('User email updated successfully');
      return Right(updatedUser);
    } catch (e) {
      AppLogger.error('Failed to update user email', e);
      return Left(ErrorHandler.handleException(e as Exception));
    }
  }

  @override
  Future<Either<Failure, Unit>> sendEmailVerification() async {
    try {
      if (_currentUser == null) {
        return const Left(AuthFailure('No user signed in', code: 'NO_USER'));
      }

      AppLogger.info(
        'Sending email verification (mock): ${_currentUser!.email}',
      );

      await recordAuthEvent(
        AuthEventData.create(
          AuthEvent.emailVerificationSent,
          provider: _currentUser!.provider,
        ),
      );

      // Mock email verification - just mark as verified
      final updatedUser = _currentUser!.copyWith(isEmailVerified: true);
      _currentUser = updatedUser;
      _authStateController.add(Right(updatedUser));

      AppLogger.info('Email verification sent (mock)');
      return const Right(unit);
    } catch (e) {
      AppLogger.error('Failed to send email verification', e);
      return Left(ErrorHandler.handleException(e as Exception));
    }
  }

  @override
  Future<Either<Failure, AuthUser>> reloadUser() async {
    try {
      if (_currentUser == null) {
        return const Left(AuthFailure('No user signed in', code: 'NO_USER'));
      }

      AppLogger.debug('Reloading user data: ${_currentUser!.email}');

      // In a real implementation, this would fetch fresh user data
      // For mock, we'll just return the current user
      return Right(_currentUser!);
    } catch (e) {
      AppLogger.error('Failed to reload user', e);
      return Left(ErrorHandler.handleException(e as Exception));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteUser() async {
    try {
      if (_currentUser == null) {
        return const Left(AuthFailure('No user signed in', code: 'NO_USER'));
      }

      AppLogger.info('Deleting user account: ${_currentUser!.email}');

      await recordAuthEvent(
        AuthEventData.create(
          AuthEvent.accountDeleted,
          provider: _currentUser!.provider,
        ),
      );

      await _clearAuthState();

      AppLogger.info('User account deleted successfully');
      return const Right(unit);
    } catch (e) {
      AppLogger.error('Failed to delete user account', e);
      return Left(ErrorHandler.handleException(e as Exception));
    }
  }

  // Session Management

  @override
  Future<Either<Failure, UserSession?>> getCurrentSession() async {
    try {
      if (_currentUser == null || !SharedPreferencesService.isSessionValid) {
        return const Right(null);
      }

      final sessionId = SharedPreferencesService.sessionId ?? 'unknown';
      final lastSignIn = SharedPreferencesService.lastSignIn ?? DateTime.now();

      final session = UserSession(
        user: _currentUser!,
        sessionId: sessionId,
        sessionStart: lastSignIn,
        isActive: true,
      );

      return Right(session);
    } catch (e) {
      AppLogger.error('Failed to get current session', e);
      return Left(ErrorHandler.handleException(e as Exception));
    }
  }

  @override
  Future<Either<Failure, Unit>> refreshToken() async {
    try {
      if (_currentUser == null) {
        return const Left(AuthFailure('No user signed in', code: 'NO_USER'));
      }

      AppLogger.debug('Refreshing token (mock)');

      await SharedPreferencesService.refreshSession();

      await recordAuthEvent(
        AuthEventData.create(
          AuthEvent.tokenRefreshed,
          provider: _currentUser!.provider,
        ),
      );

      AppLogger.debug('Token refreshed successfully');
      return const Right(unit);
    } catch (e) {
      AppLogger.error('Failed to refresh token', e);
      return Left(ErrorHandler.handleException(e as Exception));
    }
  }

  @override
  Future<Either<Failure, bool>> validateSession() async {
    try {
      final isValid =
          _currentUser != null && SharedPreferencesService.isSessionValid;

      if (!isValid && _currentUser != null) {
        await recordAuthEvent(
          AuthEventData.create(
            AuthEvent.sessionExpired,
            provider: _currentUser!.provider,
          ),
        );

        await _clearAuthState();
      }

      return Right(isValid);
    } catch (e) {
      AppLogger.error('Failed to validate session', e);
      return Left(ErrorHandler.handleException(e as Exception));
    }
  }

  @override
  Future<Either<Failure, Unit>> endSession() async {
    return signOut();
  }

  // Password Management (Mock implementations)

  @override
  Future<Either<Failure, Unit>> sendPasswordResetEmail(String email) async {
    try {
      AppLogger.info('Sending password reset email (mock): $email');

      await recordAuthEvent(
        AuthEventData.create(
          AuthEvent.passwordResetRequested,
          provider: AuthProvider.email,
        ),
      );

      // Mock implementation - always succeeds
      AppLogger.info('Password reset email sent (mock)');
      return const Right(unit);
    } catch (e) {
      AppLogger.error('Failed to send password reset email', e);
      return Left(ErrorHandler.handleException(e as Exception));
    }
  }

  @override
  Future<Either<Failure, Unit>> confirmPasswordReset(
    String code,
    String newPassword,
  ) async {
    try {
      AppLogger.info('Confirming password reset (mock)');

      // Mock validation
      if (code.length < 6 || newPassword.length < 6) {
        return const Left(
          AuthFailure('Invalid code or password', code: 'INVALID_INPUT'),
        );
      }

      AppLogger.info('Password reset confirmed (mock)');
      return const Right(unit);
    } catch (e) {
      AppLogger.error('Failed to confirm password reset', e);
      return Left(ErrorHandler.handleException(e as Exception));
    }
  }

  @override
  Future<Either<Failure, Unit>> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      if (_currentUser == null) {
        return const Left(AuthFailure('No user signed in', code: 'NO_USER'));
      }

      AppLogger.info('Changing password (mock)');

      // Mock validation
      if (currentPassword.length < 6 || newPassword.length < 6) {
        return const Left(
          AuthFailure('Invalid password', code: 'INVALID_PASSWORD'),
        );
      }

      AppLogger.info('Password changed successfully (mock)');
      return const Right(unit);
    } catch (e) {
      AppLogger.error('Failed to change password', e);
      return Left(ErrorHandler.handleException(e as Exception));
    }
  }

  // Account Linking (Mock implementations)

  @override
  Future<Either<Failure, AuthUser>> linkProvider(AuthProvider provider) async {
    try {
      if (_currentUser == null) {
        return const Left(AuthFailure('No user signed in', code: 'NO_USER'));
      }

      AppLogger.info('Linking provider (mock): ${provider.displayName}');

      // Mock implementation - just return current user
      return Right(_currentUser!);
    } catch (e) {
      AppLogger.error('Failed to link provider', e);
      return Left(ErrorHandler.handleException(e as Exception));
    }
  }

  @override
  Future<Either<Failure, AuthUser>> unlinkProvider(
    AuthProvider provider,
  ) async {
    try {
      if (_currentUser == null) {
        return const Left(AuthFailure('No user signed in', code: 'NO_USER'));
      }

      AppLogger.info('Unlinking provider (mock): ${provider.displayName}');

      // Mock implementation - just return current user
      return Right(_currentUser!);
    } catch (e) {
      AppLogger.error('Failed to unlink provider', e);
      return Left(ErrorHandler.handleException(e as Exception));
    }
  }

  @override
  Future<Either<Failure, List<AuthProvider>>> getLinkedProviders() async {
    try {
      if (_currentUser == null) {
        return const Left(AuthFailure('No user signed in', code: 'NO_USER'));
      }

      // Mock implementation - return current provider
      return Right([_currentUser!.provider]);
    } catch (e) {
      AppLogger.error('Failed to get linked providers', e);
      return Left(ErrorHandler.handleException(e as Exception));
    }
  }

  // User Metadata

  @override
  Future<Either<Failure, AuthUser>> updateUserMetadata(
    Map<String, dynamic> metadata,
  ) async {
    try {
      if (_currentUser == null) {
        return const Left(AuthFailure('No user signed in', code: 'NO_USER'));
      }

      AppLogger.debug('Updating user metadata');

      final updatedUser = _currentUser!.copyWith(
        metadata: {..._currentUser!.metadata, ...metadata},
      );

      _currentUser = updatedUser;
      _authStateController.add(Right(updatedUser));

      return Right(updatedUser);
    } catch (e) {
      AppLogger.error('Failed to update user metadata', e);
      return Left(ErrorHandler.handleException(e as Exception));
    }
  }

  @override
  Future<Either<Failure, T?>> getUserMetadata<T>(String key) async {
    try {
      if (_currentUser == null) {
        return const Left(AuthFailure('No user signed in', code: 'NO_USER'));
      }

      final value = _currentUser!.getMetadata<T>(key);
      return Right(value);
    } catch (e) {
      AppLogger.error('Failed to get user metadata', e);
      return Left(ErrorHandler.handleException(e as Exception));
    }
  }

  @override
  Future<Either<Failure, AuthUser>> removeUserMetadata(String key) async {
    try {
      if (_currentUser == null) {
        return const Left(AuthFailure('No user signed in', code: 'NO_USER'));
      }

      final updatedUser = _currentUser!.withoutMetadata(key);
      _currentUser = updatedUser;
      _authStateController.add(Right(updatedUser));

      return Right(updatedUser);
    } catch (e) {
      AppLogger.error('Failed to remove user metadata', e);
      return Left(ErrorHandler.handleException(e as Exception));
    }
  }

  // Authentication Analytics

  @override
  Future<Either<Failure, AuthStatistics>> getAuthStatistics() async {
    try {
      AppLogger.debug('Getting authentication statistics (mock)');

      // Mock statistics
      final statistics = AuthStatistics(
        totalSignIns: 1,
        totalSignOuts: 0,
        signInsByProvider: {AuthProvider.mock: 1},
        lastSignIn: SharedPreferencesService.lastSignIn,
        totalSessionTime: const Duration(hours: 1),
        failedSignInAttempts: 0,
      );

      return Right(statistics);
    } catch (e) {
      AppLogger.error('Failed to get authentication statistics', e);
      return Left(ErrorHandler.handleException(e as Exception));
    }
  }

  @override
  Future<Either<Failure, Unit>> recordAuthEvent(AuthEventData event) async {
    try {
      AppLogger.debug('Recording auth event: ${event.event.value}');

      // In a real implementation, this would store events in a database
      // For mock, we just log it
      AppLogger.info(
        'Auth event recorded: ${event.event.value} at ${event.timestamp}',
      );

      return const Right(unit);
    } catch (e) {
      AppLogger.error('Failed to record auth event', e);
      return Left(ErrorHandler.handleException(e as Exception));
    }
  }

  // Cleanup and Maintenance

  @override
  Future<Either<Failure, Unit>> clearAuthData() async {
    try {
      AppLogger.info('Clearing all authentication data');

      await _clearAuthState();

      AppLogger.info('Authentication data cleared successfully');
      return const Right(unit);
    } catch (e) {
      AppLogger.error('Failed to clear authentication data', e);
      return Left(ErrorHandler.handleException(e as Exception));
    }
  }

  @override
  Future<Either<Failure, Unit>> performCleanup() async {
    try {
      AppLogger.debug('Performing authentication cleanup');

      // Check for expired sessions
      if (_currentUser != null && !SharedPreferencesService.isSessionValid) {
        await _clearAuthState();
        AppLogger.info('Expired session cleaned up');
      }

      return const Right(unit);
    } catch (e) {
      AppLogger.error('Failed to perform authentication cleanup', e);
      return Left(ErrorHandler.handleException(e as Exception));
    }
  }

  /// Disposes resources
  void dispose() {
    _authStateController.close();
  }
}
