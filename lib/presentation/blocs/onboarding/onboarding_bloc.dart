import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../core/errors/failures.dart';
import '../../../core/utils/logger.dart';
import '../../../core/validation/form_validator.dart';
import '../../../domain/entities/entities.dart';
import '../../../domain/usecases/usecases.dart';

// Events
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

// States
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

// Form Data Model
class OnboardingFormData extends Equatable {
  final String firstName;
  final String lastName;
  final String trade;
  final DateTime? apprenticeshipStartDate;
  final DateTime? apprenticeshipEndDate;
  final String? companyName;
  final String? schoolName;
  final String? email;
  final String? phone;

  const OnboardingFormData({
    this.firstName = '',
    this.lastName = '',
    this.trade = '',
    this.apprenticeshipStartDate,
    this.apprenticeshipEndDate,
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

  OnboardingFormData copyWith({
    String? firstName,
    String? lastName,
    String? trade,
    DateTime? apprenticeshipStartDate,
    DateTime? apprenticeshipEndDate,
    String? companyName,
    String? schoolName,
    String? email,
    String? phone,
  }) {
    return OnboardingFormData(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      trade: trade ?? this.trade,
      apprenticeshipStartDate:
          apprenticeshipStartDate ?? this.apprenticeshipStartDate,
      apprenticeshipEndDate:
          apprenticeshipEndDate ?? this.apprenticeshipEndDate,
      companyName: companyName ?? this.companyName,
      schoolName: schoolName ?? this.schoolName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
    );
  }

  bool get isComplete {
    return firstName.isNotEmpty &&
        lastName.isNotEmpty &&
        trade.isNotEmpty &&
        apprenticeshipStartDate != null &&
        apprenticeshipEndDate != null;
  }
}

// BLoC
class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  final CreateProfileUseCase _createProfileUseCase;

  OnboardingBloc({
    required CreateProfileUseCase createProfileUseCase,
    required FormValidator formValidator,
  }) : _createProfileUseCase = createProfileUseCase,
       super(const OnboardingInitial()) {
    // Register event handlers
    on<OnboardingStarted>(_onOnboardingStarted);
    on<OnboardingFieldChanged>(_onOnboardingFieldChanged);
    on<OnboardingValidationRequested>(_onOnboardingValidationRequested);
    on<OnboardingSubmitted>(_onOnboardingSubmitted);
  }

  /// Handles onboarding start
  Future<void> _onOnboardingStarted(
    OnboardingStarted event,
    Emitter<OnboardingState> emit,
  ) async {
    AppLogger.debug('Starting onboarding process');

    const initialFormData = OnboardingFormData();
    emit(
      const OnboardingInProgress(
        formData: initialFormData,
        fieldErrors: {},
        isValid: false,
      ),
    );
  }

  /// Handles field changes with real-time validation
  Future<void> _onOnboardingFieldChanged(
    OnboardingFieldChanged event,
    Emitter<OnboardingState> emit,
  ) async {
    final currentState = state;
    if (currentState is! OnboardingInProgress) return;

    // Update form data
    final updatedFormData = _updateFormData(
      currentState.formData,
      event.field,
      event.value,
    );

    // Validate the specific field
    final fieldErrors = Map<String, String>.from(currentState.fieldErrors);
    final fieldValidationResult = _validateField(event.field, event.value);

    if (fieldValidationResult != null) {
      fieldErrors[event.field] = fieldValidationResult;
    } else {
      fieldErrors.remove(event.field);
    }

    // Check overall form validity
    final isValid = _isFormValid(updatedFormData, fieldErrors);

    emit(
      currentState.copyWith(
        formData: updatedFormData,
        fieldErrors: fieldErrors,
        isValid: isValid,
      ),
    );
  }

  /// Handles form validation request
  Future<void> _onOnboardingValidationRequested(
    OnboardingValidationRequested event,
    Emitter<OnboardingState> emit,
  ) async {
    AppLogger.debug('Validating onboarding form');

    final fieldErrors = <String, String>{};

    // Validate all fields
    final firstNameError = _validateField(
      'firstName',
      event.formData.firstName,
    );
    if (firstNameError != null) fieldErrors['firstName'] = firstNameError;

    final lastNameError = _validateField('lastName', event.formData.lastName);
    if (lastNameError != null) fieldErrors['lastName'] = lastNameError;

    final tradeError = _validateField('trade', event.formData.trade);
    if (tradeError != null) fieldErrors['trade'] = tradeError;

    final startDateError = _validateField(
      'apprenticeshipStartDate',
      event.formData.apprenticeshipStartDate,
    );
    if (startDateError != null) {
      fieldErrors['apprenticeshipStartDate'] = startDateError;
    }

    final endDateError = _validateField(
      'apprenticeshipEndDate',
      event.formData.apprenticeshipEndDate,
    );
    if (endDateError != null) {
      fieldErrors['apprenticeshipEndDate'] = endDateError;
    }

    // Validate date range
    if (event.formData.apprenticeshipStartDate != null &&
        event.formData.apprenticeshipEndDate != null) {
      if (event.formData.apprenticeshipEndDate!.isBefore(
        event.formData.apprenticeshipStartDate!,
      )) {
        fieldErrors['apprenticeshipEndDate'] =
            'End date must be after start date';
      }
    }

    // Validate optional fields if provided
    if (event.formData.email != null && event.formData.email!.isNotEmpty) {
      final emailError = _validateField('email', event.formData.email);
      if (emailError != null) fieldErrors['email'] = emailError;
    }

    if (event.formData.phone != null && event.formData.phone!.isNotEmpty) {
      final phoneError = _validateField('phone', event.formData.phone);
      if (phoneError != null) fieldErrors['phone'] = phoneError;
    }

    final isValid = _isFormValid(event.formData, fieldErrors);

    emit(
      OnboardingInProgress(
        formData: event.formData,
        fieldErrors: fieldErrors,
        isValid: isValid,
      ),
    );
  }

  /// Handles form submission
  Future<void> _onOnboardingSubmitted(
    OnboardingSubmitted event,
    Emitter<OnboardingState> emit,
  ) async {
    try {
      AppLogger.info(
        'Submitting onboarding form: ${event.formData.firstName} ${event.formData.lastName}',
      );
      emit(OnboardingSubmitting(event.formData));

      // Validate form before submission
      add(OnboardingValidationRequested(event.formData));

      // Wait for validation to complete
      await Future.delayed(const Duration(milliseconds: 100));

      final currentState = state;
      if (currentState is OnboardingInProgress && !currentState.isValid) {
        AppLogger.warning('Form validation failed during submission');
        return;
      }

      // Create profile
      final params = CreateProfileParams(
        firstName: event.formData.firstName,
        lastName: event.formData.lastName,
        trade: event.formData.trade,
        apprenticeshipStartDate: event.formData.apprenticeshipStartDate!,
        apprenticeshipEndDate: event.formData.apprenticeshipEndDate!,
        companyName: event.formData.companyName,
        schoolName: event.formData.schoolName,
        email: event.formData.email,
        phone: event.formData.phone,
      );

      final result = await _createProfileUseCase(params);

      result.fold(
        (failure) {
          AppLogger.error('Onboarding submission failed: ${failure.message}');
          emit(
            OnboardingError(
              message: failure.message,
              code: failure.code,
              formData: event.formData,
              isRecoverable: _isRecoverableFailure(failure),
            ),
          );
        },
        (profile) {
          AppLogger.info(
            'Onboarding completed successfully: ${profile.fullName}',
          );
          emit(OnboardingSuccess(profile));
        },
      );
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error during onboarding submission',
        e,
        stackTrace,
      );
      emit(
        OnboardingError(
          message: 'An unexpected error occurred during onboarding',
          formData: event.formData,
          isRecoverable: true,
        ),
      );
    }
  }

  /// Updates form data based on field changes
  OnboardingFormData _updateFormData(
    OnboardingFormData formData,
    String field,
    dynamic value,
  ) {
    switch (field) {
      case 'firstName':
        return formData.copyWith(firstName: value as String);
      case 'lastName':
        return formData.copyWith(lastName: value as String);
      case 'trade':
        return formData.copyWith(trade: value as String);
      case 'apprenticeshipStartDate':
        return formData.copyWith(apprenticeshipStartDate: value as DateTime?);
      case 'apprenticeshipEndDate':
        return formData.copyWith(apprenticeshipEndDate: value as DateTime?);
      case 'companyName':
        return formData.copyWith(companyName: value as String?);
      case 'schoolName':
        return formData.copyWith(schoolName: value as String?);
      case 'email':
        return formData.copyWith(email: value as String?);
      case 'phone':
        return formData.copyWith(phone: value as String?);
      default:
        return formData;
    }
  }

  /// Validates individual fields
  String? _validateField(String field, dynamic value) {
    switch (field) {
      case 'firstName':
        if (value == null || (value as String).isEmpty) {
          return 'First name is required';
        }
        if (value.length < 2) {
          return 'First name must be at least 2 characters';
        }
        break;
      case 'lastName':
        if (value == null || (value as String).isEmpty) {
          return 'Last name is required';
        }
        if (value.length < 2) {
          return 'Last name must be at least 2 characters';
        }
        break;
      case 'trade':
        if (value == null || (value as String).isEmpty) {
          return 'Trade is required';
        }
        break;
      case 'apprenticeshipStartDate':
        if (value == null) {
          return 'Start date is required';
        }
        final date = value as DateTime;
        final now = DateTime.now();
        if (date.isAfter(now.add(const Duration(days: 365)))) {
          return 'Start date cannot be more than a year in the future';
        }
        break;
      case 'apprenticeshipEndDate':
        if (value == null) {
          return 'End date is required';
        }
        break;
      case 'email':
        if (value != null && (value as String).isNotEmpty) {
          final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
          if (!emailRegex.hasMatch(value)) {
            return 'Please enter a valid email address';
          }
        }
        break;
      case 'phone':
        if (value != null && (value as String).isNotEmpty) {
          final phoneRegex = RegExp(r'^\+?[\d\s\-\(\)]{10,}$');
          if (!phoneRegex.hasMatch(value)) {
            return 'Please enter a valid phone number';
          }
        }
        break;
    }
    return null;
  }

  /// Checks if the entire form is valid
  bool _isFormValid(
    OnboardingFormData formData,
    Map<String, String> fieldErrors,
  ) {
    return fieldErrors.isEmpty && formData.isComplete;
  }

  /// Determines if a failure is recoverable
  bool _isRecoverableFailure(Failure failure) {
    switch (failure.runtimeType) {
      case ValidationFailure _:
        return true; // User can correct validation errors
      case DatabaseFailure:
        final dbFailure = failure as DatabaseFailure;
        return dbFailure.code != 'DB_008'; // Data corruption is not recoverable
      case NetworkFailure:
        return true; // Network issues are usually temporary
      default:
        return true; // Default to recoverable
    }
  }

  /// Gets the current form data
  OnboardingFormData? get currentFormData {
    final currentState = state;
    if (currentState is OnboardingInProgress) {
      return currentState.formData;
    } else if (currentState is OnboardingSubmitting) {
      return currentState.formData;
    } else if (currentState is OnboardingError) {
      return currentState.formData;
    }
    return null;
  }

  /// Gets current field errors
  Map<String, String> get fieldErrors {
    final currentState = state;
    if (currentState is OnboardingInProgress) {
      return currentState.fieldErrors;
    }
    return {};
  }

  /// Checks if form is valid
  bool get isFormValid {
    final currentState = state;
    if (currentState is OnboardingInProgress) {
      return currentState.isValid;
    }
    return false;
  }

  /// Checks if onboarding is in progress
  bool get isSubmitting => state is OnboardingSubmitting;

  /// Gets the current error message if any
  String? get errorMessage {
    final currentState = state;
    if (currentState is OnboardingError) {
      return currentState.message;
    }
    return null;
  }
}

/// Predefined trade options matching the HTML design
class TradeOptions {
  static const List<String> trades = [
    'Electrician',
    'Plumber',
    'Carpenter',
    'Welder',
  ];

  static bool isValidTrade(String trade) {
    return trades.contains(trade);
  }
}
