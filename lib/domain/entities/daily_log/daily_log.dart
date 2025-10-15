import 'package:equatable/equatable.dart';

import '../../../core/constants/domain_constants.dart';
import 'daily_log_status.dart';

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
    if (isToday) return DomainConstants.displayToday;

    final now = DateTime.now();
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    if (dateOnly.isAtSameMomentAs(yesterday)) {
      return DomainConstants.displayYesterday;
    }

    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    if (dateOnly.isAtSameMomentAs(tomorrow)) {
      return DomainConstants.displayTomorrow;
    }

    // Format as "Mon 15" or "Tue 16"
    final weekday = DomainConstants.weekdayAbbreviations[date.weekday - 1];
    return '$weekday ${date.day}';
  }

  /// Gets the full date display text
  String get fullDateDisplayText {
    final month = DomainConstants.monthNames[date.month - 1];
    return '$month ${date.day}, ${date.year}';
  }

  /// Validates the daily log data
  List<String> validate() {
    final errors = <String>[];

    if (profileId.trim().isEmpty) {
      errors.add(DomainConstants.errorProfileIdRequired);
    }

    // Validate that the date is not too far in the future
    final maxFutureDate = DateTime.now().add(
      Duration(days: DomainConstants.maxDailyLogFutureDays),
    );
    if (date.isAfter(maxFutureDate)) {
      errors.add(DomainConstants.errorDateTooFarFuture);
    }

    // Validate that the date is not too far in the past
    final minPastDate = DateTime.now().subtract(
      Duration(days: 365 * DomainConstants.maxDailyLogPastYears),
    );
    if (date.isBefore(minPastDate)) {
      errors.add(DomainConstants.errorDateTooFarPast);
    }

    // Validate notes length if provided
    if (notes != null &&
        notes!.length > DomainConstants.maxDailyLogNotesLength) {
      errors.add(DomainConstants.errorNotesTooLong);
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
