part of 'delete_account_bloc.dart';

sealed class DeleteAccountEvent extends Equatable {
  const DeleteAccountEvent();

  @override
  List<Object?> get props => [];
}

/// Event for Delete Account.

class DeleteAccountGetEvent extends DeleteAccountEvent {

  const DeleteAccountGetEvent();

  @override
  List<Object?> get props => [];
}