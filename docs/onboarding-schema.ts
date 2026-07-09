// ─────────────────────────────────────────────────────────────
// Mental Mantra — Onboarding Schema (TypeScript Reference)
// 11-Section Adaptive Flow
// ─────────────────────────────────────────────────────────────

// ── Section 1: Consent & Welcome ──────────────────────────
interface ConsentSection {
  consentAccepted: boolean;
  consentDate: string; // ISO 8601
}

// ── Section 2: Basic Info ─────────────────────────────────
type AgeRange =
  | 'Under 18'
  | '18-24'
  | '25-34'
  | '35-44'
  | '45-54'
  | '55+';

type Gender = 'Male' | 'Female' | 'Non-binary' | 'Prefer not to say' | 'Other';
type RelationshipStatus = 'Single' | 'In a relationship' | 'Married' | 'Divorced' | 'Widowed' | 'Prefer not to say';
type LivingSituation = 'Alone' | 'With partner' | 'With family' | 'With friends' | 'With roommates' | 'Other';

interface BasicInfoSection {
  nickname: string;
  ageRange: AgeRange;
  gender: Gender;
  country: string;
  role: string; // e.g., Student, Professional, Homemaker, etc.
  relationshipStatus: RelationshipStatus;
  livingWith: LivingSituation;
}

// ── Section 3: Needs & Motivation ────────────────────────
type ReasonJoined =
  | 'Stress'
  | 'Anxiety'
  | 'Loneliness'
  | 'Addictions'
  | 'Sleep Issues'
  | 'Low Motivation'
  | 'Anger Management'
  | 'Relationship Issues'
  | 'Grief'
  | 'Self-Improvement'
  | 'Depression'
  | 'Burnout'
  | 'Trauma'
  | 'Other';

type Duration = 'Just started (days)' | 'A few weeks' | 'A few months' | 'A year or more';
type AffectedArea = 'Work' | 'Relationships' | 'Health' | 'Self-esteem' | 'Social life' | 'Studies' | 'Family';

interface NeedsSection {
  reasonsJoined: ReasonJoined[];
  duration: Duration;
  affectedAreas: AffectedArea[];
  previousHelp: boolean;
  previousHelpDetails?: string;
}

// ── Section 4: Emotional Check-in ─────────────────────────
type SymptomFrequency = 'Never' | 'Rarely' | 'Sometimes' | 'Often' | 'Almost Always';

type SymptomKey =
  | 'feeling_overwhelmed'
  | 'nervous_anxious'
  | 'difficulty_concentrating'
  | 'loss_of_interest'
  | 'irritable_angry'
  | 'low_energy'
  | 'restless'
  | 'hopeless'
  | 'physical_tension'
  | 'avoiding_people'
  | 'intrusive_thoughts'
  | 'emotional_numbness';

type EmotionalCheckinSection = Record<SymptomKey, SymptomFrequency>;

// ── Section 5: Sleep & Energy ─────────────────────────────
interface SleepEnergySection {
  sleepHours: 'Less than 4' | '4-5' | '6-7' | '7-8' | '8+';
  sleepQuality: 'Very poor' | 'Poor' | 'Fair' | 'Good' | 'Excellent';
  sleepLatency: 'Under 15 min' | '15-30 min' | '30-60 min' | 'Over 1 hour';
  nightWakeups: 'Never' | 'Once' | '2-3 times' | '4+ times';
  morningEnergy: 'Very refreshed' | 'Somewhat refreshed' | 'Tired' | 'Exhausted';
  mentalFatigue: 'None' | 'Mild' | 'Moderate' | 'Severe' | 'Extreme';
  nightScreenUse: boolean;
}

// ── Section 6: Lifestyle & Daily Habits ───────────────────
interface LifestyleSection {
  physicalActivity: 'None' | '1-2 days/week' | '3-4 days/week' | '5+ days/week';
  offlineTime: 'Less than 1 hour' | '1-2 hours' | '3-4 hours' | '5+ hours';
  emotionalSupport: 'None' | 'One person' | 'A few people' | 'Strong support network';
  screenTime: 'Less than 2 hours' | '2-4 hours' | '4-7 hours' | '7+ hours';
  socialInteractions: 'Very limited' | 'Limited' | 'Moderate' | 'Active' | 'Very active';
  workLifeBalance: 'Very poor' | 'Poor' | 'Fair' | 'Good' | 'Excellent';
  mealRoutine: 'Irregular / Skip meals' | '2 meals a day' | '3 meals a day' | '3 meals + snacks';
  hydration: 'Less than 3 glasses' | '3-5 glasses' | '5-8 glasses' | '8+ glasses';
}

// ── Section 7: Habits & Addictions ───────────────────────
type AddictionType =
  | 'Social media / Phone'
  | 'Pornography'
  | 'Smoking / Nicotine'
  | 'Alcohol'
  | 'Caffeine'
  | 'Gaming'
  | 'Binge eating'
  | 'Substance use'
  | 'Shopping'
  | 'Not applicable';

interface HabitsSection {
  addictions: AddictionType[];
  addictionSeverity: 'Mild' | 'Moderate' | 'Severe' | 'Not applicable';
  attemptedQuitting: boolean;
  quittingAttempts?: number;
  longestAbstinence?: string;
  triggers?: string[];
}

// ── Section 8: Body & Eating ─────────────────────────────
interface BodySection {
  eatingHabits: 'Balanced and healthy' | 'Mostly healthy' | 'Mixed' | 'Mostly unhealthy' | 'Very unhealthy';
  appetiteChanges: 'No change' | 'Increased appetite' | 'Decreased appetite' | 'Erratic';
  bodyImageConcerns: 'Not at all' | 'Slightly' | 'Moderately' | 'Very' | 'Extremely';
  physicalSymptoms: string[]; // e.g., Headaches, Digestive issues, Muscle tension
  healthConditions?: string;
}

// ── Section 9: Coping Mechanisms ─────────────────────────
type CopingMechanism =
  | 'Talking to friends/family'
  | 'Exercise / Sports'
  | 'Music'
  | 'Meditation / Prayer'
  | 'Journaling'
  | 'Watching TV / Movies'
  | 'Gaming'
  | 'Sleeping'
  | 'Eating'
  | 'Substance use'
  | 'Self-harm'
  | 'Withdrawal / Isolation'
  | 'Work / Busy work'
  | 'Deep breathing'
  | 'Crying'
  | 'Other';

type PersonalityTrait =
  | 'Introvert'
  | 'Extrovert'
  | 'Ambivert'
  | 'Thinker'
  | 'Feeler'
  | 'Planner'
  | 'Spontaneous';

interface CopingSection {
  copingMechanisms: CopingMechanism[];
  healthyCoping: boolean;
  personalityTraits: PersonalityTrait[];
  selfHarmIdeation: 'Never' | 'Rarely' | 'Sometimes' | 'Often';
  emotionallySafe: boolean;
  wantsSupportResources: boolean;
  safetyPlan: boolean;
}

// ── Section 10: Spiritual & Meaning ──────────────────────
interface SpiritualSection {
  spiritualOrReligious: boolean;
  faithTradition?: string;
  interestInSpiritualContent: boolean;
  prefersSecularContent: boolean;
  meaningAndPurpose: 'Not important' | 'Slightly important' | 'Moderately important' | 'Very important' | 'Essential';
}

// ── Section 11: Goals & Preferences ──────────────────────
type Goal =
  | 'Reduce stress and anxiety'
  | 'Improve sleep'
  | 'Build healthier habits'
  | 'Quit an addiction'
  | 'Improve relationships'
  | 'Find purpose and meaning'
  | 'Manage anger'
  | 'Boost confidence'
  | 'Process grief or loss'
  | 'Feel happier day-to-day'
  | 'Practice mindfulness';

type SupportPreference =
  | 'Meditation & Breathing'
  | 'Music Therapy'
  | 'Yoga & Movement'
  | 'Journaling'
  | 'AI Chat Support'
  | 'Bhagavad Gita / Spiritual'
  | 'Addiction Recovery Tools'
  | 'Mood Tracking'
  | 'Habit Tracking'
  | 'Nutrition Guidance'
  | 'Community Support'
  | 'Crisis Resources';

interface GoalsSection {
  goals: Goal[];
  preferredSupport: SupportPreference[];
  commitmentLevel: 'Low' | 'Medium' | 'High';
  preferredTimeOfDay: 'Morning' | 'Afternoon' | 'Evening' | 'Before bed';
  reminderPreference: 'Gentle nudges' | 'Regular reminders' | 'Only when I open the app';
}

// ── Complete Onboarding Data ─────────────────────────────
interface OnboardingData {
  consent: ConsentSection;
  basicInfo: BasicInfoSection;
  needs: NeedsSection;
  emotionalCheckin: EmotionalCheckinSection;
  sleepEnergy: SleepEnergySection;
  lifestyle: LifestyleSection;
  habits: HabitsSection;
  body: BodySection;
  coping: CopingSection;
  spiritual: SpiritualSection;
  goals: GoalsSection;
  completedAt?: string;
  version: number; // schema version for migration
}

// ── Classification Result ────────────────────────────────
type UserDomain =
  | 'Stress & Burnout'
  | 'Anxiety & Overthinking'
  | 'Emotional Isolation'
  | 'Addiction Recovery'
  | 'Anger Dysregulation'
  | 'Low Motivation'
  | 'Spiritual Seeking'
  | 'Sleep Dysregulation';

interface ClassificationResult {
  primaryDomain: UserDomain;
  secondaryDomain: UserDomain;
  domainScores: Record<UserDomain, number>;
  riskLevel: 'Low' | 'Moderate' | 'High' | 'Critical';
  requiresEscalation: boolean;
  crisisResourcesTriggered: boolean;
}
