part of 'order_details_bloc.dart';

sealed class OrderDetailsEvent extends Equatable {
  const OrderDetailsEvent();

  @override
  List<Object?> get props => [];
}

/// Event for order details.

class OrderDetailsGetEvent extends OrderDetailsEvent {
  final String uu_id;

  const OrderDetailsGetEvent(this.uu_id);

  @override
  List<Object?> get props => [uu_id];
}