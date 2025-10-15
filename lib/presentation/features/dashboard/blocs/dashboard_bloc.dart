import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/logger.dart';
import '../../../../domain/entities/entities.dart';
import '../../../../domain/usecases/usecases.dart';
import 'dashboard_data.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

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

          final dashboardData = DashboardViewModel(
            profile: dashboardResult.profile,
            progressData: dashboardResult.progressData,
            dailyLogs: dashboardResult.recentDailyLogs,
            questionOfTheDay: dashboardResult.todaysQuestion,
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
    switch (failure) {
      case NetworkFailure():
        return true; // Network issues are usually temporary
      case DatabaseFailure():
        final dbFailure = failure;
        // Some database errors are not recoverable
        return dbFailure.code != 'DB_008'; // Data corruption
      case ValidationFailure():
        return true; // User can correct validation errors
      case StorageFailure():
        return true; // Storage issues are usually temporary
      default:
        return true; // Default to recoverable
    }
  }

  /// Gets the current dashboard data
  DashboardViewModel? get currentDashboardData {
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
