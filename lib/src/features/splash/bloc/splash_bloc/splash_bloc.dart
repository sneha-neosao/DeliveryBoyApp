import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'splash_event.dart';
part 'splash_state.dart';

/// Handles state management for Splash animations and navigation.
class SplashBloc extends Bloc<SplashEvent, SplashState> {
  SplashBloc() : super(const SplashInitialState(time: 3000)) {
    on<SplashTimerCompletedEvent>(_onSplashTimer);
    add(const SplashTimerCompletedEvent(3000)); // start timer immediately
  }

  Future<void> _onSplashTimer(
    SplashTimerCompletedEvent event,
    Emitter<SplashState> emit,
  ) async {
    await Future.delayed(Duration(milliseconds: event.time));
    emit(const SplashDataState());
  }
}
