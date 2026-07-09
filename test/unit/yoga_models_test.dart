import 'package:flutter_test/flutter_test.dart';
import 'package:mental_mantra/features/yoga/data/models/yoga_class.dart';

void main() {
  group('YogaPose', () {
    test('fromJson and toJson round-trip', () {
      const original = YogaPose(
        id: 'p1',
        name: 'Downward Dog',
        sanskritName: 'Adho Mukha Svanasana',
        description: 'An inverted V-shape pose',
        difficultyRating: 2,
        benefits: ['Strengthens arms', 'Stretches hamstrings'],
        durationSeconds: 30,
      );
      final json = original.toJson();
      final restored = YogaPose.fromJson(json);
      expect(restored.id, 'p1');
      expect(restored.name, 'Downward Dog');
      expect(restored.difficultyRating, 2);
      expect(restored.benefits.length, 2);
    });
  });

  group('YogaClass', () {
    test('fromJson and toJson round-trip', () {
      const original = YogaClass(
        id: 'y1',
        title: 'Morning Flow',
        description: 'Energizing morning yoga',
        level: YogaLevel.beginner,
        style: YogaStyle.vinyasa,
        durationMinutes: 30,
        poses: [
          YogaPose(id: 'p1', name: 'Mountain', description: 'Standing pose'),
          YogaPose(id: 'p2', name: 'Forward Fold', description: 'Bending pose'),
        ],
        instructor: 'Sarah',
      );
      final json = original.toJson();
      final restored = YogaClass.fromJson(json);
      expect(restored.id, 'y1');
      expect(restored.title, 'Morning Flow');
      expect(restored.level, YogaLevel.beginner);
      expect(restored.style, YogaStyle.vinyasa);
      expect(restored.poses.length, 2);
      expect(restored.instructor, 'Sarah');
    });

    test('copyWith updates only specified fields', () {
      const original = YogaClass(id: 'y1', title: 'Morning Flow', description: 'Energizing flow');
      final copy = original.copyWith(title: 'Evening Flow', durationMinutes: 45);
      expect(copy.title, 'Evening Flow');
      expect(copy.durationMinutes, 45);
      expect(copy.description, original.description);
      expect(copy.id, original.id);
    });

    test('copyWith toggles isFavorite', () {
      const original = YogaClass(id: 'y1', title: 'Test', description: 'Test');
      expect(original.isFavorite, false);
      final toggled = original.copyWith(isFavorite: true);
      expect(toggled.isFavorite, true);
    });

    test('durationLabel returns formatted string', () {
      const c = YogaClass(id: 'y1', title: 'Test', description: 'Test', durationMinutes: 45);
      expect(c.durationLabel, '45 min');
    });
  });
}
