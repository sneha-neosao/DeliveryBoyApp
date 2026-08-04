import 'dart:convert';

class OrderStartAssignmentResponse {
  final int status;
  final String message;
  final AssignmentBatchStart? data;

  OrderStartAssignmentResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory OrderStartAssignmentResponse.fromRawJson(String str) =>
      OrderStartAssignmentResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory OrderStartAssignmentResponse.fromJson(Map<String, dynamic> json) {
    return OrderStartAssignmentResponse(
      status: json["status"] ?? 0,
      message: json["message"] ?? "",
      data: json["data"] != null
          ? AssignmentBatchStart.fromJson(json["data"])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data?.toJson(),
  };
}

class AssignmentBatchStart {
  final String assignmentUuid;
  final bool isStart;
  final List<UpdatedOrder> updatedOrders;

  AssignmentBatchStart({
    required this.assignmentUuid,
    required this.isStart,
    required this.updatedOrders,
  });

  factory AssignmentBatchStart.fromJson(Map<String, dynamic> json) =>
      AssignmentBatchStart(
        assignmentUuid: json["assignment_uuid"] ?? "",
        isStart: json["is_start"] ?? false,
        updatedOrders: (json["updated_orders"] as List? ?? [])
            .map((x) => UpdatedOrder.fromJson(x ?? {}))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
    "assignment_uuid": assignmentUuid,
    "is_start": isStart,
    "updated_orders": updatedOrders.map((x) => x.toJson()).toList(),
  };
}

class UpdatedOrder {
  final int orderId;
  final String uuId;
  final String fromStatus;
  final String toStatus;

  UpdatedOrder({
    required this.orderId,
    required this.uuId,
    required this.fromStatus,
    required this.toStatus,
  });

  factory UpdatedOrder.fromJson(Map<String, dynamic> json) => UpdatedOrder(
    orderId: json["order_id"] ?? 0,
    uuId: json["uu_id"] ?? "",
    fromStatus: json["from_status"] ?? "",
    toStatus: json["to_status"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "order_id": orderId,
    "uu_id": uuId,
    "from_status": fromStatus,
    "to_status": toStatus,
  };
}
