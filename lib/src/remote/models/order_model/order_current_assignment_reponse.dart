import 'dart:convert';

class OrderCurrentAssignmentResponse {
  final int status;
  final String message;
  final AssignmentBatch? data;

  OrderCurrentAssignmentResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory OrderCurrentAssignmentResponse.fromRawJson(String str) =>
      OrderCurrentAssignmentResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory OrderCurrentAssignmentResponse.fromJson(Map<String, dynamic> json) {
    return OrderCurrentAssignmentResponse(
      status: json["status"] ?? 0,
      message: json["message"] ?? "",
      data: json["data"] != null ? AssignmentBatch.fromJson(json["data"]) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data?.toJson(),
  };
}

class AssignmentBatch {
  final int id;
  final String uuid;
  final int deliveryBoyId;
  final int orderCount;
  final bool isStart;
  final List<int> orderIds;
  final String createdAt;
  final String updatedAt;

  AssignmentBatch({
    required this.id,
    required this.uuid,
    required this.deliveryBoyId,
    required this.orderCount,
    required this.isStart,
    required this.orderIds,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AssignmentBatch.fromJson(Map<String, dynamic> json) => AssignmentBatch(
    id: json["id"] ?? 0,
    uuid: json["uuid"] ?? "",
    deliveryBoyId: json["delivery_boy_id"] ?? 0,
    orderCount: json["order_count"] ?? 0,
    isStart: json["is_start"] ?? false,
    orderIds: (json["order_ids"] as List? ?? [])
        .map((x) => (x ?? 0) as int)
        .toList(),
    createdAt: json["created_at"] ?? "",
    updatedAt: json["updated_at"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "uuid": uuid,
    "delivery_boy_id": deliveryBoyId,
    "order_count": orderCount,
    "is_start": isStart,
    "order_ids": orderIds,
    "created_at": createdAt,
    "updated_at": updatedAt,
  };
}
