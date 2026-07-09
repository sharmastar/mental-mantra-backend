import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/meditation_session.dart';
import '../../data/repositories/meditation_repository.dart';

final meditationRepositoryProvider = Provider<MeditationRepository>((ref) => MeditationRepository());

class MeditationState {
  final List<MeditationCategory> categories;
  final List<MeditationSession> sessions;
  final MeditationSession? currentSession;
  final bool isPlaying;
  final bool isLoading;
  final String? error;
  final Duration position;
  final Duration totalDuration;
  final String searchQuery;
  final bool isFavoriteOnly;

  const MeditationState({
    this.categories = const [],
    this.sessions = const [],
    this.currentSession,
    this.isPlaying = false,
    this.isLoading = false,
    this.error,
    this.position = Duration.zero,
    this.totalDuration = Duration.zero,
    this.searchQuery = '',
    this.isFavoriteOnly = false,
  });

  MeditationState copyWith({
    List<MeditationCategory>? categories,
    List<MeditationSession>? sessions,
    MeditationSession? currentSession,
    bool? isPlaying,
    bool? isLoading,
    String? error,
    Duration? position,
    Duration? totalDuration,
    String? searchQuery,
    bool? isFavoriteOnly,
    bool clearError = false,
    bool clearCurrentSession = false,
  }) {
    return MeditationState(
      categories: categories ?? this.categories,
      sessions: sessions ?? this.sessions,
      currentSession: clearCurrentSession ? null : (currentSession ?? this.currentSession),
      isPlaying: isPlaying ?? this.isPlaying,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      position: position ?? this.position,
      totalDuration: totalDuration ?? this.totalDuration,
      searchQuery: searchQuery ?? this.searchQuery,
      isFavoriteOnly: isFavoriteOnly ?? this.isFavoriteOnly,
    );
  }

  List<MeditationSession> get filteredSessions {
    var result = sessions;
    if (searchQuery.isNotEmpty) {
      result = result.where((s) =>
        s.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
        s.description.toLowerCase().contains(searchQuery.toLowerCase()) ||
        s.tags.any((t) => t.toLowerCase().contains(searchQuery.toLowerCase()))
      ).toList();
    }
    if (isFavoriteOnly) {
      result = result.where((s) => s.isFavorite).toList();
    }
    return result;
  }
}

class MeditationNotifier extends StateNotifier<MeditationState> {
  final MeditationRepository _repository;

  MeditationNotifier(this._repository) : super(const MeditationState());

  Future<void> loadSessions() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final categories = await _repository.getCategories();
      final sessions = await _repository.getSessions();
      state = state.copyWith(
        categories: categories,
        sessions: sessions,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to load meditations');
    }
  }

  void playSession(MeditationSession session) {
    state = state.copyWith(
      currentSession: session,
      isPlaying: true,
      position: Duration.zero,
      totalDuration: Duration(seconds: session.durationSeconds),
    );
  }

  void togglePlayPause() {
    state = state.copyWith(isPlaying: !state.isPlaying);
  }

  void seekTo(Duration position) {
    state = state.copyWith(position: position);
  }

  void stopPlayback() {
    state = state.copyWith(
      clearCurrentSession: true,
      isPlaying: false,
      position: Duration.zero,
    );
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void toggleFavoriteFilter() {
    state = state.copyWith(isFavoriteOnly: !state.isFavoriteOnly);
  }

  Future<void> toggleFavorite(String sessionId) async {
    final current = state.sessions.firstWhere((s) => s.id == sessionId);
    final newValue = !current.isFavorite;
    state = state.copyWith(
      sessions: state.sessions.map((s) {
        if (s.id == sessionId) return s.copyWith(isFavorite: newValue);
        return s;
      }).toList(),
    );
    try {
      await _repository.toggleFavorite(sessionId, newValue);
    } catch (_) {}
  }

  Future<void> markCompleted() async {
    final session = state.currentSession;
    if (session == null) return;
    try {
      await _repository.markCompleted(session.id);
    } catch (_) {}
  }

  void clearError() => state = state.copyWith(clearError: true);

  List<MeditationSession> get sessions => state.sessions;
}

final meditationProvider = StateNotifierProvider<MeditationNotifier, MeditationState>((ref) {
  final repository = ref.watch(meditationRepositoryProvider);
  return MeditationNotifier(repository);
});
