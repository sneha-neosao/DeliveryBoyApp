enum AppRoute {
  splash(path: "/splash_screen"),
  getStarted(path: "/get_started_screen"),
  login(path: "/login_screen"),
  dashboard(path: "/dashboard_screen"),
  orders(path: "/orders_screen"),
  orderDetails(path: "/order_details_screen"),
  delivered(path: "/delivered_screen"),
  cancelled(path: "/cancelled_screen"),
  rejected(path: "/rejected_screen"),
  profile(path: "/profile_screen"),
  bulkOrder(path: "/bulk_order_screen"),
  bulkOrderDetails(path: "/bulk_order_details_screen"),
  map(path: "/map_screen"),
  orderMap(path: "/order_map_screen"),
  bulkOrderMap(path: "/bulk_order_map_screen");

  final String path;

  const AppRoute({required this.path});
}
