import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:mobile/core/config/api_config.dart';
import 'package:mobile/core/network/auth_interceptor.dart';
import 'package:mobile/core/storage/secure_token_storage.dart';

abstract final class DioClient {
  static Dio create(SecureTokenStorage tokenStorage) {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        validateStatus: (code) => code != null && code < 500,
      ),
    );
    dio.interceptors.add(AuthInterceptor(tokenStorage));
    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          requestHeader: true,
          requestBody: true,
          responseHeader: false,
          responseBody: true,
          error: true,
          logPrint: (o) => debugPrint(o.toString()),
        ),
      );
    }
    return dio;
  }
}
