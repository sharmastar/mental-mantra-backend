import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/assessment_question.dart';
import '../../data/assessment_data.dart';
import '../../data/recommendation_engine.dart';
import '../../../../services/ai/ai_coach_service.dart';
import '../../../../core/storage/hive_storage.dart';
import '../../../../core/utils/debouncer.dart';
import '../../../auth/providers/auth_provider.dart';

class AssessmentState {
  final int currentStep;
  final AssessmentAnswers answers;
  final bool consentAccepted;
  final String nickname;
  final String ageGroup;
  final String gender;
  final String country;
  final String occupation;
  final String relationshipStatus;
  final String livingSituation;
  final List<AssessmentResponse> responses;
  final Map<String, dynamic>? profile;
  final bool isLoading;
  final bool isSaving;
  final String? error;
  final bool isComplete;

  const AssessmentState({
    this.currentStep = 0,
    this.answers = const AssessmentAnswers(),
    this.consentAccepted = false,
    this.nickname = '',
    this.ageGroup = '',
    this.gender = '',
    this.country = '',
    this.occupation = '',
    this.relationshipStatus = '',
    this.livingSituation = '',
    this.responses = const [],
    this.profile,
    this.isLoading = false,
    this.isSaving = false,
    this.error,
    this.isComplete = false,
  });

  AssessmentState copyWith({
    int? currentStep,
    AssessmentAnswers? answers,
    bool? consentAccepted,
    String? nickname,
    String? ageGroup,
    String? gender,
    String? country,
    String? occupation,
    String? relationshipStatus,
    String? livingSituation,
    List<AssessmentResponse>? responses,
    Map<String, dynamic>? profile,
    bool? isLoading,
    bool? isSaving,
    String? error,
    bool? isComplete,
    bool clearError = false,
  }) {
    return AssessmentState(
      currentStep: currentStep ?? this.currentStep,
      answers: answers ?? this.answers,
      consentAccepted: consentAccepted ?? this.consentAccepted,
      nickname: nickname ?? this.nickname,
      ageGroup: ageGroup ?? this.ageGroup,
      gender: gender ?? this.gender,
      country: country ?? this.country,
      occupation: occupation ?? this.occupation,
      relationshipStatus: relationshipStatus ?? this.relationshipStatus,
      livingSituation: livingSituation ?? this.livingSituation,
      responses: responses ?? this.responses,
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      error: clearError ? null : (error ?? this.error),
      isComplete: isComplete ?? this.isComplete,
    );
  }
}

class AssessmentNotifier extends StateNotifier<AssessmentState> {
  final AiCoachService _aiService = AiCoachService();
  final Debouncer _saveDebouncer =
      Debouncer(delay: const Duration(milliseconds: 800));
  final Set<String> _injectedAdaptiveIds = {};
  List<AssessmentQuestion> _visibleQuestions =
      List.from(AssessmentData.questions);

  AssessmentNotifier() : super(const AssessmentState());

  void setConsentAccepted(bool val) {
    state = state.copyWith(consentAccepted: val);
    _scheduleSave();
  }

  void setNickname(String val) {
    state = state.copyWith(nickname: val);
    _scheduleSave();
  }

  void setAgeGroup(String val) {
    state = state.copyWith(ageGroup: val);
    _scheduleSave();
  }

  void setGender(String val) {
    state = state.copyWith(gender: val);
    _scheduleSave();
  }

  void setCountry(String val) {
    state = state.copyWith(country: val);
    _scheduleSave();
  }

  void setOccupation(String val) {
    state = state.copyWith(occupation: val);
    _scheduleSave();
  }

  void setRelationshipStatus(String val) {
    state = state.copyWith(relationshipStatus: val);
    _scheduleSave();
  }

  void setLivingSituation(String val) {
    state = state.copyWith(livingSituation: val);
    _scheduleSave();
  }

  void setCurrentStep(int step) {
    state = state.copyWith(currentStep: step);
    _scheduleSave();
  }

  void selectOption(String questionId, dynamic value) {
    final newAnswers = Map<String, dynamic>.from(state.answers.toJson());
    newAnswers[questionId] = value;
    state = state.copyWith(answers: AssessmentAnswers(newAnswers));
    _scheduleSave();
  }

  void toggleOption(String questionId, String value) {
    final newAnswers = Map<String, dynamic>.from(state.answers.toJson());
    final currentList = List<String>.from(newAnswers[questionId] ?? []);
    if (currentList.contains(value)) {
      currentList.remove(value);
    } else {
      currentList.add(value);
    }
    newAnswers[questionId] = currentList;
    state = state.copyWith(answers: AssessmentAnswers(newAnswers));
    _scheduleSave();
  }

  void goNext() {
    if (state.currentStep >= 1) {
      final answers = state.answers.toJson();
      final newIds = AssessmentData.getAdaptiveFollowUps(answers)
          .where((id) => !_injectedAdaptiveIds.contains(id))
          .toList();
      if (newIds.isNotEmpty) {
        final insertPos = state.currentStep;
        var offset = 0;
        for (final id in newIds) {
          _injectedAdaptiveIds.add(id);
          final q = AssessmentData.getAdaptiveQuestion(id);
          if (q != null) {
            _visibleQuestions.insert(insertPos + offset, q);
            offset++;
          }
        }
      }
    }
    state = state.copyWith(currentStep: state.currentStep + 1);
  }

  void goPrevious() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  void skipQuestion() {
    final q = currentQuestion;
    if (q.id.isNotEmpty) {
      final newAnswers = Map<String, dynamic>.from(state.answers.toJson());
      newAnswers.remove(q.id);
      state = state.copyWith(
        answers: AssessmentAnswers(newAnswers),
        currentStep: state.currentStep + 1,
      );
    } else {
      state = state.copyWith(currentStep: state.currentStep + 1);
    }
    _scheduleSave();
  }

  void setSaving(bool val) {
    state = state.copyWith(isSaving: val, error: val ? null : state.error);
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  void _scheduleSave() {
    _saveDebouncer.call(_doSave);
  }

  Future<void> _doSave() async {
    try {
      await HiveStorage.saveOnboardingData({
        'currentStep': state.currentStep,
        'nickname': state.nickname,
        'ageGroup': state.ageGroup,
        'gender': state.gender,
        'country': state.country,
        'occupation': state.occupation,
        'relationshipStatus': state.relationshipStatus,
        'livingSituation': state.livingSituation,
        'answers': state.answers.toJson(),
        'consentAccepted': state.consentAccepted,
      });
    } catch (e) {
      debugPrint('AssessmentNotifier.saveProgress: $e');
    }
  }

  Future<void> restoreSavedProgress() async {
    _injectedAdaptiveIds.clear();
    _visibleQuestions = List.from(AssessmentData.questions);
    try {
      final saved = await HiveStorage.getOnboardingData();
      if (saved.isNotEmpty) {
        final restoredStep = saved['currentStep'] as int? ?? 0;
        state = state.copyWith(
          currentStep: restoredStep,
          nickname: saved['nickname'] as String? ?? '',
          ageGroup: saved['ageGroup'] as String? ?? '',
          gender: saved['gender'] as String? ?? '',
          country: saved['country'] as String? ?? '',
          occupation: saved['occupation'] as String? ?? '',
          relationshipStatus: saved['relationshipStatus'] as String? ?? '',
          livingSituation: saved['livingSituation'] as String? ?? '',
          consentAccepted: saved['consentAccepted'] as bool? ?? false,
          answers: AssessmentAnswers(
              Map<String, dynamic>.from(saved['answers'] as Map? ?? {})),
        );
        if (restoredStep > 0) {
          setConsentAccepted(true);
        }
      }
    } catch (e) {
      debugPrint('AssessmentNotifier.restoreSavedProgress: $e');
    }
  }

  Future<WellnessResult> generateResult() async {
    final engine = RecommendationEngine();
    return engine.generate(state.answers);
  }

  bool get canGoNext => validationError == null;

  String? get validationError {
    final step = state.currentStep;
    if (step == 0) {
      return state.consentAccepted
          ? null
          : 'Please accept the consent agreement to proceed.';
    }

    final q = currentQuestion;
    if (q.id.isEmpty) return null;

    if (q.id == 'nickname') {
      final val = state.answers.getSingle('nickname') ?? state.nickname;
      if (val.trim().isEmpty) return 'Please enter your name or nickname.';
      if (val.trim().length < 2) {
        return 'Nickname must be at least 2 characters.';
      }
      return null;
    }

    if (q.isOptional) return null;
    if (!state.answers.hasAnswer(q.id)) {
      return 'Please provide an answer to proceed.';
    }
    return null;
  }

  List<AssessmentQuestion> get visibleQuestions => _visibleQuestions;

  AssessmentQuestion get currentQuestion {
    final qIndex = state.currentStep - 1;
    if (qIndex >= 0 && qIndex < _visibleQuestions.length) {
      return _visibleQuestions[qIndex];
    }
    return const AssessmentQuestion(id: '', question: '', type: '');
  }

  void addResponse(AssessmentResponse response) {
    state = state.copyWith(responses: [...state.responses, response]);
  }

  Future<void> calculateProfile() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final responses = state.answers.toJson().entries.map((entry) {
        final q = _visibleQuestions.firstWhere(
          (q) => q.id == entry.key,
          orElse: () =>
              AssessmentQuestion(id: entry.key, question: entry.key, type: ''),
        );
        return AssessmentResponse(
          questionId: entry.key,
          question: q.question,
          type: q.type,
          answer: entry.value,
        );
      }).toList();
      final profile = await _aiService.calculateWellnessProfile(responses);
      state =
          state.copyWith(profile: profile, isLoading: false, isComplete: true);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to analyze responses. Please try again.',
      );
    }
  }

  void reset() {
    _saveDebouncer.cancel();
    _injectedAdaptiveIds.clear();
    _visibleQuestions = List.from(AssessmentData.questions);
    state = const AssessmentState();
  }
}

final assessmentProvider =
    StateNotifierProvider<AssessmentNotifier, AssessmentState>((ref) {
  return AssessmentNotifier();
});

final activeQuestionsProvider = Provider<List<AssessmentQuestion>>((ref) {
  final notifier = ref.watch(assessmentProvider.notifier);
  return notifier.visibleQuestions;
});

final wellnessResultProvider = Provider<WellnessResult?>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null || !user.onboardingCompleted) return null;
  try {
    final data = HiveStorage.cacheBox!.get('wellness_result');
    if (data != null) {
      return WellnessResult.fromJson(Map<String, dynamic>.from(data));
    }
  } catch (e) {
    debugPrint('wellnessResultProvider: $e');
  }
  return null;
});
