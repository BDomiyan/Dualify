import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';
import '../../../core/services/question_of_the_day_service.dart';
import '../../entities/entities.dart';
import '../../repositories/repositories.dart';
import '../usecase.dart';

/// Dashboard data aggregation result
class DashboardData {
  final ApprenticeProfile profile;
  final List<DailyLog> recentDailyLogs;
  final DailyLogStatistics dailyLogStatistics;
  final QuestionOfTheDay? todaysQuestion;
  final List<QuestionOfTheDay> recentQuestions;
  final int totalDaysLogged;
  final DateTime lastUpdated;

  const DashboardData({
    required this.profile,
    required this.recentDailyLogs,
    required this.dailyLogStatistics,
    this.todaysQuestion,
    required this.recentQuestions,
    required this.totalDaysLogged,
    required this.lastUpdated,
  });

  /// Gets the progress percentage (0.0 to 1.0)
  double get progressPercentage => profile.progressPercentage;

  /// Gets days remaining in apprenticeship
  int get daysRemaining => profile.daysRemaining;

  /// Gets days elapsed in apprenticeship
  int get daysElapsed => profile.daysElapsed;

  /// Checks if there's a question to answer today
  bool get hasQuestionToAnswer =>
      todaysQuestion != null && !todaysQuestion!.hasResponse;

  /// Gets the most recent daily log
  DailyLog? get mostRecentDailyLog =>
      recentDailyLogs.isNotEmpty ? recentDailyLogs.first : null;

  /// Checks if today's log has been recorded
  bool get hasTodaysLog {
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);

    return recentDailyLogs.any(
      (log) => DateTime(
        log.date.year,
        log.date.month,
        log.date.day,
      ).isAtSameMomentAs(todayOnly),
    );
  }
}

/// Use case for getting comprehensive dashboard data
/// Follows Clean Architecture and Single Responsibility Principle
class GetDashboardDataUseCase implements UseCase<DashboardData, NoParams> {
  final ILocalApprenticeshipRepository _repository;
  final QuestionOfTheDayService _questionService;

  GetDashboardDataUseCase(this._repository)
    : _questionService = QuestionOfTheDayService();

  @override
  Future<Either<Failure, DashboardData>> call(NoParams params) async {
    try {
      // Get profile first - it's required for dashboard
      final profileResult = await _repository.getProfile();

      return profileResult.fold((failure) => Left(failure), (profile) async {
        if (profile == null) {
          return Left(
            DataFailure(
              'No profile found. Please complete onboarding first.',
              code: 'PROFILE_NOT_FOUND',
            ),
          );
        }

        // Validate profile
        final profileErrors = profile.validate();
        if (profileErrors.isNotEmpty) {
          return Left(
            DataFailure(
              'Profile data is invalid: ${profileErrors.join(', ')}',
              code: 'INVALID_PROFILE_DATA',
            ),
          );
        }

        // Get recent daily logs (last 30 days)
        final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
        final today = DateTime.now();

        final recentLogsResult = await _repository.getDailyLogsByDateRange(
          thirtyDaysAgo,
          today,
        );

        return recentLogsResult.fold((failure) => Left(failure), (
          recentLogs,
        ) async {
          // Sort logs by date (most recent first)
          recentLogs.sort((a, b) => b.date.compareTo(a.date));

          // Get daily log statistics for the apprenticeship period
          final statsResult = await _repository.getDailyLogStatistics(
            profile.apprenticeshipStartDate,
            profile.apprenticeshipEndDate,
          );

          return statsResult.fold((failure) => Left(failure), (
            statistics,
          ) async {
            // Get all daily logs count
            final allLogsResult = await _repository.getAllDailyLogs();

            return allLogsResult.fold((failure) => Left(failure), (
              allLogs,
            ) async {
              // Get recent answered questions (last 10)
              final recentQuestionsResult =
                  await _repository.getAnsweredQuestions();

              return recentQuestionsResult.fold((failure) => Left(failure), (
                allQuestions,
              ) async {
                // Sort questions by response date and take last 10
                allQuestions.sort((a, b) {
                  if (a.responseDate == null && b.responseDate == null) {
                    return 0;
                  }
                  if (a.responseDate == null) return 1;
                  if (b.responseDate == null) return -1;
                  return b.responseDate!.compareTo(a.responseDate!);
                });

                final recentQuestions = allQuestions.take(10).toList();

                // Try to get today's question (this might not exist yet)
                final todaysQuestionResult = await _getTodaysQuestion();

                return todaysQuestionResult.fold(
                  (failure) {
                    // If getting today's question fails, continue without it
                    // This is not a critical error for dashboard data
                    return Right(
                      DashboardData(
                        profile: profile,
                        recentDailyLogs: recentLogs,
                        dailyLogStatistics: statistics,
                        todaysQuestion: null,
                        recentQuestions: recentQuestions,
                        totalDaysLogged: allLogs.length,
                        lastUpdated: DateTime.now(),
                      ),
                    );
                  },
                  (todaysQuestion) {
                    return Right(
                      DashboardData(
                        profile: profile,
                        recentDailyLogs: recentLogs,
                        dailyLogStatistics: statistics,
                        todaysQuestion: todaysQuestion,
                        recentQuestions: recentQuestions,
                        totalDaysLogged: allLogs.length,
                        lastUpdated: DateTime.now(),
                      ),
                    );
                  },
                );
              });
            });
          });
        });
      });
    } catch (e) {
      return Left(
        DataFailure(
          'Unexpected error getting dashboard data: ${e.toString()}',
          code: 'DASHBOARD_DATA_UNEXPECTED_ERROR',
        ),
      );
    }
  }

  /// Gets today's question (if any)
  /// This is a helper method that doesn't fail the entire dashboard if it fails
  Future<Either<Failure, QuestionOfTheDay?>> _getTodaysQuestion() async {
    try {
      // Generate a deterministic question based on today's date
      final today = DateTime.now();
      final categories = QuestionCategory.values;
      final categoryIndex = today.day % categories.length;
      final category = categories[categoryIndex];

      // Load question from service
      final questionData = await _questionService.getDeterministicQuestion(
        today,
        category: category,
      );

      // Create a question ID based on today's date
      final questionId = 'qotd_${today.year}_${today.month}_${today.day}';

      // Check if this question already has a response
      final existingResponseResult = await _repository.getQuestionResponse(
        questionId,
      );

      return existingResponseResult.fold(
        (failure) {
          // If getting existing response fails, create a new question without response
          final question = QuestionOfTheDayFactory.fromData(
            id: questionId,
            question: questionData.question,
            category: category,
            createdAt: DateTime(today.year, today.month, today.day),
          );

          return Right(question);
        },
        (existingQuestion) {
          if (existingQuestion != null) {
            return Right(existingQuestion);
          } else {
            // Create new question for today
            final question = QuestionOfTheDayFactory.fromData(
              id: questionId,
              question: questionData.question,
              category: category,
              createdAt: DateTime(today.year, today.month, today.day),
            );

            return Right(question);
          }
        },
      );
    } catch (e) {
      return Left(
        DataFailure(
          'Failed to get today\'s question: ${e.toString()}',
          code: 'TODAYS_QUESTION_ERROR',
        ),
      );
    }
  }
}

/// Extension methods for DashboardData
extension DashboardDataExtensions on DashboardData {
  /// Gets progress data calculated from profile dates
  ProgressCalculationResult get progressData {
    return ProgressCalculationResult.calculate(
      profile.apprenticeshipStartDate,
      profile.apprenticeshipEndDate,
    );
  }

  /// Gets daily logs for the last 7 days
  List<DailyLog> get dailyLogs => recentDailyLogs;

  /// Gets question of the day
  QuestionOfTheDay? get questionOfTheDay => todaysQuestion;
}
