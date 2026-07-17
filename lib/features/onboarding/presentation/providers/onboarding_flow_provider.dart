import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/onboarding_schema.dart';
import '../../data/classification_engine.dart';

// ── Onboarding Step Definitions ────────────────────────────
enum OnboardingSection {
  consent(0, 'Welcome'),
  nickname(1, 'About You'),
  ageRange(2, 'About You'),
  gender(3, 'About You'),
  country(4, 'About You'),
  relationshipStatus(5, 'About You'),
  livingWith(6, 'About You'),
  reasonsJoined(7, 'Why Are You Here?'),
  duration(8, 'Your Journey'),
  affectedAreas(9, 'What\'s Affected?'),
  feelingOverwhelmed(10, 'How Have You Been Feeling?'),
  nervousAnxious(11, 'How Have You Been Feeling?'),
  difficultyConcentrating(12, 'How Have You Been Feeling?'),
  lossOfInterest(13, 'How Have You Been Feeling?'),
  irritableAngry(14, 'How Have You Been Feeling?'),
  lowEnergy(15, 'How Have You Been Feeling?'),
  restless(16, 'How Have You Been Feeling?'),
  hopeless(17, 'How Have You Been Feeling?'),
  physicalTension(18, 'How Have You Been Feeling?'),
  avoidingPeople(19, 'How Have You Been Feeling?'),
  intrusiveThoughts(20, 'How Have You Been Feeling?'),
  emotionalNumbness(21, 'How Have You Been Feeling?'),
  sleepHours(22, 'Sleep & Energy'),
  sleepQuality(23, 'Sleep & Energy'),
  sleepLatency(24, 'Sleep & Energy'),
  nightWakeups(25, 'Sleep & Energy'),
  morningEnergy(26, 'Sleep & Energy'),
  mentalFatigue(27, 'Sleep & Energy'),
  nightScreenUse(28, 'Sleep & Energy'),
  physicalActivity(29, 'Daily Life'),
  offlineTime(30, 'Daily Life'),
  emotionalSupport(31, 'Daily Life'),
  screenTime(32, 'Daily Life'),
  workLifeBalance(33, 'Daily Life'),
  mealRoutine(34, 'Daily Life'),
  hydration(35, 'Daily Life'),
  addictions(36, 'Habits'),
  addictionSeverity(37, 'Habits'),
  attemptedQuitting(38, 'Habits'),
  eatingHabits(39, 'Body & Nutrition'),
  appetiteChanges(40, 'Body & Nutrition'),
  bodyImageConcerns(41, 'Body & Nutrition'),
  copingMechanisms(42, 'How You Cope'),
  selfHarmIdeation(43, 'How You Cope'),
  emotionallySafe(44, 'How You Cope'),
  spiritualOrReligious(45, 'Spiritual & Meaning'),
  meaningAndPurpose(46, 'Spiritual & Meaning'),
  goals(47, 'Your Goals'),
  preferredSupport(48, 'Your Goals'),
  commitmentLevel(49, 'Your Goals'),
  preferredTimeOfDay(50, 'Your Goals'),
  complete(51, '');

  final int step;
  final String sectionLabel;
  const OnboardingSection(this.step, this.sectionLabel);

  bool get isSymptomQuestion => step >= 10 && step <= 21;

  String get symptomId {
    if (!isSymptomQuestion) return '';
    const symptoms = [
      'feeling_overwhelmed',
      'nervous_anxious',
      'difficulty_concentrating',
      'loss_of_interest',
      'irritable_angry',
      'low_energy',
      'restless',
      'hopeless',
      'physical_tension',
      'avoiding_people',
      'intrusive_thoughts',
      'emotional_numbness',
    ];
    return symptoms[step - 10];
  }
}

// ── State ──────────────────────────────────────────────────
class OnboardingFlowState {
  final OnboardingSection currentSection;
  final OnboardingData data;
  final bool isComplete;
  final bool isLoading;
  final bool isSaving;
  final String? error;
  final ClassificationResult? classification;
  final bool showReinforcement;

  const OnboardingFlowState({
    this.currentSection = OnboardingSection.consent,
    this.data = const OnboardingData(),
    this.isComplete = false,
    this.isLoading = false,
    this.isSaving = false,
    this.error,
    this.classification,
    this.showReinforcement = false,
  });

  OnboardingFlowState copyWith({
    OnboardingSection? currentSection,
    OnboardingData? data,
    bool? isComplete,
    bool? isLoading,
    bool? isSaving,
    String? error,
    ClassificationResult? classification,
    bool? showReinforcement,
  }) =>
      OnboardingFlowState(
        currentSection: currentSection ?? this.currentSection,
        data: data ?? this.data,
        isComplete: isComplete ?? this.isComplete,
        isLoading: isLoading ?? this.isLoading,
        isSaving: isSaving ?? this.isSaving,
        error: error,
        classification: classification ?? this.classification,
        showReinforcement: showReinforcement ?? this.showReinforcement,
      );

  int get totalSteps => OnboardingSection.complete.step;
  double get progress => currentSection.step / totalSteps;
  bool get isFirstStep => currentSection == OnboardingSection.consent;
  bool get isLastStep => currentSection == OnboardingSection.complete;
  bool get canGoNext {
    if (currentSection == OnboardingSection.complete) return true;
    return _isCurrentStepAnswered;
  }

  bool get _isCurrentStepAnswered {
    switch (currentSection) {
      case OnboardingSection.consent:
        return data.consent.consentAccepted;
      case OnboardingSection.nickname:
        return data.basicInfo.nickname.isNotEmpty;
      case OnboardingSection.ageRange:
        return true;
      case OnboardingSection.gender:
        return true;
      case OnboardingSection.country:
        return data.basicInfo.country.isNotEmpty;
      case OnboardingSection.relationshipStatus:
        return true;
      case OnboardingSection.livingWith:
        return true;
      case OnboardingSection.reasonsJoined:
        return data.needs.reasonsJoined.isNotEmpty;
      case OnboardingSection.duration:
        return data.needs.duration.isNotEmpty;
      case OnboardingSection.affectedAreas:
        return data.needs.affectedAreas.isNotEmpty;
      case OnboardingSection.feelingOverwhelmed:
      case OnboardingSection.nervousAnxious:
      case OnboardingSection.difficultyConcentrating:
      case OnboardingSection.lossOfInterest:
      case OnboardingSection.irritableAngry:
      case OnboardingSection.lowEnergy:
      case OnboardingSection.restless:
      case OnboardingSection.hopeless:
      case OnboardingSection.physicalTension:
      case OnboardingSection.avoidingPeople:
      case OnboardingSection.intrusiveThoughts:
      case OnboardingSection.emotionalNumbness:
        return data.emotionalCheckin.symptoms[currentSection.symptomId] != null;
      case OnboardingSection.sleepHours:
        return data.sleepEnergy.sleepHours.isNotEmpty;
      case OnboardingSection.sleepQuality:
        return data.sleepEnergy.sleepQuality.isNotEmpty;
      case OnboardingSection.sleepLatency:
        return data.sleepEnergy.sleepLatency.isNotEmpty;
      case OnboardingSection.nightWakeups:
        return data.sleepEnergy.nightWakeups.isNotEmpty;
      case OnboardingSection.morningEnergy:
        return data.sleepEnergy.morningEnergy.isNotEmpty;
      case OnboardingSection.mentalFatigue:
        return data.sleepEnergy.mentalFatigue.isNotEmpty;
      case OnboardingSection.nightScreenUse:
        return true;
      case OnboardingSection.physicalActivity:
        return data.lifestyle.physicalActivity.isNotEmpty;
      case OnboardingSection.offlineTime:
        return data.lifestyle.offlineTime.isNotEmpty;
      case OnboardingSection.emotionalSupport:
        return data.lifestyle.emotionalSupport.isNotEmpty;
      case OnboardingSection.screenTime:
        return data.lifestyle.screenTime.isNotEmpty;
      case OnboardingSection.workLifeBalance:
        return data.lifestyle.workLifeBalance.isNotEmpty;
      case OnboardingSection.mealRoutine:
        return data.lifestyle.mealRoutine.isNotEmpty;
      case OnboardingSection.hydration:
        return data.lifestyle.hydration.isNotEmpty;
      case OnboardingSection.addictions:
        return data.habits.addictions.isNotEmpty;
      case OnboardingSection.addictionSeverity:
        return data.habits.addictionSeverity.isNotEmpty;
      case OnboardingSection.attemptedQuitting:
        return true;
      case OnboardingSection.eatingHabits:
        return data.body.eatingHabits.isNotEmpty;
      case OnboardingSection.appetiteChanges:
        return data.body.appetiteChanges.isNotEmpty;
      case OnboardingSection.bodyImageConcerns:
        return data.body.bodyImageConcerns.isNotEmpty;
      case OnboardingSection.copingMechanisms:
        return data.coping.copingMechanisms.isNotEmpty;
      case OnboardingSection.selfHarmIdeation:
        return data.coping.selfHarmIdeation.isNotEmpty;
      case OnboardingSection.emotionallySafe:
        return true;
      case OnboardingSection.spiritualOrReligious:
        return true;
      case OnboardingSection.meaningAndPurpose:
        return data.spiritual.meaningAndPurpose.isNotEmpty;
      case OnboardingSection.goals:
        return data.goals.goals.isNotEmpty;
      case OnboardingSection.preferredSupport:
        return data.goals.preferredSupport.isNotEmpty;
      case OnboardingSection.commitmentLevel:
        return data.goals.commitmentLevel.isNotEmpty;
      case OnboardingSection.preferredTimeOfDay:
        return data.goals.preferredTimeOfDay.isNotEmpty;
      case OnboardingSection.complete:
        return true;
    }
  }
}

// ── Provider ───────────────────────────────────────────────
class OnboardingFlowNotifier extends StateNotifier<OnboardingFlowState> {
  bool _disposed = false;

  OnboardingFlowNotifier() : super(const OnboardingFlowState());

  void goNext() {
    if (state.currentSection == OnboardingSection.complete) return;
    if (!state.canGoNext) return;

    const sections = OnboardingSection.values;
    final currentIdx = sections.indexOf(state.currentSection);
    if (currentIdx < sections.length - 1) {
      state = state.copyWith(
        currentSection: sections[currentIdx + 1],
        showReinforcement: true,
        error: null,
      );
      _clearReinforcementAfterDelay();
    }
  }

  void goPrevious() {
    if (state.currentSection == OnboardingSection.consent) return;
    const sections = OnboardingSection.values;
    final currentIdx = sections.indexOf(state.currentSection);
    if (currentIdx > 0) {
      state = state.copyWith(
        currentSection: sections[currentIdx - 1],
        error: null,
      );
    }
  }

  void skipCurrent() {
    if (!_isCurrentOptional) return;
    goNext();
  }

  bool get _isCurrentOptional {
    switch (state.currentSection) {
      case OnboardingSection.nickname:
      case OnboardingSection.spiritualOrReligious:
      case OnboardingSection.attemptedQuitting:
      case OnboardingSection.emotionallySafe:
        return true;
      default:
        return false;
    }
  }

  void _clearReinforcementAfterDelay() {
    Future.delayed(const Duration(seconds: 2), () {
      if (!_disposed) {
        state = state.copyWith(showReinforcement: false);
      }
    });
  }

  // ── Data setters ────────────────────────────────────────

  void setConsentAccepted(bool value) {
    state = state.copyWith(
      data: state.data.copyWith(
        consent: ConsentSection(
          consentAccepted: value,
          consentDate: value ? DateTime.now() : null,
        ),
      ),
    );
  }

  void setNickname(String value) {
    state = state.copyWith(
      data: state.data.copyWith(
        basicInfo: state.data.basicInfo.copyWith(nickname: value),
      ),
    );
  }

  void setAgeRange(AgeRange value) {
    state = state.copyWith(
      data: state.data.copyWith(
        basicInfo: state.data.basicInfo.copyWith(ageRange: value),
      ),
    );
  }

  void setGender(Gender value) {
    state = state.copyWith(
      data: state.data.copyWith(
        basicInfo: state.data.basicInfo.copyWith(gender: value),
      ),
    );
  }

  void setCountry(String value) {
    state = state.copyWith(
      data: state.data.copyWith(
        basicInfo: state.data.basicInfo.copyWith(country: value),
      ),
    );
  }

  void setRelationshipStatus(RelationshipStatus value) {
    state = state.copyWith(
      data: state.data.copyWith(
        basicInfo: state.data.basicInfo.copyWith(relationshipStatus: value),
      ),
    );
  }

  void setLivingWith(LivingSituation value) {
    state = state.copyWith(
      data: state.data.copyWith(
        basicInfo: state.data.basicInfo.copyWith(livingWith: value),
      ),
    );
  }

  void setReasonsJoined(List<String> value) {
    state = state.copyWith(
      data: state.data.copyWith(
        needs: state.data.needs.copyWith(reasonsJoined: value),
      ),
    );
  }

  void setDuration(String value) {
    state = state.copyWith(
      data: state.data.copyWith(
        needs: state.data.needs.copyWith(duration: value),
      ),
    );
  }

  void setAffectedAreas(List<String> value) {
    state = state.copyWith(
      data: state.data.copyWith(
        needs: state.data.needs.copyWith(affectedAreas: value),
      ),
    );
  }

  void setSymptom(String symptomId, String frequency) {
    final updated =
        Map<String, String>.from(state.data.emotionalCheckin.symptoms)
          ..[symptomId] = frequency;
    state = state.copyWith(
      data: state.data.copyWith(
        emotionalCheckin:
            state.data.emotionalCheckin.copyWith(symptoms: updated),
      ),
    );
  }

  void setSleepHours(String value) {
    state = state.copyWith(
      data: state.data.copyWith(
        sleepEnergy: state.data.sleepEnergy.copyWith(sleepHours: value),
      ),
    );
  }

  void setSleepQuality(String value) {
    state = state.copyWith(
      data: state.data.copyWith(
        sleepEnergy: state.data.sleepEnergy.copyWith(sleepQuality: value),
      ),
    );
  }

  void setSleepLatency(String value) {
    state = state.copyWith(
      data: state.data.copyWith(
        sleepEnergy: state.data.sleepEnergy.copyWith(sleepLatency: value),
      ),
    );
  }

  void setNightWakeups(String value) {
    state = state.copyWith(
      data: state.data.copyWith(
        sleepEnergy: state.data.sleepEnergy.copyWith(nightWakeups: value),
      ),
    );
  }

  void setMorningEnergy(String value) {
    state = state.copyWith(
      data: state.data.copyWith(
        sleepEnergy: state.data.sleepEnergy.copyWith(morningEnergy: value),
      ),
    );
  }

  void setMentalFatigue(String value) {
    state = state.copyWith(
      data: state.data.copyWith(
        sleepEnergy: state.data.sleepEnergy.copyWith(mentalFatigue: value),
      ),
    );
  }

  void setNightScreenUse(bool value) {
    state = state.copyWith(
      data: state.data.copyWith(
        sleepEnergy: state.data.sleepEnergy.copyWith(nightScreenUse: value),
      ),
    );
  }

  void setPhysicalActivity(String value) {
    state = state.copyWith(
      data: state.data.copyWith(
        lifestyle: state.data.lifestyle.copyWith(physicalActivity: value),
      ),
    );
  }

  void setOfflineTime(String value) {
    state = state.copyWith(
      data: state.data.copyWith(
        lifestyle: state.data.lifestyle.copyWith(offlineTime: value),
      ),
    );
  }

  void setEmotionalSupport(String value) {
    state = state.copyWith(
      data: state.data.copyWith(
        lifestyle: state.data.lifestyle.copyWith(emotionalSupport: value),
      ),
    );
  }

  void setScreenTime(String value) {
    state = state.copyWith(
      data: state.data.copyWith(
        lifestyle: state.data.lifestyle.copyWith(screenTime: value),
      ),
    );
  }

  void setWorkLifeBalance(String value) {
    state = state.copyWith(
      data: state.data.copyWith(
        lifestyle: state.data.lifestyle.copyWith(workLifeBalance: value),
      ),
    );
  }

  void setMealRoutine(String value) {
    state = state.copyWith(
      data: state.data.copyWith(
        lifestyle: state.data.lifestyle.copyWith(mealRoutine: value),
      ),
    );
  }

  void setHydration(String value) {
    state = state.copyWith(
      data: state.data.copyWith(
        lifestyle: state.data.lifestyle.copyWith(hydration: value),
      ),
    );
  }

  void setAddictions(List<String> value) {
    state = state.copyWith(
      data: state.data.copyWith(
        habits: state.data.habits.copyWith(addictions: value),
      ),
    );
  }

  void setAddictionSeverity(String value) {
    state = state.copyWith(
      data: state.data.copyWith(
        habits: state.data.habits.copyWith(addictionSeverity: value),
      ),
    );
  }

  void setAttemptedQuitting(bool value) {
    state = state.copyWith(
      data: state.data.copyWith(
        habits: state.data.habits.copyWith(attemptedQuitting: value),
      ),
    );
  }

  void setEatingHabits(String value) {
    state = state.copyWith(
      data: state.data.copyWith(
        body: state.data.body.copyWith(eatingHabits: value),
      ),
    );
  }

  void setAppetiteChanges(String value) {
    state = state.copyWith(
      data: state.data.copyWith(
        body: state.data.body.copyWith(appetiteChanges: value),
      ),
    );
  }

  void setBodyImageConcerns(String value) {
    state = state.copyWith(
      data: state.data.copyWith(
        body: state.data.body.copyWith(bodyImageConcerns: value),
      ),
    );
  }

  void setCopingMechanisms(List<String> value) {
    state = state.copyWith(
      data: state.data.copyWith(
        coping: state.data.coping.copyWith(copingMechanisms: value),
      ),
    );
  }

  void setSelfHarmIdeation(String value) {
    state = state.copyWith(
      data: state.data.copyWith(
        coping: state.data.coping.copyWith(selfHarmIdeation: value),
      ),
    );
  }

  void setEmotionallySafe(bool value) {
    state = state.copyWith(
      data: state.data.copyWith(
        coping: state.data.coping.copyWith(emotionallySafe: value),
      ),
    );
  }

  void setSpiritualOrReligious(bool value) {
    state = state.copyWith(
      data: state.data.copyWith(
        spiritual: state.data.spiritual.copyWith(
          spiritualOrReligious: value,
          interestInSpiritualContent: value,
        ),
      ),
    );
  }

  void setMeaningAndPurpose(String value) {
    state = state.copyWith(
      data: state.data.copyWith(
        spiritual: state.data.spiritual.copyWith(meaningAndPurpose: value),
      ),
    );
  }

  void setGoals(List<String> value) {
    state = state.copyWith(
      data: state.data.copyWith(
        goals: state.data.goals.copyWith(goals: value),
      ),
    );
  }

  void setPreferredSupport(List<String> value) {
    state = state.copyWith(
      data: state.data.copyWith(
        goals: state.data.goals.copyWith(preferredSupport: value),
      ),
    );
  }

  void setCommitmentLevel(String value) {
    state = state.copyWith(
      data: state.data.copyWith(
        goals: state.data.goals.copyWith(commitmentLevel: value),
      ),
    );
  }

  void setPreferredTimeOfDay(String value) {
    state = state.copyWith(
      data: state.data.copyWith(
        goals: state.data.goals.copyWith(preferredTimeOfDay: value),
      ),
    );
  }

  ClassificationResult complete() {
    final completed = state.data.copyWith(
      completedAt: DateTime.now(),
    );
    final classification = ClassificationEngine.classifyUserDomain(completed);
    state = state.copyWith(
      data: completed,
      isComplete: true,
      classification: classification,
      currentSection: OnboardingSection.complete,
    );
    return classification;
  }

  void reset() {
    state = const OnboardingFlowState();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

final onboardingFlowProvider =
    StateNotifierProvider<OnboardingFlowNotifier, OnboardingFlowState>(
  (ref) => OnboardingFlowNotifier(),
);
