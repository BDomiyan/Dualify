import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';
import '../../../core/validation/validation.dart';
import '../../entities/entities.dart';
import '../../repositories/repositories.dart';
import '../usecase.dart';

/// Parameters for updating a profile
class UpdateProfileParams {
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

  const UpdateProfileParams({
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

  /// Checks if any field is being updated
  bool get hasUpdates =>
      firstName != null ||
      lastName != null ||
      trade != null ||
      apprenticeshipStartDate != null ||
      apprenticeshipEndDate != null ||
      companyName != null ||
      schoolName != null ||
      email != null ||
      phone != null ||
      isCompanyVerified != null ||
      isSchoolVerified != null;
}

/// Use case for updating an existing apprentice profile
/// Follows Clean Architecture and Single Responsibility Principle
class UpdateProfileUseCase
    implements UseCase<ApprenticeProfile, UpdateProfileParams> {
  final ILocalApprenticeshipRepository _repository;
  final FormValidator _validator;

  UpdateProfileUseCase(this._repository) : _validator = _createValidator();

  @override
  Future<Either<Failure, ApprenticeProfile>> call(
    UpdateProfileParams params,
  ) async {
    try {
      // Validate that there are updates to apply
      if (!params.hasUpdates) {
        return Left(
          ValidationFailure('No updates provided', code: 'NO_UPDATES_PROVIDED'),
        );
      }

      // Get existing profile
      final existingProfileResult = await _repository.getProfile();

      return existingProfileResult.fold((failure) => Left(failure), (
        existingProfile,
      ) async {
        if (existingProfile == null) {
          return Left(
            DataFailure(
              'No profile found to update',
              code: 'PROFILE_NOT_FOUND',
            ),
          );
        }

        // Create updated profile
        final updatedProfile = _createUpdatedProfile(existingProfile, params);

        // Validate the updated profile data
        final validationResult = _validateUpdatedProfile(updatedProfile);
        if (!validationResult.isValid) {
          return Left(
            ValidationFailure(
              'Invalid profile update data',
              fieldErrors: validationResult.fieldErrors,
              code: 'PROFILE_UPDATE_VALIDATION_FAILED',
            ),
          );
        }

        // Validate the profile entity
        final profileValidationErrors = updatedProfile.validate();
        if (profileValidationErrors.isNotEmpty) {
          return Left(
            ValidationFailure(
              'Profile validation failed: ${profileValidationErrors.join(', ')}',
              code: 'PROFILE_ENTITY_VALIDATION_FAILED',
            ),
          );
        }

        // Check for business rule violations
        final businessRuleErrors = _validateBusinessRules(
          existingProfile,
          updatedProfile,
        );
        if (businessRuleErrors.isNotEmpty) {
          return Left(
            ValidationFailure(
              'Business rule validation failed: ${businessRuleErrors.join(', ')}',
              code: 'BUSINESS_RULE_VALIDATION_FAILED',
            ),
          );
        }

        // Update profile in repository
        final updateResult = await _repository.updateProfile(updatedProfile);

        return updateResult.fold((failure) => Left(failure), (savedProfile) {
          // Verify the saved profile
          final verificationErrors = savedProfile.validate();
          if (verificationErrors.isNotEmpty) {
            return Left(
              DataFailure(
                'Updated profile is invalid: ${verificationErrors.join(', ')}',
                code: 'UPDATED_PROFILE_INVALID',
              ),
            );
          }

          return Right(savedProfile);
        });
      });
    } catch (e) {
      return Left(
        DataFailure(
          'Unexpected error updating profile: ${e.toString()}',
          code: 'PROFILE_UPDATE_UNEXPECTED_ERROR',
        ),
      );
    }
  }

  /// Creates an updated profile with the new values
  ApprenticeProfile _createUpdatedProfile(
    ApprenticeProfile existing,
    UpdateProfileParams params,
  ) {
    return existing.copyWith(
      firstName: params.firstName,
      lastName: params.lastName,
      trade: params.trade,
      apprenticeshipStartDate: params.apprenticeshipStartDate,
      apprenticeshipEndDate: params.apprenticeshipEndDate,
      companyName: params.companyName,
      schoolName: params.schoolName,
      email: params.email,
      phone: params.phone,
      isCompanyVerified: params.isCompanyVerified,
      isSchoolVerified: params.isSchoolVerified,
      updatedAt: DateTime.now(),
    );
  }

  /// Creates the validator for profile updates
  static FormValidator _createValidator() {
    return FormValidatorBuilder()
        .addRequiredField('firstName', [
          LengthRule('First Name', minLength: 2, maxLength: 50),
        ])
        .addRequiredField('lastName', [
          LengthRule('Last Name', minLength: 2, maxLength: 50),
        ])
        .addRequiredField(
          'trade',
          ValidationRules.selection('Trade', [
            'Electrician',
            'Plumber',
            'Carpenter',
            'Mechanic',
            'Welder',
            'HVAC Technician',
            'Mason',
            'Painter',
            'Roofer',
            'Other',
          ]),
        )
        .addOptionalField('companyName', [
          LengthRule('Company Name', maxLength: 100),
        ])
        .addOptionalField('schoolName', [
          LengthRule('School Name', maxLength: 100),
        ])
        .addOptionalField(
          'email',
          ValidationRules.email('Email', required: false),
        )
        .build();
  }

  /// Validates the updated profile using the form validator
  FormValidationResult _validateUpdatedProfile(ApprenticeProfile profile) {
    final formData = {
      'firstName': profile.firstName,
      'lastName': profile.lastName,
      'trade': profile.trade,
      'companyName': profile.companyName,
      'schoolName': profile.schoolName,
      'email': profile.email,
      'phone': profile.phone,
    };

    return _validator.validateForm(formData);
  }

  /// Validates business rules for profile updates
  List<String> _validateBusinessRules(
    ApprenticeProfile existing,
    ApprenticeProfile updated,
  ) {
    final errors = <String>[];

    // Check if apprenticeship dates are being changed after it has started
    if (existing.hasStarted) {
      if (updated.apprenticeshipStartDate != existing.apprenticeshipStartDate) {
        errors.add(
          'Cannot change apprenticeship start date after it has begun',
        );
      }
    }

    // Check if apprenticeship end date is being moved to the past
    if (existing.isActive &&
        updated.apprenticeshipEndDate.isBefore(DateTime.now())) {
      errors.add(
        'Cannot set apprenticeship end date in the past for active apprenticeship',
      );
    }

    // Check if verification status is being removed inappropriately
    if (existing.isCompanyVerified && updated.isCompanyVerified == false) {
      if (updated.companyName != existing.companyName) {
        // Allow removal if company name is changing
      } else {
        errors.add(
          'Cannot remove company verification without changing company',
        );
      }
    }

    if (existing.isSchoolVerified && updated.isSchoolVerified == false) {
      if (updated.schoolName != existing.schoolName) {
        // Allow removal if school name is changing
      } else {
        errors.add('Cannot remove school verification without changing school');
      }
    }

    return errors;
  }
}
