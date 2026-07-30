import 'dart:convert';

class OrderAssignmentResponse {
  final int status;
  final String message;
  final OrderAssignment? data;

  OrderAssignmentResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory OrderAssignmentResponse.fromRawJson(String str) =>
      OrderAssignmentResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory OrderAssignmentResponse.fromJson(Map<String, dynamic> json) {
    return OrderAssignmentResponse(
      status: json["status"] ?? 0,
      message: json["message"] ?? "",
      data: json["data"] != null ? OrderAssignment.fromJson(json["data"]) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data?.toJson(),
  };
}

class OrderAssignment {
  final String orderUuId;
  final int deliveryBoyId;
  final String status;
  final bool isDelete;
  final String note;

  OrderAssignment({
    required this.orderUuId,
    required this.deliveryBoyId,
    required this.status,
    required this.isDelete,
    required this.note,
  });

  factory OrderAssignment.fromJson(Map<String, dynamic> json) => OrderAssignment(
    orderUuId: json["order_uu_id"] ?? "",
    deliveryBoyId: json["delivery_boy_id"] ?? 0,
    status: json["status"] ?? "",
    isDelete: json["is_delete"] ?? false,
    note: json["note"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "order_uu_id": orderUuId,
    "delivery_boy_id": deliveryBoyId,
    "status": status,
    "is_delete": isDelete,
    "note": note,
  };
}
