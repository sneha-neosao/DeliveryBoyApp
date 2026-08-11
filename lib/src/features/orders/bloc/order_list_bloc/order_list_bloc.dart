import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/logger.dart';
import '../../../../remote/models/order_model/food_order_model/order_list_response.dart';
import '../../domain/usecase/order_list_usecase.dart';

part 'order_list_event.dart';
part 'order_list_state.dart';

/// Handles state management for **Order List** with pagination support.
class OrderListBloc extends Bloc<OrderListEvent, OrderListState> {
  final OrderListUseCase _orderListUseCase;

  OrderListBloc(
    this._orderListUseCase,
  ) : super(const OrderListInitialState()) {
    on<GetOrderListEvent>(_onGetOrderList);
    on<ResetOrderListEvent>(_onResetOrderList);
  }

  /// Fetch order list with pagination support.
  Future<void> _onGetOrderList(
    GetOrderListEvent event,
    Emitter<OrderListState> emit,
  ) async {
    final int page = event.page;
    final bool isFirstLoad = page == 1 || event.isRefresh;

    if (isFirstLoad) {
      // First load or refresh: reset list & show loading
      emit(const OrderListLoadingState(
        orders: null,
        loadingMore: false,
        endMessage: "",
        response: null,
        currentPage: 1,
        hasReachedMax: false,
      ));
    } else {
      // Pagination: keep previous orders, set loadingMore to true
      emit(OrderListLoadingState(
        orders: state.orders,
        loadingMore: true,
        endMessage: "",
        response: state.response,
        currentPage: state.currentPage,
        hasReachedMax: state.hasReachedMax,
      ));
    }

    final result = await _orderListUseCase.call(OrderListParams(
      slot_uu_id: event.slotUuId,
      delivery_date: event.deliveryDate,
      page: page,
      limit: event.limit,
    ));

    result.fold(
      (failure) {
        emit(OrderListFailureState(
          failure.message,
          orders: state.orders,
          loadingMore: false,
          response: state.response,
          currentPage: state.currentPage,
          hasReachedMax: state.hasReachedMax,
        ));
      },
      (response) {
        final newOrders = response.data;
        final pagination = response.pagination;

        bool hasReachedMax = false;
        if (pagination != null) {
          hasReachedMax = pagination.currentPage >= pagination.totalPages;
        } else {
          hasReachedMax = newOrders.isEmpty || newOrders.length < event.limit;
        }

        if (!isFirstLoad && state.orders != null) {
          // Append new orders for pagination
          if (newOrders.isEmpty) {
            emit(OrderListSuccessState(
              orders: state.orders!,
              response: response,
              loadingMore: false,
              hasReachedMax: true,
              currentPage: state.currentPage,
            ));
            return;
          }

          final combinedOrders = List<Order>.from(state.orders!)..addAll(newOrders);
          emit(OrderListSuccessState(
            orders: combinedOrders,
            response: response,
            loadingMore: false,
            hasReachedMax: hasReachedMax,
            currentPage: page,
          ));
        } else {
          // First load or refresh
          emit(OrderListSuccessState(
            orders: newOrders,
            response: response,
            loadingMore: false,
            hasReachedMax: hasReachedMax,
            currentPage: page,
          ));
        }
      },
    );
  }

  /// Reset order list state
  Future<void> _onResetOrderList(
    ResetOrderListEvent event,
    Emitter<OrderListState> emit,
  ) async {
    emit(const OrderListInitialState());
  }

  @override
  Future<void> close() {
    logger.i("===== CLOSE OrderListBloc =====");
    return super.close();
  }
}

// Backward compatibility alias
typedef PostsBloc = OrderListBloc;
