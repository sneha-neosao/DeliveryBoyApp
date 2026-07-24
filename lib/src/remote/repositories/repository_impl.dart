import 'package:delivery_boy_app/src/core/api/api_exception.dart';
import 'package:delivery_boy_app/src/core/errors/exceptions.dart';
import 'package:delivery_boy_app/src/core/errors/failures.dart';
import 'package:delivery_boy_app/src/core/session/session_manager.dart';
import 'package:delivery_boy_app/src/core/usecases/usecase.dart';
import 'package:delivery_boy_app/src/core/utils/failure_converter.dart';
import 'package:delivery_boy_app/src/features/login/domain/login_usecase.dart';
import 'package:delivery_boy_app/src/remote/models/auth_model/Login_response.dart';
import 'package:delivery_boy_app/src/remote/models/common_response.dart';
import 'package:fpdart/fpdart.dart';

import '../../configs/injector/injector.dart';

/// Abstract Repository interface defining all data operations for the app

abstract class Repository {

  /// Authentication
  Future<Either<Failure, LoginResponse>> login(LoginParams params);

  Future<Either<Failure, CommonResponse>> logout(NoParams params);

}

class AuthRepositoryImpl implements Repository {
  final RemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  const AuthRepositoryImpl(this._remoteDataSource, this._networkInfo);

  @override
  Future<Either<Failure, LoginResponse>> login(LoginParams params) {
    return _networkInfo.check<LoginResponse>(
      connected: () async {
        try {
          final respData = await _remoteDataSource.login(params);

          if (respData.status != 200) {
            return Left(CredentialFailure(respData.message!));
          }

          // Save login status & full session object
          await SessionManager.saveLoginStatus(true);
          await SessionManager.saveUserSession(respData);

          // Save tokens to their dedicated keys so ApiInterceptor can read them
          if (respData.data?.accessToken != null) {
            await SessionManager.saveSessionId(respData.data?.accessToken);
          }
          if (respData.data?.refreshToken != null) {
            await SessionManager.saveRefreshToken(respData.data?.refreshToken);
          }

          return Right(respData);
        } on ServerException {
          return Left(ServerFailure(mapFailureToMessage(ServerFailure(""))));
        } catch (e) {
          if (e is ApiException) {
            return Left(ApiFailure(e.message)); // rethrow as-is
          }
          return Left(ServerFailure(mapFailureToMessage(ServerFailure(""))));
        }
      },
      notConnected: () async {
        try {
          return Left(InternetFailure(mapFailureToMessage(InternetFailure(""))));
        } on CacheException {
          return Left(CacheFailure(mapFailureToMessage(CacheFailure(""))));
        }
      },
    );
  }

  @override
  Future<Either<Failure, CommonResponse>> logout(NoParams params) {
    return _networkInfo.check<CommonResponse>(
      connected: () async {
        try {
          String token = await SessionManager.getAuthToken() ?? "";
          String refreshToken = await SessionManager.getRefreshToken() ?? "";

          final respData = await _remoteDataSource.logout(token, refreshToken);

          if (respData.status != 200) {
            return Left(CredentialFailure(respData.message!));
          }

          // Save full session object
          // await SessionManager.saveUserSession(respData);
          //
          // // Save tokens to their dedicated keys so ApiInterceptor can read them
          // if (respData.data?.accessToken != null) {
          //   await SessionManager.saveSessionId(respData.data?.accessToken);
          // }
          // if (respData.data?.refreshToken != null) {
          //   await SessionManager.saveRefreshToken(respData.data?.accessToken);
          // }

          return Right(respData);
        } on ServerException {
          return Left(ServerFailure(mapFailureToMessage(ServerFailure(""))));
        } catch (e) {
          if (e is ApiException) {
            return Left(ApiFailure(e.message)); // rethrow as-is
          }
          return Left(ServerFailure(mapFailureToMessage(ServerFailure(""))));
        }
      },
      notConnected: () async {
        try {
          return Left(InternetFailure(mapFailureToMessage(InternetFailure(""))));
        } on CacheException {
          return Left(CacheFailure(mapFailureToMessage(CacheFailure(""))));
        }
      },
    );
  }
}
