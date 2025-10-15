import 'package:equatable/equatable.dart';

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
