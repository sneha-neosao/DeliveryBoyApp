import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/logger.dart';

part 'profile_update_form_event.dart';
part 'profile_update_form_state.dart';

/// Handles validation logic for **Profile Update**.
class ProfileUpdateFormBloc extends Bloc<ProfileUpdateFormEvent, ProfileUpdateFormState> {
  ProfileUpdateFormBloc() : super(const ProfileUpdateFormInitialState()) {
    on<NameChangedEvent>(_nameChanged);
    on<MobileNumberChangedEvent>(_mobileNumberChanged);
  }

  /// - Listens to changes in name input
  Future _nameChanged(NameChangedEvent event, Emitter emit) async {
    emit(
      ProfileUpdateFormDataState(
        inputName: event.name,
        inputMobileNumber: state.mobile_number,
        inputIsValid: inputValidator(
          event.name,
          state.mobile_number
        ),
      ),
    );
  }

  /// - Listens to changes in mobile number input
  Future _mobileNumberChanged(MobileNumberChangedEvent event, Emitter emit) async {
    emit(
      ProfileUpdateFormDataState(
        inputName: state.name,
        inputMobileNumber: event.mobile_number,
        inputIsValid: inputValidator(
            state.name,
            event.mobile_number
        ),
      ),
    );
  }

  bool inputValidator(String name, String mobile_number,) {
    if (name.isNotEmpty && mobile_number.isNotEmpty ) {
      return true;
    }
    if (mobile_number.length < 10) {
      return false;
    }

    return false;
  }

  @override
  Future<void> close() {
    logger.i("===== CLOSE ProfileUpdateFormBloc =====");
    return super.close();
  }
}
