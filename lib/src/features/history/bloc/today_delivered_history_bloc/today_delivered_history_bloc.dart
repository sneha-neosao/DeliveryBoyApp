import 'package:delivery_boy_app/src/core/utils/logger.dart';
import 'package:delivery_boy_app/src/features/history/domain/usecase/today_delivered_history_usecase.dart';
import 'package:delivery_boy_app/src/remote/models/order_model/today_delivered_history_response.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'today_delivered_history_event.dart';
part 'today_delivered_history_state.dart';

class TodayDeliveredHistoryBloc
    extends Bloc<TodayDeliveredHistoryEvent, TodayDeliveredHistoryState> {
  final TodayDeliveredHistoryUseCase _todayDeliveredHistoryUseCase;

  TodayDeliveredHistoryBloc(this._todayDeliveredHistoryUseCase)
      : super(const TodayDeliveredHistoryInitialState()) {
    on<TodayDeliveredHistoryGetEvent>(_onGetTodayDeliveredHistory);
    on<TodayDeliveredHistoryResetEvent>(_onResetTodayDeliveredHistory);
  }

  void _onResetTodayDeliveredHistory(
    TodayDeliveredHistoryResetEvent event,
    Emitter<TodayDeliveredHistoryState> emit,
  ) {
    emit(const TodayDeliveredHistoryInitialState());
  }

  Future<void> _onGetTodayDeliveredHistory(
    TodayDeliveredHistoryGetEvent event,
    Emitter<TodayDeliveredHistoryState> emit,
  ) async {
    final int page = event.page;
    final bool isFirstLoad = page == 1 || event.isRefresh;

    if (isFirstLoad) {
      emit(const TodayDeliveredHistoryLoadingState(
        orders: null,
        loadingMore: false,
        currentPage: 1,
        hasReachedMax: false,
      ));
    } else {
      if (state.hasReachedMax || state.loadingMore) return;
      emit(TodayDeliveredHistoryLoadingState(
        orders: state.orders,
        loadingMore: true,
        currentPage: state.currentPage,
        hasReachedMax: state.hasReachedMax,
        response: state.response,
      ));
    }

    final result = await _todayDeliveredHistoryUseCase.call(
      TodayDeliveredHistoryParams(
        page: page,
        limit: event.limit,
      ),
    );

    result.fold(
      (failure) {
        emit(TodayDeliveredHistoryFailureState(
          failure.message,
          orders: state.orders,
          loadingMore: false,
          currentPage: state.currentPage,
          hasReachedMax: state.hasReachedMax,
          response: state.response,
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
          if (newOrders.isEmpty) {
            emit(TodayDeliveredHistorySuccessState(
              orders: state.orders!,
              response: response,
              loadingMore: false,
              hasReachedMax: true,
              currentPage: state.currentPage,
            ));
            return;
          }

          final combined = List<TodayDeliveredOrder>.from(state.orders!)
            ..addAll(newOrders);
          emit(TodayDeliveredHistorySuccessState(
            orders: combined,
            response: response,
            loadingMore: false,
            hasReachedMax: hasReachedMax,
            currentPage: page,
          ));
        } else {
          emit(TodayDeliveredHistorySuccessState(
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

  @override
  Future<void> close() {
    logger.i("===== CLOSE TodayDeliveredHistoryBloc =====");
    return super.close();
  }
}
