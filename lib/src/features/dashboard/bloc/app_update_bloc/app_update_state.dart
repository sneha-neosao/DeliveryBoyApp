part of 'app_update_bloc.dart';

sealed class AppUpdateState extends Equatable {
  const AppUpdateState();
  @override
  List<Object?> get props => [];
}

class AppUpdateInitialState extends AppUpdateState {}

/// States like loading, success and failure representing app update.

class AppUpdateLoadingState extends AppUpdateState {}

class AppUpdateSuccessState extends AppUpdateState {
  final AppUpdateResponse data;

  const AppUpdateSuccessState(this.data);

  @override
  List<Object?> get props => [data];
}

class AppUpdateFailureState extends AppUpdateState {
  final String message;

  const AppUpdateFailureState(this.message);

  @override
  List<Object?> get props => [message];
}