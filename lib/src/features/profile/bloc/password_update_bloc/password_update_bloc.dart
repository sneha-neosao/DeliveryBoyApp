import 'package:delivery_boy_app/src/core/utils/logger.dart';
import 'package:delivery_boy_app/src/features/login/domain/login_usecase.dart';
import 'package:delivery_boy_app/src/features/profile/domain/usecase/password_update_usecase.dart';
import 'package:delivery_boy_app/src/remote/models/common_response.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'password_update_event.dart';
part 'password_update_state.dart';

/// Handles state management for **Password update** and its related entities.

class PasswordUpdateBloc extends Bloc<PasswordUpdateEvent, PasswordUpdateState> {
  final PasswordUpdateUseCase _passwordUpdateUseCase;
  PasswordUpdateBloc(
    this._passwordUpdateUseCase,
  ) : super(PasswordUpdateInitialState()) {
    on<PasswordUpdateGetEvent>(_updatePassword);
  }

  /// - **_updatePassword:** Handles [PasswordUpdateGetEvent] → calls [AuthLoginUseCase]
  Future _updatePassword(PasswordUpdateGetEvent event, Emitter emit) async {
    emit(PasswordUpdateLoadingState());

    final result = await _passwordUpdateUseCase.call(
      PasswordUpdateParams(
        old_password: event.old_password,
        new_password: event.new_pssword,
        confirm_password: event.confirm_password
      ),
    );

    result.fold(
      (l) => emit(PasswordUpdateFailureState(l.message)),
      (r) => emit(PasswordUpdateSuccessState(r)),
    );
  }

  @override
  Future<void> close() {
    logger.i("===== CLOSE PasswordUpdateBloc =====");
    return super.close();
  }
}
