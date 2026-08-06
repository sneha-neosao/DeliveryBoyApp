import 'package:delivery_boy_app/src/core/utils/logger.dart';
import 'package:delivery_boy_app/src/features/bulk_orders/domain/usecase/current_assignment_order_list_usecase.dart';
import 'package:delivery_boy_app/src/features/orders/domain/usecase/order_details_usecase.dart';
import 'package:delivery_boy_app/src/remote/models/order_model/current_assignment_order_list_response.dart';
import 'package:delivery_boy_app/src/remote/models/order_model/order_details_response.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'current_assignment_orders_event.dart';
part 'current_assignment_orders_state.dart';

/// Handles state management for **Order Details** and its related entities.

class CurrentAssignmentOrdersBloc extends Bloc<CurrentAssignmentOrdersEvent, CurrentAssignmentOrdersState> {
  final CurrentAssignmentOrderListUseCase _currentAssignmentOrderListUseCase;
  CurrentAssignmentOrdersBloc(
    this._currentAssignmentOrderListUseCase,
  ) : super(CurrentAssignmentOrdersInitialState()) {
    on<CurrentAssignmentOrdersGetEvent>(_orderDetails);
  }

  /// - **Login:** Handles [CurrentAssignmentOrdersGetEvent] → calls [OrderDetailsUseCase]
  Future _orderDetails(CurrentAssignmentOrdersGetEvent event, Emitter emit) async {
    emit(CurrentAssignmentOrdersLoadingState());

    final result = await _currentAssignmentOrderListUseCase.call(
      CurrentAssignmentOrderListParams(
        uuid: event.uu_id,
        page: event.page,
        limit: event.limit
      ),
    );

    result.fold(
      (l) => emit(CurrentAssignmentOrdersFailureState(l.message)),
      (r) => emit(CurrentAssignmentOrdersSuccessState(r)),
    );
  }

  @override
  Future<void> close() {
    logger.i("===== CLOSE CurrentAssignmentOrdersBloc =====");
    return super.close();
  }
}
