part of 'current_assignment_orders_bloc.dart';

sealed class CurrentAssignmentOrdersState extends Equatable {
  const CurrentAssignmentOrdersState();
  @override
  List<Object?> get props => [];
}

class CurrentAssignmentOrdersInitialState extends CurrentAssignmentOrdersState {}

/// States like loading, success and failure representing order details.

class CurrentAssignmentOrdersLoadingState extends CurrentAssignmentOrdersState {}

class CurrentAssignmentOrdersSuccessState extends CurrentAssignmentOrdersState {
  final CurrentAssignmentOrderListResponse data;

  const CurrentAssignmentOrdersSuccessState(this.data);

  @override
  List<Object?> get props => [data];
}

class CurrentAssignmentOrdersFailureState extends CurrentAssignmentOrdersState {
  final String message;

  const CurrentAssignmentOrdersFailureState(this.message);

  @override
  List<Object?> get props => [message];
}