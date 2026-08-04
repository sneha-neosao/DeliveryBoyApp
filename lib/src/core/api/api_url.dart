class ApiUrl {
  const ApiUrl._();

  static const baseUrl = "http://192.168.1.28:8001/api/v1/delivery_boy"; // TEST
  // static const baseUrl = "https://web.neosao.co.in/api/v1/delivery_boy"; // LIVE

  static const login = "/auth/login";

  static const logout = "/auth/logout";

  static const firebaseTokenUpdate = "/profile/update-firebase-token";

  static const orderList = "/orders/list";

  static const orderDetails = "/orders/detail";

  static const orderAssignment = "/orders/accept-reject";

  static const orderStatusUpdate = "/orders/update-status";

  static const profile = "/profile/details";

  static const onlineStatus = "/auth/toggle-online";

  static const dashboard = "/dashboard/";

  static const passwordUpdate = "/profile/update-password";

  static const profileUpdate = "/profile/update";

  static const profileImageUpdate = "/profile/update-image";

}

