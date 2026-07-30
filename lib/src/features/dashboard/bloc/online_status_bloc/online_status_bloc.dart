import 'package:delivery_boy_app/src/core/utils/logger.dart';
import 'package:delivery_boy_app/src/features/dashboard/domain/usecase/online_status_usecase.dart';
import 'package:delivery_boy_app/src/features/orders/domain/usecase/order_details_usecase.dart';
import 'package:delivery_boy_app/src/remote/models/online_status_model/online_status_response.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'online_status_event.dart';
part 'online_status_state.dart';

/// Handles state management for **Online Status** and its related entities.

class OnlineStatusBloc extends Bloc<OnlineStatusEvent, OnlineStatusState> {
  final OnlineStatusUseCase _onlineStatusUseCase;
  OnlineStatusBloc(
    this._onlineStatusUseCase,
  ) : super(OnlineStatusInitialState()) {
    on<OnlineStatusGetEvent>(_onlineStatus);
  }

  /// - **_onlineStatus** Handles [OnlineStatusGetEvent] → calls [OrderDetailsUseCase]
  Future _onlineStatus(OnlineStatusGetEvent event, Emitter emit) async {
    emit(OnlineStatusLoadingState());

    final result = await _onlineStatusUseCase.call(
      OnlineStatusParams(
        is_online: event.is_online
      ),
    );

    result.fold(
      (l) => emit(OnlineStatusFailureState(l.message)),
      (r) => emit(OnlineStatusSuccessState(r)),
    );
  }

  @override
  Future<void> close() {
    logger.i("===== CLOSE OnlineStatusBloc =====");
    return super.close();
  }
}
