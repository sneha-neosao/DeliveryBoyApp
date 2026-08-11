import 'package:delivery_boy_app/src/core/usecases/usecase.dart';
import 'package:delivery_boy_app/src/core/utils/logger.dart';
import 'package:delivery_boy_app/src/features/orders/domain/usecase/food_order_current_assignment_usecase.dart';
import 'package:delivery_boy_app/src/remote/models/order_model/food_order_model/current_food_assignment_response.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'food_order_current_assignment_event.dart';
part 'food_order_current_assignment_state.dart';

/// Handles state management for **Food Order Current Assignment** and its related entities.

class FoodOrderCurrentAssignmentBloc extends Bloc<FoodOrderCurrentAssignmentEvent, FoodOrderCurrentAssignmentState> {
  final FoodOrderCurrentAssignmentUseCase _foodOrderCurrentAssignmentUseCase;
  FoodOrderCurrentAssignmentBloc(
    this._foodOrderCurrentAssignmentUseCase,
  ) : super(FoodOrderCurrentAssignmentInitialState()) {
    on<FoodOrderCurrentAssignmentGetEvent>(_orderCurrentAssignment);
  }

  /// - **_orderCurrentAssignment:** Handles [FoodOrderCurrentAssignmentGetEvent] → calls [FoodOrderCurrentAssignmentUseCase]
  Future _orderCurrentAssignment(FoodOrderCurrentAssignmentGetEvent event, Emitter emit) async {
    emit(FoodOrderCurrentAssignmentLoadingState());

    final result = await _foodOrderCurrentAssignmentUseCase.call(
      NoParams()
    );

    result.fold(
      (l) => emit(FoodOrderCurrentAssignmentFailureState(l.message)),
      (r) => emit(FoodOrderCurrentAssignmentSuccessState(r)),
    );
  }

  @override
  Future<void> close() {
    logger.i("===== CLOSE FoodOrderCurrentAssignmentBloc =====");
    return super.close();
  }
}
