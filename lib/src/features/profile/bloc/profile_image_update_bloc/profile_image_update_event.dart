part of 'profile_image_update_bloc.dart';

/// Event for profile photo update.

sealed class ProfileImageUpdateEvent extends Equatable {
  const ProfileImageUpdateEvent();

  @override
  List<Object?> get props => [];
}

class PhotoUpdateGetEvent extends ProfileImageUpdateEvent {


  final String profile_image;

  const PhotoUpdateGetEvent(this.profile_image);

  @override
  List<Object?> get props => [profile_image];
}