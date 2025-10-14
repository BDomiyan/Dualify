import '../../core/errors/exceptions.dart';
import '../../domain/entities/entities.dart';

/// Data model for Question of the Day JSON structure
/// Handles JSON parsing and validation with comprehensive error handling
class QuestionOfTheDayData {
  final String version;
  final String lastUpdated;
  final String description;
  final List<QuestionDataModel> questions;

  const QuestionOfTheDayData({
    required this.version,
    required this.lastUpdated,
    required this.description,
    required this.questions,
  });

  /// Creates QuestionOfTheDayData from JSON
  factory QuestionOfTheDayData.fromJson(Map<String, dynamic> json) {
    try {
      // Validate required fields
      if (!json.containsKey('questions')) {
        throw const DataException(
          'Missing required field: questions',
          code: 'DATA_007',
        );
      }

      final questionsJson = json['questions'];
      if (questionsJson is! List) {
        throw const DataException(
          'Invalid structure: questions must be an array',
          code: 'DATA_006',
        );
      }

      // Parse questions
      final questions = <QuestionDataModel>[];
      for (int i = 0; i < questionsJson.length; i++) {
        try {
          final questionJson = questionsJson[i];
          if (questionJson is! Map<String, dynamic>) {
            throw DataException(
              'Question at index $i must be an object',
              code: 'DATA_006',
            );
          }

          final question = QuestionDataModel.fromJson(questionJson);
          questions.add(question);
        } catch (e) {
          throw DataException.parsingFailed('Question at index $i', e);
        }
      }

      if (questions.isEmpty) {
        throw const DataException.notFound(
          'Questions',
          'No valid questions found in JSON',
        );
      }

      return QuestionOfTheDayData(
        version: json['version'] as String? ?? '1.0',
        lastUpdated: json['lastUpdated'] as String? ?? '',
        description: json['description'] as String? ?? '',
        questions: questions,
      );
    } catch (e) {
      if (e is DataException) {
        rethrow;
      }
      throw DataException.parsingFailed('QuestionOfTheDayData', e);
    }
  }

  /// Converts to JSON
  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'lastUpdated': lastUpdated,
      'description': description,
      'questions': questions.map((q) => q.toJson()).toList(),
    };
  }

  /// Gets questions by category
  List<QuestionDataModel> getQuestionsByCategory(QuestionCategory category) {
    return questions.where((q) => q.category == category).toList();
  }

  /// Gets question by ID
  QuestionDataModel? getQuestionById(String id) {
    try {
      return questions.firstWhere((q) => q.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Gets questions by difficulty level
  List<QuestionDataModel> getQuestionsByDifficulty(int difficulty) {
    return questions.where((q) => q.difficulty == difficulty).toList();
  }

  /// Gets questions by tags
  List<QuestionDataModel> getQuestionsByTag(String tag) {
    return questions.where((q) => q.tags.contains(tag)).toList();
  }

  /// Validates the data structure
  List<String> validate() {
    final errors = <String>[];

    if (questions.isEmpty) {
      errors.add('No questions found');
    }

    // Check for duplicate IDs
    final ids = questions.map((q) => q.id).toList();
    final uniqueIds = ids.toSet();
    if (ids.length != uniqueIds.length) {
      errors.add('Duplicate question IDs found');
    }

    // Validate each question
    for (int i = 0; i < questions.length; i++) {
      final questionErrors = questions[i].validate();
      for (final error in questionErrors) {
        errors.add('Question $i: $error');
      }
    }

    // Check category distribution
    final categoryCount = <QuestionCategory, int>{};
    for (final question in questions) {
      categoryCount[question.category] =
          (categoryCount[question.category] ?? 0) + 1;
    }

    for (final category in QuestionCategory.values) {
      final count = categoryCount[category] ?? 0;
      if (count == 0) {
        errors.add('No questions found for category: ${category.displayName}');
      } else if (count < 3) {
        errors.add(
          'Only $count questions found for category: ${category.displayName} (minimum 3 recommended)',
        );
      }
    }

    return errors;
  }

  /// Gets statistics about the question data
  QuestionDataStatistics get statistics {
    final categoryCount = <QuestionCategory, int>{};
    final difficultyCount = <int, int>{};
    final tagCount = <String, int>{};

    var totalQuestionLength = 0;

    for (final question in questions) {
      // Category count
      categoryCount[question.category] =
          (categoryCount[question.category] ?? 0) + 1;

      // Difficulty count
      difficultyCount[question.difficulty] =
          (difficultyCount[question.difficulty] ?? 0) + 1;

      // Tag count
      for (final tag in question.tags) {
        tagCount[tag] = (tagCount[tag] ?? 0) + 1;
      }

      // Question length
      totalQuestionLength += question.question.length;
    }

    return QuestionDataStatistics(
      totalQuestions: questions.length,
      categoryDistribution: categoryCount,
      difficultyDistribution: difficultyCount,
      tagDistribution: tagCount,
      averageQuestionLength:
          questions.isNotEmpty ? totalQuestionLength / questions.length : 0.0,
      version: version,
      lastUpdated: lastUpdated,
    );
  }

  @override
  String toString() =>
      'QuestionOfTheDayData(version: $version, questions: ${questions.length})';
}

/// Data model for individual question
class QuestionDataModel {
  final String id;
  final String question;
  final QuestionCategory category;
  final List<String> tags;
  final String? hint;
  final int difficulty;

  const QuestionDataModel({
    required this.id,
    required this.question,
    required this.category,
    this.tags = const [],
    this.hint,
    this.difficulty = 3,
  });

  /// Creates QuestionDataModel from JSON
  factory QuestionDataModel.fromJson(Map<String, dynamic> json) {
    try {
      // Validate required fields
      final id = json['id'] as String?;
      if (id == null || id.trim().isEmpty) {
        throw const DataException(
          'Missing required field: id',
          code: 'DATA_007',
        );
      }

      final question = json['question'] as String?;
      if (question == null || question.trim().isEmpty) {
        throw const DataException(
          'Missing required field: question',
          code: 'DATA_007',
        );
      }

      final categoryValue = json['category'] as String?;
      if (categoryValue == null || categoryValue.trim().isEmpty) {
        throw const DataException(
          'Missing required field: category',
          code: 'DATA_007',
        );
      }

      // Parse category
      final category = QuestionCategory.fromValue(categoryValue);

      // Parse optional fields
      final tags = (json['tags'] as List?)?.cast<String>() ?? [];
      final hint = json['hint'] as String?;
      final difficulty = json['difficulty'] as int? ?? 3;

      // Validate difficulty range
      if (difficulty < 1 || difficulty > 5) {
        throw const DataException(
          'Difficulty out of range: must be 1-5',
          code: 'DATA_004',
        );
      }

      return QuestionDataModel(
        id: id.trim(),
        question: question.trim(),
        category: category,
        tags:
            tags
                .map((tag) => tag.trim())
                .where((tag) => tag.isNotEmpty)
                .toList(),
        hint: hint?.trim(),
        difficulty: difficulty,
      );
    } catch (e) {
      if (e is DataException) {
        rethrow;
      }
      throw DataException.parsingFailed('QuestionDataModel', e);
    }
  }

  /// Converts to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'category': category.value,
      'tags': tags,
      if (hint != null) 'hint': hint,
      'difficulty': difficulty,
    };
  }

  /// Converts to domain entity
  QuestionOfTheDay toEntity() {
    return QuestionOfTheDayFactory.fromData(
      id: id,
      question: question,
      category: category,
      createdAt: DateTime.now(),
    );
  }

  /// Validates the question data
  List<String> validate() {
    final errors = <String>[];

    if (id.isEmpty) {
      errors.add('ID cannot be empty');
    }

    if (question.isEmpty) {
      errors.add('Question text cannot be empty');
    } else {
      if (question.length < 10) {
        errors.add('Question text must be at least 10 characters');
      }
      if (question.length > 500) {
        errors.add('Question text cannot exceed 500 characters');
      }
    }

    if (difficulty < 1 || difficulty > 5) {
      errors.add('Difficulty must be between 1 and 5');
    }

    if (hint != null && hint!.length > 200) {
      errors.add('Hint cannot exceed 200 characters');
    }

    // Validate tags
    for (final tag in tags) {
      if (tag.isEmpty) {
        errors.add('Tags cannot be empty');
      } else if (tag.length > 50) {
        errors.add('Tag "$tag" exceeds 50 characters');
      }
    }

    return errors;
  }

  /// Gets difficulty as text
  String get difficultyText {
    switch (difficulty) {
      case 1:
        return 'Very Easy';
      case 2:
        return 'Easy';
      case 3:
        return 'Medium';
      case 4:
        return 'Hard';
      case 5:
        return 'Very Hard';
      default:
        return 'Unknown';
    }
  }

  /// Checks if question has hint
  bool get hasHint => hint != null && hint!.isNotEmpty;

  @override
  String toString() =>
      'QuestionDataModel(id: $id, category: ${category.displayName}, difficulty: $difficulty)';
}

/// Statistics for question data
class QuestionDataStatistics {
  final int totalQuestions;
  final Map<QuestionCategory, int> categoryDistribution;
  final Map<int, int> difficultyDistribution;
  final Map<String, int> tagDistribution;
  final double averageQuestionLength;
  final String version;
  final String lastUpdated;

  const QuestionDataStatistics({
    required this.totalQuestions,
    required this.categoryDistribution,
    required this.difficultyDistribution,
    required this.tagDistribution,
    required this.averageQuestionLength,
    required this.version,
    required this.lastUpdated,
  });

  /// Gets the most common category
  QuestionCategory? get mostCommonCategory {
    if (categoryDistribution.isEmpty) return null;

    var maxCount = 0;
    QuestionCategory? mostCommon;

    for (final entry in categoryDistribution.entries) {
      if (entry.value > maxCount) {
        maxCount = entry.value;
        mostCommon = entry.key;
      }
    }

    return mostCommon;
  }

  /// Gets the most common difficulty
  int? get mostCommonDifficulty {
    if (difficultyDistribution.isEmpty) return null;

    var maxCount = 0;
    int? mostCommon;

    for (final entry in difficultyDistribution.entries) {
      if (entry.value > maxCount) {
        maxCount = entry.value;
        mostCommon = entry.key;
      }
    }

    return mostCommon;
  }

  /// Gets the most common tags (top 10)
  List<MapEntry<String, int>> get topTags {
    final sortedTags =
        tagDistribution.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

    return sortedTags.take(10).toList();
  }

  /// Gets category distribution as percentages
  Map<QuestionCategory, double> get categoryPercentages {
    if (totalQuestions == 0) return {};

    return categoryDistribution.map(
      (category, count) => MapEntry(category, count / totalQuestions * 100),
    );
  }

  /// Gets difficulty distribution as percentages
  Map<int, double> get difficultyPercentages {
    if (totalQuestions == 0) return {};

    return difficultyDistribution.map(
      (difficulty, count) => MapEntry(difficulty, count / totalQuestions * 100),
    );
  }

  @override
  String toString() =>
      'QuestionDataStatistics(total: $totalQuestions, avgLength: ${averageQuestionLength.toStringAsFixed(1)})';
}
