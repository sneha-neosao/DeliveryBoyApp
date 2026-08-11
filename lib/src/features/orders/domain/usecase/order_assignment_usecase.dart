import 'package:delivery_boy_app/src/core/errors/failures.dart';
import 'package:delivery_boy_app/src/core/usecases/usecase.dart';
import 'package:delivery_boy_app/src/remote/models/order_model/vegetable_grocery_order_models/order_assignment_response.dart';
import 'package:delivery_boy_app/src/remote/models/order_model/order_details_response.dart';
import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../configs/injector/injector.dart';

/// Domain layer use case for requesting order assignment

class OrderAssignmentUseCase implements UseCase<OrderAssignmentResponse, OrderAssignmentParams> {
  final Repository _authRepository;

  const OrderAssignmentUseCase(this._authRepository);

  @override
  Future<Either<Failure, OrderAssignmentResponse>> call(OrderAssignmentParams params) async {
    final result = await _authRepository.orderAssignment(params);

    return result;
  }
}

class OrderAssignmentParams extends Equatable {
  final String uu_id ;
  final String action;
  final String? note;

  const OrderAssignmentParams({
    required this.uu_id ,
    required this.action,
    required this.note
  });

  @override
  List<Object?> get props => [uu_id, action, note];
}
