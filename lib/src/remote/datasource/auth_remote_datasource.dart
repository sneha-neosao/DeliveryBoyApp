import 'package:delivery_boy_app/src/core/api/api_exception.dart';
import 'package:delivery_boy_app/src/core/api/api_url.dart';
import 'package:delivery_boy_app/src/core/constants/error_message.dart';
import 'package:delivery_boy_app/src/core/errors/exceptions.dart';
import 'package:delivery_boy_app/src/features/dashboard/domain/usecase/firebase_token_update_usecase.dart';
import 'package:delivery_boy_app/src/features/dashboard/domain/usecase/online_status_usecase.dart';
import 'package:delivery_boy_app/src/features/login/domain/login_usecase.dart';
import 'package:delivery_boy_app/src/features/bulk_orders/domain/usecase/current_assignment_order_list_usecase.dart';
import 'package:delivery_boy_app/src/features/orders/domain/usecase/order_assignment_usecase.dart';
import 'package:delivery_boy_app/src/features/orders/domain/usecase/order_details_usecase.dart';
import 'package:delivery_boy_app/src/features/orders/domain/usecase/order_list_usecase.dart';
import 'package:delivery_boy_app/src/features/orders/domain/usecase/order_start_assignment_usecase.dart';
import 'package:delivery_boy_app/src/features/orders/domain/usecase/order_status_update_usecase.dart';
import 'package:delivery_boy_app/src/features/profile/domain/usecase/password_update_usecase.dart';
import 'package:delivery_boy_app/src/features/profile/domain/usecase/profile_image_update_usecase.dart';
import 'package:delivery_boy_app/src/features/profile/domain/usecase/profile_update_usecase.dart';
import 'package:delivery_boy_app/src/remote/models/auth_model/Login_response.dart';
import 'package:delivery_boy_app/src/remote/models/auth_model/firebase_token_update_response.dart';
import 'package:delivery_boy_app/src/remote/models/common_response.dart';
import 'package:delivery_boy_app/src/remote/models/dashboard_model/dashboard_response.dart';
import 'package:delivery_boy_app/src/remote/models/online_status_model/online_status_response.dart';
import 'package:delivery_boy_app/src/remote/models/order_model/food_order_model/current_food_assignment_response.dart';
import 'package:delivery_boy_app/src/remote/models/order_model/vegetable_grocery_order_models/current_assignment_order_list_response.dart';
import 'package:delivery_boy_app/src/remote/models/order_model/vegetable_grocery_order_models/order_assignment_response.dart';
import 'package:delivery_boy_app/src/remote/models/order_model/vegetable_grocery_order_models/order_current_assignment_reponse.dart';
import 'package:delivery_boy_app/src/remote/models/order_model/order_details_response.dart';
import 'package:delivery_boy_app/src/remote/models/order_model/food_order_model/order_list_response.dart';
import 'package:delivery_boy_app/src/remote/models/order_model/vegetable_grocery_order_models/order_start_assignment_response.dart';
import 'package:delivery_boy_app/src/remote/models/order_model/vegetable_grocery_order_models/order_status_update_response.dart';
import 'package:delivery_boy_app/src/remote/models/profile_model/profile_image_update_response.dart';
import 'package:delivery_boy_app/src/remote/models/profile_model/profile_response.dart';
import 'package:delivery_boy_app/src/remote/models/profile_model/profile_update_response.dart';
import 'package:delivery_boy_app/src/remote/models/version_model/app_update_response.dart';
import 'package:dio/dio.dart';

import '../../configs/injector/injector.dart';
import '../../core/utils/logger.dart';

sealed class RemoteDataSource {
  /// Authentication
  Future<LoginResponse> login(LoginParams params);

  Future<CommonResponse> logout(String token, String refreshToken);

  Future<FirebaseTokenUpdateResponse> firebase_token_update(FirebaseTokenUpdateParams params, String token);

  /// Orders
  Future<OrdersListResponse> order_list(OrderListParams params, String token);

  Future<OrderDetailsResponse> order_details(OrderDetailsParams params, String token);

  Future<OrderAssignmentResponse> order_assignment(OrderAssignmentParams params, String token);

  Future<OrderStatusUpdateResponse> order_status_update(OrderStatusUpdateParams params, String token);

  Future<OrderCurrentAssignmentResponse> order_current_assignment(String token);

  Future<OrderStartAssignmentResponse> order_start_assignment(OrderStartAssignmentParams params, String token);

  Future<CurrentAssignmentOrderListResponse> current_assignment_orders(CurrentAssignmentOrderListParams params, String token);

  Future<CurrentFoodAssignmentResponse> food_order_current_assignment(String token);

  /// Profile
  Future<ProfileResponse> profile(String token);

  /// Online Status
  Future<OnlineStatusResponse> online_status(OnlineStatusParams params, String token);

  /// Dashboard
  Future<DashboardStatsResponse> dashboard(String token);

  ///Password Update
  Future<CommonResponse> password_update(PasswordUpdateParams params, String token);

  ///Profile Update
  Future<ProfileUpdateResponse> profile_update(ProfileUpdateParams params, String token);

  Future<ProfileImageUpdateResponse> profile_image_update(ProfileImageUpdateParams params, String token);

  /// Delete Account
  Future<CommonResponse> delete_account(String token);

  /// App Update
  Future<AppUpdateResponse> app_update(String token);
}

class RemoteDataSourceImpl implements RemoteDataSource {
  final ApiHelper _helper;

  /// Helper for normal API requests
  // final ApiHelper _superAdminHelper; /// Helper for super-admin or special API requests

  RemoteDataSourceImpl(this._helper);

  @override
  Future<LoginResponse> login(LoginParams params) async {
    try {
      var data = {"email": params.email, "password": params.password};

      final response = await _helper.execute(
        method: Method.post,
        url: ApiUrl.login,
        data: data,
      );

      final respData = LoginResponse.fromJson(response);
      return respData;
    } on EmptyException {
      throw AuthException();
    } catch (e) {
      logger.e(e);
      if (e.toString() == noElement) {
        throw AuthException();
      }
      if (e is ApiException) {
        throw e; // rethrow as-is
      }
      throw ServerException();
    }
  }

  @override
  Future<CommonResponse> logout(String token, String refreshToken) async {
    try {
      final response = await _helper.execute(
        method: Method.post,
        url: ApiUrl.logout,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'refresh-token': refreshToken,
          },
        ),
      );

      final respData = CommonResponse.fromJson(response);
      return respData;
    } on EmptyException {
      throw AuthException();
    } catch (e) {
      logger.e(e);
      if (e.toString() == noElement) {
        throw AuthException();
      }
      if (e is ApiException) {
        throw e; // rethrow as-is
      }
      throw ServerException();
    }
  }

  @override
  Future<FirebaseTokenUpdateResponse> firebase_token_update(FirebaseTokenUpdateParams params,String token) async {
    try {

      var data = {"firebase_token": params.firebase_id};

      final response = await _helper.execute(
        method: Method.put,
        url: "${ApiUrl.firebaseTokenUpdate}?firebase_token=${Uri.encodeQueryComponent(params.firebase_id)}",
        data: data,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          headers: {
            'Authorization': 'Bearer $token',
            'accept': 'application/json',
          },
        ),
      );

      final respData = FirebaseTokenUpdateResponse.fromJson(response);
      return respData;
    } on EmptyException {
      throw AuthException();
    } catch (e) {
      logger.e(e);
      if (e.toString() == noElement) {
        throw AuthException();
      }
      if (e is ApiException) {
        throw e; // rethrow as-is
      }
      throw ServerException();
    }
  }

  @override
  Future<OrdersListResponse> order_list(OrderListParams params,String token) async {
    try {
      final response = await _helper.execute(
        method: Method.get,
        url: ApiUrl.orderList,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      final respData = OrdersListResponse.fromJson(response);
      return respData;
    } on EmptyException {
      throw AuthException();
    } catch (e) {
      logger.e(e);
      if (e.toString() == noElement) {
        throw AuthException();
      }
      if (e is ApiException) {
        throw e; // rethrow as-is
      }
      throw ServerException();
    }
  }

  @override
  Future<OrderDetailsResponse> order_details(OrderDetailsParams params,String token) async {
    try {
      final response = await _helper.execute(
        method: Method.get,
        url: "${ApiUrl.orderDetails}?uu_id=${params.uu_id}",
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      final respData = OrderDetailsResponse.fromJson(response);
      return respData;
    } on EmptyException {
      throw AuthException();
    } catch (e) {
      logger.e(e);
      if (e.toString() == noElement) {
        throw AuthException();
      }
      if (e is ApiException) {
        throw e; // rethrow as-is
      }
      throw ServerException();
    }
  }

  @override
  Future<OrderAssignmentResponse> order_assignment(OrderAssignmentParams params,String token) async {
    try {

      var data = {"order_uu_id": params.uu_id, "action": params.action, "note": params.note};

      final response = await _helper.execute(
        method: Method.post,
        url: ApiUrl.orderAssignment,
        data: data,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      final respData = OrderAssignmentResponse.fromJson(response);
      return respData;
    } on EmptyException {
      throw AuthException();
    } catch (e) {
      logger.e(e);
      if (e.toString() == noElement) {
        throw AuthException();
      }
      if (e is ApiException) {
        throw e; // rethrow as-is
      }
      throw ServerException();
    }
  }

  @override
  Future<OrderStatusUpdateResponse> order_status_update(OrderStatusUpdateParams params,String token) async {
    try {

      var data = {"order_status": params.status, "note": params.note};

      final response = await _helper.execute(
        method: Method.put,
        url: '${ApiUrl.orderStatusUpdate}?uu_id=${params.uu_id}',
        data: data,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      final respData = OrderStatusUpdateResponse.fromJson(response);
      return respData;
    } on EmptyException {
      throw AuthException();
    } catch (e) {
      logger.e(e);
      if (e.toString() == noElement) {
        throw AuthException();
      }
      if (e is ApiException) {
        throw e; // rethrow as-is
      }
      throw ServerException();
    }
  }

  @override
  Future<OrderCurrentAssignmentResponse> order_current_assignment(String token) async {
    try {

      final response = await _helper.execute(
        method: Method.get,
        url: ApiUrl.orderCurrentAssignment,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      final respData = OrderCurrentAssignmentResponse.fromJson(response);
      return respData;
    } on EmptyException {
      throw AuthException();
    } catch (e) {
      logger.e(e);
      if (e.toString() == noElement) {
        throw AuthException();
      }
      if (e is ApiException) {
        throw e; // rethrow as-is
      }
      throw ServerException();
    }
  }

  @override
  Future<OrderStartAssignmentResponse> order_start_assignment(OrderStartAssignmentParams params,String token) async {
    try {
      final response = await _helper.execute(
        method: Method.post,
        url: "${ApiUrl.orderStartAssignment}?uuid=${params.uu_id}&status=${params.status}",
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      final respData = OrderStartAssignmentResponse.fromJson(response);
      return respData;
    } on EmptyException {
      throw AuthException();
    } catch (e) {
      logger.e(e);
      if (e.toString() == noElement) {
        throw AuthException();
      }
      if (e is ApiException) {
        throw e; // rethrow as-is
      }
      throw ServerException();
    }
  }

  @override
  Future<CurrentAssignmentOrderListResponse> current_assignment_orders(CurrentAssignmentOrderListParams params,String token) async {
    try {
      final response = await _helper.execute(
        method: Method.get,
        url: "${ApiUrl.currentAssignmentOrders}?uuid=${params.uuid}&page=${params.page}&limit=${params.limit}",
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      final respData = CurrentAssignmentOrderListResponse.fromJson(response);
      return respData;
    } on EmptyException {
      throw AuthException();
    } catch (e) {
      logger.e(e);
      if (e.toString() == noElement) {
        throw AuthException();
      }
      if (e is ApiException) {
        throw e; // rethrow as-is
      }
      throw ServerException();
    }
  }

  @override
  Future<CurrentFoodAssignmentResponse> food_order_current_assignment(String token) async {
    try {

      final response = await _helper.execute(
        method: Method.get,
        url: ApiUrl.foodCurrentAssignment,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      final respData = CurrentFoodAssignmentResponse.fromJson(response);
      return respData;
    } on EmptyException {
      throw AuthException();
    } catch (e) {
      logger.e(e);
      if (e.toString() == noElement) {
        throw AuthException();
      }
      if (e is ApiException) {
        throw e; // rethrow as-is
      }
      throw ServerException();
    }
  }

  @override
  Future<ProfileResponse> profile(String token) async {
    try {
      final response = await _helper.execute(
        method: Method.get,
        url: ApiUrl.profile,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      final respData = ProfileResponse.fromJson(response);
      return respData;
    } on EmptyException {
      throw AuthException();
    } catch (e) {
      logger.e(e);
      if (e.toString() == noElement) {
        throw AuthException();
      }
      if (e is ApiException) {
        throw e; // rethrow as-is
      }
      throw ServerException();
    }
  }

  @override
  Future<OnlineStatusResponse> online_status(OnlineStatusParams params, String token) async {
    try {

      var data = {"is_online": params.is_online};

      final response = await _helper.execute(
        method: Method.put,
        url: ApiUrl.onlineStatus,
        data: data,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      final respData = OnlineStatusResponse.fromJson(response);
      return respData;
    } on EmptyException {
      throw AuthException();
    } catch (e) {
      logger.e(e);
      if (e.toString() == noElement) {
        throw AuthException();
      }
      if (e is ApiException) {
        throw e; // rethrow as-is
      }
      throw ServerException();
    }
  }

  @override
  Future<DashboardStatsResponse> dashboard(String token) async {
    try {
      final response = await _helper.execute(
        method: Method.get,
        url: ApiUrl.dashboard,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      final respData = DashboardStatsResponse.fromJson(response);
      return respData;
    } on EmptyException {
      throw AuthException();
    } catch (e) {
      logger.e(e);
      if (e.toString() == noElement) {
        throw AuthException();
      }
      if (e is ApiException) {
        throw e; // rethrow as-is
      }
      throw ServerException();
    }
  }

  @override
  Future<CommonResponse> password_update(PasswordUpdateParams params,String token) async {
    try {

      var data = {
        "old_password": params.old_password,
        "new_password": params.new_password,
        "confirm_password": params.confirm_password
      };

      final response = await _helper.execute(
        method: Method.put,
        url: ApiUrl.passwordUpdate,
        data: data,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          headers: {
            'Authorization': 'Bearer $token',
            'accept': 'application/json',
          },
        ),
      );

      final respData = CommonResponse.fromJson(response);
      return respData;
    } on EmptyException {
      throw AuthException();
    } catch (e) {
      logger.e(e);
      if (e.toString() == noElement) {
        throw AuthException();
      }
      if (e is ApiException) {
        throw e; // rethrow as-is
      }
      throw ServerException();
    }
  }

  @override
  Future<ProfileUpdateResponse> profile_update(ProfileUpdateParams params,String token) async {
    try {

      var data = {
        "name": params.name,
        "phone": params.mobile_number
      };

      final response = await _helper.execute(
        method: Method.put,
        url: ApiUrl.profileUpdate,
        data: data,
        options: Options(
          // contentType: Headers.formUrlEncodedContentType,
          headers: {
            'Authorization': 'Bearer $token',
            'accept': 'application/json',
          },
        ),
      );

      final respData = ProfileUpdateResponse.fromJson(response);
      return respData;
    } on EmptyException {
      throw AuthException();
    } catch (e) {
      logger.e(e);
      if (e.toString() == noElement) {
        throw AuthException();
      }
      if (e is ApiException) {
        throw e; // rethrow as-is
      }
      throw ServerException();
    }
  }

  @override
  Future<ProfileImageUpdateResponse> profile_image_update(ProfileImageUpdateParams params,String token) async {
    try {

      FormData formData = FormData.fromMap({
        "profile_image": await MultipartFile.fromFile(
          params.profile_image,
          filename: "image.png", // or use basename(params.member_photo)
        ),
      });

      final response = await _helper.execute(
        method: Method.put,
        url: ApiUrl.profileImageUpdate,
        data: formData,
        options: Options(
          contentType: Headers.multipartFormDataContentType,
          headers: {
            'Authorization': 'Bearer $token',
            'accept': 'application/json',
          },
        ),
      );

      final respData = ProfileImageUpdateResponse.fromJson(response);
      return respData;
    } on EmptyException {
      throw AuthException();
    } catch (e) {
      logger.e(e);
      if (e.toString() == noElement) {
        throw AuthException();
      }
      if (e is ApiException) {
        throw e; // rethrow as-is
      }
      throw ServerException();
    }
  }

  @override
  Future<CommonResponse> delete_account(String token) async {
    try {
      final response = await _helper.execute(
        method: Method.delete,
        url: ApiUrl.deleteAccount,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      final respData = CommonResponse.fromJson(response);
      return respData;
    } on EmptyException {
      throw AuthException();
    } catch (e) {
      logger.e(e);
      if (e.toString() == noElement) {
        throw AuthException();
      }
      if (e is ApiException) {
        throw e; // rethrow as-is
      }
      throw ServerException();
    }
  }


  @override
  Future<AppUpdateResponse> app_update(String token) async {
    try {
      final response = await _helper.execute(
        method: Method.get,
        url: ApiUrl.appUpdate,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      final respData = AppUpdateResponse.fromJson(response);
      return respData;
    } on EmptyException {
      throw AuthException();
    } catch (e) {
      logger.e(e);
      if (e.toString() == noElement) {
        throw AuthException();
      }
      if (e is ApiException) {
        throw e; // rethrow as-is
      }
      throw ServerException();
    }
  }
}
