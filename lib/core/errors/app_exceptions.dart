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
  bool get isNetworkError => code == 'NO_CONNECTION' || code == 'TIMEOUT';

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
