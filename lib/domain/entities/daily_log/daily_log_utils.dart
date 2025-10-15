import '../../../core/constants/domain_constants.dart';
import 'daily_log.dart';
import 'daily_log_statistics.dart';
import 'daily_log_status.dart';

/// Utility class for working with daily logs
class DailyLogUtils {
  /// Generates a list of dates for the past 7 days including today
  static List<DateTime> generateSevenDayRange([DateTime? centerDate]) {
    final center = centerDate ?? DateTime.now();
    final centerDateOnly = DateTime(center.year, center.month, center.day);

    return List.generate(DomainConstants.dailyLogDisplayDays, (index) {
      return centerDateOnly.subtract(
        Duration(days: DomainConstants.dailyLogDateOffset - index),
      );
    });
  }

  /// Gets the week range that includes the given date
  static List<DateTime> getWeekRange(DateTime date) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    final weekday = dateOnly.weekday; // 1 = Monday, 7 = Sunday

    // Calculate Monday of the week
    final monday = dateOnly.subtract(Duration(days: weekday - 1));

    return List.generate(DomainConstants.daysInWeek, (index) {
      return monday.add(Duration(days: index));
    });
  }

  /// Checks if a date is within the apprenticeship period
  static bool isDateInApprenticeshipPeriod(
    DateTime date,
    DateTime apprenticeshipStart,
    DateTime apprenticeshipEnd,
  ) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    final startOnly = DateTime(
      apprenticeshipStart.year,
      apprenticeshipStart.month,
      apprenticeshipStart.day,
    );
    final endOnly = DateTime(
      apprenticeshipEnd.year,
      apprenticeshipEnd.month,
      apprenticeshipEnd.day,
    );

    return (dateOnly.isAtSameMomentAs(startOnly) ||
            dateOnly.isAfter(startOnly)) &&
        (dateOnly.isAtSameMomentAs(endOnly) || dateOnly.isBefore(endOnly));
  }

  /// Calculates statistics for a list of daily logs
  static DailyLogStatistics calculateStatistics(List<DailyLog> logs) {
    if (logs.isEmpty) {
      return const DailyLogStatistics(
        totalDays: 0,
        learningDays: 0,
        challengingDays: 0,
        neutralDays: 0,
        goodDays: 0,
      );
    }

    final statusCounts = <DailyLogStatus, int>{};
    for (final status in DailyLogStatus.values) {
      statusCounts[status] = 0;
    }

    for (final log in logs) {
      statusCounts[log.status] = (statusCounts[log.status] ?? 0) + 1;
    }

    return DailyLogStatistics(
      totalDays: logs.length,
      learningDays: statusCounts[DailyLogStatus.learning] ?? 0,
      challengingDays: statusCounts[DailyLogStatus.challenging] ?? 0,
      neutralDays: statusCounts[DailyLogStatus.neutral] ?? 0,
      goodDays: statusCounts[DailyLogStatus.good] ?? 0,
    );
  }
}
