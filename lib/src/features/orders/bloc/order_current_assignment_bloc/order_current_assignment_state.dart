part of 'order_current_assignment_bloc.dart';

sealed class OrderCurrentAssignmentState extends Equatable {
  const OrderCurrentAssignmentState();
  @override
  List<Object?> get props => [];
}

class OrderCurrentAssignmentInitialState extends OrderCurrentAssignmentState {}

/// States like loading, success and failure representing order current assignment.

class OrderCurrentAssignmentLoadingState extends OrderCurrentAssignmentState {}

class OrderCurrentAssignmentSuccessState extends OrderCurrentAssignmentState {
  final OrderCurrentAssignmentResponse data;

  const OrderCurrentAssignmentSuccessState(this.data);

  @override
  List<Object?> get props => [data];
}

class OrderCurrentAssignmentFailureState extends OrderCurrentAssignmentState {
  final String message;

  const OrderCurrentAssignmentFailureState(this.message);

  @override
  List<Object?> get props => [message];
}