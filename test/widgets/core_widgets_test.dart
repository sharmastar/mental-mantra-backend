import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mental_mantra/shared/widgets/app_logo.dart';
import 'package:mental_mantra/core/widgets/offline_banner.dart';

void main() {
  group('Core Widgets Tests', () {
    testWidgets('AppLogo renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppLogo(width: 100, height: 100),
          ),
        ),
      );

      expect(find.byType(AppLogo), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('OfflineBanner renders wrapped child correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: OfflineBanner(
                child: Text('Content'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Content'), findsOneWidget);
    });
  });
}
