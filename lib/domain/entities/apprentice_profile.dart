import 'package:equatable/equatable.dart';

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
      companyName?.isNotEmpty == true ? companyName! : 'Not specified';

  /// Gets the display name for the school (or "Not specified")
  String get schoolDisplayName =>
      schoolName?.isNotEmpty == true ? schoolName! : 'Not specified';

  /// Calculates the total duration of the apprenticeship in days
  int get apprenticeshipDurationDays =>
      apprenticeshipEndDate.difference(apprenticeshipStartDate).inDays;

  /// Calculates the total duration of the apprenticeship in months (approximate)
  int get apprenticeshipDurationMonths =>
      (apprenticeshipDurationDays / 30.44).round(); // Average days per month

  /// Calculates the total duration of the apprenticeship in years (approximate)
  double get apprenticeshipDurationYears =>
      apprenticeshipDurationDays / 365.25; // Account for leap years

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
      errors.add('First name is required');
    }

    if (lastName.trim().isEmpty) {
      errors.add('Last name is required');
    }

    if (trade.trim().isEmpty) {
      errors.add('Trade is required');
    }

    if (apprenticeshipEndDate.isBefore(apprenticeshipStartDate)) {
      errors.add('Apprenticeship end date must be after start date');
    }

    // Validate minimum duration (6 months)
    final minDuration = const Duration(days: 180);
    if (apprenticeshipEndDate.difference(apprenticeshipStartDate) <
        minDuration) {
      errors.add('Apprenticeship must be at least 6 months long');
    }

    // Validate maximum duration (8 years)
    final maxDuration = const Duration(days: 365 * 8);
    if (apprenticeshipEndDate.difference(apprenticeshipStartDate) >
        maxDuration) {
      errors.add('Apprenticeship cannot exceed 8 years');
    }

    // Validate email format if provided
    if (email != null && email!.isNotEmpty) {
      final emailRegex = RegExp(
        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
      );
      if (!emailRegex.hasMatch(email!)) {
        errors.add('Invalid email format');
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

/// Enumeration for apprenticeship status
enum ApprenticeshipStatus {
  notStarted('Not Started'),
  active('Active'),
  completed('Completed');

  const ApprenticeshipStatus(this.displayName);
  final String displayName;
}

/// Factory class for creating ApprenticeProfile instances
class ApprenticeProfileFactory {
  /// Creates a new profile with generated ID and timestamps
  static ApprenticeProfile create({
    required String firstName,
    required String lastName,
    required String trade,
    required DateTime apprenticeshipStartDate,
    required DateTime apprenticeshipEndDate,
    String? companyName,
    String? schoolName,
    String? email,
    String? phone,
  }) {
    final now = DateTime.now();
    final id = _generateId();

    return ApprenticeProfile(
      id: id,
      firstName: firstName.trim(),
      lastName: lastName.trim(),
      trade: trade.trim(),
      apprenticeshipStartDate: apprenticeshipStartDate,
      apprenticeshipEndDate: apprenticeshipEndDate,
      companyName: companyName?.trim(),
      schoolName: schoolName?.trim(),
      email: email?.trim(),
      phone: phone?.trim(),
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Creates a profile from existing data (e.g., from database)
  static ApprenticeProfile fromData({
    required String id,
    required String firstName,
    required String lastName,
    required String trade,
    required DateTime apprenticeshipStartDate,
    required DateTime apprenticeshipEndDate,
    String? companyName,
    String? schoolName,
    String? email,
    String? phone,
    bool isCompanyVerified = false,
    bool isSchoolVerified = false,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) {
    return ApprenticeProfile(
      id: id,
      firstName: firstName,
      lastName: lastName,
      trade: trade,
      apprenticeshipStartDate: apprenticeshipStartDate,
      apprenticeshipEndDate: apprenticeshipEndDate,
      companyName: companyName,
      schoolName: schoolName,
      email: email,
      phone: phone,
      isCompanyVerified: isCompanyVerified,
      isSchoolVerified: isSchoolVerified,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Generates a unique ID for the profile
  static String _generateId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = DateTime.now().microsecond;
    return 'profile_${timestamp}_$random';
  }
}
