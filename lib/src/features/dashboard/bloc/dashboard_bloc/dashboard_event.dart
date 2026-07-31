part of 'dashboard_bloc.dart';

sealed class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

/// Event for dashboard information

class DashboardGetEvent extends DashboardEvent {

  const DashboardGetEvent();

  @override
  List<Object?> get props => [];
}