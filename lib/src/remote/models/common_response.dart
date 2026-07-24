import 'dart:convert';

class CommonResponse {
  final int status;
  final String message;
  final dynamic data; // can be null or any type depending on API

  CommonResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory CommonResponse.fromRawJson(String str) =>
      CommonResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory CommonResponse.fromJson(Map<String, dynamic> json) {
    return CommonResponse(
      status: json["status"],
      message: json["message"],
      data: json["data"],
    );
  }

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data,
  };
}
