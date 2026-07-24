import 'package:delivery_boy_app/src/core/errors/exceptions.dart';
import 'package:delivery_boy_app/src/core/errors/failures.dart';
import 'package:delivery_boy_app/src/core/session/session_manager.dart';
import 'package:delivery_boy_app/src/core/usecases/usecase.dart';
import 'package:delivery_boy_app/src/core/utils/failure_converter.dart';
import 'package:delivery_boy_app/src/core/utils/logger.dart';
import 'package:delivery_boy_app/src/features/login/domain/login_usecase.dart';
import 'package:delivery_boy_app/src/features/login/domain/logout_usecase.dart';
import 'package:delivery_boy_app/src/remote/models/auth_model/Login_response.dart';
import 'package:delivery_boy_app/src/remote/models/common_response.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

part 'auth_login_event.dart';
part 'auth_login_state.dart';

/// Handles state management for **Auth Login** and its related entities.

class AuthLoginBloc extends Bloc<AuthEvent, AuthLoginState> {
  final AuthLoginUseCase _loginUseCase;
  final LogoutUseCase _logoutUseCase;
  // final ForgotPasswordUseCase _forgotPasswordUseCase;
  // final AccountDeleteUseCase _accountDeleteUseCase;
  AuthLoginBloc(
    this._loginUseCase,
    this._logoutUseCase,
    // this._forgotPasswordUseCase,
    // this._accountDeleteUseCase
  ) : super(AuthLoginInitialState()) {
    on<AuthLoginEvent>(_login);
    on<AuthCheckSignInStatusEvent>(_checkSignInStatus);
    on<AuthLogoutEvent>(_logout);
    // on<AuthForgotPasswordEvent>(_forgotPassword);
    // on<AccountDeleteGetEvent>(_accountDelete);
  }

  /// - **Login:** Handles [AuthLoginEvent] → calls [AuthLoginUseCase]
  Future _login(AuthLoginEvent event, Emitter emit) async {
    emit(AuthLoginLoadingState());

    final result = await _loginUseCase.call(
      LoginParams(
        email: event.email,
        password: event.password,
      ),
    );

    result.fold(
      (l) => emit(AuthLoginFailureState(l.message)),
      (r) => emit(AuthLoginSuccessState(r)),
    );
  }

  /// - **Check Sign-In Status:** Handles [AuthCheckSignInStatusEvent] → checks [SessionManager]
  Future<Either<Failure, LoginResponse>> checkSignInStatus() async {
    try {
      final result = await SessionManager.isLoggedIn();

      if(result==true) {
        final resultData = await SessionManager.getUserSession();
        return Right(resultData!);
      }
      return Left(CacheFailure(mapFailureToMessage(CacheFailure(""))));
    } on CacheException {
      return Left(CacheFailure(mapFailureToMessage(CacheFailure(""))));
    }
  }

  Future _checkSignInStatus(AuthCheckSignInStatusEvent event, Emitter emit) async
  {
      emit(AuthCheckSignInStatusLoadingState());

      final result= await checkSignInStatus();
      result.fold(
            (l) => emit(AuthCheckSignInStatusFailureState(mapFailureToMessage(l))),
            (r) => emit(AuthCheckSignInStatusSuccessState(r)),
      );
  }

  /// - **Logout:** Handles [AuthLogoutEvent] → clears [SessionManager]
  Future _logout(AuthLogoutEvent event, Emitter emit) async {
    emit(AuthLogoutLoadingState());

    final result = await _logoutUseCase.call(
      NoParams()
    );

    result.fold(
          (l) => emit(AuthLogoutFailureState(l.message)),
          (r) => emit(AuthLogoutSuccessState(r)),
    );
  }
  // Future _logout(AuthLogoutEvent event, Emitter emit) async {
  //   emit(AuthLogoutLoadingState());
  //
  //   final result =  await SessionManager.clear();
  //
  //   result.fold(
  //         (l) => emit(AuthLogoutFailureState(mapFailureToMessage(l))),
  //         (r) => emit(const AuthLogoutSuccessState("Logout Success")),
  //   );
  // }

  // /// - **Forgot Password:** Handles [AuthForgotPasswordEvent]
  // Future _forgotPassword(AuthForgotPasswordEvent event, Emitter emit) async {
  //   emit(AuthForgotPasswordLoadingState());
  //
  //   final result = await _forgotPasswordUseCase.call(
  //     ForgotPasswordParams(
  //       company_code: event.company_code,
  //       email: event.email,
  //     ),
  //   );
  //
  //   result.fold(
  //         (l) => emit(AuthForgotPasswordFailureState(l.message)),
  //         (r) => emit(AuthForgotPasswordSuccessState(r,event.email)),
  //   );
  // }
  //
  // ///   - Delete user account
  // Future _accountDelete(AccountDeleteGetEvent event, Emitter emit) async {
  //   emit(AccountDeleteLoadingState());
  //
  //   final result = await _accountDeleteUseCase.call(
  //       AccountDeleteParams(
  //         id: event.id,
  //       )
  //   );
  //
  //   result.fold(
  //         (l) => emit(AccountDeleteFailureState(l.message)),
  //         (r) => emit(AccountDeleteSuccessState(r)),
  //   );
  // }

  @override
  Future<void> close() {
    logger.i("===== CLOSE AuthLoginBloc =====");
    return super.close();
  }
}
