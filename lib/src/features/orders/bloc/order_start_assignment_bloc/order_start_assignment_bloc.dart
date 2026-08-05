import 'package:delivery_boy_app/src/core/utils/logger.dart';
import 'package:delivery_boy_app/src/features/orders/domain/usecase/order_start_assignment_usecase.dart';
import 'package:delivery_boy_app/src/remote/models/order_model/order_start_assignment_response.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'order_start_assignment_event.dart';
part 'order_start_assignment_state.dart';

/// Handles state management for **Order Details** and its related entities.

class OrderStartAssignmentBloc extends Bloc<OrderStartAssignmentEvent, OrderStartAssignmentState> {
  final OrderStartAssignmentUseCase _orderStartAssignmentUseCase;
  OrderStartAssignmentBloc(
    this._orderStartAssignmentUseCase,
  ) : super(OrderStartAssignmentInitialState()) {
    on<OrderStartAssignmentGetEvent>(_orderDetails);
  }

  /// - **_orderDetails:** Handles [OrderStartAssignmentGetEvent] → calls [OrderStartAssignmentUseCase]
  Future _orderDetails(OrderStartAssignmentGetEvent event, Emitter emit) async {
    emit(OrderStartAssignmentLoadingState());

    final result = await _orderStartAssignmentUseCase.call(
      OrderStartAssignmentParams(
        uu_id: event.uu_id,
        status: event.status
      ),
    );

    result.fold(
      (l) => emit(OrderStartAssignmentFailureState(l.message)),
      (r) => emit(OrderStartAssignmentSuccessState(r)),
    );
  }

  @override
  Future<void> close() {
    logger.i("===== CLOSE OrderStartAssignmentBloc =====");
    return super.close();
  }
}
