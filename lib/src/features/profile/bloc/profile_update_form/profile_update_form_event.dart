part of 'profile_update_form_bloc.dart';

/// Base class for all events related to LoginValidationBloc.
/// Extends [Equatable] to support value comparison, which helps BLoC
/// determine whether state updates are necessary.
sealed class ProfileUpdateFormEvent extends Equatable {
  const ProfileUpdateFormEvent();

  @override
  List<Object?> get props => [];
}

/// listens for change in name input
class NameChangedEvent extends ProfileUpdateFormEvent {
  final String name;

  const NameChangedEvent(this.name);

  @override
  List<Object?> get props => [name];
}

/// listens for change in mobile number input

class MobileNumberChangedEvent extends ProfileUpdateFormEvent {
  final String mobile_number;

  const MobileNumberChangedEvent(this.mobile_number);

  @override
  List<Object?> get props => [mobile_number];
}
