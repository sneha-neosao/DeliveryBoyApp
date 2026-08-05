part of 'order_start_assignment_bloc.dart';

sealed class OrderStartAssignmentEvent extends Equatable {
  const OrderStartAssignmentEvent();

  @override
  List<Object?> get props => [];
}

/// Event for order details.

class OrderStartAssignmentGetEvent extends OrderStartAssignmentEvent {
  final String uu_id;
  final String status;

  const OrderStartAssignmentGetEvent(this.uu_id, this.status);

  @override
  List<Object?> get props => [uu_id, status];
}