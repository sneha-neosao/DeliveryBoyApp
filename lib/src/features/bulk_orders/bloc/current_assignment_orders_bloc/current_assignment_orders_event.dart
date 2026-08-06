part of 'current_assignment_orders_bloc.dart';

sealed class CurrentAssignmentOrdersEvent extends Equatable {
  const CurrentAssignmentOrdersEvent();

  @override
  List<Object?> get props => [];
}

/// Event for order details.

class CurrentAssignmentOrdersGetEvent extends CurrentAssignmentOrdersEvent {
  final String uu_id;
  final int page;
  final int limit;

  const CurrentAssignmentOrdersGetEvent(this.uu_id, this.page, this.limit);

  @override
  List<Object?> get props => [uu_id, page, limit];
}