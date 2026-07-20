import 'dart:convert';

class AppSettingsResponse {
  final int? status;
  final bool? success;
  final Data? data;
  final String? message;

  AppSettingsResponse({
    this.status,
    this.success,
    this.data,
    this.message,
  });

  factory AppSettingsResponse.fromRawJson(String str) =>
      AppSettingsResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory AppSettingsResponse.fromJson(Map<String, dynamic> json) =>
      AppSettingsResponse(
        status: json["status"],
        success: json["success"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "success": success,
        "data": data?.toJson(),
        "message": message,
      };
}

class Data {
  final AndroidApp? androidApp;
  final IosApp? iosApp;

  Data({
    this.androidApp,
    this.iosApp,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        androidApp: json["android_app"] == null
            ? null
            : AndroidApp.fromJson(json["android_app"]),
        iosApp:
            json["ios_app"] == null ? null : IosApp.fromJson(json["ios_app"]),
      );

  Map<String, dynamic> toJson() => {
        "android_app": androidApp?.toJson(),
        "ios_app": iosApp?.toJson(),
      };
}

class AndroidApp {
  final String? version;
  final bool? forceUpdate;
  final String? updateMessage;
  final String? playStoreLink;

  AndroidApp({
    this.version,
    this.forceUpdate,
    this.updateMessage,
    this.playStoreLink,
  });

  factory AndroidApp.fromJson(Map<String, dynamic> json) => AndroidApp(
        version: json["version"],
        forceUpdate: json["force_update"],
        updateMessage: json["update_message"],
        playStoreLink: json["play_store_link"],
      );

  Map<String, dynamic> toJson() => {
        "version": version,
        "force_update": forceUpdate,
        "update_message": updateMessage,
        "play_store_link": playStoreLink,
      };
}

class IosApp {
  final String? version;
  final bool? forceUpdate;
  final String? appStoreLink;
  final String? updateMessage;

  IosApp({
    this.version,
    this.forceUpdate,
    this.appStoreLink,
    this.updateMessage,
  });

  factory IosApp.fromJson(Map<String, dynamic> json) => IosApp(
        version: json["version"],
        forceUpdate: json["force_update"],
        appStoreLink: json["app_store_link"],
        updateMessage: json["update_message"],
      );

  Map<String, dynamic> toJson() => {
        "version": version,
        "force_update": forceUpdate,
        "app_store_link": appStoreLink,
        "update_message": updateMessage,
      };
}
