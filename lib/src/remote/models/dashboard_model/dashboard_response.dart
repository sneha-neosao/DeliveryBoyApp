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
  final num todaysAllOrderTotal;
  final num todaysCashOrderTotal;
  final num todaysOnlineOrderTotal;

  DashboardStatsData({
    required this.pendingOrdersCount,
    required this.completedOrdersCount,
    required this.failedOrdersCount,
    required this.totalEarning,
    required this.todaysEarning,
    required this.avgRating,
    this.todaysAllOrderTotal = 0,
    this.todaysCashOrderTotal = 0,
    this.todaysOnlineOrderTotal = 0,
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
        todaysAllOrderTotal: json["todays_all_order_total"] ?? 0,
        todaysCashOrderTotal: json["todays_cash_order_total"] ?? 0,
        todaysOnlineOrderTotal: json["todays_online_order_total"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
    "pending_orders_count": pendingOrdersCount,
    "completed_orders_count": completedOrdersCount,
    "failed_orders_count": failedOrdersCount,
    "total_earning": totalEarning,
    "todays_earning": todaysEarning,
    "avg_rating": avgRating,
    "todays_all_order_total": todaysAllOrderTotal,
    "todays_cash_order_total": todaysCashOrderTotal,
    "todays_online_order_total": todaysOnlineOrderTotal,
  };
}
