import 'dart:convert';

class ProfileUpdateResponse {
  final int status;
  final String message;
  final ProfileData? data;

  ProfileUpdateResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory ProfileUpdateResponse.fromRawJson(String str) =>
      ProfileUpdateResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ProfileUpdateResponse.fromJson(Map<String, dynamic> json) {
    return ProfileUpdateResponse(
      status: json["status"] ?? 0,
      message: json["message"] ?? "",
      data: json["data"] != null ? ProfileData.fromJson(json["data"]) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data?.toJson(),
  };
}

class ProfileData {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String profileImage;
  final double currentLatitude;
  final double currentLongitude;

  ProfileData({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.profileImage,
    required this.currentLatitude,
    required this.currentLongitude,
  });

  factory ProfileData.fromJson(Map<String, dynamic> json) => ProfileData(
    id: json["id"] ?? 0,
    name: json["name"] ?? "",
    email: json["email"] ?? "",
    phone: json["phone"] ?? "",
    profileImage: json["profile_image"] ?? "",
    currentLatitude: (json["current_latitude"] ?? 0).toDouble(),
    currentLongitude: (json["current_longitude"] ?? 0).toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "email": email,
    "phone": phone,
    "profile_image": profileImage,
    "current_latitude": currentLatitude,
    "current_longitude": currentLongitude,
  };
}
