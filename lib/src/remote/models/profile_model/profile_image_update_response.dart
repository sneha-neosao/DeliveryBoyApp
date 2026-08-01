import 'dart:convert';

class ProfileImageUpdateResponse {
  final int status;
  final String message;
  final ProfileImageData? data;

  ProfileImageUpdateResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory ProfileImageUpdateResponse.fromRawJson(String str) =>
      ProfileImageUpdateResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ProfileImageUpdateResponse.fromJson(Map<String, dynamic> json) {
    return ProfileImageUpdateResponse(
      status: json["status"] ?? 0,
      message: json["message"] ?? "",
      data: json["data"] != null
          ? ProfileImageData.fromJson(json["data"])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data?.toJson(),
  };
}

class ProfileImageData {
  final String profileImageUrl;

  ProfileImageData({
    required this.profileImageUrl,
  });

  factory ProfileImageData.fromJson(Map<String, dynamic> json) =>
      ProfileImageData(
        profileImageUrl: json["profile_image_url"] ?? "",
      );

  Map<String, dynamic> toJson() => {
    "profile_image_url": profileImageUrl,
  };
}
