import 'package:delivery_boy_app/src/core/api/api_exception.dart';
import 'package:delivery_boy_app/src/core/api/api_url.dart';
import 'package:delivery_boy_app/src/core/constants/error_message.dart';
import 'package:delivery_boy_app/src/core/errors/exceptions.dart';
import 'package:delivery_boy_app/src/features/login/domain/login_usecase.dart';
import 'package:delivery_boy_app/src/features/orders/domain/usecase/order_details_usecase.dart';
import 'package:delivery_boy_app/src/features/orders/domain/usecase/order_list_usecase.dart';
import 'package:delivery_boy_app/src/remote/models/auth_model/Login_response.dart';
import 'package:delivery_boy_app/src/remote/models/common_response.dart';
import 'package:delivery_boy_app/src/remote/models/order_model/order_details_response.dart';
import 'package:delivery_boy_app/src/remote/models/order_model/order_list_response.dart';
import 'package:delivery_boy_app/src/remote/models/profile_model/profile_response.dart';
import 'package:dio/dio.dart';

import '../../configs/injector/injector.dart';
import '../../core/utils/logger.dart';

sealed class RemoteDataSource {
  /// Authentication
  Future<LoginResponse> login(LoginParams params);

  Future<CommonResponse> logout(String token, String refreshToken);

  /// Orders
  Future<OrdersListResponse> order_list(OrderListParams params, String token);

  Future<OrderDetailsResponse> order_details(OrderDetailsParams params, String token);

  /// Profile
  Future<ProfileResponse> profile(String token);

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
        url: ApiUrl.orderDetails,
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
}
