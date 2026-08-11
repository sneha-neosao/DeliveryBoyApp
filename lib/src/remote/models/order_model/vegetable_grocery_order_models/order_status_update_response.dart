import 'dart:convert';

class OrderStatusUpdateResponse {
  final int status;
  final String message;
  final OrderStatusData? data;

  OrderStatusUpdateResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory OrderStatusUpdateResponse.fromRawJson(String str) =>
      OrderStatusUpdateResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory OrderStatusUpdateResponse.fromJson(Map<String, dynamic> json) {
    return OrderStatusUpdateResponse(
      status: json["status"] ?? 0,
      message: json["message"] ?? "",
      data: json["data"] != null ? OrderStatusData.fromJson(json["data"]) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data?.toJson(),
  };
}

class OrderStatusData {
  final int orderId;
  final String uuId;
  final String fromStatus;
  final String toStatus;
  final String orderStatus;
  final String paymentStatus;

  OrderStatusData({
    required this.orderId,
    required this.uuId,
    required this.fromStatus,
    required this.toStatus,
    required this.orderStatus,
    required this.paymentStatus,
  });

  factory OrderStatusData.fromJson(Map<String, dynamic> json) => OrderStatusData(
    orderId: json["order_id"] ?? 0,
    uuId: json["uu_id"] ?? "",
    fromStatus: json["from_status"] ?? "",
    toStatus: json["to_status"] ?? "",
    orderStatus: json["order_status"] ?? "",
    paymentStatus: json["payment_status"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "order_id": orderId,
    "uu_id": uuId,
    "from_status": fromStatus,
    "to_status": toStatus,
    "order_status": orderStatus,
    "payment_status": paymentStatus,
  };
}
