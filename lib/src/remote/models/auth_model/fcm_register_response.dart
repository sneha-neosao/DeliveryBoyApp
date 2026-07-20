import 'dart:convert';

class FcmRegisterResponse {
  final int? status;
  final bool? success;
  final dynamic data;
  final String? message;

  FcmRegisterResponse({
    this.status,
    this.success,
    this.data,
    this.message,
  });

  factory FcmRegisterResponse.fromRawJson(String str) =>
      FcmRegisterResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory FcmRegisterResponse.fromJson(Map<String, dynamic> json) =>
      FcmRegisterResponse(
        status: json["status"],
        success: json["success"],
        data: json["data"],
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "success": success,
        "data": data,
        "message": message,
      };
}
