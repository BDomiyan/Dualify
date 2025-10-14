import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';

import '../../entities/entities.dart';
import '../../repositories/repositories.dart';
import '../usecase.dart';

/// Use case for signing in with mock Google authentication
/// Follows Clean Architecture and Single Responsibility Principle
class SignInWithMockGoogleUseCase implements UseCase<AuthUser, NoParams> {
  final IAuthRepository _authRepository;

  const SignInWithMockGoogleUseCase(this._authRepository);

  @override
  Future<Either<Failure, AuthUser>> call(NoParams params) async {
    try {
      // Check if user is already authenticated
      final currentUserResult = await _authRepository.getCurrentUser();

      return currentUserResult.fold(
        (failure) async {
          // If getting current user fails, proceed with sign in
          return await _performSignIn();
        },
        (currentUser) async {
          if (currentUser != null) {
            // User is already signed in, return current user
            return Right(currentUser);
          }

          // No current user, proceed with sign in
          return await _performSignIn();
        },
      );
    } catch (e) {
      return Left(
        AuthFailure(
          'Unexpected error during Google sign-in: ${e.toString()}',
          code: 'SIGN_IN_UNEXPECTED_ERROR',
        ),
      );
    }
  }

  /// Performs the actual sign-in operation
  Future<Either<Failure, AuthUser>> _performSignIn() async {
    try {
      // Record sign-in attempt
      await _authRepository.recordAuthEvent(
        AuthEventData.create(
          AuthEvent.signInAttempted,
          provider: AuthProvider.google,
        ),
      );

      // Perform mock Google sign-in
      final signInResult = await _authRepository.signInWithGoogle();

      return signInResult.fold(
        (failure) async {
          // Record failed sign-in
          await _authRepository.recordAuthEvent(
            AuthEventData.create(
              AuthEvent.signInFailed,
              provider: AuthProvider.google,
              metadata: {'error': failure.message},
            ),
          );

          return Left(failure);
        },
        (user) async {
          // Validate the signed-in user
          final validationErrors = user.validate();
          if (validationErrors.isNotEmpty) {
            return Left(
              ValidationFailure(
                'Invalid user data: ${validationErrors.join(', ')}',
                code: 'INVALID_USER_DATA',
              ),
            );
          }

          // Record successful sign-in
          await _authRepository.recordAuthEvent(
            AuthEventData.create(
              AuthEvent.signInSucceeded,
              provider: AuthProvider.google,
              metadata: {'userId': user.id, 'email': user.email},
            ),
          );

          return Right(user);
        },
      );
    } catch (e) {
      // Record failed sign-in
      await _authRepository.recordAuthEvent(
        AuthEventData.create(
          AuthEvent.signInFailed,
          provider: AuthProvider.google,
          metadata: {'error': e.toString()},
        ),
      );

      return Left(
        AuthFailure(
          'Failed to sign in with Google: ${e.toString()}',
          code: 'GOOGLE_SIGN_IN_FAILED',
        ),
      );
    }
  }
}
