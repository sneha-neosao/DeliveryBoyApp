import 'package:delivery_boy_app/src/core/errors/failures.dart';
import 'package:delivery_boy_app/src/core/usecases/usecase.dart';
import 'package:delivery_boy_app/src/remote/models/order_model/order_list_response.dart';
import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../configs/injector/injector.dart';

/// Domain layer use case for requesting order list

class OrderListUseCase implements UseCase<OrdersListResponse, OrderListParams> {
  final Repository _authRepository;

  const OrderListUseCase(this._authRepository);

  @override
  Future<Either<Failure, OrdersListResponse>> call(OrderListParams params) async {
    final result = await _authRepository.orderList(params);

    return result;
  }
}

class OrderListParams extends Equatable {
  final String? slot_uu_id;
  final String? delivery_date;
  final int? page, limit;

  const OrderListParams({
    required this.slot_uu_id,
    required this.delivery_date,
    required this.page,
    required this.limit,
  });

  @override
  List<Object?> get props => [slot_uu_id, delivery_date, page, limit];
}
