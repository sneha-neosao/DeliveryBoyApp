part of 'dashboard_bloc.dart';

sealed class DashboardState extends Equatable {
  const DashboardState();
  @override
  List<Object?> get props => [];
}

class DashboardInitialState extends DashboardState {}

/// States like loading, success and failure representing dashboard information.

class DashboardLoadingState extends DashboardState {}

class DashboardSuccessState extends DashboardState {
  final DashboardStatsResponse data;

  const DashboardSuccessState(this.data);

  @override
  List<Object?> get props => [data];
}

class DashboardFailureState extends DashboardState {
  final String message;

  const DashboardFailureState(this.message);

  @override
  List<Object?> get props => [message];
}