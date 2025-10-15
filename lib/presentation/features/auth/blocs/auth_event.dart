import 'package:equatable/equatable.dart';

import '../../../../domain/entities/entities.dart';

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
