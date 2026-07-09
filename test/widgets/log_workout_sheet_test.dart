import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mental_mantra/features/fitness/presentation/widgets/log_workout_sheet.dart';

void main() {
  testWidgets('LogWorkoutSheet renders workout type chips', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: LogWorkoutSheet(),
          ),
        ),
      ),
    );
    expect(find.text('Walking'), findsOneWidget);
    expect(find.text('Running'), findsOneWidget);
    expect(find.text('Cycling'), findsOneWidget);
    expect(find.text('Yoga'), findsOneWidget);
    expect(find.text('Strength'), findsOneWidget);
    expect(find.text('Save Workout'), findsOneWidget);
  });

  testWidgets('LogWorkoutSheet has duration and calories fields', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: LogWorkoutSheet(),
          ),
        ),
      ),
    );
    expect(find.text('Duration (min)'), findsOneWidget);
    expect(find.text('Calories'), findsOneWidget);
  });
}
