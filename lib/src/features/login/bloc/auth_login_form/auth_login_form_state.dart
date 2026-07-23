part of 'auth_login_form_bloc.dart';

/// Base state for SocialMediaValidationBloc.
///
/// Holds the current form data in [inputs] and a validation flag [isValid].
sealed class LoginFormState extends Equatable
{
  final String email;
  final String password;
  final bool isValid;

  const LoginFormState({
    required this.email,
    required this.password,
    required this.isValid,
  });

  @override
  List<Object?> get props => [
        email,
        password,
        isValid,
      ];
}

/// Provides a default empty [inputs] with [isValid] set to false.

class LoginFormInitialState extends LoginFormState {
  const LoginFormInitialState()
      : super(
          email: "",
          password: "",
          isValid: false,
        );
}

/// State representing the current validated data after an input change.
///
/// Carries the updated [inputs] and a boolean [inputIsValid] indicating
/// if the current input passes validation.
class LoginFormDataState extends LoginFormState {
  final String inputEmail;
  final String inputPassword;
  final bool inputIsValid;

  const LoginFormDataState({
    required this.inputEmail,
    required this.inputPassword,
    required this.inputIsValid,
  }) : super(
          email: inputEmail,
          password: inputPassword,
          isValid: inputIsValid,
        );

  @override
  List<Object?> get props => [
        inputEmail,
        inputPassword,
        inputIsValid,
      ];
}
