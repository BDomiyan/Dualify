import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';
import '../../../core/services/question_of_the_day_service.dart';
import '../../../core/validation/validation.dart';
import '../../entities/entities.dart';
import '../../repositories/repositories.dart';
import '../usecase.dart';

/// Parameters for refreshing Question of the Day
class RefreshQotdParams {
  final String? response;
  final bool forceNewQuestion;

  const RefreshQotdParams({this.response, this.forceNewQuestion = false});
}

/// Result for Question of the Day refresh operation
class QotdRefreshResult {
  final QuestionOfTheDay question;
  final bool isNewQuestion;
  final bool wasResponseSaved;

  const QotdRefreshResult({
    required this.question,
    required this.isNewQuestion,
    required this.wasResponseSaved,
  });
}

/// Use case for refreshing Question of the Day
/// Handles both getting new questions and saving responses
class RefreshQotdUseCase
    implements UseCase<QotdRefreshResult, RefreshQotdParams> {
  final ILocalApprenticeshipRepository _repository;
  final QuestionOfTheDayService _questionService;
  final FormValidator _validator;

  RefreshQotdUseCase(this._repository)
    : _questionService = QuestionOfTheDayService(),
      _validator = _createValidator();

  @override
  Future<Either<Failure, QotdRefreshResult>> call(
    RefreshQotdParams params,
  ) async {
    try {
      // If response is provided, validate it first
      if (params.response != null) {
        final validationResult = _validateResponse(params.response!);
        if (!validationResult.isValid) {
          return Left(
            ValidationFailure(
              'Invalid question response',
              fieldErrors: validationResult.fieldErrors,
              code: 'QUESTION_RESPONSE_VALIDATION_FAILED',
            ),
          );
        }
      }

      // Get today's question
      final todaysQuestionResult = await _getTodaysQuestion(
        params.forceNewQuestion,
      );

      return todaysQuestionResult.fold((failure) => Left(failure), (
        question,
      ) async {
        var currentQuestion = question;
        var wasResponseSaved = false;

        // If response is provided, save it
        if (params.response != null && params.response!.trim().isNotEmpty) {
          final saveResponseResult = await _saveQuestionResponse(
            currentQuestion,
            params.response!,
          );

          return saveResponseResult.fold((failure) => Left(failure), (
            updatedQuestion,
          ) {
            return Right(
              QotdRefreshResult(
                question: updatedQuestion,
                isNewQuestion: false,
                wasResponseSaved: true,
              ),
            );
          });
        }

        // If forcing new question or current question is answered, get a new one
        if (params.forceNewQuestion || currentQuestion.hasResponse) {
          final newQuestionResult = await _getNewQuestion();

          return newQuestionResult.fold(
            (failure) {
              // If getting new question fails, return current question
              return Right(
                QotdRefreshResult(
                  question: currentQuestion,
                  isNewQuestion: false,
                  wasResponseSaved: wasResponseSaved,
                ),
              );
            },
            (newQuestion) {
              return Right(
                QotdRefreshResult(
                  question: newQuestion,
                  isNewQuestion: true,
                  wasResponseSaved: wasResponseSaved,
                ),
              );
            },
          );
        }

        // Return current question
        return Right(
          QotdRefreshResult(
            question: currentQuestion,
            isNewQuestion: false,
            wasResponseSaved: wasResponseSaved,
          ),
        );
      });
    } catch (e) {
      return Left(
        DataFailure(
          'Unexpected error refreshing question of the day: ${e.toString()}',
          code: 'QOTD_REFRESH_UNEXPECTED_ERROR',
        ),
      );
    }
  }

  /// Creates the validator for question responses
  static FormValidator _createValidator() {
    return FormValidatorBuilder().addRequiredField('response', [
      LengthRule('Response', minLength: 10, maxLength: 1000),
    ]).build();
  }

  /// Validates the question response
  FormValidationResult _validateResponse(String response) {
    final formData = {'response': response};

    return _validator.validateForm(formData);
  }

  /// Gets today's question
  Future<Either<Failure, QuestionOfTheDay>> _getTodaysQuestion(
    bool forceNew,
  ) async {
    try {
      final today = DateTime.now();
      final questionId = 'qotd_${today.year}_${today.month}_${today.day}';

      if (!forceNew) {
        // Try to get existing question for today
        final existingQuestionResult = await _repository.getQuestionResponse(
          questionId,
        );

        final existingQuestion = existingQuestionResult.fold(
          (failure) => null,
          (question) => question,
        );

        if (existingQuestion != null) {
          return Right(existingQuestion);
        }
      }

      // Generate new question for today
      return await _generateTodaysQuestion(questionId, today);
    } catch (e) {
      return Left(
        DataFailure(
          'Failed to get today\'s question: ${e.toString()}',
          code: 'GET_TODAYS_QUESTION_ERROR',
        ),
      );
    }
  }

  /// Generates a new question for today
  Future<Either<Failure, QuestionOfTheDay>> _generateTodaysQuestion(
    String questionId,
    DateTime today,
  ) async {
    try {
      // Use deterministic algorithm to select category and question
      final categories = QuestionCategory.values;
      final categoryIndex = today.day % categories.length;
      final category = categories[categoryIndex];

      // Load question from service
      final questionData = await _questionService.getDeterministicQuestion(
        today,
        category: category,
      );

      final question = QuestionOfTheDayFactory.fromData(
        id: questionId,
        question: questionData.question,
        category: category,
        createdAt: DateTime(today.year, today.month, today.day),
      );

      // Validate the generated question
      final validationErrors = question.validate();
      if (validationErrors.isNotEmpty) {
        return Left(
          DataFailure(
            'Generated question is invalid: ${validationErrors.join(', ')}',
            code: 'GENERATED_QUESTION_INVALID',
          ),
        );
      }

      return Right(question);
    } catch (e) {
      return Left(
        DataFailure(
          'Failed to generate today\'s question: ${e.toString()}',
          code: 'GENERATE_QUESTION_ERROR',
        ),
      );
    }
  }

  /// Gets a new random question
  Future<Either<Failure, QuestionOfTheDay>> _getNewQuestion() async {
    try {
      final now = DateTime.now();

      // Get a random category based on current time
      final categories = QuestionCategory.values;
      final categoryIndex = now.millisecond % categories.length;
      final category = categories[categoryIndex];

      // Get a random question from the service
      final questionData = await _questionService.getRandomQuestion(
        category: category,
        seed: now.millisecondsSinceEpoch,
      );

      // Generate unique ID
      final questionId = 'qotd_random_${now.millisecondsSinceEpoch}';

      final question = QuestionOfTheDayFactory.fromData(
        id: questionId,
        question: questionData.question,
        category: category,
        createdAt: now,
      );

      // Validate the generated question
      final validationErrors = question.validate();
      if (validationErrors.isNotEmpty) {
        return Left(
          DataFailure(
            'Generated random question is invalid: ${validationErrors.join(', ')}',
            code: 'GENERATED_RANDOM_QUESTION_INVALID',
          ),
        );
      }

      return Right(question);
    } catch (e) {
      return Left(
        DataFailure(
          'Failed to get new random question: ${e.toString()}',
          code: 'GET_NEW_QUESTION_ERROR',
        ),
      );
    }
  }

  /// Saves a response to a question
  Future<Either<Failure, QuestionOfTheDay>> _saveQuestionResponse(
    QuestionOfTheDay question,
    String response,
  ) async {
    try {
      // Create question with response
      final questionWithResponse = question.withResponse(response.trim());

      // Validate the question with response
      final validationErrors = questionWithResponse.validate();
      if (validationErrors.isNotEmpty) {
        return Left(
          ValidationFailure(
            'Question with response validation failed: ${validationErrors.join(', ')}',
            code: 'QUESTION_WITH_RESPONSE_VALIDATION_FAILED',
          ),
        );
      }

      // Check if response meets minimum requirements
      if (!questionWithResponse.hasValidResponse) {
        return Left(
          ValidationFailure(
            'Response must be at least 5 words and 20 characters long',
            code: 'RESPONSE_TOO_SHORT',
          ),
        );
      }

      // Save to repository
      final saveResult = await _repository.saveQuestionResponse(
        questionWithResponse,
      );

      return saveResult.fold((failure) => Left(failure), (savedQuestion) {
        // Verify the saved question
        final verificationErrors = savedQuestion.validate();
        if (verificationErrors.isNotEmpty) {
          return Left(
            DataFailure(
              'Saved question response is invalid: ${verificationErrors.join(', ')}',
              code: 'SAVED_QUESTION_RESPONSE_INVALID',
            ),
          );
        }

        return Right(savedQuestion);
      });
    } catch (e) {
      return Left(
        DataFailure(
          'Unexpected error saving question response: ${e.toString()}',
          code: 'SAVE_QUESTION_RESPONSE_ERROR',
        ),
      );
    }
  }
}
