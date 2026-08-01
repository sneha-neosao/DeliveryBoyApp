part of 'profile_update_bloc.dart';

sealed class ProfileUpdateEvent extends Equatable {
  const ProfileUpdateEvent();

  @override
  List<Object?> get props => [];
}

/// Event for profile update.

class ProfileUpdateGetEvent extends ProfileUpdateEvent {
  final String name;
  final String mobile_number;

  const ProfileUpdateGetEvent(this.name, this.mobile_number);

  @override
  List<Object?> get props => [name, mobile_number];
}