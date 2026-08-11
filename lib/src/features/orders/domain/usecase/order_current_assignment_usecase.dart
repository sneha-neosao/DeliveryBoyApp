import 'package:delivery_boy_app/src/core/errors/failures.dart';
import 'package:delivery_boy_app/src/core/usecases/usecase.dart';
import 'package:delivery_boy_app/src/remote/models/order_model/vegetable_grocery_order_models/order_current_assignment_reponse.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../remote/repositories/repository_impl.dart';

/// Domain layer use case for requesting order current assignment

class OrderCurrentAssignmentUseCase implements UseCase<OrderCurrentAssignmentResponse, NoParams> {
  final Repository _authRepository;

  const OrderCurrentAssignmentUseCase(this._authRepository);

  @override
  Future<Either<Failure, OrderCurrentAssignmentResponse>> call(NoParams params) async {
    final result = await _authRepository.orderCurrentAssignment(params);

    return result;
  }
}
