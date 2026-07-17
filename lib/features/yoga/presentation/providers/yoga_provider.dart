import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/yoga_class.dart';
import '../../data/repositories/yoga_repository.dart';

final yogaRepositoryProvider =
    Provider<YogaRepository>((ref) => YogaRepository());

class YogaState {
  final List<YogaClass> classes;
  final YogaClass? currentSession;
  final bool isLoading;
  final String? error;
  final String searchQuery;
  final YogaLevel? filterLevel;

  const YogaState({
    this.classes = const [],
    this.currentSession,
    this.isLoading = false,
    this.error,
    this.searchQuery = '',
    this.filterLevel,
  });

  YogaState copyWith({
    List<YogaClass>? classes,
    YogaClass? currentSession,
    bool? isLoading,
    String? error,
    String? searchQuery,
    YogaLevel? filterLevel,
    bool clearError = false,
    bool clearCurrentSession = false,
  }) =>
      YogaState(
        classes: classes ?? this.classes,
        currentSession: clearCurrentSession
            ? null
            : (currentSession ?? this.currentSession),
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : (error ?? this.error),
        searchQuery: searchQuery ?? this.searchQuery,
        filterLevel: filterLevel ?? this.filterLevel,
      );

  List<YogaClass> get filteredClasses {
    var result = classes;
    if (searchQuery.isNotEmpty) {
      result = result
          .where((c) =>
              c.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
              c.description.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();
    }
    if (filterLevel != null) {
      result = result.where((c) => c.level == filterLevel).toList();
    }
    return result;
  }
}

class YogaNotifier extends StateNotifier<YogaState> {
  final YogaRepository _repository;

  YogaNotifier(this._repository) : super(const YogaState());

  Future<void> loadClasses() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final classes = await _repository.getClasses();
      state = state.copyWith(classes: classes, isLoading: false);
    } catch (e) {
      state = state.copyWith(
          isLoading: false, error: 'Failed to load yoga classes');
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setFilterLevel(YogaLevel? level) {
    state = state.copyWith(filterLevel: level);
  }

  void startSession(YogaClass yogaClass) {
    state = state.copyWith(currentSession: yogaClass);
  }

  void clearSession() {
    state = state.copyWith(clearCurrentSession: true);
  }

  Future<void> toggleFavorite(String classId) async {
    final current = state.classes.firstWhere((c) => c.id == classId);
    final newValue = !current.isFavorite;
    state = state.copyWith(
      classes: state.classes.map((c) {
        if (c.id == classId) return c.copyWith(isFavorite: newValue);
        return c;
      }).toList(),
    );
    try {
      await _repository.toggleFavorite(classId, newValue);
    } catch (e) {
      debugPrint('YogaNotifier.toggleFavorite: $e');
    }
  }

  void clearError() => state = state.copyWith(clearError: true);

  List<YogaClass> get classes => state.classes;
}

final yogaProvider = StateNotifierProvider<YogaNotifier, YogaState>((ref) {
  final repository = ref.watch(yogaRepositoryProvider);
  return YogaNotifier(repository);
});
