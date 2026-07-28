part of 'order_list_bloc.dart';

/// Base event for OrderList feature.
sealed class OrderListEvent extends Equatable {
  const OrderListEvent();

  @override
  List<Object?> get props => [];
}

/// Event to fetch order list with pagination support.
class GetOrderListEvent extends OrderListEvent {
  final String? slotUuId;
  final String? deliveryDate;
  final int page;
  final int limit;
  final bool isRefresh;

  const GetOrderListEvent({
    this.slotUuId,
    this.deliveryDate,
    this.page = 1,
    this.limit = 10,
    this.isRefresh = false,
  });

  @override
  List<Object?> get props => [slotUuId, deliveryDate, page, limit, isRefresh];
}

/// Event to reset order list state.
class ResetOrderListEvent extends OrderListEvent {
  const ResetOrderListEvent();
}

// Backward compatibility aliases
typedef OrderListGetEvent = GetOrderListEvent;
typedef OrderListResetEvent = ResetOrderListEvent;
typedef PostsEvent = OrderListEvent;
typedef PostsListGetEvent = GetOrderListEvent;
typedef PostsListResetEvent = ResetOrderListEvent;
