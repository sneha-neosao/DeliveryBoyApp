import 'package:delivery_boy_app/src/features/login/domain/login_usecase.dart';
import 'package:delivery_boy_app/src/features/login/domain/logout_usecase.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'injector.dart';

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

  /// API Helper

  getIt.registerLazySingleton(() => NetworkInfo());

  getIt.registerLazySingleton(() => AuthRepositoryImpl(getIt<RemoteDataSourceImpl>(), getIt<NetworkInfo>()),);

  getIt.registerLazySingleton(() => RemoteDataSourceImpl(getIt<ApiHelper>()));

  getIt.registerLazySingleton(() => ApiHelper(getIt<Dio>()));
}
