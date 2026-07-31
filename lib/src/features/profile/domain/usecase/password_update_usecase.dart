import 'package:delivery_boy_app/src/core/errors/failures.dart';
import 'package:delivery_boy_app/src/core/extensions/string_validator_extension.dart';
import 'package:delivery_boy_app/src/core/usecases/usecase.dart';
import 'package:delivery_boy_app/src/remote/models/common_response.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../configs/injector/injector.dart';

/// Domain layer use case for updating password, validates inputs and calls repository method.

class PasswordUpdateUseCase implements UseCase<CommonResponse, PasswordUpdateParams> {
  final Repository _authRepository;
  const PasswordUpdateUseCase(this._authRepository);

  @override
  Future<Either<Failure, CommonResponse>> call(PasswordUpdateParams params) async {

    if (params.old_password.isEmpty) {
      return Left(EmptyFailure("please_enter_old_password".tr()));
    }

    if (!params.old_password.isPasswordValid) {
      return Left(EmptyFailure("please_enter_valid_old_password".tr()));
    }

    if (params.new_password.isEmpty) {
      return Left(EmptyFailure("please_enter_new_password".tr()));
    }

    if (!params.new_password.isPasswordValid) {
      return Left(EmptyFailure("please_enter_valid_new_password".tr()));
    }

    if (params.confirm_password.isEmpty) {
      return Left(EmptyFailure("please_enter_confirm_password".tr()));
    }

    if (!params.confirm_password.isPasswordValid) {
      return Left(EmptyFailure("please_enter_valid_confirm_password".tr()));
    }

    final result = await _authRepository.passwordUpdate(params);

    return result;
  }
}

class PasswordUpdateParams extends Equatable {
  final String old_password ;
  final String new_password ;
  final String confirm_password;

  const PasswordUpdateParams({
    required this.old_password,
    required this.new_password,
    required this.confirm_password
  });

  @override
  List<Object?> get props => [
        old_password,
        new_password,
        confirm_password
      ];
}
