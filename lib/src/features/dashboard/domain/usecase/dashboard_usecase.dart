import 'package:delivery_boy_app/src/core/errors/failures.dart';
import 'package:delivery_boy_app/src/core/usecases/usecase.dart';
import 'package:delivery_boy_app/src/remote/models/dashboard_model/dashboard_response.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../configs/injector/injector.dart';

/// Domain layer use case for requesting dashboard information

class DashboardUseCase implements UseCase<DashboardStatsResponse, NoParams> {
  final Repository _authRepository;

  const DashboardUseCase(this._authRepository);

  @override
  Future<Either<Failure, DashboardStatsResponse>> call(NoParams params) async {
    final result = await _authRepository.dashboard(params);

    return result;
  }
}
