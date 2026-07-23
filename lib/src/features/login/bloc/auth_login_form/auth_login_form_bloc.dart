import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/logger.dart';

part 'auth_login_form_event.dart';
part 'auth_login_form_state.dart';

/// Handles validation logic for **Login**.
class AuthLoginFormBloc extends Bloc<LoginFormEvent, LoginFormState> {
  AuthLoginFormBloc() : super(const LoginFormInitialState()) {
    on<LoginFormEmailChangedEvent>(_emailChanged);
    on<LoginFormPasswordChangedEvent>(_passwordChanged);
  }

  /// - Listens to changes in login email input
  Future _emailChanged(LoginFormEmailChangedEvent event, Emitter emit) async {
    emit(
      LoginFormDataState(
        inputEmail: event.email,
        inputPassword: state.password,
        inputIsValid: inputValidator(
          event.email,
          state.password,
        ),
      ),
    );
  }

  /// - Listens to changes in login password input
  Future _passwordChanged(
      LoginFormPasswordChangedEvent event, Emitter emit) async {
    emit(
      LoginFormDataState(
        inputEmail: state.email,
        inputPassword: event.password,
        inputIsValid: inputValidator(
          state.email,
          event.password
        ),
      ),
    );
  }

  bool inputValidator(String email, String password) {
    if (email.isNotEmpty && password.isNotEmpty) {
      return true;
    }
    if (password.length < 6) {
      return false;
    }

    return false;
  }

  @override
  Future<void> close() {
    logger.i("===== CLOSE AuthLoginFormBloc =====");
    return super.close();
  }
}
