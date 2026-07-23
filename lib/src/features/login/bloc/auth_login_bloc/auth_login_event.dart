part of 'auth_login_bloc.dart';

/// Event for authentication related information.

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Event for login.

class AuthLoginEvent extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginEvent(this.email, this.password);

  @override
  List<Object?> get props => [email, password];
}

/// Event for logout.

class AuthLogoutEvent extends AuthEvent {}

/// Event to check login status.

class AuthCheckSignInStatusEvent extends AuthEvent {}

/// Event for forgot password.

class AuthForgotPasswordEvent extends AuthEvent {
  final String companyCode;
  final String email;

  const AuthForgotPasswordEvent(this.companyCode, this.email);

  @override
  List<Object?> get props => [companyCode, email];
}

/// Event to delete user account .

class AccountDeleteGetEvent extends AuthEvent {
  final int id;

  const AccountDeleteGetEvent(this.id);

  @override
  List<Object?> get props => [id];
}