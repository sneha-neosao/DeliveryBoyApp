import 'dart:convert';

class OrderCurrentAssignmentResponse {
  final int status;
  final String message;
  final AssignmentBatch? data;
  final String autoAssignMode;

  OrderCurrentAssignmentResponse({
    required this.status,
    required this.message,
    this.data,
    this.autoAssignMode = '',
  });

  factory OrderCurrentAssignmentResponse.fromRawJson(String str) =>
      OrderCurrentAssignmentResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory OrderCurrentAssignmentResponse.fromJson(Map<String, dynamic> json) {
    return OrderCurrentAssignmentResponse(
      status: json["status"] ?? 0,
      message: json["message"] ?? "",
      data: json["data"] != null ? AssignmentBatch.fromJson(json["data"]) : null,
      autoAssignMode: json["auto_assign_mode"] ?? json["autoAssignMode"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data?.toJson(),
    "auto_assign_mode": autoAssignMode,
  };
}

class AssignmentBatch {
  final int id;
  final String uuid;
  final int deliveryBoyId;
  final int orderCount;
  final bool isStart;
  final String status;
  final List<int> orderIds;
  final String createdAt;
  final String updatedAt;
  final OrderSetting? orderSetting;
  final String autoAssignMode;

  AssignmentBatch({
    required this.id,
    required this.uuid,
    required this.deliveryBoyId,
    required this.orderCount,
    required this.isStart,
    required this.status,
    required this.orderIds,
    required this.createdAt,
    required this.updatedAt,
    this.orderSetting,
    this.autoAssignMode = '',
  });

  String get effectiveAutoAssignMode {
    if (autoAssignMode.isNotEmpty) return autoAssignMode;
    if (orderSetting?.autoAssignMode != null && orderSetting!.autoAssignMode.isNotEmpty) {
      return orderSetting!.autoAssignMode;
    }
    return '';
  }

  factory AssignmentBatch.fromJson(Map<String, dynamic> json) => AssignmentBatch(
    id: json["id"] ?? 0,
    uuid: json["uuid"] ?? "",
    deliveryBoyId: json["delivery_boy_id"] ?? 0,
    orderCount: json["order_count"] ?? 0,
    isStart: json["is_start"] ?? false,
    status: json["status"] ?? "",
    orderIds: (json["order_ids"] as List? ?? [])
        .map((x) => (x ?? 0) as int)
        .toList(),
    createdAt: json["created_at"] ?? "",
    updatedAt: json["updated_at"] ?? "",
    orderSetting: json["order_setting"] != null
        ? OrderSetting.fromJson(json["order_setting"])
        : null,
    autoAssignMode: json["auto_assign_mode"] ??
        json["autoAssignMode"] ??
        (json["order_setting"] != null
            ? (json["order_setting"]["auto_assign_mode"] ?? json["order_setting"]["autoAssignMode"])
            : null) ??
        "",
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "uuid": uuid,
    "delivery_boy_id": deliveryBoyId,
    "order_count": orderCount,
    "is_start": isStart,
    "status": status,
    "order_ids": orderIds,
    "created_at": createdAt,
    "updated_at": updatedAt,
    "order_setting": orderSetting?.toJson(),
    "auto_assign_mode": autoAssignMode,
  };
}

class OrderSetting {
  final int id;
  final String uuId;
  final bool isCodEnabled;
  final bool isOnlineEnabled;
  final bool isFirstOrderFree;
  final String autoAssignMode;
  final bool isActive;

  OrderSetting({
    required this.id,
    required this.uuId,
    required this.isCodEnabled,
    required this.isOnlineEnabled,
    required this.isFirstOrderFree,
    required this.autoAssignMode,
    required this.isActive,
  });

  factory OrderSetting.fromJson(Map<String, dynamic> json) => OrderSetting(
    id: json["id"] ?? 0,
    uuId: json["uu_id"] ?? "",
    isCodEnabled: json["is_cod_enabled"] ?? false,
    isOnlineEnabled: json["is_online_enabled"] ?? false,
    isFirstOrderFree: json["is_first_order_free"] ?? false,
    autoAssignMode: json["auto_assign_mode"] ?? json["autoAssignMode"] ?? "",
    isActive: json["is_active"] ?? false,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "uu_id": uuId,
    "is_cod_enabled": isCodEnabled,
    "is_online_enabled": isOnlineEnabled,
    "is_first_order_free": isFirstOrderFree,
    "auto_assign_mode": autoAssignMode,
    "is_active": isActive,
  };
}
