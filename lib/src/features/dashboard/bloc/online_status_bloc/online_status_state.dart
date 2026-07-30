part of 'online_status_bloc.dart';

sealed class OnlineStatusState extends Equatable {
  const OnlineStatusState();
  @override
  List<Object?> get props => [];
}

class OnlineStatusInitialState extends OnlineStatusState {}

/// States like loading, success and failure representing online status of delivery boy .

class OnlineStatusLoadingState extends OnlineStatusState {}

class OnlineStatusSuccessState extends OnlineStatusState {
  final OnlineStatusResponse data;

  const OnlineStatusSuccessState(this.data);

  @override
  List<Object?> get props => [data];
}

class OnlineStatusFailureState extends OnlineStatusState {
  final String message;

  const OnlineStatusFailureState(this.message);

  @override
  List<Object?> get props => [message];
}