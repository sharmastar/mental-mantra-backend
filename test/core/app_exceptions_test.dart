import 'package:flutter_test/flutter_test.dart';
import 'package:mental_mantra/core/errors/app_exceptions.dart';

void main() {
  group('AppException', () {
    test('creates with required message', () {
      const ex = AppException(message: 'test error');
      expect(ex.message, 'test error');
      expect(ex.code, isNull);
      expect(ex.statusCode, isNull);
    });

    test('detects unauthorized', () {
      expect(const AppException(message: 'x', statusCode: 401).isUnauthorized, isTrue);
      expect(const AppException(message: 'x', statusCode: 403).isUnauthorized, isFalse);
    });

    test('detects server errors', () {
      expect(const AppException(message: 'x', statusCode: 500).isServerError, isTrue);
      expect(const AppException(message: 'x', statusCode: 404).isServerError, isFalse);
    });

    test('detects network errors', () {
      expect(const AppException(message: 'x', code: 'NO_CONNECTION').isNetworkError, isTrue);
      expect(const AppException(message: 'x', code: 'TIMEOUT').isNetworkError, isTrue);
      expect(const AppException(message: 'x', code: 'SERVER_ERROR').isNetworkError, isFalse);
    });
  });

  group('AuthException', () {
    test('extends AppException', () {
      const ex = AuthException(message: 'auth failed', statusCode: 401);
      expect(ex, isA<AppException>());
      expect(ex.isUnauthorized, isTrue);
    });
  });

  group('NetworkException', () {
    test('extends AppException with no status code', () {
      const ex = NetworkException(message: 'no connection');
      expect(ex, isA<AppException>());
      expect(ex.statusCode, isNull);
    });
  });

  group('ValidationException', () {
    test('can have field errors', () {
      const ex = ValidationException(
        message: 'validation failed',
        fieldErrors: [FieldError(field: 'email', message: 'invalid')],
      );
      expect(ex.fieldErrors.length, 1);
      expect(ex.fieldErrors[0].field, 'email');
    });
  });
}
