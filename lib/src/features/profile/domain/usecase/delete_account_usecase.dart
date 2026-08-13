import 'package:delivery_boy_app/src/core/errors/failures.dart';
import 'package:delivery_boy_app/src/core/usecases/usecase.dart';
import 'package:delivery_boy_app/src/remote/models/common_response.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../configs/injector/injector.dart';

/// Domain layer use case for requesting delete account

class DeleteAccountUseCase implements UseCase<CommonResponse, NoParams> {
  final Repository _authRepository;

  const DeleteAccountUseCase(this._authRepository);

  @override
  Future<Either<Failure, CommonResponse>> call(NoParams params) async {
    final result = await _authRepository.deleteAccount(params);

    return result;
  }
}
