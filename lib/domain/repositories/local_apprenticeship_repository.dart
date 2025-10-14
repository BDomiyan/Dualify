import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../entities/entities.dart';

/// Repository interface for local apprenticeship data operations
/// Follows Repository Pattern and Dependency Inversion Principle
/// Uses Either type for functional error handling
abstract class ILocalApprenticeshipRepository {
  // Profile Management

  /// Creates a new apprentice profile
  /// Returns the created profile or a failure
  Future<Either<Failure, ApprenticeProfile>> createProfile(
    ApprenticeProfile profile,
  );

  /// Gets the current apprentice profile
  /// Returns the profile if exists, null if not found, or a failure
  Future<Either<Failure, ApprenticeProfile?>> getProfile();

  /// Updates an existing apprentice profile
  /// Returns the updated profile or a failure
  Future<Either<Failure, ApprenticeProfile>> updateProfile(
    ApprenticeProfile profile,
  );

  /// Deletes the apprentice profile
  /// Returns success (unit) or a failure
  Future<Either<Failure, Unit>> deleteProfile();

  /// Checks if a profile exists
  /// Returns true if profile exists, false otherwise, or a failure
  Future<Either<Failure, bool>> hasProfile();

  // Daily Log Management

  /// Creates a new daily log entry
  /// Returns the created log entry or a failure
  Future<Either<Failure, DailyLog>> createDailyLog(DailyLog dailyLog);

  /// Gets a daily log entry for a specific date
  /// Returns the log entry if exists, null if not found, or a failure
  Future<Either<Failure, DailyLog?>> getDailyLogByDate(DateTime date);

  /// Gets daily log entries for a date range
  /// Returns list of log entries (may be empty) or a failure
  Future<Either<Failure, List<DailyLog>>> getDailyLogsByDateRange(
    DateTime startDate,
    DateTime endDate,
  );

  /// Gets all daily log entries for the current profile
  /// Returns list of log entries (may be empty) or a failure
  Future<Either<Failure, List<DailyLog>>> getAllDailyLogs();

  /// Updates an existing daily log entry
  /// Returns the updated log entry or a failure
  Future<Either<Failure, DailyLog>> updateDailyLog(DailyLog dailyLog);

  /// Deletes a daily log entry
  /// Returns success (unit) or a failure
  Future<Either<Failure, Unit>> deleteDailyLog(String dailyLogId);

  /// Deletes daily log entries for a date range
  /// Returns the number of deleted entries or a failure
  Future<Either<Failure, int>> deleteDailyLogsByDateRange(
    DateTime startDate,
    DateTime endDate,
  );

  /// Gets daily log statistics for a date range
  /// Returns statistics or a failure
  Future<Either<Failure, DailyLogStatistics>> getDailyLogStatistics(
    DateTime startDate,
    DateTime endDate,
  );

  // Question of the Day Management

  /// Saves a question of the day with response
  /// Returns the saved question or a failure
  Future<Either<Failure, QuestionOfTheDay>> saveQuestionResponse(
    QuestionOfTheDay question,
  );

  /// Gets a question response by question ID
  /// Returns the question if exists, null if not found, or a failure
  Future<Either<Failure, QuestionOfTheDay?>> getQuestionResponse(
    String questionId,
  );

  /// Gets all answered questions
  /// Returns list of answered questions (may be empty) or a failure
  Future<Either<Failure, List<QuestionOfTheDay>>> getAnsweredQuestions();

  /// Gets answered questions for a date range
  /// Returns list of answered questions (may be empty) or a failure
  Future<Either<Failure, List<QuestionOfTheDay>>>
  getAnsweredQuestionsByDateRange(DateTime startDate, DateTime endDate);

  /// Deletes a question response
  /// Returns success (unit) or a failure
  Future<Either<Failure, Unit>> deleteQuestionResponse(String questionId);

  /// Gets question response statistics
  /// Returns statistics or a failure
  Future<Either<Failure, QuestionResponseStatistics>>
  getQuestionResponseStatistics();

  // Data Management

  /// Exports all data as JSON
  /// Returns JSON string or a failure
  Future<Either<Failure, String>> exportData();

  /// Imports data from JSON
  /// Returns success (unit) or a failure
  Future<Either<Failure, Unit>> importData(String jsonData);

  /// Clears all data (for testing or reset)
  /// Returns success (unit) or a failure
  Future<Either<Failure, Unit>> clearAllData();

  /// Gets database statistics
  /// Returns statistics or a failure
  Future<Either<Failure, DatabaseStatistics>> getDatabaseStatistics();
}

/// Statistics for question responses
class QuestionResponseStatistics {
  final int totalQuestions;
  final int answeredQuestions;
  final Map<QuestionCategory, int> answersByCategory;
  final double averageResponseLength;
  final DateTime? lastResponseDate;

  const QuestionResponseStatistics({
    required this.totalQuestions,
    required this.answeredQuestions,
    required this.answersByCategory,
    required this.averageResponseLength,
    this.lastResponseDate,
  });

  /// Gets the response rate as a percentage (0.0 to 1.0)
  double get responseRate =>
      totalQuestions > 0 ? answeredQuestions / totalQuestions : 0.0;

  /// Gets the most active category
  QuestionCategory? get mostActiveCategory {
    if (answersByCategory.isEmpty) return null;

    var maxCount = 0;
    QuestionCategory? mostActive;

    for (final entry in answersByCategory.entries) {
      if (entry.value > maxCount) {
        maxCount = entry.value;
        mostActive = entry.key;
      }
    }

    return mostActive;
  }
}

/// Database statistics
class DatabaseStatistics {
  final int profileCount;
  final int dailyLogCount;
  final int questionResponseCount;
  final DateTime? oldestEntry;
  final DateTime? newestEntry;
  final int databaseSizeBytes;

  const DatabaseStatistics({
    required this.profileCount,
    required this.dailyLogCount,
    required this.questionResponseCount,
    this.oldestEntry,
    this.newestEntry,
    required this.databaseSizeBytes,
  });

  /// Gets the total number of entries
  int get totalEntries => profileCount + dailyLogCount + questionResponseCount;

  /// Gets the database size in a human-readable format
  String get databaseSizeFormatted {
    if (databaseSizeBytes < 1024) {
      return '$databaseSizeBytes B';
    } else if (databaseSizeBytes < 1024 * 1024) {
      return '${(databaseSizeBytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(databaseSizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  /// Gets the data span in days
  int? get dataSpanDays {
    if (oldestEntry == null || newestEntry == null) return null;
    return newestEntry!.difference(oldestEntry!).inDays;
  }
}
