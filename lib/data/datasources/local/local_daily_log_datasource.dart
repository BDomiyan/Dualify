import '../../../core/errors/exceptions.dart';
import '../../../core/utils/logger.dart';
import '../../../domain/entities/entities.dart';
import 'database_helper.dart';

/// Local data source for daily log operations
/// Handles SQLite operations for daily log data with comprehensive error handling
class LocalDailyLogDataSource {
  final DatabaseHelper _databaseHelper;

  const LocalDailyLogDataSource(this._databaseHelper);

  /// Creates a new daily log in the database
  /// Throws DatabaseException if operation fails
  Future<DailyLog> createDailyLog(DailyLog dailyLog) async {
    try {
      AppLogger.debug(
        'Creating daily log: ${dailyLog.id} for date: ${dailyLog.date}',
      );

      // Convert daily log to database format
      final dailyLogData = _dailyLogToMap(dailyLog);

      // Insert into database
      await _databaseHelper.insert(DatabaseHelper.tableDailyLogs, dailyLogData);

      AppLogger.info('Daily log created successfully: ${dailyLog.id}');
      return dailyLog;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to create daily log: ${dailyLog.id}',
        e,
        stackTrace,
      );

      if (e is DatabaseException) {
        rethrow;
      }

      throw DatabaseException(
        'Failed to create daily log: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Gets a daily log by date
  /// Returns null if no log exists for the date
  /// Throws DatabaseException if operation fails
  Future<DailyLog?> getDailyLogByDate(DateTime date) async {
    try {
      final dateOnly = DateTime(date.year, date.month, date.day);
      final timestamp = dateOnly.millisecondsSinceEpoch;

      AppLogger.debug('Retrieving daily log for date: $dateOnly');

      final results = await _databaseHelper.query(
        DatabaseHelper.tableDailyLogs,
        where: 'date = ?',
        whereArgs: [timestamp],
        limit: 1,
      );

      if (results.isEmpty) {
        AppLogger.debug('No daily log found for date: $dateOnly');
        return null;
      }

      final dailyLogData = results.first;
      final dailyLog = _mapToDailyLog(dailyLogData);

      AppLogger.debug('Daily log retrieved successfully: ${dailyLog.id}');
      return dailyLog;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to retrieve daily log for date: $date',
        e,
        stackTrace,
      );

      if (e is DatabaseException) {
        rethrow;
      }

      throw DatabaseException(
        'Failed to retrieve daily log: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Gets daily logs for a date range
  /// Returns empty list if no logs exist in the range
  /// Throws DatabaseException if operation fails
  Future<List<DailyLog>> getDailyLogsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final startDateOnly = DateTime(
        startDate.year,
        startDate.month,
        startDate.day,
      );
      final endDateOnly = DateTime(endDate.year, endDate.month, endDate.day);
      final startTimestamp = startDateOnly.millisecondsSinceEpoch;
      final endTimestamp = endDateOnly.millisecondsSinceEpoch;

      AppLogger.debug(
        'Retrieving daily logs from $startDateOnly to $endDateOnly',
      );

      final results = await _databaseHelper.query(
        DatabaseHelper.tableDailyLogs,
        where: 'date >= ? AND date <= ?',
        whereArgs: [startTimestamp, endTimestamp],
        orderBy: 'date DESC',
      );

      final dailyLogs = results.map(_mapToDailyLog).toList();

      AppLogger.debug(
        'Retrieved ${dailyLogs.length} daily logs for date range',
      );
      return dailyLogs;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to retrieve daily logs for date range: $startDate to $endDate',
        e,
        stackTrace,
      );

      if (e is DatabaseException) {
        rethrow;
      }

      throw DatabaseException(
        'Failed to retrieve daily logs: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Gets all daily logs
  /// Returns empty list if no logs exist
  /// Throws DatabaseException if operation fails
  Future<List<DailyLog>> getAllDailyLogs() async {
    try {
      AppLogger.debug('Retrieving all daily logs');

      final results = await _databaseHelper.query(
        DatabaseHelper.tableDailyLogs,
        orderBy: 'date DESC',
      );

      final dailyLogs = results.map(_mapToDailyLog).toList();

      AppLogger.debug('Retrieved ${dailyLogs.length} daily logs');
      return dailyLogs;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to retrieve all daily logs', e, stackTrace);

      if (e is DatabaseException) {
        rethrow;
      }

      throw DatabaseException(
        'Failed to retrieve all daily logs: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Updates an existing daily log in the database
  /// Throws DatabaseException if operation fails
  Future<DailyLog> updateDailyLog(DailyLog dailyLog) async {
    try {
      AppLogger.debug('Updating daily log: ${dailyLog.id}');

      // Convert daily log to database format
      final dailyLogData = _dailyLogToMap(dailyLog);

      // Update in database
      final rowsAffected = await _databaseHelper.update(
        DatabaseHelper.tableDailyLogs,
        dailyLogData,
        where: 'id = ?',
        whereArgs: [dailyLog.id],
      );

      if (rowsAffected == 0) {
        throw const DatabaseException(
          'Daily log not found for update',
          code: 'DB_007',
        );
      }

      AppLogger.info('Daily log updated successfully: ${dailyLog.id}');
      return dailyLog;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to update daily log: ${dailyLog.id}',
        e,
        stackTrace,
      );

      if (e is DatabaseException) {
        rethrow;
      }

      throw DatabaseException(
        'Failed to update daily log: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Deletes a daily log from the database
  /// Throws DatabaseException if operation fails
  Future<void> deleteDailyLog(String dailyLogId) async {
    try {
      AppLogger.debug('Deleting daily log: $dailyLogId');

      final rowsAffected = await _databaseHelper.delete(
        DatabaseHelper.tableDailyLogs,
        where: 'id = ?',
        whereArgs: [dailyLogId],
      );

      if (rowsAffected == 0) {
        throw const DatabaseException(
          'Daily log not found for deletion',
          code: 'DB_007',
        );
      }

      AppLogger.info('Daily log deleted successfully: $dailyLogId');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to delete daily log: $dailyLogId', e, stackTrace);

      if (e is DatabaseException) {
        rethrow;
      }

      throw DatabaseException(
        'Failed to delete daily log: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Deletes daily logs for a date range
  /// Returns the number of deleted logs
  /// Throws DatabaseException if operation fails
  Future<int> deleteDailyLogsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final startDateOnly = DateTime(
        startDate.year,
        startDate.month,
        startDate.day,
      );
      final endDateOnly = DateTime(endDate.year, endDate.month, endDate.day);
      final startTimestamp = startDateOnly.millisecondsSinceEpoch;
      final endTimestamp = endDateOnly.millisecondsSinceEpoch;

      AppLogger.debug(
        'Deleting daily logs from $startDateOnly to $endDateOnly',
      );

      final rowsAffected = await _databaseHelper.delete(
        DatabaseHelper.tableDailyLogs,
        where: 'date >= ? AND date <= ?',
        whereArgs: [startTimestamp, endTimestamp],
      );

      AppLogger.info('Deleted $rowsAffected daily logs for date range');
      return rowsAffected;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to delete daily logs for date range: $startDate to $endDate',
        e,
        stackTrace,
      );

      if (e is DatabaseException) {
        rethrow;
      }

      throw DatabaseException(
        'Failed to delete daily logs: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Gets daily log statistics for a date range
  /// Throws DatabaseException if operation fails
  Future<DailyLogStatistics> getDailyLogStatistics(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final startDateOnly = DateTime(
        startDate.year,
        startDate.month,
        startDate.day,
      );
      final endDateOnly = DateTime(endDate.year, endDate.month, endDate.day);
      final startTimestamp = startDateOnly.millisecondsSinceEpoch;
      final endTimestamp = endDateOnly.millisecondsSinceEpoch;

      AppLogger.debug(
        'Calculating daily log statistics from $startDateOnly to $endDateOnly',
      );

      final results = await _databaseHelper.query(
        DatabaseHelper.tableDailyLogs,
        where: 'date >= ? AND date <= ?',
        whereArgs: [startTimestamp, endTimestamp],
      );

      final dailyLogs = results.map(_mapToDailyLog).toList();
      final statistics = DailyLogUtils.calculateStatistics(dailyLogs);

      AppLogger.debug(
        'Calculated statistics for ${dailyLogs.length} daily logs',
      );
      return statistics;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to calculate daily log statistics',
        e,
        stackTrace,
      );

      if (e is DatabaseException) {
        rethrow;
      }

      throw DatabaseException(
        'Failed to calculate daily log statistics: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Converts DailyLog entity to database map
  Map<String, dynamic> _dailyLogToMap(DailyLog dailyLog) {
    return {
      'id': dailyLog.id,
      'profile_id': dailyLog.profileId,
      'date': dailyLog.dateOnly.millisecondsSinceEpoch,
      'status': dailyLog.status.value,
      'notes': dailyLog.notes,
      'created_at': dailyLog.createdAt.millisecondsSinceEpoch,
      'updated_at': dailyLog.updatedAt.millisecondsSinceEpoch,
    };
  }

  /// Converts database map to DailyLog entity
  DailyLog _mapToDailyLog(Map<String, dynamic> map) {
    try {
      return DailyLogFactory.fromData(
        id: map['id'] as String,
        profileId: map['profile_id'] as String,
        date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
        status: DailyLogStatus.fromValue(map['status'] as String),
        notes: map['notes'] as String?,
        createdAt: DateTime.fromMillisecondsSinceEpoch(
          map['created_at'] as int,
        ),
        updatedAt: DateTime.fromMillisecondsSinceEpoch(
          map['updated_at'] as int,
        ),
      );
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to convert database map to daily log',
        e,
        stackTrace,
      );
      throw DataException.transformationFailed('Daily log data mapping', e);
    }
  }
}
