import 'package:equatable/equatable.dart';

import 'dashboard_data.dart';

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
  final DashboardViewModel dashboardData;

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
  final DashboardViewModel currentData;
  final String updateType;

  const DashboardUpdating({
    required this.currentData,
    required this.updateType,
  });

  @override
  List<Object?> get props => [currentData, updateType];
}
