import '../../../core/errors/exceptions.dart';
import '../../../core/utils/logger.dart';
import '../../../domain/entities/entities.dart';
import 'database_helper.dart';

/// Local data source for apprentice profile operations
/// Handles SQLite operations for profile data with comprehensive error handling
class LocalProfileDataSource {
  final DatabaseHelper _databaseHelper;

  const LocalProfileDataSource(this._databaseHelper);

  /// Creates a new profile in the database
  /// Throws DatabaseException if operation fails
  Future<ApprenticeProfile> createProfile(ApprenticeProfile profile) async {
    try {
      AppLogger.debug('Creating profile: ${profile.id}');

      // Convert profile to database format
      final profileData = _profileToMap(profile);

      // Insert into database
      await _databaseHelper.insert(DatabaseHelper.tableProfiles, profileData);

      AppLogger.info('Profile created successfully: ${profile.id}');
      return profile;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to create profile: ${profile.id}', e, stackTrace);

      if (e is DatabaseException) {
        rethrow;
      }

      throw DatabaseException(
        'Failed to create profile: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Gets the profile from the database
  /// Returns null if no profile exists
  /// Throws DatabaseException if operation fails
  Future<ApprenticeProfile?> getProfile() async {
    try {
      AppLogger.debug('Retrieving profile from database');

      final results = await _databaseHelper.query(
        DatabaseHelper.tableProfiles,
        limit: 1,
      );

      if (results.isEmpty) {
        AppLogger.debug('No profile found in database');
        return null;
      }

      final profileData = results.first;
      final profile = _mapToProfile(profileData);

      AppLogger.debug('Profile retrieved successfully: ${profile.id}');
      return profile;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to retrieve profile', e, stackTrace);

      if (e is DatabaseException) {
        rethrow;
      }

      throw DatabaseException(
        'Failed to retrieve profile: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Updates an existing profile in the database
  /// Throws DatabaseException if operation fails
  Future<ApprenticeProfile> updateProfile(ApprenticeProfile profile) async {
    try {
      AppLogger.debug('Updating profile: ${profile.id}');

      // Convert profile to database format
      final profileData = _profileToMap(profile);

      // Update in database
      final rowsAffected = await _databaseHelper.update(
        DatabaseHelper.tableProfiles,
        profileData,
        where: 'id = ?',
        whereArgs: [profile.id],
      );

      if (rowsAffected == 0) {
        throw const DatabaseException(
          'Profile not found for update',
          code: 'DB_007',
        );
      }

      AppLogger.info('Profile updated successfully: ${profile.id}');
      return profile;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to update profile: ${profile.id}', e, stackTrace);

      if (e is DatabaseException) {
        rethrow;
      }

      throw DatabaseException(
        'Failed to update profile: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Deletes the profile from the database
  /// Throws DatabaseException if operation fails
  Future<void> deleteProfile() async {
    try {
      AppLogger.debug('Deleting profile from database');

      final rowsAffected = await _databaseHelper.delete(
        DatabaseHelper.tableProfiles,
      );

      AppLogger.info(
        'Profile deleted successfully. Rows affected: $rowsAffected',
      );
    } catch (e, stackTrace) {
      AppLogger.error('Failed to delete profile', e, stackTrace);

      if (e is DatabaseException) {
        rethrow;
      }

      throw DatabaseException(
        'Failed to delete profile: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Checks if a profile exists in the database
  /// Throws DatabaseException if operation fails
  Future<bool> hasProfile() async {
    try {
      AppLogger.debug('Checking if profile exists');

      final results = await _databaseHelper.query(
        DatabaseHelper.tableProfiles,
        columns: ['id'],
        limit: 1,
      );

      final exists = results.isNotEmpty;
      AppLogger.debug('Profile exists: $exists');
      return exists;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to check profile existence', e, stackTrace);

      if (e is DatabaseException) {
        rethrow;
      }

      throw DatabaseException(
        'Failed to check profile existence: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Converts ApprenticeProfile entity to database map
  Map<String, dynamic> _profileToMap(ApprenticeProfile profile) {
    return {
      'id': profile.id,
      'first_name': profile.firstName,
      'last_name': profile.lastName,
      'trade': profile.trade,
      'apprenticeship_start_date':
          profile.apprenticeshipStartDate.millisecondsSinceEpoch,
      'apprenticeship_end_date':
          profile.apprenticeshipEndDate.millisecondsSinceEpoch,
      'company_name': profile.companyName,
      'school_name': profile.schoolName,
      'email': profile.email,
      'phone': profile.phone,
      'is_company_verified': profile.isCompanyVerified ? 1 : 0,
      'is_school_verified': profile.isSchoolVerified ? 1 : 0,
      'created_at': profile.createdAt.millisecondsSinceEpoch,
      'updated_at': profile.updatedAt.millisecondsSinceEpoch,
    };
  }

  /// Converts database map to ApprenticeProfile entity
  ApprenticeProfile _mapToProfile(Map<String, dynamic> map) {
    try {
      return ApprenticeProfileFactory.fromData(
        id: map['id'] as String,
        firstName: map['first_name'] as String,
        lastName: map['last_name'] as String,
        trade: map['trade'] as String,
        apprenticeshipStartDate: DateTime.fromMillisecondsSinceEpoch(
          map['apprenticeship_start_date'] as int,
        ),
        apprenticeshipEndDate: DateTime.fromMillisecondsSinceEpoch(
          map['apprenticeship_end_date'] as int,
        ),
        companyName: map['company_name'] as String?,
        schoolName: map['school_name'] as String?,
        email: map['email'] as String?,
        phone: map['phone'] as String?,
        isCompanyVerified: (map['is_company_verified'] as int) == 1,
        isSchoolVerified: (map['is_school_verified'] as int) == 1,
        createdAt: DateTime.fromMillisecondsSinceEpoch(
          map['created_at'] as int,
        ),
        updatedAt: DateTime.fromMillisecondsSinceEpoch(
          map['updated_at'] as int,
        ),
      );
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to convert database map to profile',
        e,
        stackTrace,
      );
      throw DataException.transformationFailed('Profile data mapping', e);
    }
  }
}
