import 'package:delivery_boy_app/src/core/errors/failures.dart';
import 'package:delivery_boy_app/src/core/usecases/usecase.dart';
import 'package:delivery_boy_app/src/remote/models/online_status_model/online_status_response.dart';
import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../configs/injector/injector.dart';

/// Domain layer use case for requesting online status

class OnlineStatusUseCase implements UseCase<OnlineStatusResponse, OnlineStatusParams> {
  final Repository _authRepository;

  const OnlineStatusUseCase(this._authRepository);

  @override
  Future<Either<Failure, OnlineStatusResponse>> call(OnlineStatusParams params) async {
    final result = await _authRepository.onlineStatus(params);

    return result;
  }
}

class OnlineStatusParams extends Equatable {
  final bool is_online;

  const OnlineStatusParams({
    required this.is_online
  });

  @override
  List<Object?> get props => [is_online];
}
