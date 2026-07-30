part of 'order_assignment_bloc.dart';

sealed class OrderAssignmentEvent extends Equatable {
  const OrderAssignmentEvent();

  @override
  List<Object?> get props => [];
}

/// Event for order assignment.

class OrderAssignmentGetEvent extends OrderAssignmentEvent {
  final String uu_id;
  final String action;
  final String? note;

  const OrderAssignmentGetEvent(this.uu_id, this.action, this.note);

  @override
  List<Object?> get props => [uu_id, action, note];
}