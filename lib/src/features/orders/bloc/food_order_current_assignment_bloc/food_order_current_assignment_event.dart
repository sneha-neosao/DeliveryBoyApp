part of 'food_order_current_assignment_bloc.dart';

sealed class FoodOrderCurrentAssignmentEvent extends Equatable {
  const FoodOrderCurrentAssignmentEvent();

  @override
  List<Object?> get props => [];
}

/// Event for food order assignment.

class FoodOrderCurrentAssignmentGetEvent extends FoodOrderCurrentAssignmentEvent {

  const FoodOrderCurrentAssignmentGetEvent();

  @override
  List<Object?> get props => [];
}