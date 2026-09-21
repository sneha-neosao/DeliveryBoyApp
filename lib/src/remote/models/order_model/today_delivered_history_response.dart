import 'dart:convert';
import 'food_order_model/order_list_response.dart';

class TodayDeliveredHistoryResponse {
  final int status;
  final String message;
  final List<TodayDeliveredOrder> data;
  final TodayDeliveredPagination? pagination;

  TodayDeliveredHistoryResponse({
    required this.status,
    required this.message,
    required this.data,
    this.pagination,
  });

  factory TodayDeliveredHistoryResponse.fromRawJson(String str) =>
      TodayDeliveredHistoryResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory TodayDeliveredHistoryResponse.fromJson(Map<String, dynamic> json) =>
      TodayDeliveredHistoryResponse(
        status: json["status"] ?? 0,
        message: json["message"] ?? "",
        data: json["data"] == null
            ? []
            : List<TodayDeliveredOrder>.from(
                (json["data"] as List).map((x) => TodayDeliveredOrder.fromJson(x ?? {})),
              ),
        pagination: json["pagination"] == null
            ? null
            : TodayDeliveredPagination.fromJson(json["pagination"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
        "pagination": pagination?.toJson(),
      };
}

class TodayDeliveredOrder {
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
  final int? assignedDeliveryBoyId;
  final String? assignedDeliveryBoyName;
  final String? assignedDeliveryBoyPhone;
  final String assignmentStatus;

  TodayDeliveredOrder({
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
    this.assignedDeliveryBoyId,
    this.assignedDeliveryBoyName,
    this.assignedDeliveryBoyPhone,
    required this.assignmentStatus,
  });

  factory TodayDeliveredOrder.fromRawJson(String str) =>
      TodayDeliveredOrder.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory TodayDeliveredOrder.fromJson(Map<String, dynamic> json) => TodayDeliveredOrder(
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
        deliveryLat: (json["delivery_lat"] as num?)?.toDouble(),
        deliveryLng: (json["delivery_lng"] as num?)?.toDouble(),
        storeLatitude: (json["store_latitude"] as num?)?.toDouble(),
        storeLongitude: (json["store_longitude"] as num?)?.toDouble(),
        slotStartTime: json["slot_start_time"],
        slotEndTime: json["slot_end_time"],
        deliveryDate: json["delivery_date"] ?? "",
        isAssigned: json["is_assigned"] ?? false,
        assignedDeliveryBoyId: json["assigned_delivery_boy_id"],
        assignedDeliveryBoyName: json["assigned_delivery_boy_name"],
        assignedDeliveryBoyPhone: json["assigned_delivery_boy_phone"],
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

  Order toOrder() => Order(
        id: id,
        uuId: uuId,
        orderStatus: orderStatus,
        paymentMode: paymentMode,
        paymentStatus: paymentStatus,
        grandTotal: grandTotal,
        platformCharges: platformCharges,
        totalItems: totalItems,
        customerName: customerName,
        customerContact: customerContact,
        deliveryAddress: deliveryAddress,
        deliveryName: deliveryName,
        deliveryPhone: deliveryPhone,
        deliveryPincode: deliveryPincode,
        slotStartTime: slotStartTime ?? '',
        slotEndTime: slotEndTime ?? '',
        deliveryDate: deliveryDate,
        isAssigned: isAssigned,
        assignedDeliveryBoyId: assignedDeliveryBoyId ?? 0,
        assignedDeliveryBoyName: assignedDeliveryBoyName ?? '',
        assignedDeliveryBoyPhone: assignedDeliveryBoyPhone ?? '',
        assignmentStatus: assignmentStatus,
        deliveryLat: deliveryLat ?? 0.0,
        deliveryLng: deliveryLng ?? 0.0,
        storeLatitude: storeLatitude,
        storeLongitude: storeLongitude,
      );
}

class TodayDeliveredPagination {
  final int total;
  final int perPage;
  final int currentPage;
  final int totalPages;

  TodayDeliveredPagination({
    required this.total,
    required this.perPage,
    required this.currentPage,
    required this.totalPages,
  });

  factory TodayDeliveredPagination.fromRawJson(String str) =>
      TodayDeliveredPagination.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory TodayDeliveredPagination.fromJson(Map<String, dynamic> json) =>
      TodayDeliveredPagination(
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
