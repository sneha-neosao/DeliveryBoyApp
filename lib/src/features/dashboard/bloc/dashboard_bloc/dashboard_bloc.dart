import 'package:delivery_boy_app/src/core/usecases/usecase.dart';
import 'package:delivery_boy_app/src/core/utils/logger.dart';
import 'package:delivery_boy_app/src/features/dashboard/domain/usecase/dashboard_usecase.dart';
import 'package:delivery_boy_app/src/remote/models/dashboard_model/dashboard_response.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'dashboard_event.dart';
part 'dashboard_state.dart';

/// Handles state management for **Dashboard Information** and its related entities.

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final DashboardUseCase _dashboardUseCase;
  DashboardBloc(
    this._dashboardUseCase,
  ) : super(DashboardInitialState()) {
    on<DashboardGetEvent>(_dashboard);
  }

  /// - **_dashboard:** Handles [DashboardGetEvent] → calls [DashboardUseCase]
  Future _dashboard(DashboardGetEvent event, Emitter emit) async {
    emit(DashboardLoadingState());

    final result = await _dashboardUseCase.call(
      NoParams(),
    );

    result.fold(
      (l) => emit(DashboardFailureState(l.message)),
      (r) => emit(DashboardSuccessState(r)),
    );
  }

  @override
  Future<void> close() {
    logger.i("===== CLOSE DashboardBloc =====");
    return super.close();
  }
}
