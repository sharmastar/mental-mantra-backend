class AppException implements Exception {
  final String message;
  final String? code;
  final int? statusCode;

  const AppException({
    required this.message,
    this.code,
    this.statusCode,
  });

  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;
  bool get isNotFound => statusCode == 404;
  bool get isServerError => statusCode != null && statusCode! >= 500;
  bool get isNetworkError =>
      code == 'NO_CONNECTION' ||
      code == 'TIMEOUT' ||
      code == 'SSL_ERROR' ||
      code == 'DNS_FAILURE' ||
      code == 'SERVER_OFFLINE';
  bool get isSslError => code == 'SSL_ERROR';
  bool get isDnsError => code == 'DNS_FAILURE';
  bool get isTimeout => code == 'TIMEOUT';
  bool get isServerOffline => code == 'SERVER_OFFLINE';

  @override
  String toString() => 'AppException($code): $message';
}

class AuthException extends AppException {
  const AuthException({required super.message, super.code, super.statusCode});
}

class NetworkException extends AppException {
  const NetworkException({required super.message, super.code})
      : super(statusCode: null);
}

/// Thrown when SSL/TLS handshake or certificate verification fails.
class SslException extends AppException {
  final String? host;
  const SslException({
    required super.message,
    this.host,
  }) : super(code: 'SSL_ERROR', statusCode: null);
}

/// Thrown when DNS resolution fails for the target host.
class DnsException extends AppException {
  final String? host;
  const DnsException({
    required super.message,
    this.host,
  }) : super(code: 'DNS_FAILURE', statusCode: null);
}

/// Thrown when the backend server is unreachable (connection refused).
class ServerOfflineException extends AppException {
  const ServerOfflineException({
    required super.message,
  }) : super(code: 'SERVER_OFFLINE', statusCode: null);
}

/// Thrown when a network operation times out, with the specific timeout type.
class NetworkTimeoutException extends AppException {
  /// One of: 'connect', 'receive', 'send'
  final String timeoutType;
  const NetworkTimeoutException({
    required super.message,
    required this.timeoutType,
  }) : super(code: 'TIMEOUT', statusCode: null);
}

class ApiSendException extends AppException {
  const ApiSendException(String message)
      : super(message: message, code: 'API_SEND_ERROR');
}

class ValidationException extends AppException {
  final List<FieldError> fieldErrors;
  const ValidationException({
    required super.message,
    this.fieldErrors = const [],
  }) : super(code: 'VALIDATION_ERROR');
}

class FieldError {
  final String field;
  final String message;
  const FieldError({required this.field, required this.message});
}
