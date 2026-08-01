part of 'firebase_token_update_bloc.dart';

sealed class FirebaseTokenUpdateState extends Equatable {
  const FirebaseTokenUpdateState();
  @override
  List<Object?> get props => [];
}

class FirebaseTokenUpdateInitialState extends FirebaseTokenUpdateState {}

/// States like loading, success and failure representing firebase token update.

class FirebaseTokenUpdateLoadingState extends FirebaseTokenUpdateState {}

class FirebaseTokenUpdateSuccessState extends FirebaseTokenUpdateState {
  final FirebaseTokenUpdateResponse data;

  const FirebaseTokenUpdateSuccessState(this.data);

  @override
  List<Object?> get props => [data];
}

class FirebaseTokenUpdateFailureState extends FirebaseTokenUpdateState {
  final String message;

  const FirebaseTokenUpdateFailureState(this.message);

  @override
  List<Object?> get props => [message];
}




