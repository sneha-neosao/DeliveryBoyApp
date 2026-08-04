part of 'order_current_assignment_bloc.dart';

sealed class OrderCurrentAssignmentEvent extends Equatable {
  const OrderCurrentAssignmentEvent();

  @override
  List<Object?> get props => [];
}

/// Event for order details.

class OrderCurrentAssignmentGetEvent extends OrderCurrentAssignmentEvent {

  const OrderCurrentAssignmentGetEvent();

  @override
  List<Object?> get props => [];
}