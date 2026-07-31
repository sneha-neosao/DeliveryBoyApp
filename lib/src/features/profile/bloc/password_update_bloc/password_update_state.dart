part of 'password_update_bloc.dart';

sealed class PasswordUpdateState extends Equatable {
  const PasswordUpdateState();
  @override
  List<Object?> get props => [];
}

class PasswordUpdateInitialState extends PasswordUpdateState {}

/// States like loading, success and failure representing password update.

class PasswordUpdateLoadingState extends PasswordUpdateState {}

class PasswordUpdateSuccessState extends PasswordUpdateState {
  final CommonResponse data;

  const PasswordUpdateSuccessState(this.data);

  @override
  List<Object?> get props => [data];
}

class PasswordUpdateFailureState extends PasswordUpdateState {
  final String message;

  const PasswordUpdateFailureState(this.message);

  @override
  List<Object?> get props => [message];
}