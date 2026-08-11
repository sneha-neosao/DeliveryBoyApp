import 'package:delivery_boy_app/src/core/errors/failures.dart';
import 'package:delivery_boy_app/src/core/usecases/usecase.dart';
import 'package:delivery_boy_app/src/remote/models/order_model/vegetable_grocery_order_models/order_start_assignment_response.dart';
import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../configs/injector/injector.dart';

/// Domain layer use case for requesting order start assignment

class OrderStartAssignmentUseCase implements UseCase<OrderStartAssignmentResponse, OrderStartAssignmentParams> {
  final Repository _authRepository;

  const OrderStartAssignmentUseCase(this._authRepository);

  @override
  Future<Either<Failure, OrderStartAssignmentResponse>> call(OrderStartAssignmentParams params) async {
    final result = await _authRepository.orderStartAssignment(params);

    return result;
  }
}

class OrderStartAssignmentParams extends Equatable {
  final String uu_id ;
  final String status;

  const OrderStartAssignmentParams({
    required this.uu_id ,
    required this.status
  });

  @override
  List<Object?> get props => [uu_id, status];
}
