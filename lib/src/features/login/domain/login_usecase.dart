import 'package:delivery_boy_app/src/core/errors/failures.dart';
import 'package:delivery_boy_app/src/core/extensions/string_validator_extension.dart';
import 'package:delivery_boy_app/src/core/usecases/usecase.dart';
import 'package:delivery_boy_app/src/core/utils/failure_converter.dart';
import 'package:delivery_boy_app/src/remote/models/auth_model/Login_response.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import '../../../configs/injector/injector.dart';

/// Domain layer use case for logging in into account, validates inputs and calls repository method.

class AuthLoginUseCase implements UseCase<LoginResponse, LoginParams> {
  final Repository _authRepository;
  const AuthLoginUseCase(this._authRepository);

  @override
  Future<Either<Failure, LoginResponse>> call(LoginParams params) async {

    if (params.email.isEmpty) {
      return Left(EmptyFailure("please_enter_email".tr()));
    }

    if (!params.email.isEmailValid) {
      return Left(InvalidEmailFailure(mapFailureToMessage(InvalidEmailFailure(""))));
    }

    if (params.password.isEmpty) {
      return Left(EmptyFailure("please_enter_password".tr()));
    }

    if (!params.password.isPasswordValid) {
      return Left(InvalidEmailFailure(mapFailureToMessage(InvalidPasswordFailure(""))));
    }

    final result = await _authRepository.login(params);

    return result;
  }
}

class LoginParams extends Equatable {
  final String email;
  final String password;
  const LoginParams({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [
        email,
        password,
      ];
}
