import 'dart:convert';

class CommonResponse {
  final int status;
  final bool success;
  final dynamic data; // can be null or any type depending on API
  final String message;

  CommonResponse({
    required this.status,
    required this.success,
    this.data,
    required this.message,
  });

  factory CommonResponse.fromRawJson(String str) =>
      CommonResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory CommonResponse.fromJson(Map<String, dynamic> json) {
    return CommonResponse(
      status: json["status"],
      success: json["success"],
      data: json["data"],
      message: json["message"],
    );
  }

  Map<String, dynamic> toJson() => {
    "status": status,
    "success": success,
    "data": data,
    "message": message,
  };
}
