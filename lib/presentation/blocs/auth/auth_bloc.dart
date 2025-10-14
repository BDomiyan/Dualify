import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../core/errors/failures.dart';
import '../../../core/utils/logger.dart';
import '../../../domain/entities/entities.dart';
import '../../../domain/usecases/usecases.dart';

// Events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

class AuthSignInWithGoogleRequested extends AuthEvent {
  const AuthSignInWithGoogleRequested();
}

class AuthSignInWithAppleRequested extends AuthEvent {
  const AuthSignInWithAppleRequested();
}

class AuthSignInWithEmailRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthSignInWithEmailRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

class AuthSignInAnonymouslyRequested extends AuthEvent {
  const AuthSignInAnonymouslyRequested();
}

class AuthSignInWithMockRequested extends AuthEvent {
  final String? email;
  final String? displayName;

  const AuthSignInWithMockRequested({this.email, this.displayName});

  @override
  List<Object?> get props => [email, displayName];
}

class AuthSignOutRequested extends AuthEvent {
  const AuthSignOutRequested();
}

class AuthUserUpdated extends AuthEvent {
  final AuthUser? user;

  const AuthUserUpdated(this.user);

  @override
  List<Object?> get props => [user];
}

// States
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  final AuthUser user;
  final bool isSessionValid;

  const AuthAuthenticated({required this.user, this.isSessionValid = true});

  @override
  List<Object?> get props => [user, isSessionValid];
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthError extends AuthState {
  final String message;
  final String? code;
  final bool isRecoverable;

  const AuthError({
    required this.message,
    this.code,
    this.isRecoverable = true,
  });

  @override
  List<Object?> get props => [message, code, isRecoverable];
}

// BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final CheckAuthStatusUseCase _checkAuthStatusUseCase;
  final SignInWithMockGoogleUseCase _signInWithGoogleUseCase;

  StreamSubscription<AuthStatusResult>? _authStatusSubscription;

  AuthBloc({
    required CheckAuthStatusUseCase checkAuthStatusUseCase,
    required SignInWithMockGoogleUseCase signInWithGoogleUseCase,
  }) : _checkAuthStatusUseCase = checkAuthStatusUseCase,
       _signInWithGoogleUseCase = signInWithGoogleUseCase,
       super(const AuthInitial()) {
    // Register event handlers
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthSignInWithGoogleRequested>(_onSignInWithGoogleRequested);
    on<AuthSignInWithAppleRequested>(_onSignInWithAppleRequested);
    on<AuthSignInWithEmailRequested>(_onSignInWithEmailRequested);
    on<AuthSignInAnonymouslyRequested>(_onSignInAnonymouslyRequested);
    on<AuthSignInWithMockRequested>(_onSignInWithMockRequested);
    on<AuthSignOutRequested>(_onSignOutRequested);
    on<AuthUserUpdated>(_onUserUpdated);

    // Check initial auth status
    add(const AuthCheckRequested());
  }

  /// Handles auth status check
  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      AppLogger.debug('Checking authentication status');
      emit(const AuthLoading());

      final result = await _checkAuthStatusUseCase(const NoParams());

      result.fold(
        (failure) {
          AppLogger.error('Auth status check failed: ${failure.message}');
          emit(
            AuthError(
              message: failure.message,
              code: failure.code,
              isRecoverable: _isRecoverableFailure(failure),
            ),
          );
        },
        (authStatusResult) {
          if (authStatusResult.isAuthenticated) {
            AppLogger.info(
              'User is authenticated: ${authStatusResult.user!.email}',
            );
            emit(
              AuthAuthenticated(
                user: authStatusResult.user!,
                isSessionValid: authStatusResult.isSessionValid,
              ),
            );
          } else {
            AppLogger.debug('User is not authenticated');
            emit(const AuthUnauthenticated());
          }
        },
      );
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error during auth check', e, stackTrace);
      emit(
        const AuthError(
          message: 'An unexpected error occurred during authentication check',
          isRecoverable: true,
        ),
      );
    }
  }

  /// Handles Google sign-in
  Future<void> _onSignInWithGoogleRequested(
    AuthSignInWithGoogleRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      AppLogger.info('Attempting Google sign-in');
      emit(const AuthLoading());

      final result = await _signInWithGoogleUseCase(const NoParams());

      result.fold(
        (failure) {
          AppLogger.error('Google sign-in failed: ${failure.message}');
          emit(
            AuthError(
              message: failure.message,
              code: failure.code,
              isRecoverable: _isRecoverableFailure(failure),
            ),
          );
        },
        (user) {
          AppLogger.info('Google sign-in successful: ${user.email}');
          emit(AuthAuthenticated(user: user));
        },
      );
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error during Google sign-in', e, stackTrace);
      emit(
        const AuthError(
          message: 'An unexpected error occurred during Google sign-in',
          isRecoverable: true,
        ),
      );
    }
  }

  /// Handles Apple sign-in (mock)
  Future<void> _onSignInWithAppleRequested(
    AuthSignInWithAppleRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      AppLogger.info('Attempting Apple sign-in (mock)');
      emit(const AuthLoading());

      // For now, use mock sign-in with Apple-like credentials
      add(
        const AuthSignInWithMockRequested(
          email: 'user@icloud.com',
          displayName: 'Apple User',
        ),
      );
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error during Apple sign-in', e, stackTrace);
      emit(
        const AuthError(
          message: 'An unexpected error occurred during Apple sign-in',
          isRecoverable: true,
        ),
      );
    }
  }

  /// Handles email sign-in (mock)
  Future<void> _onSignInWithEmailRequested(
    AuthSignInWithEmailRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      AppLogger.info('Attempting email sign-in (mock): ${event.email}');
      emit(const AuthLoading());

      // For now, use mock sign-in with email credentials
      add(
        AuthSignInWithMockRequested(
          email: event.email,
          displayName: event.email.split('@').first,
        ),
      );
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error during email sign-in', e, stackTrace);
      emit(
        const AuthError(
          message: 'An unexpected error occurred during email sign-in',
          isRecoverable: true,
        ),
      );
    }
  }

  /// Handles anonymous sign-in (mock)
  Future<void> _onSignInAnonymouslyRequested(
    AuthSignInAnonymouslyRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      AppLogger.info('Attempting anonymous sign-in (mock)');
      emit(const AuthLoading());

      // For now, use mock sign-in with anonymous credentials
      add(
        const AuthSignInWithMockRequested(
          email: 'anonymous@dualify.app',
          displayName: 'Anonymous User',
        ),
      );
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error during anonymous sign-in',
        e,
        stackTrace,
      );
      emit(
        const AuthError(
          message: 'An unexpected error occurred during anonymous sign-in',
          isRecoverable: true,
        ),
      );
    }
  }

  /// Handles mock sign-in
  Future<void> _onSignInWithMockRequested(
    AuthSignInWithMockRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      AppLogger.info('Attempting mock sign-in: ${event.email}');
      emit(const AuthLoading());

      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 1500));

      // Create mock user
      final user = AuthUserFactory.createMockUser(
        email: event.email,
        displayName: event.displayName,
      );

      AppLogger.info('Mock sign-in successful: ${user.email}');
      emit(AuthAuthenticated(user: user));
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error during mock sign-in', e, stackTrace);
      emit(
        const AuthError(
          message: 'An unexpected error occurred during sign-in',
          isRecoverable: true,
        ),
      );
    }
  }

  /// Handles sign-out
  Future<void> _onSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      AppLogger.info('Attempting sign-out');
      emit(const AuthLoading());

      // Simulate sign-out delay
      await Future.delayed(const Duration(milliseconds: 500));

      AppLogger.info('Sign-out successful');
      emit(const AuthUnauthenticated());
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error during sign-out', e, stackTrace);
      emit(
        const AuthError(
          message: 'An unexpected error occurred during sign-out',
          isRecoverable: true,
        ),
      );
    }
  }

  /// Handles user updates from auth state changes
  Future<void> _onUserUpdated(
    AuthUserUpdated event,
    Emitter<AuthState> emit,
  ) async {
    try {
      if (event.user != null) {
        AppLogger.debug('User updated: ${event.user!.email}');
        emit(AuthAuthenticated(user: event.user!));
      } else {
        AppLogger.debug('User signed out');
        emit(const AuthUnauthenticated());
      }
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error during user update', e, stackTrace);
      emit(
        const AuthError(
          message: 'An unexpected error occurred during user update',
          isRecoverable: true,
        ),
      );
    }
  }

  /// Determines if a failure is recoverable
  bool _isRecoverableFailure(Failure failure) {
    // Most auth failures are recoverable (user can retry)
    switch (failure.runtimeType) {
      case AuthFailure:
        final authFailure = failure as AuthFailure;
        // Session expired or invalid credentials are recoverable
        return authFailure.code != 'ACCOUNT_DISABLED';
      case NetworkFailure:
        return true; // Network issues are usually temporary
      case ValidationFailure:
        return true; // User can correct validation errors
      default:
        return true; // Default to recoverable
    }
  }

  /// Gets the current authenticated user
  AuthUser? get currentUser {
    final currentState = state;
    if (currentState is AuthAuthenticated) {
      return currentState.user;
    }
    return null;
  }

  /// Checks if user is currently authenticated
  bool get isAuthenticated => state is AuthAuthenticated;

  /// Checks if authentication is in progress
  bool get isLoading => state is AuthLoading;

  /// Gets the current error message if any
  String? get errorMessage {
    final currentState = state;
    if (currentState is AuthError) {
      return currentState.message;
    }
    return null;
  }

  @override
  Future<void> close() {
    _authStatusSubscription?.cancel();
    return super.close();
  }
}
