import 'package:delivery_boy_app/src/core/utils/logger.dart';
import 'package:delivery_boy_app/src/features/orders/domain/usecase/order_details_usecase.dart';
import 'package:delivery_boy_app/src/features/orders/domain/usecase/order_status_update_usecase.dart';
import 'package:delivery_boy_app/src/remote/models/order_model/vegetable_grocery_order_models/order_status_update_response.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'order_status_update_event.dart';
part 'order_status_update_state.dart';

/// Handles state management for **Order Status Update** and its related entities.

class OrderStatusUpdateBloc extends Bloc<OrderStatusUpdateEvent, OrderStatusUpdateState> {
  final OrderStatusUpdateUseCase _orderStatusUpdateUseCase;
  OrderStatusUpdateBloc(
    this._orderStatusUpdateUseCase,
  ) : super(OrderStatusUpdateInitialState()) {
    on<OrderStatusUpdateGetEvent>(_orderStatusUpdate);
  }

  /// - **_orderStatusUpdate:** Handles [OrderStatusUpdateGetEvent] → calls [OrderStatusUpdateUseCase]
  Future _orderStatusUpdate(OrderStatusUpdateGetEvent event, Emitter emit) async {
    emit(OrderStatusUpdateLoadingState());

    final result = await _orderStatusUpdateUseCase.call(
      OrderStatusUpdateParams(
        uu_id: event.uu_id,
        status: event.status,
        note: event.note
      ),
    );

    result.fold(
      (l) => emit(OrderStatusUpdateFailureState(l.message)),
      (r) => emit(OrderStatusUpdateSuccessState(r)),
    );
  }

  @override
  Future<void> close() {
    logger.i("===== CLOSE OrderStatusUpdateBloc =====");
    return super.close();
  }
}
