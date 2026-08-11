part of 'food_order_current_assignment_bloc.dart';

sealed class FoodOrderCurrentAssignmentState extends Equatable {
  const FoodOrderCurrentAssignmentState();
  @override
  List<Object?> get props => [];
}

class FoodOrderCurrentAssignmentInitialState extends FoodOrderCurrentAssignmentState {}

/// States like loading, success and failure representing food order current assignment.

class FoodOrderCurrentAssignmentLoadingState extends FoodOrderCurrentAssignmentState {}

class FoodOrderCurrentAssignmentSuccessState extends FoodOrderCurrentAssignmentState {
  final CurrentFoodAssignmentResponse data;

  const FoodOrderCurrentAssignmentSuccessState(this.data);

  @override
  List<Object?> get props => [data];
}

class FoodOrderCurrentAssignmentFailureState extends FoodOrderCurrentAssignmentState {
  final String message;

  const FoodOrderCurrentAssignmentFailureState(this.message);

  @override
  List<Object?> get props => [message];
}