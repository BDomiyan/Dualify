import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';

import '../errors/exceptions.dart';
import '../utils/logger.dart';
import '../../domain/entities/entities.dart';

/// Service for managing Question of the Day functionality
/// Handles JSON loading, caching, and question selection algorithms
class QuestionOfTheDayService {
  static QuestionOfTheDayService? _instance;
  static List<QuestionData>? _cachedQuestions;
  static DateTime? _lastLoadTime;

  // Cache duration (24 hours)
  static const Duration _cacheDuration = Duration(hours: 24);

  // Asset path for questions JSON file
  static const String _questionsAssetPath =
      'assets/data/questions_of_the_day.json';

  /// Singleton pattern
  QuestionOfTheDayService._internal();

  factory QuestionOfTheDayService() {
    _instance ??= QuestionOfTheDayService._internal();
    return _instance!;
  }

  /// Loads questions from JSON asset with caching
  /// Throws DataException if loading fails
  Future<List<QuestionData>> loadQuestions({bool forceReload = false}) async {
    try {
      // Check if we have cached data and it's still valid
      if (!forceReload && _cachedQuestions != null && _lastLoadTime != null) {
        final cacheAge = DateTime.now().difference(_lastLoadTime!);
        if (cacheAge < _cacheDuration) {
          AppLogger.debug(
            'Using cached questions (${_cachedQuestions!.length} questions)',
          );
          return _cachedQuestions!;
        }
      }

      AppLogger.debug('Loading questions from asset: $_questionsAssetPath');

      // Load JSON from assets
      final jsonString = await rootBundle.loadString(_questionsAssetPath);

      if (jsonString.isEmpty) {
        throw const DataException.notFound(
          'Questions JSON',
          'Asset file is empty',
        );
      }

      // Parse JSON
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;

      // Validate JSON structure
      if (!jsonData.containsKey('questions') ||
          jsonData['questions'] is! List) {
        throw const DataException(
          'Invalid structure: Questions JSON must contain a "questions" array',
          code: 'DATA_006',
        );
      }

      final questionsJson = jsonData['questions'] as List;

      if (questionsJson.isEmpty) {
        throw const DataException.notFound(
          'Questions',
          'No questions found in JSON file',
        );
      }

      // Parse questions
      final questions = <QuestionData>[];
      for (int i = 0; i < questionsJson.length; i++) {
        try {
          final questionJson = questionsJson[i] as Map<String, dynamic>;
          final questionData = QuestionData.fromJson(questionJson);
          questions.add(questionData);
        } catch (e) {
          AppLogger.warning('Failed to parse question at index $i: $e');
          // Continue parsing other questions
        }
      }

      if (questions.isEmpty) {
        throw const DataException.parsingFailed(
          'Questions',
          'No valid questions could be parsed',
        );
      }

      // Cache the loaded questions
      _cachedQuestions = questions;
      _lastLoadTime = DateTime.now();

      AppLogger.info('Loaded ${questions.length} questions successfully');
      return questions;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to load questions from asset', e, stackTrace);

      if (e is DataException) {
        rethrow;
      }

      throw DataException(
        'Failed to load questions: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Gets a deterministic question for a specific date
  /// Uses date-based algorithm to ensure same question for same date
  /// Throws DataException if no questions available
  Future<QuestionData> getDeterministicQuestion(
    DateTime date, {
    QuestionCategory? category,
  }) async {
    try {
      final questions = await loadQuestions();

      // Filter by category if specified
      final filteredQuestions =
          category != null
              ? questions.where((q) => q.category == category).toList()
              : questions;

      if (filteredQuestions.isEmpty) {
        throw DataException.notFound(
          'Questions',
          category != null
              ? 'No questions found for category: ${category.displayName}'
              : 'No questions available',
        );
      }

      // Create deterministic index based on date
      final dayOfYear = date.difference(DateTime(date.year, 1, 1)).inDays;
      final yearOffset = date.year * 365; // Add year variation
      final seed = dayOfYear + yearOffset;

      final index = seed % filteredQuestions.length;
      final selectedQuestion = filteredQuestions[index];

      AppLogger.debug(
        'Selected deterministic question for $date: ${selectedQuestion.id}',
      );
      return selectedQuestion;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to get deterministic question for date: $date',
        e,
        stackTrace,
      );

      if (e is DataException) {
        rethrow;
      }

      throw DataException(
        'Failed to get deterministic question: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Gets a random question with optional exclusion list
  /// Throws DataException if no questions available
  Future<QuestionData> getRandomQuestion({
    QuestionCategory? category,
    List<String>? excludeIds,
    int? seed,
  }) async {
    try {
      final questions = await loadQuestions();

      // Filter by category if specified
      var filteredQuestions =
          category != null
              ? questions.where((q) => q.category == category).toList()
              : questions;

      // Exclude specified IDs
      if (excludeIds != null && excludeIds.isNotEmpty) {
        filteredQuestions =
            filteredQuestions.where((q) => !excludeIds.contains(q.id)).toList();
      }

      if (filteredQuestions.isEmpty) {
        throw DataException.notFound(
          'Questions',
          'No available questions after filtering',
        );
      }

      // Select random question
      final random = seed != null ? Random(seed) : Random();
      final index = random.nextInt(filteredQuestions.length);
      final selectedQuestion = filteredQuestions[index];

      AppLogger.debug('Selected random question: ${selectedQuestion.id}');
      return selectedQuestion;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to get random question', e, stackTrace);

      if (e is DataException) {
        rethrow;
      }

      throw DataException(
        'Failed to get random question: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Gets questions by category
  /// Throws DataException if loading fails
  Future<List<QuestionData>> getQuestionsByCategory(
    QuestionCategory category,
  ) async {
    try {
      final questions = await loadQuestions();
      final categoryQuestions =
          questions.where((q) => q.category == category).toList();

      AppLogger.debug(
        'Found ${categoryQuestions.length} questions for category: ${category.displayName}',
      );
      return categoryQuestions;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to get questions by category: ${category.displayName}',
        e,
        stackTrace,
      );

      if (e is DataException) {
        rethrow;
      }

      throw DataException(
        'Failed to get questions by category: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Gets question statistics
  /// Throws DataException if loading fails
  Future<QuestionStatistics> getQuestionStatistics() async {
    try {
      final questions = await loadQuestions();

      // Count questions by category
      final categoryCount = <QuestionCategory, int>{};
      for (final category in QuestionCategory.values) {
        categoryCount[category] = 0;
      }

      for (final question in questions) {
        categoryCount[question.category] =
            (categoryCount[question.category] ?? 0) + 1;
      }

      // Calculate average question length
      final totalLength = questions.fold<int>(
        0,
        (sum, q) => sum + q.question.length,
      );
      final averageLength =
          questions.isNotEmpty ? totalLength / questions.length : 0.0;

      final statistics = QuestionStatistics(
        totalQuestions: questions.length,
        questionsByCategory: categoryCount,
        averageQuestionLength: averageLength,
        lastLoadTime: _lastLoadTime,
      );

      AppLogger.debug(
        'Calculated question statistics: ${statistics.totalQuestions} total questions',
      );
      return statistics;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to get question statistics', e, stackTrace);

      if (e is DataException) {
        rethrow;
      }

      throw DataException(
        'Failed to get question statistics: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Validates question data structure
  /// Throws ValidationException if validation fails
  static void validateQuestionData(QuestionData questionData) {
    final errors = <String>[];

    if (questionData.id.trim().isEmpty) {
      errors.add('Question ID cannot be empty');
    }

    if (questionData.question.trim().isEmpty) {
      errors.add('Question text cannot be empty');
    }

    if (questionData.question.length > 500) {
      errors.add('Question text cannot exceed 500 characters');
    }

    if (questionData.question.length < 10) {
      errors.add('Question text must be at least 10 characters');
    }

    if (errors.isNotEmpty) {
      throw ValidationException(
        'Question validation failed: ${errors.join(', ')}',
        code: 'QUESTION_VALIDATION_FAILED',
      );
    }
  }

  /// Clears the question cache
  static void clearCache() {
    _cachedQuestions = null;
    _lastLoadTime = null;
    AppLogger.debug('Question cache cleared');
  }

  /// Checks if questions are cached and valid
  static bool get isCacheValid {
    if (_cachedQuestions == null || _lastLoadTime == null) return false;

    final cacheAge = DateTime.now().difference(_lastLoadTime!);
    return cacheAge < _cacheDuration;
  }

  /// Gets the number of cached questions
  static int get cachedQuestionCount => _cachedQuestions?.length ?? 0;
}

/// Data class for question information from JSON
class QuestionData {
  final String id;
  final String question;
  final QuestionCategory category;
  final List<String> tags;
  final String? hint;
  final int difficulty; // 1-5 scale

  const QuestionData({
    required this.id,
    required this.question,
    required this.category,
    this.tags = const [],
    this.hint,
    this.difficulty = 3,
  });

  /// Creates QuestionData from JSON
  factory QuestionData.fromJson(Map<String, dynamic> json) {
    try {
      return QuestionData(
        id: json['id'] as String,
        question: json['question'] as String,
        category: QuestionCategory.fromValue(json['category'] as String),
        tags: (json['tags'] as List?)?.cast<String>() ?? [],
        hint: json['hint'] as String?,
        difficulty: json['difficulty'] as int? ?? 3,
      );
    } catch (e) {
      throw DataException.parsingFailed('QuestionData', e);
    }
  }

  /// Converts QuestionData to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'category': category.value,
      'tags': tags,
      'hint': hint,
      'difficulty': difficulty,
    };
  }

  /// Converts to QuestionOfTheDay entity
  QuestionOfTheDay toEntity() {
    return QuestionOfTheDayFactory.fromData(
      id: id,
      question: question,
      category: category,
      createdAt: DateTime.now(),
    );
  }

  @override
  String toString() =>
      'QuestionData(id: $id, category: ${category.displayName})';
}

/// Statistics for question data
class QuestionStatistics {
  final int totalQuestions;
  final Map<QuestionCategory, int> questionsByCategory;
  final double averageQuestionLength;
  final DateTime? lastLoadTime;

  const QuestionStatistics({
    required this.totalQuestions,
    required this.questionsByCategory,
    required this.averageQuestionLength,
    this.lastLoadTime,
  });

  /// Gets the most common category
  QuestionCategory? get mostCommonCategory {
    if (questionsByCategory.isEmpty) return null;

    var maxCount = 0;
    QuestionCategory? mostCommon;

    for (final entry in questionsByCategory.entries) {
      if (entry.value > maxCount) {
        maxCount = entry.value;
        mostCommon = entry.key;
      }
    }

    return mostCommon;
  }

  /// Gets the least common category
  QuestionCategory? get leastCommonCategory {
    if (questionsByCategory.isEmpty) return null;

    var minCount = double.infinity.toInt();
    QuestionCategory? leastCommon;

    for (final entry in questionsByCategory.entries) {
      if (entry.value < minCount && entry.value > 0) {
        minCount = entry.value;
        leastCommon = entry.key;
      }
    }

    return leastCommon;
  }

  /// Gets category distribution as percentages
  Map<QuestionCategory, double> get categoryDistribution {
    if (totalQuestions == 0) return {};

    return questionsByCategory.map(
      (category, count) => MapEntry(category, count / totalQuestions),
    );
  }

  @override
  String toString() =>
      'QuestionStatistics(total: $totalQuestions, avgLength: ${averageQuestionLength.toStringAsFixed(1)})';
}
