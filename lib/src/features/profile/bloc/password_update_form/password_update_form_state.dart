part of 'password_update_form_bloc.dart';

/// Base state for SocialMediaValidationBloc.
///
/// Holds the current form data in [inputs] and a validation flag [isValid].
sealed class PasswordUpdateFormState extends Equatable
{
  final String old_password;
  final String new_password;
  final String confirm_password;
  final bool isValid;

  const PasswordUpdateFormState({
    required this.old_password,
    required this.new_password,
    required this.confirm_password,
    required this.isValid,
  });

  @override
  List<Object?> get props => [
        old_password,
        new_password,
        confirm_password,
        isValid,
      ];
}

/// Provides a default empty [inputs] with [isValid] set to false.

class PasswordUpdateFormInitialState extends PasswordUpdateFormState {
  const PasswordUpdateFormInitialState()
      : super(
          old_password: "",
          new_password: "",
          confirm_password: "",
          isValid: false,
        );
}

/// State representing the current validated data after an input change.
///
/// Carries the updated [inputs] and a boolean [inputIsValid] indicating
/// if the current input passes validation.
class PasswordUpdateFormDataState extends PasswordUpdateFormState {
  final String inputOldPassword;
  final String inputNewPassword;
  final String inputConfirmPassword;
  final bool inputIsValid;

  const PasswordUpdateFormDataState({
    required this.inputOldPassword,
    required this.inputNewPassword,
    required this.inputConfirmPassword,
    required this.inputIsValid,
  }) : super(
          old_password: inputOldPassword,
          new_password: inputNewPassword,
          confirm_password: inputConfirmPassword,
          isValid: inputIsValid,
        );

  @override
  List<Object?> get props => [
        inputOldPassword,
        inputNewPassword,
        inputConfirmPassword,
        inputIsValid,
      ];
}
