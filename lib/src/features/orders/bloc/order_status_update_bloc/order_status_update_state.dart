part of 'order_status_update_bloc.dart';

sealed class OrderStatusUpdateState extends Equatable {
  const OrderStatusUpdateState();
  @override
  List<Object?> get props => [];
}

class OrderStatusUpdateInitialState extends OrderStatusUpdateState {}

/// States like loading, success and failure representing order status updating.

class OrderStatusUpdateLoadingState extends OrderStatusUpdateState {}

class OrderStatusUpdateSuccessState extends OrderStatusUpdateState {
  final OrderStatusUpdateResponse data;

  const OrderStatusUpdateSuccessState(this.data);

  @override
  List<Object?> get props => [data];
}

class OrderStatusUpdateFailureState extends OrderStatusUpdateState {
  final String message;

  const OrderStatusUpdateFailureState(this.message);

  @override
  List<Object?> get props => [message];
}