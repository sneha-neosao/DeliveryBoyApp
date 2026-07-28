part of 'order_list_bloc.dart';

/// Base state for OrderList feature.
sealed class OrderListState extends Equatable {
  final OrdersListResponse? response;
  final List<Order>? orders;
  final bool loadingMore;
  final String? endMessage;
  final bool hasReachedMax;
  final int currentPage;

  const OrderListState({
    this.orders,
    this.loadingMore = false,
    this.endMessage,
    this.response,
    this.hasReachedMax = false,
    this.currentPage = 1,
  });

  @override
  List<Object?> get props => [orders, loadingMore, endMessage, response, hasReachedMax, currentPage];
}

/// Initial state when order list has not been requested yet.
class OrderListInitialState extends OrderListState {
  const OrderListInitialState() : super();
}

/// Loading state for initial load, refresh, or fetching next page.
class OrderListLoadingState extends OrderListState {
  const OrderListLoadingState({
    super.orders,
    super.loadingMore = false,
    super.endMessage,
    super.response,
    super.hasReachedMax = false,
    super.currentPage = 1,
  });
}

/// Success state containing fetched list of orders & response metadata.
class OrderListSuccessState extends OrderListState {
  const OrderListSuccessState({
    required List<Order> super.orders,
    required OrdersListResponse super.response,
    super.loadingMore = false,
    super.hasReachedMax = false,
    super.currentPage = 1,
  });

  List<Order> get orderList => orders ?? const [];
}

/// Failure state containing error message and previous state data.
class OrderListFailureState extends OrderListState {
  final String message;

  const OrderListFailureState(
    this.message, {
    super.orders,
    super.loadingMore = false,
    super.response,
    super.hasReachedMax = false,
    super.currentPage = 1,
  }) : super(
          endMessage: message,
        );

  @override
  List<Object?> get props => [message, orders, loadingMore, response, hasReachedMax, currentPage];
}

// Backward compatibility aliases
typedef PostsState = OrderListState;
typedef PostsInitialState = OrderListInitialState;
typedef PostsListLoadingState = OrderListLoadingState;
typedef PostsListSuccessState = OrderListSuccessState;
typedef PostsListFailureState = OrderListFailureState;
