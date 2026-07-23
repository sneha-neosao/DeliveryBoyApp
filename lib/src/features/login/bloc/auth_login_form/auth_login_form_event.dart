part of 'auth_login_form_bloc.dart';

/// Base class for all events related to LoginValidationBloc.
/// Extends [Equatable] to support value comparison, which helps BLoC
/// determine whether state updates are necessary.
sealed class LoginFormEvent extends Equatable {
  const LoginFormEvent();

  @override
  List<Object?> get props => [];
}

/// listens for change in email input
class LoginFormEmailChangedEvent extends LoginFormEvent {
  final String email;

  const LoginFormEmailChangedEvent(this.email);

  @override
  List<Object?> get props => [email];
}

/// listens for change in password input

class LoginFormPasswordChangedEvent extends LoginFormEvent {
  final String password;

  const LoginFormPasswordChangedEvent(this.password);

  @override
  List<Object?> get props => [password];
}

