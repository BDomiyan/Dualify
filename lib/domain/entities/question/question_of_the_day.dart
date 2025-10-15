import 'package:equatable/equatable.dart';

import '../../../core/constants/domain_constants.dart';
import 'question_category.dart';

/// Core domain entity representing a Question of the Day
/// Immutable entity following Domain-Driven Design principles
class QuestionOfTheDay extends Equatable {
  final String id;
  final String question;
  final QuestionCategory category;
  final String? response;
  final DateTime? responseDate;
  final DateTime createdAt;

  const QuestionOfTheDay({
    required this.id,
    required this.question,
    required this.category,
    this.response,
    this.responseDate,
    required this.createdAt,
  });

  /// Creates a copy of this question with updated fields
  QuestionOfTheDay copyWith({
    String? id,
    String? question,
    QuestionCategory? category,
    String? response,
    DateTime? responseDate,
    DateTime? createdAt,
  }) {
    return QuestionOfTheDay(
      id: id ?? this.id,
      question: question ?? this.question,
      category: category ?? this.category,
      response: response ?? this.response,
      responseDate: responseDate ?? this.responseDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Creates a copy with a response added
  QuestionOfTheDay withResponse(String response) {
    return copyWith(response: response.trim(), responseDate: DateTime.now());
  }

  /// Creates a copy with the response cleared
  QuestionOfTheDay withoutResponse() {
    return copyWith(response: null, responseDate: null);
  }

  /// Checks if this question has been answered
  bool get hasResponse => response != null && response!.isNotEmpty;

  /// Gets the response word count
  int get responseWordCount {
    if (!hasResponse) return 0;
    return response!.trim().split(RegExp(r'\s+')).length;
  }

  /// Gets the response character count
  int get responseCharacterCount => response?.length ?? 0;

  /// Checks if the response meets minimum requirements
  bool get hasValidResponse {
    if (!hasResponse) return false;
    return responseWordCount >= DomainConstants.minResponseWordCount &&
        responseCharacterCount >= DomainConstants.minResponseCharCount;
  }

  /// Gets the display text for when the question was answered
  String get responseDisplayDate {
    if (responseDate == null) return '';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final responseDay = DateTime(
      responseDate!.year,
      responseDate!.month,
      responseDate!.day,
    );

    if (responseDay.isAtSameMomentAs(today)) {
      return DomainConstants.displayAnsweredToday;
    }

    final yesterday = today.subtract(const Duration(days: 1));
    if (responseDay.isAtSameMomentAs(yesterday)) {
      return DomainConstants.displayAnsweredYesterday;
    }

    final daysDiff = today.difference(responseDay).inDays;
    if (daysDiff < DomainConstants.daysInWeek) {
      return 'Answered $daysDiff days ago';
    }

    return 'Answered on ${responseDate!.day}/${responseDate!.month}/${responseDate!.year}';
  }

  /// Validates the question data
  List<String> validate() {
    final errors = <String>[];

    if (question.trim().isEmpty) {
      errors.add(DomainConstants.errorQuestionRequired);
    }

    if (question.length > DomainConstants.maxQuestionLength) {
      errors.add(DomainConstants.errorQuestionTooLong);
    }

    if (response != null &&
        response!.length > DomainConstants.maxResponseLength) {
      errors.add(DomainConstants.errorResponseTooLong);
    }

    if (response != null &&
        response!.trim().isNotEmpty &&
        responseDate == null) {
      errors.add(DomainConstants.errorResponseDateRequired);
    }

    return errors;
  }

  /// Checks if the question is valid
  bool get isValid => validate().isEmpty;

  @override
  List<Object?> get props => [
    id,
    question,
    category,
    response,
    responseDate,
    createdAt,
  ];

  @override
  String toString() =>
      'QuestionOfTheDay(id: $id, category: ${category.displayName}, hasResponse: $hasResponse)';
}

/// NOTE: Predefined questions have been moved to the data layer
/// See: assets/data/predefined_questions.json
/// 
/// This follows Clean Architecture principles by separating:
/// - Domain layer (business logic) from
/// - Data layer (data sources and fixtures)
/// 
/// To load questions, use a repository or data source in the data layer.
