part of 'password_update_bloc.dart';

sealed class PasswordUpdateEvent extends Equatable {
  const PasswordUpdateEvent();

  @override
  List<Object?> get props => [];
}

/// Event for password update.

class PasswordUpdateGetEvent extends PasswordUpdateEvent {
  final String old_password;
  final String new_pssword;
  final String confirm_password;

  const PasswordUpdateGetEvent(this.old_password, this.new_pssword, this.confirm_password);

  @override
  List<Object?> get props => [old_password, new_pssword, confirm_password];
}