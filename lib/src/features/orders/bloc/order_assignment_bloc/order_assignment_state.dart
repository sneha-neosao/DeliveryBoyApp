part of 'order_assignment_bloc.dart';

sealed class OrderAssignmentState extends Equatable {
  const OrderAssignmentState();
  @override
  List<Object?> get props => [];
}

class OrderAssignmentInitialState extends OrderAssignmentState {}

/// States like loading, success and failure representing order assignment.

class OrderAssignmentLoadingState extends OrderAssignmentState {}

class OrderAssignmentSuccessState extends OrderAssignmentState {
  final OrderAssignmentResponse data;

  const OrderAssignmentSuccessState(this.data);

  @override
  List<Object?> get props => [data];
}

class OrderAssignmentFailureState extends OrderAssignmentState {
  final String message;

  const OrderAssignmentFailureState(this.message);

  @override
  List<Object?> get props => [message];
}