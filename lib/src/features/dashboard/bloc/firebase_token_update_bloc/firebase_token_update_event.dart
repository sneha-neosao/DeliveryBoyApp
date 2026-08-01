part of 'firebase_token_update_bloc.dart';

/// Event to update firebase token.

sealed class FirebaseTokenUpdateEvent extends Equatable {
  const FirebaseTokenUpdateEvent();

  @override
  List<Object?> get props => [];
}

/// Event to update firebase token .

class FirebaseTokenUpdateGetEvent extends FirebaseTokenUpdateEvent {
  final String? firebase_id;

  const FirebaseTokenUpdateGetEvent(this.firebase_id);

  @override
  List<Object?> get props => [firebase_id];
}