import 'dart:convert';

/// Represents the API response for login.
class LoginResponse {
  dynamic status;
  String? message;
  LoginResult? data;

  LoginResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory LoginResponse.fromRawJson(String str) =>
      LoginResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
    status: json["status"],
    message: json["message"],
    data: json["data"] != null ? LoginResult.fromJson(json["data"]) : null,
  );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (status != null) map['status'] = status;
    if (message != null) map['message'] = message;
    if (data != null) map['data'] = data?.toJson();
    return map;
  }
}

/// Represents the login result containing tokens and delivery boy details.
class LoginResult {
  String? accessToken;
  String? refreshToken;
  String? tokenType;
  DeliveryBoy? deliveryBoy;

  LoginResult({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.deliveryBoy,
  });

  factory LoginResult.fromRawJson(String str) =>
      LoginResult.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory LoginResult.fromJson(Map<String, dynamic> json) => LoginResult(
    accessToken: json["access_token"] ?? "",
    refreshToken: json["refresh_token"] ?? "",
    tokenType: json["token_type"] ?? "",
    deliveryBoy: json["delivery_boy"] != null
        ? DeliveryBoy.fromJson(json["delivery_boy"])
        : null,
  );

  Map<String, dynamic> toJson() => {
    "access_token": accessToken,
    "refresh_token": refreshToken,
    "token_type": tokenType,
    "delivery_boy": deliveryBoy?.toJson(),
  };
}

/// Represents the delivery boy details.
class DeliveryBoy {
  int? id;
  String? uuId;
  String? name;
  String? phone;
  String? email;
  String? vehicleType;
  String? deliveryType;
  String? vehicleNumber;
  bool? isActive;
  bool? isAvailable;

  DeliveryBoy({
    required this.id,
    required this.uuId,
    required this.name,
    required this.phone,
    required this.email,
    required this.vehicleType,
    required this.deliveryType,
    required this.vehicleNumber,
    required this.isActive,
    required this.isAvailable,
  });

  factory DeliveryBoy.fromRawJson(String str) =>
      DeliveryBoy.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory DeliveryBoy.fromJson(Map<String, dynamic> json) => DeliveryBoy(
    id: json["id"],
    uuId: json["uu_id"] ?? "",
    name: json["name"] ?? "",
    phone: json["phone"] ?? "",
    email: json["email"] ?? "",
    vehicleType: json["vehicle_type"] ?? "",
    deliveryType: json["delivery_type"] ?? "",
    vehicleNumber: json["vehicle_number"] ?? "",
    isActive: json["is_active"] ?? false,
    isAvailable: json["is_available"] ?? false,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "uu_id": uuId,
    "name": name,
    "phone": phone,
    "email": email,
    "vehicle_type": vehicleType,
    "delivery_type": deliveryType,
    "vehicle_number": vehicleNumber,
    "is_active": isActive,
    "is_available": isAvailable,
  };
}
