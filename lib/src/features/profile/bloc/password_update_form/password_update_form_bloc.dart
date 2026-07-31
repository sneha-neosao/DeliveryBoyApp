import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/logger.dart';

part 'password_update_form_event.dart';
part 'password_update_form_state.dart';

/// Handles validation logic for **Password Update**.
class PasswordUpdateFormBloc extends Bloc<PasswordUpdateFormEvent, PasswordUpdateFormState> {
  PasswordUpdateFormBloc() : super(const PasswordUpdateFormInitialState()) {
    on<OldPasswordChangedEvent>(_oldPasswordChanged);
    on<NewPasswordChangedEvent>(_newPasswordChanged);
    on<ConfirmPasswordChangedEvent>(_confirmPasswordChanged);
  }

  /// - Listens to changes in old password input
  Future _oldPasswordChanged(OldPasswordChangedEvent event, Emitter emit) async {
    emit(
      PasswordUpdateFormDataState(
        inputOldPassword: event.old_password,
        inputNewPassword: state.new_password,
        inputConfirmPassword: state.confirm_password,
        inputIsValid: inputValidator(
          event.old_password,
          state.new_password,
          state.confirm_password
        ),
      ),
    );
  }

  /// - Listens to changes in new password input
  Future _newPasswordChanged(NewPasswordChangedEvent event, Emitter emit) async {
    emit(
      PasswordUpdateFormDataState(
        inputOldPassword: state.old_password,
        inputNewPassword: event.new_password,
        inputConfirmPassword: state.confirm_password,
        inputIsValid: inputValidator(
            state.old_password,
            event.new_password,
            state.confirm_password
        ),
      ),
    );
  }

  /// - Listens to changes in confirm password input
  Future _confirmPasswordChanged(ConfirmPasswordChangedEvent event, Emitter emit) async {
    emit(
      PasswordUpdateFormDataState(
        inputOldPassword: state.old_password,
        inputNewPassword: state.new_password,
        inputConfirmPassword: event.confirm_password,
        inputIsValid: inputValidator(
            state.old_password,
            state.new_password,
            event.confirm_password
        ),
      ),
    );
  }

  bool inputValidator(String old_password, String new_password, String confirm_password) {
    if (old_password.isNotEmpty && new_password.isNotEmpty && confirm_password.isNotEmpty) {
      return true;
    }
    if (old_password.length < 8 || old_password.length < 8 || old_password.length < 8) {
      return false;
    }

    return false;
  }

  @override
  Future<void> close() {
    logger.i("===== CLOSE PasswordUpdateFormBloc =====");
    return super.close();
  }
}
