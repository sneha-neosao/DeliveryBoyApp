import 'package:delivery_boy_app/src/core/utils/logger.dart';
import 'package:delivery_boy_app/src/features/profile/domain/usecase/profile_update_usecase.dart';
import 'package:delivery_boy_app/src/remote/models/profile_model/profile_update_response.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'profile_update_event.dart';
part 'profile_update_state.dart';

/// Handles state management for **Profile update** and its related entities.

class ProfileUpdateBloc extends Bloc<ProfileUpdateEvent, ProfileUpdateState> {
  final ProfileUpdateUseCase _profileUpdateUseCase;
  ProfileUpdateBloc(
    this._profileUpdateUseCase,
  ) : super(ProfileUpdateInitialState()) {
    on<ProfileUpdateGetEvent>(_updateProfile);
  }

  /// - **_updateProfile:** Handles [ProfileUpdateGetEvent] → calls [ProfileUpdateUseCase]
  Future _updateProfile(ProfileUpdateGetEvent event, Emitter emit) async {
    emit(ProfileUpdateLoadingState());

    final result = await _profileUpdateUseCase.call(
      ProfileUpdateParams(
        name: event.name,
        mobile_number: event.mobile_number,
      ),
    );

    result.fold(
      (l) => emit(ProfileUpdateFailureState(l.message)),
      (r) => emit(ProfileUpdateSuccessState(r)),
    );
  }

  @override
  Future<void> close() {
    logger.i("===== CLOSE ProfileUpdateBloc =====");
    return super.close();
  }
}
