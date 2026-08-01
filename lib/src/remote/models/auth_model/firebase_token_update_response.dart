import 'dart:convert';

class FirebaseTokenUpdateResponse {
  final int status;
  final String message;
  final FirebaseTokenData? data;

  FirebaseTokenUpdateResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory FirebaseTokenUpdateResponse.fromRawJson(String str) =>
      FirebaseTokenUpdateResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory FirebaseTokenUpdateResponse.fromJson(Map<String, dynamic> json) {
    return FirebaseTokenUpdateResponse(
      status: json["status"] ?? 0,
      message: json["message"] ?? "",
      data: json["data"] != null
          ? FirebaseTokenData.fromJson(json["data"])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data?.toJson(),
  };
}

class FirebaseTokenData {
  final int id;
  final String firebaseToken;

  FirebaseTokenData({
    required this.id,
    required this.firebaseToken,
  });

  factory FirebaseTokenData.fromJson(Map<String, dynamic> json) =>
      FirebaseTokenData(
        id: json["id"] ?? 0,
        firebaseToken: json["firebase_token"] ?? "",
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "firebase_token": firebaseToken,
  };
}
