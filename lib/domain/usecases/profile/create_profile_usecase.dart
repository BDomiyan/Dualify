import 'package:dartz/dartz.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/errors/failures.dart';
import '../../../core/validation/validation.dart';
import '../../entities/entities.dart';
import '../../repositories/repositories.dart';
import '../usecase.dart';

/// Parameters for creating a profile
class CreateProfileParams {
  final String firstName;
  final String lastName;
  final String trade;
  final DateTime apprenticeshipStartDate;
  final DateTime apprenticeshipEndDate;
  final String? companyName;
  final String? schoolName;
  final String? email;
  final String? phone;

  const CreateProfileParams({
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
}

/// Use case for creating a new apprentice profile
/// Follows Clean Architecture and Single Responsibility Principle
class CreateProfileUseCase
    implements UseCase<ApprenticeProfile, CreateProfileParams> {
  final ILocalApprenticeshipRepository _repository;
  final FormValidator _validator;

  CreateProfileUseCase(this._repository) : _validator = _createValidator();

  @override
  Future<Either<Failure, ApprenticeProfile>> call(
    CreateProfileParams params,
  ) async {
    try {
      // Check if profile already exists
      final existingProfileResult = await _repository.hasProfile();

      return existingProfileResult.fold((failure) => Left(failure), (
        hasProfile,
      ) async {
        if (hasProfile) {
          return Left(
            ValidationFailure(
              'Profile already exists. Use update profile instead.',
              code: 'PROFILE_ALREADY_EXISTS',
            ),
          );
        }

        // Validate input parameters
        final validationResult = _validateParams(params);
        if (!validationResult.isValid) {
          return Left(
            ValidationFailure(
              'Invalid profile data',
              fieldErrors: validationResult.fieldErrors,
              code: 'PROFILE_VALIDATION_FAILED',
            ),
          );
        }

        // Create profile entity
        final profile = ApprenticeProfileFactory.create(
          firstName: params.firstName,
          lastName: params.lastName,
          trade: params.trade,
          apprenticeshipStartDate: params.apprenticeshipStartDate,
          apprenticeshipEndDate: params.apprenticeshipEndDate,
          companyName: params.companyName,
          schoolName: params.schoolName,
          email: params.email,
          phone: params.phone,
        );

        // Validate the created profile
        final profileValidationErrors = profile.validate();
        if (profileValidationErrors.isNotEmpty) {
          return Left(
            ValidationFailure(
              'Profile validation failed: ${profileValidationErrors.join(', ')}',
              code: 'PROFILE_ENTITY_VALIDATION_FAILED',
            ),
          );
        }

        // Save profile to repository
        final createResult = await _repository.createProfile(profile);

        return createResult.fold((failure) => Left(failure), (createdProfile) {
          // Verify the created profile
          final verificationErrors = createdProfile.validate();
          if (verificationErrors.isNotEmpty) {
            return Left(
              DataFailure(
                'Created profile is invalid: ${verificationErrors.join(', ')}',
                code: 'CREATED_PROFILE_INVALID',
              ),
            );
          }

          return Right(createdProfile);
        });
      });
    } catch (e) {
      return Left(
        DataFailure(
          'Unexpected error creating profile: ${e.toString()}',
          code: 'PROFILE_CREATION_UNEXPECTED_ERROR',
        ),
      );
    }
  }

  /// Creates the validator for profile creation
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
          ValidationRules.selection('Trade', AppStrings.tradeOptions),
        )
        .addRequiredField(
          'apprenticeshipStartDate',
          ValidationRules.date(
            'Apprenticeship Start Date',
            allowFuture: false,
            minDate: DateTime.now().subtract(const Duration(days: 365 * 10)),
          ),
        )
        .addRequiredField(
          'apprenticeshipEndDate',
          ValidationRules.date(
            'Apprenticeship End Date',
            allowPast: false,
            maxDate: DateTime.now().add(const Duration(days: 365 * 10)),
          ),
        )
        .addOptionalField('companyName', [
          LengthRule('Company Name', maxLength: 100),
        ])
        .addOptionalField('schoolName', [
          LengthRule('School Name', maxLength: 100),
        ])
        .build();
  }

  /// Validates the input parameters using the form validator
  FormValidationResult _validateParams(CreateProfileParams params) {
    final formData = {
      'firstName': params.firstName,
      'lastName': params.lastName,
      'trade': params.trade,
      'apprenticeshipStartDate': params.apprenticeshipStartDate,
      'apprenticeshipEndDate': params.apprenticeshipEndDate,
      'companyName': params.companyName,
      'schoolName': params.schoolName,
      'email': params.email,
      'phone': params.phone,
    };

    return _validator.validateForm(formData);
  }
}
