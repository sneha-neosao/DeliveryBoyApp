part of 'today_delivered_history_bloc.dart';

sealed class TodayDeliveredHistoryState extends Equatable {
  final List<TodayDeliveredOrder>? orders;
  final bool loadingMore;
  final bool hasReachedMax;
  final int currentPage;
  final TodayDeliveredHistoryResponse? response;

  const TodayDeliveredHistoryState({
    this.orders,
    this.loadingMore = false,
    this.hasReachedMax = false,
    this.currentPage = 1,
    this.response,
  });

  @override
  List<Object?> get props => [orders, loadingMore, hasReachedMax, currentPage, response];
}

class TodayDeliveredHistoryInitialState extends TodayDeliveredHistoryState {
  const TodayDeliveredHistoryInitialState() : super();
}

class TodayDeliveredHistoryLoadingState extends TodayDeliveredHistoryState {
  const TodayDeliveredHistoryLoadingState({
    super.orders,
    super.loadingMore,
    super.hasReachedMax,
    super.currentPage,
    super.response,
  });
}

class TodayDeliveredHistorySuccessState extends TodayDeliveredHistoryState {
  const TodayDeliveredHistorySuccessState({
    required List<TodayDeliveredOrder> orders,
    required TodayDeliveredHistoryResponse response,
    bool loadingMore = false,
    bool hasReachedMax = false,
    int currentPage = 1,
  }) : super(
          orders: orders,
          response: response,
          loadingMore: loadingMore,
          hasReachedMax: hasReachedMax,
          currentPage: currentPage,
        );
}

class TodayDeliveredHistoryFailureState extends TodayDeliveredHistoryState {
  final String message;

  const TodayDeliveredHistoryFailureState(
    this.message, {
    super.orders,
    super.loadingMore,
    super.hasReachedMax,
    super.currentPage,
    super.response,
  });

  @override
  List<Object?> get props => [message, ...super.props];
}
