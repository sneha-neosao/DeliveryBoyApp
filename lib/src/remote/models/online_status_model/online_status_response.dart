import 'dart:convert';

class OnlineStatusResponse {
  final int status;
  final String message;
  final OnlineStatus? data;

  OnlineStatusResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory OnlineStatusResponse.fromRawJson(String str) =>
      OnlineStatusResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory OnlineStatusResponse.fromJson(Map<String, dynamic> json) {
    return OnlineStatusResponse(
      status: json["status"] ?? 0,
      message: json["message"] ?? "",
      data: json["data"] != null ? OnlineStatus.fromJson(json["data"]) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data?.toJson(),
  };
}

class OnlineStatus {
  final bool isOnline;
  final double? currentLatitude;
  final double? currentLongitude;

  OnlineStatus({
    required this.isOnline,
    this.currentLatitude,
    this.currentLongitude,
  });

  factory OnlineStatus.fromJson(Map<String, dynamic> json) => OnlineStatus(
    isOnline: json["is_online"] ?? false,
    currentLatitude: json["current_latitude"] != null
        ? (json["current_latitude"] as num).toDouble()
        : null,
    currentLongitude: json["current_longitude"] != null
        ? (json["current_longitude"] as num).toDouble()
        : null,
  );

  Map<String, dynamic> toJson() => {
    "is_online": isOnline,
    "current_latitude": currentLatitude,
    "current_longitude": currentLongitude,
  };
}
