import 'package:delivery_boy_app/src/core/utils/logger.dart';
import 'package:delivery_boy_app/src/features/orders/domain/usecase/order_assignment_usecase.dart';
import 'package:delivery_boy_app/src/features/orders/domain/usecase/order_details_usecase.dart';
import 'package:delivery_boy_app/src/remote/models/order_model/order_assignment_response.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'order_assignment_event.dart';
part 'order_assignment_state.dart';

/// Handles state management for **Order assignment** and its related entities.

class OrderAssignmentBloc extends Bloc<OrderAssignmentEvent, OrderAssignmentState> {
  final OrderAssignmentUseCase _orderAssignmentUseCase;
  OrderAssignmentBloc(
    this._orderAssignmentUseCase,
  ) : super(OrderAssignmentInitialState()) {
    on<OrderAssignmentGetEvent>(_orderAssignment);
  }

  /// - **Order assignment:** Handles [OrderAssignmentGetEvent] → calls [OrderDetailsUseCase]
  Future _orderAssignment(OrderAssignmentGetEvent event, Emitter emit) async {
    emit(OrderAssignmentLoadingState());

    final result = await _orderAssignmentUseCase.call(
      OrderAssignmentParams(
        uu_id: event.uu_id,
        action: event.action,
        note: event.note
      ),
    );

    result.fold(
      (l) => emit(OrderAssignmentFailureState(l.message)),
      (r) => emit(OrderAssignmentSuccessState(r)),
    );
  }

  @override
  Future<void> close() {
    logger.i("===== CLOSE OrderAssignmentBloc =====");
    return super.close();
  }
}
