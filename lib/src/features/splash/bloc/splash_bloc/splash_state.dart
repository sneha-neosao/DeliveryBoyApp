part of 'splash_bloc.dart';

sealed class SplashState extends Equatable {
  final int time;
  const SplashState({required this.time});

  @override
  List<Object?> get props => [time];
}

/// Initial splash state
class SplashInitialState extends SplashState {
  const SplashInitialState({required int time}) : super(time: time);
}

/// State after splash timer completes
class SplashDataState extends SplashState {
  const SplashDataState() : super(time: 0);
}
