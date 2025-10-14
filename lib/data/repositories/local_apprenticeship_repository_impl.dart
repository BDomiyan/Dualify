import 'dart:convert';

import 'package:dartz/dartz.dart';

import '../../core/errors/error_handler.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/logger.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/repositories.dart';
import '../datasources/local/local_datasources.dart';

/// Implementation of ILocalApprenticeshipRepository
/// Handles all local data operations with comprehensive error handling
class LocalApprenticeshipRepositoryImpl
    implements ILocalApprenticeshipRepository {
  final LocalProfileDataSource _profileDataSource;
  final LocalDailyLogDataSource _dailyLogDataSource;
  final LocalQuestionDataSource _questionDataSource;

  const LocalApprenticeshipRepositoryImpl(
    this._profileDataSource,
    this._dailyLogDataSource,
    this._questionDataSource,
  );

  // Profile Management

  @override
  Future<Either<Failure, ApprenticeProfile>> createProfile(
    ApprenticeProfile profile,
  ) async {
    try {
      AppLogger.info('Creating profile: ${profile.id}');

      final result = await _profileDataSource.createProfile(profile);

      AppLogger.info('Profile created successfully: ${profile.id}');
      return Right(result);
    } catch (e) {
      AppLogger.error('Failed to create profile: ${profile.id}', e);
      return Left(ErrorHandler.handleException(e as Exception));
    }
  }

  @override
  Future<Either<Failure, ApprenticeProfile?>> getProfile() async {
    try {
      AppLogger.debug('Retrieving profile');

      final result = await _profileDataSource.getProfile();

      AppLogger.debug('Profile retrieved: ${result?.id ?? 'none'}');
      return Right(result);
    } catch (e) {
      AppLogger.error('Failed to retrieve profile', e);
      return Left(ErrorHandler.handleException(e as Exception));
    }
  }

  @override
  Future<Either<Failure, ApprenticeProfile>> updateProfile(
    ApprenticeProfile profile,
  ) async {
    try {
      AppLogger.info('Updating profile: ${profile.id}');

      final result = await _profileDataSource.updateProfile(profile);

      AppLogger.info('Profile updated successfully: ${profile.id}');
      return Right(result);
    } catch (e) {
      AppLogger.error('Failed to update profile: ${profile.id}', e);
      return Left(ErrorHandler.handleException(e as Exception));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteProfile() async {
    try {
      AppLogger.info('Deleting profile');

      await _profileDataSource.deleteProfile();

      AppLogger.info('Profile deleted successfully');
      return const Right(unit);
    } catch (e) {
      AppLogger.error('Failed to delete profile', e);
      return Left(ErrorHandler.handleException(e as Exception));
    }
  }

  @override
  Future<Either<Failure, bool>> hasProfile() async {
    try {
      AppLogger.debug('Checking if profile exists');

      final result = await _profileDataSource.hasProfile();

      AppLogger.debug('Profile exists: $result');
      return Right(result);
    } catch (e) {
      AppLogger.error('Failed to check profile existence', e);
      return Left(ErrorHandler.handleException(e as Exception));
    }
  }

  // Daily Log Management

  @override
  Future<Either<Failure, DailyLog>> createDailyLog(DailyLog dailyLog) async {
    try {
      AppLogger.info(
        'Creating daily log: ${dailyLog.id} for ${dailyLog.dateDisplayText}',
      );

      final result = await _dailyLogDataSource.createDailyLog(dailyLog);

      AppLogger.info('Daily log created successfully: ${dailyLog.id}');
      return Right(result);
    } catch (e) {
      AppLogger.error('Failed to create daily log: ${dailyLog.id}', e);
      return Left(ErrorHandler.handleException(e as Exception));
    }
  }

  @override
  Future<Either<Failure, DailyLog?>> getDailyLogByDate(DateTime date) async {
    try {
      AppLogger.debug('Retrieving daily log for date: $date');

      final result = await _dailyLogDataSource.getDailyLogByDate(date);

      AppLogger.debug('Daily log retrieved for $date: ${result?.id ?? 'none'}');
      return Right(result);
    } catch (e) {
      AppLogger.error('Failed to retrieve daily log for date: $date', e);
      return Left(ErrorHandler.handleException(e as Exception));
    }
  }

  @override
  Future<Either<Failure, List<DailyLog>>> getDailyLogsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      AppLogger.debug('Retrieving daily logs from $startDate to $endDate');

      final result = await _dailyLogDataSource.getDailyLogsByDateRange(
        startDate,
        endDate,
      );

      AppLogger.debug('Retrieved ${result.length} daily logs for date range');
      return Right(result);
    } catch (e) {
      AppLogger.error(
        'Failed to retrieve daily logs for date range: $startDate to $endDate',
        e,
      );
      return Left(ErrorHandler.handleException(e as Exception));
    }
  }

  @override
  Future<Either<Failure, List<DailyLog>>> getAllDailyLogs() async {
    try {
      AppLogger.debug('Retrieving all daily logs');

      final result = await _dailyLogDataSource.getAllDailyLogs();

      AppLogger.debug('Retrieved ${result.length} daily logs');
      return Right(result);
    } catch (e) {
      AppLogger.error('Failed to retrieve all daily logs', e);
      return Left(ErrorHandler.handleException(e as Exception));
    }
  }

  @override
  Future<Either<Failure, DailyLog>> updateDailyLog(DailyLog dailyLog) async {
    try {
      AppLogger.info('Updating daily log: ${dailyLog.id}');

      final result = await _dailyLogDataSource.updateDailyLog(dailyLog);

      AppLogger.info('Daily log updated successfully: ${dailyLog.id}');
      return Right(result);
    } catch (e) {
      AppLogger.error('Failed to update daily log: ${dailyLog.id}', e);
      return Left(ErrorHandler.handleException(e as Exception));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteDailyLog(String dailyLogId) async {
    try {
      AppLogger.info('Deleting daily log: $dailyLogId');

      await _dailyLogDataSource.deleteDailyLog(dailyLogId);

      AppLogger.info('Daily log deleted successfully: $dailyLogId');
      return const Right(unit);
    } catch (e) {
      AppLogger.error('Failed to delete daily log: $dailyLogId', e);
      return Left(ErrorHandler.handleException(e as Exception));
    }
  }

  @override
  Future<Either<Failure, int>> deleteDailyLogsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      AppLogger.info('Deleting daily logs from $startDate to $endDate');

      final result = await _dailyLogDataSource.deleteDailyLogsByDateRange(
        startDate,
        endDate,
      );

      AppLogger.info('Deleted $result daily logs for date range');
      return Right(result);
    } catch (e) {
      AppLogger.error(
        'Failed to delete daily logs for date range: $startDate to $endDate',
        e,
      );
      return Left(ErrorHandler.handleException(e as Exception));
    }
  }

  @override
  Future<Either<Failure, DailyLogStatistics>> getDailyLogStatistics(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      AppLogger.debug(
        'Calculating daily log statistics from $startDate to $endDate',
      );

      final result = await _dailyLogDataSource.getDailyLogStatistics(
        startDate,
        endDate,
      );

      AppLogger.debug(
        'Calculated daily log statistics: ${result.totalDays} total days',
      );
      return Right(result);
    } catch (e) {
      AppLogger.error('Failed to calculate daily log statistics', e);
      return Left(ErrorHandler.handleException(e as Exception));
    }
  }

  // Question of the Day Management

  @override
  Future<Either<Failure, QuestionOfTheDay>> saveQuestionResponse(
    QuestionOfTheDay question,
  ) async {
    try {
      AppLogger.info('Saving question response: ${question.id}');

      final result = await _questionDataSource.saveQuestionResponse(question);

      AppLogger.info('Question response saved successfully: ${question.id}');
      return Right(result);
    } catch (e) {
      AppLogger.error('Failed to save question response: ${question.id}', e);
      return Left(ErrorHandler.handleException(e as Exception));
    }
  }

  @override
  Future<Either<Failure, QuestionOfTheDay?>> getQuestionResponse(
    String questionId,
  ) async {
    try {
      AppLogger.debug('Retrieving question response: $questionId');

      final result = await _questionDataSource.getQuestionResponse(questionId);

      AppLogger.debug('Question response retrieved: ${result?.id ?? 'none'}');
      return Right(result);
    } catch (e) {
      AppLogger.error('Failed to retrieve question response: $questionId', e);
      return Left(ErrorHandler.handleException(e as Exception));
    }
  }

  @override
  Future<Either<Failure, List<QuestionOfTheDay>>> getAnsweredQuestions() async {
    try {
      AppLogger.debug('Retrieving all answered questions');

      final result = await _questionDataSource.getAnsweredQuestions();

      AppLogger.debug('Retrieved ${result.length} answered questions');
      return Right(result);
    } catch (e) {
      AppLogger.error('Failed to retrieve answered questions', e);
      return Left(ErrorHandler.handleException(e as Exception));
    }
  }

  @override
  Future<Either<Failure, List<QuestionOfTheDay>>>
  getAnsweredQuestionsByDateRange(DateTime startDate, DateTime endDate) async {
    try {
      AppLogger.debug(
        'Retrieving answered questions from $startDate to $endDate',
      );

      final result = await _questionDataSource.getAnsweredQuestionsByDateRange(
        startDate,
        endDate,
      );

      AppLogger.debug(
        'Retrieved ${result.length} answered questions for date range',
      );
      return Right(result);
    } catch (e) {
      AppLogger.error(
        'Failed to retrieve answered questions for date range: $startDate to $endDate',
        e,
      );
      return Left(ErrorHandler.handleException(e as Exception));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteQuestionResponse(
    String questionId,
  ) async {
    try {
      AppLogger.info('Deleting question response: $questionId');

      await _questionDataSource.deleteQuestionResponse(questionId);

      AppLogger.info('Question response deleted successfully: $questionId');
      return const Right(unit);
    } catch (e) {
      AppLogger.error('Failed to delete question response: $questionId', e);
      return Left(ErrorHandler.handleException(e as Exception));
    }
  }

  @override
  Future<Either<Failure, QuestionResponseStatistics>>
  getQuestionResponseStatistics() async {
    try {
      AppLogger.debug('Calculating question response statistics');

      final result = await _questionDataSource.getQuestionResponseStatistics();

      AppLogger.debug(
        'Calculated question response statistics: ${result.answeredQuestions}/${result.totalQuestions}',
      );
      return Right(result);
    } catch (e) {
      AppLogger.error('Failed to calculate question response statistics', e);
      return Left(ErrorHandler.handleException(e as Exception));
    }
  }

  // Data Management

  @override
  Future<Either<Failure, String>> exportData() async {
    try {
      AppLogger.info('Exporting all data');

      // Get all data
      final profileResult = await getProfile();
      final dailyLogsResult = await getAllDailyLogs();
      final questionsResult = await getAnsweredQuestions();

      // Handle any failures
      if (profileResult.isLeft()) {
        return profileResult.fold(
          (failure) => Left(failure),
          (_) => throw Exception(),
        );
      }
      if (dailyLogsResult.isLeft()) {
        return dailyLogsResult.fold(
          (failure) => Left(failure),
          (_) => throw Exception(),
        );
      }
      if (questionsResult.isLeft()) {
        return questionsResult.fold(
          (failure) => Left(failure),
          (_) => throw Exception(),
        );
      }

      // Extract data
      final profile = profileResult.getOrElse(() => null);
      final dailyLogs = dailyLogsResult.getOrElse(() => []);
      final questions = questionsResult.getOrElse(() => []);

      // Create export data structure
      final exportData = {
        'version': '1.0',
        'exportDate': DateTime.now().toIso8601String(),
        'profile': profile != null ? _profileToJson(profile) : null,
        'dailyLogs': dailyLogs.map(_dailyLogToJson).toList(),
        'questions': questions.map(_questionToJson).toList(),
      };

      final jsonString = json.encode(exportData);

      AppLogger.info(
        'Data exported successfully (${jsonString.length} characters)',
      );
      return Right(jsonString);
    } catch (e) {
      AppLogger.error('Failed to export data', e);
      return Left(ErrorHandler.handleException(e as Exception));
    }
  }

  @override
  Future<Either<Failure, Unit>> importData(String jsonData) async {
    try {
      AppLogger.info('Importing data (${jsonData.length} characters)');

      // Parse JSON
      final data = json.decode(jsonData) as Map<String, dynamic>;

      // Validate structure
      if (!data.containsKey('version')) {
        return const Left(
          ValidationFailure('Invalid import data: missing version'),
        );
      }

      // Clear existing data (optional - could be made configurable)
      await clearAllData();

      // Import profile
      if (data['profile'] != null) {
        final profileData = data['profile'] as Map<String, dynamic>;
        final profile = _profileFromJson(profileData);
        final createResult = await createProfile(profile);
        if (createResult.isLeft()) {
          return createResult.fold(
            (failure) => Left(failure),
            (_) => throw Exception(),
          );
        }
      }

      // Import daily logs
      if (data['dailyLogs'] != null) {
        final dailyLogsData = data['dailyLogs'] as List;
        for (final logData in dailyLogsData) {
          final dailyLog = _dailyLogFromJson(logData as Map<String, dynamic>);
          final createResult = await createDailyLog(dailyLog);
          if (createResult.isLeft()) {
            AppLogger.warning('Failed to import daily log: ${dailyLog.id}');
          }
        }
      }

      // Import questions
      if (data['questions'] != null) {
        final questionsData = data['questions'] as List;
        for (final questionData in questionsData) {
          final question = _questionFromJson(
            questionData as Map<String, dynamic>,
          );
          final saveResult = await saveQuestionResponse(question);
          if (saveResult.isLeft()) {
            AppLogger.warning('Failed to import question: ${question.id}');
          }
        }
      }

      AppLogger.info('Data imported successfully');
      return const Right(unit);
    } catch (e) {
      AppLogger.error('Failed to import data', e);
      return Left(ErrorHandler.handleException(e as Exception));
    }
  }

  @override
  Future<Either<Failure, Unit>> clearAllData() async {
    try {
      AppLogger.info('Clearing all data');

      // Delete all questions
      await _questionDataSource.deleteAllQuestions();

      // Delete profile (this will cascade delete daily logs due to foreign key)
      await _profileDataSource.deleteProfile();

      AppLogger.info('All data cleared successfully');
      return const Right(unit);
    } catch (e) {
      AppLogger.error('Failed to clear all data', e);
      return Left(ErrorHandler.handleException(e as Exception));
    }
  }

  @override
  Future<Either<Failure, DatabaseStatistics>> getDatabaseStatistics() async {
    try {
      AppLogger.debug('Calculating database statistics');

      // Get counts
      final profileExists = await hasProfile();
      final dailyLogs = await getAllDailyLogs();
      final questions = await getAnsweredQuestions();

      // Handle failures
      if (profileExists.isLeft()) {
        return profileExists.fold(
          (failure) => Left(failure),
          (_) => throw Exception(),
        );
      }
      if (dailyLogs.isLeft()) {
        return dailyLogs.fold(
          (failure) => Left(failure),
          (_) => throw Exception(),
        );
      }
      if (questions.isLeft()) {
        return questions.fold(
          (failure) => Left(failure),
          (_) => throw Exception(),
        );
      }

      final hasProfileValue = profileExists.getOrElse(() => false);
      final dailyLogsList = dailyLogs.getOrElse(() => []);
      final questionsList = questions.getOrElse(() => []);

      // Find oldest and newest entries
      DateTime? oldestEntry;
      DateTime? newestEntry;

      if (dailyLogsList.isNotEmpty) {
        final sortedLogs = List<DailyLog>.from(dailyLogsList)
          ..sort((a, b) => a.date.compareTo(b.date));
        oldestEntry = sortedLogs.first.date;
        newestEntry = sortedLogs.last.date;
      }

      if (questionsList.isNotEmpty) {
        final sortedQuestions =
            questionsList.where((q) => q.responseDate != null).toList()
              ..sort((a, b) => a.responseDate!.compareTo(b.responseDate!));

        if (sortedQuestions.isNotEmpty) {
          final oldestQuestion = sortedQuestions.first.responseDate!;
          final newestQuestion = sortedQuestions.last.responseDate!;

          if (oldestEntry == null || oldestQuestion.isBefore(oldestEntry)) {
            oldestEntry = oldestQuestion;
          }
          if (newestEntry == null || newestQuestion.isAfter(newestEntry)) {
            newestEntry = newestQuestion;
          }
        }
      }

      final statistics = DatabaseStatistics(
        profileCount: hasProfileValue ? 1 : 0,
        dailyLogCount: dailyLogsList.length,
        questionResponseCount: questionsList.length,
        oldestEntry: oldestEntry,
        newestEntry: newestEntry,
        databaseSizeBytes: 0, // Would need to calculate actual file size
      );

      AppLogger.debug(
        'Database statistics calculated: ${statistics.totalEntries} total entries',
      );
      return Right(statistics);
    } catch (e) {
      AppLogger.error('Failed to calculate database statistics', e);
      return Left(ErrorHandler.handleException(e as Exception));
    }
  }

  // Helper methods for JSON conversion

  Map<String, dynamic> _profileToJson(ApprenticeProfile profile) {
    return {
      'id': profile.id,
      'firstName': profile.firstName,
      'lastName': profile.lastName,
      'trade': profile.trade,
      'apprenticeshipStartDate':
          profile.apprenticeshipStartDate.toIso8601String(),
      'apprenticeshipEndDate': profile.apprenticeshipEndDate.toIso8601String(),
      'companyName': profile.companyName,
      'schoolName': profile.schoolName,
      'email': profile.email,
      'phone': profile.phone,
      'isCompanyVerified': profile.isCompanyVerified,
      'isSchoolVerified': profile.isSchoolVerified,
      'createdAt': profile.createdAt.toIso8601String(),
      'updatedAt': profile.updatedAt.toIso8601String(),
    };
  }

  ApprenticeProfile _profileFromJson(Map<String, dynamic> json) {
    return ApprenticeProfileFactory.fromData(
      id: json['id'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      trade: json['trade'] as String,
      apprenticeshipStartDate: DateTime.parse(
        json['apprenticeshipStartDate'] as String,
      ),
      apprenticeshipEndDate: DateTime.parse(
        json['apprenticeshipEndDate'] as String,
      ),
      companyName: json['companyName'] as String?,
      schoolName: json['schoolName'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      isCompanyVerified: json['isCompanyVerified'] as bool? ?? false,
      isSchoolVerified: json['isSchoolVerified'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> _dailyLogToJson(DailyLog dailyLog) {
    return {
      'id': dailyLog.id,
      'profileId': dailyLog.profileId,
      'date': dailyLog.date.toIso8601String(),
      'status': dailyLog.status.value,
      'notes': dailyLog.notes,
      'createdAt': dailyLog.createdAt.toIso8601String(),
      'updatedAt': dailyLog.updatedAt.toIso8601String(),
    };
  }

  DailyLog _dailyLogFromJson(Map<String, dynamic> json) {
    return DailyLogFactory.fromData(
      id: json['id'] as String,
      profileId: json['profileId'] as String,
      date: DateTime.parse(json['date'] as String),
      status: DailyLogStatus.fromValue(json['status'] as String),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> _questionToJson(QuestionOfTheDay question) {
    return {
      'id': question.id,
      'question': question.question,
      'category': question.category.value,
      'response': question.response,
      'responseDate': question.responseDate?.toIso8601String(),
      'createdAt': question.createdAt.toIso8601String(),
    };
  }

  QuestionOfTheDay _questionFromJson(Map<String, dynamic> json) {
    return QuestionOfTheDayFactory.fromData(
      id: json['id'] as String,
      question: json['question'] as String,
      category: QuestionCategory.fromValue(json['category'] as String),
      response: json['response'] as String?,
      responseDate:
          json['responseDate'] != null
              ? DateTime.parse(json['responseDate'] as String)
              : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
