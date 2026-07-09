# Mental Mantra — Data Models Specification

This document details all 26 data models defined under `lib/models/` and their respective Firestore collection mappings.

---

## 1. Authentication & User Profile

### `UserModel`
* **File**: [user_model.dart](file:///c:/Users/kuldeep/OneDrive/Desktop/mental%20mantra/lib/models/user_model.dart)
* **Firestore Collection**: `/users/{userId}`
* **Schema**:
  * `uid`: `String` (Document ID)
  * `email`: `String`
  * `displayName`: `String?`
  * `streakDays`: `int`
  * `lastActiveDate`: `DateTime?` (stored as ISO8601 String)
  * `assessmentScores`: `Map<String, int>?`
  * `onboardingCompleted`: `bool`
  * `careDomain`: `String?`
  * `createdAt`: `DateTime` (stored as ISO8601 String)
  * `trustedContacts`: `List<TrustedContact>`
  * `photoBase64`: `String?`

### `TrustedContact` (Nested Helper Model)
* **File**: [user_model.dart](file:///c:/Users/kuldeep/OneDrive/Desktop/mental%20mantra/lib/models/user_model.dart)
* **Schema**:
  * `name`: `String`
  * `phone`: `String`
  * `relation`: `String`

---

## 2. Onboarding & Assessment

### `AssessmentStep`
* **File**: [assessment_question.dart](file:///c:/Users/kuldeep/OneDrive/Desktop/mental%20mantra/lib/models/assessment_question.dart)
* **Usage**: Static UI configuration representation.
* **Schema**:
  * `id`: `String`
  * `type`: `QuestionType` (Enum: `welcomeConsent`, `textInput`, `singleChoice`, `multipleChoice`, `scaleGroup`, `dropdown`, `radioGroup`)
  * `title`: `String?`
  * `subtitle`: `String?`
  * `sectionLabel`: `String?`
  * `question`: `String?`
  * `options`: `List<String>`
  * `scaleQuestions`: `List<ScaleQuestion>?`
  * `hint`: `String?`
  * `allowMultiple`: `bool`

### `AssessmentData`
* **File**: [assessment_data.dart](file:///c:/Users/kuldeep/OneDrive/Desktop/mental%20mantra/lib/models/assessment_data.dart)
* **Firestore Collection**: `/assessments/{userId}`
* **Schema**:
  * `name`: `String?`
  * `ageRange`: `String?`
  * `gender`: `String?`
  * `country`: `String?`
  * `role`: `String?`
  * `relationshipStatus`: `String?`
  * `livingSituation`: `String?`
  * `joinReasons`: `List<String>`
  * `challengeDuration`: `String?`
  * `affectedAreas`: `List<String>`
  * `emotionalWellness`: `Map<String, int>`
  * `sleepHours`: `String?`
  * `sleepQuality`: `String?`
  * `mentalTiredness`: `String?`
  * `lateNightScreen`: `String?`
  * `physicalActivity`: `String?`
  * `offlineTime`: `String?`
  * `emotionalSupport`: `String?`
  * `dailyScreenTime`: `String?`
  * `struggledHabits`: `List<String>`
  * `habitImpact`: `String?`
  * `triedReducing`: `String?`
  * `eatingHabits`: `String?`
  * `stressAppetite`: `String?`
  * `copingStrategies`: `List<String>`
  * `personalityType`: `String?`
  * `givingUpFeeling`: `String?`
  * `emotionallySafe`: `String?`
  * `wantResources`: `String?`
  * `improvementGoals`: `List<String>`
  * `supportNeeds`: `List<String>`
  * `consented`: `bool`

### `SolutionRecommendation`
* **File**: [solution_recommendation.dart](file:///c:/Users/kuldeep/OneDrive/Desktop/mental%20mantra/lib/models/solution_recommendation.dart)
* **Usage**: Computed client-side protocol suggestion.
* **Schema**:
  * `domain`: `CareDomain` (class containing `id`, `name`, `description`, `icon`)
  * `primaryFocus`: `String`
  * `suggestedHabits`: `List<String>`
  * `suggestedMeditation`: `List<String>`
  * `gitaVerseKey`: `String`
  * `gitaVerseContext`: `String`

---

## 3. Meditation & Audio Therapy

### `Meditation` (Metadata model)
* **File**: [meditation.dart](file:///c:/Users/kuldeep/OneDrive/Desktop/mental%20mantra/lib/models/meditation.dart)
* **Schema**:
  * `id`: `String`
  * `title`: `String`
  * `durationMinutes`: `int`
  * `category`: `String`
  * `description`: `String`
  * `audioUrl`: `String?`

### `MeditationSession` (Playback history log)
* **File**: [meditation_session.dart](file:///c:/Users/kuldeep/OneDrive/Desktop/mental%20mantra/lib/models/meditation_session.dart)
* **Firestore Collection**: `/meditation_sessions/{docId}`
* **Schema**:
  * `id`: `String`
  * `userId`: `String`
  * `meditationId`: `String`
  * `title`: `String`
  * `durationMinutes`: `int`
  * `completedAt`: `DateTime` (stored as ISO8601 String)

### `MusicTrack`
* **File**: [music_track.dart](file:///c:/Users/kuldeep/OneDrive/Desktop/mental%20mantra/lib/models/music_track.dart)
* **Schema**:
  * `id`: `String`
  * `title`: `String`
  * `artist`: `String`
  * `duration`: `String`
  * `audioUrl`: `String`
  * `imageUrl`: `String?`
  * `category`: `String`
  * `isFeatured`: `bool`

### `MusicHistory`
* **File**: [music_history.dart](file:///c:/Users/kuldeep/OneDrive/Desktop/mental%20mantra/lib/models/music_history.dart)
* **Firestore Collection**: `/music_history/{docId}`
* **Schema**:
  * `id`: `String`
  * `userId`: `String`
  * `trackId`: `String`
  * `playedAt`: `DateTime` (stored as ISO8601 String)
  * `completed`: `bool`

### `MusicGenerationRequest` / `MusicGenerationResponse`
* **Files**: [music_generation_request.dart](file:///c:/Users/kuldeep/OneDrive/Desktop/mental%20mantra/lib/models/music_generation_request.dart), [music_generation_response.dart](file:///c:/Users/kuldeep/OneDrive/Desktop/mental%20mantra/lib/models/music_generation_response.dart)
* **Usage**: Hugging Face generation payloads.
* **Schema (Request)**:
  * `prompt`: `String`
  * `duration`: `int`
  * `temperature`: `double`
* **Schema (Response)**:
  * `audioUrl`: `String`
  * `prompt`: `String`
  * `duration`: `int`

---

## 4. Daily Logs & Health

### `JournalEntry`
* **File**: [journal_entry.dart](file:///c:/Users/kuldeep/OneDrive/Desktop/mental%20mantra/lib/models/journal_entry.dart)
* **Firestore Collection**: `/journals/{docId}`
* **Schema**:
  * `id`: `String`
  * `userId`: `String`
  * `title`: `String`
  * `content`: `String`
  * `mood`: `String`
  * `createdAt`: `DateTime` (stored as ISO8601 String)

### `GratitudeEntry`
* **File**: [gratitude_entry.dart](file:///c:/Users/kuldeep/OneDrive/Desktop/mental%20mantra/lib/models/gratitude_entry.dart)
* **Firestore Collection**: `/gratitude_entries/{docId}`
* **Schema**:
  * `id`: `String`
  * `userId`: `String`
  * `things`: `List<String>`
  * `createdAt`: `DateTime` (stored as ISO8601 String)

### `HealthMetrics`
* **File**: [health_metrics.dart](file:///c:/Users/kuldeep/OneDrive/Desktop/mental%20mantra/lib/models/health_metrics.dart)
* **Firestore Collection**: `/health_metrics/{docId}`
* **Schema**:
  * `id`: `String`
  * `userId`: `String`
  * `steps`: `int`
  * `sleepMinutes`: `int`
  * `waterMl`: `int`
  * `mood`: `String`
  * `date`: `DateTime` (stored as ISO8601 String)

### `MealLog`
* **File**: [meal_log.dart](file:///c:/Users/kuldeep/OneDrive/Desktop/mental%20mantra/lib/models/meal_log.dart)
* **Firestore Collection**: `/meal_logs/{docId}`
* **Schema**:
  * `id`: `String`
  * `userId`: `String`
  * `mealType`: `String` (e.g., Breakfast, Lunch)
  * `foodName`: `String`
  * `calories`: `int`
  * `createdAt`: `DateTime` (stored as ISO8601 String)

### `SleepLog`
* **File**: [sleep_log.dart](file:///c:/Users/kuldeep/OneDrive/Desktop/mental%20mantra/lib/models/sleep_log.dart)
* **Schema**:
  * `id`: `String`
  * `userId`: `String`
  * `durationMinutes`: `int`
  * `quality`: `String`
  * `notes`: `String?`
  * `createdAt`: `DateTime` (stored as ISO8601 String)

---

## 5. Recovery & Habits

### `Habit`
* **File**: [habit.dart](file:///c:/Users/kuldeep/OneDrive/Desktop/mental%20mantra/lib/models/habit.dart)
* **Schema**:
  * `id`: `String`
  * `title`: `String`
  * `category`: `String`
  * `frequency`: `String`
  * `streak`: `int`

### `HabitLog`
* **File**: [habit_log.dart](file:///c:/Users/kuldeep/OneDrive/Desktop/mental%20mantra/lib/models/habit_log.dart)
* **Schema**:
  * `id`: `String`
  * `habitId`: `String`
  * `completedAt`: `DateTime` (stored as ISO8601 String)

### `UrgeLog`
* **File**: [urge_log.dart](file:///c:/Users/kuldeep/OneDrive/Desktop/mental%20mantra/lib/models/urge_log.dart)
* **Firestore Collection**: `/urge_logs/{docId}`
* **Schema**:
  * `id`: `String`
  * `userId`: `String`
  * `intensity`: `int` (scale 1-10)
  * `trigger`: `String`
  * `notes`: `String?`
  * `createdAt`: `DateTime` (stored as ISO8601 String)

### `RecoveryMilestone`
* **File**: [recovery_milestone.dart](file:///c:/Users/kuldeep/OneDrive/Desktop/mental%20mantra/lib/models/recovery_milestone.dart)
* **Firestore Collection**: `/recovery_milestones/{docId}`
* **Schema**:
  * `id`: `String`
  * `userId`: `String`
  * `title`: `String`
  * `daysNeeded`: `int`
  * `unlockedAt`: `DateTime` (stored as ISO8601 String)

---

## 6. AI Profile & Subscriptions

### `AIProfile`
* **File**: [ai_profile.dart](file:///c:/Users/kuldeep/OneDrive/Desktop/mental%20mantra/lib/models/ai_profile.dart)
* **Firestore Collection**: `/user_ai_profiles/{userId}`
* **Schema**:
  * `userId`: `String` (Document ID)
  * `companionName`: `String`
  * `companionGender`: `String`
  * `tone`: `String`
  * `personality`: `String`
  * `customInstructions`: `String`

### `SubscriptionPlan`
* **File**: [subscription_plan.dart](file:///c:/Users/kuldeep/OneDrive/Desktop/mental%20mantra/lib/models/subscription_plan.dart)
* **Schema**:
  * `id`: `String`
  * `name`: `String`
  * `price`: `double`
  * `features`: `List<String>`
  * `billingPeriod`: `String`

### `UserSubscription`
* **File**: [user_subscription.dart](file:///c:/Users/kuldeep/OneDrive/Desktop/mental%20mantra/lib/models/user_subscription.dart)
* **Firestore Collection**: `/subscriptions/{docId}`
* **Schema**:
  * `id`: `String`
  * `userId`: `String`
  * `planId`: `String`
  * `status`: `String`
  * `expiryDate`: `DateTime` (stored as ISO8601 String)

---

## 7. Gamification & Resources

### `PointsAccount`
* **File**: [points_account.dart](file:///c:/Users/kuldeep/OneDrive/Desktop/mental%20mantra/lib/models/points_account.dart)
* **Firestore Collection**: `/points_accounts/{docId}`
* **Schema**:
  * `id`: `String`
  * `userId`: `String`
  * `totalPoints`: `int`
  * `redeemedPoints`: `int`

### `RewardItem`
* **File**: [reward_item.dart](file:///c:/Users/kuldeep/OneDrive/Desktop/mental%20mantra/lib/models/reward_item.dart)
* **Schema**:
  * `id`: `String`
  * `title`: `String`
  * `pointsCost`: `int`
  * `description`: `String`

### `EmergencyResource`
* **File**: [emergency_resource.dart](file:///c:/Users/kuldeep/OneDrive/Desktop/mental%20mantra/lib/models/emergency_resource.dart)
* **Schema**:
  * `id`: `String`
  * `title`: `String`
  * `phoneNumber`: `String`
  * `description`: `String`
  * `country`: `String`

### `GuidedVideo`
* **File**: [guided_video.dart](file:///c:/Users/kuldeep/OneDrive/Desktop/mental%20mantra/lib/models/guided_video.dart)
* **Schema**:
  * `id`: `String`
  * `title`: `String`
  * `youtubeId`: `String`
  * `duration`: `String`
  * `domain`: `String`
