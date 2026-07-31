import 'package:delivery_boy_app/src/core/errors/failures.dart';
import 'package:delivery_boy_app/src/core/usecases/usecase.dart';
import 'package:delivery_boy_app/src/remote/models/profile_model/profile_response.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../configs/injector/injector.dart';

/// Domain layer use case for requesting profile information

class ProfileUseCase implements UseCase<ProfileResponse, NoParams> {
  final Repository _authRepository;

  const ProfileUseCase(this._authRepository);

  @override
  Future<Either<Failure, ProfileResponse>> call(NoParams params) async {
    final result = await _authRepository.profile(params);

    return result;
  }
}
