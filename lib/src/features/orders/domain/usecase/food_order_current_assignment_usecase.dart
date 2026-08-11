import 'package:delivery_boy_app/src/core/errors/failures.dart';
import 'package:delivery_boy_app/src/core/usecases/usecase.dart';
import 'package:delivery_boy_app/src/remote/models/order_model/food_order_model/current_food_assignment_response.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../configs/injector/injector.dart';

/// Domain layer use case for requesting order current assignment

class FoodOrderCurrentAssignmentUseCase implements UseCase<CurrentFoodAssignmentResponse, NoParams> {
  final Repository _authRepository;

  const FoodOrderCurrentAssignmentUseCase(this._authRepository);

  @override
  Future<Either<Failure, CurrentFoodAssignmentResponse>> call(NoParams params) async {
    final result = await _authRepository.foodOrderCurrentAssignment(params);

    return result;
  }
}

