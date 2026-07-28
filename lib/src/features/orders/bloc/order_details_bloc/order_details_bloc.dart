import 'package:delivery_boy_app/src/core/utils/logger.dart';
import 'package:delivery_boy_app/src/features/orders/domain/usecase/order_details_usecase.dart';
import 'package:delivery_boy_app/src/remote/models/order_model/order_details_response.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'order_details_event.dart';
part 'order_details_state.dart';

/// Handles state management for **Order Details** and its related entities.

class OrderDetailsBloc extends Bloc<OrderDetailsEvent, OrderDetailsState> {
  final OrderDetailsUseCase _orderDetailsUseCase;
  OrderDetailsBloc(
    this._orderDetailsUseCase,
  ) : super(OrderDetailsInitialState()) {
    on<OrderDetailsGetEvent>(_orderDetails);
  }

  /// - **Login:** Handles [OrderDetailsGetEvent] → calls [OrderDetailsUseCase]
  Future _orderDetails(OrderDetailsGetEvent event, Emitter emit) async {
    emit(OrderDetailsLoadingState());

    final result = await _orderDetailsUseCase.call(
      OrderDetailsParams(
        uu_id: event.uu_id
      ),
    );

    result.fold(
      (l) => emit(OrderDetailsFailureState(l.message)),
      (r) => emit(OrderDetailsSuccessState(r)),
    );
  }

  @override
  Future<void> close() {
    logger.i("===== CLOSE OrderDetailsBloc =====");
    return super.close();
  }
}
