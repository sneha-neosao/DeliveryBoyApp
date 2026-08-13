part of 'delete_account_bloc.dart';

sealed class DeleteAccountState extends Equatable {
  const DeleteAccountState();
  @override
  List<Object?> get props => [];
}

class DeleteAccountInitialState extends DeleteAccountState {}

/// States like loading, success and failure representing deleting account.

class DeleteAccountLoadingState extends DeleteAccountState {}

class DeleteAccountSuccessState extends DeleteAccountState {
  final CommonResponse data;

  const DeleteAccountSuccessState(this.data);

  @override
  List<Object?> get props => [data];
}

class DeleteAccountFailureState extends DeleteAccountState {
  final String message;

  const DeleteAccountFailureState(this.message);

  @override
  List<Object?> get props => [message];
}