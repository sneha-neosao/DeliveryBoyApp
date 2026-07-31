import 'package:delivery_boy_app/src/core/usecases/usecase.dart';
import 'package:delivery_boy_app/src/core/utils/logger.dart';
import 'package:delivery_boy_app/src/features/profile/domain/usecase/profile_usecase.dart';
import 'package:delivery_boy_app/src/remote/models/profile_model/profile_response.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'profile_event.dart';
part 'profile_state.dart';

/// Handles state management for **Profile Details** and its related entities.

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileUseCase _profileUseCase;
  ProfileBloc(
    this._profileUseCase,
  ) : super(ProfileInitialState()) {
    on<ProfileGetEvent>(_profile);
  }

  /// - **_profile:** Handles [ProfileGetEvent] → calls [ProfileUseCase]
  Future _profile(ProfileGetEvent event, Emitter emit) async {
    emit(ProfileLoadingState());

    final result = await _profileUseCase.call(
      NoParams(),
    );

    result.fold(
      (l) => emit(ProfileFailureState(l.message)),
      (r) => emit(ProfileSuccessState(r)),
    );
  }

  @override
  Future<void> close() {
    logger.i("===== CLOSE ProfileBloc =====");
    return super.close();
  }
}
