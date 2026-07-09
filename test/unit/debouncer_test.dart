import 'package:flutter_test/flutter_test.dart';
import 'package:mental_mantra/core/utils/debouncer.dart';

void main() {
  group('Debouncer', () {
    test('debounces multiple rapid calls', () async {
      final debouncer = Debouncer(delay: const Duration(milliseconds: 100));
      int callCount = 0;

      debouncer(() => callCount++);
      debouncer(() => callCount++);
      debouncer(() => callCount++);

      expect(callCount, 0);

      await Future.delayed(const Duration(milliseconds: 150));
      expect(callCount, 1);
    });

    test('cancel prevents execution', () async {
      final debouncer = Debouncer(delay: const Duration(milliseconds: 100));
      int callCount = 0;

      debouncer(() => callCount++);
      debouncer.cancel();

      await Future.delayed(const Duration(milliseconds: 150));
      expect(callCount, 0);
    });
  });

  group('Throttler', () {
    test('allows first call but blocks subsequent calls', () {
      final throttler = Throttler(interval: const Duration(milliseconds: 100));

      expect(throttler.tryRun(), true);
      expect(throttler.tryRun(), false);
      expect(throttler.tryRun(), false);
    });

    test('allows call after interval', () async {
      final throttler = Throttler(interval: const Duration(milliseconds: 50));

      expect(throttler.tryRun(), true);
      expect(throttler.tryRun(), false);

      await Future.delayed(const Duration(milliseconds: 60));
      expect(throttler.tryRun(), true);
    });

    test('reset allows immediate call', () {
      final throttler = Throttler(interval: const Duration(milliseconds: 100));

      expect(throttler.tryRun(), true);
      throttler.reset();
      expect(throttler.tryRun(), true);
    });
  });
}
