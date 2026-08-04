part of 'order_start_assignment_bloc.dart';

sealed class OrderStartAssignmentState extends Equatable {
  const OrderStartAssignmentState();
  @override
  List<Object?> get props => [];
}

class OrderStartAssignmentInitialState extends OrderStartAssignmentState {}

/// States like loading, success and failure representing order details.

class OrderStartAssignmentLoadingState extends OrderStartAssignmentState {}

class OrderStartAssignmentSuccessState extends OrderStartAssignmentState {
  final OrderStartAssignmentResponse data;

  const OrderStartAssignmentSuccessState(this.data);

  @override
  List<Object?> get props => [data];
}

class OrderStartAssignmentFailureState extends OrderStartAssignmentState {
  final String message;

  const OrderStartAssignmentFailureState(this.message);

  @override
  List<Object?> get props => [message];
}