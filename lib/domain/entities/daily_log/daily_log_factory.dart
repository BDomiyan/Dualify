import '../../../core/constants/domain_constants.dart';
import 'daily_log.dart';
import 'daily_log_status.dart';

/// Factory class for creating DailyLog instances
class DailyLogFactory {
  /// Creates a new daily log entry
  static DailyLog create({
    required String profileId,
    required DateTime date,
    required DailyLogStatus status,
    String? notes,
  }) {
    final now = DateTime.now();
    final id = _generateId();

    return DailyLog(
      id: id,
      profileId: profileId,
      date: DateTime(date.year, date.month, date.day), // Normalize to date only
      status: status,
      notes: notes?.trim(),
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Creates a daily log from existing data (e.g., from database)
  static DailyLog fromData({
    required String id,
    required String profileId,
    required DateTime date,
    required DailyLogStatus status,
    String? notes,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) {
    return DailyLog(
      id: id,
      profileId: profileId,
      date: date,
      status: status,
      notes: notes,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Creates a daily log from string status value
  static DailyLog fromStatusValue({
    required String profileId,
    required DateTime date,
    required String statusValue,
    String? notes,
  }) {
    return create(
      profileId: profileId,
      date: date,
      status: DailyLogStatus.fromValue(statusValue),
      notes: notes,
    );
  }

  /// Generates a unique ID for the daily log
  static String _generateId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = DateTime.now().microsecond;
    return 'log_$timestamp${DomainConstants.idSeparator}$random';
  }
}
