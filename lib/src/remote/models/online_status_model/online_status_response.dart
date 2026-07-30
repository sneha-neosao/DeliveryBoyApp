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

  OnlineStatus({
    required this.isOnline,
  });

  factory OnlineStatus.fromJson(Map<String, dynamic> json) => OnlineStatus(
    isOnline: json["is_online"] ?? false,
  );

  Map<String, dynamic> toJson() => {
    "is_online": isOnline,
  };
}
