part of 'profile_bloc.dart';

sealed class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

/// Event for Profile details.

class ProfileGetEvent extends ProfileEvent {

  const ProfileGetEvent();

  @override
  List<Object?> get props => [];
}