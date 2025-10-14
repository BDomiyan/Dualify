import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../core/errors/failures.dart';
import '../../../core/utils/logger.dart';
import '../../../domain/entities/entities.dart';
import '../../../domain/usecases/usecases.dart';

// Events
abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class ProfileLoadRequested extends ProfileEvent {
  const ProfileLoadRequested();
}

class ProfileCreateRequested extends ProfileEvent {
  final String firstName;
  final String lastName;
  final String trade;
  final DateTime apprenticeshipStartDate;
  final DateTime apprenticeshipEndDate;
  final String? companyName;
  final String? schoolName;
  final String? email;
  final String? phone;

  const ProfileCreateRequested({
    required this.firstName,
    required this.lastName,
    required this.trade,
    required this.apprenticeshipStartDate,
    required this.apprenticeshipEndDate,
    this.companyName,
    this.schoolName,
    this.email,
    this.phone,
  });

  @override
  List<Object?> get props => [
    firstName,
    lastName,
    trade,
    apprenticeshipStartDate,
    apprenticeshipEndDate,
    companyName,
    schoolName,
    email,
    phone,
  ];
}

class ProfileUpdateRequested extends ProfileEvent {
  final String? firstName;
  final String? lastName;
  final String? trade;
  final DateTime? apprenticeshipStartDate;
  final DateTime? apprenticeshipEndDate;
  final String? companyName;
  final String? schoolName;
  final String? email;
  final String? phone;
  final bool? isCompanyVerified;
  final bool? isSchoolVerified;

  const ProfileUpdateRequested({
    this.firstName,
    this.lastName,
    this.trade,
    this.apprenticeshipStartDate,
    this.apprenticeshipEndDate,
    this.companyName,
    this.schoolName,
    this.email,
    this.phone,
    this.isCompanyVerified,
    this.isSchoolVerified,
  });

  @override
  List<Object?> get props => [
    firstName,
    lastName,
    trade,
    apprenticeshipStartDate,
    apprenticeshipEndDate,
    companyName,
    schoolName,
    email,
    phone,
    isCompanyVerified,
    isSchoolVerified,
  ];
}

class ProfileRefreshRequested extends ProfileEvent {
  const ProfileRefreshRequested();
}

// States
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

// BLoC
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetProfileUseCase _getProfileUseCase;
  final CreateProfileUseCase _createProfileUseCase;
  final UpdateProfileUseCase _updateProfileUseCase;

  ProfileBloc({
    required GetProfileUseCase getProfileUseCase,
    required CreateProfileUseCase createProfileUseCase,
    required UpdateProfileUseCase updateProfileUseCase,
  }) : _getProfileUseCase = getProfileUseCase,
       _createProfileUseCase = createProfileUseCase,
       _updateProfileUseCase = updateProfileUseCase,
       super(const ProfileInitial()) {
    // Register event handlers
    on<ProfileLoadRequested>(_onProfileLoadRequested);
    on<ProfileCreateRequested>(_onProfileCreateRequested);
    on<ProfileUpdateRequested>(_onProfileUpdateRequested);
    on<ProfileRefreshRequested>(_onProfileRefreshRequested);
  }

  /// Handles profile load request
  Future<void> _onProfileLoadRequested(
    ProfileLoadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      AppLogger.debug('Loading profile');
      emit(const ProfileLoading());

      final result = await _getProfileUseCase(const NoParams());

      result.fold(
        (failure) {
          AppLogger.error('Profile load failed: ${failure.message}');
          emit(
            ProfileError(
              message: failure.message,
              code: failure.code,
              isRecoverable: _isRecoverableFailure(failure),
            ),
          );
        },
        (profile) {
          if (profile != null) {
            AppLogger.info('Profile loaded successfully: ${profile.fullName}');
            final progressData = ProgressCalculationResult.calculate(
              profile.apprenticeshipStartDate,
              profile.apprenticeshipEndDate,
            );
            emit(ProfileLoaded(profile: profile, progressData: progressData));
          } else {
            AppLogger.debug('No profile found');
            emit(const ProfileEmpty());
          }
        },
      );
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error during profile load', e, stackTrace);
      emit(
        const ProfileError(
          message: 'An unexpected error occurred while loading profile',
          isRecoverable: true,
        ),
      );
    }
  }

  /// Handles profile creation request
  Future<void> _onProfileCreateRequested(
    ProfileCreateRequested event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      AppLogger.info('Creating profile: ${event.firstName} ${event.lastName}');
      emit(const ProfileCreating());

      final params = CreateProfileParams(
        firstName: event.firstName,
        lastName: event.lastName,
        trade: event.trade,
        apprenticeshipStartDate: event.apprenticeshipStartDate,
        apprenticeshipEndDate: event.apprenticeshipEndDate,
        companyName: event.companyName,
        schoolName: event.schoolName,
        email: event.email,
        phone: event.phone,
      );

      final result = await _createProfileUseCase(params);

      result.fold(
        (failure) {
          AppLogger.error('Profile creation failed: ${failure.message}');
          emit(
            ProfileError(
              message: failure.message,
              code: failure.code,
              isRecoverable: _isRecoverableFailure(failure),
            ),
          );
        },
        (profile) {
          AppLogger.info('Profile created successfully: ${profile.fullName}');
          final progressData = ProgressCalculationResult.calculate(
            profile.apprenticeshipStartDate,
            profile.apprenticeshipEndDate,
          );
          emit(ProfileLoaded(profile: profile, progressData: progressData));
        },
      );
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error during profile creation',
        e,
        stackTrace,
      );
      emit(
        const ProfileError(
          message: 'An unexpected error occurred while creating profile',
          isRecoverable: true,
        ),
      );
    }
  }

  /// Handles profile update request
  Future<void> _onProfileUpdateRequested(
    ProfileUpdateRequested event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      final currentState = state;
      if (currentState is! ProfileLoaded) {
        AppLogger.warning('Cannot update profile: no profile loaded');
        emit(
          const ProfileError(
            message: 'No profile loaded to update',
            code: 'NO_PROFILE_LOADED',
            isRecoverable: false,
          ),
        );
        return;
      }

      AppLogger.info('Updating profile: ${currentState.profile.fullName}');
      emit(ProfileUpdating(currentState.profile));

      final params = UpdateProfileParams(
        firstName: event.firstName,
        lastName: event.lastName,
        trade: event.trade,
        apprenticeshipStartDate: event.apprenticeshipStartDate,
        apprenticeshipEndDate: event.apprenticeshipEndDate,
        companyName: event.companyName,
        schoolName: event.schoolName,
        email: event.email,
        phone: event.phone,
        isCompanyVerified: event.isCompanyVerified,
        isSchoolVerified: event.isSchoolVerified,
      );

      final result = await _updateProfileUseCase(params);

      result.fold(
        (failure) {
          AppLogger.error('Profile update failed: ${failure.message}');
          emit(
            ProfileError(
              message: failure.message,
              code: failure.code,
              isRecoverable: _isRecoverableFailure(failure),
            ),
          );
        },
        (profile) {
          AppLogger.info('Profile updated successfully: ${profile.fullName}');
          final progressData = ProgressCalculationResult.calculate(
            profile.apprenticeshipStartDate,
            profile.apprenticeshipEndDate,
          );
          emit(ProfileLoaded(profile: profile, progressData: progressData));
        },
      );
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error during profile update', e, stackTrace);
      emit(
        const ProfileError(
          message: 'An unexpected error occurred while updating profile',
          isRecoverable: true,
        ),
      );
    }
  }

  /// Handles profile refresh request
  Future<void> _onProfileRefreshRequested(
    ProfileRefreshRequested event,
    Emitter<ProfileState> emit,
  ) async {
    // Refresh is the same as load
    add(const ProfileLoadRequested());
  }

  /// Determines if a failure is recoverable
  bool _isRecoverableFailure(Failure failure) {
    switch (failure.runtimeType) {
      case ValidationFailure:
        return true; // User can correct validation errors
      case DatabaseFailure:
        final dbFailure = failure as DatabaseFailure;
        // Some database errors are not recoverable
        return dbFailure.code != 'DB_008'; // Data corruption
      case StorageFailure:
        return true; // Storage issues are usually temporary
      default:
        return true; // Default to recoverable
    }
  }

  /// Gets the current profile
  ApprenticeProfile? get currentProfile {
    final currentState = state;
    if (currentState is ProfileLoaded) {
      return currentState.profile;
    } else if (currentState is ProfileUpdating) {
      return currentState.currentProfile;
    }
    return null;
  }

  /// Gets the current progress data
  ProgressCalculationResult? get currentProgressData {
    final currentState = state;
    if (currentState is ProfileLoaded) {
      return currentState.progressData;
    }
    return null;
  }

  /// Checks if profile exists
  bool get hasProfile => currentProfile != null;

  /// Checks if profile is loading
  bool get isLoading => state is ProfileLoading || state is ProfileCreating;

  /// Checks if profile is being updated
  bool get isUpdating => state is ProfileUpdating;

  /// Gets the current error message if any
  String? get errorMessage {
    final currentState = state;
    if (currentState is ProfileError) {
      return currentState.message;
    }
    return null;
  }
}
