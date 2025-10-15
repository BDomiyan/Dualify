import 'package:equatable/equatable.dart';

import 'daily_log_status.dart';

/// Statistics for daily logs
class DailyLogStatistics extends Equatable {
  final int totalDays;
  final int learningDays;
  final int challengingDays;
  final int neutralDays;
  final int goodDays;

  const DailyLogStatistics({
    required this.totalDays,
    required this.learningDays,
    required this.challengingDays,
    required this.neutralDays,
    required this.goodDays,
  });

  /// Gets the percentage of learning days
  double get learningPercentage =>
      totalDays > 0 ? learningDays / totalDays : 0.0;

  /// Gets the percentage of challenging days
  double get challengingPercentage =>
      totalDays > 0 ? challengingDays / totalDays : 0.0;

  /// Gets the percentage of neutral days
  double get neutralPercentage => totalDays > 0 ? neutralDays / totalDays : 0.0;

  /// Gets the percentage of good days
  double get goodPercentage => totalDays > 0 ? goodDays / totalDays : 0.0;

  /// Gets the most common status
  DailyLogStatus get mostCommonStatus {
    final counts = [
      (DailyLogStatus.learning, learningDays),
      (DailyLogStatus.challenging, challengingDays),
      (DailyLogStatus.neutral, neutralDays),
      (DailyLogStatus.good, goodDays),
    ];

    counts.sort((a, b) => b.$2.compareTo(a.$2));
    return counts.first.$1;
  }

  @override
  List<Object?> get props => [
    totalDays,
    learningDays,
    challengingDays,
    neutralDays,
    goodDays,
  ];
}
