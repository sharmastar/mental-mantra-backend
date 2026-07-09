import 'package:flutter_test/flutter_test.dart';
import 'package:mental_mantra/utils/validators.dart';

void main() {
  group('Validators', () {
    group('email', () {
      test('returns null for valid email', () {
        expect(Validators.email('test@example.com'), null);
        expect(Validators.email('user.name+tag@domain.co.uk'), null);
      });

      test('returns error for empty email', () {
        expect(Validators.email(''), isNotNull);
        expect(Validators.email(null), isNotNull);
      });

      test('returns error for invalid email', () {
        expect(Validators.email('notanemail'), isNotNull);
        expect(Validators.email('@domain.com'), isNotNull);
        expect(Validators.email('user@'), isNotNull);
      });
    });

    group('password', () {
      test('returns null for valid password', () {
        expect(Validators.password('Pass1234!'), null);
        expect(Validators.password('Str0ng!Pass'), null);
      });

      test('returns error for empty password', () {
        expect(Validators.password(''), isNotNull);
        expect(Validators.password(null), isNotNull);
      });

      test('returns error for too short password', () {
        expect(Validators.password('Ab1!'), isNotNull);
      });

      test('returns error for missing uppercase', () {
        expect(Validators.password('pass1234!'), isNotNull);
      });

      test('returns error for missing number', () {
        expect(Validators.password('PassWord!'), isNotNull);
      });

      test('returns error for missing special char', () {
        expect(Validators.password('Pass1234'), isNotNull);
      });
    });

    group('confirmPassword', () {
      test('returns null when passwords match', () {
        expect(Validators.confirmPassword('Pass123!', 'Pass123!'), null);
      });

      test('returns error when passwords do not match', () {
        expect(Validators.confirmPassword('Pass123!', 'Different!'), isNotNull);
      });

      test('returns error when empty', () {
        expect(Validators.confirmPassword('', 'Pass123!'), isNotNull);
        expect(Validators.confirmPassword(null, 'Pass123!'), isNotNull);
      });
    });

    group('name', () {
      test('returns null for valid name', () {
        expect(Validators.name('John'), null);
        expect(Validators.name('John Doe'), null);
      });

      test('returns error for empty name', () {
        expect(Validators.name(''), isNotNull);
        expect(Validators.name(null), isNotNull);
      });

      test('returns error for too short name', () {
        expect(Validators.name('J'), isNotNull);
      });
    });

    group('phone', () {
      test('returns null for valid phone', () {
        expect(Validators.phone('+1234567890'), null);
        expect(Validators.phone('+1 (234) 567-890'), null);
      });

      test('returns null for empty phone', () {
        expect(Validators.phone(''), null);
        expect(Validators.phone(null), null);
      });

      test('returns error for invalid phone', () {
        expect(Validators.phone('abc'), isNotNull);
      });
    });

    group('age', () {
      test('returns null for valid age', () {
        expect(Validators.age('25'), null);
        expect(Validators.age('13'), null);
        expect(Validators.age('120'), null);
      });

      test('returns null for empty age', () {
        expect(Validators.age(''), null);
        expect(Validators.age(null), null);
      });

      test('returns error for age below 13', () {
        expect(Validators.age('12'), isNotNull);
        expect(Validators.age('5'), isNotNull);
      });

      test('returns error for age above 120', () {
        expect(Validators.age('121'), isNotNull);
      });
    });
  });
}
