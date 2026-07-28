part of 'order_details_bloc.dart';

sealed class OrderDetailsState extends Equatable {
  const OrderDetailsState();
  @override
  List<Object?> get props => [];
}

class OrderDetailsInitialState extends OrderDetailsState {}

/// States like loading, success and failure representing order details.

class OrderDetailsLoadingState extends OrderDetailsState {}

class OrderDetailsSuccessState extends OrderDetailsState {
  final OrderDetailsResponse data;

  const OrderDetailsSuccessState(this.data);

  @override
  List<Object?> get props => [data];
}

class OrderDetailsFailureState extends OrderDetailsState {
  final String message;

  const OrderDetailsFailureState(this.message);

  @override
  List<Object?> get props => [message];
}