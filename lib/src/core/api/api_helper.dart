import 'dart:io';
import 'package:delivery_boy_app/src/configs/injector/injector.dart';
import 'package:delivery_boy_app/src/core/theme/app_color.dart';
import 'package:delivery_boy_app/src/features/widgets/snackbar_widget.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../network/network_checker.dart';
import '../utils/logger.dart';
import 'api_exception.dart';

class ApiHelper {
  final Dio _dio;
  const ApiHelper(this._dio);

  Future<Map<String, dynamic>> execute({
    required Method method,
    required String url,
    dynamic data,
    dynamic options,
  }) async {
    print("🚀 ApiHelper → EXECUTE CALLED");

    final isConnected = await NetworkInfo().checkIsConnected;
    if (!isConnected) {
      final context = globalNavigator.currentContext;
      if (context != null) {
        appSnackBar(context, AppColor.bright_red, "Please check your internet connection");
      }
      throw FetchDataException('No Internet connection');
    }

    // final newToken = await SecureStorage.getAccessToken();

    try {
      Response response;
      logger.d("URL: $url");
      logger.d("Method: $method");
      
      if (data is FormData) {
        final fields = Map.fromEntries(data.fields);
        final files = data.files.map((e) => "${e.key}: ${e.value.filename} (${e.value.length} bytes)").toList();
        logger.d("FormData Fields: $fields");
        logger.d("FormData Files: $files");
      } else {
        logger.d("Data: $data");
      }

      switch (method) {
        case Method.get:
          response = await _dio.get(
            url,
            data: data,
            options: options ?? Options(),
          );
          break;
        case Method.post:
          response = await _dio.post(
            url,
            data: data,
            options: options ?? Options(),
          );
          break;
        case Method.put:
          response = await _dio.put(
            url,
            data: data,
            options: options ?? Options(),
          );
          break;
        case Method.patch:
          response = await _dio.patch(
            url,
            data: data,
            options: options ?? Options(),
          );
          break;
        case Method.delete:
          response = await _dio.delete(
            url,
            data: data,
            options: options ?? Options(),
          );
          break;
      }

      logger.d(response);
      print("before return response");
      return _returnResponse(response);
    } on SocketException {
      throw FetchDataException('No Internet connection');
    } on DioException catch (e) {
      logger.e("🔥 DioException: ${e.message}");
      if (e.response != null) {
        logger.e("🔥 Response status: ${e.response?.statusCode}");
        logger.e("🔥 Response data: ${e.response?.data}");
        logger.e("🔥 Response headers: ${e.response?.headers}");
        
        final data = e.response?.data;
        if (data is Map<String, dynamic>) {
          if (data['error'] is Map<String, dynamic> && data['error']['message'] != null) {
            throw ApiException(data['error']['message'].toString());
          }
          if (data['message'] != null) {
            throw ApiException(data['message'].toString());
          }
        }
      }
      throw ApiException(e.message ?? "Network error");
    }
  }

  Map<String, dynamic> _returnResponse(Response response) {
    switch (response.statusCode) {
      case 200:
        return response.data;
      case 201:
        return response.data;
      case 300:
        return response.data;
      case 400:
        throw BadRequestException(response.data["message"].toString());
      case 401:
        return response.data;
      case 403:
        throw ForbiddenException(response.data["message"].toString());
      case 404:
        throw NotFoundException(response.data["message"].toString());
      case 422:
        throw UnprocessableContentException(
          response.data["message"].toString(),
        );
      case 500:
        throw InternalServerException(response.data["message"].toString());
      default:
        throw FetchDataException(
          'Error occured while Communication with Server with StatusCode : ${response.statusCode}',
        );
    }
  }
}

enum Method { get, post, put, patch, delete }
