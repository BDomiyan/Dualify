import 'package:equatable/equatable.dart';

import '../../../../domain/entities/entities.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

class ProfileLoaded extends ProfileState {
  final ApprenticeProfile profile;
  final ProgressCalculationResult progressData;

  const ProfileLoaded({required this.profile, required this.progressData});

  @override
  List<Object?> get props => [profile, progressData];
}

class ProfileEmpty extends ProfileState {
  const ProfileEmpty();
}

class ProfileError extends ProfileState {
  final String message;
  final String? code;
  final bool isRecoverable;

  const ProfileError({
    required this.message,
    this.code,
    this.isRecoverable = true,
  });

  @override
  List<Object?> get props => [message, code, isRecoverable];
}

class ProfileCreating extends ProfileState {
  const ProfileCreating();
}

class ProfileUpdating extends ProfileState {
  final ApprenticeProfile currentProfile;

  const ProfileUpdating(this.currentProfile);

  @override
  List<Object?> get props => [currentProfile];
}
