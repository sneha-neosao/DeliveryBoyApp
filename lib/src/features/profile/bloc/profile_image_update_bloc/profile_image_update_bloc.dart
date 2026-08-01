import 'package:delivery_boy_app/src/core/utils/logger.dart';
import 'package:delivery_boy_app/src/features/profile/domain/usecase/profile_image_update_usecase.dart';
import 'package:delivery_boy_app/src/remote/models/profile_model/profile_image_update_response.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'profile_image_update_event.dart';
part 'profile_image_update_state.dart';

/// Handles state management for **Photo Update** and its related entities.

class ProfileImageUpdateBloc extends Bloc<ProfileImageUpdateEvent, ProfileImageUpdateState> {
  final ProfileImageUpdateUseCase _profileImageUpdateUseCase;
  ProfileImageUpdateBloc(
    this._profileImageUpdateUseCase,
  ) : super(ProfileImageUpdateInitialState()) {
    on<PhotoUpdateGetEvent>(_photoupdate);
  }

  ///   - Update an existing profile photo
  void _photoupdate(
      PhotoUpdateGetEvent event,
      Emitter<ProfileImageUpdateState> emit,
      ) async {
    print("📸 PhotoUpdateGetEvent triggered with path: ${event.profile_image}");

    emit(ProfileImageUpdateLoadingState());

    try {
      final result = await _profileImageUpdateUseCase.call(
          ProfileImageUpdateParams(
        profile_image: event.profile_image,
      ));

      result.fold(
            (failure) {
          print("❌ Photo update failed: ${failure.message}");
          emit(ProfileImageUpdateFailureState(failure.message));
        },
            (success) {
          print("✅ Photo update success");
          emit(ProfileImageUpdateSuccessState( success));
        },
      );
    } catch (e) {
      print("❗ Error in PhotoUpdateBloc: $e");
      emit(ProfileImageUpdateFailureState("Something went wrong"));
    }
  }


  @override
  Future<void> close() {
    logger.i("===== CLOSE ProfileImageUpdateBloc =====");
    return super.close();
  }
}
