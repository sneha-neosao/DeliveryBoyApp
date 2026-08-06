import 'package:delivery_boy_app/src/core/errors/failures.dart';
import 'package:delivery_boy_app/src/core/usecases/usecase.dart';
import 'package:delivery_boy_app/src/remote/models/order_model/current_assignment_order_list_response.dart';
import 'package:delivery_boy_app/src/remote/models/order_model/order_details_response.dart';
import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../configs/injector/injector.dart';

/// Domain layer use case for requesting current assignment order list

class CurrentAssignmentOrderListUseCase implements UseCase<CurrentAssignmentOrderListResponse, CurrentAssignmentOrderListParams> {
  final Repository _authRepository;

  const CurrentAssignmentOrderListUseCase(this._authRepository);

  @override
  Future<Either<Failure, CurrentAssignmentOrderListResponse>> call(CurrentAssignmentOrderListParams params) async {
    final result = await _authRepository.currentOrderAssignmentOrders(params);

    return result;
  }
}

class CurrentAssignmentOrderListParams extends Equatable {
  final String uuid ;
  final int page;
  final int limit;

  const CurrentAssignmentOrderListParams({
    required this.uuid ,
    required this.page,
    required this.limit
  });

  @override
  List<Object?> get props => [uuid, page, limit];
}
