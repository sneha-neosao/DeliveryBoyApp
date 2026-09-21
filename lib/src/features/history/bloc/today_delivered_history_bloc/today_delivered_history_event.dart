part of 'today_delivered_history_bloc.dart';

sealed class TodayDeliveredHistoryEvent extends Equatable {
  const TodayDeliveredHistoryEvent();

  @override
  List<Object?> get props => [];
}

class TodayDeliveredHistoryGetEvent extends TodayDeliveredHistoryEvent {
  final int page;
  final int limit;
  final bool isRefresh;

  const TodayDeliveredHistoryGetEvent({
    this.page = 1,
    this.limit = 10,
    this.isRefresh = false,
  });

  @override
  List<Object?> get props => [page, limit, isRefresh];
}

class TodayDeliveredHistoryResetEvent extends TodayDeliveredHistoryEvent {}
