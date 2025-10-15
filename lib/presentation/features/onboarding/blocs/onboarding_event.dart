import 'package:equatable/equatable.dart';

import 'onboarding_form_data.dart';

abstract class OnboardingEvent extends Equatable {
  const OnboardingEvent();

  @override
  List<Object?> get props => [];
}

class OnboardingStarted extends OnboardingEvent {
  const OnboardingStarted();
}

class OnboardingFieldChanged extends OnboardingEvent {
  final String field;
  final dynamic value;

  const OnboardingFieldChanged({required this.field, required this.value});

  @override
  List<Object?> get props => [field, value];
}

class OnboardingSubmitted extends OnboardingEvent {
  final OnboardingFormData formData;

  const OnboardingSubmitted(this.formData);

  @override
  List<Object?> get props => [formData];
}

class OnboardingValidationRequested extends OnboardingEvent {
  final OnboardingFormData formData;

  const OnboardingValidationRequested(this.formData);

  @override
  List<Object?> get props => [formData];
}
