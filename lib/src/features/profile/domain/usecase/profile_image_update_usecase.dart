
import 'package:delivery_boy_app/src/core/errors/failures.dart';
import 'package:delivery_boy_app/src/core/usecases/usecase.dart';
import 'package:delivery_boy_app/src/remote/models/profile_model/profile_image_update_response.dart';
import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../configs/injector/injector.dart';

/// Domain layer use case for updating profile photo, validates inputs and calls repository method.

class ProfileImageUpdateUseCase implements UseCase<ProfileImageUpdateResponse, ProfileImageUpdateParams> {
  final Repository _authRepository;
  const ProfileImageUpdateUseCase(this._authRepository);

  @override
  Future<Either<Failure, ProfileImageUpdateResponse>> call(ProfileImageUpdateParams params) async {

    final result = await _authRepository.profileImageUpdate(params);

    return result;
  }
}

class ProfileImageUpdateParams extends Equatable {
  final String profile_image ;

  const ProfileImageUpdateParams({
    required this.profile_image ,
  });

  @override
  List<Object?> get props => [
    profile_image ,
  ];
}
