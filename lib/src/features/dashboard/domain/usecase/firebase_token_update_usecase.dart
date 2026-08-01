import 'package:delivery_boy_app/src/core/errors/failures.dart';
import 'package:delivery_boy_app/src/core/usecases/usecase.dart';
import 'package:delivery_boy_app/src/remote/models/auth_model/firebase_token_update_response.dart';
import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../configs/injector/injector.dart';

/// Encapsulates the use case for fetching firebase token data with pagination.

class FirebaseTokenUpdateUseCase implements UseCase<FirebaseTokenUpdateResponse, FirebaseTokenUpdateParams> {
  final Repository _authRepository;
  const FirebaseTokenUpdateUseCase(this._authRepository);

  @override
  Future<Either<Failure, FirebaseTokenUpdateResponse>> call(FirebaseTokenUpdateParams params) async {

    final result = await _authRepository.firebaseTokenUpdate(params);

    return result;
  }
}

class FirebaseTokenUpdateParams extends Equatable {
  final String firebase_id;

  const FirebaseTokenUpdateParams({
    required this.firebase_id,
  });

  @override
  List<Object?> get props => [
    firebase_id,
  ];
}
