import 'dart:convert';

class OrderDetailsResponse {
  final int status;
  final String message;
  final OrderDetails? data;

  OrderDetailsResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory OrderDetailsResponse.fromRawJson(String str) =>
      OrderDetailsResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory OrderDetailsResponse.fromJson(Map<String, dynamic> json) {
    return OrderDetailsResponse(
      status: json["status"] ?? 0,
      message: json["message"] ?? "",
      data: json["data"] != null ? OrderDetails.fromJson(json["data"]) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data?.toJson(),
  };
}

class OrderDetails {
  final int id;
  final String uuId;
  final num totalAmount;
  final num grandTotal;
  final num platformCharges;
  final int totalItems;
  final String note;
  final String paymentMode;
  final String paymentStatus;
  final String orderStatus;
  final String createdAt;
  final String customerName;
  final String? customerEmail;
  final String customerContact;
  final String slotStartTime;
  final String slotEndTime;
  final String deliveryDate;
  final DeliveryDetails? deliveryDetails;
  final List<Item> items;
  final List<StatusLog> statusLogs;

  OrderDetails({
    required this.id,
    required this.uuId,
    required this.totalAmount,
    required this.grandTotal,
    required this.platformCharges,
    required this.totalItems,
    required this.note,
    required this.paymentMode,
    required this.paymentStatus,
    required this.orderStatus,
    required this.createdAt,
    required this.customerName,
    this.customerEmail,
    required this.customerContact,
    required this.slotStartTime,
    required this.slotEndTime,
    required this.deliveryDate,
    this.deliveryDetails,
    required this.items,
    required this.statusLogs,
  });

  factory OrderDetails.fromJson(Map<String, dynamic> json) => OrderDetails(
    id: json["id"] ?? 0,
    uuId: json["uu_id"] ?? "",
    totalAmount: json["total_amount"] ?? 0,
    grandTotal: json["grand_total"] ?? 0,
    platformCharges: json["platform_charges"] ?? 0,
    totalItems: json["total_items"] ?? 0,
    note: json["note"] ?? "",
    paymentMode: json["payment_mode"] ?? "",
    paymentStatus: json["payment_status"] ?? "",
    orderStatus: json["order_status"] ?? "",
    createdAt: json["created_at"] ?? "",
    customerName: json["customer_name"] ?? "",
    customerEmail: json["customer_email"],
    customerContact: json["customer_contact"] ?? "",
    slotStartTime: json["slot_start_time"] ?? "",
    slotEndTime: json["slot_end_time"] ?? "",
    deliveryDate: json["delivery_date"] ?? "",
    deliveryDetails: json["delivery_details"] != null
        ? DeliveryDetails.fromJson(json["delivery_details"])
        : null,
    items: (json["items"] as List? ?? [])
        .map((x) => Item.fromJson(x ?? {}))
        .toList(),
    statusLogs: (json["status_logs"] as List? ?? [])
        .map((x) => StatusLog.fromJson(x ?? {}))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "uu_id": uuId,
    "total_amount": totalAmount,
    "grand_total": grandTotal,
    "platform_charges": platformCharges,
    "total_items": totalItems,
    "note": note,
    "payment_mode": paymentMode,
    "payment_status": paymentStatus,
    "order_status": orderStatus,
    "created_at": createdAt,
    "customer_name": customerName,
    "customer_email": customerEmail,
    "customer_contact": customerContact,
    "slot_start_time": slotStartTime,
    "slot_end_time": slotEndTime,
    "delivery_date": deliveryDate,
    "delivery_details": deliveryDetails?.toJson(),
    "items": items.map((x) => x.toJson()).toList(),
    "status_logs": statusLogs.map((x) => x.toJson()).toList(),
  };
}

class DeliveryDetails {
  final String name;
  final String phone;
  final String address;
  final String pincode;
  final double deliveryLat;
  final double deliveryLng;

  DeliveryDetails({
    required this.name,
    required this.phone,
    required this.address,
    required this.pincode,
    required this.deliveryLat,
    required this.deliveryLng,
  });

  factory DeliveryDetails.fromJson(Map<String, dynamic> json) => DeliveryDetails(
    name: json["name"] ?? "",
    phone: json["phone"] ?? "",
    address: json["address"] ?? "",
    pincode: json["pincode"] ?? "",
    deliveryLat: (json["delivery_lat"] ?? 0).toDouble(),
    deliveryLng: (json["delivery_lng"] ?? 0).toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "phone": phone,
    "address": address,
    "pincode": pincode,
    "delivery_lat": deliveryLat,
    "delivery_lng": deliveryLng,
  };
}

class Item {
  final int productId;
  final int productVariantId;
  final String productName;
  final String variantName;
  final String uomName;
  final int? itemId;
  final String? vendorItemName;
  final List<String> images;
  final int quantity;
  final num price;
  final num totalPrice;

  Item({
    required this.productId,
    required this.productVariantId,
    required this.productName,
    required this.variantName,
    required this.uomName,
    this.itemId,
    this.vendorItemName,
    required this.images,
    required this.quantity,
    required this.price,
    required this.totalPrice,
  });

  factory Item.fromJson(Map<String, dynamic> json) => Item(
    productId: json["product_id"] ?? 0,
    productVariantId: json["product_variant_id"] ?? 0,
    productName: json["product_name"] ?? "",
    variantName: json["variant_name"] ?? "",
    uomName: json["uom_name"] ?? "",
    itemId: json["item_id"],
    vendorItemName: json["vendor_item_name"],
    images: (json["images"] as List? ?? []).map((x) => x.toString()).toList(),
    quantity: json["quantity"] ?? 0,
    price: json["price"] ?? 0,
    totalPrice: json["total_price"] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    "product_id": productId,
    "product_variant_id": productVariantId,
    "product_name": productName,
    "variant_name": variantName,
    "uom_name": uomName,
    "item_id": itemId,
    "vendor_item_name": vendorItemName,
    "images": images,
    "quantity": quantity,
    "price": price,
    "total_price": totalPrice,
  };
}

class StatusLog {
  final String? fromStatus;
  final String toStatus;
  final String changedBy;
  final String note;
  final String createdAt;

  StatusLog({
    this.fromStatus,
    required this.toStatus,
    required this.changedBy,
    required this.note,
    required this.createdAt,
  });

  factory StatusLog.fromJson(Map<String, dynamic> json) => StatusLog(
    fromStatus: json["from_status"],
    toStatus: json["to_status"] ?? "",
    changedBy: json["changed_by"] ?? "",
    note: json["note"] ?? "",
    createdAt: json["created_at"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "from_status": fromStatus,
    "to_status": toStatus,
    "changed_by": changedBy,
    "note": note,
    "created_at": createdAt,
  };
}
