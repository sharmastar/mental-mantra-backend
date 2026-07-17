import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mental_mantra/core/widgets/debounce_button.dart';

void main() {
  group('DebounceButton', () {
    testWidgets('renders child widget', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DebounceButton(
              onTap: () {},
              child: const Text('Tap Me'),
            ),
          ),
        ),
      );
      expect(find.text('Tap Me'), findsOneWidget);
    });

    testWidgets('calls onTap on tap', (WidgetTester tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DebounceButton(
              onTap: () => tapped = true,
              child: const Text('Tap Me'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Tap Me'));
      expect(tapped, isTrue);
    });

    testWidgets('debounces rapid taps', (WidgetTester tester) async {
      var tapCount = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DebounceButton(
              debounceDelay: const Duration(milliseconds: 300),
              onTap: () => tapCount++,
              child: const Text('Tap Me'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Tap Me'));
      await tester.tap(find.text('Tap Me'));
      await tester.tap(find.text('Tap Me'));
      expect(tapCount, 1);
    });

    testWidgets('allows tap after debounce period',
        (WidgetTester tester) async {
      var tapCount = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DebounceButton(
              debounceDelay: const Duration(milliseconds: 50),
              onTap: () => tapCount++,
              child: const Text('Tap Me'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Tap Me'));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(find.text('Tap Me'));
      expect(tapCount, 2);
    });
  });
}
