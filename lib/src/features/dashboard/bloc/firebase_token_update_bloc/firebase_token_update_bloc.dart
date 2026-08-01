import 'package:delivery_boy_app/src/features/dashboard/domain/usecase/firebase_token_update_usecase.dart';
import 'package:delivery_boy_app/src/remote/models/auth_model/firebase_token_update_response.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/logger.dart';

part 'firebase_token_update_event.dart';
part 'firebase_token_update_state.dart';

/// Handles state management for **Firebase Token Update** and its related entities.
class FirebaseTokenUpdateBloc extends Bloc<FirebaseTokenUpdateEvent, FirebaseTokenUpdateState> {
  final FirebaseTokenUpdateUseCase _firebaseTokenUpdateUseCase;
  FirebaseTokenUpdateBloc(
    this._firebaseTokenUpdateUseCase,
  ) : super(FirebaseTokenUpdateInitialState()) {
    on<FirebaseTokenUpdateGetEvent>(_firebaseTokenUpdate);
  }

  ///   - Updates firebase token
  Future _firebaseTokenUpdate(FirebaseTokenUpdateGetEvent event, Emitter emit) async {
    emit(FirebaseTokenUpdateLoadingState());

    final result = await _firebaseTokenUpdateUseCase.call(
      FirebaseTokenUpdateParams(
          firebase_id: event.firebase_id!,
      )
    );

    result.fold(
          (l) => emit(FirebaseTokenUpdateFailureState(l.message)),
          (r) => emit(FirebaseTokenUpdateSuccessState(r)),
    );
  }

  @override
  Future<void> close() {
    logger.i("===== CLOSE FirebaseTokenUpdateBloc =====");
    return super.close();
  }
}
