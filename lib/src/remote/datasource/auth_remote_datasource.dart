import 'package:delivery_boy_app/src/core/api/api_exception.dart';
import 'package:delivery_boy_app/src/core/api/api_url.dart';
import 'package:delivery_boy_app/src/core/constants/error_message.dart';
import 'package:delivery_boy_app/src/core/errors/exceptions.dart';
import 'package:delivery_boy_app/src/features/login/domain/login_usecase.dart';
import 'package:delivery_boy_app/src/remote/models/auth_model/Login_response.dart';

import '../../configs/injector/injector.dart';
import '../../core/utils/logger.dart';
sealed class RemoteDataSource {
  Future<LoginResponse> login(LoginParams params);
}

class RemoteDataSourceImpl implements RemoteDataSource {
  final ApiHelper _helper;

  /// Helper for normal API requests
  // final ApiHelper _superAdminHelper; /// Helper for super-admin or special API requests

  const RemoteDataSourceImpl(this._helper /* this._superAdminHelper*/);

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
      // throw here i want to pass same exception which is send by catch();
    }
  }

}
