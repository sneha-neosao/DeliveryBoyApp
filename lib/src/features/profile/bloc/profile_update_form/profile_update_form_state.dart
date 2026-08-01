part of 'profile_update_form_bloc.dart';

/// Base state for SocialMediaValidationBloc.
///
/// Holds the current form data in [inputs] and a validation flag [isValid].
sealed class ProfileUpdateFormState extends Equatable
{
  final String name;
  final String mobile_number;
  final bool isValid;

  const ProfileUpdateFormState({
    required this.name,
    required this.mobile_number,
    required this.isValid,
  });

  @override
  List<Object?> get props => [
        name,
        mobile_number,
        isValid,
      ];
}

/// Provides a default empty [inputs] with [isValid] set to false.

class ProfileUpdateFormInitialState extends ProfileUpdateFormState {
  const ProfileUpdateFormInitialState()
      : super(
          name: "",
          mobile_number: "",
          isValid: false,
        );
}

/// State representing the current validated data after an input change.
///
/// Carries the updated [inputs] and a boolean [inputIsValid] indicating
/// if the current input passes validation.
class ProfileUpdateFormDataState extends ProfileUpdateFormState {
  final String inputName;
  final String inputMobileNumber;
  final bool inputIsValid;

  const ProfileUpdateFormDataState({
    required this.inputName,
    required this.inputMobileNumber,
    required this.inputIsValid,
  }) : super(
          name: inputName,
          mobile_number: inputMobileNumber,
          isValid: inputIsValid,
        );

  @override
  List<Object?> get props => [
        inputName,
        inputMobileNumber,
        inputIsValid,
      ];
}
