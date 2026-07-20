

import '../../configs/injector/injector.dart';

/// Abstract Repository interface defining all data operations for the app

abstract class Repository {
  // Future<Either<Failure, LoginResponse>> login(LoginParams params);
}

class AuthRepositoryImpl implements Repository {
  final RemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  const AuthRepositoryImpl(this._remoteDataSource, this._networkInfo);

  // @override
  // Future<Either<Failure, LoginResponse>> login(LoginParams params) {
  //   return _networkInfo.check<LoginResponse>(
  //     connected: () async {
  //       try {
  //         final respData = await _remoteDataSource.login(params);
  //
  //         if (respData.status != 200) {
  //           return Left(CredentialFailure(respData.message!));
  //         }
  //
  //         // Save full session object
  //         await SessionManager.saveUserSession(respData);
  //
  //         // Save tokens to their dedicated keys so ApiInterceptor can read them
  //         if (respData.accessToken != null) {
  //           await SessionManager.saveSessionId(respData.accessToken!);
  //         }
  //         if (respData.refreshToken != null) {
  //           await SessionManager.saveRefreshToken(respData.refreshToken!);
  //         }
  //
  //         // Save credentials for auto-fill on next login
  //         await SessionManager.saveCredentials(params.phone, params.password);
  //
  //         // Retrieve later
  //         final savedSession = await SessionManager.getUserSession();
  //         if (savedSession != null) {
  //           print(savedSession.technician?.name);
  //           print(savedSession.dealer?.name);
  //         }
  //
  //         return Right(respData);
  //       } on ServerException {
  //         return Left(ServerFailure(mapFailureToMessage(ServerFailure(""))));
  //       } catch (e) {
  //         if (e is ApiException) {
  //           return Left(ApiFailure(e.message)); // rethrow as-is
  //         }
  //         return Left(ServerFailure(mapFailureToMessage(ServerFailure(""))));
  //       }
  //     },
  //     notConnected: () async {
  //       try {
  //         return Left(InternetFailure(mapFailureToMessage(InternetFailure(""))));
  //       } on CacheException {
  //         return Left(CacheFailure(mapFailureToMessage(CacheFailure(""))));
  //       }
  //     },
  //   );
  // }

}
