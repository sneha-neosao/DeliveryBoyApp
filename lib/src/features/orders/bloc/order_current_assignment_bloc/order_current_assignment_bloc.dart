import 'package:delivery_boy_app/src/core/usecases/usecase.dart';
import 'package:delivery_boy_app/src/core/utils/logger.dart';
import 'package:delivery_boy_app/src/features/orders/domain/usecase/order_current_assignment_usecase.dart';
import 'package:delivery_boy_app/src/features/orders/domain/usecase/order_details_usecase.dart';
import 'package:delivery_boy_app/src/remote/models/order_model/vegetable_grocery_order_models/order_current_assignment_reponse.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'order_current_assignment_event.dart';
part 'order_current_assignment_state.dart';

/// Handles state management for **Order Current Assignment** and its related entities.

class OrderCurrentAssignmentBloc extends Bloc<OrderCurrentAssignmentEvent, OrderCurrentAssignmentState> {
  final OrderCurrentAssignmentUseCase _orderCurrentAssignmentUseCase;
  OrderCurrentAssignmentBloc(
    this._orderCurrentAssignmentUseCase,
  ) : super(OrderCurrentAssignmentInitialState()) {
    on<OrderCurrentAssignmentGetEvent>(_orderCurrentAssignment);
  }

  /// - **_orderCurrentAssignment:** Handles [OrderCurrentAssignmentGetEvent] → calls [OrderDetailsUseCase]
  Future _orderCurrentAssignment(OrderCurrentAssignmentGetEvent event, Emitter emit) async {
    emit(OrderCurrentAssignmentLoadingState());

    final result = await _orderCurrentAssignmentUseCase.call(
      NoParams()
    );

    result.fold(
      (l) => emit(OrderCurrentAssignmentFailureState(l.message)),
      (r) => emit(OrderCurrentAssignmentSuccessState(r)),
    );
  }

  @override
  Future<void> close() {
    logger.i("===== CLOSE OrderCurrentAssignmentBloc =====");
    return super.close();
  }
}
