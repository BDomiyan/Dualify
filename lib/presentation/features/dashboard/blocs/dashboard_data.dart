import 'package:equatable/equatable.dart';

import '../../../../domain/entities/entities.dart';

class DashboardViewModel extends Equatable {
  final ApprenticeProfile? profile;
  final ProgressCalculationResult? progressData;
  final List<DailyLog> dailyLogs;
  final QuestionOfTheDay? questionOfTheDay;
  final DateTime lastUpdated;

  const DashboardViewModel({
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

  DashboardViewModel copyWith({
    ApprenticeProfile? profile,
    ProgressCalculationResult? progressData,
    List<DailyLog>? dailyLogs,
    QuestionOfTheDay? questionOfTheDay,
    DateTime? lastUpdated,
  }) {
    return DashboardViewModel(
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
