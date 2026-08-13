import 'package:delivery_boy_app/src/core/errors/failures.dart';
import 'package:delivery_boy_app/src/core/usecases/usecase.dart';
import 'package:delivery_boy_app/src/remote/models/version_model/app_update_response.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../configs/injector/injector.dart';

/// Domain layer use case for requesting app versions

class AppUpdateUseCase implements UseCase<AppUpdateResponse, NoParams> {
  final Repository _authRepository;

  const AppUpdateUseCase(this._authRepository);

  @override
  Future<Either<Failure, AppUpdateResponse>> call(NoParams params) async {
    final result = await _authRepository.appUpdate(params);

    return result;
  }
}
