import '../../../core/constants/domain_constants.dart';
import 'apprentice_profile.dart';

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
    return 'profile_$timestamp${DomainConstants.idSeparator}$random';
  }
}
