import 'package:delivery_boy_app/src/core/errors/failures.dart';
import 'package:delivery_boy_app/src/core/usecases/usecase.dart';
import 'package:delivery_boy_app/src/remote/models/order_model/order_details_response.dart';
import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../configs/injector/injector.dart';

/// Domain layer use case for requesting order details

class OrderDetailsUseCase implements UseCase<OrderDetailsResponse, OrderDetailsParams> {
  final Repository _authRepository;

  const OrderDetailsUseCase(this._authRepository);

  @override
  Future<Either<Failure, OrderDetailsResponse>> call(OrderDetailsParams params) async {
    final result = await _authRepository.orderDetails(params);

    return result;
  }
}

typedef OrderListUseCase = OrderDetailsUseCase;


class OrderDetailsParams extends Equatable {
  final String uu_id ;

  const OrderDetailsParams({
    required this.uu_id ,
  });

  @override
  List<Object?> get props => [uu_id];
}
