import 'package:equatable/equatable.dart';

// ── Section 1: Consent ────────────────────────────────────
class ConsentSection extends Equatable {
  final bool consentAccepted;
  final DateTime? consentDate;

  const ConsentSection({this.consentAccepted = false, this.consentDate});

  ConsentSection copyWith({bool? consentAccepted, DateTime? consentDate}) =>
      ConsentSection(
        consentAccepted: consentAccepted ?? this.consentAccepted,
        consentDate: consentDate ?? this.consentDate,
      );

  Map<String, dynamic> toJson() => {
        'consentAccepted': consentAccepted,
        'consentDate': consentDate?.toIso8601String(),
      };

  factory ConsentSection.fromJson(Map<String, dynamic> json) => ConsentSection(
        consentAccepted: json['consentAccepted'] ?? false,
        consentDate: json['consentDate'] != null
            ? DateTime.parse(json['consentDate'])
            : null,
      );

  @override
  List<Object?> get props => [consentAccepted, consentDate];
}

// ── Section 2: Basic Info ────────────────────────────────
enum AgeRange {
  under18('Under 18'),
  age18_24('18-24'),
  age25_34('25-34'),
  age35_44('35-44'),
  age45_54('45-54'),
  age55plus('55+');

  final String label;
  const AgeRange(this.label);
  static AgeRange fromLabel(String label) =>
      values.firstWhere((e) => e.label == label, orElse: () => age25_34);
}

enum Gender {
  male('Male'),
  female('Female'),
  nonBinary('Non-binary'),
  preferNotSay('Prefer not to say'),
  other('Other');

  final String label;
  const Gender(this.label);
  static Gender fromLabel(String label) =>
      values.firstWhere((e) => e.label == label, orElse: () => preferNotSay);
}

enum RelationshipStatus {
  single('Single'),
  inRelationship('In a relationship'),
  married('Married'),
  divorced('Divorced'),
  widowed('Widowed'),
  preferNotSay('Prefer not to say');

  final String label;
  const RelationshipStatus(this.label);
  static RelationshipStatus fromLabel(String label) =>
      values.firstWhere((e) => e.label == label, orElse: () => preferNotSay);
}

enum LivingSituation {
  alone('Alone'),
  withPartner('With partner'),
  withFamily('With family'),
  withFriends('With friends'),
  withRoommates('With roommates'),
  other('Other');

  final String label;
  const LivingSituation(this.label);
  static LivingSituation fromLabel(String label) =>
      values.firstWhere((e) => e.label == label, orElse: () => other);
}

class BasicInfoSection extends Equatable {
  final String nickname;
  final AgeRange ageRange;
  final Gender gender;
  final String country;
  final String role;
  final RelationshipStatus relationshipStatus;
  final LivingSituation livingWith;

  const BasicInfoSection({
    this.nickname = '',
    this.ageRange = AgeRange.age25_34,
    this.gender = Gender.preferNotSay,
    this.country = '',
    this.role = '',
    this.relationshipStatus = RelationshipStatus.preferNotSay,
    this.livingWith = LivingSituation.other,
  });

  BasicInfoSection copyWith({
    String? nickname,
    AgeRange? ageRange,
    Gender? gender,
    String? country,
    String? role,
    RelationshipStatus? relationshipStatus,
    LivingSituation? livingWith,
  }) =>
      BasicInfoSection(
        nickname: nickname ?? this.nickname,
        ageRange: ageRange ?? this.ageRange,
        gender: gender ?? this.gender,
        country: country ?? this.country,
        role: role ?? this.role,
        relationshipStatus: relationshipStatus ?? this.relationshipStatus,
        livingWith: livingWith ?? this.livingWith,
      );

  Map<String, dynamic> toJson() => {
        'nickname': nickname,
        'ageRange': ageRange.label,
        'gender': gender.label,
        'country': country,
        'role': role,
        'relationshipStatus': relationshipStatus.label,
        'livingWith': livingWith.label,
      };

  factory BasicInfoSection.fromJson(Map<String, dynamic> json) =>
      BasicInfoSection(
        nickname: json['nickname'] ?? '',
        ageRange: AgeRange.fromLabel(json['ageRange'] ?? ''),
        gender: Gender.fromLabel(json['gender'] ?? ''),
        country: json['country'] ?? '',
        role: json['role'] ?? '',
        relationshipStatus:
            RelationshipStatus.fromLabel(json['relationshipStatus'] ?? ''),
        livingWith: LivingSituation.fromLabel(json['livingWith'] ?? ''),
      );

  @override
  List<Object?> get props => [
        nickname,
        ageRange,
        gender,
        country,
        role,
        relationshipStatus,
        livingWith
      ];
}

// ── Section 3: Needs & Motivation ─────────────────────────
class NeedsSection extends Equatable {
  final List<String> reasonsJoined;
  final String duration;
  final List<String> affectedAreas;
  final bool previousHelp;
  final String? previousHelpDetails;

  const NeedsSection({
    this.reasonsJoined = const [],
    this.duration = '',
    this.affectedAreas = const [],
    this.previousHelp = false,
    this.previousHelpDetails,
  });

  NeedsSection copyWith({
    List<String>? reasonsJoined,
    String? duration,
    List<String>? affectedAreas,
    bool? previousHelp,
    String? previousHelpDetails,
  }) =>
      NeedsSection(
        reasonsJoined: reasonsJoined ?? this.reasonsJoined,
        duration: duration ?? this.duration,
        affectedAreas: affectedAreas ?? this.affectedAreas,
        previousHelp: previousHelp ?? this.previousHelp,
        previousHelpDetails: previousHelpDetails ?? this.previousHelpDetails,
      );

  Map<String, dynamic> toJson() => {
        'reasonsJoined': reasonsJoined,
        'duration': duration,
        'affectedAreas': affectedAreas,
        'previousHelp': previousHelp,
        'previousHelpDetails': previousHelpDetails,
      };

  factory NeedsSection.fromJson(Map<String, dynamic> json) => NeedsSection(
        reasonsJoined: List<String>.from(json['reasonsJoined'] ?? []),
        duration: json['duration'] ?? '',
        affectedAreas: List<String>.from(json['affectedAreas'] ?? []),
        previousHelp: json['previousHelp'] ?? false,
        previousHelpDetails: json['previousHelpDetails'],
      );

  @override
  List<Object?> get props => [
        reasonsJoined,
        duration,
        affectedAreas,
        previousHelp,
        previousHelpDetails
      ];
}

// ── Section 4: Emotional Check-in ─────────────────────────
class EmotionalCheckinSection extends Equatable {
  final Map<String, String> symptoms;

  const EmotionalCheckinSection({this.symptoms = const {}});

  EmotionalCheckinSection copyWith({Map<String, String>? symptoms}) =>
      EmotionalCheckinSection(symptoms: symptoms ?? this.symptoms);

  Map<String, dynamic> toJson() => symptoms;

  factory EmotionalCheckinSection.fromJson(Map<String, dynamic> json) =>
      EmotionalCheckinSection(
        symptoms: json.map((k, v) => MapEntry(k, v.toString())),
      );

  List<String> get elevatedSymptoms => symptoms.entries
      .where((e) => ['Often', 'Almost Always'].contains(e.value))
      .map((e) => e.key)
      .toList();

  List<String> get moderateSymptoms => symptoms.entries
      .where((e) => e.value == 'Sometimes')
      .map((e) => e.key)
      .toList();

  @override
  List<Object?> get props => [symptoms];
}

// ── Section 5: Sleep & Energy ─────────────────────────────
class SleepEnergySection extends Equatable {
  final String sleepHours;
  final String sleepQuality;
  final String sleepLatency;
  final String nightWakeups;
  final String morningEnergy;
  final String mentalFatigue;
  final bool nightScreenUse;

  const SleepEnergySection({
    this.sleepHours = '',
    this.sleepQuality = '',
    this.sleepLatency = '',
    this.nightWakeups = '',
    this.morningEnergy = '',
    this.mentalFatigue = '',
    this.nightScreenUse = false,
  });

  SleepEnergySection copyWith({
    String? sleepHours,
    String? sleepQuality,
    String? sleepLatency,
    String? nightWakeups,
    String? morningEnergy,
    String? mentalFatigue,
    bool? nightScreenUse,
  }) =>
      SleepEnergySection(
        sleepHours: sleepHours ?? this.sleepHours,
        sleepQuality: sleepQuality ?? this.sleepQuality,
        sleepLatency: sleepLatency ?? this.sleepLatency,
        nightWakeups: nightWakeups ?? this.nightWakeups,
        morningEnergy: morningEnergy ?? this.morningEnergy,
        mentalFatigue: mentalFatigue ?? this.mentalFatigue,
        nightScreenUse: nightScreenUse ?? this.nightScreenUse,
      );

  double get sleepScore {
    final quality = {
      'Excellent': 1.0,
      'Good': 0.8,
      'Fair': 0.6,
      'Poor': 0.3,
      'Very poor': 0.1,
    };
    return (quality[sleepQuality] ?? 0.5);
  }

  Map<String, dynamic> toJson() => {
        'sleepHours': sleepHours,
        'sleepQuality': sleepQuality,
        'sleepLatency': sleepLatency,
        'nightWakeups': nightWakeups,
        'morningEnergy': morningEnergy,
        'mentalFatigue': mentalFatigue,
        'nightScreenUse': nightScreenUse,
      };

  factory SleepEnergySection.fromJson(Map<String, dynamic> json) =>
      SleepEnergySection(
        sleepHours: json['sleepHours'] ?? '',
        sleepQuality: json['sleepQuality'] ?? '',
        sleepLatency: json['sleepLatency'] ?? '',
        nightWakeups: json['nightWakeups'] ?? '',
        morningEnergy: json['morningEnergy'] ?? '',
        mentalFatigue: json['mentalFatigue'] ?? '',
        nightScreenUse: json['nightScreenUse'] ?? false,
      );

  @override
  List<Object?> get props => [
        sleepHours,
        sleepQuality,
        sleepLatency,
        nightWakeups,
        morningEnergy,
        mentalFatigue,
        nightScreenUse,
      ];
}

// ── Section 6: Lifestyle ──────────────────────────────────
class LifestyleSection extends Equatable {
  final String physicalActivity;
  final String offlineTime;
  final String emotionalSupport;
  final String screenTime;
  final String socialInteractions;
  final String workLifeBalance;
  final String mealRoutine;
  final String hydration;

  const LifestyleSection({
    this.physicalActivity = '',
    this.offlineTime = '',
    this.emotionalSupport = '',
    this.screenTime = '',
    this.socialInteractions = '',
    this.workLifeBalance = '',
    this.mealRoutine = '',
    this.hydration = '',
  });

  LifestyleSection copyWith({
    String? physicalActivity,
    String? offlineTime,
    String? emotionalSupport,
    String? screenTime,
    String? socialInteractions,
    String? workLifeBalance,
    String? mealRoutine,
    String? hydration,
  }) =>
      LifestyleSection(
        physicalActivity: physicalActivity ?? this.physicalActivity,
        offlineTime: offlineTime ?? this.offlineTime,
        emotionalSupport: emotionalSupport ?? this.emotionalSupport,
        screenTime: screenTime ?? this.screenTime,
        socialInteractions: socialInteractions ?? this.socialInteractions,
        workLifeBalance: workLifeBalance ?? this.workLifeBalance,
        mealRoutine: mealRoutine ?? this.mealRoutine,
        hydration: hydration ?? this.hydration,
      );

  Map<String, dynamic> toJson() => {
        'physicalActivity': physicalActivity,
        'offlineTime': offlineTime,
        'emotionalSupport': emotionalSupport,
        'screenTime': screenTime,
        'socialInteractions': socialInteractions,
        'workLifeBalance': workLifeBalance,
        'mealRoutine': mealRoutine,
        'hydration': hydration,
      };

  factory LifestyleSection.fromJson(Map<String, dynamic> json) =>
      LifestyleSection(
        physicalActivity: json['physicalActivity'] ?? '',
        offlineTime: json['offlineTime'] ?? '',
        emotionalSupport: json['emotionalSupport'] ?? '',
        screenTime: json['screenTime'] ?? '',
        socialInteractions: json['socialInteractions'] ?? '',
        workLifeBalance: json['workLifeBalance'] ?? '',
        mealRoutine: json['mealRoutine'] ?? '',
        hydration: json['hydration'] ?? '',
      );

  @override
  List<Object?> get props => [
        physicalActivity,
        offlineTime,
        emotionalSupport,
        screenTime,
        socialInteractions,
        workLifeBalance,
        mealRoutine,
        hydration,
      ];
}

// ── Section 7: Habits & Addictions ───────────────────────
class HabitsSection extends Equatable {
  final List<String> addictions;
  final String addictionSeverity;
  final bool attemptedQuitting;
  final int? quittingAttempts;
  final String? longestAbstinence;
  final List<String> triggers;

  const HabitsSection({
    this.addictions = const [],
    this.addictionSeverity = '',
    this.attemptedQuitting = false,
    this.quittingAttempts,
    this.longestAbstinence,
    this.triggers = const [],
  });

  HabitsSection copyWith({
    List<String>? addictions,
    String? addictionSeverity,
    bool? attemptedQuitting,
    int? quittingAttempts,
    String? longestAbstinence,
    List<String>? triggers,
  }) =>
      HabitsSection(
        addictions: addictions ?? this.addictions,
        addictionSeverity: addictionSeverity ?? this.addictionSeverity,
        attemptedQuitting: attemptedQuitting ?? this.attemptedQuitting,
        quittingAttempts: quittingAttempts ?? this.quittingAttempts,
        longestAbstinence: longestAbstinence ?? this.longestAbstinence,
        triggers: triggers ?? this.triggers,
      );

  bool get hasAddictions =>
      addictions.isNotEmpty && addictions != ['Not applicable'];

  Map<String, dynamic> toJson() => {
        'addictions': addictions,
        'addictionSeverity': addictionSeverity,
        'attemptedQuitting': attemptedQuitting,
        'quittingAttempts': quittingAttempts,
        'longestAbstinence': longestAbstinence,
        'triggers': triggers,
      };

  factory HabitsSection.fromJson(Map<String, dynamic> json) => HabitsSection(
        addictions: List<String>.from(json['addictions'] ?? []),
        addictionSeverity: json['addictionSeverity'] ?? '',
        attemptedQuitting: json['attemptedQuitting'] ?? false,
        quittingAttempts: json['quittingAttempts'],
        longestAbstinence: json['longestAbstinence'],
        triggers: List<String>.from(json['triggers'] ?? []),
      );

  @override
  List<Object?> get props => [
        addictions,
        addictionSeverity,
        attemptedQuitting,
        quittingAttempts,
        longestAbstinence,
        triggers,
      ];
}

// ── Section 8: Body & Eating ────────────────────────────
class BodySection extends Equatable {
  final String eatingHabits;
  final String appetiteChanges;
  final String bodyImageConcerns;
  final List<String> physicalSymptoms;
  final String? healthConditions;

  const BodySection({
    this.eatingHabits = '',
    this.appetiteChanges = '',
    this.bodyImageConcerns = '',
    this.physicalSymptoms = const [],
    this.healthConditions,
  });

  BodySection copyWith({
    String? eatingHabits,
    String? appetiteChanges,
    String? bodyImageConcerns,
    List<String>? physicalSymptoms,
    String? healthConditions,
  }) =>
      BodySection(
        eatingHabits: eatingHabits ?? this.eatingHabits,
        appetiteChanges: appetiteChanges ?? this.appetiteChanges,
        bodyImageConcerns: bodyImageConcerns ?? this.bodyImageConcerns,
        physicalSymptoms: physicalSymptoms ?? this.physicalSymptoms,
        healthConditions: healthConditions ?? this.healthConditions,
      );

  Map<String, dynamic> toJson() => {
        'eatingHabits': eatingHabits,
        'appetiteChanges': appetiteChanges,
        'bodyImageConcerns': bodyImageConcerns,
        'physicalSymptoms': physicalSymptoms,
        'healthConditions': healthConditions,
      };

  factory BodySection.fromJson(Map<String, dynamic> json) => BodySection(
        eatingHabits: json['eatingHabits'] ?? '',
        appetiteChanges: json['appetiteChanges'] ?? '',
        bodyImageConcerns: json['bodyImageConcerns'] ?? '',
        physicalSymptoms: List<String>.from(json['physicalSymptoms'] ?? []),
        healthConditions: json['healthConditions'],
      );

  @override
  List<Object?> get props => [
        eatingHabits,
        appetiteChanges,
        bodyImageConcerns,
        physicalSymptoms,
        healthConditions,
      ];
}

// ── Section 9: Coping & Safety ──────────────────────────
class CopingSection extends Equatable {
  final List<String> copingMechanisms;
  final bool healthyCoping;
  final List<String> personalityTraits;
  final String selfHarmIdeation;
  final bool emotionallySafe;
  final bool wantsSupportResources;
  final bool safetyPlan;

  const CopingSection({
    this.copingMechanisms = const [],
    this.healthyCoping = true,
    this.personalityTraits = const [],
    this.selfHarmIdeation = 'Never',
    this.emotionallySafe = true,
    this.wantsSupportResources = false,
    this.safetyPlan = false,
  });

  CopingSection copyWith({
    List<String>? copingMechanisms,
    bool? healthyCoping,
    List<String>? personalityTraits,
    String? selfHarmIdeation,
    bool? emotionallySafe,
    bool? wantsSupportResources,
    bool? safetyPlan,
  }) =>
      CopingSection(
        copingMechanisms: copingMechanisms ?? this.copingMechanisms,
        healthyCoping: healthyCoping ?? this.healthyCoping,
        personalityTraits: personalityTraits ?? this.personalityTraits,
        selfHarmIdeation: selfHarmIdeation ?? this.selfHarmIdeation,
        emotionallySafe: emotionallySafe ?? this.emotionallySafe,
        wantsSupportResources:
            wantsSupportResources ?? this.wantsSupportResources,
        safetyPlan: safetyPlan ?? this.safetyPlan,
      );

  bool get requiresCrisisEscalation =>
      selfHarmIdeation == 'Often' || !emotionallySafe;

  Map<String, dynamic> toJson() => {
        'copingMechanisms': copingMechanisms,
        'healthyCoping': healthyCoping,
        'personalityTraits': personalityTraits,
        'selfHarmIdeation': selfHarmIdeation,
        'emotionallySafe': emotionallySafe,
        'wantsSupportResources': wantsSupportResources,
        'safetyPlan': safetyPlan,
      };

  factory CopingSection.fromJson(Map<String, dynamic> json) => CopingSection(
        copingMechanisms: List<String>.from(json['copingMechanisms'] ?? []),
        healthyCoping: json['healthyCoping'] ?? true,
        personalityTraits: List<String>.from(json['personalityTraits'] ?? []),
        selfHarmIdeation: json['selfHarmIdeation'] ?? 'Never',
        emotionallySafe: json['emotionallySafe'] ?? true,
        wantsSupportResources: json['wantsSupportResources'] ?? false,
        safetyPlan: json['safetyPlan'] ?? false,
      );

  @override
  List<Object?> get props => [
        copingMechanisms,
        healthyCoping,
        personalityTraits,
        selfHarmIdeation,
        emotionallySafe,
        wantsSupportResources,
        safetyPlan,
      ];
}

// ── Section 10: Spiritual & Meaning ──────────────────────
class SpiritualSection extends Equatable {
  final bool spiritualOrReligious;
  final String? faithTradition;
  final bool interestInSpiritualContent;
  final bool prefersSecularContent;
  final String meaningAndPurpose;

  const SpiritualSection({
    this.spiritualOrReligious = false,
    this.faithTradition,
    this.interestInSpiritualContent = false,
    this.prefersSecularContent = true,
    this.meaningAndPurpose = '',
  });

  SpiritualSection copyWith({
    bool? spiritualOrReligious,
    String? faithTradition,
    bool? interestInSpiritualContent,
    bool? prefersSecularContent,
    String? meaningAndPurpose,
  }) =>
      SpiritualSection(
        spiritualOrReligious: spiritualOrReligious ?? this.spiritualOrReligious,
        faithTradition: faithTradition ?? this.faithTradition,
        interestInSpiritualContent:
            interestInSpiritualContent ?? this.interestInSpiritualContent,
        prefersSecularContent:
            prefersSecularContent ?? this.prefersSecularContent,
        meaningAndPurpose: meaningAndPurpose ?? this.meaningAndPurpose,
      );

  Map<String, dynamic> toJson() => {
        'spiritualOrReligious': spiritualOrReligious,
        'faithTradition': faithTradition,
        'interestInSpiritualContent': interestInSpiritualContent,
        'prefersSecularContent': prefersSecularContent,
        'meaningAndPurpose': meaningAndPurpose,
      };

  factory SpiritualSection.fromJson(Map<String, dynamic> json) =>
      SpiritualSection(
        spiritualOrReligious: json['spiritualOrReligious'] ?? false,
        faithTradition: json['faithTradition'],
        interestInSpiritualContent: json['interestInSpiritualContent'] ?? false,
        prefersSecularContent: json['prefersSecularContent'] ?? true,
        meaningAndPurpose: json['meaningAndPurpose'] ?? '',
      );

  @override
  List<Object?> get props => [
        spiritualOrReligious,
        faithTradition,
        interestInSpiritualContent,
        prefersSecularContent,
        meaningAndPurpose,
      ];
}

// ── Section 11: Goals & Preferences ──────────────────────
class GoalsSection extends Equatable {
  final List<String> goals;
  final List<String> preferredSupport;
  final String commitmentLevel;
  final String preferredTimeOfDay;
  final String reminderPreference;

  const GoalsSection({
    this.goals = const [],
    this.preferredSupport = const [],
    this.commitmentLevel = '',
    this.preferredTimeOfDay = '',
    this.reminderPreference = '',
  });

  GoalsSection copyWith({
    List<String>? goals,
    List<String>? preferredSupport,
    String? commitmentLevel,
    String? preferredTimeOfDay,
    String? reminderPreference,
  }) =>
      GoalsSection(
        goals: goals ?? this.goals,
        preferredSupport: preferredSupport ?? this.preferredSupport,
        commitmentLevel: commitmentLevel ?? this.commitmentLevel,
        preferredTimeOfDay: preferredTimeOfDay ?? this.preferredTimeOfDay,
        reminderPreference: reminderPreference ?? this.reminderPreference,
      );

  Map<String, dynamic> toJson() => {
        'goals': goals,
        'preferredSupport': preferredSupport,
        'commitmentLevel': commitmentLevel,
        'preferredTimeOfDay': preferredTimeOfDay,
        'reminderPreference': reminderPreference,
      };

  factory GoalsSection.fromJson(Map<String, dynamic> json) => GoalsSection(
        goals: List<String>.from(json['goals'] ?? []),
        preferredSupport: List<String>.from(json['preferredSupport'] ?? []),
        commitmentLevel: json['commitmentLevel'] ?? '',
        preferredTimeOfDay: json['preferredTimeOfDay'] ?? '',
        reminderPreference: json['reminderPreference'] ?? '',
      );

  @override
  List<Object?> get props => [
        goals,
        preferredSupport,
        commitmentLevel,
        preferredTimeOfDay,
        reminderPreference,
      ];
}

// ── Complete Onboarding Data ─────────────────────────────
class OnboardingData extends Equatable {
  final ConsentSection consent;
  final BasicInfoSection basicInfo;
  final NeedsSection needs;
  final EmotionalCheckinSection emotionalCheckin;
  final SleepEnergySection sleepEnergy;
  final LifestyleSection lifestyle;
  final HabitsSection habits;
  final BodySection body;
  final CopingSection coping;
  final SpiritualSection spiritual;
  final GoalsSection goals;
  final DateTime? completedAt;
  final int version;

  const OnboardingData({
    this.consent = const ConsentSection(),
    this.basicInfo = const BasicInfoSection(),
    this.needs = const NeedsSection(),
    this.emotionalCheckin = const EmotionalCheckinSection(),
    this.sleepEnergy = const SleepEnergySection(),
    this.lifestyle = const LifestyleSection(),
    this.habits = const HabitsSection(),
    this.body = const BodySection(),
    this.coping = const CopingSection(),
    this.spiritual = const SpiritualSection(),
    this.goals = const GoalsSection(),
    this.completedAt,
    this.version = 1,
  });

  bool get isComplete => completedAt != null;
  bool get needsCrisisSupport => coping.requiresCrisisEscalation;

  OnboardingData copyWith({
    ConsentSection? consent,
    BasicInfoSection? basicInfo,
    NeedsSection? needs,
    EmotionalCheckinSection? emotionalCheckin,
    SleepEnergySection? sleepEnergy,
    LifestyleSection? lifestyle,
    HabitsSection? habits,
    BodySection? body,
    CopingSection? coping,
    SpiritualSection? spiritual,
    GoalsSection? goals,
    DateTime? completedAt,
    int? version,
  }) =>
      OnboardingData(
        consent: consent ?? this.consent,
        basicInfo: basicInfo ?? this.basicInfo,
        needs: needs ?? this.needs,
        emotionalCheckin: emotionalCheckin ?? this.emotionalCheckin,
        sleepEnergy: sleepEnergy ?? this.sleepEnergy,
        lifestyle: lifestyle ?? this.lifestyle,
        habits: habits ?? this.habits,
        body: body ?? this.body,
        coping: coping ?? this.coping,
        spiritual: spiritual ?? this.spiritual,
        goals: goals ?? this.goals,
        completedAt: completedAt ?? this.completedAt,
        version: version ?? this.version,
      );

  Map<String, dynamic> toJson() => {
        'consent': consent.toJson(),
        'basicInfo': basicInfo.toJson(),
        'needs': needs.toJson(),
        'emotionalCheckin': emotionalCheckin.toJson(),
        'sleepEnergy': sleepEnergy.toJson(),
        'lifestyle': lifestyle.toJson(),
        'habits': habits.toJson(),
        'body': body.toJson(),
        'coping': coping.toJson(),
        'spiritual': spiritual.toJson(),
        'goals': goals.toJson(),
        'completedAt': completedAt?.toIso8601String(),
        'version': version,
      };

  factory OnboardingData.fromJson(Map<String, dynamic> json) => OnboardingData(
        consent: ConsentSection.fromJson(json['consent'] ?? {}),
        basicInfo: BasicInfoSection.fromJson(json['basicInfo'] ?? {}),
        needs: NeedsSection.fromJson(json['needs'] ?? {}),
        emotionalCheckin:
            EmotionalCheckinSection.fromJson(json['emotionalCheckin'] ?? {}),
        sleepEnergy: SleepEnergySection.fromJson(json['sleepEnergy'] ?? {}),
        lifestyle: LifestyleSection.fromJson(json['lifestyle'] ?? {}),
        habits: HabitsSection.fromJson(json['habits'] ?? {}),
        body: BodySection.fromJson(json['body'] ?? {}),
        coping: CopingSection.fromJson(json['coping'] ?? {}),
        spiritual: SpiritualSection.fromJson(json['spiritual'] ?? {}),
        goals: GoalsSection.fromJson(json['goals'] ?? {}),
        completedAt: json['completedAt'] != null
            ? DateTime.parse(json['completedAt'])
            : null,
        version: json['version'] ?? 1,
      );

  @override
  List<Object?> get props => [
        consent,
        basicInfo,
        needs,
        emotionalCheckin,
        sleepEnergy,
        lifestyle,
        habits,
        body,
        coping,
        spiritual,
        goals,
        completedAt,
        version,
      ];
}
