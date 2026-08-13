import 'package:delivery_boy_app/src/core/usecases/usecase.dart';
import 'package:delivery_boy_app/src/core/utils/logger.dart';
import 'package:delivery_boy_app/src/features/profile/domain/usecase/delete_account_usecase.dart';
import 'package:delivery_boy_app/src/features/profile/domain/usecase/profile_usecase.dart';
import 'package:delivery_boy_app/src/remote/models/common_response.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'delete_account_event.dart';
part 'delete_account_state.dart';

/// Handles state management for **Account Delete** and its related entities.

class DeleteAccountBloc extends Bloc<DeleteAccountEvent, DeleteAccountState> {
  final DeleteAccountUseCase _deleteAccountUseCase;
  DeleteAccountBloc(
    this._deleteAccountUseCase,
  ) : super(DeleteAccountInitialState()) {
    on<DeleteAccountGetEvent>(_deleteAccount);
  }

  /// - **_profile:** Handles [DeleteAccountGetEvent] → calls [ProfileUseCase]
  Future _deleteAccount(DeleteAccountGetEvent event, Emitter emit) async {
    emit(DeleteAccountLoadingState());

    final result = await _deleteAccountUseCase.call(
      NoParams(),
    );

    result.fold(
      (l) => emit(DeleteAccountFailureState(l.message)),
      (r) => emit(DeleteAccountSuccessState(r)),
    );
  }

  @override
  Future<void> close() {
    logger.i("===== CLOSE DeleteAccountBloc =====");
    return super.close();
  }
}
