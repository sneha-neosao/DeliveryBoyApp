part of 'splash_bloc.dart';

sealed class SplashEvent extends Equatable {
  const SplashEvent();

  @override
  List<Object?> get props => [];
}

/// Event triggered when splash timer completes
class SplashTimerCompletedEvent extends SplashEvent {
  final int time;
  const SplashTimerCompletedEvent(this.time);

  @override
  List<Object?> get props => [time];
}
