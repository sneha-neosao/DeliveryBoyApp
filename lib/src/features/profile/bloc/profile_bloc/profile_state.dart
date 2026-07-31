part of 'profile_bloc.dart';

sealed class ProfileState extends Equatable {
  const ProfileState();
  @override
  List<Object?> get props => [];
}

class ProfileInitialState extends ProfileState {}

/// States like loading, success and failure representing Profile details.

class ProfileLoadingState extends ProfileState {}

class ProfileSuccessState extends ProfileState {
  final LoginResponse data;

  const ProfileSuccessState(this.data);

  @override
  List<Object?> get props => [data];
}

class ProfileFailureState extends ProfileState {
  final String message;

  const ProfileFailureState(this.message);

  @override
  List<Object?> get props => [message];
}