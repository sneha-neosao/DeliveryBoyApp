part of 'auth_login_bloc.dart';

sealed class AuthLoginState extends Equatable {
  const AuthLoginState();
  @override
  List<Object?> get props => [];
}

class AuthLoginInitialState extends AuthLoginState {}

/// States like loading, success and failure representing login.

class AuthLoginLoadingState extends AuthLoginState {}

class AuthLoginSuccessState extends AuthLoginState {
  final LoginResponse data;

  const AuthLoginSuccessState(this.data);

  @override
  List<Object?> get props => [data];
}

class AuthLoginFailureState extends AuthLoginState {
  final String message;

  const AuthLoginFailureState(this.message);

  @override
  List<Object?> get props => [message];
}

// /// States like loading, success and failure representing login status.
//
// class AuthCheckSignInStatusLoadingState extends AuthLoginState {}
//
// class AuthCheckSignInStatusSuccessState extends AuthLoginState {
//   final MemberModel userData;
//   final List<CompanySocialAccountSelectionResult> socialData;
//
//   const AuthCheckSignInStatusSuccessState(this.userData,this.socialData);
//
//   @override
//   List<Object?> get props => [userData];
// }
//
// class AuthCheckSignInStatusFailureState extends AuthLoginState {
//   final String message;
//
//   const AuthCheckSignInStatusFailureState(this.message);
//
//   @override
//   List<Object?> get props => [message];
// }
//
// /// States like loading, success and failure representing logout.
//
// class AuthLogoutLoadingState extends AuthLoginState {}
//
// class AuthLogoutSuccessState extends AuthLoginState {
//   final String message;
//
//   const AuthLogoutSuccessState(this.message);
//
//   @override
//   List<Object?> get props => [message];
// }
//
// class AuthLogoutFailureState extends AuthLoginState {
//   final String message;
//
//   const AuthLogoutFailureState(this.message);
//
//   @override
//   List<Object?> get props => [message];
// }
//
// /// States like loading, success and failure representing forgot password.
//
// class AuthForgotPasswordLoadingState extends AuthLoginState {}
//
// class AuthForgotPasswordSuccessState extends AuthLoginState {
//   final ForgotPasswordResponse data;
//   final String email;
//
//   const AuthForgotPasswordSuccessState(this.data,this.email);
//
//   @override
//   List<Object?> get props => [data,email];
// }
//
// class AuthForgotPasswordFailureState extends AuthLoginState {
//   final String message;
//
//   const AuthForgotPasswordFailureState(this.message);
//
//   @override
//   List<Object?> get props => [message];
// }
//
// /// States like loading, success and failure representing user account delete.
//
// class AccountDeleteLoadingState extends AuthLoginState {}
//
// class AccountDeleteSuccessState extends AuthLoginState {
//   final CommonResponse data;
//
//   const AccountDeleteSuccessState(this.data);
//
//   @override
//   List<Object?> get props => [data];
// }
//
// class AccountDeleteFailureState extends AuthLoginState {
//   final String message;
//
//   const AccountDeleteFailureState(this.message);
//
//   @override
//   List<Object?> get props => [message];
// }



