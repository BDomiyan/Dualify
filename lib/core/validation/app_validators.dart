import '../constants/app_strings.dart';
import 'validation.dart';

/// Application-specific form validators
/// Contains pre-configured validators for common app forms
class AppValidators {
  /// Validator for onboarding form
  static final FormValidator onboarding =
      FormValidatorBuilder()
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
          .addRequiredField(
            'apprenticeshipStartDate',
            ValidationRules.date(
              'Apprenticeship Start Date',
              allowFuture: false, // Cannot start in the future
              minDate: DateTime.now().subtract(
                const Duration(days: 365 * 10),
              ), // Max 10 years ago
            ),
          )
          .addRequiredField(
            'apprenticeshipEndDate',
            ValidationRules.date(
              'Apprenticeship End Date',
              allowPast: false, // Cannot end in the past
              maxDate: DateTime.now().add(
                const Duration(days: 365 * 10),
              ), // Max 10 years from now
            ),
          )
          .addOptionalField('companyName', [
            LengthRule('Company Name', maxLength: 100),
          ])
          .addOptionalField('schoolName', [
            LengthRule('School Name', maxLength: 100),
          ])
          .addFormRule(
            CustomRule(
              'Date Range',
              (formData) {
                final startDate =
                    formData['apprenticeshipStartDate'] as DateTime?;
                final endDate = formData['apprenticeshipEndDate'] as DateTime?;

                if (startDate != null && endDate != null) {
                  if (endDate.isBefore(startDate) ||
                      endDate.isAtSameMomentAs(startDate)) {
                    return 'Apprenticeship end date must be after start date';
                  }

                  // Check minimum duration (e.g., 6 months)
                  final minDuration = const Duration(days: 180);
                  if (endDate.difference(startDate) < minDuration) {
                    return 'Apprenticeship must be at least 6 months long';
                  }

                  // Check maximum duration (e.g., 8 years)
                  final maxDuration = const Duration(days: 365 * 8);
                  if (endDate.difference(startDate) > maxDuration) {
                    return 'Apprenticeship cannot exceed 8 years';
                  }
                }

                return null;
              },
              'validation.dateRange',
              'End date must be after start date with reasonable duration',
            ),
          )
          .build();

  /// Validator for profile editing form
  static final FormValidator profileEdit =
      FormValidatorBuilder()
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
          .addOptionalField('phone', [
            PatternRule(
              'Phone',
              RegExp(r'^\+?[\d\s\-\(\)]{10,}$'),
              'must be a valid phone number',
            ),
          ])
          .build();

  /// Validator for daily log status updates
  static final FormValidator dailyLogStatus =
      FormValidatorBuilder()
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

  /// Validator for question responses
  static final FormValidator questionResponse =
      FormValidatorBuilder()
          .addRequiredField('response', [
            LengthRule('Response', minLength: 10, maxLength: 1000),
          ])
          .addOptionalField(
            'category',
            ValidationRules.selection('Category', [
              'learning',
              'problem-solving',
              'achievement',
              'reflection',
            ], required: false),
          )
          .build();

  /// Validator for company verification
  static final FormValidator companyVerification =
      FormValidatorBuilder()
          .addRequiredField('companyName', [
            LengthRule('Company Name', minLength: 2, maxLength: 100),
          ])
          .addRequiredField('supervisorName', [
            LengthRule('Supervisor Name', minLength: 2, maxLength: 100),
          ])
          .addRequiredField(
            'supervisorEmail',
            ValidationRules.email('Supervisor Email'),
          )
          .addOptionalField('supervisorPhone', [
            PatternRule(
              'Supervisor Phone',
              RegExp(r'^\+?[\d\s\-\(\)]{10,}$'),
              'must be a valid phone number',
            ),
          ])
          .addOptionalField('companyAddress', [
            LengthRule('Company Address', maxLength: 200),
          ])
          .build();

  /// Validator for school verification
  static final FormValidator schoolVerification =
      FormValidatorBuilder()
          .addRequiredField('schoolName', [
            LengthRule('School Name', minLength: 2, maxLength: 100),
          ])
          .addRequiredField('instructorName', [
            LengthRule('Instructor Name', minLength: 2, maxLength: 100),
          ])
          .addRequiredField(
            'instructorEmail',
            ValidationRules.email('Instructor Email'),
          )
          .addOptionalField('instructorPhone', [
            PatternRule(
              'Instructor Phone',
              RegExp(r'^\+?[\d\s\-\(\)]{10,}$'),
              'must be a valid phone number',
            ),
          ])
          .addOptionalField('schoolAddress', [
            LengthRule('School Address', maxLength: 200),
          ])
          .addRequiredField('programName', [
            LengthRule('Program Name', minLength: 2, maxLength: 100),
          ])
          .build();
}

/// Validation utilities for common app scenarios
class ValidationUtils {
  /// Validates apprenticeship date range
  static String? validateApprenticeshipDates(
    DateTime? startDate,
    DateTime? endDate,
  ) {
    if (startDate == null || endDate == null) {
      return null; // Let individual field validators handle null values
    }

    if (endDate.isBefore(startDate) || endDate.isAtSameMomentAs(startDate)) {
      return 'End date must be after start date';
    }

    // Check minimum duration (6 months)
    final minDuration = const Duration(days: 180);
    if (endDate.difference(startDate) < minDuration) {
      return 'Apprenticeship must be at least 6 months long';
    }

    // Check maximum duration (8 years)
    final maxDuration = const Duration(days: 365 * 8);
    if (endDate.difference(startDate) > maxDuration) {
      return 'Apprenticeship cannot exceed 8 years';
    }

    return null;
  }

  /// Validates that a date is within apprenticeship period
  static String? validateDateWithinApprenticeship(
    DateTime? date,
    DateTime? apprenticeshipStart,
    DateTime? apprenticeshipEnd,
  ) {
    if (date == null ||
        apprenticeshipStart == null ||
        apprenticeshipEnd == null) {
      return null;
    }

    if (date.isBefore(apprenticeshipStart)) {
      return 'Date cannot be before apprenticeship start date';
    }

    if (date.isAfter(apprenticeshipEnd)) {
      return 'Date cannot be after apprenticeship end date';
    }

    return null;
  }

  /// Validates trade selection
  static String? validateTrade(String? trade) {
    if (trade == null || trade.isEmpty) {
      return 'Please select a trade';
    }

    if (!AppStrings.tradeOptions.contains(trade)) {
      return 'Please select a valid trade';
    }

    return null;
  }

  /// Validates daily log status
  static String? validateDailyStatus(String? status) {
    const validStatuses = ['learning', 'challenging', 'neutral', 'good'];

    if (status == null || status.isEmpty) {
      return 'Please select a status';
    }

    if (!validStatuses.contains(status)) {
      return 'Please select a valid status';
    }

    return null;
  }
}
