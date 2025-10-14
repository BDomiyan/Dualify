import 'package:equatable/equatable.dart';

/// Core domain entity representing a daily log entry
/// Immutable entity following Domain-Driven Design principles
class DailyLog extends Equatable {
  final String id;
  final String profileId;
  final DateTime date;
  final DailyLogStatus status;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DailyLog({
    required this.id,
    required this.profileId,
    required this.date,
    required this.status,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates a copy of this daily log with updated fields
  DailyLog copyWith({
    String? id,
    String? profileId,
    DateTime? date,
    DailyLogStatus? status,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DailyLog(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      date: date ?? this.date,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Gets the date as a date-only DateTime (without time)
  DateTime get dateOnly => DateTime(date.year, date.month, date.day);

  /// Checks if this log entry is for today
  bool get isToday {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return dateOnly.isAtSameMomentAs(today);
  }

  /// Checks if this log entry is for a future date
  bool get isFuture {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return dateOnly.isAfter(today);
  }

  /// Checks if this log entry is for a past date
  bool get isPast {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return dateOnly.isBefore(today);
  }

  /// Gets the display text for the date
  String get dateDisplayText {
    if (isToday) return 'Today';

    final now = DateTime.now();
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    if (dateOnly.isAtSameMomentAs(yesterday)) return 'Yesterday';

    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    if (dateOnly.isAtSameMomentAs(tomorrow)) return 'Tomorrow';

    // Format as "Mon 15" or "Tue 16"
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final weekday = weekdays[date.weekday - 1];
    return '$weekday ${date.day}';
  }

  /// Gets the full date display text
  String get fullDateDisplayText {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    final month = months[date.month - 1];
    return '$month ${date.day}, ${date.year}';
  }

  /// Validates the daily log data
  List<String> validate() {
    final errors = <String>[];

    if (profileId.trim().isEmpty) {
      errors.add('Profile ID is required');
    }

    // Validate that the date is not too far in the future
    final maxFutureDate = DateTime.now().add(const Duration(days: 7));
    if (date.isAfter(maxFutureDate)) {
      errors.add('Date cannot be more than 7 days in the future');
    }

    // Validate that the date is not too far in the past
    final minPastDate = DateTime.now().subtract(const Duration(days: 365 * 2));
    if (date.isBefore(minPastDate)) {
      errors.add('Date cannot be more than 2 years in the past');
    }

    // Validate notes length if provided
    if (notes != null && notes!.length > 500) {
      errors.add('Notes cannot exceed 500 characters');
    }

    return errors;
  }

  /// Checks if the daily log is valid
  bool get isValid => validate().isEmpty;

  @override
  List<Object?> get props => [
    id,
    profileId,
    date,
    status,
    notes,
    createdAt,
    updatedAt,
  ];

  @override
  String toString() =>
      'DailyLog(id: $id, date: $dateDisplayText, status: ${status.displayName})';
}

/// Enumeration for daily log status with emoji and color information
enum DailyLogStatus {
  learning('learning', '📚', 'Learning', 'Had a great learning day'),
  challenging(
    'challenging',
    '💪',
    'Challenging',
    'Faced some challenges but pushed through',
  ),
  neutral('neutral', '😐', 'Neutral', 'A regular day at work'),
  good('good', '😊', 'Good', 'Had a good productive day');

  const DailyLogStatus(
    this.value,
    this.emoji,
    this.displayName,
    this.description,
  );

  final String value;
  final String emoji;
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

  /// Gets the color associated with this status
  String get colorHex {
    switch (this) {
      case DailyLogStatus.learning:
        return '#87CEEB'; // Sky blue
      case DailyLogStatus.challenging:
        return '#FFD700'; // Gold
      case DailyLogStatus.neutral:
        return '#D3D3D3'; // Light gray
      case DailyLogStatus.good:
        return '#90EE90'; // Light green
    }
  }
}

/// Factory class for creating DailyLog instances
class DailyLogFactory {
  /// Creates a new daily log entry
  static DailyLog create({
    required String profileId,
    required DateTime date,
    required DailyLogStatus status,
    String? notes,
  }) {
    final now = DateTime.now();
    final id = _generateId();

    return DailyLog(
      id: id,
      profileId: profileId,
      date: DateTime(date.year, date.month, date.day), // Normalize to date only
      status: status,
      notes: notes?.trim(),
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Creates a daily log from existing data (e.g., from database)
  static DailyLog fromData({
    required String id,
    required String profileId,
    required DateTime date,
    required DailyLogStatus status,
    String? notes,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) {
    return DailyLog(
      id: id,
      profileId: profileId,
      date: date,
      status: status,
      notes: notes,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Creates a daily log from string status value
  static DailyLog fromStatusValue({
    required String profileId,
    required DateTime date,
    required String statusValue,
    String? notes,
  }) {
    return create(
      profileId: profileId,
      date: date,
      status: DailyLogStatus.fromValue(statusValue),
      notes: notes,
    );
  }

  /// Generates a unique ID for the daily log
  static String _generateId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = DateTime.now().microsecond;
    return 'daily_log_${timestamp}_$random';
  }
}

/// Utility class for working with daily logs
class DailyLogUtils {
  /// Generates a list of dates for the past 7 days including today
  static List<DateTime> generateSevenDayRange([DateTime? centerDate]) {
    final center = centerDate ?? DateTime.now();
    final centerDateOnly = DateTime(center.year, center.month, center.day);

    return List.generate(7, (index) {
      return centerDateOnly.subtract(Duration(days: 6 - index));
    });
  }

  /// Gets the week range that includes the given date
  static List<DateTime> getWeekRange(DateTime date) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    final weekday = dateOnly.weekday; // 1 = Monday, 7 = Sunday

    // Calculate Monday of the week
    final monday = dateOnly.subtract(Duration(days: weekday - 1));

    return List.generate(7, (index) {
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
