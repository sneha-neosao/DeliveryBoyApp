part of 'order_status_update_bloc.dart';

sealed class OrderStatusUpdateEvent extends Equatable {
  const OrderStatusUpdateEvent();

  @override
  List<Object?> get props => [];
}

/// Event for order status update.

class OrderStatusUpdateGetEvent extends OrderStatusUpdateEvent {
  final String uu_id;
  final String status;
  final String? note;

  const OrderStatusUpdateGetEvent(this.uu_id, this.status, this.note);

  @override
  List<Object?> get props => [uu_id, status, note];
}