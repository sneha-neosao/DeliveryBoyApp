import 'dart:convert';

class DashboardStatsResponse {
  final int status;
  final String message;
  final DashboardStatsData? data;

  DashboardStatsResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory DashboardStatsResponse.fromRawJson(String str) =>
      DashboardStatsResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory DashboardStatsResponse.fromJson(Map<String, dynamic> json) =>
      DashboardStatsResponse(
        status: json["status"] ?? 0,
        message: json["message"] ?? "",
        data: json["data"] != null
            ? DashboardStatsData.fromJson(json["data"])
            : null,
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data?.toJson(),
  };
}

class DashboardStatsData {
  final int pendingOrdersCount;
  final int completedOrdersCount;
  final int failedOrdersCount;
  final num totalEarning;
  final num todaysEarning;
  final double avgRating;

  DashboardStatsData({
    required this.pendingOrdersCount,
    required this.completedOrdersCount,
    required this.failedOrdersCount,
    required this.totalEarning,
    required this.todaysEarning,
    required this.avgRating,
  });

  factory DashboardStatsData.fromJson(Map<String, dynamic> json) =>
      DashboardStatsData(
        pendingOrdersCount: json["pending_orders_count"] ?? 0,
        completedOrdersCount: json["completed_orders_count"] ?? 0,
        failedOrdersCount: json["failed_orders_count"] ?? 0,
        totalEarning: json["total_earning"] ?? 0,
        todaysEarning: json["todays_earning"] ?? 0,
        avgRating: json["avg_rating"] != null
            ? (json["avg_rating"] as num).toDouble()
            : 0.0,
      );

  Map<String, dynamic> toJson() => {
    "pending_orders_count": pendingOrdersCount,
    "completed_orders_count": completedOrdersCount,
    "failed_orders_count": failedOrdersCount,
    "total_earning": totalEarning,
    "todays_earning": todaysEarning,
    "avg_rating": avgRating,
  };
}
