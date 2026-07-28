import 'dart:convert';

class OrdersListResponse {
  final int status;
  final String message;
  final List<Order> data;
  final Pagination? pagination;

  OrdersListResponse({
    required this.status,
    required this.message,
    required this.data,
    this.pagination,
  });

  factory OrdersListResponse.fromRawJson(String str) =>
      OrdersListResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory OrdersListResponse.fromJson(Map<String, dynamic> json) {
    return OrdersListResponse(
      status: json["status"] ?? 0,
      message: json["message"] ?? "",
      data: (json["data"] as List? ?? [])
          .map((x) => Order.fromJson(x ?? {}))
          .toList(),
      pagination: json["pagination"] != null
          ? Pagination.fromJson(json["pagination"])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data.map((x) => x.toJson()).toList(),
    "pagination": pagination?.toJson(),
  };
}

class Order {
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
  final String slotStartTime;
  final String slotEndTime;
  final String deliveryDate;
  final bool isAssigned;
  final int assignedDeliveryBoyId;
  final String assignedDeliveryBoyName;
  final String assignedDeliveryBoyPhone;
  final String assignmentStatus;

  Order({
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
    required this.slotStartTime,
    required this.slotEndTime,
    required this.deliveryDate,
    required this.isAssigned,
    required this.assignedDeliveryBoyId,
    required this.assignedDeliveryBoyName,
    required this.assignedDeliveryBoyPhone,
    required this.assignmentStatus,
  });

  factory Order.fromJson(Map<String, dynamic> json) => Order(
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
    slotStartTime: json["slot_start_time"] ?? "",
    slotEndTime: json["slot_end_time"] ?? "",
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

class Pagination {
  final int total;
  final int perPage;
  final int currentPage;
  final int totalPages;

  Pagination({
    required this.total,
    required this.perPage,
    required this.currentPage,
    required this.totalPages,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
    total: json["total"] ?? 0,
    perPage: json["per_page"] ?? 0,
    currentPage: json["current_page"] ?? 0,
    totalPages: json["total_pages"] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    "total": total,
    "per_page": perPage,
    "current_page": currentPage,
    "total_pages": totalPages,
  };
}
