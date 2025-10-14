import 'package:equatable/equatable.dart';

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
    return responseWordCount >= 5 && responseCharacterCount >= 20;
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
      return 'Answered today';
    }

    final yesterday = today.subtract(const Duration(days: 1));
    if (responseDay.isAtSameMomentAs(yesterday)) {
      return 'Answered yesterday';
    }

    final daysDiff = today.difference(responseDay).inDays;
    if (daysDiff < 7) {
      return 'Answered $daysDiff days ago';
    }

    return 'Answered on ${responseDate!.day}/${responseDate!.month}/${responseDate!.year}';
  }

  /// Validates the question data
  List<String> validate() {
    final errors = <String>[];

    if (question.trim().isEmpty) {
      errors.add('Question text is required');
    }

    if (question.length > 500) {
      errors.add('Question text cannot exceed 500 characters');
    }

    if (response != null && response!.length > 2000) {
      errors.add('Response cannot exceed 2000 characters');
    }

    if (response != null &&
        response!.trim().isNotEmpty &&
        responseDate == null) {
      errors.add('Response date is required when response is provided');
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

/// Enumeration for question categories
enum QuestionCategory {
  learning('learning', 'Learning', '📚', 'Questions about what you learned'),
  problemSolving(
    'problem-solving',
    'Problem Solving',
    '🧩',
    'Questions about challenges and solutions',
  ),
  achievement(
    'achievement',
    'Achievement',
    '🏆',
    'Questions about accomplishments and milestones',
  ),
  reflection(
    'reflection',
    'Reflection',
    '🤔',
    'Questions for self-reflection and growth',
  ),
  skills('skills', 'Skills', '🛠️', 'Questions about skill development'),
  teamwork(
    'teamwork',
    'Teamwork',
    '👥',
    'Questions about collaboration and communication',
  ),
  safety(
    'safety',
    'Safety',
    '⚠️',
    'Questions about workplace safety and best practices',
  ),
  goals('goals', 'Goals', '🎯', 'Questions about future goals and aspirations');

  const QuestionCategory(
    this.value,
    this.displayName,
    this.emoji,
    this.description,
  );

  final String value;
  final String displayName;
  final String emoji;
  final String description;

  /// Gets category from string value
  static QuestionCategory fromValue(String value) {
    return QuestionCategory.values.firstWhere(
      (category) => category.value == value,
      orElse: () => QuestionCategory.reflection,
    );
  }

  /// Gets all available categories
  static List<QuestionCategory> get allCategories => QuestionCategory.values;

  /// Gets the display text with emoji
  String get displayTextWithEmoji => '$emoji $displayName';
}

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
    return 'qotd_${timestamp}_$random';
  }
}

/// Predefined questions for each category
class PredefinedQuestions {
  /// Learning category questions
  static const List<String> learningQuestions = [
    'What new skill or technique did you learn today?',
    'What was the most interesting thing you discovered during your work?',
    'How did you apply something you learned in school to your work today?',
    'What would you like to learn more about based on today\'s experience?',
    'What concept that seemed difficult before makes more sense now?',
    'How has your understanding of your trade evolved this week?',
    'What learning resource (book, video, mentor) helped you most recently?',
    'What mistake taught you the most valuable lesson?',
  ];

  /// Problem-solving category questions
  static const List<String> problemSolvingQuestions = [
    'What challenge did you face today and how did you overcome it?',
    'Describe a problem you solved using creative thinking.',
    'What tools or techniques helped you troubleshoot an issue?',
    'How did you approach a task you\'ve never done before?',
    'What would you do differently if you encountered the same problem again?',
    'Who did you ask for help when you were stuck, and what did you learn?',
    'What problem-solving strategy worked best for you this week?',
    'How do you break down complex problems into manageable parts?',
  ];

  /// Achievement category questions
  static const List<String> achievementQuestions = [
    'What accomplishment are you most proud of this week?',
    'How did you exceed expectations on a recent task?',
    'What positive feedback did you receive from your supervisor or mentor?',
    'What milestone in your apprenticeship did you recently reach?',
    'How have you improved compared to when you first started?',
    'What project or task gave you the greatest sense of satisfaction?',
    'What recognition or praise meant the most to you recently?',
    'How did you help a colleague or contribute to team success?',
  ];

  /// Reflection category questions
  static const List<String> reflectionQuestions = [
    'What aspect of your trade do you find most rewarding?',
    'How has your confidence grown since starting your apprenticeship?',
    'What values are most important to you in your work?',
    'How do you maintain motivation during challenging times?',
    'What advice would you give to someone just starting their apprenticeship?',
    'How do you balance learning with productivity?',
    'What personal strengths have you discovered through your work?',
    'How has your apprenticeship changed your perspective on your career?',
  ];

  /// Skills category questions
  static const List<String> skillsQuestions = [
    'What technical skill are you most eager to develop further?',
    'How do you practice and refine your craft outside of work hours?',
    'What soft skills have become more important than you initially thought?',
    'How do you stay current with new technologies in your field?',
    'What skill gap are you working to close?',
    'How do you measure your progress in skill development?',
    'What certification or qualification are you working toward?',
    'How do you learn best - through observation, practice, or instruction?',
  ];

  /// Teamwork category questions
  static const List<String> teamworkQuestions = [
    'How did you collaborate effectively with others today?',
    'What did you learn from observing experienced colleagues?',
    'How do you communicate technical information to non-technical people?',
    'What role do you typically play in team projects?',
    'How do you handle disagreements or conflicts in the workplace?',
    'What makes a good mentor in your opinion?',
    'How do you contribute to a positive work environment?',
    'What have you learned about leadership through your apprenticeship?',
  ];

  /// Safety category questions
  static const List<String> safetyQuestions = [
    'What safety practice did you follow particularly well today?',
    'How do you stay alert and focused during repetitive tasks?',
    'What potential hazard did you identify and address?',
    'How do you ensure you\'re using personal protective equipment correctly?',
    'What safety tip would you share with other apprentices?',
    'How do you balance efficiency with safety requirements?',
    'What safety training has been most valuable to you?',
    'How do you speak up when you notice unsafe conditions?',
  ];

  /// Goals category questions
  static const List<String> goalsQuestions = [
    'What do you hope to achieve by the end of your apprenticeship?',
    'Where do you see yourself in five years?',
    'What specialization within your trade interests you most?',
    'How are you preparing for your journeyman certification?',
    'What additional training or education are you considering?',
    'What type of projects would you like to work on in the future?',
    'How do you plan to give back to the apprenticeship community?',
    'What legacy do you want to leave in your trade?',
  ];

  /// Gets all questions for a specific category
  static List<String> getQuestionsForCategory(QuestionCategory category) {
    switch (category) {
      case QuestionCategory.learning:
        return learningQuestions;
      case QuestionCategory.problemSolving:
        return problemSolvingQuestions;
      case QuestionCategory.achievement:
        return achievementQuestions;
      case QuestionCategory.reflection:
        return reflectionQuestions;
      case QuestionCategory.skills:
        return skillsQuestions;
      case QuestionCategory.teamwork:
        return teamworkQuestions;
      case QuestionCategory.safety:
        return safetyQuestions;
      case QuestionCategory.goals:
        return goalsQuestions;
    }
  }

  /// Gets all questions from all categories
  static List<String> getAllQuestions() {
    return [
      ...learningQuestions,
      ...problemSolvingQuestions,
      ...achievementQuestions,
      ...reflectionQuestions,
      ...skillsQuestions,
      ...teamworkQuestions,
      ...safetyQuestions,
      ...goalsQuestions,
    ];
  }

  /// Gets a random question from a specific category
  static String getRandomQuestionFromCategory(QuestionCategory category) {
    final questions = getQuestionsForCategory(category);
    final randomIndex =
        DateTime.now().millisecondsSinceEpoch % questions.length;
    return questions[randomIndex];
  }

  /// Gets a deterministic question based on date and category
  static String getDeterministicQuestion(
    DateTime date,
    QuestionCategory category,
  ) {
    final questions = getQuestionsForCategory(category);
    final dayOfYear = date.difference(DateTime(date.year, 1, 1)).inDays;
    final index = dayOfYear % questions.length;
    return questions[index];
  }
}
