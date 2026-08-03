import 'package:delivery_boy_app/src/core/errors/failures.dart';
import 'package:delivery_boy_app/src/core/usecases/usecase.dart';
import 'package:delivery_boy_app/src/remote/models/order_model/order_status_update_response.dart';
import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../configs/injector/injector.dart';

/// Domain layer use case for requesting order status update

class OrderStatusUpdateUseCase implements UseCase<OrderStatusUpdateResponse, OrderStatusUpdateParams> {
  final Repository _authRepository;

  const OrderStatusUpdateUseCase(this._authRepository);

  @override
  Future<Either<Failure, OrderStatusUpdateResponse>> call(OrderStatusUpdateParams params) async {
    final result = await _authRepository.orderStatusUpdate(params);

    return result;
  }
}

class OrderStatusUpdateParams extends Equatable {
  final String uu_id ;
  final String status;
  final String? note;

  const OrderStatusUpdateParams({
    required this.uu_id ,
    required this.status,
    this.note
  });

  @override
  List<Object?> get props => [uu_id, status, note];
}
