part of 'password_update_form_bloc.dart';

/// Base class for all events related to LoginValidationBloc.
/// Extends [Equatable] to support value comparison, which helps BLoC
/// determine whether state updates are necessary.
sealed class PasswordUpdateFormEvent extends Equatable {
  const PasswordUpdateFormEvent();

  @override
  List<Object?> get props => [];
}

/// listens for change in old password input
class OldPasswordChangedEvent extends PasswordUpdateFormEvent {
  final String old_password;

  const OldPasswordChangedEvent(this.old_password);

  @override
  List<Object?> get props => [old_password];
}

/// listens for change in new password input

class NewPasswordChangedEvent extends PasswordUpdateFormEvent {
  final String new_password;

  const NewPasswordChangedEvent(this.new_password);

  @override
  List<Object?> get props => [new_password];
}

/// listens for change in confirm password input

class ConfirmPasswordChangedEvent extends PasswordUpdateFormEvent {
  final String confirm_password;

  const ConfirmPasswordChangedEvent(this.confirm_password);

  @override
  List<Object?> get props => [confirm_password];
}