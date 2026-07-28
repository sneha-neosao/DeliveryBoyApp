import 'dart:convert';

class ProfileResponse {
  final int status;
  final String message;
  final ProfileData? data;

  ProfileResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory ProfileResponse.fromRawJson(String str) =>
      ProfileResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ProfileResponse.fromJson(Map<String, dynamic> json) => ProfileResponse(
    status: json["status"] ?? 0,
    message: json["message"] ?? "",
    data: json["data"] != null ? ProfileData.fromJson(json["data"]) : null,
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data?.toJson(),
  };
}

class ProfileData {
  final int id;
  final String uuId;
  final String name;
  final String phone;
  final String email;
  final String? profileImage;
  final String vehicleType;
  final String vehicleNumber;
  final bool isActive;
  final bool isOnline;
  final num commissionWallet;
  final num transactionWallet;
  final double? currentLatitude;
  final double? currentLongitude;
  final num avgRating;
  final int totalReviews;

  ProfileData({
    required this.id,
    required this.uuId,
    required this.name,
    required this.phone,
    required this.email,
    this.profileImage,
    required this.vehicleType,
    required this.vehicleNumber,
    required this.isActive,
    required this.isOnline,
    required this.commissionWallet,
    required this.transactionWallet,
    this.currentLatitude,
    this.currentLongitude,
    required this.avgRating,
    required this.totalReviews,
  });

  factory ProfileData.fromJson(Map<String, dynamic> json) => ProfileData(
    id: json["id"] ?? 0,
    uuId: json["uu_id"] ?? "",
    name: json["name"] ?? "",
    phone: json["phone"] ?? "",
    email: json["email"] ?? "",
    profileImage: json["profile_image"],
    vehicleType: json["vehicle_type"] ?? "",
    vehicleNumber: json["vehicle_number"] ?? "",
    isActive: json["is_active"] ?? false,
    isOnline: json["is_online"] ?? false,
    commissionWallet: json["commission_wallet"] ?? 0,
    transactionWallet: json["transaction_wallet"] ?? 0,
    currentLatitude: json["current_latitude"] != null
        ? (json["current_latitude"] as num).toDouble()
        : null,
    currentLongitude: json["current_longitude"] != null
        ? (json["current_longitude"] as num).toDouble()
        : null,
    avgRating: json["avg_rating"] ?? 0,
    totalReviews: json["total_reviews"] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "uu_id": uuId,
    "name": name,
    "phone": phone,
    "email": email,
    "profile_image": profileImage,
    "vehicle_type": vehicleType,
    "vehicle_number": vehicleNumber,
    "is_active": isActive,
    "is_online": isOnline,
    "commission_wallet": commissionWallet,
    "transaction_wallet": transactionWallet,
    "current_latitude": currentLatitude,
    "current_longitude": currentLongitude,
    "avg_rating": avgRating,
    "total_reviews": totalReviews,
  };
}
