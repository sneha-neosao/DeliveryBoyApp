enum AppRoute {
  splash(path: "/splash_screen"),
  getStarted(path: "/get_started_screen"),
  login(path: "/login_screen"),
  orders(path: "/orders_screen"),
  delivered(path: "/delivered_screen"),
  cancelled(path: "/cancelled_screen"),
  rejected(path: "/rejected_screen"),
  profile(path: "/profile_screen");

  final String path;

  const AppRoute({required this.path});
}
