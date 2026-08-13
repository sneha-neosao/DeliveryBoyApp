import 'package:delivery_boy_app/src/core/usecases/usecase.dart';
import 'package:delivery_boy_app/src/core/utils/logger.dart';
import 'package:delivery_boy_app/src/features/dashboard/domain/usecase/app_update_usecase.dart';
import 'package:delivery_boy_app/src/remote/models/version_model/app_update_response.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'app_update_event.dart';
part 'app_update_state.dart';

/// Handles state management for **App Update** and its related entities.

class AppUpdateBloc extends Bloc<AppUpdateEvent, AppUpdateState> {
  final AppUpdateUseCase _appUpdateUseCase;
  AppUpdateBloc(
    this._appUpdateUseCase,
  ) : super(AppUpdateInitialState()) {
    on<AppUpdateGetEvent>(_appUpdate);
  }

  /// - **_appUpdate:** Handles [AppUpdateGetEvent] → calls [AppUpdateUseCase]
  Future _appUpdate(AppUpdateGetEvent event, Emitter emit) async {
    emit(AppUpdateLoadingState());

    final result = await _appUpdateUseCase.call(
      NoParams(),
    );

    result.fold(
      (l) => emit(AppUpdateFailureState(l.message)),
      (r) => emit(AppUpdateSuccessState(r)),
    );
  }

  @override
  Future<void> close() {
    logger.i("===== CLOSE AppUpdateBloc =====");
    return super.close();
  }
}
