import 'dart:async';
import 'dart:io';
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

  static void Function()? onUnauthorized;
  static bool _initialized = false;

  static const int _maxRetries = 3;
  static const Duration _baseRetryDelay = Duration(seconds: 1);
  static final List<CancelToken> _activeTokens = [];

  // Mutex to prevent concurrent 401 refresh-token races
  static bool _isRefreshing = false;
  static final List<Completer<void>> _refreshWaiters = [];

  static void updateBaseUrl(String newUrl) {
    _dio.options.baseUrl = newUrl;
    _authDio.options.baseUrl = newUrl;
    debugPrint('[ApiClient] Base URL updated to: $newUrl');
  }

  static void init() {
    if (_initialized) return;
    _initialized = true;

    AppConfig.onBackendUrlResolved = (newUrl) {
      updateBaseUrl('$newUrl/api');
    };
    if (AppConfig.backendHost.isNotEmpty) {
      updateBaseUrl(AppConfig.apiBaseUrl);
    }

    _authDio.options = BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: AppConfig.connectTimeout,
      receiveTimeout: AppConfig.receiveTimeout,
      sendTimeout: AppConfig.sendTimeout,
      headers: {'Content-Type': 'application/json'},
    );

    _dio.options = BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: AppConfig.connectTimeout,
      receiveTimeout: AppConfig.receiveTimeout,
      sendTimeout: AppConfig.sendTimeout,
      headers: {'Content-Type': 'application/json'},
    );

    SslPinningClient.configureSslPinning(_authDio);
    SslPinningClient.configureSslPinning(_dio);

    debugPrint('[ApiClient] Initialized with API URL: ${AppConfig.apiBaseUrl}');
    debugPrint(
      '[ApiClient] Timeouts → connect: ${AppConfig.connectTimeout.inSeconds}s, '
      'receive: ${AppConfig.receiveTimeout.inSeconds}s, '
      'send: ${AppConfig.sendTimeout.inSeconds}s',
    );

    // Debug-mode verbose logging interceptor
    if (kDebugMode) {
      _dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          debugPrint('=== API REQUEST ===');
          debugPrint('URL: ${options.uri}');
          debugPrint('Method: ${options.method}');
          debugPrint('Headers: ${options.headers}');
          if (options.data != null) {
            debugPrint('Body: ${options.data}');
          }
          // Attach timing
          options.extra['_requestStartMs'] =
              DateTime.now().millisecondsSinceEpoch;
          handler.next(options);
        },
        onResponse: (response, handler) {
          final startMs =
              response.requestOptions.extra['_requestStartMs'] as int?;
          final durationMs = startMs != null
              ? DateTime.now().millisecondsSinceEpoch - startMs
              : -1;
          debugPrint('=== API RESPONSE ===');
          debugPrint('URL: ${response.requestOptions.uri}');
          debugPrint('Status Code: ${response.statusCode}');
          debugPrint('Duration: ${durationMs}ms');
          debugPrint('Body: ${response.data}');
          handler.next(response);
        },
        onError: (DioException e, handler) {
          final startMs =
              e.requestOptions.extra['_requestStartMs'] as int?;
          final durationMs = startMs != null
              ? DateTime.now().millisecondsSinceEpoch - startMs
              : -1;
          debugPrint('=== API ERROR ===');
          debugPrint('URL: ${e.requestOptions.uri}');
          debugPrint('Error Type: ${e.type}');
          debugPrint('Duration: ${durationMs}ms');
          debugPrint('Message: ${e.message}');
          if (e.response != null) {
            debugPrint('Status Code: ${e.response?.statusCode}');
            debugPrint('Response Body: ${e.response?.data}');
          }
          if (e.error != null) {
            debugPrint('Inner Error: ${e.error}');
            debugPrint('Inner Error Type: ${e.error.runtimeType}');
          }
          handler.next(e);
        },
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
      // Wait if another 401 is already being refreshed
      if (_isRefreshing) {
        final completer = Completer<void>();
        _refreshWaiters.add(completer);
        await completer.future;
        // Re-check if refresh succeeded
        final newToken = await SecureStorage.getAccessToken();
        if (newToken != null && newToken.isNotEmpty) {
          final opts = error.requestOptions;
          opts.headers['Authorization'] = 'Bearer $newToken';
          try {
            final retryResponse = await _dio.fetch(opts);
            handler.resolve(retryResponse);
            return;
          } catch (e) {
            debugPrint('[ApiClient] Retry after wait failed: $e');
          }
        }
        handler.next(error);
        return;
      }

      _isRefreshing = true;
      try {
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
          onUnauthorized?.call();
        }
      } finally {
        _isRefreshing = false;
        for (final waiter in _refreshWaiters) {
          if (!waiter.isCompleted) waiter.complete();
        }
        _refreshWaiters.clear();
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
          debugPrint(
            '[ApiClient] Retry ${attempt + 1}/$_maxRetries after '
            '${delay.inMilliseconds}ms for ${e.requestOptions.uri}',
          );
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
      // Don't retry SSL errors — they'll fail every time
      if (_isSslError(e)) return false;
      if (attempt < 2) return true;
    }

    final statusCode = e.response?.statusCode;
    if (statusCode != null && statusCode >= 500 && statusCode < 600) {
      return true;
    }
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

  // ── Error Classification Helpers ──────────────────────────────────

  /// Detect SSL/TLS handshake failures from the inner error
  static bool _isSslError(DioException e) {
    final error = e.error;
    if (error == null) return false;
    final errorStr = error.toString();
    return error is HandshakeException ||
        errorStr.contains('HandshakeException') ||
        errorStr.contains('CERTIFICATE_VERIFY_FAILED') ||
        errorStr.contains('certificate') ||
        errorStr.contains('SSL') ||
        errorStr.contains('TLS');
  }

  /// Detect DNS resolution failures
  static bool _isDnsError(DioException e) {
    final errorStr = e.error?.toString() ?? '';
    return errorStr.contains('Failed host lookup') ||
        errorStr.contains('getaddrinfo') ||
        errorStr.contains('Name or service not known') ||
        errorStr.contains('No address associated with hostname');
  }

  /// Detect connection refused (server offline)
  static bool _isConnectionRefused(DioException e) {
    final errorStr = e.error?.toString() ?? '';
    return errorStr.contains('Connection refused') ||
        errorStr.contains('ECONNREFUSED') ||
        errorStr.contains('errno = 111') ||
        errorStr.contains('errno = 61');
  }

  /// Convert a DioException into a specific, user-friendly AppException
  static AppException _handleDioError(DioException e) {
    final statusCode = e.response?.statusCode;

    // ── Extract server message if available ──────────────────────────
    String serverMessage = '';
    String? code;
    if (e.response?.data is Map) {
      final data = e.response!.data as Map;
      code = data['code']?.toString();
      final rawMessage = data['message'];
      if (rawMessage is List) {
        serverMessage = rawMessage.join(', ');
      } else if (rawMessage != null) {
        serverMessage = rawMessage.toString();
      }
    } else if (e.response?.data != null) {
      serverMessage = e.response!.data.toString();
    }

    // ── Timeout errors ──────────────────────────────────────────────
    if (e.type == DioExceptionType.connectionTimeout) {
      return const NetworkTimeoutException(
        message:
            'Connection timed out. The server may be slow or unreachable. '
            'Please check your network and try again.',
        timeoutType: 'connect',
      );
    }
    if (e.type == DioExceptionType.sendTimeout) {
      return const NetworkTimeoutException(
        message:
            'Request timed out while sending data. '
            'Please check your network speed and try again.',
        timeoutType: 'send',
      );
    }
    if (e.type == DioExceptionType.receiveTimeout) {
      return const NetworkTimeoutException(
        message:
            'Server is taking too long to respond. '
            'The server may be overloaded. Please try again later.',
        timeoutType: 'receive',
      );
    }

    // ── Connection-level errors ─────────────────────────────────────
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.unknown) {
      // SSL/TLS errors
      if (_isSslError(e)) {
        final host = e.requestOptions.uri.host;
        return SslException(
          message:
              'SSL certificate verification failed for $host. '
              'The connection is not secure.',
          host: host,
        );
      }

      // DNS resolution failures
      if (_isDnsError(e)) {
        final host = e.requestOptions.uri.host;
        return DnsException(
          message:
              'Cannot resolve server address ($host). '
              'Please check your internet connection.',
          host: host,
        );
      }

      // Connection refused — server offline
      if (_isConnectionRefused(e)) {
        return const ServerOfflineException(
          message:
              'Cannot connect to the server (connection refused). '
              'The backend may be offline or the server address is incorrect.',
        );
      }

      // Generic SocketException / unknown connection error
      final isSocket = e.error is SocketException ||
          (e.error?.toString().contains('SocketException') ?? false);
      return NetworkException(
        message: isSocket
            ? 'Network error. Please check your internet connection '
                'and try again.'
            : 'Connection error: Unable to reach the server. '
                'Please verify your network and try again.',
        code: 'NO_CONNECTION',
      );
    }

    // ── HTTP status code errors ─────────────────────────────────────
    if (statusCode == 429) {
      return AppException(
        message: serverMessage.isNotEmpty
            ? serverMessage
            : 'Too many requests. Please try again later.',
        code: 'RATE_LIMITED',
        statusCode: statusCode,
      );
    }

    if (statusCode != null && statusCode >= 400 && statusCode < 500) {
      return AppException(
        message: serverMessage.isNotEmpty
            ? serverMessage
            : 'Client Error ($statusCode)',
        code: code ?? 'CLIENT_ERROR',
        statusCode: statusCode,
      );
    }

    if (statusCode != null && statusCode >= 500) {
      return AppException(
        message: serverMessage.isNotEmpty
            ? 'Server error: $serverMessage'
            : 'Server unavailable ($statusCode). '
                'The backend encountered an error. Please try again later.',
        code: code ?? 'SERVER_ERROR',
        statusCode: statusCode,
      );
    }

    // ── Fallback ────────────────────────────────────────────────────
    final fallbackMessage = serverMessage.isNotEmpty
        ? serverMessage
        : e.message ?? e.error?.toString() ?? 'An unknown network error occurred';
    return AppException(
      message: fallbackMessage,
      code: code,
      statusCode: statusCode,
    );
  }

  static Future<bool> checkConnectivity() => ConnectivityUtil.hasInternet();
}
