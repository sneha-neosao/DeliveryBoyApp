part of 'online_status_bloc.dart';

sealed class OnlineStatusEvent extends Equatable {
  const OnlineStatusEvent();

  @override
  List<Object?> get props => [];
}

/// Event for online status of delivery boy.

class OnlineStatusGetEvent extends OnlineStatusEvent {
  final bool is_online;

  const OnlineStatusGetEvent(this.is_online);

  @override
  List<Object?> get props => [is_online];
}