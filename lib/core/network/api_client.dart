import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:mental_mantra/core/config/app_config.dart';
import 'package:mental_mantra/core/storage/secure_storage.dart';
import 'package:mental_mantra/core/errors/app_exceptions.dart';
import 'package:mental_mantra/core/utils/connectivity.dart';
import 'package:mental_mantra/core/network/ssl_pinning_client.dart';

class ApiClient {
  ApiClient._();

  static final Dio _dio = Dio();
  static final Dio _authDio = Dio();

  static const int _maxRetries = 3;
  static const Duration _baseRetryDelay = Duration(seconds: 1);
  static final List<CancelToken> _activeTokens = [];

  static void updateBaseUrl(String newUrl) {
    _dio.options.baseUrl = newUrl;
    _authDio.options.baseUrl = newUrl;
    debugPrint('[ApiClient] Base URL updated dynamically to: $newUrl');
  }

  static void init() {
    _authDio.options = BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: AppConfig.connectTimeout,
      receiveTimeout: AppConfig.receiveTimeout,
      headers: {'Content-Type': 'application/json'},
    );

    _dio.options = BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: AppConfig.connectTimeout,
      receiveTimeout: AppConfig.receiveTimeout,
      headers: {'Content-Type': 'application/json'},
    );

    SslPinningClient.configureSslPinning(_authDio);
    SslPinningClient.configureSslPinning(_dio);


    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: false,
        responseHeader: false,
      ));
    }

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: _onRequest,
      onError: _onError,
    ));
  }

  static Future<void> _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await SecureStorage.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  static Future<void> _onError(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    if (error.response?.statusCode == 401) {
      final refreshed = await _tryRefreshToken();
      if (refreshed) {
        final opts = error.requestOptions;
        final newToken = await SecureStorage.getAccessToken();
        if (newToken != null) {
          opts.headers['Authorization'] = 'Bearer $newToken';
        }
        try {
          final retryResponse = await _dio.fetch(opts);
          handler.resolve(retryResponse);
          return;
        } catch (e) {
          debugPrint('[ApiClient] Retry failed: $e');
        }
      } else {
        await SecureStorage.clearAuth();
      }
    }
    handler.next(error);
  }

  static Future<bool> _tryRefreshToken() async {
    try {
      final refreshToken = await SecureStorage.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) return false;

      final response = await _authDio.post('/auth/refresh', data: {
        'refreshToken': refreshToken,
      });

      if (response.statusCode == 200 && response.data != null) {
        final newAccessToken = response.data['accessToken'] as String?;
        final newRefreshToken = response.data['refreshToken'] as String?;
        if (newAccessToken != null && newRefreshToken != null) {
          await SecureStorage.saveAccessToken(newAccessToken);
          await SecureStorage.saveRefreshToken(newRefreshToken);
          return true;
        }
      }
    } catch (e) {
      debugPrint('[ApiClient] Token refresh failed: $e');
    }
    return false;
  }

  static Future<Response<T>> _executeWithRetry<T>(
    Future<Response<T>> Function() request, {
    CancelToken? cancelToken,
  }) async {
    DioException? lastError;

    if (cancelToken != null) _activeTokens.add(cancelToken);

    try {
      for (int attempt = 0; attempt < _maxRetries; attempt++) {
        try {
          return await request();
        } on DioException catch (e) {
          lastError = e;

          final shouldRetry = _shouldRetry(e, attempt);
          if (!shouldRetry) break;

          final delay = _baseRetryDelay * (1 << attempt);
          await Future.delayed(delay);
        }
      }

      throw _handleDioError(lastError!);
    } finally {
      _activeTokens.remove(cancelToken);
    }
  }

  static bool _shouldRetry(DioException e, int attempt) {
    if (attempt >= _maxRetries - 1) return false;

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return true;
    }

    if (e.type == DioExceptionType.connectionError) {
      if (attempt < 2) return true;
    }

    final statusCode = e.response?.statusCode;
    if (statusCode != null && statusCode >= 500 && statusCode < 600) return true;
    if (statusCode == 429) return true;

    return false;
  }

  static Dio get dio => _dio;

  static void cancelAll() {
    for (final token in _activeTokens) {
      token.cancel();
    }
    _activeTokens.clear();
  }

  static Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _executeWithRetry(
      () => _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      ),
      cancelToken: cancelToken,
    );
  }

  static Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _executeWithRetry(
      () => _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      ),
      cancelToken: cancelToken,
    );
  }

  static Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _executeWithRetry(
      () => _dio.put<T>(
        path,
        data: data,
        options: options,
        cancelToken: cancelToken,
      ),
      cancelToken: cancelToken,
    );
  }

  static Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _executeWithRetry(
      () => _dio.delete<T>(
        path,
        data: data,
        options: options,
        cancelToken: cancelToken,
      ),
      cancelToken: cancelToken,
    );
  }

  static AppException _handleDioError(DioException e) {
    final statusCode = e.response?.statusCode;
    
    String message = e.message ?? 'Unknown error';
    String? code;

    if (e.response?.data is Map) {
      final data = e.response!.data as Map;
      code = data['code']?.toString();
      
      final rawMessage = data['message'];
      if (rawMessage is List) {
        message = rawMessage.join(', ');
      } else if (rawMessage != null) {
        message = rawMessage.toString();
      }
    }

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return AppException(
        message: 'Connection timeout: ${e.message}',
        code: 'TIMEOUT',
      );
    }

    if (e.type == DioExceptionType.connectionError) {
      return AppException(
        message: 'Connection error: ${e.message}',
        code: 'NO_CONNECTION',
      );
    }

    if (statusCode == 429) {
      return AppException(
        message: 'Too many requests (429): $message',
        code: 'RATE_LIMITED',
        statusCode: statusCode,
      );
    }

    if (statusCode != null && statusCode >= 500) {
      return AppException(
        message: 'Server Error ($statusCode): $message',
        code: code ?? 'SERVER_ERROR',
        statusCode: statusCode,
      );
    }

    return AppException(message: message, code: code, statusCode: statusCode);
  }

  static Future<bool> checkConnectivity() => ConnectivityUtil.hasInternet();
}
