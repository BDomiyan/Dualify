import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';
import '../../../core/validation/validation.dart';
import '../../entities/entities.dart';
import '../../repositories/repositories.dart';
import '../usecase.dart';

/// Parameters for updating daily status
class UpdateDailyStatusParams {
  final DateTime date;
  final DailyLogStatus status;
  final String? notes;

  const UpdateDailyStatusParams({
    required this.date,
    required this.status,
    this.notes,
  });
}

/// Use case for updating daily log status
/// Follows Clean Architecture and Single Responsibility Principle
class UpdateDailyStatusUseCase
    implements UseCase<DailyLog, UpdateDailyStatusParams> {
  final ILocalApprenticeshipRepository _repository;
  final FormValidator _validator;

  UpdateDailyStatusUseCase(this._repository) : _validator = _createValidator();

  @override
  Future<Either<Failure, DailyLog>> call(UpdateDailyStatusParams params) async {
    try {
      // Validate input parameters
      final validationResult = _validateParams(params);
      if (!validationResult.isValid) {
        return Left(
          ValidationFailure(
            'Invalid daily status update data',
            fieldErrors: validationResult.fieldErrors,
            code: 'DAILY_STATUS_VALIDATION_FAILED',
          ),
        );
      }

      // Get current profile to validate date is within apprenticeship period
      final profileResult = await _repository.getProfile();

      return profileResult.fold((failure) => Left(failure), (profile) async {
        if (profile == null) {
          return Left(
            DataFailure(
              'No profile found. Please complete onboarding first.',
              code: 'PROFILE_NOT_FOUND',
            ),
          );
        }

        // Validate date is within apprenticeship period
        final dateValidationError = _validateDateWithinApprenticeship(
          params.date,
          profile,
        );
        if (dateValidationError != null) {
          return Left(
            ValidationFailure(dateValidationError, code: 'DATE_OUT_OF_RANGE'),
          );
        }

        // Check if daily log already exists for this date
        final existingLogResult = await _repository.getDailyLogByDate(
          params.date,
        );

        return existingLogResult.fold((failure) => Left(failure), (
          existingLog,
        ) async {
          if (existingLog != null) {
            // Update existing log
            return _updateExistingLog(existingLog, params);
          } else {
            // Create new log
            return _createNewLog(profile.id, params);
          }
        });
      });
    } catch (e) {
      return Left(
        DataFailure(
          'Unexpected error updating daily status: ${e.toString()}',
          code: 'DAILY_STATUS_UPDATE_UNEXPECTED_ERROR',
        ),
      );
    }
  }

  /// Creates the validator for daily status updates
  static FormValidator _createValidator() {
    return FormValidatorBuilder()
        .addRequiredField(
          'status',
          ValidationRules.selection('Status', [
            'learning',
            'challenging',
            'neutral',
            'good',
          ]),
        )
        .addOptionalField('notes', [LengthRule('Notes', maxLength: 500)])
        .build();
  }

  /// Validates the input parameters
  FormValidationResult _validateParams(UpdateDailyStatusParams params) {
    final formData = {'status': params.status.value, 'notes': params.notes};

    return _validator.validateForm(formData);
  }

  /// Validates that the date is within the apprenticeship period
  String? _validateDateWithinApprenticeship(
    DateTime date,
    ApprenticeProfile profile,
  ) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    final startOnly = DateTime(
      profile.apprenticeshipStartDate.year,
      profile.apprenticeshipStartDate.month,
      profile.apprenticeshipStartDate.day,
    );
    final endOnly = DateTime(
      profile.apprenticeshipEndDate.year,
      profile.apprenticeshipEndDate.month,
      profile.apprenticeshipEndDate.day,
    );

    if (dateOnly.isBefore(startOnly)) {
      return 'Cannot log status before apprenticeship start date';
    }

    if (dateOnly.isAfter(endOnly)) {
      return 'Cannot log status after apprenticeship end date';
    }

    // Check if date is too far in the future (max 7 days)
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    final maxFutureDate = todayOnly.add(const Duration(days: 7));

    if (dateOnly.isAfter(maxFutureDate)) {
      return 'Cannot log status more than 7 days in the future';
    }

    return null;
  }

  /// Updates an existing daily log
  Future<Either<Failure, DailyLog>> _updateExistingLog(
    DailyLog existingLog,
    UpdateDailyStatusParams params,
  ) async {
    try {
      // Create updated log
      final updatedLog = existingLog.copyWith(
        status: params.status,
        notes: params.notes,
        updatedAt: DateTime.now(),
      );

      // Validate the updated log
      final validationErrors = updatedLog.validate();
      if (validationErrors.isNotEmpty) {
        return Left(
          ValidationFailure(
            'Updated daily log validation failed: ${validationErrors.join(', ')}',
            code: 'DAILY_LOG_ENTITY_VALIDATION_FAILED',
          ),
        );
      }

      // Update in repository
      final updateResult = await _repository.updateDailyLog(updatedLog);

      return updateResult.fold((failure) => Left(failure), (savedLog) {
        // Verify the saved log
        final verificationErrors = savedLog.validate();
        if (verificationErrors.isNotEmpty) {
          return Left(
            DataFailure(
              'Updated daily log is invalid: ${verificationErrors.join(', ')}',
              code: 'UPDATED_DAILY_LOG_INVALID',
            ),
          );
        }

        return Right(savedLog);
      });
    } catch (e) {
      return Left(
        DataFailure(
          'Unexpected error updating existing daily log: ${e.toString()}',
          code: 'UPDATE_EXISTING_LOG_ERROR',
        ),
      );
    }
  }

  /// Creates a new daily log
  Future<Either<Failure, DailyLog>> _createNewLog(
    String profileId,
    UpdateDailyStatusParams params,
  ) async {
    try {
      // Create new daily log
      final newLog = DailyLogFactory.create(
        profileId: profileId,
        date: params.date,
        status: params.status,
        notes: params.notes,
      );

      // Validate the new log
      final validationErrors = newLog.validate();
      if (validationErrors.isNotEmpty) {
        return Left(
          ValidationFailure(
            'New daily log validation failed: ${validationErrors.join(', ')}',
            code: 'DAILY_LOG_ENTITY_VALIDATION_FAILED',
          ),
        );
      }

      // Save in repository
      final createResult = await _repository.createDailyLog(newLog);

      return createResult.fold((failure) => Left(failure), (savedLog) {
        // Verify the saved log
        final verificationErrors = savedLog.validate();
        if (verificationErrors.isNotEmpty) {
          return Left(
            DataFailure(
              'Created daily log is invalid: ${verificationErrors.join(', ')}',
              code: 'CREATED_DAILY_LOG_INVALID',
            ),
          );
        }

        return Right(savedLog);
      });
    } catch (e) {
      return Left(
        DataFailure(
          'Unexpected error creating new daily log: ${e.toString()}',
          code: 'CREATE_NEW_LOG_ERROR',
        ),
      );
    }
  }
}
