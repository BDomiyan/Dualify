import 'package:equatable/equatable.dart';

import '../../../../domain/entities/entities.dart';
import 'onboarding_form_data.dart';

abstract class OnboardingState extends Equatable {
  const OnboardingState();

  @override
  List<Object?> get props => [];
}

class OnboardingInitial extends OnboardingState {
  const OnboardingInitial();
}

class OnboardingInProgress extends OnboardingState {
  final OnboardingFormData formData;
  final Map<String, String> fieldErrors;
  final bool isValid;

  const OnboardingInProgress({
    required this.formData,
    this.fieldErrors = const {},
    this.isValid = false,
  });

  @override
  List<Object?> get props => [formData, fieldErrors, isValid];

  OnboardingInProgress copyWith({
    OnboardingFormData? formData,
    Map<String, String>? fieldErrors,
    bool? isValid,
  }) {
    return OnboardingInProgress(
      formData: formData ?? this.formData,
      fieldErrors: fieldErrors ?? this.fieldErrors,
      isValid: isValid ?? this.isValid,
    );
  }
}

class OnboardingSubmitting extends OnboardingState {
  final OnboardingFormData formData;

  const OnboardingSubmitting(this.formData);

  @override
  List<Object?> get props => [formData];
}

class OnboardingSuccess extends OnboardingState {
  final ApprenticeProfile profile;

  const OnboardingSuccess(this.profile);

  @override
  List<Object?> get props => [profile];
}

class OnboardingError extends OnboardingState {
  final String message;
  final String? code;
  final OnboardingFormData? formData;
  final bool isRecoverable;

  const OnboardingError({
    required this.message,
    this.code,
    this.formData,
    this.isRecoverable = true,
  });

  @override
  List<Object?> get props => [message, code, formData, isRecoverable];
}
