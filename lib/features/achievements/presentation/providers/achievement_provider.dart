import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../data/repositories/achievement_repository.dart';
import '../../data/models/achievement.dart';

final achievementRepositoryProvider =
    Provider<AchievementRepository>((ref) => AchievementRepository());

final achievementsProvider = FutureProvider<List<Achievement>>((ref) async {
  final repo = ref.watch(achievementRepositoryProvider);
  return repo.getAllAchievements();
});

final userAchievementsProvider =
    FutureProvider<List<UserAchievement>>((ref) async {
  final userId = ref.watch(currentUserProvider.select((u) => u?.uid ?? ''));
  if (userId.isEmpty) return [];
  final repo = ref.watch(achievementRepositoryProvider);
  return repo.getUserAchievements(userId);
});

final streakProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final userId = ref.watch(currentUserProvider.select((u) => u?.uid ?? ''));
  if (userId.isEmpty) return {'currentDays': 0, 'longestDays': 0};
  final repo = ref.watch(achievementRepositoryProvider);
  return repo.getStreak(userId);
});
