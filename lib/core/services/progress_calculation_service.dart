import '../errors/exceptions.dart';
import '../utils/logger.dart';

/// Service for calculating apprenticeship progress and time-related metrics
/// Provides static methods for progress calculations with comprehensive error handling
class ProgressCalculationService {
  /// Calculates progress percentage based on start and end dates
  /// Returns value between 0.0 and 1.0
  /// Throws ValidationException for invalid inputs
  static double calculateProgressPercentage(
    DateTime startDate,
    DateTime endDate, {
    DateTime? currentDate,
  }) {
    try {
      final now = currentDate ?? DateTime.now();

      // Validate input parameters
      _validateDateRange(startDate, endDate);

      // Calculate total duration
      final totalDuration = endDate.difference(startDate);
      if (totalDuration.inDays <= 0) {
        throw const ValidationException.invalidFormat(
          'Date range',
          'End date must be after start date',
        );
      }

      // Calculate elapsed duration
      final elapsedDuration = now.difference(startDate);

      // Handle edge cases
      if (now.isBefore(startDate)) {
        // Not started yet
        return 0.0;
      } else if (now.isAfter(endDate)) {
        // Already completed
        return 1.0;
      }

      // Calculate progress percentage
      final progress =
          elapsedDuration.inMilliseconds / totalDuration.inMilliseconds;

      // Ensure result is within valid range
      return progress.clamp(0.0, 1.0);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to calculate progress percentage', e, stackTrace);

      if (e is ValidationException) {
        rethrow;
      }

      throw DataException(
        'Progress calculation failed: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Calculates days remaining until end date
  /// Returns 0 if already past end date, total days if not started
  /// Throws ValidationException for invalid inputs
  static int calculateDaysRemaining(
    DateTime startDate,
    DateTime endDate, {
    DateTime? currentDate,
  }) {
    try {
      final now = currentDate ?? DateTime.now();

      // Validate input parameters
      _validateDateRange(startDate, endDate);

      // Handle edge cases
      if (now.isAfter(endDate)) {
        // Already completed
        return 0;
      } else if (now.isBefore(startDate)) {
        // Not started yet - return total duration
        return endDate.difference(startDate).inDays;
      }

      // Calculate remaining days
      final remainingDuration = endDate.difference(now);
      return remainingDuration.inDays.clamp(0, double.infinity).toInt();
    } catch (e, stackTrace) {
      AppLogger.error('Failed to calculate days remaining', e, stackTrace);

      if (e is ValidationException) {
        rethrow;
      }

      throw DataException(
        'Days remaining calculation failed: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Calculates days elapsed since start date
  /// Returns 0 if not started yet, total days if completed
  /// Throws ValidationException for invalid inputs
  static int calculateDaysElapsed(
    DateTime startDate,
    DateTime endDate, {
    DateTime? currentDate,
  }) {
    try {
      final now = currentDate ?? DateTime.now();

      // Validate input parameters
      _validateDateRange(startDate, endDate);

      // Handle edge cases
      if (now.isBefore(startDate)) {
        // Not started yet
        return 0;
      } else if (now.isAfter(endDate)) {
        // Already completed - return total duration
        return endDate.difference(startDate).inDays;
      }

      // Calculate elapsed days
      final elapsedDuration = now.difference(startDate);
      return elapsedDuration.inDays.clamp(0, double.infinity).toInt();
    } catch (e, stackTrace) {
      AppLogger.error('Failed to calculate days elapsed', e, stackTrace);

      if (e is ValidationException) {
        rethrow;
      }

      throw DataException(
        'Days elapsed calculation failed: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Calculates total duration in days
  /// Throws ValidationException for invalid inputs
  static int calculateTotalDays(DateTime startDate, DateTime endDate) {
    try {
      // Validate input parameters
      _validateDateRange(startDate, endDate);

      final totalDuration = endDate.difference(startDate);
      return totalDuration.inDays;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to calculate total days', e, stackTrace);

      if (e is ValidationException) {
        rethrow;
      }

      throw DataException(
        'Total days calculation failed: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Calculates total duration in months (approximate)
  /// Uses average of 30.44 days per month
  /// Throws ValidationException for invalid inputs
  static int calculateTotalMonths(DateTime startDate, DateTime endDate) {
    try {
      final totalDays = calculateTotalDays(startDate, endDate);
      return (totalDays / 30.44).round();
    } catch (e, stackTrace) {
      AppLogger.error('Failed to calculate total months', e, stackTrace);

      if (e is ValidationException) {
        rethrow;
      }

      throw DataException(
        'Total months calculation failed: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Calculates total duration in years (approximate)
  /// Uses 365.25 days per year to account for leap years
  /// Throws ValidationException for invalid inputs
  static double calculateTotalYears(DateTime startDate, DateTime endDate) {
    try {
      final totalDays = calculateTotalDays(startDate, endDate);
      return totalDays / 365.25;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to calculate total years', e, stackTrace);

      if (e is ValidationException) {
        rethrow;
      }

      throw DataException(
        'Total years calculation failed: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Determines apprenticeship status based on dates
  /// Throws ValidationException for invalid inputs
  static ApprenticeshipStatus getApprenticeshipStatus(
    DateTime startDate,
    DateTime endDate, {
    DateTime? currentDate,
  }) {
    try {
      final now = currentDate ?? DateTime.now();

      // Validate input parameters
      _validateDateRange(startDate, endDate);

      if (now.isBefore(startDate)) {
        return ApprenticeshipStatus.notStarted;
      } else if (now.isAfter(endDate)) {
        return ApprenticeshipStatus.completed;
      } else {
        return ApprenticeshipStatus.active;
      }
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to determine apprenticeship status',
        e,
        stackTrace,
      );

      if (e is ValidationException) {
        rethrow;
      }

      throw DataException(
        'Status determination failed: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Calculates estimated completion date based on current progress
  /// Returns null if apprenticeship is already completed or not started
  /// Throws ValidationException for invalid inputs
  static DateTime? calculateEstimatedCompletion(
    DateTime startDate,
    DateTime endDate,
    double currentProgress, {
    DateTime? currentDate,
  }) {
    try {
      final now = currentDate ?? DateTime.now();

      // Validate input parameters
      _validateDateRange(startDate, endDate);
      _validateProgress(currentProgress);

      final status = getApprenticeshipStatus(
        startDate,
        endDate,
        currentDate: now,
      );

      // Only calculate for active apprenticeships
      if (status != ApprenticeshipStatus.active) {
        return null;
      }

      // If no progress, return original end date
      if (currentProgress <= 0.0) {
        return endDate;
      }

      // Calculate estimated completion based on current rate
      final elapsedDays = calculateDaysElapsed(
        startDate,
        endDate,
        currentDate: now,
      );
      final progressRate = currentProgress / elapsedDays;

      if (progressRate <= 0.0) {
        return endDate;
      }

      final estimatedTotalDays = (1.0 / progressRate).round();
      return startDate.add(Duration(days: estimatedTotalDays));
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to calculate estimated completion',
        e,
        stackTrace,
      );

      if (e is ValidationException) {
        rethrow;
      }

      throw DataException(
        'Estimated completion calculation failed: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Calculates milestone dates (25%, 50%, 75% completion)
  /// Throws ValidationException for invalid inputs
  static Map<String, DateTime> calculateMilestoneDates(
    DateTime startDate,
    DateTime endDate,
  ) {
    try {
      // Validate input parameters
      _validateDateRange(startDate, endDate);

      final totalDuration = endDate.difference(startDate);

      return {
        '25%': startDate.add(
          Duration(milliseconds: (totalDuration.inMilliseconds * 0.25).round()),
        ),
        '50%': startDate.add(
          Duration(milliseconds: (totalDuration.inMilliseconds * 0.50).round()),
        ),
        '75%': startDate.add(
          Duration(milliseconds: (totalDuration.inMilliseconds * 0.75).round()),
        ),
      };
    } catch (e, stackTrace) {
      AppLogger.error('Failed to calculate milestone dates', e, stackTrace);

      if (e is ValidationException) {
        rethrow;
      }

      throw DataException(
        'Milestone calculation failed: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Calculates working days between two dates (excludes weekends)
  /// Throws ValidationException for invalid inputs
  static int calculateWorkingDays(DateTime startDate, DateTime endDate) {
    try {
      // Validate input parameters
      _validateDateRange(startDate, endDate);

      int workingDays = 0;
      DateTime current = DateTime(
        startDate.year,
        startDate.month,
        startDate.day,
      );
      final end = DateTime(endDate.year, endDate.month, endDate.day);

      while (current.isBefore(end) || current.isAtSameMomentAs(end)) {
        // Monday = 1, Sunday = 7
        if (current.weekday >= 1 && current.weekday <= 5) {
          workingDays++;
        }
        current = current.add(const Duration(days: 1));
      }

      return workingDays;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to calculate working days', e, stackTrace);

      if (e is ValidationException) {
        rethrow;
      }

      throw DataException(
        'Working days calculation failed: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Validates date range parameters
  static void _validateDateRange(DateTime startDate, DateTime endDate) {
    if (endDate.isBefore(startDate) || endDate.isAtSameMomentAs(startDate)) {
      throw const ValidationException.outOfRange(
        'Date range',
        'End date must be after start date',
      );
    }

    // Check for reasonable date range (not more than 10 years)
    final duration = endDate.difference(startDate);
    if (duration.inDays > 365 * 10) {
      throw const ValidationException.outOfRange(
        'Date range',
        'Duration cannot exceed 10 years',
      );
    }

    // Check for minimum duration (at least 1 day)
    if (duration.inDays < 1) {
      throw const ValidationException.outOfRange(
        'Date range',
        'Duration must be at least 1 day',
      );
    }
  }

  /// Validates progress value
  static void _validateProgress(double progress) {
    if (progress < 0.0 || progress > 1.0) {
      throw const ValidationException.outOfRange(
        'Progress',
        'Progress must be between 0.0 and 1.0',
      );
    }
  }
}

/// Enumeration for apprenticeship status
enum ApprenticeshipStatus {
  notStarted('Not Started'),
  active('Active'),
  completed('Completed');

  const ApprenticeshipStatus(this.displayName);
  final String displayName;
}

/// Progress calculation result with comprehensive metrics
class ProgressCalculationResult {
  final double progressPercentage;
  final int daysElapsed;
  final int daysRemaining;
  final int totalDays;
  final int totalMonths;
  final double totalYears;
  final ApprenticeshipStatus status;
  final DateTime? estimatedCompletion;
  final Map<String, DateTime> milestones;
  final int workingDays;
  final int workingDaysElapsed;
  final int workingDaysRemaining;

  const ProgressCalculationResult({
    required this.progressPercentage,
    required this.daysElapsed,
    required this.daysRemaining,
    required this.totalDays,
    required this.totalMonths,
    required this.totalYears,
    required this.status,
    this.estimatedCompletion,
    required this.milestones,
    required this.workingDays,
    required this.workingDaysElapsed,
    required this.workingDaysRemaining,
  });

  /// Factory method to calculate all progress metrics at once
  factory ProgressCalculationResult.calculate(
    DateTime startDate,
    DateTime endDate, {
    DateTime? currentDate,
  }) {
    final now = currentDate ?? DateTime.now();

    final progressPercentage =
        ProgressCalculationService.calculateProgressPercentage(
          startDate,
          endDate,
          currentDate: now,
        );

    final daysElapsed = ProgressCalculationService.calculateDaysElapsed(
      startDate,
      endDate,
      currentDate: now,
    );

    final daysRemaining = ProgressCalculationService.calculateDaysRemaining(
      startDate,
      endDate,
      currentDate: now,
    );

    final totalDays = ProgressCalculationService.calculateTotalDays(
      startDate,
      endDate,
    );
    final totalMonths = ProgressCalculationService.calculateTotalMonths(
      startDate,
      endDate,
    );
    final totalYears = ProgressCalculationService.calculateTotalYears(
      startDate,
      endDate,
    );

    final status = ProgressCalculationService.getApprenticeshipStatus(
      startDate,
      endDate,
      currentDate: now,
    );

    final estimatedCompletion =
        ProgressCalculationService.calculateEstimatedCompletion(
          startDate,
          endDate,
          progressPercentage,
          currentDate: now,
        );

    final milestones = ProgressCalculationService.calculateMilestoneDates(
      startDate,
      endDate,
    );

    final workingDays = ProgressCalculationService.calculateWorkingDays(
      startDate,
      endDate,
    );

    final workingDaysElapsed =
        status == ApprenticeshipStatus.notStarted
            ? 0
            : ProgressCalculationService.calculateWorkingDays(
              startDate,
              status == ApprenticeshipStatus.completed ? endDate : now,
            );

    final workingDaysRemaining =
        status == ApprenticeshipStatus.completed
            ? 0
            : ProgressCalculationService.calculateWorkingDays(
              status == ApprenticeshipStatus.notStarted ? startDate : now,
              endDate,
            );

    return ProgressCalculationResult(
      progressPercentage: progressPercentage,
      daysElapsed: daysElapsed,
      daysRemaining: daysRemaining,
      totalDays: totalDays,
      totalMonths: totalMonths,
      totalYears: totalYears,
      status: status,
      estimatedCompletion: estimatedCompletion,
      milestones: milestones,
      workingDays: workingDays,
      workingDaysElapsed: workingDaysElapsed,
      workingDaysRemaining: workingDaysRemaining,
    );
  }

  /// Gets progress percentage as integer (0-100)
  int get progressPercentageInt => (progressPercentage * 100).round();

  /// Checks if apprenticeship is on track (comparing actual vs expected progress)
  bool get isOnTrack {
    if (status != ApprenticeshipStatus.active) return true;

    final expectedProgress = daysElapsed / totalDays;
    const tolerance = 0.05; // 5% tolerance

    return (progressPercentage - expectedProgress).abs() <= tolerance;
  }

  /// Gets a human-readable status description
  String get statusDescription {
    switch (status) {
      case ApprenticeshipStatus.notStarted:
        return 'Apprenticeship starts in $daysRemaining days';
      case ApprenticeshipStatus.active:
        return '$daysRemaining days remaining ($progressPercentageInt% complete)';
      case ApprenticeshipStatus.completed:
        return 'Apprenticeship completed';
    }
  }
}
