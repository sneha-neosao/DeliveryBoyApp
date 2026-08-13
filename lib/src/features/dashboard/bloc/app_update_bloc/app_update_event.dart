part of 'app_update_bloc.dart';

sealed class AppUpdateEvent extends Equatable {
  const AppUpdateEvent();

  @override
  List<Object?> get props => [];
}

/// Event for App update.

class AppUpdateGetEvent extends AppUpdateEvent {

  const AppUpdateGetEvent();

  @override
  List<Object?> get props => [];
}