import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/logger.dart';
import '../../../../domain/entities/entities.dart';
import '../../../../domain/usecases/usecases.dart';

// Events
abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

class DashboardLoadRequested extends DashboardEvent {
  const DashboardLoadRequested();
}

class DashboardRefreshRequested extends DashboardEvent {
  const DashboardRefreshRequested();
}

class DailyStatusUpdateRequested extends DashboardEvent {
  final DateTime date;
  final String status;
  final String? notes;

  const DailyStatusUpdateRequested({
    required this.date,
    required this.status,
    this.notes,
  });

  @override
  List<Object?> get props => [date, status, notes];
}

class QuestionOfTheDayRefreshRequested extends DashboardEvent {
  const QuestionOfTheDayRefreshRequested();
}

// States
abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {
  const DashboardInitial();
}

class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

class DashboardLoaded extends DashboardState {
  final DashboardData dashboardData;

  const DashboardLoaded({required this.dashboardData});

  @override
  List<Object?> get props => [dashboardData];
}

class DashboardError extends DashboardState {
  final String message;
  final String? code;
  final bool isRecoverable;

  const DashboardError({
    required this.message,
    this.code,
    this.isRecoverable = true,
  });

  @override
  List<Object?> get props => [message, code, isRecoverable];
}

class DashboardUpdating extends DashboardState {
  final DashboardData currentData;
  final String updateType;

  const DashboardUpdating({
    required this.currentData,
    required this.updateType,
  });

  @override
  List<Object?> get props => [currentData, updateType];
}

// Dashboard Data Model
class DashboardData extends Equatable {
  final ApprenticeProfile? profile;
  final ProgressCalculationResult? progressData;
  final List<DailyLog> dailyLogs;
  final QuestionOfTheDay? questionOfTheDay;
  final DateTime lastUpdated;

  const DashboardData({
    this.profile,
    this.progressData,
    this.dailyLogs = const [],
    this.questionOfTheDay,
    required this.lastUpdated,
  });

  @override
  List<Object?> get props => [
    profile,
    progressData,
    dailyLogs,
    questionOfTheDay,
    lastUpdated,
  ];

  DashboardData copyWith({
    ApprenticeProfile? profile,
    ProgressCalculationResult? progressData,
    List<DailyLog>? dailyLogs,
    QuestionOfTheDay? questionOfTheDay,
    DateTime? lastUpdated,
  }) {
    return DashboardData(
      profile: profile ?? this.profile,
      progressData: progressData ?? this.progressData,
      dailyLogs: dailyLogs ?? this.dailyLogs,
      questionOfTheDay: questionOfTheDay ?? this.questionOfTheDay,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  /// Gets daily logs for the last 7 days
  List<DailyLog> get recentDailyLogs {
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 6));

    return dailyLogs
        .where(
          (log) =>
              log.date.isAfter(
                sevenDaysAgo.subtract(const Duration(days: 1)),
              ) &&
              log.date.isBefore(now.add(const Duration(days: 1))),
        )
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  /// Checks if profile setup is complete
  bool get isProfileComplete => profile != null;

  /// Checks if there are any daily logs
  bool get hasDailyLogs => dailyLogs.isNotEmpty;

  /// Gets the current streak of logged days
  int get currentStreak {
    if (dailyLogs.isEmpty) return 0;

    final sortedLogs = List<DailyLog>.from(dailyLogs)
      ..sort((a, b) => b.date.compareTo(a.date));

    int streak = 0;
    DateTime currentDate = DateTime.now();

    for (final log in sortedLogs) {
      final daysDifference = currentDate.difference(log.date).inDays;

      if (daysDifference == streak) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }
}

// BLoC
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetDashboardDataUseCase _getDashboardDataUseCase;
  final UpdateDailyStatusUseCase _updateDailyStatusUseCase;
  final RefreshQotdUseCase _refreshQotdUseCase;

  DashboardBloc({
    required GetDashboardDataUseCase getDashboardDataUseCase,
    required UpdateDailyStatusUseCase updateDailyStatusUseCase,
    required RefreshQotdUseCase refreshQotdUseCase,
  }) : _getDashboardDataUseCase = getDashboardDataUseCase,
       _updateDailyStatusUseCase = updateDailyStatusUseCase,
       _refreshQotdUseCase = refreshQotdUseCase,
       super(const DashboardInitial()) {
    // Register event handlers
    on<DashboardLoadRequested>(_onDashboardLoadRequested);
    on<DashboardRefreshRequested>(_onDashboardRefreshRequested);
    on<DailyStatusUpdateRequested>(_onDailyStatusUpdateRequested);
    on<QuestionOfTheDayRefreshRequested>(_onQuestionOfTheDayRefreshRequested);
  }

  /// Handles dashboard load request
  Future<void> _onDashboardLoadRequested(
    DashboardLoadRequested event,
    Emitter<DashboardState> emit,
  ) async {
    try {
      AppLogger.debug('Loading dashboard data');
      emit(const DashboardLoading());

      final result = await _getDashboardDataUseCase(const NoParams());

      result.fold(
        (failure) {
          AppLogger.error('Dashboard load failed: ${failure.message}');
          emit(
            DashboardError(
              message: failure.message,
              code: failure.code,
              isRecoverable: _isRecoverableFailure(failure),
            ),
          );
        },
        (dashboardResult) {
          AppLogger.info('Dashboard loaded successfully');

          final dashboardData = DashboardData(
            profile: dashboardResult.profile,
            progressData: dashboardResult.progressData,
            dailyLogs: dashboardResult.dailyLogs,
            questionOfTheDay: dashboardResult.questionOfTheDay,
            lastUpdated: DateTime.now(),
          );

          emit(DashboardLoaded(dashboardData: dashboardData));
        },
      );
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error during dashboard load', e, stackTrace);
      emit(
        const DashboardError(
          message: 'An unexpected error occurred while loading dashboard',
          isRecoverable: true,
        ),
      );
    }
  }

  /// Handles dashboard refresh request
  Future<void> _onDashboardRefreshRequested(
    DashboardRefreshRequested event,
    Emitter<DashboardState> emit,
  ) async {
    // Refresh is the same as load but we keep current data during loading
    final currentState = state;
    if (currentState is DashboardLoaded) {
      emit(
        DashboardUpdating(
          currentData: currentState.dashboardData,
          updateType: 'refresh',
        ),
      );
    }

    add(const DashboardLoadRequested());
  }

  /// Handles daily status update request
  Future<void> _onDailyStatusUpdateRequested(
    DailyStatusUpdateRequested event,
    Emitter<DashboardState> emit,
  ) async {
    try {
      final currentState = state;
      if (currentState is! DashboardLoaded) {
        AppLogger.warning(
          'Cannot update daily status: no dashboard data loaded',
        );
        emit(
          const DashboardError(
            message: 'No dashboard data loaded',
            code: 'NO_DASHBOARD_DATA',
            isRecoverable: false,
          ),
        );
        return;
      }

      AppLogger.info(
        'Updating daily status for ${event.date}: ${event.status}',
      );
      emit(
        DashboardUpdating(
          currentData: currentState.dashboardData,
          updateType: 'daily_status',
        ),
      );

      // Convert string status to DailyLogStatus enum
      final statusEnum = DailyLogStatus.values.firstWhere(
        (status) => status.value == event.status,
        orElse: () => DailyLogStatus.neutral,
      );

      final params = UpdateDailyStatusParams(
        date: event.date,
        status: statusEnum,
        notes: event.notes,
      );

      final result = await _updateDailyStatusUseCase(params);

      result.fold(
        (failure) {
          AppLogger.error('Daily status update failed: ${failure.message}');
          emit(
            DashboardError(
              message: failure.message,
              code: failure.code,
              isRecoverable: _isRecoverableFailure(failure),
            ),
          );
        },
        (updatedLog) {
          AppLogger.info('Daily status updated successfully');

          // Update the daily logs list with the new/updated log
          final updatedLogs = List<DailyLog>.from(
            currentState.dashboardData.dailyLogs,
          );
          final existingIndex = updatedLogs.indexWhere(
            (log) =>
                log.date.year == event.date.year &&
                log.date.month == event.date.month &&
                log.date.day == event.date.day,
          );

          if (existingIndex >= 0) {
            updatedLogs[existingIndex] = updatedLog;
          } else {
            updatedLogs.add(updatedLog);
          }

          final updatedDashboardData = currentState.dashboardData.copyWith(
            dailyLogs: updatedLogs,
            lastUpdated: DateTime.now(),
          );

          emit(DashboardLoaded(dashboardData: updatedDashboardData));
        },
      );
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error during daily status update',
        e,
        stackTrace,
      );
      emit(
        const DashboardError(
          message: 'An unexpected error occurred while updating daily status',
          isRecoverable: true,
        ),
      );
    }
  }

  /// Handles question of the day refresh request
  Future<void> _onQuestionOfTheDayRefreshRequested(
    QuestionOfTheDayRefreshRequested event,
    Emitter<DashboardState> emit,
  ) async {
    try {
      final currentState = state;
      if (currentState is! DashboardLoaded) {
        AppLogger.warning('Cannot refresh QOTD: no dashboard data loaded');
        emit(
          const DashboardError(
            message: 'No dashboard data loaded',
            code: 'NO_DASHBOARD_DATA',
            isRecoverable: false,
          ),
        );
        return;
      }

      AppLogger.info('Refreshing question of the day');
      emit(
        DashboardUpdating(
          currentData: currentState.dashboardData,
          updateType: 'qotd_refresh',
        ),
      );

      final result = await _refreshQotdUseCase(
        const RefreshQotdParams(forceNewQuestion: true),
      );

      result.fold(
        (failure) {
          AppLogger.error('QOTD refresh failed: ${failure.message}');
          emit(
            DashboardError(
              message: failure.message,
              code: failure.code,
              isRecoverable: _isRecoverableFailure(failure),
            ),
          );
        },
        (refreshResult) {
          AppLogger.info('QOTD refreshed successfully');

          final updatedDashboardData = currentState.dashboardData.copyWith(
            questionOfTheDay: refreshResult.question,
            lastUpdated: DateTime.now(),
          );

          emit(DashboardLoaded(dashboardData: updatedDashboardData));
        },
      );
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error during QOTD refresh', e, stackTrace);
      emit(
        const DashboardError(
          message: 'An unexpected error occurred while refreshing question',
          isRecoverable: true,
        ),
      );
    }
  }

  /// Determines if a failure is recoverable
  bool _isRecoverableFailure(Failure failure) {
    switch (failure.runtimeType) {
      case NetworkFailure:
        return true; // Network issues are usually temporary
      case DatabaseFailure:
        final dbFailure = failure as DatabaseFailure;
        // Some database errors are not recoverable
        return dbFailure.code != 'DB_008'; // Data corruption
      case ValidationFailure:
        return true; // User can correct validation errors
      case StorageFailure:
        return true; // Storage issues are usually temporary
      default:
        return true; // Default to recoverable
    }
  }

  /// Gets the current dashboard data
  DashboardData? get currentDashboardData {
    final currentState = state;
    if (currentState is DashboardLoaded) {
      return currentState.dashboardData;
    } else if (currentState is DashboardUpdating) {
      return currentState.currentData;
    }
    return null;
  }

  /// Gets the current profile
  ApprenticeProfile? get currentProfile => currentDashboardData?.profile;

  /// Gets the current progress data
  ProgressCalculationResult? get currentProgressData =>
      currentDashboardData?.progressData;

  /// Gets the recent daily logs
  List<DailyLog> get recentDailyLogs =>
      currentDashboardData?.recentDailyLogs ?? [];

  /// Gets the current question of the day
  QuestionOfTheDay? get currentQuestionOfTheDay =>
      currentDashboardData?.questionOfTheDay;

  /// Checks if dashboard is loading
  bool get isLoading => state is DashboardLoading;

  /// Checks if dashboard is updating
  bool get isUpdating => state is DashboardUpdating;

  /// Gets the current error message if any
  String? get errorMessage {
    final currentState = state;
    if (currentState is DashboardError) {
      return currentState.message;
    }
    return null;
  }

  /// Checks if profile setup is complete
  bool get isProfileComplete =>
      currentDashboardData?.isProfileComplete ?? false;

  /// Gets the current streak
  int get currentStreak => currentDashboardData?.currentStreak ?? 0;
}
