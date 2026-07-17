import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/journal_entry.dart';
import '../../data/repositories/journal_repository.dart';

final journalRepositoryProvider =
    Provider<JournalRepository>((ref) => JournalRepository());

final journalListProvider =
    FutureProvider.family<List<JournalEntry>, String>((ref, userId) async {
  final repo = ref.watch(journalRepositoryProvider);
  return repo.getEntries();
});

final journalStatsProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, userId) async {
  final repo = ref.watch(journalRepositoryProvider);
  return repo.getStats();
});

final journalFilterProvider =
    StateProvider<JournalFilter>((ref) => const JournalFilter());

class JournalEntryNotifier extends StateNotifier<AsyncValue<JournalEntry?>> {
  final JournalRepository _repo;

  JournalEntryNotifier(this._repo) : super(const AsyncValue.data(null));

  Future<void> loadEntry(String entryId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repo.getEntry(entryId));
  }

  Future<String?> createEntry(JournalEntry entry) async {
    final id = await _repo.createEntry(entry);
    return id;
  }

  Future<void> updateEntry(String entryId, Map<String, dynamic> updates) async {
    await _repo.updateEntry(entryId, updates);
  }

  Future<void> deleteEntry(String entryId) async {
    await _repo.deleteEntry(entryId);
  }

  Future<void> saveAiAnalysis(
      String entryId, Map<String, dynamic> analysis) async {
    await _repo.saveAiAnalysis(entryId, analysis);
  }
}

final journalEntryProvider = StateNotifierProvider.family<JournalEntryNotifier,
    AsyncValue<JournalEntry?>, String>((ref, entryId) {
  final repo = ref.watch(journalRepositoryProvider);
  final notifier = JournalEntryNotifier(repo);
  if (entryId.isNotEmpty) notifier.loadEntry(entryId);
  return notifier;
});
