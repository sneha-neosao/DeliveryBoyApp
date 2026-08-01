part of 'profile_image_update_bloc.dart';

/// Base state for the CPhotoUpdateBloc.
///
/// Extends [Equatable] to support value comparison so that BLoC can detect
/// state changes efficiently.
sealed class ProfileImageUpdateState extends Equatable {
  const ProfileImageUpdateState();
  @override
  List<Object?> get props => [];
}

//change profile photo state
class ProfileImageUpdateInitialState extends ProfileImageUpdateState {}

/// States like loading, success and failure representing profile photo update.

class ProfileImageUpdateLoadingState extends ProfileImageUpdateState {}

class ProfileImageUpdateSuccessState extends ProfileImageUpdateState {
  final ProfileImageUpdateResponse data;

  const ProfileImageUpdateSuccessState(this.data);

  @override
  List<Object?> get props => [data];
}

class ProfileImageUpdateFailureState extends ProfileImageUpdateState {
  final String message;

  const ProfileImageUpdateFailureState(this.message);

  @override
  List<Object?> get props => [message];
}




