import '../../../core/errors/exceptions.dart';
import '../../../core/utils/logger.dart';
import '../../../domain/entities/entities.dart';
import '../../../domain/repositories/local_apprenticeship_repository.dart';
import 'database_helper.dart';

/// Local data source for question operations
/// Handles SQLite operations for question data with comprehensive error handling
class LocalQuestionDataSource {
  final DatabaseHelper _databaseHelper;

  const LocalQuestionDataSource(this._databaseHelper);

  /// Saves a question response to the database
  /// Throws DatabaseException if operation fails
  Future<QuestionOfTheDay> saveQuestionResponse(
    QuestionOfTheDay question,
  ) async {
    try {
      AppLogger.debug('Saving question response: ${question.id}');

      // Convert question to database format
      final questionData = _questionToMap(question);

      // Check if question already exists
      final existingResults = await _databaseHelper.query(
        DatabaseHelper.tableQuestions,
        where: 'id = ?',
        whereArgs: [question.id],
        limit: 1,
      );

      if (existingResults.isNotEmpty) {
        // Update existing question
        await _databaseHelper.update(
          DatabaseHelper.tableQuestions,
          questionData,
          where: 'id = ?',
          whereArgs: [question.id],
        );
        AppLogger.info(
          'Question response updated successfully: ${question.id}',
        );
      } else {
        // Insert new question
        await _databaseHelper.insert(
          DatabaseHelper.tableQuestions,
          questionData,
        );
        AppLogger.info('Question response saved successfully: ${question.id}');
      }

      return question;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to save question response: ${question.id}',
        e,
        stackTrace,
      );

      if (e is DatabaseException) {
        rethrow;
      }

      throw DatabaseException(
        'Failed to save question response: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Gets a question response by ID
  /// Returns null if no question exists with the ID
  /// Throws DatabaseException if operation fails
  Future<QuestionOfTheDay?> getQuestionResponse(String questionId) async {
    try {
      AppLogger.debug('Retrieving question response: $questionId');

      final results = await _databaseHelper.query(
        DatabaseHelper.tableQuestions,
        where: 'id = ?',
        whereArgs: [questionId],
        limit: 1,
      );

      if (results.isEmpty) {
        AppLogger.debug('No question found with ID: $questionId');
        return null;
      }

      final questionData = results.first;
      final question = _mapToQuestion(questionData);

      AppLogger.debug(
        'Question response retrieved successfully: ${question.id}',
      );
      return question;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to retrieve question response: $questionId',
        e,
        stackTrace,
      );

      if (e is DatabaseException) {
        rethrow;
      }

      throw DatabaseException(
        'Failed to retrieve question response: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Gets all answered questions
  /// Returns empty list if no answered questions exist
  /// Throws DatabaseException if operation fails
  Future<List<QuestionOfTheDay>> getAnsweredQuestions() async {
    try {
      AppLogger.debug('Retrieving all answered questions');

      final results = await _databaseHelper.query(
        DatabaseHelper.tableQuestions,
        where: 'response IS NOT NULL AND response != ""',
        orderBy: 'response_date DESC',
      );

      final questions = results.map(_mapToQuestion).toList();

      AppLogger.debug('Retrieved ${questions.length} answered questions');
      return questions;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to retrieve answered questions', e, stackTrace);

      if (e is DatabaseException) {
        rethrow;
      }

      throw DatabaseException(
        'Failed to retrieve answered questions: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Gets answered questions for a date range
  /// Returns empty list if no questions exist in the range
  /// Throws DatabaseException if operation fails
  Future<List<QuestionOfTheDay>> getAnsweredQuestionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final startTimestamp = startDate.millisecondsSinceEpoch;
      final endTimestamp = endDate.millisecondsSinceEpoch;

      AppLogger.debug(
        'Retrieving answered questions from $startDate to $endDate',
      );

      final results = await _databaseHelper.query(
        DatabaseHelper.tableQuestions,
        where:
            'response IS NOT NULL AND response != "" AND response_date >= ? AND response_date <= ?',
        whereArgs: [startTimestamp, endTimestamp],
        orderBy: 'response_date DESC',
      );

      final questions = results.map(_mapToQuestion).toList();

      AppLogger.debug(
        'Retrieved ${questions.length} answered questions for date range',
      );
      return questions;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to retrieve answered questions for date range: $startDate to $endDate',
        e,
        stackTrace,
      );

      if (e is DatabaseException) {
        rethrow;
      }

      throw DatabaseException(
        'Failed to retrieve answered questions: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Deletes a question response from the database
  /// Throws DatabaseException if operation fails
  Future<void> deleteQuestionResponse(String questionId) async {
    try {
      AppLogger.debug('Deleting question response: $questionId');

      final rowsAffected = await _databaseHelper.delete(
        DatabaseHelper.tableQuestions,
        where: 'id = ?',
        whereArgs: [questionId],
      );

      if (rowsAffected == 0) {
        throw const DatabaseException(
          'Question not found for deletion',
          code: 'DB_007',
        );
      }

      AppLogger.info('Question response deleted successfully: $questionId');
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to delete question response: $questionId',
        e,
        stackTrace,
      );

      if (e is DatabaseException) {
        rethrow;
      }

      throw DatabaseException(
        'Failed to delete question response: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Gets question response statistics
  /// Throws DatabaseException if operation fails
  Future<QuestionResponseStatistics> getQuestionResponseStatistics() async {
    try {
      AppLogger.debug('Calculating question response statistics');

      // Get total questions count
      final totalResults = await _databaseHelper.query(
        DatabaseHelper.tableQuestions,
        columns: ['COUNT(*) as total'],
      );
      final totalQuestions = totalResults.first['total'] as int;

      // Get answered questions count
      final answeredResults = await _databaseHelper.query(
        DatabaseHelper.tableQuestions,
        columns: ['COUNT(*) as answered'],
        where: 'response IS NOT NULL AND response != ""',
      );
      final answeredQuestions = answeredResults.first['answered'] as int;

      // Get answers by category
      final categoryResults = await _databaseHelper.query(
        DatabaseHelper.tableQuestions,
        columns: ['category', 'COUNT(*) as count'],
        where: 'response IS NOT NULL AND response != ""',
        groupBy: 'category',
      );

      final answersByCategory = <QuestionCategory, int>{};
      for (final result in categoryResults) {
        final category = QuestionCategory.fromValue(
          result['category'] as String,
        );
        final count = result['count'] as int;
        answersByCategory[category] = count;
      }

      // Get average response length
      final lengthResults = await _databaseHelper.query(
        DatabaseHelper.tableQuestions,
        columns: ['AVG(LENGTH(response)) as avg_length'],
        where: 'response IS NOT NULL AND response != ""',
      );
      final averageLength =
          (lengthResults.first['avg_length'] as num?)?.toDouble() ?? 0.0;

      // Get last response date
      final lastResponseResults = await _databaseHelper.query(
        DatabaseHelper.tableQuestions,
        columns: ['MAX(response_date) as last_response'],
        where: 'response IS NOT NULL AND response != ""',
      );
      final lastResponseTimestamp =
          lastResponseResults.first['last_response'] as int?;
      final lastResponseDate =
          lastResponseTimestamp != null
              ? DateTime.fromMillisecondsSinceEpoch(lastResponseTimestamp)
              : null;

      final statistics = QuestionResponseStatistics(
        totalQuestions: totalQuestions,
        answeredQuestions: answeredQuestions,
        answersByCategory: answersByCategory,
        averageResponseLength: averageLength,
        lastResponseDate: lastResponseDate,
      );

      AppLogger.debug(
        'Calculated question response statistics: $answeredQuestions/$totalQuestions answered',
      );
      return statistics;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to calculate question response statistics',
        e,
        stackTrace,
      );

      if (e is DatabaseException) {
        rethrow;
      }

      throw DatabaseException(
        'Failed to calculate question response statistics: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Deletes all questions (for testing or reset)
  /// Throws DatabaseException if operation fails
  Future<void> deleteAllQuestions() async {
    try {
      AppLogger.debug('Deleting all questions');

      final rowsAffected = await _databaseHelper.delete(
        DatabaseHelper.tableQuestions,
      );

      AppLogger.info('Deleted $rowsAffected questions');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to delete all questions', e, stackTrace);

      if (e is DatabaseException) {
        rethrow;
      }

      throw DatabaseException(
        'Failed to delete all questions: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Converts QuestionOfTheDay entity to database map
  Map<String, dynamic> _questionToMap(QuestionOfTheDay question) {
    return {
      'id': question.id,
      'question': question.question,
      'category': question.category.value,
      'response': question.response,
      'response_date': question.responseDate?.millisecondsSinceEpoch,
      'created_at': question.createdAt.millisecondsSinceEpoch,
    };
  }

  /// Converts database map to QuestionOfTheDay entity
  QuestionOfTheDay _mapToQuestion(Map<String, dynamic> map) {
    try {
      return QuestionOfTheDayFactory.fromData(
        id: map['id'] as String,
        question: map['question'] as String,
        category: QuestionCategory.fromValue(map['category'] as String),
        response: map['response'] as String?,
        responseDate:
            map['response_date'] != null
                ? DateTime.fromMillisecondsSinceEpoch(
                  map['response_date'] as int,
                )
                : null,
        createdAt: DateTime.fromMillisecondsSinceEpoch(
          map['created_at'] as int,
        ),
      );
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to convert database map to question',
        e,
        stackTrace,
      );
      throw DataException.transformationFailed('Question data mapping', e);
    }
  }
}
