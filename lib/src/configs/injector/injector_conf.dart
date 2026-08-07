import 'package:delivery_boy_app/src/features/bulk_orders/domain/usecase/current_assignment_order_list_usecase.dart';
import 'package:delivery_boy_app/src/features/dashboard/domain/usecase/dashboard_usecase.dart';
import 'package:delivery_boy_app/src/features/dashboard/domain/usecase/firebase_token_update_usecase.dart';
import 'package:delivery_boy_app/src/features/dashboard/domain/usecase/online_status_usecase.dart';
import 'package:delivery_boy_app/src/features/login/domain/login_usecase.dart';
import 'package:delivery_boy_app/src/features/login/domain/logout_usecase.dart';
import 'package:delivery_boy_app/src/features/orders/bloc/order_assignment_bloc/order_assignment_bloc.dart';
import 'package:delivery_boy_app/src/features/orders/domain/usecase/order_assignment_usecase.dart';
import 'package:delivery_boy_app/src/features/orders/domain/usecase/order_current_assignment_usecase.dart';
import 'package:delivery_boy_app/src/features/orders/domain/usecase/order_details_usecase.dart';
import 'package:delivery_boy_app/src/features/orders/domain/usecase/order_list_usecase.dart';
import 'package:delivery_boy_app/src/features/orders/domain/usecase/order_start_assignment_usecase.dart';
import 'package:delivery_boy_app/src/features/orders/domain/usecase/order_status_update_usecase.dart';
import 'package:delivery_boy_app/src/features/profile/domain/usecase/password_update_usecase.dart';
import 'package:delivery_boy_app/src/features/profile/domain/usecase/profile_image_update_usecase.dart';
import 'package:delivery_boy_app/src/features/profile/domain/usecase/profile_update_usecase.dart';
import 'package:delivery_boy_app/src/features/profile/domain/usecase/profile_usecase.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:delivery_boy_app/src/configs/injector/injector.dart';

final getIt = GetIt.I;

void configureDepedencies() {
  getIt.registerLazySingleton<Dio>(() {
    final dio = Dio(
      BaseOptions(
        validateStatus: (status) => status != null && status < 400,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );

    dio.interceptors.add(ApiInterceptor(dio));
    return dio;
  });

  /// App Essentials
  getIt.registerLazySingleton(() => ThemeBloc());

  getIt.registerLazySingleton(() => TranslateBloc());

  getIt.registerLazySingleton(() => AppRouteConf());

  // getIt.registerFactory(() => BottomNav4Bloc());
  //
  // getIt.registerFactory(() => BottomNav3Bloc());

  /// Other api blocs
  getIt.registerLazySingleton(
        () => AuthLoginUseCase(getIt<AuthRepositoryImpl>()),
  );
  getIt.registerLazySingleton(
        () => LogoutUseCase(getIt<AuthRepositoryImpl>()),
  );
  getIt.registerFactory(
        () => AuthLoginBloc(getIt<AuthLoginUseCase>(), getIt<LogoutUseCase>()),
  );

  getIt.registerFactory(
        () => AuthLoginFormBloc(),
  );

  getIt.registerLazySingleton(
        () => OrderListUseCase(getIt<AuthRepositoryImpl>()),
  );

  getIt.registerFactory(
        () => OrderListBloc(getIt<OrderListUseCase>()),
  );

  getIt.registerLazySingleton(
        () => OrderDetailsUseCase(getIt<AuthRepositoryImpl>()),
  );

  getIt.registerFactory(
        () => OrderDetailsBloc(getIt<OrderDetailsUseCase>()),
  );
  getIt.registerLazySingleton(
        () => OrderAssignmentUseCase(getIt<AuthRepositoryImpl>()),
  );

  getIt.registerFactory(
        () => OrderAssignmentBloc(getIt<OrderAssignmentUseCase>()),
  );
  getIt.registerLazySingleton(
        () => ProfileUseCase(getIt<AuthRepositoryImpl>()),
  );

  getIt.registerFactory(
        () => ProfileBloc(getIt<ProfileUseCase>()),
  );
  getIt.registerLazySingleton(
        () => OnlineStatusUseCase(getIt<AuthRepositoryImpl>()),
  );

  getIt.registerFactory(
        () => OnlineStatusBloc(getIt<OnlineStatusUseCase>()),
  );
  getIt.registerLazySingleton(
        () => DashboardUseCase(getIt<AuthRepositoryImpl>()),
  );

  getIt.registerFactory(
        () => DashboardBloc(getIt<DashboardUseCase>()),
  );
  getIt.registerLazySingleton(
        () => PasswordUpdateUseCase(getIt<AuthRepositoryImpl>()),
  );
  getIt.registerFactory(
        () => PasswordUpdateBloc(getIt<PasswordUpdateUseCase>()),
  );

  getIt.registerFactory(
        () => PasswordUpdateFormBloc(),
  );
  getIt.registerLazySingleton(
        () => ProfileUpdateUseCase(getIt<AuthRepositoryImpl>()),
  );
  getIt.registerFactory(
        () => ProfileUpdateBloc(getIt<ProfileUpdateUseCase>()),
  );

  getIt.registerFactory(
        () => ProfileUpdateFormBloc(),
  );

  getIt.registerLazySingleton(
        () => ProfileImageUpdateUseCase(getIt<AuthRepositoryImpl>()),
  );
  getIt.registerFactory(
        () => ProfileImageUpdateBloc(getIt<ProfileImageUpdateUseCase>()),
  );
  getIt.registerLazySingleton(
        () => FirebaseTokenUpdateUseCase(getIt<AuthRepositoryImpl>()),
  );
  getIt.registerFactory(
        () => FirebaseTokenUpdateBloc(getIt<FirebaseTokenUpdateUseCase>()),
  );
  getIt.registerLazySingleton(
        () => OrderStatusUpdateUseCase(getIt<AuthRepositoryImpl>()),
  );
  getIt.registerFactory(
        () => OrderStatusUpdateBloc(getIt<OrderStatusUpdateUseCase>()),
  );
  getIt.registerLazySingleton(
        () => OrderCurrentAssignmentUseCase(getIt<AuthRepositoryImpl>()),
  );
  getIt.registerFactory(
        () => OrderCurrentAssignmentBloc(getIt<OrderCurrentAssignmentUseCase>()),
  );
  getIt.registerLazySingleton(
        () => OrderStartAssignmentUseCase(getIt<AuthRepositoryImpl>()),
  );
  getIt.registerFactory(
        () => OrderStartAssignmentBloc(getIt<OrderStartAssignmentUseCase>()),
  );
  getIt.registerLazySingleton(
        () => CurrentAssignmentOrderListUseCase(getIt<AuthRepositoryImpl>()),
  );
  getIt.registerFactory(
        () => CurrentAssignmentOrdersBloc(getIt<CurrentAssignmentOrderListUseCase>()),
  );
  getIt.registerLazySingleton(
        () => TrackingSocketService(),
  );
  /// API Helper

  getIt.registerLazySingleton(() => NetworkInfo());

  getIt.registerLazySingleton(() => AuthRepositoryImpl(getIt<RemoteDataSourceImpl>(), getIt<NetworkInfo>()),);

  getIt.registerLazySingleton(() => RemoteDataSourceImpl(getIt<ApiHelper>()));

  getIt.registerLazySingleton(() => ApiHelper(getIt<Dio>()));
}
