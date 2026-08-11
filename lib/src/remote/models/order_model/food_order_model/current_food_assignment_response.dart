import 'dart:convert';

class CurrentFoodAssignmentResponse {
  final int status;
  final String message;
  final AssignmentOrder? data;

  CurrentFoodAssignmentResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory CurrentFoodAssignmentResponse.fromRawJson(String str) =>
      CurrentFoodAssignmentResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory CurrentFoodAssignmentResponse.fromJson(Map<String, dynamic> json) {
    return CurrentFoodAssignmentResponse(
      status: json["status"] ?? 0,
      message: json["message"] ?? "",
      data: json["data"] != null ? AssignmentOrder.fromJson(json["data"]) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data?.toJson(),
  };
}

class AssignmentOrder {
  final int id;
  final String uuId;
  final String orderStatus;
  final String paymentMode;
  final String paymentStatus;
  final num grandTotal;
  final num platformCharges;
  final int totalItems;
  final String customerName;
  final String customerContact;
  final String deliveryAddress;
  final String deliveryName;
  final String deliveryPhone;
  final String deliveryPincode;
  final double? deliveryLat;
  final double? deliveryLng;
  final double? storeLatitude;
  final double? storeLongitude;
  final String? slotStartTime;
  final String? slotEndTime;
  final String deliveryDate;
  final bool isAssigned;
  final int assignedDeliveryBoyId;
  final String assignedDeliveryBoyName;
  final String assignedDeliveryBoyPhone;
  final String assignmentStatus;

  AssignmentOrder({
    required this.id,
    required this.uuId,
    required this.orderStatus,
    required this.paymentMode,
    required this.paymentStatus,
    required this.grandTotal,
    required this.platformCharges,
    required this.totalItems,
    required this.customerName,
    required this.customerContact,
    required this.deliveryAddress,
    required this.deliveryName,
    required this.deliveryPhone,
    required this.deliveryPincode,
    this.deliveryLat,
    this.deliveryLng,
    this.storeLatitude,
    this.storeLongitude,
    this.slotStartTime,
    this.slotEndTime,
    required this.deliveryDate,
    required this.isAssigned,
    required this.assignedDeliveryBoyId,
    required this.assignedDeliveryBoyName,
    required this.assignedDeliveryBoyPhone,
    required this.assignmentStatus,
  });

  factory AssignmentOrder.fromJson(Map<String, dynamic> json) => AssignmentOrder(
    id: json["id"] ?? 0,
    uuId: json["uu_id"] ?? "",
    orderStatus: json["order_status"] ?? "",
    paymentMode: json["payment_mode"] ?? "",
    paymentStatus: json["payment_status"] ?? "",
    grandTotal: json["grand_total"] ?? 0,
    platformCharges: json["platform_charges"] ?? 0,
    totalItems: json["total_items"] ?? 0,
    customerName: json["customer_name"] ?? "",
    customerContact: json["customer_contact"] ?? "",
    deliveryAddress: json["delivery_address"] ?? "",
    deliveryName: json["delivery_name"] ?? "",
    deliveryPhone: json["delivery_phone"] ?? "",
    deliveryPincode: json["delivery_pincode"] ?? "",
    deliveryLat: (json["delivery_lat"] != null)
        ? (json["delivery_lat"] as num).toDouble()
        : null,
    deliveryLng: (json["delivery_lng"] != null)
        ? (json["delivery_lng"] as num).toDouble()
        : null,
    storeLatitude: (json["store_latitude"] != null)
        ? (json["store_latitude"] as num).toDouble()
        : null,
    storeLongitude: (json["store_longitude"] != null)
        ? (json["store_longitude"] as num).toDouble()
        : null,
    slotStartTime: json["slot_start_time"],
    slotEndTime: json["slot_end_time"],
    deliveryDate: json["delivery_date"] ?? "",
    isAssigned: json["is_assigned"] ?? false,
    assignedDeliveryBoyId: json["assigned_delivery_boy_id"] ?? 0,
    assignedDeliveryBoyName: json["assigned_delivery_boy_name"] ?? "",
    assignedDeliveryBoyPhone: json["assigned_delivery_boy_phone"] ?? "",
    assignmentStatus: json["assignment_status"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "uu_id": uuId,
    "order_status": orderStatus,
    "payment_mode": paymentMode,
    "payment_status": paymentStatus,
    "grand_total": grandTotal,
    "platform_charges": platformCharges,
    "total_items": totalItems,
    "customer_name": customerName,
    "customer_contact": customerContact,
    "delivery_address": deliveryAddress,
    "delivery_name": deliveryName,
    "delivery_phone": deliveryPhone,
    "delivery_pincode": deliveryPincode,
    "delivery_lat": deliveryLat,
    "delivery_lng": deliveryLng,
    "store_latitude": storeLatitude,
    "store_longitude": storeLongitude,
    "slot_start_time": slotStartTime,
    "slot_end_time": slotEndTime,
    "delivery_date": deliveryDate,
    "is_assigned": isAssigned,
    "assigned_delivery_boy_id": assignedDeliveryBoyId,
    "assigned_delivery_boy_name": assignedDeliveryBoyName,
    "assigned_delivery_boy_phone": assignedDeliveryBoyPhone,
    "assignment_status": assignmentStatus,
  };
}
