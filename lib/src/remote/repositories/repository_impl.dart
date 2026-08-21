import 'package:delivery_boy_app/src/core/api/api_exception.dart';
import 'package:delivery_boy_app/src/core/errors/exceptions.dart';
import 'package:delivery_boy_app/src/core/errors/failures.dart';
import 'package:delivery_boy_app/src/core/services/socket_connect_service.dart';
import 'package:delivery_boy_app/src/core/session/session_manager.dart';
import 'package:delivery_boy_app/src/core/usecases/usecase.dart';
import 'package:delivery_boy_app/src/core/utils/failure_converter.dart';
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
import 'package:fpdart/fpdart.dart';

import 'package:delivery_boy_app/src/configs/injector/injector_conf.dart';
import '../../configs/injector/injector.dart';

/// Abstract Repository interface defining all data operations for the app

abstract class Repository {

  /// Authentication
  Future<Either<Failure, LoginResponse>> login(LoginParams params);

  Future<Either<Failure, CommonResponse>> logout(NoParams params);

  Future<Either<Failure, FirebaseTokenUpdateResponse>> firebaseTokenUpdate(FirebaseTokenUpdateParams params);

  /// Orders
  Future<Either<Failure, OrdersListResponse>> orderList(OrderListParams params);

  Future<Either<Failure, OrderDetailsResponse>> orderDetails(OrderDetailsParams params);

  Future<Either<Failure, OrderAssignmentResponse>> orderAssignment(OrderAssignmentParams params);

  Future<Either<Failure, OrderStatusUpdateResponse>> orderStatusUpdate(OrderStatusUpdateParams params);

  Future<Either<Failure, OrderCurrentAssignmentResponse>> orderCurrentAssignment(NoParams params);

  Future<Either<Failure, OrderStartAssignmentResponse>> orderStartAssignment(OrderStartAssignmentParams params);

  Future<Either<Failure, CurrentAssignmentOrderListResponse>> currentOrderAssignmentOrders(CurrentAssignmentOrderListParams params);

  Future<Either<Failure, CurrentFoodAssignmentResponse>> foodOrderCurrentAssignment(NoParams params);

  /// Profile
  Future<Either<Failure, ProfileResponse>> profile(NoParams params);

  /// Online Status
  Future<Either<Failure, OnlineStatusResponse>> onlineStatus(OnlineStatusParams params);

  /// Dashboard
  Future<Either<Failure, DashboardStatsResponse>> dashboard(NoParams params);

  /// Update Password
  Future<Either<Failure, CommonResponse>> passwordUpdate(PasswordUpdateParams params);

  /// Update Profile
  Future<Either<Failure, ProfileUpdateResponse>> profileUpdate(ProfileUpdateParams params);

  Future<Either<Failure, ProfileImageUpdateResponse>> profileImageUpdate(ProfileImageUpdateParams params);

  /// Delete Account
  Future<Either<Failure, CommonResponse>> deleteAccount(NoParams params);

  /// App Version
  Future<Either<Failure, AppUpdateResponse>> appUpdate(NoParams params);

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
            final token = respData.data!.accessToken!;
            final wsUrl = "${ApiUrl.socketUrl}?token=$token";
            getIt<TrackingSocketService>().startTracking(
              socketUrl: wsUrl,
              jwtToken: token,
            );
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


  @override
  Future<Either<Failure, FirebaseTokenUpdateResponse>> firebaseTokenUpdate(FirebaseTokenUpdateParams params) {
    return _networkInfo.check<FirebaseTokenUpdateResponse>(
      connected: () async {
        try {
          String token = await SessionManager.getAuthToken() ?? "";

          final respData = await _remoteDataSource.firebase_token_update(params, token);

          if (respData.status != 200) {
            return Left(CredentialFailure(respData.message!));
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
  Future<Either<Failure, OrdersListResponse>> orderList(OrderListParams params) {
    return _networkInfo.check<OrdersListResponse>(
      connected: () async {
        try {
          String token = await SessionManager.getAuthToken() ?? "";

          final respData = await _remoteDataSource.order_list(params, token);

          if (respData.status != 200) {
            return Left(CredentialFailure(respData.message!));
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
  Future<Either<Failure, OrderDetailsResponse>> orderDetails(OrderDetailsParams params) {
    return _networkInfo.check<OrderDetailsResponse>(
      connected: () async {
        try {
          String token = await SessionManager.getAuthToken() ?? "";

          final respData = await _remoteDataSource.order_details(params, token);

          if (respData.status != 200) {
            return Left(CredentialFailure(respData.message!));
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
  Future<Either<Failure, OrderAssignmentResponse>> orderAssignment(OrderAssignmentParams params) {
    return _networkInfo.check<OrderAssignmentResponse>(
      connected: () async {
        try {
          String token = await SessionManager.getAuthToken() ?? "";

          final respData = await _remoteDataSource.order_assignment(params, token);

          if (respData.status != 200) {
            return Left(CredentialFailure(respData.message!));
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
  Future<Either<Failure, OrderStatusUpdateResponse>> orderStatusUpdate(OrderStatusUpdateParams params) {
    return _networkInfo.check<OrderStatusUpdateResponse>(
      connected: () async {
        try {
          String token = await SessionManager.getAuthToken() ?? "";

          final respData = await _remoteDataSource.order_status_update(params, token);

          if (respData.status != 200) {
            return Left(CredentialFailure(respData.message!));
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
  Future<Either<Failure, OrderCurrentAssignmentResponse>> orderCurrentAssignment(NoParams params) {
    return _networkInfo.check<OrderCurrentAssignmentResponse>(
      connected: () async {
        try {
          String token = await SessionManager.getAuthToken() ?? "";

          final respData = await _remoteDataSource.order_current_assignment(token);

          if (respData.status != 200) {
            return Left(CredentialFailure(respData.message!));
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
  Future<Either<Failure, OrderStartAssignmentResponse>> orderStartAssignment(OrderStartAssignmentParams params) {
    return _networkInfo.check<OrderStartAssignmentResponse>(
      connected: () async {
        try {
          String token = await SessionManager.getAuthToken() ?? "";

          final respData = await _remoteDataSource.order_start_assignment(params, token);

          if (respData.status != 200) {
            return Left(CredentialFailure(respData.message!));
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
  Future<Either<Failure, CurrentAssignmentOrderListResponse>> currentOrderAssignmentOrders(CurrentAssignmentOrderListParams params) {
    return _networkInfo.check<CurrentAssignmentOrderListResponse>(
      connected: () async {
        try {
          String token = await SessionManager.getAuthToken() ?? "";

          final respData = await _remoteDataSource.current_assignment_orders(params, token);

          if (respData.status != 200) {
            return Left(CredentialFailure(respData.message!));
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
  Future<Either<Failure, CurrentFoodAssignmentResponse>> foodOrderCurrentAssignment(NoParams params) {
    return _networkInfo.check<CurrentFoodAssignmentResponse>(
      connected: () async {
        try {
          String token = await SessionManager.getAuthToken() ?? "";

          final respData = await _remoteDataSource.food_order_current_assignment(token);

          if (respData.status != 200) {
            return Left(CredentialFailure(respData.message!));
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
  Future<Either<Failure, ProfileResponse>> profile(NoParams params) {
    return _networkInfo.check<ProfileResponse>(
      connected: () async {
        try {
          String token = await SessionManager.getAuthToken() ?? "";

          final respData = await _remoteDataSource.profile(token);

          if (respData.status != 200) {
            return Left(CredentialFailure(respData.message));
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
  Future<Either<Failure, OnlineStatusResponse>> onlineStatus(OnlineStatusParams params) {
    return _networkInfo.check<OnlineStatusResponse>(
      connected: () async {
        try {
          String token = await SessionManager.getAuthToken() ?? "";

          final respData = await _remoteDataSource.online_status(params,token);

          if (respData.status != 200) {
            return Left(CredentialFailure(respData.message!));
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
  Future<Either<Failure, DashboardStatsResponse>> dashboard(NoParams params) {
    return _networkInfo.check<DashboardStatsResponse>(
      connected: () async {
        try {
          String token = await SessionManager.getAuthToken() ?? "";

          final respData = await _remoteDataSource.dashboard(token);

          if (respData.status != 200) {
            return Left(CredentialFailure(respData.message!));
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
  Future<Either<Failure, CommonResponse>> passwordUpdate(PasswordUpdateParams params) {
    return _networkInfo.check<CommonResponse>(
      connected: () async {
        try {
          String token = await SessionManager.getAuthToken() ?? "";

          final respData = await _remoteDataSource.password_update(params,token);

          if (respData.status != 200) {
            return Left(CredentialFailure(respData.message!));
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
  Future<Either<Failure, ProfileUpdateResponse>> profileUpdate(ProfileUpdateParams params) {
    return _networkInfo.check<ProfileUpdateResponse>(
      connected: () async {
        try {
          String token = await SessionManager.getAuthToken() ?? "";

          final respData = await _remoteDataSource.profile_update(params,token);

          if (respData.status != 200) {
            return Left(CredentialFailure(respData.message!));
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
  Future<Either<Failure, ProfileImageUpdateResponse>> profileImageUpdate(ProfileImageUpdateParams params) {
    return _networkInfo.check<ProfileImageUpdateResponse>(
      connected: () async {
        try {
          String token = await SessionManager.getAuthToken() ?? "";

          final respData = await _remoteDataSource.profile_image_update(params,token);

          if (respData.status != 200) {
            return Left(CredentialFailure(respData.message!));
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
  Future<Either<Failure, CommonResponse>> deleteAccount(NoParams params) {
    return _networkInfo.check<CommonResponse>(
      connected: () async {
        try {
          String token = await SessionManager.getAuthToken() ?? "";

          final respData = await _remoteDataSource.delete_account(token);

          if (respData.status != 200) {
            return Left(CredentialFailure(respData.message));
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
  Future<Either<Failure, AppUpdateResponse>> appUpdate(NoParams params) {
    return _networkInfo.check<AppUpdateResponse>(
      connected: () async {
        try {
          String token = await SessionManager.getAuthToken() ?? "";

          final respData = await _remoteDataSource.app_update(token);

          if (respData.status != 200) {
            return Left(CredentialFailure(respData.message));
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
}
