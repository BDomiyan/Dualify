import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';
import '../../entities/entities.dart';
import '../../repositories/repositories.dart';
import '../usecase.dart';

/// Use case for checking the current authentication status
/// Follows Clean Architecture and Single Responsibility Principle
class CheckAuthStatusUseCase implements UseCase<AuthStatusResult, NoParams> {
  final IAuthRepository _authRepository;

  const CheckAuthStatusUseCase(this._authRepository);

  @override
  Future<Either<Failure, AuthStatusResult>> call(NoParams params) async {
    try {
      // Get current authentication status
      final statusResult = await _authRepository.getAuthStatus();

      return statusResult.fold((failure) => Left(failure), (status) async {
        // Get current user if authenticated
        if (status == AuthStatus.authenticated) {
          final userResult = await _authRepository.getCurrentUser();

          return userResult.fold((failure) => Left(failure), (user) async {
            if (user == null) {
              // Status says authenticated but no user found - inconsistent state
              return Right(
                AuthStatusResult(
                  status: AuthStatus.unauthenticated,
                  user: null,
                  isSessionValid: false,
                ),
              );
            }

            // Validate session if user is authenticated
            final sessionValidResult = await _authRepository.validateSession();

            return sessionValidResult.fold((failure) => Left(failure), (
              isSessionValid,
            ) {
              if (!isSessionValid) {
                // Session is invalid, user needs to re-authenticate
                return Right(
                  AuthStatusResult(
                    status: AuthStatus.unauthenticated,
                    user: null,
                    isSessionValid: false,
                  ),
                );
              }

              // Validate user data
              final validationErrors = user.validate();
              if (validationErrors.isNotEmpty) {
                return Left(
                  ValidationFailure(
                    'Invalid user data: ${validationErrors.join(', ')}',
                    code: 'INVALID_USER_DATA',
                  ),
                );
              }

              return Right(
                AuthStatusResult(
                  status: AuthStatus.authenticated,
                  user: user,
                  isSessionValid: true,
                ),
              );
            });
          });
        } else {
          // Not authenticated
          return Right(
            AuthStatusResult(status: status, user: null, isSessionValid: false),
          );
        }
      });
    } catch (e) {
      return Left(
        AuthFailure(
          'Unexpected error checking auth status: ${e.toString()}',
          code: 'AUTH_STATUS_CHECK_ERROR',
        ),
      );
    }
  }
}

/// Result class for authentication status check
class AuthStatusResult {
  final AuthStatus status;
  final AuthUser? user;
  final bool isSessionValid;

  const AuthStatusResult({
    required this.status,
    this.user,
    required this.isSessionValid,
  });

  /// Checks if the user is authenticated and session is valid
  bool get isAuthenticated =>
      status == AuthStatus.authenticated && user != null && isSessionValid;

  /// Checks if authentication is in progress
  bool get isLoading => status == AuthStatus.loading;

  /// Checks if there's an authentication error
  bool get hasError => status == AuthStatus.error;

  /// Checks if the user is not authenticated
  bool get isUnauthenticated =>
      status == AuthStatus.unauthenticated || user == null || !isSessionValid;
}
