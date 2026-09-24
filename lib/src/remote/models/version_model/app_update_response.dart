import 'dart:convert';

class AppUpdateResponse {
  final int status;
  final String message;
  final DeliveryAppData? data;

  AppUpdateResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory AppUpdateResponse.fromRawJson(String str) =>
      AppUpdateResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory AppUpdateResponse.fromJson(Map<String, dynamic> json) {
    return AppUpdateResponse(
      status: json["status"] ?? 0,
      message: json["message"] ?? "",
      data: json["data"] != null ? DeliveryAppData.fromJson(json["data"]) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data?.toJson(),
  };
}

class DeliveryAppData {
  final AppVersion deliveryAndroidAppVersion;
  final AppVersion deliveryIosAppVersion;

  DeliveryAppData({
    required this.deliveryAndroidAppVersion,
    required this.deliveryIosAppVersion,
  });

  factory DeliveryAppData.fromJson(Map<String, dynamic> json) => DeliveryAppData(
    deliveryAndroidAppVersion:
    AppVersion.fromJson(json["delivery_android_app_version"] ?? {}),
    deliveryIosAppVersion:
    AppVersion.fromJson(json["delivery_ios_app_version"] ?? {}),
  );

  Map<String, dynamic> toJson() => {
    "delivery_android_app_version": deliveryAndroidAppVersion.toJson(),
    "delivery_ios_app_version": deliveryIosAppVersion.toJson(),
  };
}

class AppVersion {
  final String version;
  final bool forceUpdate;
  final String updateMessage;
  final String storeLink;

  AppVersion({
    required this.version,
    required this.forceUpdate,
    required this.updateMessage,
    required this.storeLink,
  });

  factory AppVersion.fromJson(Map<String, dynamic> json) => AppVersion(
    version: (json["version"] ?? "").toString().trim(),
    forceUpdate: _parseBool(json["force_update"]),
    updateMessage: (json["update_message"] ?? "").toString(),
    storeLink: (json["store_link"] ?? "").toString().trim(),
  );

  static bool _parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is num) return value == 1;
    if (value is String) {
      final v = value.toLowerCase().trim();
      return v == 'true' || v == '1';
    }
    return false;
  }

  Map<String, dynamic> toJson() => {
    "version": version,
    "force_update": forceUpdate,
    "update_message": updateMessage,
    "store_link": storeLink,
  };
}
