import 'package:delivery_boy_app/src/core/errors/failures.dart';
import 'package:delivery_boy_app/src/core/usecases/usecase.dart';
import 'package:delivery_boy_app/src/remote/models/order_model/today_delivered_history_response.dart';
import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../configs/injector/injector.dart';

/// Domain layer use case for requesting today's delivered orders history
class TodayDeliveredHistoryUseCase
    implements UseCase<TodayDeliveredHistoryResponse, TodayDeliveredHistoryParams> {
  final Repository _repository;

  const TodayDeliveredHistoryUseCase(this._repository);

  @override
  Future<Either<Failure, TodayDeliveredHistoryResponse>> call(
      TodayDeliveredHistoryParams params) async {
    final result = await _repository.todayDeliveredHistory(params);
    return result;
  }
}

class TodayDeliveredHistoryParams extends Equatable {
  final int page;
  final int limit;

  const TodayDeliveredHistoryParams({
    required this.page,
    required this.limit,
  });

  @override
  List<Object?> get props => [page, limit];
}
