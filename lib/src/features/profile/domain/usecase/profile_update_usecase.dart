import 'package:delivery_boy_app/src/core/errors/failures.dart';
import 'package:delivery_boy_app/src/core/extensions/string_validator_extension.dart';
import 'package:delivery_boy_app/src/core/usecases/usecase.dart';
import 'package:delivery_boy_app/src/remote/models/profile_model/profile_update_response.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../configs/injector/injector.dart';

/// Domain layer use case for updating profile, validates inputs and calls repository method.

class ProfileUpdateUseCase implements UseCase<ProfileUpdateResponse, ProfileUpdateParams> {
  final Repository _authRepository;
  const ProfileUpdateUseCase(this._authRepository);

  @override
  Future<Either<Failure, ProfileUpdateResponse>> call(ProfileUpdateParams params) async {

    if (params.name.isEmpty) {
      return Left(EmptyFailure("please_enter_name".tr()));
    }

    if (params.mobile_number.isEmpty) {
      return Left(EmptyFailure("please_enter_mobile_number".tr()));
    }

    if (!params.mobile_number.isMobileNumberValid) {
      return Left(EmptyFailure("please_enter_valid_mobile_number".tr()));
    }

    final result = await _authRepository.profileUpdate(params);

    return result;
  }
}

class ProfileUpdateParams extends Equatable {
  final String name ;
  final String mobile_number;

  const ProfileUpdateParams({
    required this.name,
    required this.mobile_number
  });

  @override
  List<Object?> get props => [
        name,
        mobile_number
      ];
}
