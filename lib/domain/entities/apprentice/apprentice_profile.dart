import 'package:equatable/equatable.dart';

import '../../../core/constants/domain_constants.dart';
import 'apprenticeship_status.dart';

/// Core domain entity representing an apprentice's profile
/// Immutable entity following Domain-Driven Design principles
class ApprenticeProfile extends Equatable {
  final String id;
  final String firstName;
  final String lastName;
  final String trade;
  final DateTime apprenticeshipStartDate;
  final DateTime apprenticeshipEndDate;
  final String? companyName;
  final String? schoolName;
  final String? email;
  final String? phone;
  final bool isCompanyVerified;
  final bool isSchoolVerified;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ApprenticeProfile({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.trade,
    required this.apprenticeshipStartDate,
    required this.apprenticeshipEndDate,
    this.companyName,
    this.schoolName,
    this.email,
    this.phone,
    this.isCompanyVerified = false,
    this.isSchoolVerified = false,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates a copy of this profile with updated fields
  ApprenticeProfile copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? trade,
    DateTime? apprenticeshipStartDate,
    DateTime? apprenticeshipEndDate,
    String? companyName,
    String? schoolName,
    String? email,
    String? phone,
    bool? isCompanyVerified,
    bool? isSchoolVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ApprenticeProfile(
      id: id ?? this.id,
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
      isCompanyVerified: isCompanyVerified ?? this.isCompanyVerified,
      isSchoolVerified: isSchoolVerified ?? this.isSchoolVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Gets the full name of the apprentice
  String get fullName => '$firstName $lastName';

  /// Gets the display name for the company (or "Not specified")
  String get companyDisplayName =>
      companyName?.isNotEmpty == true
          ? companyName!
          : DomainConstants.notSpecifiedLabel;

  /// Gets the display name for the school (or "Not specified")
  String get schoolDisplayName =>
      schoolName?.isNotEmpty == true
          ? schoolName!
          : DomainConstants.notSpecifiedLabel;

  /// Calculates the total duration of the apprenticeship in days
  int get apprenticeshipDurationDays =>
      apprenticeshipEndDate.difference(apprenticeshipStartDate).inDays;

  /// Calculates the total duration of the apprenticeship in months (approximate)
  int get apprenticeshipDurationMonths =>
      (apprenticeshipDurationDays / DomainConstants.daysPerMonth).round();

  /// Calculates the total duration of the apprenticeship in years (approximate)
  double get apprenticeshipDurationYears =>
      apprenticeshipDurationDays / DomainConstants.daysPerYear;

  /// Calculates days elapsed since apprenticeship start
  int get daysElapsed {
    final now = DateTime.now();
    if (now.isBefore(apprenticeshipStartDate)) return 0;
    if (now.isAfter(apprenticeshipEndDate)) return apprenticeshipDurationDays;
    return now.difference(apprenticeshipStartDate).inDays;
  }

  /// Calculates days remaining until apprenticeship end
  int get daysRemaining {
    final now = DateTime.now();
    if (now.isBefore(apprenticeshipStartDate)) {
      return apprenticeshipDurationDays;
    }
    if (now.isAfter(apprenticeshipEndDate)) return 0;
    return apprenticeshipEndDate.difference(now).inDays;
  }

  /// Calculates progress percentage (0.0 to 1.0)
  double get progressPercentage {
    if (apprenticeshipDurationDays == 0) return 0.0;
    return (daysElapsed / apprenticeshipDurationDays).clamp(0.0, 1.0);
  }

  /// Checks if the apprenticeship has started
  bool get hasStarted => DateTime.now().isAfter(apprenticeshipStartDate);

  /// Checks if the apprenticeship has ended
  bool get hasEnded => DateTime.now().isAfter(apprenticeshipEndDate);

  /// Checks if the apprenticeship is currently active
  bool get isActive => hasStarted && !hasEnded;

  /// Gets the apprenticeship status
  ApprenticeshipStatus get status {
    if (!hasStarted) return ApprenticeshipStatus.notStarted;
    if (hasEnded) return ApprenticeshipStatus.completed;
    return ApprenticeshipStatus.active;
  }

  /// Validates the profile data
  List<String> validate() {
    final errors = <String>[];

    if (firstName.trim().isEmpty) {
      errors.add(DomainConstants.errorFirstNameRequired);
    }

    if (lastName.trim().isEmpty) {
      errors.add(DomainConstants.errorLastNameRequired);
    }

    if (trade.trim().isEmpty) {
      errors.add(DomainConstants.errorTradeRequired);
    }

    if (apprenticeshipEndDate.isBefore(apprenticeshipStartDate)) {
      errors.add(DomainConstants.errorInvalidDateRange);
    }

    // Validate minimum duration (6 months)
    final minDuration = const Duration(
      days: DomainConstants.minApprenticeDurationDays,
    );
    if (apprenticeshipEndDate.difference(apprenticeshipStartDate) <
        minDuration) {
      errors.add(DomainConstants.errorDurationTooShort);
    }

    // Validate maximum duration (8 years)
    final maxDuration = const Duration(
      days: DomainConstants.maxApprenticeDurationDays,
    );
    if (apprenticeshipEndDate.difference(apprenticeshipStartDate) >
        maxDuration) {
      errors.add(DomainConstants.errorDurationTooLong);
    }

    // Validate email format if provided
    if (email != null && email!.isNotEmpty) {
      final emailRegex = RegExp(DomainConstants.emailRegexPattern);
      if (!emailRegex.hasMatch(email!)) {
        errors.add(DomainConstants.errorInvalidEmail);
      }
    }

    return errors;
  }

  /// Checks if the profile is valid
  bool get isValid => validate().isEmpty;

  @override
  List<Object?> get props => [
    id,
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
    createdAt,
    updatedAt,
  ];

  @override
  String toString() =>
      'ApprenticeProfile(id: $id, name: $fullName, trade: $trade)';
}
