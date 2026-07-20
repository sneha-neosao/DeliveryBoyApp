import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:delivery_boy_app/src/core/api/api_url.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../configs/injector/injector.dart';
import '../session/session_manager.dart';
import '../utils/logger.dart';

class ApiInterceptor extends Interceptor {
  final Dio dio;
  bool isRefreshing = false;
  bool _isLoggingOut = false;
  final List<void Function(String)> _requestsQueue = [];


  Map<String, dynamic>? _cachedDeviceInfo;

  // Future<Map<String, dynamic>> _getDeviceInfo() async {
  //   if (_cachedDeviceInfo != null) return _cachedDeviceInfo!;
  //
  //   try {
  //     final deviceInfo = DeviceInfoPlugin();
  //     if (Platform.isAndroid) {
  //       final androidInfo = await deviceInfo.androidInfo;
  //       _cachedDeviceInfo = {
  //         'platform': 'android',
  //         'brand': androidInfo.brand,
  //         'manufacturer': androidInfo.manufacturer,
  //         'model': androidInfo.model,
  //         'device': androidInfo.device,
  //         'product': androidInfo.product,
  //         'androidVersion': androidInfo.version.release,
  //         'sdkInt': androidInfo.version.sdkInt,
  //         'hardware': androidInfo.hardware,
  //         'isPhysicalDevice': androidInfo.isPhysicalDevice,
  //       };
  //     } else if (Platform.isIOS) {
  //       final iosInfo = await deviceInfo.iosInfo;
  //       _cachedDeviceInfo = {
  //         'platform': 'ios',
  //         'name': iosInfo.name,
  //         'model': iosInfo.model,
  //         'localizedModel': iosInfo.localizedModel,
  //         'systemName': iosInfo.systemName,
  //         'systemVersion': iosInfo.systemVersion,
  //         'machine': iosInfo.utsname.machine,
  //         'isPhysicalDevice': iosInfo.isPhysicalDevice,
  //       };
  //     } else {
  //       _cachedDeviceInfo = {
  //         'platform': Platform.operatingSystem,
  //         'model': Platform.operatingSystemVersion,
  //       };
  //     }
  //   } catch (e) {
  //     logger.e('Error getting device info: $e');
  //     _cachedDeviceInfo = {'platform': 'unknown', 'model': 'Unknown'};
  //   }
  //   return _cachedDeviceInfo!;
  // }

  void _addToQueue(void Function(String) callback) {
    _requestsQueue.add(callback);
  }

  void _resolveQueue(String token) {
    for (var callback in _requestsQueue) {
      callback(token);
    }
    _requestsQueue.clear();
  }

  void _clearQueue() {
    _requestsQueue.clear();
  }

  ApiInterceptor(this.dio);

  @override
  Future<void> onRequest(
      RequestOptions options,
      RequestInterceptorHandler handler,
      ) async {
    final token = await SessionManager.getAuthToken();

    options.baseUrl = ApiUrl.baseUrl;

    bool skipAuth = options.path.contains('login') || options.path.contains('/token/refresh');

    if (!skipAuth && token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    // final deviceInfo = await _getDeviceInfo();
    // options.headers['Device-Name'] = deviceInfo['model']?.toString() ?? 'Unknown';
    // options.headers['Device-Info'] = jsonEncode(deviceInfo);

    // 🔥 FULL REQUEST LOG
    //     debugPrint('''
    // ━━━━━━━━━━━━━━━━━━━━━━ 📤 API REQUEST ━━━━━━━━━━━━━━━━━━━━━━
    // ➡️ METHOD   : ${options.method}
    // 🌐 URL      : ${options.uri}
    // 📌 PATH     : ${options.path}
    //
    // 🧾 HEADERS  :
    // ${options.headers.entries.map((e) => '  ${e.key}: ${e.value}').join('\n')}
    //
    // 🔍 QUERY PARAMS :
    // ${options.queryParameters.isEmpty ? '  <empty>' : options.queryParameters}
    //
    // 📦 BODY :
    // ${options.data ?? '<empty>'}
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // ''');

    // logger.i("➡️ ${options.method} ${options.uri}");
    super.onRequest(options, handler);
  }

  @override
  Future<void> onError(
      DioException err,
      ErrorInterceptorHandler handler,
      ) async {
    print(
      "🔥 ApiInterceptor.onError CALLED with status: ${err.response?.statusCode}",
    );
    // print("❌ ERROR ${err.response?.statusCode}");

    // Avoid infinite loop
    if (err.requestOptions.path.contains('/auth/send-otp') ||
        err.requestOptions.path.contains('/auth/refresh') ||
        err.requestOptions.path.contains('/auth/verify-otp') ||
        err.requestOptions.path.contains('/auth/signup') ||
        err.requestOptions.path.contains('/token/refresh')) {
      return handler.next(err);
    }

    if (err.response?.statusCode == 401) {
      if (_isLoggingOut) return;

      if (!isRefreshing) {
        isRefreshing = true;

        final refreshToken = await SessionManager.getRefreshToken();
        print("refresh token: ${refreshToken}");

        if (refreshToken == null || refreshToken.isEmpty) {
          isRefreshing = false;
          _logout();
          return; // Stay on loading / navigation
        }

        try {
          final refreshResponse = await dio.post(
            "${ApiUrl.baseUrl}technician/token/refresh",
            data: {'refresh_token': refreshToken},
            options: Options(headers: {
              'accept': 'application/json',
              'Content-Type': 'application/json',
            }),
          );

          if (refreshResponse.statusCode == 200 && refreshResponse.data['data'] != null) {
            final newToken = refreshResponse.data['data']['access_token'];
            final newRefreshToken = refreshResponse.data['data']['refresh_token'];
            print("new token after refresh token api called: ${newToken}");

            if (newToken != null) {
              await SessionManager.saveSessionId(newToken.toString());
            }
            if (newRefreshToken != null) {
              await SessionManager.saveRefreshToken(newRefreshToken.toString());
            }

            dio.options.headers['Authorization'] = 'Bearer $newToken';

            isRefreshing = false;
            _resolveQueue(newToken.toString());

            err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
            final retryResponse = await dio.fetch(err.requestOptions);
            return handler.resolve(retryResponse);
          } else {
            isRefreshing = false;
            _clearQueue();
            _logout();
            return;
          }
        } catch (e) {
          isRefreshing = false;
          _clearQueue();
          _logout();
          return;
        }
      } else {
        // Add to queue and wait for refresh
        return handler.resolve(await _retryRequest(err.requestOptions));
      }
    }

    return handler.next(err);
  }

  Future<Response> _retryRequest(RequestOptions requestOptions) {
    final responseCompleter = Completer<Response>();

    _addToQueue((newToken) async {
      requestOptions.headers['Authorization'] = 'Bearer $newToken';
      try {
        final response = await dio.fetch(requestOptions);
        responseCompleter.complete(response);
      } catch (e) {
        responseCompleter.completeError(e);
      }
    });

    return responseCompleter.future;
  }

  Future<void> _logout() async {
    if (_isLoggingOut) return;
    _isLoggingOut = true;

    print("🔴 LOGOUT triggered in ApiInterceptor");

    // 1️⃣ Clear secure storage
    await SessionManager.saveLoginStatus(false);
    await SessionManager.clear();

    // 2️⃣ Clear Dio in-memory auth header
    dio.options.headers.remove('Authorization');

    // 3️⃣ Navigate to login using GoRouter
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = globalNavigator.currentContext;
      print("🔴 Navigation Context: $context");
      if (context == null) return;

      // Close any open dialogs/bottom sheets on the root navigator
      Navigator.of(context, rootNavigator: true).popUntil((route) => route.isFirst);

      // context.go(AppRoute.loginScreen.path);
    });
  }
}
