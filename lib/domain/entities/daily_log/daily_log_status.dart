import '../../../core/constants/domain_constants.dart';

/// Enumeration for daily log status
enum DailyLogStatus {
  learning(
    DomainConstants.dailyLogStatusLearning,
    DomainConstants.dailyLogStatusLearningDisplay,
    DomainConstants.dailyLogStatusLearningDescription,
  ),
  challenging(
    DomainConstants.dailyLogStatusChallenging,
    DomainConstants.dailyLogStatusChallengingDisplay,
    DomainConstants.dailyLogStatusChallengingDescription,
  ),
  neutral(
    DomainConstants.dailyLogStatusNeutral,
    DomainConstants.dailyLogStatusNeutralDisplay,
    DomainConstants.dailyLogStatusNeutralDescription,
  ),
  good(
    DomainConstants.dailyLogStatusGood,
    DomainConstants.dailyLogStatusGoodDisplay,
    DomainConstants.dailyLogStatusGoodDescription,
  );

  const DailyLogStatus(this.value, this.displayName, this.description);

  final String value;
  final String displayName;
  final String description;

  /// Gets status from string value
  static DailyLogStatus fromValue(String value) {
    return DailyLogStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => DailyLogStatus.neutral,
    );
  }

  /// Gets all available statuses for selection
  static List<DailyLogStatus> get allStatuses => DailyLogStatus.values;
}
