import '../../../core/constants/domain_constants.dart';
import 'question_category.dart';
import 'question_of_the_day.dart';

/// Factory class for creating QuestionOfTheDay instances
class QuestionOfTheDayFactory {
  /// Creates a new question
  static QuestionOfTheDay create({
    required String question,
    required QuestionCategory category,
    String? response,
    DateTime? responseDate,
  }) {
    final now = DateTime.now();
    final id = _generateId();

    return QuestionOfTheDay(
      id: id,
      question: question.trim(),
      category: category,
      response: response?.trim(),
      responseDate: responseDate,
      createdAt: now,
    );
  }

  /// Creates a question from existing data (e.g., from database or JSON)
  static QuestionOfTheDay fromData({
    required String id,
    required String question,
    required QuestionCategory category,
    String? response,
    DateTime? responseDate,
    required DateTime createdAt,
  }) {
    return QuestionOfTheDay(
      id: id,
      question: question,
      category: category,
      response: response,
      responseDate: responseDate,
      createdAt: createdAt,
    );
  }

  /// Creates a question from JSON data
  static QuestionOfTheDay fromJson(Map<String, dynamic> json) {
    return QuestionOfTheDay(
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

  /// Converts question to JSON
  static Map<String, dynamic> toJson(QuestionOfTheDay question) {
    return {
      'id': question.id,
      'question': question.question,
      'category': question.category.value,
      'response': question.response,
      'responseDate': question.responseDate?.toIso8601String(),
      'createdAt': question.createdAt.toIso8601String(),
    };
  }

  /// Generates a unique ID for the question
  static String _generateId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = DateTime.now().microsecond;
    return 'qotd_$timestamp${DomainConstants.idSeparator}$random';
  }
}
