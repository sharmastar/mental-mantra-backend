# MENTAL MANTRA

# MASTER BUILD PROMPT

## VERSION 1.0 (Production Ready)

---

# ROLE

You are an elite software engineering team composed of:

* Lead Flutter Architect
* Senior Flutter Developer
* Senior Firebase Engineer
* Senior Backend Engineer
* AI Engineer
* UX Researcher
* UI Designer
* Security Engineer
* DevOps Engineer
* QA Automation Engineer
* Performance Engineer
* Accessibility Specialist

You are responsible for transforming this project into a production-grade AI-powered mental wellness platform.

Never behave like a code generator.

Behave like an experienced engineering team building a real startup.

---

# PRIMARY OBJECTIVE

Build a complete production-ready application.

Never generate:

* placeholder widgets
* TODO comments
* fake implementations
* mock APIs
* temporary repositories
* empty classes
* unfinished screens
* sample business logic

Everything must be production ready.

---

# DEFINITION OF COMPLETE

A feature is NOT complete until ALL of the following exist:

UI

Business Logic

Repository

Model

Firebase Integration

Offline Cache

Validation

Navigation

Animations

Error Handling

Loading State

Empty State

Retry Logic

Testing

Accessibility

Responsive Design

Production Optimization

---

# PROJECT GOALS

Mental Mantra is NOT a simple meditation app.

It is an AI-powered personalized mental wellness platform that combines:

Psychology

Lifestyle Science

Mindfulness

Behavior Tracking

Journaling

Habit Improvement

AI Personalization

Evidence-informed wellness guidance

Optional spiritual wellness practices presented inclusively

Never present the app as a medical diagnostic tool. Align with the document's positioning as a wellness-support platform. 

---

# CORE PRINCIPLES

Every feature must be

Beautiful

Reliable

Fast

Scalable

Maintainable

Reusable

Secure

Offline-first

Responsive

Accessible

Production Ready

---

# CODING STANDARDS

Use latest stable Flutter.

Use null safety everywhere.

Avoid deprecated APIs.

Never duplicate logic.

Prefer composition over inheritance.

Keep widgets small.

Follow SOLID principles.

Follow Clean Architecture.

Follow Repository Pattern.

Use dependency injection.

Separate UI from Business Logic.

Every function should have one responsibility.

Never place business logic inside widgets.

---

# PROJECT STRUCTURE

lib/

core/

config/

constants/

theme/

router/

errors/

extensions/

utils/

services/

widgets/

models/

repositories/

features/

authentication/

onboarding/

dashboard/

mood/

journal/

meditation/

music/

therapy/

community/

profile/

notifications/

goals/

analytics/

settings/

offline/

spiritual/

wellness/

shared/

assets/

test/

---

# STATE MANAGEMENT

Use only one architecture consistently.

Preferred:

Riverpod

or

Bloc

Never mix:

Riverpod

Provider

GetX

Bloc

Choose one.

---

# DEPENDENCY INJECTION

Implement dependency injection across the entire project.

Every service

Every repository

Every API

Every local storage

Every AI module

must be injectable.

---

# LOCAL DATABASE

Use Hive.

Cache

Mood History

Journal

Recommendations

Quotes

Settings

Goals

Meditation Progress

Yoga Progress

Offline Queue

Authentication Tokens

Sync Status

---

# CLOUD

Firebase

Firestore

Firebase Authentication

Firebase Storage

Firebase Messaging

Crashlytics

Analytics

Remote Config

Performance Monitoring

---

# FIRESTORE DESIGN

Create scalable collections.

Example

users/

profiles/

onboarding/

mood_entries/

journal_entries/

therapy_sessions/

recommendations/

notifications/

quotes/

goals/

streaks/

achievements/

meditation/

music/

yoga/

community_posts/

comments/

likes/

support_groups/

analytics/

sync_queue/

---

# NETWORK LAYER

Create

API Client

Request Interceptor

Authentication Interceptor

Retry Policy

Timeout Policy

Error Mapper

Response Parser

Network Status Detection

Offline Queue

---

# ERROR HANDLING

Every feature must support

Loading

Success

Failure

Retry

Offline

Unauthorized

Unknown Error

Validation Error

---

# LOGGING

Implement structured logging.

Separate

Debug Logs

API Logs

Authentication Logs

AI Logs

Firestore Logs

Offline Sync Logs

Crash Logs

---

# SECURITY

Never expose

API Keys

Secrets

Firebase Tokens

JWT

Private Keys

Environment variables

must be secured.

---

# PERFORMANCE

Optimize

Startup

Memory

Scrolling

Image Loading

Animations

Caching

Pagination

Lazy Loading

Background Tasks

Offline Sync

---

# ACCESSIBILITY

Support

Large Fonts

Screen Readers

Color Contrast

Keyboard Navigation

Voice Control

TalkBack

VoiceOver

Responsive Layout

---

# LOCALIZATION

Design the application to support multiple languages.

Initially include:

English

Hindi

Punjabi

Architecture must allow additional languages without refactoring.

---

# UI DESIGN SYSTEM

Follow a consistent design language.

Use:

Material 3

Modern cards

Rounded corners

Smooth transitions

Micro animations

Consistent spacing

Soft shadows

Premium typography

Dark mode

Light mode

Adaptive layouts

---

# APP EXPERIENCE

The application should feel

Calm

Warm

Professional

Supportive

Encouraging

Never make users feel judged.

The onboarding language should be conversational and empathetic, with positive reinforcement, as described in the Mental Mantra specification. 

---

# PROHIBITED OUTPUT

Never generate

Lorem Ipsum

Sample Text

Fake Quotes

Placeholder Images

Dummy APIs

Hardcoded Responses

Random JSON

Temporary Widgets

TODO comments

FIXME comments

---

# QUALITY GATE

Before considering ANY feature complete verify:

✓ Clean Architecture

✓ Repository Pattern

✓ Responsive UI

✓ Accessibility

✓ Firebase Connected

✓ Hive Connected

✓ Offline Support

✓ Error Handling

✓ Loading State

✓ Testing

✓ Production Ready

---

# IMPORTANT GLOBAL RULES

The app must never:

Diagnose mental illnesses.

Promise cures.

Guarantee recovery.

Replace professional healthcare.

Instead position itself as:

**"An AI-powered personalized mental wellness and emotional support platform integrating psychology, mindfulness, lifestyle science, and culturally adaptive wellbeing practices."** 

---

## END OF PART 1

---

# PART 2A — BACKEND ARCHITECTURE & FIREBASE

This section defines the backend foundation of the Mental Mantra application.

---

# BACKEND PHILOSOPHY

The backend must be production-grade.

Never use:

* Temporary APIs
* Mock Firestore
* Dummy repositories
* Fake authentication
* Sample data

Everything must connect to real Firebase services.

The backend must support:

* Millions of users
* Offline-first architecture
* Real-time synchronization
* Secure authentication
* AI personalization
* Analytics
* Push notifications
* Future scalability

---

# BACKEND ARCHITECTURE

Follow Clean Architecture.

Presentation Layer

↓

Business Logic Layer

↓

Repository Layer

↓

Data Sources

↓

Firebase Services

↓

Local Cache (Hive)

↓

Network Layer

Never allow UI to communicate directly with Firebase.

Every request must pass through repositories.

---

# FIREBASE SERVICES

Configure:

Firebase Authentication

Cloud Firestore

Firebase Storage

Firebase Cloud Messaging

Firebase Analytics

Firebase Crashlytics

Firebase Performance Monitoring

Firebase Remote Config

App Check

Cloud Functions (future-ready)

---

# FIREBASE INITIALIZATION

Initialize Firebase before any service.

Configure:

Android

iOS

Web

Desktop (optional)

Handle initialization failures gracefully.

Retry automatically.

Show user-friendly error messages.

---

# FIREBASE PROJECT CONFIGURATION

Enable:

Authentication

Firestore

Storage

Messaging

Analytics

Crashlytics

Performance

App Check

Disable anonymous write access.

Never expose configuration secrets.

---

# APP CHECK

Enable Firebase App Check.

Support:

Android Play Integrity

Apple App Attest

Web reCAPTCHA Enterprise

Reject unauthorized clients.

---

# ENVIRONMENT CONFIGURATION

Create environments.

Development

Staging

Production

Each environment must have:

Firebase Project

API Keys

Remote Config

Analytics

Crash Reporting

Storage Bucket

Notification Topics

Never hardcode keys.

Use environment configuration.

---

# FOLDER STRUCTURE

lib/

core/

firebase/

auth/

database/

storage/

notification/

analytics/

remote_config/

repositories/

models/

services/

utils/

---

# FIREBASE SERVICE LAYER

Create dedicated services.

AuthenticationService

FirestoreService

StorageService

NotificationService

AnalyticsService

CrashlyticsService

PerformanceService

RemoteConfigService

AppCheckService

AIService

Every service must be injectable.

---

# REPOSITORY LAYER

Repositories communicate with Firebase.

Never call Firebase directly from UI.

Example:

AuthenticationRepository

MoodRepository

JournalRepository

RecommendationRepository

MeditationRepository

MusicRepository

YogaRepository

CommunityRepository

NotificationRepository

ProfileRepository

SettingsRepository

AnalyticsRepository

---

# MODEL DESIGN

Every Firestore document must have:

id

createdAt

updatedAt

createdBy

version

isDeleted

syncStatus

deviceId

This allows:

Versioning

Conflict resolution

Offline sync

Recovery

Audit trail

---

# TIMESTAMP RULES

Never use device time for authoritative records.

Use Firestore server timestamps.

Store:

createdAt

updatedAt

lastSyncedAt

---

# DOCUMENT VERSIONING

Every document must support:

Version number

Last modified timestamp

Sync status

Merge conflict detection

Soft deletion

Recovery

---

# SOFT DELETE

Never permanently delete immediately.

Instead:

isDeleted = true

deletedAt = timestamp

Allow recovery within retention period.

---

# STORAGE RULES

Store:

Profile Images

Journal Images

Voice Notes

Meditation Downloads

Music Cache

Community Images

Never store large blobs inside Firestore.

Use Firebase Storage.

---

# IMAGE MANAGEMENT

Compress before upload.

Generate thumbnails.

Support:

JPEG

PNG

WEBP

HEIC

Limit upload size.

Retry failed uploads.

Show upload progress.

---

# VOICE NOTE STORAGE

Store recordings in Firebase Storage.

Save metadata in Firestore.

Metadata includes:

Duration

Size

Transcription Status

AI Summary Status

Created Time

---

# CACHE STRATEGY

Hive stores:

Recent Journals

Mood Entries

Recommendations

Meditation History

Downloaded Music

Quotes

Goals

Notifications

Profile

Settings

Sync Queue

---

# OFFLINE-FIRST STRATEGY

The application must work without internet.

Users can:

Create Journals

Track Mood

Complete Meditation

Update Goals

Write Notes

Browse Cached Recommendations

Queue uploads.

Sync automatically when internet returns.

---

# DATA SYNCHRONIZATION

Implement intelligent synchronization.

Detect:

New documents

Updated documents

Deleted documents

Merge conflicts

Retry failures

Never overwrite newer data.

---

# CONFLICT RESOLUTION

If conflict occurs:

Compare

updatedAt

version

deviceId

Merge intelligently.

Never lose user data.

---

# CLOUD FUNCTIONS (Future Ready)

Design architecture for:

AI Processing

Journal Summaries

Recommendation Updates

Push Notifications

Community Moderation

Scheduled Reports

Weekly Wellness Summary

Daily Quotes

Future features should plug in without refactoring.

---

# PUSH NOTIFICATIONS

Support:

Daily Mood Reminder

Journal Reminder

Meditation Reminder

Sleep Reminder

Hydration Reminder

Goal Reminder

Achievement Notification

Community Activity

Emergency Support Messages

Allow users to customize notification preferences.

---

# ANALYTICS

Track anonymously:

App Opens

Session Duration

Feature Usage

Meditation Time

Mood Tracking Frequency

Journal Frequency

Streak Progress

AI Interaction Count

Community Engagement

Never log journal content or personally sensitive free-text responses.

---

# CRASH REPORTING

Automatically report:

Unhandled Exceptions

Flutter Errors

Firebase Errors

API Errors

Offline Sync Errors

Image Upload Failures

Authentication Errors

Attach:

App Version

Device Type

OS Version

Network Status

Never include personal user content.

---

# REMOTE CONFIG

Remote Config must control:

Feature Flags

Quote Rotation

Meditation Catalog

Music Categories

Notification Timing

Maintenance Mode

Community Visibility

Experimental Features

Never require app updates for simple configuration changes.

---

# BACKUP STRATEGY

Support:

Automatic Cloud Backup

Local Backup

Restore from Cloud

Restore after Device Change

User Data Export

Account Recovery

---

# BACKEND QUALITY CHECKLIST

Before considering backend complete verify:

✓ Firebase initialized

✓ Firestore connected

✓ Storage connected

✓ Authentication connected

✓ Crashlytics working

✓ Analytics working

✓ Performance Monitoring enabled

✓ Remote Config working

✓ App Check enabled

✓ Offline mode functional

✓ Sync engine working

✓ Storage optimized

✓ Versioning implemented

✓ Soft delete implemented

✓ No direct Firebase calls from UI

✓ Repository pattern enforced

✓ Dependency injection complete

✓ Environment separation complete

✓ Production ready

---

## END OF PART 2A

---

# PART 2B — AUTHENTICATION, USER MANAGEMENT & SECURITY

---

# AUTHENTICATION PHILOSOPHY

Authentication must be enterprise-grade.

The authentication system must prioritize:

* Security
* Privacy
* Reliability
* Scalability
* Fast Login
* Session Recovery
* Offline Awareness

Never store passwords locally.

Never expose authentication tokens.

Never bypass authentication checks.

---

# AUTHENTICATION FLOW

Support the following methods:

* Email & Password
* Google Sign-In
* Apple Sign-In (iOS)
* Phone Number + OTP (optional)
* Anonymous Guest Mode (optional, with limited functionality)

Future-ready:

* Microsoft Login
* GitHub Login
* Facebook Login

---

# FIRST APP LAUNCH

On first launch:

1. Show Splash Screen
2. Check App Version
3. Initialize Firebase
4. Check Internet
5. Initialize Hive
6. Initialize Remote Config
7. Initialize Notifications
8. Check Authentication Status

If authenticated:

→ Restore session

Else:

→ Navigate to Welcome Screen

---

# AUTHENTICATION NAVIGATION

Flow:

Splash Screen

↓

Welcome Screen

↓

Login / Signup

↓

Email Verification

↓

Complete Onboarding

↓

Dashboard

---

# SIGNUP SCREEN

Collect:

Full Name

Preferred Nickname (optional)

Email Address

Password

Confirm Password

Country

Accept Privacy Policy

Accept Terms & Conditions

Consent Checkbox:

"I understand Mental Mantra is a wellness-support platform and not a substitute for medical diagnosis or emergency psychiatric care."

Do not allow signup without consent.

---

# PASSWORD REQUIREMENTS

Minimum 8 characters.

Must contain:

Uppercase

Lowercase

Number

Special Character

Reject weak passwords.

Show password strength indicator.

---

# LOGIN SCREEN

Support:

Email

Password

Google Login

Apple Login

Remember Me

Forgot Password

Show/hide password

Biometric Login (optional)

---

# GOOGLE SIGN-IN

After successful login:

Create user if first login.

Update:

lastLoginAt

deviceInfo

platform

FCM Token

If account already exists with same email:

Link providers where appropriate.

Handle errors gracefully.

---

# APPLE SIGN-IN

Required for iOS.

Handle:

Private Email Relay

First Login

Returning Users

Account Linking

---

# EMAIL VERIFICATION

Immediately after signup:

Send verification email.

Prevent access to onboarding until verified, unless you intentionally support limited pre-verification flows.

Provide:

Resend Email

Change Email

Refresh Status

Auto-check verification.

---

# FORGOT PASSWORD

Flow:

Enter Email

↓

Send Reset Link

↓

Confirmation Screen

↓

Password Reset

↓

Login

Validate email before sending.

Rate-limit repeated requests.

---

# PHONE OTP (Optional)

Future-ready.

Support:

Country Code

Auto Detect Country

OTP Auto Read

Manual OTP Entry

Resend Timer

Maximum Retry Limit

Auto Verify

---

# SESSION MANAGEMENT

Maintain secure sessions.

Remember Me

Refresh Tokens

Automatic Login

Secure Logout

Session Expiry

Multiple Device Support

---

# SECURE LOGOUT

On logout:

Clear Tokens

Clear Cached Credentials

Revoke Sessions (where supported)

Retain user-generated local content only if the user chooses to keep offline data.

Return to Login Screen.

---

# USER PROFILE MODEL

Each user must include:

userId

fullName

nickname

email

photoUrl

gender

ageGroup

country

timezone

language

createdAt

updatedAt

lastLogin

isVerified

isPremium

accountStatus

onboardingCompleted

wellnessProfileId

notificationSettings

privacySettings

securitySettings

---

# ACCOUNT STATUS

Support:

Active

Pending Verification

Suspended

Deleted

Blocked

Archived

---

# USER ROLES

Future-ready:

User

Moderator

Counselor (future)

Administrator

Super Admin

Use role-based permissions.

---

# PRIVACY SETTINGS

Allow users to control:

Profile Visibility

Community Visibility

Anonymous Posting

AI Memory

Data Sharing

Analytics Sharing

Push Notifications

Email Notifications

Voice Recording Storage

Location Sharing (default off)

---

# SECURITY SETTINGS

Provide:

Change Password

Biometric Lock

Device Management

Login History

Connected Accounts

Delete Account

Download My Data

---

# DELETE ACCOUNT

Two-step confirmation.

Inform users that:

Cloud data will be deleted according to the retention policy.

Offer:

Export Data

Cancel

Continue

Soft-delete first, then permanently remove after the retention period unless legal or safety obligations require otherwise.

---

# ACCOUNT RECOVERY

Support:

Password Reset

Email Change

Device Change

Session Recovery

Backup Restore

---

# BIOMETRIC LOGIN

Support:

Fingerprint

Face Unlock

Face ID

Windows Hello (Desktop)

Biometrics should unlock the local session but must not replace server-side authentication.

---

# DEVICE MANAGEMENT

Track:

Device Name

OS

Login Time

Location (country-level if available)

Last Active

Allow:

Remove Device

Logout Specific Device

Logout All Devices

---

# LOGIN SECURITY

Implement:

Rate Limiting

Brute Force Protection

Session Timeout

Failed Login Counter

Suspicious Login Detection

Email Alerts for New Devices

---

# INPUT VALIDATION

Validate:

Email

Password

Phone

OTP

Nickname

Name

Country

Trim whitespace.

Reject invalid formats.

Sanitize user input before storage.

---

# AUTHENTICATION ERROR HANDLING

Handle:

Invalid Email

Weak Password

Wrong Password

Account Not Found

Email Already Exists

Too Many Requests

No Internet

Firebase Error

Unknown Error

Provide user-friendly messages.

Never expose internal error details.

---

# TERMS & PRIVACY

Users must explicitly accept:

Privacy Policy

Terms & Conditions

Consent Statement

Record acceptance timestamp and version.

---

# AUTHENTICATION QUALITY CHECKLIST

Before authentication is complete verify:

✓ Email Signup

✓ Email Login

✓ Google Login

✓ Apple Login

✓ Email Verification

✓ Forgot Password

✓ Secure Sessions

✓ Remember Me

✓ Logout

✓ Delete Account

✓ Privacy Settings

✓ Security Settings

✓ Role-Based Access

✓ Device Management

✓ Input Validation

✓ Error Handling

✓ Firebase Authentication Working

✓ No Security Vulnerabilities

✓ Production Ready

---

## END OF PART 2B

---

# PART 2C-1 — COMPLETE FIRESTORE DATABASE DESIGN: COLLECTIONS & SCHEMA

This section defines every Firestore collection, document schema, field type, and constraint.

---

# DATABASE PHILOSOPHY

Firestore is the authoritative data source.

Every collection must:

* Use consistent field naming
* Include base fields on every document
* Support offline-first reads and writes
* Enable efficient queries with minimal indexes
* Store only what is necessary — avoid document bloat
* Use subcollections for 1-to-many relationships where documents may grow unbounded

---

# BASE FIELDS (Every Document)

Every document in every collection MUST include:

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| id | string | yes | Document ID (Firestore doc id) |
| createdAt | timestamp | yes | Firestore server timestamp |
| updatedAt | timestamp | yes | Firestore server timestamp |
| createdBy | string | yes | User ID who created it |
| version | number | yes | Incrementing version counter |
| isDeleted | boolean | yes | Soft delete flag |
| syncStatus | string | yes | pending / synced / conflict / failed |
| deviceId | string | yes | Device that last modified |

---

# COLLECTION: users

Collection ID: `users`
Document ID: `{userId}` (Firebase Auth UID)

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| fullName | string | yes | Legal or full display name |
| nickname | string | no | Preferred name |
| email | string | yes | Email address |
| photoUrl | string | no | Profile photo URL |
| gender | string | no | self-described |
| ageGroup | string | no | 13-17 / 18-24 / 25-34 / 35-44 / 45-54 / 55+ |
| country | string | yes | ISO country code |
| timezone | string | yes | IANA timezone |
| language | string | yes | Preferred language code |
| createdAt | timestamp | yes | |
| updatedAt | timestamp | yes | |
| lastLoginAt | timestamp | yes | |
| isVerified | boolean | yes | Email verified |
| isPremium | boolean | yes | Premium subscription |
| accountStatus | string | yes | active / pending / suspended / deleted / blocked / archived |
| onboardingCompleted | boolean | yes | |
| onboardingStep | string | yes | Current onboarding step |
| termsAcceptedAt | timestamp | no | |
| termsVersion | string | no | |
| privacyAcceptedAt | timestamp | no | |
| privacyVersion | string | no | |
| consentWellnessAcknowledged | boolean | yes | |
| fcmToken | string | no | Push notification token |
| fcmTokenUpdatedAt | timestamp | no | |
| devicePlatform | string | no | android / ios / web |
| appVersion | string | no | Current app version |
| isDeleted | boolean | yes | |
| version | number | yes | |
| syncStatus | string | yes | |

---

# COLLECTION: profiles

Collection ID: `profiles`
Document ID: `{userId}` (1:1 with users)

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| userId | string | yes | Reference to users |
| bio | string | no | Short bio |
| dateOfBirth | timestamp | no | For age-based personalization |
| occupation | string | no | |
| interests | array<string> | no | Interest tags |
| wellnessGoals | array<string> | no | Goal tags |
| meditationExperience | string | no | beginner / intermediate / advanced |
| yogaExperience | string | no | beginner / intermediate / advanced |
| preferredMeditationDuration | number | no | Minutes preferred |
| preferredMeditationType | string | no | guided / unguided / breathing / body_scan / loving_kindness |
| preferredMusicGenre | array<string> | no | |
| emergencyContact | string | no | Optional emergency contact |
| emergencyContactPhone | string | no | |
| crisisPlan | string | no | User-defined crisis plan text |
| isAnonymous | boolean | yes | Community anonymity |
| showInCommunity | boolean | yes | Community visibility |
| allowAiMemory | boolean | yes | Allow AI to remember context |
| dataSharingConsent | boolean | yes | Analytics opt-in |
| version | number | yes | |
| createdAt | timestamp | yes | |
| updatedAt | timestamp | yes | |
| isDeleted | boolean | yes | |
| syncStatus | string | yes | |

---

# COLLECTION: wellness_profiles

Collection ID: `wellness_profiles`
Document ID: `{userId}` (1:1)

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| userId | string | yes | |
| baselineMood | number | no | Average mood score (1-10) |
| dominantMoodTags | array<string> | no | Most frequent mood tags |
| commonTriggers | array<string> | no | User-reported triggers |
| copingStrategies | array<string> | no | What helps user |
| journalInsights | string | no | AI-generated insight summary |
| recommendationModel | string | no | Current AI model version |
| lastRecommendationRefresh | timestamp | no | |
| streakData | map | no | { current: int, longest: int, lastActivity: timestamp } |
| wellnessScore | number | no | Composite wellness score |
| scoreHistory | array<map> | no | [{ score, date }] last 90 days |
| version | number | yes | |
| createdAt | timestamp | yes | |
| updatedAt | timestamp | yes | |
| isDeleted | boolean | yes | |
| syncStatus | string | yes | |

---

# COLLECTION: mood_entries

Collection ID: `mood_entries`
Document ID: `{autoId}`
Subcollection of: `users/{userId}/mood_entries` (preferred for privacy/scalability)

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| userId | string | yes | |
| moodScore | number | yes | 1-10 scale |
| moodLabel | string | yes | Label from picker (e.g., "calm", "anxious") |
| moodTags | array<string> | no | Up to 5 tags |
| note | string | no | Optional note |
| trigger | string | no | What triggered the mood |
| context | string | no | Where/when (home, work, etc.) |
| physicalState | map | no | { sleep: int, energy: int, hunger: int } |
| isPrivate | boolean | yes | |
| aiInsight | string | no | AI-generated reflection |
| aiInsightGeneratedAt | timestamp | no | |
| date | timestamp | yes | Date of entry (user-local date) |
| entryType | string | yes | check_in / reflection / triggered |
| version | number | yes | |
| createdAt | timestamp | yes | |
| updatedAt | timestamp | yes | |
| isDeleted | boolean | yes | |
| syncStatus | string | yes | |

Index: `userId + date` (descending)
Index: `userId + createdAt` (descending)

---

# COLLECTION: journal_entries

Collection ID: `journal_entries`
Document ID: `{autoId}`
Subcollection of: `users/{userId}/journal_entries`

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| userId | string | yes | |
| title | string | no | Entry title (auto-generated if empty) |
| content | string | yes | Journal body text |
| contentType | string | yes | text / voice / image |
| voiceNoteUrl | string | no | Storage URL if voice entry |
| voiceNoteDuration | number | no | Duration in seconds |
| voiceTranscription | string | no | Auto-transcribed text |
| transcriptionStatus | string | yes | pending / completed / failed |
| imageUrls | array<string> | no | Storage URLs |
| moodScore | number | no | Associated mood (1-10) |
| moodTags | array<string> | no | |
| tags | array<string> | no | User-defined tags |
| prompt | string | no | Journal prompt used |
| isPrivate | boolean | yes | |
| aiAnalysis | map | no | { sentiment, topics, keywords, summary, suggestions } |
| aiAnalysisVersion | string | no | |
| aiAnalysisGeneratedAt | timestamp | no | |
| date | timestamp | yes | User-local date |
| version | number | yes | |
| createdAt | timestamp | yes | |
| updatedAt | timestamp | yes | |
| isDeleted | boolean | yes | |
| syncStatus | string | yes | |

Index: `userId + date` (descending)
Index: `userId + createdAt` (descending)
Index: `userId + tags` (array)

---

# COLLECTION: check_ins

Collection ID: `check_ins`
Document ID: `{autoId}`
Subcollection of: `users/{userId}/check_ins`

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| userId | string | yes | |
| date | timestamp | yes | |
| moodScore | number | yes | 1-10 |
| energyLevel | number | yes | 1-10 |
| sleepHours | number | no | |
| sleepQuality | number | no | 1-5 |
| waterIntake | number | no | Glasses |
| meals | number | no | Meals eaten |
| exerciseMinutes | number | no | |
| socialInteraction | number | no | 1-5 scale |
| stressLevel | number | no | 1-10 |
| gratitudeEntry | string | no | What user is grateful for |
| aiBrief | string | no | One-line AI summary |
| version | number | yes | |
| createdAt | timestamp | yes | |
| updatedAt | timestamp | yes | |
| isDeleted | boolean | yes | |
| syncStatus | string | yes | |

Index: `userId + date` (descending)

---

# COLLECTION: goals

Collection ID: `goals`
Document ID: `{autoId}`
Subcollection of: `users/{userId}/goals`

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| userId | string | yes | |
| title | string | yes | Goal title |
| description | string | no | |
| category | string | yes | mindfulness / fitness / sleep / social / productivity / self_care / spiritual / custom |
| goalType | string | yes | daily / weekly / monthly / custom |
| targetValue | number | no | e.g., 10 (minutes), 3 (times) |
| unit | string | no | minutes / times / sessions / pages |
| currentValue | number | yes | Progress so far |
| startDate | timestamp | yes | |
| endDate | timestamp | no | Optional target end date |
| isRecurring | boolean | yes | |
| recurringDays | array<number> | no | Days of week (0=Sun) |
| reminderTime | string | no | HH:mm format |
| reminderEnabled | boolean | yes | |
| status | string | yes | active / paused / completed / archived / failed |
| completedDates | array<timestamp> | no | Dates completed (for daily) |
| streak | number | yes | Current streak |
| longestStreak | number | yes | |
| notes | string | no | |
| aiSuggestion | string | no | AI-generated tip |
| version | number | yes | |
| createdAt | timestamp | yes | |
| updatedAt | timestamp | yes | |
| isDeleted | boolean | yes | |
| syncStatus | string | yes | |

Index: `userId + status` (filter)
Index: `userId + category + status`

---

# COLLECTION: habits

Collection ID: `habits`
Document ID: `{autoId}`
Subcollection of: `users/{userId}/habits`

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| userId | string | yes | |
| name | string | yes | |
| description | string | no | |
| category | string | yes | |
| frequency | string | yes | daily / weekly / monthly |
| targetCount | number | yes | Times per frequency period |
| currentStreak | number | yes | |
| longestStreak | number | yes | |
| totalCompletions | number | yes | |
| isGood | boolean | yes | true = build, false = break |
| reminderTimes | array<string> | no | ["HH:mm"] |
| color | string | no | Hex color for UI |
| icon | string | no | Icon name |
| version | number | yes | |
| createdAt | timestamp | yes | |
| updatedAt | timestamp | yes | |
| isDeleted | boolean | yes | |
| syncStatus | string | yes | |

Subcollection: `habit_logs/{logId}`
| Field | Type | Required |
|-------|------|----------|
| date | timestamp | yes |
| completed | boolean | yes |
| value | number | no |
| note | string | no |

---

# COLLECTION: meditation_sessions (Content)

Collection ID: `meditation_sessions`
Document ID: `{autoId}` (root collection, admin-managed)

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| title | string | yes | |
| titleLocalized | map | no | { en, hi, pa } |
| description | string | yes | |
| descriptionLocalized | map | no | |
| category | string | yes | guided / unguided / breathing / body_scan / loving_kindness / sleep / focus / stress / anxiety / gratitude |
| durationMinutes | number | yes | |
| difficulty | string | yes | beginner / intermediate / advanced |
| audioUrl | string | yes | Storage URL |
| thumbnailUrl | string | no | |
| instructor | string | no | Voice/narrator name |
| musicType | string | no | Background music style |
| tags | array<string> | no | |
| isPremium | boolean | yes | |
| isFeatured | boolean | yes | |
| sortOrder | number | yes | |
| averageRating | number | no | |
| totalSessions | number | no | Times completed globally |
| version | number | yes | |
| createdAt | timestamp | yes | |
| updatedAt | timestamp | yes | |
| isDeleted | boolean | yes | |

---

# COLLECTION: meditation_progress (User)

Collection ID: `meditation_progress`
Document ID: `{autoId}`
Subcollection of: `users/{userId}/meditation_progress`

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| userId | string | yes | |
| sessionId | string | yes | Reference to meditation_sessions |
| durationCompleted | number | yes | Seconds completed |
| rating | number | no | 1-5 |
| notes | string | no | |
| completedAt | timestamp | yes | |
| version | number | yes | |
| createdAt | timestamp | yes | |
| isDeleted | boolean | yes | |
| syncStatus | string | yes | |

Subcollection: `users/{userId}/meditation_stats`

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| totalMinutes | number | yes | |
| totalSessions | number | yes | |
| currentStreak | number | yes | |
| longestStreak | number | yes | |
| lastSessionAt | timestamp | no | |
| weeklyMinutes | array<map> | no | [{ weekStart, minutes }] |

---

# COLLECTION: music_tracks

Collection ID: `music_tracks`
Document ID: `{autoId}` (root collection, admin-managed)

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| title | string | yes | |
| titleLocalized | map | no | |
| artist | string | yes | |
| album | string | no | |
| genre | string | yes | nature / classical / binaural / ambient / instrumental / mantra / white_noise |
| durationSeconds | number | yes | |
| audioUrl | string | yes | Storage URL |
| coverUrl | string | no | |
| isPremium | boolean | yes | |
| isDownloadable | boolean | yes | |
| tags | array<string> | no | |
| bpm | number | no | Beats per minute |
| frequency | string | no | e.g., "432Hz", "528Hz" |
| sortOrder | number | yes | |
| averageRating | number | no | |
| playCount | number | yes | |
| version | number | yes | |
| createdAt | timestamp | yes | |
| updatedAt | timestamp | yes | |
| isDeleted | boolean | yes | |

---

# COLLECTION: music_playlists (User)

Collection ID: `music_playlists`
Document ID: `{autoId}`
Subcollection of: `users/{userId}/playlists`

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| userId | string | yes | |
| name | string | yes | |
| description | string | no | |
| trackIds | array<string> | no | Ordered references |
| isDefault | boolean | yes | System playlist |
| icon | string | no | |
| color | string | no | |
| sortOrder | number | yes | |
| version | number | yes | |
| createdAt | timestamp | yes | |
| updatedAt | timestamp | yes | |
| isDeleted | boolean | yes | |
| syncStatus | string | yes | |

---

# COLLECTION: yoga_sessions (Content)

Collection ID: `yoga_sessions`
Document ID: `{autoId}` (root collection)

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| title | string | yes | |
| titleLocalized | map | no | |
| description | string | yes | |
| category | string | yes | morning / evening / stress_relief / energy / sleep / beginner / intermediate / advanced |
| durationMinutes | number | yes | |
| difficulty | string | yes | beginner / intermediate / advanced |
| videoUrl | string | no | |
| thumbnailUrl | string | no | |
| instructor | string | no | |
| poseCount | number | no | |
| poses | array<map> | no | [{ name, durationSeconds, instructions }] |
| musicTrackId | string | no | Background music reference |
| isPremium | boolean | yes | |
| sortOrder | number | yes | |
| averageRating | number | no | |
| totalSessions | number | yes | |
| version | number | yes | |
| createdAt | timestamp | yes | |
| updatedAt | timestamp | yes | |
| isDeleted | boolean | yes | |

---

# COLLECTION: yoga_progress (User)

Collection ID: `yoga_progress`
Document ID: `{autoId}`
Subcollection of: `users/{userId}/yoga_progress`

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| userId | string | yes | |
| sessionId | string | yes | |
| durationCompleted | number | yes | |
| posesCompleted | number | no | |
| rating | number | no | 1-5 |
| notes | string | no | |
| completedAt | timestamp | yes | |
| version | number | yes | |
| createdAt | timestamp | yes | |
| isDeleted | boolean | yes | |
| syncStatus | string | yes | |

---

# COLLECTION: recommendations

Collection ID: `recommendations`
Document ID: `{autoId}`
Subcollection of: `users/{userId}/recommendations`

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| userId | string | yes | |
| type | string | yes | meditation / music / yoga / journal_prompt / quote / article / activity / self_care / breathing_exercise |
| title | string | yes | |
| description | string | no | |
| referenceId | string | no | ID of referenced content |
| reason | string | no | Why recommended (AI-generated) |
| confidenceScore | number | yes | 0.0-1.0 |
| isRead | boolean | yes | |
| isCompleted | boolean | yes | |
| isDismissed | boolean | yes | |
| generatedAt | timestamp | yes | |
| expiresAt | timestamp | no | When recommendation expires |
| context | map | no | { moodBased, timeBased, goalBased, streakBased } |
| version | number | yes | |
| createdAt | timestamp | yes | |
| updatedAt | timestamp | yes | |
| isDeleted | boolean | yes | |
| syncStatus | string | yes | |

Index: `userId + type + isRead` (filter)
Index: `userId + generatedAt` (desc)

---

# COLLECTION: ai_memory

Collection ID: `ai_memory`
Document ID: `{autoId}`
Subcollection of: `users/{userId}/ai_memory`

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| userId | string | yes | |
| category | string | yes | user_preference / mood_pattern / trigger / coping_strategy / goal_progress / journal_theme / recommendation_feedback / conversation_context |
| key | string | yes | Memory key |
| value | any | yes | Memory value |
| context | string | no | When this was learned |
| confidence | number | yes | 0.0-1.0 |
| source | string | yes | mood_entry / journal / check_in / conversation / recommendation / system |
| expiresAt | timestamp | no | Auto-expire memory |
| isActive | boolean | yes | |
| version | number | yes | |
| createdAt | timestamp | yes | |
| updatedAt | timestamp | yes | |
| isDeleted | boolean | yes | |
| syncStatus | string | yes | |

Index: `userId + category + isActive`
Index: `userId + expiresAt` (for cleanup)

---

# COLLECTION: quotes

Collection ID: `quotes`
Document ID: `{autoId}` (root collection, system-managed)

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| text | string | yes | |
| textLocalized | map | no | { en, hi, pa } |
| author | string | yes | |
| category | string | yes | mindfulness / motivation / gratitude / peace / hope / strength / spirituality / wisdom |
| tags | array<string> | no | |
| isFeatured | boolean | yes | |
| isPremium | boolean | no | |
| sortOrder | number | yes | |
| version | number | yes | |
| createdAt | timestamp | yes | |
| updatedAt | timestamp | yes | |
| isDeleted | boolean | yes | |

Subcollection: `users/{userId}/saved_quotes`

| Field | Type | Required |
|-------|------|----------|
| quoteId | string | yes |
| savedAt | timestamp | yes |
| note | string | no |

---

# COLLECTION: achievements

Collection ID: `achievements`
Document ID: `{autoId}` (root collection, system-managed)

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| name | string | yes | |
| nameLocalized | map | no | |
| description | string | yes | |
| icon | string | yes | Icon name |
| category | string | yes | mood / meditation / journal / yoga / streak / community / goals |
| criteria | map | yes | { type, target, metric } |
| points | number | yes | Gamification points |
| tier | string | yes | bronze / silver / gold / platinum |
| sortOrder | number | yes | |

Subcollection: `users/{userId}/achievements`

| Field | Type | Required |
|-------|------|----------|
| achievementId | string | yes |
| unlockedAt | timestamp | yes |
| isNew | boolean | yes |

---

# COLLECTION: community_posts

Collection ID: `community_posts`
Document ID: `{autoId}` (root collection)

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| userId | string | yes | |
| title | string | yes | |
| content | string | yes | |
| category | string | yes | general / support / gratitude / discussion / tips / mindfulness / spirituality |
| tags | array<string> | no | |
| isAnonymous | boolean | yes | |
| isModerated | boolean | yes | |
| moderationStatus | string | yes | pending / approved / rejected / flagged |
| moderatedBy | string | no | |
| moderatedAt | timestamp | no | |
| rejectionReason | string | no | |
| likeCount | number | yes | |
| commentCount | number | yes | |
| isPinned | boolean | yes | |
| isLocked | boolean | yes | |
| reportCount | number | yes | |
| version | number | yes | |
| createdAt | timestamp | yes | |
| updatedAt | timestamp | yes | |
| isDeleted | boolean | yes | |

Index: `moderationStatus + createdAt` (desc)
Index: `category + createdAt` (desc)
Index: `userId + createdAt` (desc)

---

# COLLECTION: comments

Collection ID: `comments`
Document ID: `{autoId}`
Subcollection of: `community_posts/{postId}/comments`

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| userId | string | yes | |
| content | string | yes | |
| isAnonymous | boolean | yes | |
| isModerated | boolean | yes | |
| moderationStatus | string | yes | |
| parentCommentId | string | no | For nested replies |
| likeCount | number | yes | |
| reportCount | number | yes | |
| version | number | yes | |
| createdAt | timestamp | yes | |
| updatedAt | timestamp | yes | |
| isDeleted | boolean | yes | |

Index: `moderationStatus + createdAt`
Index: `parentCommentId`

---

# COLLECTION: likes

Collection ID: `likes`
Document ID: `{autoId}`
Subcollection of: `community_posts/{postId}/likes`
Also: `comments/{commentId}/likes`

| Field | Type | Required |
|-------|------|----------|
| userId | string | yes |
| targetType | string | yes | post / comment |
| targetId | string | yes |
| createdAt | timestamp | yes |

---

# COLLECTION: support_groups

Collection ID: `support_groups`
Document ID: `{autoId}` (root collection)

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| name | string | yes | |
| nameLocalized | map | no | |
| description | string | yes | |
| category | string | yes | anxiety / stress / grief / mindfulness / gratitude / parenting / sleep / general |
| isPrivate | boolean | yes | |
| joinMethod | string | yes | open / request / invite |
| maxMembers | number | no | |
| memberCount | number | yes | |
| moderatorIds | array<string> | no | |
| rules | string | no | Group rules |
| icon | string | no | |
| coverUrl | string | no | |
| isActive | boolean | yes | |
| version | number | yes | |
| createdAt | timestamp | yes | |
| updatedAt | timestamp | yes | |
| isDeleted | boolean | yes | |

Subcollection: `members/{userId}`
| Field | Type | Required |
|-------|------|----------|
| role | string | yes | member / moderator / admin |
| joinedAt | timestamp | yes |
| isMuted | boolean | yes |

Subcollection: `messages/{messageId}`
| Field | Type | Required |
|-------|------|----------|
| userId | string | yes |
| content | string | yes |
| isAnonymous | boolean | yes |
| moderated | boolean | yes |
| createdAt | timestamp | yes |

---

# COLLECTION: notifications

Collection ID: `notifications`
Document ID: `{autoId}`
Subcollection of: `users/{userId}/notifications`

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| userId | string | yes | |
| type | string | yes | reminder / achievement / recommendation / community / system / wellness_tip / daily_quote / goal / streak / emergency |
| title | string | yes | |
| body | string | yes | |
| data | map | no | Deep link payload |
| isRead | boolean | yes | |
| isActioned | boolean | yes | |
| imageUrl | string | no | |
| scheduledFor | timestamp | no | For scheduled notifications |
| sentAt | timestamp | no | |
| readAt | timestamp | no | |
| category | string | no | Notification channel category |
| priority | string | yes | low / normal / high / urgent |
| version | number | yes | |
| createdAt | timestamp | yes | |
| updatedAt | timestamp | yes | |
| isDeleted | boolean | yes | |
| syncStatus | string | yes | |

Index: `userId + isRead + createdAt` (desc)
Index: `userId + type + createdAt`

---

# COLLECTION: notification_settings

Collection ID: `notification_settings`
Document ID: `{userId}` (1:1 with users)

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| userId | string | yes | |
| moodReminder | boolean | yes | |
| moodReminderTime | string | no | HH:mm |
| journalReminder | boolean | yes | |
| journalReminderTime | string | no | |
| meditationReminder | boolean | yes | |
| meditationReminderTime | string | no | |
| sleepReminder | boolean | yes | |
| sleepReminderTime | string | no | |
| hydrationReminder | boolean | yes | |
| hydrationInterval | number | no | Minutes |
| goalReminders | boolean | yes | |
| achievementNotifications | boolean | yes | |
| communityActivity | boolean | yes | |
| dailyQuote | boolean | yes | |
| dailyQuoteTime | string | no | |
| wellnessTip | boolean | yes | |
| emergencyMessages | boolean | yes | |
| marketingEmails | boolean | yes | |
| soundEnabled | boolean | yes | |
| vibrationEnabled | boolean | yes | |
| quietHoursStart | string | no | HH:mm |
| quietHoursEnd | string | no | HH:mm |
| version | number | yes | |
| createdAt | timestamp | yes | |
| updatedAt | timestamp | yes | |
| isDeleted | boolean | yes | |
| syncStatus | string | yes | |

---

# COLLECTION: therapy_sessions

Collection ID: `therapy_sessions`
Document ID: `{autoId}`
Subcollection of: `users/{userId}/therapy_sessions`

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| userId | string | yes | |
| sessionType | string | yes | ai_chat / journal_reflection / breathing_exercise / grounding_exercise / cbt_exercise / meditation |
| sessionStatus | string | yes | started / in_progress / completed / interrupted |
| startedAt | timestamp | yes | |
| completedAt | timestamp | no | |
| durationSeconds | number | no | |
| conversation | array<map> | no | [{ role, content, timestamp }] |
| aiModelUsed | string | no | |
| sessionSummary | string | no | AI-generated summary |
| moodBefore | number | no | Mood score before session |
| moodAfter | number | no | Mood score after session |
| effectivenessScore | number | no | User rating 1-5 |
| tags | array<string> | no | |
| isPrivate | boolean | yes | |
| version | number | yes | |
| createdAt | timestamp | yes | |
| updatedAt | timestamp | yes | |
| isDeleted | boolean | yes | |
| syncStatus | string | yes | |

Index: `userId + startedAt` (desc)
Index: `userId + sessionType + startedAt`

---

# COLLECTION: onboarding

Collection ID: `onboarding`
Document ID: `{userId}` (1:1)

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| userId | string | yes | |
| currentStep | string | yes | welcome / profile / wellness_goals / meditation_prefs / notification_setup / community_prefs / complete |
| completedSteps | array<string> | yes | |
| skippedSteps | array<string> | no | |
| startedAt | timestamp | yes | |
| completedAt | timestamp | no | |
| version | number | yes | |
| createdAt | timestamp | yes | |
| updatedAt | timestamp | yes | |
| isDeleted | boolean | yes | |
| syncStatus | string | yes | |

---

# COLLECTION: sync_queue

Collection ID: `sync_queue`
Document ID: `{autoId}`
Subcollection of: `users/{userId}/sync_queue`

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| userId | string | yes | |
| operation | string | yes | create / update / delete |
| collection | string | yes | Target collection |
| documentId | string | yes | Target document |
| data | map | yes | Full document data |
| timestamp | timestamp | yes | Local timestamp |
| retryCount | number | yes | |
| maxRetries | number | yes | |
| lastError | string | no | |
| status | string | yes | queued / syncing / failed / completed |
| version | number | yes | |
| createdAt | timestamp | yes | |
| updatedAt | timestamp | yes | |

---

# COLLECTION: analytics_events

Collection ID: `analytics_events`
Document ID: `{autoId}` (root collection, system-managed)

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| userId | string | no | Anonymous if opted out |
| eventName | string | yes | |
| eventParams | map | no | |
| sessionId | string | yes | |
| deviceInfo | map | no | { platform, osVersion, appVersion, deviceModel } |
| timestamp | timestamp | yes | |
| version | number | yes | |

---

# COLLECTION: app_config

Collection ID: `app_config`
Document ID: `{configKey}` (root collection, system-managed)

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| key | string | yes | |
| value | any | yes | |
| type | string | yes | string / number / boolean / json / array |
| description | string | no | |
| updatedBy | string | yes | |
| updatedAt | timestamp | yes | |

---

# COLLECTION: content_reports

Collection ID: `content_reports`
Document ID: `{autoId}` (root collection)

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| reporterId | string | yes | |
| targetType | string | yes | post / comment / user / group |
| targetId | string | yes | |
| reason | string | yes | |
| description | string | no | |
| status | string | yes | pending / reviewed / dismissed / actioned |
| reviewedBy | string | no | |
| reviewedAt | timestamp | no | |
| action | string | no | warning / removed / banned |
| version | number | yes | |
| createdAt | timestamp | yes | |
| updatedAt | timestamp | yes | |

---

# COLLECTION: feedback

Collection ID: `feedback`
Document ID: `{autoId}`
Subcollection of: `users/{userId}/feedback`

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| userId | string | yes | |
| type | string | yes | feature_request / bug_report / general / rating |
| title | string | yes | |
| description | string | no | |
| rating | number | no | 1-5 (for rating type) |
| category | string | no | |
| appVersion | string | yes | |
| deviceInfo | string | no | |
| status | string | yes | submitted / reviewed / planned / implemented / declined |
| version | number | yes | |
| createdAt | timestamp | yes | |
| updatedAt | timestamp | yes | |
| isDeleted | boolean | yes | |

---

# COLLECTION: crisis_resources

Collection ID: `crisis_resources`
Document ID: `{countryCode}` (root collection)

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| country | string | yes | |
| countryCode | string | yes | |
| helplines | array<map> | yes | [{ name, number, hours, description }] |
| emergencyNumber | string | yes | |
| mentalHealthCenters | array<map> | no | [{ name, address, phone, website }] |
| onlineResources | array<map> | no | [{ name, url, description }] |
| version | number | yes | |
| updatedAt | timestamp | yes | |

---

## END OF PART 2C-1

---

# PART 2C-2 — RELATIONSHIPS, INDEXES, SECURITY RULES & DATA FLOW

---

# RELATIONSHIPS OVERVIEW

Firestore is a NoSQL database. Relationships are expressed through:

1. **Subcollections** — For 1-to-many relationships where children grow unbounded (mood_entries, journal_entries, notifications)
2. **Reference fields** — For 1-to-1 or limited 1-to-many (userId fields pointing to users/{id})
3. **Denormalized copies** — For frequently read data (e.g., commentCount on posts)
4. **Map fields** — For embedded data that is always read together (e.g., aiAnalysis on journal_entries)

---

# RELATIONSHIP MAP

```
users (root)
├── profiles (1:1, same doc ID as userId)
├── wellness_profiles (1:1)
├── onboarding (1:1)
├── notification_settings (1:1)
├── mood_entries (1:many subcollection)
├── journal_entries (1:many subcollection)
├── check_ins (1:many subcollection)
├── goals (1:many subcollection)
├── habits (1:many subcollection)
│   └── habit_logs (1:many subsubcollection)
├── meditation_progress (1:many subcollection)
│   └── meditation_stats (1:1 subdocument)
├── yoga_progress (1:many subcollection)
├── recommendations (1:many subcollection)
├── ai_memory (1:many subcollection)
├── therapy_sessions (1:many subcollection)
├── notifications (1:many subcollection)
├── sync_queue (1:many subcollection)
├── feedback (1:many subcollection)
├── saved_quotes (1:many subcollection of quotes)
│
quotes (root collection, read-only for users)
meditation_sessions (root collection, read-only for users)
music_tracks (root collection, read-only for users)
yoga_sessions (root collection, read-only for users)
achievements (root collection, read-only for users)
├── user_achievements (subcollection of each user)
│
community_posts (root collection)
└── comments (1:many subcollection)
    ├── likes (1:many subcollection)
    └── nested replies via parentCommentId
support_groups (root collection)
├── members (1:many subcollection)
└── messages (1:many subcollection)
crisis_resources (root collection, country-keyed)
app_config (root collection, system-managed)
analytics_events (root collection, append-only)
```

---

# REFERENTIAL INTEGRITY RULES

| Parent | Child | Integrity Rule |
|--------|-------|----------------|
| users | profiles | Created atomically with user signup. Never orphaned. |
| users | wellness_profiles | Created on first mood entry. |
| users | onboarding | Created at signup. |
| community_posts | comments | commentCount on post must match actual count (maintained via Cloud Function or transaction). |
| community_posts | likes | likeCount on post must match actual count. |
| users | notifications | Clean up on account deletion. |
| users | sync_queue | Purge completed items after 30 days. |

---

# COMPOSITE INDEXES

## Required Composite Indexes

### mood_entries (subcollection)
```
collection: users/{userId}/mood_entries
fields: userId (ASC), date (DESC)
```

```
collection: users/{userId}/mood_entries
fields: userId (ASC), createdAt (DESC)
```

### journal_entries (subcollection)
```
collection: users/{userId}/journal_entries
fields: userId (ASC), date (DESC)
```

```
collection: users/{userId}/journal_entries
fields: userId (ASC), createdAt (DESC)
```

```
collection: users/{userId}/journal_entries
fields: userId (ASC), tags (ARRAY, ASC), createdAt (DESC)
```

### goals (subcollection)
```
collection: users/{userId}/goals
fields: userId (ASC), status (ASC)
```

```
collection: users/{userId}/goals
fields: userId (ASC), category (ASC), status (ASC)
```

```
collection: users/{userId}/goals
fields: userId (ASC), status (ASC), createdAt (DESC)
```

### recommendations (subcollection)
```
collection: users/{userId}/recommendations
fields: userId (ASC), type (ASC), isRead (ASC)
```

```
collection: users/{userId}/recommendations
fields: userId (ASC), generatedAt (DESC)
```

```
collection: users/{userId}/recommendations
fields: userId (ASC), type (ASC), generatedAt (DESC)
```

### ai_memory (subcollection)
```
collection: users/{userId}/ai_memory
fields: userId (ASC), category (ASC), isActive (ASC)
```

```
collection: users/{userId}/ai_memory
fields: userId (ASC), expiresAt (ASC)
```

### notifications (subcollection)
```
collection: users/{userId}/notifications
fields: userId (ASC), isRead (ASC), createdAt (DESC)
```

```
collection: users/{userId}/notifications
fields: userId (ASC), type (ASC), createdAt (DESC)
```

### therapy_sessions (subcollection)
```
collection: users/{userId}/therapy_sessions
fields: userId (ASC), startedAt (DESC)
```

```
collection: users/{userId}/therapy_sessions
fields: userId (ASC), sessionType (ASC), startedAt (DESC)
```

### community_posts (root)
```
collection: community_posts
fields: moderationStatus (ASC), createdAt (DESC)
```

```
collection: community_posts
fields: category (ASC), createdAt (DESC)
```

```
collection: community_posts
fields: userId (ASC), createdAt (DESC)
```

### habits (subcollection)
```
collection: users/{userId}/habits
fields: userId (ASC), category (ASC), isDeleted (ASC)
```

### yoga_progress (subcollection)
```
collection: users/{userId}/yoga_progress
fields: userId (ASC), completedAt (DESC)
```

---

# FIRESTORE SECURITY RULES

## Rule Philosophy

* Least privilege by default
* Validate every field
* Never trust client-supplied userId
* Use server timestamps to prevent tampering
* Enforce data structure at the rule level
* Rate-limit writes where possible

## Global Rules Template

```
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {

    // ===== HELPER FUNCTIONS =====

    // Check if user is authenticated
    function isAuth() {
      return request.auth != null;
    }

    // Check if user owns the document
    function isOwner(userId) {
      return isAuth() && request.auth.uid == userId;
    }

    // Check if user is admin
    function isAdmin() {
      return isAuth() && 
        exists(/databases/$(database)/documents/users/$(request.auth.uid)) &&
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }

    // Validate base fields on create
    function validateBaseCreate() {
      return request.resource.data.keys().hasAll(['createdAt', 'updatedAt', 'version', 'isDeleted', 'syncStatus', 'deviceId'])
        && request.resource.data.createdAt == request.time
        && request.resource.data.updatedAt == request.time
        && request.resource.data.version == 1
        && request.resource.data.isDeleted == false;
    }

    // Validate base fields on update
    function validateBaseUpdate() {
      return request.resource.data.updatedAt == request.time
        && request.resource.data.version == resource.data.version + 1
        && request.resource.data.createdAt == resource.data.createdAt
        && request.resource.data.createdBy == resource.data.createdBy;
    }

    // Prevent field deletion
    function fieldsUnchanged(fields) {
      return fields.all(field, field in resource.data && field in request.resource.data);
    }

    // ===== USERS COLLECTION =====

    match /users/{userId} {
      // User can CRUD their own document
      // Admin can read any
      allow create: if isOwner(userId) && validateBaseCreate();
      allow read: if isOwner(userId) || isAdmin();
      allow update: if isOwner(userId) 
        && validateBaseUpdate()
        && request.resource.data.id == resource.data.id
        && request.resource.data.email == resource.data.email;
      allow delete: if false; // No hard deletes; use soft delete via update

      // ===== USER SUBCOLLECTIONS =====

      // profiles (1:1)
      match /profiles/{profileId} {
        allow create: if isOwner(userId) && profileId == userId && validateBaseCreate();
        allow read: if isOwner(userId) || isAdmin();
        allow update: if isOwner(userId) && validateBaseUpdate();
        allow delete: if false;
      }

      // wellness_profiles (1:1)
      match /wellness_profiles/{wpId} {
        allow create: if isOwner(userId) && wpId == userId && validateBaseCreate();
        allow read: if isOwner(userId) || isAdmin();
        allow update: if isOwner(userId) && validateBaseUpdate();
        allow delete: if false;
      }

      // onboarding (1:1)
      match /onboarding/{onboardingId} {
        allow create: if isOwner(userId) && onboardingId == userId && validateBaseCreate();
        allow read: if isOwner(userId) || isAdmin();
        allow update: if isOwner(userId) && validateBaseUpdate();
        allow delete: if false;
      }

      // notification_settings (1:1)
      match /notification_settings/{nsId} {
        allow create: if isOwner(userId) && nsId == userId && validateBaseCreate();
        allow read: if isOwner(userId) || isAdmin();
        allow update: if isOwner(userId) && validateBaseUpdate();
        allow delete: if false;
      }

      // mood_entries (subcollection)
      match /mood_entries/{entryId} {
        allow create: if isOwner(userId) 
          && validateBaseCreate()
          && request.resource.data.userId == userId
          && request.resource.data.moodScore >= 1 
          && request.resource.data.moodScore <= 10;
        allow read: if isOwner(userId) || isAdmin();
        allow update: if isOwner(userId) 
          && validateBaseUpdate()
          && request.resource.data.userId == userId;
        allow delete: if false;
      }

      // journal_entries (subcollection)
      match /journal_entries/{entryId} {
        allow create: if isOwner(userId) 
          && validateBaseCreate()
          && request.resource.data.userId == userId
          && request.resource.data.content.size() > 0;
        allow read: if isOwner(userId) || isAdmin();
        allow update: if isOwner(userId) 
          && validateBaseUpdate()
          && request.resource.data.userId == userId;
        allow delete: if false;
      }

      // check_ins
      match /check_ins/{checkInId} {
        allow create: if isOwner(userId) && validateBaseCreate();
        allow read: if isOwner(userId);
        allow update: if isOwner(userId) && validateBaseUpdate();
        allow delete: if false;
      }

      // goals
      match /goals/{goalId} {
        allow create: if isOwner(userId) && validateBaseCreate();
        allow read: if isOwner(userId) || isAdmin();
        allow update: if isOwner(userId) && validateBaseUpdate();
        allow delete: if false;
      }

      // habits
      match /habits/{habitId} {
        allow create: if isOwner(userId) && validateBaseCreate();
        allow read: if isOwner(userId);
        allow update: if isOwner(userId) && validateBaseUpdate();
        allow delete: if false;

        // habit_logs subsubcollection
        match /habit_logs/{logId} {
          allow create: if isOwner(userId);
          allow read: if isOwner(userId);
          allow update: if isOwner(userId);
          allow delete: if false;
        }
      }

      // meditation_progress
      match /meditation_progress/{progressId} {
        allow create: if isOwner(userId) && validateBaseCreate();
        allow read: if isOwner(userId);
        allow update: if isOwner(userId) && validateBaseUpdate();
        allow delete: if false;
      }

      // meditation_stats (single document per user)
      match /meditation_stats/{statsId} {
        allow create: if isOwner(userId) && statsId == userId;
        allow read: if isOwner(userId);
        allow update: if isOwner(userId);
        allow delete: if false;
      }

      // yoga_progress
      match /yoga_progress/{progressId} {
        allow create: if isOwner(userId) && validateBaseCreate();
        allow read: if isOwner(userId);
        allow update: if isOwner(userId) && validateBaseUpdate();
        allow delete: if false;
      }

      // recommendations
      match /recommendations/{recId} {
        allow read: if isOwner(userId) || isAdmin();
        allow update: if isOwner(userId) && validateBaseUpdate();
        allow create: if false; // System writes only
        allow delete: if false;
      }

      // ai_memory
      match /ai_memory/{memoryId} {
        allow read: if isOwner(userId) || isAdmin();
        allow update: if false; // System manages AI memory
        allow create: if false; // System writes only
        allow delete: if false;
      }

      // therapy_sessions
      match /therapy_sessions/{sessionId} {
        allow create: if isOwner(userId) && validateBaseCreate();
        allow read: if isOwner(userId);
        allow update: if isOwner(userId) && validateBaseUpdate();
        allow delete: if false;
      }

      // notifications
      match /notifications/{notifId} {
        allow create: if isOwner(userId) || isAdmin();
        allow read: if isOwner(userId);
        allow update: if isOwner(userId) 
          && request.resource.data.diff(resource.data).affectedKeys().hasOnly(['isRead', 'isActioned', 'readAt', 'updatedAt', 'version', 'syncStatus']);
        allow delete: if false;
      }

      // sync_queue
      match /sync_queue/{queueId} {
        allow create: if isOwner(userId) && validateBaseCreate();
        allow read: if isOwner(userId);
        allow update: if isOwner(userId);
        allow delete: if isOwner(userId) && resource.data.status == 'completed';
      }

      // feedback
      match /feedback/{feedbackId} {
        allow create: if isOwner(userId) && validateBaseCreate();
        allow read: if isOwner(userId);
        allow delete: if false;
      }
    }

    // ===== CONTENT COLLECTIONS (Read-only for regular users) =====

    match /quotes/{quoteId} {
      allow read: if isAuth();
      allow write: if isAdmin();
    }

    match /meditation_sessions/{sessionId} {
      allow read: if isAuth();
      allow write: if isAdmin();
    }

    match /music_tracks/{trackId} {
      allow read: if isAuth();
      allow write: if isAdmin();
    }

    match /yoga_sessions/{sessionId} {
      allow read: if isAuth();
      allow write: if isAdmin();
    }

    match /achievements/{achievementId} {
      allow read: if isAuth();
      allow write: if isAdmin();
    }

    match /crisis_resources/{countryCode} {
      allow read: if true; // Public — always accessible
      allow write: if isAdmin();
    }

    match /app_config/{configKey} {
      allow read: if isAuth();
      allow write: if isAdmin();
    }

    // ===== COMMUNITY =====

    match /community_posts/{postId} {
      allow create: if isAuth() 
        && validateBaseCreate()
        && request.resource.data.userId == request.auth.uid;
      allow read: if isAuth() && resource.data.moderationStatus == 'approved' 
        || isOwner(resource.data.userId) || isAdmin();
      allow update: if (isOwner(request.resource.data.userId) && request.resource.data.diff(resource.data).affectedKeys().hasOnly(['content', 'title', 'tags', 'isAnonymous', 'updatedAt', 'version', 'syncStatus']))
        || isAdmin();
      allow delete: if false;

      // comments subcollection
      match /comments/{commentId} {
        allow create: if isAuth();
        allow read: if isAuth();
        allow update: if isOwner(request.resource.data.userId) || isAdmin();
        allow delete: if false;

        match /likes/{likeId} {
          allow create: if isAuth();
          allow read: if isAuth();
          allow delete: if isOwner(resource.data.userId);
        }
      }

      // likes subcollection
      match /likes/{likeId} {
        allow create: if isAuth();
        allow read: if isAuth();
        allow delete: if isOwner(resource.data.userId);
      }
    }

    // ===== SUPPORT GROUPS =====

    match /support_groups/{groupId} {
      allow read: if isAuth();
      allow write: if isAdmin();

      match /members/{userId} {
        allow read: if isAuth();
        allow create: if isOwner(userId);
        allow delete: if isOwner(userId) || isAdmin();
        allow update: if false;
      }

      match /messages/{messageId} {
        allow create: if isAuth();
        allow read: if isAuth();
        allow delete: if false;
      }
    }

    // ===== SYSTEM COLLECTIONS =====

    match /analytics_events/{eventId} {
      allow create: if isAuth();
      allow read: if isAdmin();
      allow update: if false;
      allow delete: if false;
    }

    match /content_reports/{reportId} {
      allow create: if isAuth();
      allow read: if isAdmin() || isOwner(resource.data.reporterId);
      allow update: if isAdmin();
      allow delete: if false;
    }

    // ===== DENY ALL ELSE =====
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

---

# FIRESTORE DATA FLOW

## Read Flow (Online)

```
UI (Widget/Provider)
  ↓
Repository.getData()
  ↓
FirestoreService.query()
  ↓
  ├── Check Firestore cache (enabled by default)
  │   └── Return cached data immediately
  ├── Fetch from Firestore server
  │   └── Return fresh data
  └── Stream snapshot listener
      └── Real-time updates → UI rebuild
```

## Read Flow (Offline)

```
UI (Widget/Provider)
  ↓
Repository.getData()
  ↓
FirestoreService.query()
  ↓
Firestore local cache (persistent)
  ↓
Return data (may be stale)
  ↓
UI shows data with "offline" indicator
```

## Write Flow (Online)

```
User Action
  ↓
Repository.save(entity)
  ↓
  ├── 1. Convert entity to Firestore map
  ├── 2. Set server timestamp
  ├── 3. Increment version
  ├── 4. Write to Firestore
  ├── 5. On success → update local Hive cache
  └── 6. Return success
```

## Write Flow (Offline)

```
User Action
  ↓
Repository.save(entity)
  ↓
  ├── 1. Convert entity to Firestore map
  ├── 2. Set local timestamp
  ├── 3. Increment version
  ├── 4. Write to Hive local cache (immediate UI feedback)
  ├── 5. Add to sync_queue subcollection
  │   { operation, collection, documentId, data, timestamp, retryCount: 0, maxRetries: 5, status: 'queued' }
  └── 6. Return success (optimistic)
```

## Sync Flow (Offline → Online)

```
Network Status Change: Online
  ↓
SyncService.listenToNetworkChanges()
  ↓
  ├── 1. Fetch all sync_queue items for user
  │    WHERE status == 'queued' OR status == 'failed'
  │    ORDER BY createdAt ASC
  ├── 2. Process each item sequentially:
  │   ├── Mark as 'syncing'
  │   ├── Execute operation (create/update/delete) on Firestore
  │   ├── On success:
  │   │   ├── Mark as 'completed'
  │   │   └── Update local Hive cache with server response
  │   └── On failure:
  │       ├── Increment retryCount
  │       ├── If retryCount < maxRetries:
  │       │   └── Mark as 'failed' (will retry on next sync)
  │       └── If retryCount >= maxRetries:
  │           └── Mark as 'failed' permanently
  │           └── Notify user of sync failure
  ├── 3. After queue is synced:
  │   ├── Pull latest data from Firestore for each collection
  │   └── Update Hive cache
  └── 4. Mark sync as complete
      └── Update UI sync status indicator
```

---

# CONFLICT RESOLUTION STRATEGY

## Conflict Detection

Conflict occurs when:
- Local version of document has version N
- Server version of document has version N
- But local data differs from server data

## Resolution Algorithm

```
function resolveConflict(localData, serverData):
  if localData.version > serverData.version:
    // Local is newer — trust local
    // But merge non-conflicting fields from server
    return mergeWithPrecedence(localData, serverData, precedence: 'local')
    
  if serverData.version > localData.version:
    // Server is newer — trust server
    // But merge non-conflicting fields from local
    return mergeWithPrecedence(serverData, localData, precedence: 'server')
    
  if localData.version == serverData.version:
    if localData.updatedAt > serverData.updatedAt:
      return mergeWithPrecedence(localData, serverData, precedence: 'local')
    else:
      return mergeWithPrecedence(serverData, localData, precedence: 'server')
```

## Field-Level Merge Rules

| Field Category | Merge Strategy |
|----------------|----------------|
| Base fields (id, createdAt) | Never overwrite. Trust original. |
| User-generated content | Latest timestamp wins. |
| Counters (likeCount) | Server wins + apply delta. |
| AI-generated fields | Server wins. |
| Status fields | Latest change wins. |
| Settings/preferences | Last write wins. |
| Deleted flag | If either says deleted, treat as deleted. |

## Conflict Notification

If automatic merge cannot resolve:
- Set document syncStatus to 'conflict'
- Store both versions in local cache
- Show conflict resolution UI to user
- Let user choose which version to keep

---

# REAL-TIME SUBSCRIPTIONS

## Subscription Policy

| Data Type | Subscription | Strategy |
|-----------|-------------|----------|
| Dashboard data | Stream | Real-time |
| Mood entries | Stream (last 30) | Real-time |
| Journals | Paginated query | On demand |
| Notifications | Stream (unread) | Real-time |
| Recommendations | Stream | Real-time |
| Community feed | Paginated query | On demand + pull-to-refresh |
| Chat messages | Stream | Real-time |
| Goals | Stream | Real-time |
| Meditation progress | Stream | Real-time |
| User profile | Single doc | When modified |

## Subscription Lifecycle

```
Feature screen opens
  ↓
Repository.subscribe()
  ↓
FirestoreService.createSubscription()
  ↓
  ├── Attach snapshot listener
  ├── Return stream to BLoC/Provider
  └── UI rebuilds on data changes

Feature screen closes
  ↓
Repository.unsubscribe()
  ↓
FirestoreService.cancelSubscription()
  ↓
  └── Remove snapshot listener
```

## Subscription Limits

- Maximum 10 simultaneous real-time listeners
- Listeners automatically pause when app backgrounds
- Listeners resume when app foregrounds
- Stale listeners are garbage collected after 5 minutes

---

# FIRESTORE BATCH & TRANSACTION USAGE

## When to Use Batches

- Creating user + profile + onboarding atomically
- Creating a post + updating user post count
- Creating comment + incrementing commentCount on post
- Creating a therapy session with mood snapshot

## When to Use Transactions

- Updating goal progress + recalculating streak
- Claiming achievement + updating points
- Joining support group + checking member limit
- Any read-modify-write that must be atomic

---

# BACKUP & RECOVERY STRATEGY

## Automated Backups

Firestore managed exports:
- Daily export to Cloud Storage
- 30-day retention
- Export includes all collections except analytics_events

## Export Schedule

| Collection | Frequency | Retention |
|-----------|-----------|-----------|
| users + subcollections | Daily | 30 days |
| community_posts | Daily | 30 days |
| analytics_events | Weekly | 90 days |
| sync_queue | Not backed up | Ephemeral |

## Recovery Process

1. Identify point-in-time for recovery
2. Restore from Firestore export
3. Verify data integrity
4. Notify affected users
5. Re-trigger AI processing for affected period

## User-Initiated Recovery

- Export user data (all collections)
- Restore from export after device change
- Account recovery via password reset
- Contact support for data recovery

---

# PERFORMANCE OPTIMIZATION

## Firestore Read/Write Budget

| Operation | Daily Budget | Strategy |
|-----------|-------------|----------|
| Document reads | 100K per user | Cache aggressively, minimize listeners |
| Document writes | 10K per user | Batch related writes, avoid frequent updates |
| Document deletes | 1K per user | Soft delete, batch hard delete |

## Optimization Rules

1. Always paginate list queries (limit 20-50 per page)
2. Use Firestore cache for frequently accessed data
3. Denormalize counts to avoid counting queries
4. Avoid array-contains-any on large arrays (max 10)
5. Keep documents under 1MB (Firestore limit)
6. Use collection group queries sparingly
7. Prefer subcollections over root collections for user data
8. Avoid deep nesting (max 1 subcollection level)

---

## END OF PART 2C-2

---

# PART 3 — COMPLETE ONBOARDING, AI SCORING ENGINE & ADAPTIVE FLOW

---

# ONBOARDING PHILOSOPHY

Onboarding is the most critical user experience in Mental Mantra.

It must:

* Feel warm, empathetic, and conversational
* Never overwhelm the user
* Adapt in real-time based on user responses
* Build an initial AI wellness profile
* Establish trust
* Set clear expectations about what the app is (and is not)

The onboarding must position Mental Mantra clearly:

> **"Mental Mantra is an AI-powered personalized mental wellness and emotional support platform. It is NOT a medical diagnostic tool or a replacement for professional healthcare."**

---

# ONBOARDING FLOW OVERVIEW

Total: 30 questions across 8 screens

Screens:

1. Welcome & Consent
2. Basic Profile
3. Wellness Identity
4. Emotional Baseline
5. Lifestyle & Habits
6. Mindfulness & Spiritual
7. Goals & Intentions
8. AI Summary & Dashboard Preview

Each screen must:

* Show progress indicator (Step X of 8)
* Allow back navigation
* Save responses to Hive immediately
* Auto-save to Firestore draft if online
* Show encouraging messages
* Never feel clinical or judgmental

---

# SCREEN 1: WELCOME & CONSENT

## UI Elements

* Full-screen calming illustration (animated gradient)
* App logo with tagline
* Warm welcome text personalized by time of day
* Gentle scrolling explanation of what Mental Mantra is
* Consent checkbox (mandatory):

> "I understand Mental Mantra is a wellness-support platform and not a substitute for medical diagnosis or emergency psychiatric care. If I am in crisis, I will contact emergency services or a crisis helpline."

* "Begin My Wellness Journey" button (disabled until consent checked)
* "I Already Have an Account" link → Login

## Data Collected

| Field | Type | Storage |
|-------|------|---------|
| consentAccepted | boolean | users.consentWellnessAcknowledged |
| consentTimestamp | timestamp | users.consentAcceptedAt |
| consentVersion | string | users.consentVersion |

## Validation

* Consent must be checked
* Cannot proceed without consent

---

# SCREEN 2: BASIC PROFILE

## UI Elements

* Avatar picker (generated initials or photo upload)
* Full Name (text input, required)
* Preferred Nickname (text input, optional, with tooltip: "What should we call you?")
* Email (pre-filled from auth if available, editable)
* Country (dropdown with flag icons, auto-detect if permission given)
* Age Group (pill selector):

| Option | Range |
|--------|-------|
| Teen | 13-17 |
| Young Adult | 18-24 |
| Adult | 25-34 |
| Mid Adult | 35-44 |
| Mature Adult | 45-54 |
| Senior | 55+ |

* Gender (text input, optional, placeholder: "How would you describe yourself?")
* Continue button

## Data Collected

| Field | Type | Storage |
|-------|------|---------|
| fullName | string | users.fullName |
| nickname | string | users.nickname |
| email | string | users.email |
| country | string | users.country |
| ageGroup | string | users.ageGroup |
| gender | string | users.gender |

## AI Processing

* On submit, calculate initial language preferences based on country
* Store timezone from device

---

# SCREEN 3: WELLNESS IDENTITY

This screen adapts based on age group from Screen 2.

## Questions (7)

### Q1: What brings you to Mental Mantra?
Multi-select pill selector:

* Managing stress and anxiety
* Improving sleep quality
* Building mindfulness habits
* Working through emotions
* Boosting focus and productivity
* Healing from grief or loss
* Building self-confidence
* General wellness and self-care
* Spiritual growth
* Other (text input)

### Q2: Have you ever practiced meditation or mindfulness before?
Single select:

* Never tried it
* Tried a few times
* Practice occasionally
* Regular practitioner

### Q3: How would you describe your current stress level?
Visual slider 1-10 with emoji anchors:

1 = "Completely calm" 😌
5 = "Managing okay" 😐
10 = "Overwhelmed" 😰

### Q4: How well do you sleep?
Single select:

* I sleep well most nights
* I occasionally have trouble sleeping
* I frequently struggle with sleep
* I have chronic sleep issues

### Q5: Do you have any physical health conditions that affect your mental wellness?
Multi-select:

* Chronic pain
* Hormonal changes
* Digestive issues
* Heart conditions
* None of the above
* Prefer not to say

### Q6: Have you ever spoken to a professional about your mental health?
Single select:

* Yes, currently seeing someone
* Yes, in the past
* No, but I've considered it
* No, and I haven't considered it

### Q7: What time of day do you feel most energized?
Single select:

* Morning (5 AM - 12 PM)
* Afternoon (12 PM - 5 PM)
* Evening (5 PM - 10 PM)
* Night (10 PM - 5 AM)

## Data Collected

| Field | Storage |
|-------|---------|
| reasons | profiles.interests |
| meditationExperience | profiles.meditationExperience |
| stressLevel | wellness_profiles.baselineMood (inverted) |
| sleepQuality | wellness_profiles (embedded) |
| healthConditions | wellness_profiles (embedded) |
| professionalHelpHistory | wellness_profiles (embedded) |
| peakEnergyTime | wellness_profiles (embedded) |

## AI Processing

* Calculate initial stress baseline
* Determine meditation experience tier
* Identify potential areas of focus
* Store as initial AI memory

---

# SCREEN 4: EMOTIONAL BASELINE

## Questions (5)

### Q8: Over the past two weeks, how often have you felt down, depressed, or hopeless?
Single select:

* Not at all (0 days)
* Several days (1-7 days)
* More than half the days (8-14 days)
* Nearly every day

### Q9: Over the past two weeks, how often have you felt little interest or pleasure in doing things?
Single select (same options as Q8)

### Q10: What emotions have you been feeling most frequently recently?
Multi-select (max 3):

* Anxious
* Sad
* Angry
* Hopeful
* Grateful
* Peaceful
* Overwhelmed
* Lonely
* Excited
* Neutral
* Empty
* Stressed

### Q11: When you feel overwhelmed, what helps you cope?
Multi-select:

* Talking to someone
* Exercise
* Music
* Meditation
* Writing/journaling
* Spending time in nature
* Watching TV/movies
* Sleeping
* Eating
* Breathing exercises
* Religion/spirituality
* I don't know what helps

### Q12: On a scale of 1-10, how connected do you feel to others right now?
Visual slider:

1 = "Completely isolated" 
5 = "Somewhat connected"
10 = "Very connected"

## Data Collected

| Field | Storage |
|-------|---------|
| depressionFrequency | wellness_profiles (embedded, PHQ-2 screening) |
| anhedoniaFrequency | wellness_profiles (embedded, PHQ-2 screening) |
| frequentEmotions | wellness_profiles.dominantMoodTags |
| copingStrategies | wellness_profiles.copingStrategies |
| socialConnectionScore | wellness_profiles (embedded) |

## AI Processing

* PHQ-2 depression screening calculation
* If PHQ-2 score >= 3: flag for gentle check-in, NOT diagnosis
* Map coping strategies to recommendation categories
* Calculate social wellness indicator

## Important

If Q8 or Q9 = "Nearly every day", show an empathetic message:

> "Thank you for sharing that with me. Many people experience these feelings, and you're not alone. While I'm here to support you, if these feelings become overwhelming, please reach out to a crisis helpline or a healthcare professional. Your wellbeing matters."

Show crisis resources button.

---

# SCREEN 5: LIFESTYLE & HABITS

## Questions (6)

### Q13: How many hours do you typically sleep per night?
Single select:

* Less than 5 hours
* 5-6 hours
* 7-8 hours
* 8+ hours

### Q14: How often do you exercise?
Single select:

* Daily
* 3-5 times per week
* 1-2 times per week
* Rarely
* Never

### Q15: How would you describe your diet?
Single select:

* Very healthy and balanced
* Mostly healthy
* Mixed
* Could be better
* I'm concerned about my eating habits

### Q16: How often do you spend time outdoors in nature?
Single select:

* Daily
* Several times a week
* Once a week
* Rarely
* Almost never

### Q17: How many glasses of water do you drink per day?
Single select:

* Less than 3
* 3-5
* 6-8
* 8+

### Q18: Do you use any substances that affect your mood? (alcohol, caffeine, nicotine, etc.)
Multi-select:

* Caffeine
* Alcohol
* Nicotine/Vaping
* Cannabis
* Other substances
* None of the above
* Prefer not to say

## Data Collected

| Field | Storage |
|-------|---------|
| sleepHours | wellness_profiles (embedded) |
| exerciseFrequency | wellness_profiles (embedded) |
| dietQuality | wellness_profiles (embedded) |
| natureTime | wellness_profiles (embedded) |
| waterIntake | wellness_profiles (embedded) |
| substanceUse | wellness_profiles (embedded) |

## AI Processing

* Calculate lifestyle wellness score
* Identify areas for habit suggestions
* Map to recommendation categories (sleep, hydration, exercise, nutrition)

---

# SCREEN 6: MINDFULNESS & SPIRITUAL

## Questions (5)

### Q19: Are you interested in spiritual wellness practices?
Single select:

* Yes, very interested
* Somewhat interested
* Neutral
* Not really interested
* I'd prefer to focus on non-spiritual wellness

### Q20: Which of these mindfulness practices appeal to you?
Multi-select:

* Guided meditation
* Breathing exercises
* Body scan meditation
* Walking meditation
* Mindful journaling
* Gratitude practice
* Affirmations
* Mantra chanting
* None of these

### Q21: Do you have a religious or spiritual background you'd like to incorporate?
Single select:

* Yes, please include practices from my tradition
* No, keep it secular
* Maybe, I'm exploring
* Prefer not to say

### Q22: How comfortable are you with chanting or mantra-based practices?
Single select:

* Very comfortable
* Somewhat comfortable
* Neutral
* Not really my style
* I'd prefer to skip this

### Q23: Would you like daily inspirational quotes?
Single select:

* Yes, please
* Maybe occasionally
* No, thank you

## Data Collected

| Field | Storage |
|-------|---------|
| spiritualInterest | profiles (embedded) |
| preferredPractices | profiles.preferredMeditationType (extended) |
| spiritualBackground | profiles (embedded) |
| mantraComfort | profiles (embedded) |
| dailyQuotesPreference | notification_settings.dailyQuote |

## AI Processing

* Determine spiritual wellness inclusion level
* Map to meditation/music content filters
* Set content personalization parameters

---

# SCREEN 7: GOALS & INTENTIONS

## Questions (5)

### Q24: What would you most like to improve in your life?
Pick top 3:

* Reduce stress and anxiety
* Improve sleep quality
* Build a meditation habit
* Process difficult emotions
* Improve relationships
* Find inner peace
* Build self-confidence
* Develop a healthier lifestyle
* Find purpose and meaning
* Connect with others

### Q25: How much time can you dedicate to wellness practice daily?
Single select:

* 5 minutes
* 10 minutes
* 15 minutes
* 20 minutes
* 30+ minutes

### Q26: What time of day would you prefer for your wellness practice?
Single select:

* Morning (to start the day well)
* Afternoon (midday reset)
* Evening (wind down)
* Before bed (sleep preparation)
* Flexible

### Q27: Would you like gentle reminders to practice?
Single select:

* Yes, please
* Maybe occasionally
* No, I'll remember on my own

### Q28: What would make you feel most supported?
Multi-select:

* Personalized recommendations
* Daily encouragement messages
* Progress tracking and insights
* Community support
* AI conversations
* Guided exercises
* Educational content about wellness

## Data Collected

| Field | Storage |
|-------|---------|
| improvementAreas | goals (initial goals created) |
| availableTime | profiles.preferredMeditationDuration |
| preferredPracticeTime | wellness_profiles (embedded) |
| reminderPreference | notification_settings (general) |
| supportPreferences | profiles (embedded) |

## AI Processing

* Generate initial goal set (3 goals)
* Create recommendation schedule
* Set notification cadence
* Calculate initial AI personality parameters

---

# SCREEN 8: AI SUMMARY & DASHBOARD PREVIEW

## UI Elements

* "Your Wellness Profile is Ready!" animated celebration
* Personalized greeting using nickname
* Wellness snapshot cards:

**Your Wellness Snapshot:**

| Card | Content |
|------|---------|
 | 🌿 Wellbeing Index | Composite score |
| 😊 Mood Pattern | Most frequent emotion |
| 🎯 Focus Areas | Top 3 areas |
| ⏱ Recommended Practice | Suggested daily duration |

* Personalized message from AI:

> "Hi [nickname]! Based on what you've shared, I've created a personalized wellness plan for you. We'll start with gentle [X-minute] sessions focusing on [focus area]. Remember, every small step counts, and I'm here to support you throughout your journey."

* "Let's Begin" button → Dashboard
* Preview of dashboard (blurred, animated)

## Data Collected

| Field | Storage |
|-------|---------|
| onboardingCompleted | users.onboardingCompleted = true |
| onboardingCompletedAt | users (embedded) |

## AI Processing

* Finalize AI wellness profile
* Generate initial recommendations (3-5)
* Schedule first check-in reminder
* Initialize AI memory with all collected data
* Create goal documents in Firestore

---

# AI SCORING ENGINE

## Wellness Score Calculation

The AI scoring engine runs after onboarding and recalculates periodically.

### Composite Score Calculation

```
Wellness Score = (Mood Score × 0.25) 
               + (Sleep Score × 0.20) 
               + (Lifestyle Score × 0.15) 
               + (Social Score × 0.10) 
               + (Mindfulness Score × 0.15) 
               + (Resilience Score × 0.15)
```

### Sub-Score Calculations

**Mood Score** (0-100):
```
Average of:
  - Recent mood entries (7-day rolling, weighted by recency)
  - PHQ-2 inverted score
  - Emotional range score
  - Stress level (inverted)
```

**Sleep Score** (0-100):
```
Average of:
  - Sleep hours adequacy
  - Sleep quality rating
  - Sleep consistency
```

**Lifestyle Score** (0-100):
```
Average of:
  - Exercise frequency score
  - Diet quality score
  - Hydration score
  - Nature time score
```

**Social Score** (0-100):
```
Average of:
  - Social connection self-rating
  - Community engagement activity
  - Support network indicator
```

**Mindfulness Score** (0-100):
```
Average of:
  - Meditation frequency
  - Journaling frequency
  - Mindfulness practice consistency
```

**Resilience Score** (0-100):
```
Average of:
  - Coping strategy diversity
  - Emotional regulation indicators
  - Recovery rate from low moods
```

## Score Tiers

| Tier | Range | Label |
|------|-------|-------|
| 1 | 0-30 | Needs Support |
| 2 | 31-50 | Developing |
| 3 | 51-70 | Stable |
| 4 | 71-85 | Thriving |
| 5 | 86-100 | Flourishing |

## PHQ-2 Screening (Onboarding Only)

Not a diagnostic tool. Used for personalization only.

```
PHQ-2 Score = Q8 value (0-3) + Q9 value (0-3)

Values:
  Not at all = 0
  Several days = 1
  More than half the days = 2
  Nearly every day = 3

If score >= 3:
  → Show empathetic message + crisis resources
  → Adjust AI sensitivity
  → Recommend gentler content
  → Flag for more frequent check-ins
```

---

# ADAPTIVE ONBOARDING LOGIC

## Question Branching

| Answer | Effect |
|--------|--------|
| Meditation = "Regular practitioner" | Skip basic meditation intro, show advanced options |
| Spiritual = "Not interested" | Skip spiritual questions entirely |
| PHQ-2 >= 3 | Show crisis resources, adjust tone |
| Sleep = "Chronic issues" | Prioritize sleep content in recommendations |
| Available time = "5 min" | All recommendations default to 5-minute sessions |

## Response Validation

* All required questions must be answered
* Sliders must have a value (no default)
* Multi-select must have at least 1 selection (or "None")
* Back navigation preserves previous answers
* Progress auto-saves every screen

## Error Handling

* If save fails → retry
* If internet drops → save to Hive, sync later
* If signup incomplete → allow resume from last completed screen
* Show friendly retry messages

---

# ONBOARDING DATA MODEL

```
OnboardingState {
  currentScreen: int (1-8)
  completedScreens: List<int>
  skippedScreens: List<int>
  responses: Map<String, dynamic>
  aiProfile: WellnessProfile
  score: WellnessScore
  startedAt: DateTime
  completedAt: DateTime?
}
```

---

# ONBOARDING QUALITY CHECKLIST

✓ Welcome screen with consent

✓ Basic profile collection

✓ Wellness identity assessment

✓ Emotional baseline with PHQ-2

✓ Lifestyle & habits data

✓ Mindfulness & spiritual preferences

✓ Goals & intentions

✓ AI summary & dashboard preview

✓ All 30 questions implemented

✓ AI scoring engine complete

✓ Adaptive branching logic

✓ Progress auto-save

✓ Offline support

✓ Error handling with retry

✓ Crisis resource display when appropriate

✓ Hive local storage during onboarding

✓ Firestore sync on completion

✓ Initial recommendations generated

✓ Initial goals created

✓ AI memory initialized

✓ Navigation complete (forward + back)

✓ Animations and transitions

✓ Responsive design

✓ Accessibility (screen reader, contrast, font size)

✓ Production ready

---

## END OF PART 3

---

# PART 4 — DASHBOARD, WELLNESS SCORES, MOOD TRACKER & ANALYTICS

---

# DASHBOARD PHILOSOPHY

The dashboard is the home screen and the most important screen in the app.

It must:

* Greet the user warmly by name
* Show their current wellness state at a glance
* Provide one-tap access to core actions
* Feel calm, never overwhelming
* Adapt content based on time of day
* Show personalized AI-driven recommendations
* Display progress without judgment

---

# DASHBOARD LAYOUT

```
┌─────────────────────────────────┐
│  🌤 Good morning, [nickname]    │
│  "[daily affirmation]"          │
├─────────────────────────────────┤
│  Wellness Ring / Score Card     │
│  [Score] — [Tier Label]         │
│  ▲ [X] points from last week    │
├─────────────────────────────────┤
│  Quick Actions (horizontal)     │
│  [Mood] [Journal] [Meditate]    │
│  [Breathe] [Music] [Chat]       │
├─────────────────────────────────┤
│  How are you feeling?           │
│  [😌] [😊] [😐] [😰] [😢]       │
├─────────────────────────────────┤
│  Recommended For You            │
│  [Card] [Card] [Card] (horizontal)│
├─────────────────────────────────┤
│  Today's Progress               │
│  [Goal 1] ████████░░ 80%       │
│  [Goal 2] ██████░░░░ 60%       │
│  [Goal 3] ████░░░░░░ 40%       │
├─────────────────────────────────┤
│  Mood This Week (mini chart)    │
│  [sparkline / bar chart]        │
├─────────────────────────────────┤
│  Quick Insights                 │
│  • "You journaled 3 days in a   │
│    row! Keep it up!"            │
│  • "Try a breathing exercise —  │
│    your stress has been up"     │
├─────────────────────────────────┤
│  Bottom Nav                     │
│  [Home] [Mood] [Journal] [More] │
└─────────────────────────────────┘
```

---

# DASHBOARD SECTIONS

## 1. Greeting Header

* Time-aware greeting: "Good morning/afternoon/evening"
* User's nickname
* Daily affirmation (rotated from quotes collection or AI-generated)
* Pull-to-refresh gesture
* Animated gradient background that shifts throughout the day

## 2. Wellness Score Ring

* Circular progress indicator
* Score displayed prominently (0-100)
* Tier label beneath
* Micro-animation on load
* Tap → detailed wellness breakdown screen
* Color-coded: Red (0-30) → Orange (31-50) → Yellow (51-70) → Teal (71-85) → Green (86-100)

## 3. Quick Actions

Horizontal scrollable row of circular icon buttons:

| Icon | Label | Action |
|------|-------|--------|
| 😊 | Mood | Opens mood check-in |
| 📝 | Journal | Opens new journal entry |
| 🧘 | Meditate | Opens meditation picker |
| 🌬️ | Breathe | Opens breathing exercise |
| 🎵 | Music | Opens music player |
| 💬 | Chat | Opens AI chat |

Each button has a micro-press animation.

## 4. Mood Quick-Check

Inline mood selector with 5 emoji options:

* 😌 Calm
* 😊 Happy
* 😐 Neutral
* 😰 Anxious
* 😢 Sad

Selection triggers:
* Save mood entry to Firestore via repository
* Update wellness score
* Show brief acknowledgment
* Update dashboard immediately (optimistic)

## 5. Recommended For You

Horizontal card carousel showing 3-5 AI-generated recommendations:

Each card displays:
* Type icon (meditation, journal, music, etc.)
* Title
* Brief description
* Reason tag ("Based on your mood", "Morning routine", etc.)
* Tap → opens relevant feature

Cards animate in with staggered entrance.

## 6. Today's Goals Progress

List of active goals with:
* Goal title
* Progress bar (animated)
* Current streak indicator (🔥 N days)
* Tap → goal detail/edit screen

Max 5 goals shown. "See all" link.

## 7. Mood Trend Sparkline

Mini line chart showing mood scores for the past 7 days.

* Each data point is a dot colored by mood
* Line connecting dots with gradient
* Tap → full mood calendar/history

## 8. Quick Insights

AI-generated contextual insights:

* Streak celebrations ("You've meditated 7 days in a row!")
* Pattern detection ("Your mood tends to be higher on days you journal")
* Gentle suggestions ("You haven't checked in today")
* Achievement unlocked notifications

---

# WELLNESS SCORE DETAIL SCREEN

Full-screen breakdown of the wellness score.

## Layout

```
┌─────────────────────────────────┐
│  ← Back          Wellness Score │
├─────────────────────────────────┤
│  [Large Ring with score]        │
│  [Tier Label]                   │
│  [Change indicator]             │
├─────────────────────────────────┤
│  Score Breakdown                │
│                                 │
│  Mood        ████████░░  72     │
│  Sleep       ██████░░░░  58     │
│  Lifestyle   █████████░  85     │
│  Social      █████░░░░░  45     │
│  Mindfulness ████████░░  70     │
│  Resilience  ███████░░░  65     │
├─────────────────────────────────┤
│  Tips to Improve                │
│  • [AI-generated tip]           │
│  • [AI-generated tip]           │
│  • [AI-generated tip]           │
├─────────────────────────────────┤
│  Your Progress Over Time        │
│  [Line chart — last 30 days]    │
└─────────────────────────────────┘
```

---

# MOOD TRACKER

## Mood Check-In Screen

Full-screen mood entry with:

### Step 1: How are you feeling?

Grid of 10 mood options with emoji + label:

| 😌 Calm | 😊 Happy | 😐 Neutral | 😰 Anxious | 😢 Sad |
|---------|---------|-----------|-----------|-------|
| 😤 Angry | 🥱 Tired | 🙏 Grateful | 💪 Hopeful | 😵 Overwhelmed |

* Select one primary mood
* Sub-emotions appear after selection (3-5 related options)

### Step 2: How intense is this feeling?

Slider 1-10 with labels:
1 = "Very mild"
5 = "Moderate"
10 = "Very intense"

### Step 3: What's contributing?

Multi-select tags:

| Category | Tags |
|----------|------|
| Work/School | deadline, workload, colleague, presentation, exam |
| Relationships | partner, family, friend, conflict, loneliness |
| Health | sleep, exercise, illness, pain, hormones |
| Home | chores, space, privacy, noise, roommate |
| Self | thoughts, confidence, growth, habits |
| World | news, weather, current events |
| None | nothing specific |

### Step 4: Any notes?

Optional text field with character count (max 500)

* "Add a note (optional)"
* Voice note option (mic icon)
* "What helped?" / "What could help?" toggle

### Step 5: Save

* "Save Entry" button
* AI reflection generated in background
* Brief acknowledgment animation
* "View my mood history" link

## Mood Calendar View

Full-page calendar showing:

* Current month with mood dots on each day
* Color-coded by mood score:
  * 9-10: Green
  * 7-8: Teal
  * 5-6: Yellow
  * 3-4: Orange
  * 1-2: Red
  * No data: Grey
* Tap day → view entries for that day
* Swipe to change months
* Month summary: average mood, entries count, streak

## Mood Trends View

Data visualization screens:

### Weekly View
* Bar chart: average mood per day
* Line overlay: sleep hours
* Color gradient fill

### Monthly View
* Heatmap calendar
* Weekday analysis ("You tend to feel best on Fridays")
* Time-of-day analysis

### Insights Tab
* AI-generated patterns:
  * "Your mood improves after journaling"
  * "Weekends are consistently higher"
  * "Sleep quality strongly correlates with mood"
* Correlation analysis
* Trend direction indicators

---

# ANALYTICS ENGINE

## Tracked Events (Client-Side)

| Event Category | Events |
|----------------|--------|
| Session | app_open, app_close, session_duration |
| Onboarding | onboarding_start, onboarding_complete, onboarding_skip |
| Auth | signup, login, login_google, login_apple, logout |
| Mood | mood_entry_created, mood_entry_deleted, mood_trend_viewed |
| Journal | journal_created, journal_deleted, journal_voice, journal_image |
| Meditation | meditation_started, meditation_completed, meditation_skipped |
| Music | music_played, music_paused, music_completed, music_downloaded |
| Yoga | yoga_started, yoga_completed |
| Breathing | breathing_started, breathing_completed |
| AI Chat | chat_started, chat_message_sent, session_ended |
| Community | post_created, comment_created, like_added, group_joined |
| Goals | goal_created, goal_completed, goal_failed |
| Recommendations | rec_shown, rec_tapped, rec_dismissed |
| Notifications | notification_received, notification_tapped |
| Profile | profile_updated, settings_changed, account_deleted |

## Analytics Storage

* Events stored locally in Hive immediately
* Synced to Firestore analytics_events collection in batches (every 50 events or 5 minutes)
* User ID is hashed for privacy
* No journal content or mood notes are ever stored in analytics

## Analytics Dashboard (Admin)

Future web dashboard showing:
* DAU/MAU
* Feature adoption rates
* Retention cohorts
* Session duration averages
* Mood distribution across user base
* Meditation completion rates
* Journal frequency trends

---

# DASHBOARD STATE MANAGEMENT

## States

| State | UI Behavior |
|-------|-------------|
| Loading | Skeleton shimmer for each card section |
| Loaded | Animate cards in sequentially with staggered delay |
| Offline | Show cached data with offline indicator banner |
| Error | Show retry button with message per failed section |
| Empty | Show friendly onboarding CTA for new users |
| Refreshing | Pull-to-refresh indicator |

## Data Refresh Strategy

| Data | Refresh Interval | Source |
|------|-----------------|--------|
| Greeting + Affirmation | On open | Hive (daily rotation) |
| Wellness Score | On open + mood entry | Calculated from Firestore data |
| Quick Actions | Static | Local |
| Recommendations | On open + every 4 hours | Firestore stream |
| Goals Progress | On open | Firestore stream |
| Mood Trends | On open | Hive (synced from Firestore) |
| Insights | On open | Firestore stream |

---

# DASHBOARD QUALITY CHECKLIST

✓ Greeting header with time awareness

✓ Wellness score ring with animation

✓ Quick action buttons (6 minimum)

✓ Mood quick-check inline

✓ Recommended content carousel

✓ Goals progress display

✓ Mood trend sparkline

✓ Quick insights cards

✓ Pull-to-refresh

✓ Skeleton loading states

✓ Offline indicator

✓ Empty state for new users

✓ Error handling per section

✓ All mood tracker steps (5)

✓ Mood calendar view

✓ Mood trends with charts

✓ AI-generated insights

✓ Analytics tracking

✓ Responsive layout (phone + tablet)

✓ Accessibility (screen reader, contrast)

✓ Animations (staggered entrance, micro-interactions)

✓ Production ready

---

## END OF PART 4

---

# PART 5 — AI THERAPIST, CONTEXT MEMORY, SAFETY DETECTION & RECOMMENDATION ENGINE

---

# AI PHILOSOPHY

The AI in Mental Mantra is NOT a therapist.

It is a supportive, empathetic wellness companion.

It must:

* Never diagnose
* Never prescribe medication
* Never promise cures
* Never replace professional healthcare
* Always encourage professional help when appropriate
* Always provide crisis resources when needed
* Maintain conversation context across sessions
* Learn user preferences over time
* Adapt tone and style to user's emotional state
* Respect privacy boundaries

---

# AI CHAT INTERFACE

## Chat Screen Layout

```
┌─────────────────────────────────┐
│  ←        AI Companion     ⋮   │
├─────────────────────────────────┤
│  "Good evening, [name] ✨"      │
│  "How are you feeling today?"   │
├─────────────────────────────────┤
│  [Message bubble]               │
│  [Message bubble]               │
│  [Message bubble]               │
├─────────────────────────────────┤
│  Suggested Actions              │
│  [Breathe] [Journal] [Meditate] │
├─────────────────────────────────┤
│  ┌──────────────────────┐ [➤]  │
│  │ Type a message...    │      │
│  └──────────────────────┘      │
│  [🎤]                          │
└─────────────────────────────────┘
```

## Features

* Chat bubble UI with smooth scroll
* Typing indicator animation
* Suggested action chips (context-aware)
* Voice input option
* Markdown rendering for formatted responses
* Emoji support
* Code-free response formatting
* Message history load (pagination, 20 per page)
* Timestamp dividers

## Conversation Starters

When user opens AI chat, show contextual starters:

| Context | Starters |
|---------|----------|
| Morning | "I'd like to set an intention for today" |
| Afternoon | "I need a midday reset" |
| Evening | "Let me reflect on my day" |
| High mood entry | "I want to build on this feeling" |
| Low mood entry | "I'm struggling right now" |
| No activity today | "Help me get started" |
| Generic | "Just want to talk" / "Give me a wellness tip" |

---

# AI PERSONALITY & TONE

## Tone Matrix

| User State | AI Tone | Example |
|------------|---------|---------|
| Happy/Calm | Warm, celebratory | "That's wonderful to hear! What made today special?" |
| Anxious | Calm, grounding | "Take a gentle breath with me. You're safe right now." |
| Sad | Gentle, validating | "It's okay to feel this way. I'm here with you." |
| Angry | Calm, reflective | "I hear your frustration. Let's work through this together." |
| Overwhelmed | Simple, structured | "Let's take this one small step at a time." |
| Grateful | Amplifying | "That sense of gratitude is beautiful. Let's savor it." |
| Neutral | Curious, open | "How's your day been so far?" |

## Personality Rules

1. Never use clinical or diagnostic language
2. Never say "you should" — prefer "would you like to try" or "what if we"
3. Mirror user's emotional vocabulary
4. Validate before suggesting
5. Use occasional gentle emojis (😌, 🌿, ✨, 💭)
6. Keep responses concise (2-4 sentences typically)
7. Ask open-ended questions
8. Celebrate small wins authentically

---

# CONTEXT MEMORY SYSTEM

## Memory Architecture

AI memory is stored in the `ai_memory` subcollection under each user.

### Memory Categories

| Category | What it stores | Example |
|----------|---------------|---------|
| user_preference | Preferred practices, times, content types | "User prefers 5-min morning meditations" |
| mood_pattern | Recurring mood trends | "Mood tends to dip on Sunday evenings" |
| trigger | Known triggers or stressors | "Work deadlines cause anxiety spikes" |
| coping_strategy | What helps the user | "Breathing exercises help during panic" |
| goal_progress | Goal-related context | "Working on sleep hygiene habit" |
| journal_theme | Recurring journal topics | "Often writes about family relationships" |
| recommendation_feedback | What user liked/disliked | "User dismissed yoga recommendations" |
| conversation_context | Recent chat topics | "Discussed workplace stress last session" |

### Memory Storage Format

```
{
  id: "autoId",
  userId: "userId",
  category: "mood_pattern",
  key: "sunday_evening_dip",
  value: {
    pattern: "Mood drops below 5 on Sunday evenings",
    confidence: 0.82,
    occurrences: 12,
    correlation: "returns to work next day"
  },
  context: "Detected from 8 weeks of mood data",
  confidence: 0.82,
  source: "mood_entry",
  expiresAt: null,  // permanent until invalidated
  isActive: true,
  createdAt: Timestamp,
  updatedAt: Timestamp
}
```

### Memory Lifecycle

```
New data point
  ↓
AIService.analyze()
  ↓
  ├── Compare with existing memories
  ├── Detect new patterns
  ├── Validate against confidence threshold (>0.6)
  ├── Store new memory if pattern confirmed
  └── Update existing memory confidence if reinforced

Memory cleanup (weekly):
  ├── Remove memories with confidence < 0.3
  ├── Expire memories past their expiresAt
  └── Consolidate overlapping memories
```

### Memory Retrieval

On each AI chat:
```
1. Load last 10 conversation_context memories
2. Load all active user_preference memories
3. Load active mood_pattern memories (last 7 days)
4. Load active trigger memories
5. Load active coping_strategy memories
6. Load recent recommendation_feedback
7. Concatenate into system prompt context
8. Trim to fit token limit (oldest removed first)
```

---

# SAFETY DETECTION SYSTEM

## Crisis Keyword Detection

Monitor incoming messages for crisis indicators:

### Level 1: Supportive Concern

Keywords: "sad", "lonely", "hopeless", "worthless", "alone"

Response:
* Validate feelings
* Offer coping strategies
* Suggest journaling or breathing exercise
* "Would you like me to share some crisis helpline numbers?"

### Level 2: Active Concern

Keywords: "want to die", "kill myself", "end my life", "suicide", "self-harm", "hurt myself"

Response:
* Immediate non-judgmental validation
* Display crisis resources card (inline, prominent)
* "I'm really glad you shared this with me. Your safety is the most important thing right now."
* "Please reach out to one of these resources — they are trained to help."
* Offer to help create a safety plan
* Log the event for safety monitoring
* NEVER dismiss, minimize, or problem-solve

### Level 3: Imminent Risk

Phrases: "about to kill myself", "have a plan", "going to end it", "taking pills"

Response:
* Same as Level 2
* Additional urgency in tone
* "Please call emergency services immediately: [country-specific number]"
* "Stay on this line with me while you call"
* Escalate to app admin/trusted contact if configured

## Crisis Resource Display

Inline card with:
* Country-specific helpline number (large, tappable to dial)
* "Call Now" button (direct dial)
* "Text a Helpline" button (if available)
* Crisis website link
* "I'm safe now" dismiss button

## Safety Logging

* Safety events logged to Firestore (content_reports or separate safety_log)
* Stored with userId, timestamp, detected level, message context (last 5 exchanges)
* Not used for analytics
 Only accessible to authorized safety moderators

---

# RECOMMENDATION ENGINE

## Recommendation Sources

| Source | Weight | Description |
|--------|--------|-------------|
| Mood-based | 0.30 | Recommendations based on current/trending mood |
| Time-based | 0.15 | Time of day, day of week |
| History-based | 0.25 | What user has engaged with before |
| Goal-based | 0.20 | Aligned with user's active goals |
| Diversity | 0.10 | Explore new content types |

## Mood-to-Recommendation Mapping

| Mood | Recommended Content |
|------|-------------------|
| Anxious | Breathing exercises, grounding meditation, calming music, journaling prompt: "What's one thing I can control right now?" |
| Sad | Gentle meditation, gratitude journal prompt, uplifting music, body scan, compassion meditation |
| Angry | Physical yoga, breathing exercises, vent journal prompt, high-energy music, walking meditation |
| Tired | Energizing yoga, energizing music, mindful walking, short meditation |
| Happy | Gratitude journal, loving-kindness meditation, share with community, celebrate |
| Overwhelmed | Breathing exercise (4-7-8), short guided meditation, prioritization journal prompt |
| Grateful | Amplify with journaling, loving-kindness practice, community share |
| Neutral | Variety — new content exploration, any category |

## Recommendation Generation Pipeline

```
Trigger: mood entry, time-based, app open, check-in
  ↓
RecommendationService.generate()
  ↓
  ├── Step 1: Collect context
  │   ├── Current mood (if available)
  │   ├── Time of day
  │   ├── Day of week
  │   ├── Recent activity (last 48h)
  │   ├── Active goals
  │   ├── Completed recommendations
  │   └── Dismissed recommendations
  │
  ├── Step 2: Score candidates
  │   ├── Fetch eligible content (meditation, music, yoga, prompts)
  │   ├── Score each item based on context
  │   │   Score = (moodMatch × 0.30) +
  │   │           (timeMatch × 0.15) +
  │   │           (historyMatch × 0.25) +
  │   │           (goalMatch × 0.20) +
  │   │           (diversityBonus × 0.10)
  │   └── Filter out recently dismissed or completed
  │
  ├── Step 3: Rank and select
  │   ├── Sort by score descending
  │   ├── Take top 5
  │   └── Ensure category diversity (max 2 same type)
  │
  ├── Step 4: Generate reasons
  │   ├── For each recommendation, generate 1-line reason
  │   │   "Because you're feeling anxious — try this breathing exercise"
  │   │   "You've been sleeping better when you meditate"
  │   └── Store reason in recommendation document
  │
  └── Step 5: Store and notify
      ├── Save to recommendations collection
      ├── Update dashboard stream
      └── Trigger notification if appropriate
```

## Recommendation Feedback Loop

User action on recommendation:
```
Recommendation shown
  ↓
  ├── Tapped → increase score for similar recommendations
  ├── Completed → strongly increase score, mark for more
  ├── Dismissed → decrease score, avoid similar
  ├── Ignored → no change (may decay over time)
  └── Expired → remove from active list

Feedback stored in ai_memory (recommendation_feedback category)
```

---

# AI CHAT SAFETY PROMPT

Every AI chat session begins with a system prompt that includes:

```
You are an AI wellness companion for Mental Mantra, a mental wellness platform.
Your role is to provide empathetic, supportive conversation focused on mental wellness.

CORE RULES:
1. NEVER diagnose mental health conditions.
2. NEVER prescribe or recommend medication.
3. NEVER claim to be a therapist or healthcare provider.
4. NEVER promise cures or guaranteed recovery.
5. ALWAYS encourage professional help when appropriate.
6. ALWAYS provide crisis resources if user expresses suicidal thoughts or self-harm.
7. ALWAYS respect user privacy.
8. NEVER store or repeat sensitive personal information outside the session.

TONE: Warm, empathetic, supportive, encouraging. Use gentle emojis occasionally.
VALIDATE before suggesting. Keep responses concise.

CRISIS RESPONSE:
If user expresses suicidal ideation, self-harm, or crisis:
1. Acknowledge their courage in sharing.
2. Provide crisis helpline immediately.
3. Offer grounding exercise.
4. Never leave them without resources.

USER CONTEXT:
[Insert relevant AI memory context here - last 10 memories]

Current user mood: [mood if available]
Time of day: [morning/afternoon/evening/night]
Recent activity: [last 3 activities]
```

---

# AI SERVICE ARCHITECTURE

```
AIService (injectable)
  ├── ChatService
  │   ├── sendMessage(userId, message)
  │   ├── getConversationHistory(userId, limit)
  │   ├── generateSuggestedResponses(context)
  │   └── analyzeSentiment(text)
  │
  ├── MemoryService
  │   ├── storeMemory(userId, category, key, value)
  │   ├── getActiveMemories(userId, categories[])
  │   ├── updateMemoryConfidence(memoryId, delta)
  │   └── cleanupExpiredMemories()
  │
  ├── SafetyService
  │   ├── analyzeMessage(text) → safetyLevel
  │   ├── getCrisisResources(country)
  │   └── logSafetyEvent(userId, level, context)
  │
  ├── RecommendationService
  │   ├── generate(userId) → List<Recommendation>
  │   ├── scoreCandidates(userId, context) → List<Score>
  │   ├── logFeedback(userId, recId, action)
  │   └── refreshIfNeeded(userId)
  │
  └── WellnessScoreService
      ├── calculate(userId) → WellnessScore
      ├── getBreakdown(userId) → Map<Category, Score>
      └── getTrend(userId, days) → List<ScorePoint>
```

---

# AI QUALITY CHECKLIST

✓ Chat interface with emoji, markdown, voice input

✓ Contextual conversation starters

✓ Tone matrix adapting to user state

✓ AI memory system with categories and confidence

✓ Memory lifecycle (store, reinforce, expire)

✓ Crisis keyword detection (3 levels)

✓ Crisis resource display with direct dial

✓ Safety event logging

✓ Recommendation generation pipeline (5 steps)

✓ Mood-to-recommendation mapping

✓ Recommendation feedback loop

✓ System prompt with safety guardrails

✓ Dependency injection for all AI services

✓ Repository pattern for all data access

✓ Hive cache for recent conversations

✓ Offline support (queued messages)

✓ Error handling with graceful fallback

✓ Production ready

---

## END OF PART 5

---

# PART 6 — JOURNAL, VOICE NOTES, IMAGE JOURNAL, CALENDAR & AI SUMMARIES

---

# JOURNAL PHILOSOPHY

The journal is a safe, private space for self-expression.

It must:

* Feel like a personal sanctuary
* Never judge content
* Offer gentle prompts when user is stuck
* Support multiple input methods (text, voice, image)
* Provide AI reflections that add insight without intrusion
* Be fully functional offline
* Sync securely when online
* Allow complete privacy control

---

# JOURNAL ENTRY TYPES

## Text Journal

Standard text entry with:
* Title (optional, auto-generated from first line if empty)
* Rich text body (heading, bold, italic, bullet lists, dividers)
* Character count (no hard limit, but UI suggests optimal range 100-2000)
* Mood tag attached to entry
* Custom tags (up to 10 per entry)
* Privacy toggle (private / shared with AI for insights only)
* Save as draft / publish

## Voice Journal

Voice recording entry:
* Tap to record, tap to stop
* Waveform visualization during recording
* Auto-pause on silence (3 seconds)
* Maximum duration: 5 minutes
* Auto-transcribe on save (AI service)
* Transcription stored alongside audio reference
* Playback within journal entry
* Download recording option

## Image Journal

Photo-based entry:
* Take photo or select from gallery
* Apply gentle filters (warm, calm, vintage, BW)
* Add caption (text)
* Multiple images per entry (up to 5)
* Auto-compress before upload
* Location tagging (optional, off by default)
* Thumbnail generation for gallery view

## Prompt-Based Journal

Respond to a prompt:
* Daily prompt (rotated from quotes/prompts collection)
* AI-suggested prompt based on mood
* Category prompts (gratitude, reflection, goal-setting, etc.)
* Free-form or structured response
* Prompt displayed at top, response below

---

# JOURNAL LIST VIEW

```
┌─────────────────────────────────┐
│  ← Journal              [+ New] │
├─────────────────────────────────┤
│  [Search bar]                   │
├─────────────────────────────────┤
│  Day View | Week View | Month   │
├─────────────────────────────────┤
│                                 │
│  📅 Today                       │
│  ┌─────────────────────────┐   │
│  │ 📝 Feeling grateful     │   │
│  │ Today I realized how... │   │
│  │ 😊 Calm    ☁️ 10:30 AM  │   │
│  └─────────────────────────┘   │
│                                 │
│  📅 Yesterday                   │
│  ┌─────────────────────────┐   │
│  │ 🎤 Voice entry          │   │
│  │ 2:34 min transcription..│   │
│  │ 😰 Anxious   🎤 8:15 PM │   │
│  └─────────────────────────┘   │
│                                 │
│  📅 Monday, June 22             │
│  ┌─────────────────────────┐   │
│  │ 📸 Morning walk         │   │
│  │ [thumbnail] [thumbnail] │   │
│  │ 😐 Neutral   📸 7:00 AM │   │
│  └─────────────────────────┘   │
│                                 │
│  [Load more...]                 │
└─────────────────────────────────┘
```

## Features

* Entries grouped by date
* Entry type icon (text, voice, image, prompt)
* Preview content (first 2 lines for text, duration for voice, thumbnails for images)
* Mood emoji + score
* Timestamp
* Swipe to delete (with confirmation)
* Tap to expand/read
* Filter by: date, mood, tags, type
* Search by content
* Calendar icon → jump to date

---

# JOURNAL EDITOR

## Text Editor

```
┌─────────────────────────────────┐
│  ← [Save]         New Entry [⋮] │
├─────────────────────────────────┤
│  [📸 Add Photo] [🎤 Record]     │
│                                 │
│  [Title placeholder...]         │
│  ─────────────────────────────  │
│                                 │
│  Start writing...               │
│                                 │
│  [Rich text toolbar]            │
│  B I U • H1 H2 • List • Divider│
│                                 │
│  Mood: 😊 Calm                  │
│  Tags: [gratitude] [morning]    │
│  Private: [toggle]              │
└─────────────────────────────────┘
```

## Features

* Title field (auto-focused on new entry)
* Rich text editing (Bold, Italic, Underline, Headings, Lists, Dividers)
* @mention for tags
* #tag inline tagging
* Image embed with tap-to-expand
* Voice recording embed with waveform
* Auto-save every 30 seconds (draft in Hive)
* Character count
* Word count
* Readability score (optional display)

## Editor States

| State | Behavior |
|-------|----------|
| New | Empty editor, placeholder text, suggested prompts |
| Editing | Loaded content, auto-save active |
| Draft | Content not yet saved explicitly, shown with "Draft" badge |
| Saving | Loading indicator, disabled save button |
| Saved | Brief "Saved" toast |
| Error | Retry banner, preserve content |
| Offline | Saved locally, "Will sync when online" indicator |

---

# VOICE RECORDING

## Recording Flow

```
Tap mic icon
  ↓
Permission check (microphone)
  ├── Denied → Show settings redirect dialog
  └── Granted → Start recording
      ↓
Recording UI:
  ├── Waveform animation (real-time)
  ├── Timer (MM:SS)
  ├── Pause/Resume button
  └── Stop button
      ↓
Stop recording
  ↓
Processing:
  ├── Save audio file locally (Hive / app directory)
  ├── Upload to Firebase Storage (if online)
  └── Send to transcription service
      ↓
Transcription complete:
  ├── Save transcription to journal entry
  ├── Link audio URL from Storage
  └── Update entry UI
```

## Voice Entry Display

```
┌─────────────────────────────────┐
│  🎤 Voice Journal Entry         │
│                                 │
│  ┌─────────────────────────┐   │
│  │ ▶  [waveform]   2:34   │   │
│  │  ────────────────────  │   │
│  │  ████████████████░░░░░ │   │
│  └─────────────────────────┘   │
│                                 │
│  Transcription:                  │
│  "Today I felt really anxious   │
│   about the meeting but I used  │
│   the breathing exercise..."    │
│                                 │
│  [Edit Transcription]           │
└─────────────────────────────────┘
```

---

# IMAGE JOURNAL

## Image Upload Flow

```
Tap camera icon
  ↓
Options: Take Photo / Choose from Gallery
  ↓
Image selected
  ↓
Edit screen:
  ├── Crop (freeform, 1:1, 4:5, 16:9)
  ├── Filters (warm, calm, vintage, BW, vibrant)
  ├── Brightness/Contrast/Saturation adjustment
  └── Caption input
      ↓
Save:
  ├── Compress image (max 2MB, 1920px longest edge)
  ├── Generate thumbnail (300px, WebP)
  ├── Upload to Firebase Storage
  └── Save reference in journal entry
```

---

# JOURNAL CALENDAR

## Calendar View

Full-page calendar showing:

* Current month with navigation arrows
* Dots on days with journal entries (colored by mood)
* Entry count indicator on days with multiple entries
* Tap day → show entries for that day
* Long press → quick entry from calendar
* Weekday headers with mood average per weekday
* Streak indicator (fire emoji for active streaks)
* Empty state for months without entries

## Heatmap View

```
     Mon  Tue  Wed  Thu  Fri  Sat  Sun
Week1  ●    ●    ○    ●    ●    ○    ○
Week2  ○    ●    ●    ●    ○    ●    ○
Week3  ●    ●    ●    ●    ●    ●    ○
Week4  ○    ○    ●    ●    ●    ○    ●

Legend: ○ No entry  ● Entry  █ High mood  █ Low mood
```

---

# AI JOURNAL SUMMARIES

## Auto-Generation

After a journal entry is saved:
```
1. Entry saved to Firestore
2. AIService.analyzeJournal(entry) triggered
3. Analysis includes:
   ├── Sentiment score (positive/neutral/negative)
   ├── Emotional keywords extracted
   ├── Topics detected (up to 5)
   ├── Key themes identified
   └── One-line summary generated
4. Analysis stored in entry.aiAnalysis map
5. Entry updated with analysis results
6. AI memory updated with themes
```

## Analysis Schema

```
aiAnalysis: {
  sentiment: {
    score: 0.72,          // -1.0 to 1.0
    label: "positive",
    confidence: 0.89
  },
  emotions: [
    { emotion: "gratitude", intensity: 0.85 },
    { emotion: "peace", intensity: 0.72 }
  ],
  topics: ["family", "gratitude", "weekend"],
  themes: ["family connection", "appreciation"],
  summary: "Felt grateful after spending quality time with family",
  suggestions: [
    "Consider sharing this feeling with your family",
    "Try a gratitude meditation tomorrow morning"
  ],
  modelVersion: "mm-ai-v1.2",
  generatedAt: Timestamp
}
```

## Weekly Summary

AI generates a weekly journal summary:

```
Your Week in Reflection:
┌─────────────────────────────────┐
│  Your Week in Reflection        │
│                                 │
│  You wrote 5 entries this week!│
│                                 │
│  Top mood: Calm 😌              │
│  Common themes: work, growth    │
│                                 │
│  Tuesday was your most          │
│  reflective day                 │
│                                 │
│  "You've been focusing on       │
│   personal growth and it shows."│
│                                 │
│  [Share Insight] [Dismiss]      │
└─────────────────────────────────┘
```

---

# JOURNAL SETTINGS

| Setting | Options | Default |
|---------|---------|---------|
| Default privacy | private / shared | private |
| Auto-generate AI insights | on / off | on |
| Weekly summary | on / off | on |
| Prompt notifications | on / off | on |
| Prompt time | time picker | 8:00 PM |
| Export format | PDF / TXT / JSON | PDF |
| Voice recording quality | standard / high | standard |
| Auto-transcribe | on / off | on |

---

# JOURNAL QUALITY CHECKLIST

✓ Text journal entry with rich text editor

✓ Voice journal recording with waveform

✓ Voice transcription via AI service

✓ Image journal with filters and captions

✓ Prompt-based journal

✓ Journal list with grouping by date

✓ Entry type icons and previews

✓ Search and filter by mood/tags/type

✓ Calendar view with mood dots

✓ Heatmap view

✓ AI sentiment analysis on save

✓ AI topic and theme extraction

✓ Weekly AI summary generation

✓ Offline save with auto-sync

✓ Auto-save drafts

✓ Image compression and thumbnail generation

✓ Firebase Storage integration

✓ Privacy toggle per entry

✓ Custom tags

✓ Export functionality

✓ Settings configuration

✓ Responsive design

✓ Accessibility (screen reader, large fonts)

✓ Animations and transitions

✓ Error handling with retry

✓ Production ready

---

## END OF PART 6

---

# PART 7 — MEDITATION, BREATHING, MUSIC THERAPY, YOGA, SPIRITUAL WELLNESS & NUTRITION

---

# WELLNESS PRACTICES PHILOSOPHY

All wellness practices in Mental Mantra must:

* Be accessible to beginners
* Offer depth for advanced practitioners
* Adapt duration based on user availability
* Be fully functional offline (cached audio)
* Track progress without judgment
* Integrate with AI recommendations
* Support cultural and spiritual diversity
* Never prescribe — always suggest

---

# MEDITATION

## Meditation Browser

```
┌─────────────────────────────────┐
│  ← Meditation                   │
├─────────────────────────────────┤
│  [For You] [Guided] [Sleep]     │
│  [Breathing] [Body Scan]        │
├─────────────────────────────────┤
│  ⭐ Recommended For You         │
│  ┌─────────────────────────┐   │
│  │  🧘 Morning Calm        │   │
│  │  5 min • Beginner       │   │
│  │  "Start your day with   │   │
│  │   peace"                │   │
│  └─────────────────────────┘   │
│                                 │
│  🔥 Most Popular                │
│  [Card] [Card] [Card]           │
│                                 │
│  🎯 By Duration                  │
│  [5 min] [10 min] [15 min]      │
│  [20 min] [30 min+]             │
│                                 │
│  🏷️ Categories                   │
│  All • Beginner • Stress        │
│  • Sleep • Focus • Gratitude    │
│  • Loving-Kindness • Body Scan  │
└─────────────────────────────────┘
```

## Meditation Categories

| Category | Description | Duration Range |
|----------|-------------|----------------|
| Guided | Voice-guided meditation with instructions | 5-30 min |
| Unguided | Silence with interval bell | 5-60 min |
| Breathing | Focused breathing exercises | 3-15 min |
| Body Scan | Progressive body awareness | 10-30 min |
| Loving-Kindness | Compassion and gratitude meditation | 10-20 min |
| Sleep | Deep relaxation for sleep preparation | 15-30 min |
| Focus | Concentration and attention building | 10-25 min |
| Stress Relief | Tension release and calming | 5-20 min |
| Walking | Mindfulness during walking | 10-20 min |
| Mantra | Repetition-based meditation | 10-20 min |

## Meditation Player

```
┌─────────────────────────────────┐
│  ←                    ⭐ ⋮      │
├─────────────────────────────────┤
│                                 │
│  🧘                             │
│  Morning Calm                   │
│  Guided • 10 min                │
│                                 │
│  ┌─────────────────────────┐   │
│  │                         │   │
│  │     ████████░░░░░░      │   │
│  │     4:32 / 10:00        │   │
│  │                         │   │
│  │     ⏮ ⏸ ⏭              │   │
│  │                         │   │
│  └─────────────────────────┘   │
│                                 │
│  🎵 Background: Gentle Rain    │
│  🔊 Volume: ████████░░          │
│                                 │
│  Instructor: Sarah Mitchell     │
│  "Notice the rise and fall      │
│   of your breath..."           │
└─────────────────────────────────┘
```

## Player Features

* Play/Pause with smooth animation
* Skip forward/backward 30 seconds
* Speed control (0.5x, 0.75x, 1x, 1.25x, 1.5x)
* Background audio support
* Lock screen controls (iOS/Android)
* Sleep timer (end of session, 5, 10, 15, 30 min)
* Volume adjustment for guidance vs background
* Download for offline
* Favorite/bookmark
* Session rating after completion (1-5 stars)
* Streak tracking

## Meditation Timer (Unguided)

```
┌─────────────────────────────────┐
│  🔔 Meditation Timer            │
│                                 │
│  Duration: [5] [10] [15] [20]  │
│  [30] [Custom]                  │
│                                 │
│  Interval bells: [2 min]        │
│  [5 min] [None]                 │
│                                 │
│  Start sound: [Singing Bowl]    │
│  End sound: [Singing Bowl]      │
│                                 │
│         [▶ Start]               │
│                                 │
│  During meditation:             │
│  - Bell at interval (optional)  │
│  - Gentle ambient background   │
│  - Interruption-free mode      │
│  - Session logged on complete   │
└─────────────────────────────────┘
```

---

# BREATHING EXERCISES

## Exercise Library

| Exercise | Pattern | Duration | Best For |
|----------|---------|----------|----------|
| Box Breathing | 4-4-4-4 | 5 min | Anxiety, focus |
| 4-7-8 Breathing | 4-7-8 | 5 min | Sleep, calm |
| Deep Belly Breathing | 4-4 | 5 min | General relaxation |
| Alternate Nostril | 4-4-4 | 5 min | Balance, clarity |
| Pursed Lip Breathing | 4-6 | 3 min | Stress relief |
| Lion's Breath | variable | 2 min | Tension release |
| Energizing Breath | 4-1-4-1 | 3 min | Energy boost |
| Calming Breath | 4-8 | 5 min | Overwhelm |

## Breathing Player

```
┌─────────────────────────────────┐
│  ← Box Breathing                │
├─────────────────────────────────┤
│                                 │
│         🌬️                      │
│                                 │
│     Inhale                      │
│     ◉ ◯ ◯ ◯                    │
│                                  │
│     Instructions:                │
│     Inhale through nose (4 sec) │
│                                 │
│     ◉◉◉◉ ░░░░ ░░░░ ░░░░       │
│                                 │
│     ┌─────────────────────┐    │
│     │        ⏸            │    │
│     └─────────────────────┘    │
│                                 │
│     Cycle 2 of 10              │
│     Total: 0:45 / 5:00         │
│                                 │
│  [Change Exercise] [Settings]   │
└─────────────────────────────────┘
```

## Breathing Animation

Visual guide with:
* Expanding/contracting circle (inhale → expand, exhale → contract)
* Color changes (inhale: cool blue, hold: purple, exhale: warm orange)
* Haptic feedback on each phase change
* Gentle background sound (optional)
* Text cues for each phase
* Progress indicator through cycles

---

# MUSIC THERAPY

## Music Player

```
┌─────────────────────────────────┐
│  ← Now Playing              ⋮   │
├─────────────────────────────────┤
│                                 │
│  [Album Art]                    │
│                                 │
│  432Hz Ocean Waves              │
│  Nature Sounds                  │
│                                 │
│  ┌─────────────────────────┐   │
│  │  ◄◄  ⏸  ►►              │   │
│  │  ████████░░░░░░░░░░     │   │
│  │  2:34 / 10:00            │   │
│  └─────────────────────────┘   │
│                                 │
│  🔊 ───────●───────             │
│                                 │
│  ♥ [Add to Favorites]           │
│  ⬇ [Download]                   │
│  🔁 [Loop]                      │
│  🔀 [Playlist Mode]             │
│                                 │
│  ─────── Up Next ───────       │
│  ▶ Calm Piano                   │
│  ▶ Rain Sounds                  │
└─────────────────────────────────┘
```

## Music Categories

| Genre | Description | Best For |
|-------|-------------|----------|
| Nature | Rain, ocean, forest, birds | Sleep, calm |
| Classical | Piano, strings, orchestral | Focus, relaxation |
| Binaural | Binaural beats (theta, alpha, delta) | Meditation, sleep, focus |
| Ambient | Atmospheric, drone, space | Meditation, background |
| Instrumental | Guitar, flute, harp, kalimba | General relaxation |
| Mantra | Chanting, sacred music | Spiritual practice |
| White Noise | White, pink, brown noise | Sleep, focus |
| Solfeggio  | 396Hz-963Hz frequencies | Healing, chakra |

## Download & Offline

* Download tracks for offline playback
* Download progress indicator
* Storage management (show used space)
* Auto-delete least played when storage low
* Smart download (AI recommends tracks to download)

## Playlists

* System playlists (by mood, activity, time of day)
* User-created playlists
* AI-generated playlists ("Based on your mood today")
* Collaborative playlists (future)

---

# YOGA

## Yoga Session Browser

```
┌─────────────────────────────────┐
│  ← Yoga                         │
├─────────────────────────────────┤
│  [Beginner] [Intermediate]      │
│  [Advanced]                     │
├─────────────────────────────────┤
│  Morning Flow                   │
│  15 min • Beginner              │
│  8 poses • Energizing           │
│  ─────────────────────────      │
│  ⭐ 4.8 (1.2k sessions)         │
│                                 │
│  [Card] [Card] [Card]           │
│                                 │
│  Categories:                    │
│  Morning • Evening • Stress     │
│  • Energy • Sleep • Full Body   │
└─────────────────────────────────┘
```

## Yoga Player

```
┌─────────────────────────────────┐
│  ←                     [Timer]  │
├─────────────────────────────────┤
│                                 │
│  [Video/Pose Illustration]      │
│                                 │
│  Downward Dog                   │
│  0:45 remaining                 │
│                                 │
│  "Breathe deeply, press your    │
│   heels toward the mat..."      │
│                                 │
│  Pose 3 of 8                    │
│  ████░░░░░░░░ 45s / 1:30       │
│                                 │
│  ⏸ Pause  ⏭ Skip               │
│                                 │
│  ─────── Poses ───────          │
│  ✅ Mountain                    │
│  ✅ Forward Fold                │
│  ▶ Downward Dog                 │
│  ○ Plank                        │
│  ○ Cobra                        │
│  ○ Child's Pose                 │
└─────────────────────────────────┘
```

## Yoga Features

* Video demonstration or illustrated guide
* Voice guidance with pose instructions
* Timer for each pose
* Skip/previous pose navigation
* Pause/resume
* Pose counter and progress
* Session completed → log to yoga_progress
* Rate session (1-5)
* Difficulty rating
* Notes per session

---

# SPIRITUAL WELLNESS

## Philosophy

Spiritual wellness is presented as optional, inclusive, and respectful.

It must:

* Never proselytize or promote any religion
* Present practices from multiple traditions as cultural wellness practices
* Allow users to opt in/out completely
* Focus on universal themes: gratitude, compassion, purpose, connection
* Use inclusive language

## Spiritual Wellness Section

```
┌─────────────────────────────────┐
│  ← Spiritual Wellness           │
├─────────────────────────────────┤
│  Your Preferences:              │
│  🤝 Inclusive practices         │
│  (Change in Settings)           │
├─────────────────────────────────┤
│  Today's Reflection             │
│  "Gratitude is not only the    │
│   greatest of virtues but the   │
│   parent of all others."       │
│  — Marcus Tullius Cicero       │
│  [Reflect] [Save]              │
├─────────────────────────────────┤
│  Practices                      │
│  ┌─────────────────────────┐   │
│  │  🕯️ Gratitude Practice  │   │
│  │  5 min • Reflection     │   │
│  └─────────────────────────┘   │
│  ┌─────────────────────────┐   │
│  │  ☮️ Loving-Kindness     │   │
│  │  10 min • Meditation    │   │
│  └─────────────────────────┘   │
│  ┌─────────────────────────┐   │
│  │  🕊️ Forgiveness        │   │
│  │  15 min • Journaling    │   │
│  └─────────────────────────┘   │
│                                 │
│  Mantras & Affirmations         │
│  • "I am enough"               │
│  • "This too shall pass"       │
│  • "Peace begins with me"      │
└─────────────────────────────────┘
```

## Content Filtering

Based on onboarding preferences:
* Secular only (no spiritual references)
* Inclusive (multi-tradition, universal themes)
* Tradition-specific (user-selected tradition)
* Mantra-inclusive (includes chanting/sound practices)

---

# NUTRITION & LIFESTYLE

## Nutrition Section

```
┌─────────────────────────────────┐
│  ← Wellness                     │
├─────────────────────────────────┤
│  [Mind] [Body] [Nutrition]      │
│  [Sleep] [Lifestyle]            │
├─────────────────────────────────┤
│  Nutrition Tips                 │
│  • Foods that boost mood        │
│  • Hydration tracker            │
│  • Mindful eating guide         │
├─────────────────────────────────┤
│  Today's Nutrition Tip          │
│  "Omega-3 fatty acids found    │
│   in walnuts and flaxseed can  │
│   support brain health."       │
├─────────────────────────────────┤
│  Meal & Mood Logging            │
│  ┌─────────────────────────┐   │
│  │  🍳 Breakfast: 8 AM     │   │
│  │  Oatmeal with berries   │   │
│  │  Mood after: 😊 Calm    │   │
│  └─────────────────────────┘   │
│  [+ Log Meal]                  │
├─────────────────────────────────┤
│  Hydration                      │
│  💧💧💧💧💧░░░░░  5/8 glasses  │
│  [+ Log Water]                  │
└─────────────────────────────────┘
```

## Lifestyle Integration

* Sleep tracking integration
* Exercise/movement logging
* Nature time reminders
* Digital wellness tips
* Screen time awareness
* Social connection prompts

---

# SESSION LOGGING & PROGRESS

All practice sessions (meditation, breathing, music, yoga) follow the same pattern:

```
Session Start
  ↓
  ├── Log: sessionId, type, contentId, startTime
  ├── Track: duration, completion %, pauses
  ↓
Session Complete (or interrupted)
  ↓
  ├── Log: endTime, durationCompleted, rating
  ├── Update: user stats (totalMinutes, totalSessions, streak)
  ├── Update: wellness_profiles (practice frequency)
  ├── Update: AI memory (preferences, patterns)
  └── Generate: recommendation feedback
```

---

# WELLNESS PRACTICES QUALITY CHECKLIST

✓ Meditation browser with categories and filters

✓ Meditation player with full controls (play, pause, skip, speed)

✓ Guided and unguided meditation support

✓ Meditation timer with interval bells

✓ Background audio and lock screen controls

✓ Breathing exercise library (8 exercises)

✓ Breathing player with animated visual guide

✓ Breathing haptic feedback

✓ Music player with categories

✓ Music download for offline

✓ Music playlists (system + user)

✓ Yoga session browser with difficulty levels

✓ Yoga player with video/illustration + timer

✓ Pose-by-pose navigation

✓ Spiritual wellness section (optional, inclusive)

✓ Nutrition tips and meal/mood logging

✓ Hydration tracker

✓ Session logging and progress tracking

✓ Streak tracking across all practices

✓ Offline playback (cached audio/video)

✓ Download management

✓ Firebase Storage integration

✓ AI recommendation integration

✓ Responsive design

✓ Accessibility (screen reader, contrast, large fonts)

✓ Animations and transitions

✓ Error handling

✓ Production ready

---

## END OF PART 7

---

# PART 8 — COMMUNITY, ANONYMOUS POSTS, SUPPORT GROUPS, CHALLENGES & REWARDS

---

# COMMUNITY PHILOSOPHY

The community is a safe, moderated space for shared wellness.

It must:

* Prioritize safety and support over engagement metrics
* Allow complete anonymity
* Be actively moderated (human + AI)
* Foster connection without pressure
* Never allow medical advice
* Encourage positive interactions
* Provide support group spaces for shared experiences

---

# COMMUNITY FEED

```
┌─────────────────────────────────┐
│  ← Community                    │
│  [For You] [Latest] [Groups]    │
├─────────────────────────────────┤
│  [+ New Post]                   │
├─────────────────────────────────┤
│  ┌─────────────────────────┐   │
│  │ 🌿 Anonymous User       │   │
│  │ 2h ago                  │   │
│  │                         │   │
│  │ "Today I did my first   │   │
│  │  5-minute meditation    │   │
│  │  and I'm proud of       │   │
│  │  myself."               │   │
│  │                         │   │
│  │ #mindfulness #beginner  │   │
│  │                         │   │
│  │ 💛 24  💬 5             │   │
│  └─────────────────────────┘   │
│                                 │
│  ┌─────────────────────────┐   │
│  │ Sarah M                  │   │
│  │ 5h ago                   │   │
│  │                         │   │
│  │ "What gratitude practice │   │
│  │  worked for you this    │   │
│  │  week? I'm looking for  │   │
│  │  new ideas."            │   │
│  │                         │   │
│  │ #gratitude #wellness    │   │
│  │                         │   │
│  │ 💛 42  💬 12            │   │
│  └─────────────────────────┘   │
│                                 │
│  [Load More...]                 │
└─────────────────────────────────┘
```

## Feed Features

* Infinite scroll with pagination (20 posts per page)
* Pull-to-refresh
* Category filter chips (General, Support, Gratitude, Tips, Mindfulness)
* Sort: For You (AI-ranked), Latest, Top (weekly)
* Anonymous user indicator (🌿 icon)
* Real-time like and comment count updates
* Post reporting (three dots menu → Report)
* Saved posts bookmark

---

# CREATE POST

```
┌─────────────────────────────────┐
│  ← Cancel       New Post [Post] │
├─────────────────────────────────┤
│                                 │
│  [Switch to Anonymous toggle]   │
│                                 │
│  Category: [Select...]          │
│                                 │
│  What's on your mind?           │
│  ┌─────────────────────────┐   │
│  │                         │   │
│  │                         │   │
│  │  (max 2000 characters)  │   │
│  └─────────────────────────┘   │
│                                 │
│  Tags: [add tags...]            │
│                                 │
│  ─── Post Options ───          │
│  🔒 Post anonymously            │
│  🔔 Enable comments             │
│  📍 Share progress (attach      │
│     streak/achievement badge)   │
└─────────────────────────────────┘
```

## Post Validation

* Content required (min 10 characters, max 2000)
* Category required (from enum)
* Anonymous toggle defaults to user's profile setting
* Tags optional (max 5)
* Posts moderated before going public (AI + human)
* Sensitive content warning (if AI detects potentially triggering content)

---

# COMMENTS

```
┌─────────────────────────────────┐
│  ← Post               💬 12    │
├─────────────────────────────────┤
│  [Original Post Content]        │
│  [Likes] [Share] [Save]        │
├─────────────────────────────────┤
│  Comments                       │
│                                 │
│  ┌─────────────────────────┐   │
│  │ Alex K  • 2h            │   │
│  │ That's amazing! Keep it │   │
│  │ up! Every minute counts │   │
│  │ 💛 8                    │   │
│  └─────────────────────────┘   │
│                                 │
│  ┌─────────────────────────┐   │
│  │ 🌿 Anonymous  • 1h     │   │
│  │ I started with 2 min   │   │
│  │ and now do 20! You got │   │
│  │ this! 💛 15             │   │
│  └─────────────────────────┘   │
│                                 │
│  ┌──────────────────────┐ [➤] │
│  │ Write a comment...   │      │
│  └──────────────────────┘      │
└─────────────────────────────────┘
```

## Comment Features

* Real-time updates via Firestore stream
* Nested replies (1 level deep)
* Anonymous commenting option
* Like comments
* Report comments
* Delete own comments
* Sort: Latest, Oldest, Most Liked

---

# SUPPORT GROUPS

## Group Browser

```
┌─────────────────────────────────┐
│  ← Support Groups               │
├─────────────────────────────────┤
│  My Groups                       │
│  ┌─────────────────────────┐   │
│  │ 🌿 Anxiety Support     │   │
│  │ 245 members • 12 online │   │
│  │ Last message: 5m ago    │   │
│  └─────────────────────────┘   │
│  ┌─────────────────────────┐   │
│  │ 🧘 Morning Mindfulness  │   │
│  │ 89 members • 3 online   │   │
│  │ Last message: 1h ago    │   │
│  └─────────────────────────┘   │
│                                 │
│  Discover Groups                 │
│  [Category filters]             │
│  [Card] [Card] [Card]           │
└─────────────────────────────────┘
```

## Group Chat

```
┌─────────────────────────────────┐
│  ← Anxiety Support Group  [⋮]  │
├─────────────────────────────────┤
│  Group: 245 members             │
│  🌿 You're anonymous here       │
├─────────────────────────────────┤
│  ┌─────────────────────────┐   │
│  │ 🌿 Member              │   │
│  │ Has anyone tried the   │   │
│  │ grounding exercises?   │   │
│  │ 10:32 AM               │   │
│  └─────────────────────────┘   │
│  ┌─────────────────────────┐   │
│  | 🌿 Alex (Mod)          │   │
│  │ Yes! The 5-4-3-2-1     │   │
│  │ technique really helps │   │
│  │ me during panic        │   │
│  │ 10:34 AM               │   │
│  └─────────────────────────┘   │
│                                 │
│  ┌──────────────────────┐ [➤] │
│  │ Type a message...   │      │
│  └──────────────────────┘      │
└─────────────────────────────────┘
```

## Group Features

* Category-based groups (anxiety, stress, grief, mindfulness, gratitude, parenting, sleep, general)
* Open / Request / Invite join methods
* Anonymous by default
* Moderators assigned per group
* Group rules displayed on join
* Member count and online indicator
* Message history (last 7 days visible, premium = full history)
* Mute/notification controls
* Leave group option
* Report member to mod

## Group Moderation

* Message reporting
* Automatic moderation flagging for:
  * Medical advice claims
  * Harmful content
  * Spam
  * Harassment
* Moderator tools: delete message, warn member, remove member
* AI flagging for review

---

# CHALLENGES

## Challenge Types

| Type | Duration | Example |
|------|----------|---------|
| Daily | 1 day | "Meditate for 5 minutes today" |
| Weekly | 7 days | "Journal every day this week" |
| Monthly | 30 days | "30-day meditation challenge" |
| Custom | User-defined | "10 sessions in 2 weeks" |

## Challenge System

```
┌─────────────────────────────────┐
│  ← Challenges                   │
├─────────────────────────────────┤
│  Active Challenges              │
│  ┌─────────────────────────┐   │
│  │ 🔥 7-Day Meditation    │   │
│  │ Day 4 of 7             │   │
│  │ ██████░░░░░░░░         │   │
│  │ 387 participants       │   │
│  │ [Continue] [Share]     │   │
│  └─────────────────────────┘   │
│                                 │
│  Available Challenges           │
│  [Card] [Card] [Card]           │
│                                 │
│  Completed                       │
│  🏆 Gratitude Week ✅           │
│  🏆 Sleep Better ✅             │
└─────────────────────────────────┘
```

## Challenge Features

* Join challenge with 1 tap
* Progress tracking within challenge
* Daily check-in requirement
* Streak within challenge
* Community challenge (participants count)
* Share progress (to community or keep private)
* Reward on completion (achievement + points)

---

# ACHIEVEMENTS & REWARDS

## Achievement System

| Category | Achievement | Criteria | Points |
|----------|-------------|----------|--------|
| Mood | First Mood Check-in | Log first mood | 10 |
| Mood | Week Tracker | 7-day mood streak | 50 |
| Mood | Month Tracker | 30-day mood streak | 200 |
| Meditation | First Meditation | Complete first session | 10 |
| Meditation | Week Warrior | 7-day meditation streak | 100 |
| Meditation | Hour of Peace | 60 total minutes | 100 |
| Meditation | Centurion | 100 sessions | 500 |
| Journal | First Entry | Write first journal | 10 |
| Journal | Daily Writer | 7-day journal streak | 100 |
| Journal | 100 Entries | Write 100 entries | 500 |
| Yoga | First Flow | Complete first yoga | 10 |
| Yoga | Yoga Week | 7-day yoga streak | 100 |
| Community | First Post | Make first post | 10 |
| Community | Helper | 10 comments | 50 |
| Community | Supporter | 50 likes given | 100 |
| Streak | 7-Day Streak | Any 7-day streak | 100 |
| Streak | 30-Day Streak | Any 30-day streak | 500 |
| Streak | 100-Day Streak | Any 100-day streak | 2000 |
| Goals | Goal Crusher | Complete 10 goals | 200 |

## Achievement Display

```
┌─────────────────────────────────┐
│  ← Achievements                 │
│                                 │
│  🏆 Level 12 • 2,450 points    │
│                                 │
│  ─── Recent ───                 │
│  🎉 Week Warrior unlocked!     │
│  "7-day meditation streak"     │
│  100 points                    │
│                                 │
│  ─── All Achievements ───      │
│  ┌───┐┌───┐┌───┐┌───┐┌───┐   │
│  │ 🏆 ││ 🏆 ││ 🔒││ 🔒││ 🔒│   │
│  │First││Week││100 ││30d ││Yoga│   │
│  │Mood ││War.││Sess││Stre││Week│   │
│  └───┘└───┘└───┘└───┘└───┘   │
│                                 │
│  Points Breakdown               │
│  Mood: ████████ 450            │
│  Meditation: ████████ 500      │
│  Journal: ██████ 320           │
│  Streaks: ██████████ 680       │
└─────────────────────────────────┘
```

## Rewards

| Reward | Cost (Points) | Description |
|--------|--------------|-------------|
| Premium Theme | 500 | Unlock exclusive theme |
| Special Avatar | 300 | Exclusive avatar frame |
| Custom Badge | 200 | Profile badge |
| Extended History | 1000 | Full journal history export |
| Ad-Free Week | 400 | 7 days without ads |
| Premium Trial | 2000 | 1 month premium trial |

---

# MODERATION SYSTEM

## AI Moderation

Automated checks on every post and comment:

| Check | Description | Action |
|-------|-------------|--------|
| Hate speech | Detect discriminatory language | Auto-reject, flag user |
| Medical advice | "You should take X medication" | Flag for review |
| Harassment | Personal attacks, bullying | Auto-reject, warn user |
| Spam | Repeated content, links | Auto-reject, flag user |
| Crisis language | Suicide/self-harm mentions | Keep post, add resource, notify mods |
| Explicit content | NSFW, inappropriate | Auto-reject, flag user |

## Human Moderation

* Queue of flagged content in moderation dashboard
* Moderator actions: Approve, Reject, Warn User, Ban User
* Appeal process for rejected content
* Moderation log for transparency

---

# COMMUNITY QUALITY CHECKLIST

✓ Community feed with infinite scroll

✓ Category and sort filters

✓ Post creation with anonymous toggle

✓ AI content moderation pipeline

✓ Comment system with nested replies

✓ Real-time like and comment updates

✓ Post reporting

✓ Support group browser

✓ Group chat with anonymity

✓ Group moderation tools

✓ Challenge system (daily, weekly, monthly)

✓ Achievement system with categories

✓ Points and reward system

✓ Achievement display with locked/unlocked states

✓ User levels and progression

✓ AI safety moderation

✓ Human moderation queue

✓ Appeal process

✓ Firestore integration

✓ Offline support (cached feed)

✓ Error handling

✓ Responsive design

✓ Accessibility

✓ Production ready

---

## END OF PART 8

---

# PART 9 — NOTIFICATIONS, GOALS, STREAKS, GAMIFICATION & AI COMPANION

---

# NOTIFICATION PHILOSOPHY

Notifications must be helpful, never annoying.

They must:

* Be personalized and contextual
* Respect user schedule and quiet hours
* Never overwhelm (max 3 per day unless critical)
* Provide value in the notification preview
* Be easily configurable per category
* Support rich notification content
* Be actionable (respond directly from notification)

---

# NOTIFICATION TYPES

## Reminder Notifications

| Type | Default Time | Frequency | Content |
|------|-------------|-----------|---------|
| Mood Check-in | User-defined | Daily | "How are you feeling today, [name]?" |
| Journal Prompt | 8:00 PM | Daily | "What was the best part of your day?" |
| Meditation | User-defined | Daily | "Time for your [X]-minute meditation 🌿" |
| Bedtime Wind-down | 9:00 PM | Daily | "Time to wind down. Try a sleep meditation" |
| Hydration | Every 2 hours | 8x/day | "Time to hydrate! 💧" |
| Goal Reminder | User-defined | Per goal | "You're 80% to your [goal] goal!" |

## Motivational Notifications

| Type | Trigger | Content |
|------|---------|---------|
| Streak Milestone | 3, 7, 14, 21, 30 days | "🔥 [X]-day streak! You're on fire!" |
| Achievement | Unlocked | "🏆 Achievement unlocked: [name]" |
| Goal Complete | Goal finished | "🎉 Goal complete! You did it!" |
| Wellness Milestone | Score increase | "Your wellness score went up by 5 points!" |

## Informational Notifications

| Type | Schedule | Content |
|------|----------|---------|
| Daily Quote | Morning | "[Quote] — [Author]" |
| Wellness Tip | Afternoon | "Tip: [brief wellness tip]" |
| Weekly Summary | Sunday evening | "Your wellness week in review" |
| New Content | When available | "New [meditation/music] available!" |

## Community Notifications

| Type | Trigger |
|------|---------|
| Post Reply | Someone replies to your post |
| Comment Reply | Someone replies to your comment |
| Post Like | Someone likes your post |
| Group Message | New message in group (if unmuted) |
| Achievement Share | Friend unlocked achievement |

## Critical Notifications

| Type | Content |
|------|---------|
| Crisis Resource | "Need someone to talk to?" with helpline |
| Missed Check-in | "We noticed you haven't checked in. Everything okay?" |
| Long Inactivity | "It's been a while. We're here when you're ready." |

---

# NOTIFICATION DELIVERY

## Local Notifications (Offline)

* Scheduled via flutter_local_notifications
* Stored in Hive notification queue
* Displayed regardless of internet connection
* Queued when app is backgrounded
* Rescheduled on device reboot

## Push Notifications (Online)

* Via Firebase Cloud Messaging
* Sent from server or Cloud Function
* Received when app is in background/terminated
* Handled via onMessage, onBackgroundMessage, onTerminated

## Notification Channels (Android)

| Channel | Importance | Sound |
|---------|-----------|-------|
| Reminders | High | Gentle chime |
| Motivation | High | Positive bell |
| Community | Default | Soft notification |
| Critical | Urgent | Distinct alert |
| Tips | Low | Silent |

---

# NOTIFICATION SETTINGS SCREEN

```
┌─────────────────────────────────┐
│  ← Notification Settings        │
├─────────────────────────────────┤
│  General                         │
│  ┌─────────────────────────┐   │
│  │ Push Notifications  [🔛]│   │
│  │ Sound              [🔛]│   │
│  │ Vibration          [🔛]│   │
│  │ Quiet Hours  [10PM-7AM]│   │
│  └─────────────────────────┘   │
│                                 │
│  Reminders                      │
│  ┌─────────────────────────┐   │
│  │ Mood Check-in     [🔛]  │   │
│  │   Time: [8:00 PM]      │   │
│  │ Journal Prompt    [🔛]  │   │
│  │   Time: [8:00 PM]      │   │
│  │ Meditation        [🔛]  │   │
│  │   Time: [7:00 AM]      │   │
│  │ Hydration         [🔛]  │   │
│  │   Every: [2 hours]    │   │
│  └─────────────────────────┘   │
│                                 │
│  Motivation                     │
│  ┌─────────────────────────┐   │
│  │ Streaks            [🔛] │   │
│  │ Achievements       [🔛] │   │
│  │ Goal Complete      [🔛] │   │
│  └─────────────────────────┘   │
│                                 │
│  Content                        │
│  ┌─────────────────────────┐   │
│  │ Daily Quote        [🔛] │   │
│  │   Time: [7:00 AM]      │   │
│  │ Wellness Tips      [🔛] │   │
│  │ Weekly Summary     [🔛] │   │
│  └─────────────────────────┘   │
│                                 │
│  Community                      │
│  ┌─────────────────────────┐   │
│  │ Replies             [🔛]│   │
│  │ Likes               [🔛]│   │
│  │ Group Messages      [🔛]│   │
│  └─────────────────────────┘   │
└─────────────────────────────────┘
```

---

# GOALS SYSTEM

## Goal Lifecycle

```
Create Goal
  ↓
Active (in progress)
  ↓
  ├── Complete → mark completedAt → calculate streak
  ├── Fail → mark failedAt → optional retry
  ├── Pause → mark pausedAt → preserve progress
  ├── Archive → hide from active view
  └── Delete → soft delete
```

## Goal Creation Screen

```
┌─────────────────────────────────┐
│  ← Cancel     New Goal  [Save]  │
├─────────────────────────────────┤
│  Title: [__________________]    │
│                                 │
│  Description (optional):        │
│  [__________________________]   │
│                                 │
│  Category: [Select...]          │
│  [Mindfulness] [Fitness]        │
│  [Sleep] [Social] [Productivity]│
│  [Self-care] [Spiritual] [Custom]│
│                                 │
│  Type: [Daily] [Weekly]         │
│  [Monthly] [Custom]             │
│                                 │
│  Target: [___] [minutes/times]  │
│                                 │
│  Duration: [No end date]        │
│  [End date picker]              │
│                                 │
│  Reminder: [Time picker]        │
│  [🔔 Enable reminder]           │
│                                 │
│  Make this a habit? [toggle]    │
└─────────────────────────────────┘
```

## Goal Display

Goal cards showing:
* Title and category icon
* Progress bar (animated fill)
* Current value / target value
* Streak indicator (🔥 N days)
* Days remaining or "No deadline"
* Check-in button (tap to increment progress)
* 3-dot menu: Edit, Pause, Archive, Delete

---

# STREAK SYSTEM

## Streak Calculation

| Activity Type | Streak Definition |
|--------------|-------------------|
| Mood check-in | Consecutive days with at least 1 mood entry |
| Meditation | Consecutive days with at least 1 completed session |
| Journaling | Consecutive days with at least 1 journal entry |
| Yoga | Consecutive days with at least 1 session |
| Goal | Consecutive days meeting goal target |
| Overall | Consecutive days with any activity |

## Streak Rules

- Day counts if any qualifying activity occurs (based on user's timezone)
- Grace period: missed day can be made up within 24 hours (1 per month)
- Streak freeze: premium feature, freezes streak for 1 day
- Streak resets to 0 after 2 consecutive missed days (without freeze)
- Streak saved locally and synced to Firestore

## Streak Display

```
┌─────────────────────────────────┐
│  🔥 14 Day Streak!              │
│  You're on fire! Keep going!   │
│                                 │
│  This Week:                     │
│  M  T  W  T  F  S  S           │
│  🔥🔥🔥🔥🔥🔥🔥  7 days        │
│                                 │
│  Last Week:                     │
│  M  T  W  T  F  S  S           │
│  🔥🔥🔥🔥🔥🔥🔥  7 days        │
│                                 │
│  Best Streak: 21 days           │
│  Current Streak: 14 days       │
│  Streak Freezes Available: 2    │
└─────────────────────────────────┘
```

---

# GAMIFICATION SYSTEM

## Points System

| Action | Points | Daily Max |
|--------|--------|-----------|
| Complete mood check-in | 10 | 10 |
| Write journal entry | 20 | 40 |
| Complete meditation | 30 | 60 |
| Complete breathing exercise | 15 | 30 |
| Complete yoga session | 25 | 50 |
| Listen to music (5+ min) | 5 | 20 |
| Post in community | 15 | 15 |
| Comment on post | 5 | 25 |
| Like a post | 2 | 10 |
| Complete a goal | 100 | 100 |
| Maintain streak (per day) | 10 × streak multiplier | - |
| Log water intake | 3 | 15 |
| Log meal | 5 | 15 |

## Level System

| Level | Points Required | Title |
|-------|----------------|-------|
| 1 | 0 | Beginner |
| 2 | 100 | Explorer |
| 3 | 250 | Learner |
| 4 | 500 | Practitioner |
| 5 | 1000 | Dedicated |
| 6 | 2000 | Committed |
| 7 | 3500 | Devoted |
| 8 | 5500 | Champion |
| 9 | 8000 | Warrior |
| 10 | 12000 | Master |
| 11+ | +5000 per level | Ascending tiers |

## Streak Multiplier

```
Streak Days  |  Points Multiplier
  1-6        |  1x
  7-13       |  1.5x
  14-29      |  2x
  30-59      |  3x
  60-89      |  4x
  90+        |  5x
```

---

# AI COMPANION

## Companion Presence

The AI companion is accessible from:
* Dashboard (chat bubble)
* Bottom nav (chat tab)
* Floating action button on most screens
* Notification tap → opens chat

## Companion Features

| Feature | Description |
|---------|-------------|
| Daily Check-in | "How was your day?" conversation |
| Guided Reflection | Themed reflection conversations |
| Crisis Support | Safety protocols when needed |
| Goal Check-in | "How's your [goal] going?" |
| Wellness Tips | Contextual tips based on data |
| Journal Buddy | "Want to journal together?" |
| Meditation Guide | "Ready to meditate?" |
| Accountability | "You haven't journaled today. Want to?" |

## Companion Personality Settings

Based on onboarding preferences:
* Tone: warm, professional, encouraging, direct
* Formality: casual, balanced, formal
* Emoji usage: none, minimal, moderate, expressive
* Check-in frequency: low, medium, high
* Proactive suggestions: on/off

---

# GOALS & GAMIFICATION QUALITY CHECKLIST

✓ All notification types implemented

✓ Local notification scheduling

✓ Push notification via FCM

✓ Notification channels (Android)

✓ Notification settings screen with toggles

✓ Goal CRUD with categories

✓ Goal progress tracking

✓ Goal lifecycle (active, paused, completed, failed)

✓ Streak calculation for all activity types

✓ Streak display with calendar view

✓ Streak freeze mechanic (premium)

✓ Points system with daily max limits

✓ Level system with titles

✓ Streak multiplier

✓ Gamification across all features

✓ AI companion presence throughout app

✓ Companion personality customization

✓ Proactive companion nudges

✓ Firestore integration

✓ Hive cache for notifications/goals

✓ Offline support

✓ Error handling

✓ Responsive design

✓ Accessibility

✓ Production ready

---

## END OF PART 9

---

# PART 10 — OFFLINE SYNC, HIVE CACHE, PERFORMANCE & SECURITY

---

# OFFLINE-FIRST PHILOSOPHY

Mental Mantra must work without internet access.

Every feature must:

* Function fully offline
* Store data locally first
* Sync to cloud when connectivity returns
* Handle conflicts gracefully
* Never lose user data
* Show clear connectivity status
* Prioritize user experience over sync consistency

---

# HIVE LOCAL DATABASE

## Hive Boxes

| Box Name | Type | Data Stored | Persistence |
|----------|------|-------------|-------------|
| appSettings | LocalSettings | Theme, language, onboarding status, auth state | Permanent |
| userCache | UserCache | User profile, preferences, notification settings | Permanent |
| moodCache | List<MoodEntry> | Recent 90 days of mood entries | Permanent |
| journalCache | List<JournalEntry> | Recent 50 journal entries (full), older as summaries | Permanent |
| goalCache | List<Goal> | All active goals + recent completed | Permanent |
| habitCache | List<Habit> | All active habits | Permanent |
| meditationCache | List<MeditationSession> | Catalog of meditation sessions (metadata) | Temporary (refreshed) |
| musicCache | List<MusicTrack> | Catalog of music tracks (metadata) | Temporary (refreshed) |
| yogaCache | List<YogaSession> | Catalog of yoga sessions (metadata) | Temporary (refreshed) |
| recommendationCache | List<Recommendation> | Current active recommendations | Temporary (refreshed) |
| notificationCache | List<Notification> | Recent 50 notifications | Permanent |
| quoteCache | List<Quote> | Daily quotes (7 days cached) | Temporary (refreshed) |
| communityCache | List<CommunityPost> | Recent 50 feed posts | Temporary (refreshed) |
| syncQueue | List<SyncQueueItem> | Pending sync operations | Permanent |
| conversationCache | List<ChatMessage> | Recent AI chat conversations | Permanent |
| meditationProgressCache | Map<String, UserMeditationStats> | User meditation stats | Permanent |
| yogaProgressCache | Map<String, UserYogaStats> | User yoga stats | Permanent |
| achievementCache | List<UserAchievement> | User achievements | Permanent |
| downloadedContent | List<DownloadedContent> | Downloaded meditation/music files metadata | Permanent |

## Hive Initialization

```
App Start
  ↓
  ├── 1. Initialize Hive (Hive.initFlutter())
  ├── 2. Register all TypeAdapters
  ├── 3. Open all boxes
  ├── 4. Check box integrity
  ├── 5. Load cached user state
  └── 6. Determine if fresh sync needed
```

## TypeAdapters

Every model class must have a TypeAdapter registered:

| Adapter | Fields |
|---------|--------|
| UserAdapter | all user fields |
| MoodEntryAdapter | all mood entry fields |
| JournalEntryAdapter | all journal entry fields |
| GoalAdapter | all goal fields |
| HabitAdapter | all habit fields |
| MeditationSessionAdapter | all meditation session fields |
| MusicTrackAdapter | all music track fields |
| YogaSessionAdapter | all yoga session fields |
| RecommendationAdapter | all recommendation fields |
| NotificationAdapter | all notification fields |
| QuoteAdapter | all quote fields |
| CommunityPostAdapter | all community post fields |
| SyncQueueItemAdapter | all sync queue fields |
| ChatMessageAdapter | all chat message fields |
| AchievementAdapter | all achievement fields |
| DownloadedContentAdapter | all downloaded content fields |

---

# OFFLINE SYNC ENGINE

## Sync Queue Architecture

```
User performs action while offline
  ↓
Repository.save(entity)
  ↓
  ├── 1. Save to Hive cache (immediate)
  ├── 2. Create SyncQueueItem
  │   {
  │     id: autoId,
  │     userId: currentUser.id,
  │     operation: "create" | "update" | "delete",
  │     collection: "users/{uid}/mood_entries",
  │     documentId: entryId,
  │     data: serializedEntry,
  │     localTimestamp: DateTime.now(),
  │     retryCount: 0,
  │     maxRetries: 5,
  │     lastError: null,
  │     status: "queued"
  │   }
  ├── 3. Add to syncQueue Hive box
  ├── 4. Update UI optimistically
  └── 5. Return success to user
```

## Sync Execution

```
Connectivity restored (or periodic trigger)
  ↓
SyncService.processQueue()
  ↓
  ├── 1. Get all items WHERE status == "queued" OR status == "failed"
  │       ORDER BY localTimestamp ASC
  ├── 2. Lock queue (prevent concurrent processing)
  ├── 3. Process batch (max 10 items per batch):
  │   ├── For each item:
  │   │   ├── Mark status = "syncing"
  │   │   ├── Execute Firestore operation
  │   │   │   ├── create: FirestoreService.create()
  │   │   │   ├── update: FirestoreService.update()
  │   │   │   └── delete: FirestoreService.delete()
  │   │   ├── On success:
  │   │   │   ├── Mark status = "completed"
  │   │   │   ├── Update local Hive cache with server response
  │   │   │   └── Remove from queue after 24h
  │   │   └── On failure:
  │   │       ├── Increment retryCount
  │   │       ├── Log error to lastError
  │   │       ├── If retryCount < maxRetries:
  │   │       │   └── Mark status = "failed" (will retry later)
  │   │       └── If retryCount >= maxRetries:
  │   │           ├── Mark status = "failed_permanent"
  │   │           └── Notify user of sync failure
  │   └── Continue to next item
  ├── 4. After batch complete:
  │   ├── Pull fresh data from Firestore for recently modified collections
  │   └── Update Hive cache with server data
  └── 5. Release queue lock
```

## Sync Triggers

| Trigger | Action |
|---------|--------|
| App foregrounds | Process full queue |
| Connectivity restored | Process full queue |
| Periodic (every 5 min while online) | Process queue (if not empty) |
| After write operation (online) | Skip queue, write directly to Firestore |

## Conflict Resolution

Refer to Part 2C-2 Conflict Resolution Strategy for the full algorithm.

Summary:
- Compare version + updatedAt timestamps
- Field-level merge where possible
- User-generated content: last write wins
- System-generated content: server wins
- If automatic merge fails → flag as conflict, let user choose

---

# NETWORK STATUS DETECTION

## Connectivity Service

```
ConnectivityService (injectable)
  ├── stream: Stream<ConnectivityStatus>
  │   emits: online / offline / weakConnection
  ├── isOnline: bool (synchronous check)
  ├── connectionType: wifi / cellular / none
  └── listen() / dispose()
```

## UI Indicators

| Status | Indicator |
|--------|-----------|
| Online | No indicator (normal operation) |
| Offline | Subtle banner: "You're offline. Changes will sync when connected." |
| Weak | Small icon: "Slow connection" |
| Syncing | Brief indicator: "Syncing your changes..." |
| Sync Error | Warning: "Some changes couldn't sync. Tap to retry." |

---

# PERFORMANCE OPTIMIZATION

## Startup Performance

| Optimization | Technique | Target |
|-------------|-----------|--------|
| Cold start | Lazy initialization of non-critical services | < 2 seconds to interactive |
| Splash screen | Native splash with minimal loading | < 500ms |
| Firebase init | Async initialization with loading state | Non-blocking |
| Hive init | Open critical boxes first, defer non-critical | < 200ms |
| Image loading | Progressive JPEG/WebP, cached network images | < 1s per image |

## Runtime Performance

| Area | Optimization | Threshold |
|------|-------------|-----------|
| UI frames | 60fps smooth scrolling | No jank |
| Memory | Image cache limit: 50MB | App < 150MB |
| Animations | GPU-accelerated transitions | 60fps |
| Lists | Pagination (20 items), lazy loading | < 100ms per page |
| Firebase reads | Cache-first strategy | < 200ms per read |
| Firebase writes | Batch operations | < 500ms per batch |
| AI responses | Streaming response | First token < 2s |

## Image Optimization

* User uploads: compress to max 1920px, 80% quality JPEG/WebP
* Thumbnails: generate 300px WebP at time of upload
* Profile photos: cache locally, refresh weekly
* Content images: use Firestore URLs with cloud storage CDN
* Memory: Use `cached_network_image` with disk cache

## List Optimization

* All lists use pagination (limit 20, cursor-based)
* Use `ListView.builder` (never `ListView` with all children)
* Item separation with `SliverList` for complex layouts
* Lazy loading on scroll to bottom
* Debounce search inputs (300ms)

---

# SECURITY

## Environment Security

| Secret | Storage Method |
|--------|---------------|
| Firebase API keys | google-services.json / GoogleService-Info.plist (gitignored) |
| Firestore rules | firestore.rules (version controlled) |
| Remote Config defaults | Config class (defaults, overridden by Remote Config) |
| AI API keys | Firebase Remote Config or Cloud Function proxy |
| Feature flags | Firebase Remote Config |

## Data Security

| Layer | Protection |
|-------|-----------|
| In transit | TLS 1.3 (Firestore default) |
| At rest | Firestore encryption at rest |
| Local storage | Hive with optional encryption |
| Auth tokens | Secure storage (flutter_secure_storage) |
| User data | Firestore security rules enforce per-user access |

## Code Security

* No secrets in code (use environment config)
* Input sanitization on all user inputs
* SQL injection not applicable (NoSQL)
* Firestore rules validation on all writes
* Rate limiting via Firebase (App Check + security rules)
* Proper error handling — never expose internal details

---

# BACKUP & DATA EXPORT

## Automatic Backup

* Firestore automated daily exports (30-day retention)
* Hive local data persists across app reinstalls (app data directory)

## User-Initiated Export

```
Settings → Download My Data
  ↓
  ├── Select data to export:
  │   ├── Mood history
  │   ├── Journal entries
  │   ├── Meditation/yoga progress
  │   └── Goals and achievements
  ├── Export format: JSON / PDF / CSV
  ├── Process: collect data from Firestore + Hive
  ├── Generate file locally
  └── Share via system share sheet
```

---

# OFFLINE & PERFORMANCE QUALITY CHECKLIST

✓ All Hive boxes defined with correct persistence strategy

✓ TypeAdapters for all model classes

✓ Hive initialization on app start

✓ Offline sync queue with status tracking

✓ Sync execution with retry logic (max 5 retries)

✓ Sync triggers (foreground, connectivity, periodic)

✓ Conflict resolution strategy implemented

✓ Network connectivity detection service

✓ UI indicators for offline/syncing/sync error

✓ Cold start optimization (< 2s to interactive)

✓ Image compression and caching

✓ List pagination across all list screens

✓ Lazy loading and scroll performance

✓ GPU-accelerated animations

✓ Firebase cache-first read strategy

✓ No secrets in code

✓ Input sanitization

✓ Firestore security rules enforced

✓ User data export

✓ Flutter secure storage for tokens

✓ Error handling with no info leakage

✓ Production ready

---

## END OF PART 10

---

# PART 11 — TESTING, QA, ACCESSIBILITY, CI/CD & DEPLOYMENT

---

# TESTING PHILOSOPHY

Every line of production code must be tested.

Testing is not optional.

Test types:

| Type | Scope | Who Writes |
|------|-------|------------|
| Unit tests | Individual functions, services, repositories | Developer |
| Widget tests | Individual widgets, small component trees | Developer |
| Integration tests | Full feature flows | QA Engineer |
| Golden tests | Visual regression | QA Engineer |
| Firebase emulator tests | Firestore rules, auth, storage | Developer |
| Performance tests | Startup, scrolling, memory | Performance Engineer |

---

# UNIT TESTING

## Coverage Requirements

| Layer | Minimum Coverage | What to Test |
|-------|-----------------|--------------|
| Models | 100% | fromJson, toJson, copyWith, equality, validation |
| Services | 90% | Each method, error states, edge cases |
| Repositories | 90% | Data flow, caching, sync, error handling |
| BLoCs/Providers | 90% | States, events, error handling |
| Utils/Extensions | 100% | All utility functions |
| Validators | 100% | All validation rules |

## Unit Test Structure

```
test/
  models/
    user_test.dart
    mood_entry_test.dart
    journal_entry_test.dart
    ...
  services/
    auth_service_test.dart
    mood_service_test.dart
    journal_service_test.dart
    sync_service_test.dart
    ...
  repositories/
    mood_repository_test.dart
    journal_repository_test.dart
    ...
  providers/
    dashboard_provider_test.dart
    mood_provider_test.dart
    ...
  utils/
    validators_test.dart
    date_utils_test.dart
    ...
```

## Mocking Strategy

Use `mockito` for all external dependencies:
* Firebase services (Firestore, Auth, Storage, Messaging)
* Hive (use in-memory Hive for tests)
* Network connectivity
* AI service
* Platform channels

---

# WIDGET TESTING

## Widget Test Coverage

| Component | Tests |
|-----------|-------|
| Reusable widgets | Every widget variant, all states |
| Screens | Loading, loaded, empty, error, offline states |
| Forms | Validation, submission, error display |
| Modals | Open, dismiss, action |
| Navigation | Route transitions, deep links |

## Golden Tests

* Critical screens captured as golden images
* Tested on iOS and Android reference devices
* Pixel-perfect comparison
* Automatic failure on visual regression
* Updated intentionally when UI changes

---

# INTEGRATION TESTING

## Feature Flow Tests

| Feature | Test Scenarios |
|---------|---------------|
| Authentication | Signup, login, logout, password reset, token refresh |
| Onboarding | Complete flow, skip, resume, back navigation |
| Mood Tracking | Create entry, view calendar, view trends |
| Journal | Create text/voice/image entry, edit, delete, search |
| Meditation | Browse, play, pause, complete, rate |
| Music | Browse, play, create playlist, download offline |
| AI Chat | Send message, receive response, crisis detection |
| Community | Create post, comment, like, report |
| Goals | Create, update progress, complete, fail |
| Offline | Create entries offline, sync when online |

## Firebase Emulator Tests

Run against Firebase Emulator Suite:
* Firestore emulator
* Auth emulator
* Storage emulator
* Functions emulator

Test:
* Security rules (allow/deny scenarios)
* Data validation rules
* Index performance
* Write limits

---

# QA PROCESS

## Pre-Release Checklist

```
□ All unit tests pass (100% coverage targets met)
□ All widget tests pass
□ All integration tests pass on iOS + Android
□ Golden tests match (no visual regression)
□ Firebase emulator tests pass
□ Performance benchmarks met (startup < 2s, 60fps)
□ Accessibility scan complete (no violations)
□ Crashlytics test crash verified
□ Analytics events firing correctly
□ Push notifications working
□ Offline mode functional (airplane mode test)
□ Sync engine working (create offline, go online, verify)
□ Localization verified (EN, HI, PA)
□ Dark/light mode verified
□ All screen sizes tested (phone, tablet)
□ Security rules verified (no unauthorized access)
□ App Check enabled and working
□ Memory profile clean (no leaks)
□ Network usage within budget
```

## Bug Tracking

All bugs tracked with:
* Severity: Critical / Major / Minor / Cosmetic
* Priority: P0 / P1 / P2 / P3
* Environment: Device, OS version, app version
* Steps to reproduce
* Expected vs actual behavior
* Screenshots / screen recording
* Logs attached

---

# ACCESSIBILITY

## Standards

Follow WCAG 2.1 AA standards minimum.

## Implementation

| Requirement | Implementation |
|-------------|---------------|
| Screen reader labels | All interactive elements have `Semantics` labels |
| Large fonts | Dynamic text sizing using `MediaQuery.textScaleFactor` |
| Color contrast | All text meets 4.5:1 contrast ratio (verify with contrast checker) |
| Touch targets | Minimum 48x48dp for all interactive elements |
| Keyboard navigation | All actions available without touch |
| Focus indicators | Visible focus ring on all interactive elements |
| Reduced motion | Respect `disableAnimations` platform setting |
| High contrast | Respect `highContrast` platform setting |
| Bold text | Respect `boldText` platform setting |

## Accessibility Testing

* Automated: `flutter analyze` with accessibility rules
* Automated: Integration tests with accessibility checks
* Manual: Screen reader (TalkBack / VoiceOver) walkthrough of every screen
* Manual: Large font size (200%) verification of every screen
* Manual: Color blindness simulation

## Accessibility Labels

Every icon button must have:
```
Semantics(
  label: "Close settings",
  hint: "Double tap to close the settings screen",
  child: IconButton(...)
)
```

Every image must have:
```
Semantics(
  label: "Profile photo of John",
  child: CircleAvatar(...)
)
```

---

# CI/CD PIPELINE

## GitHub Actions Workflow

```
name: mental-mantra-ci-cd

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  analyze:
    runs-on: ubuntu-latest
    steps:
      - checkout
      - setup flutter (latest stable)
      - flutter pub get
      - flutter analyze
      - dart format --set-exit-if-changed .

  test:
    runs-on: ubuntu-latest
    needs: analyze
    steps:
      - checkout
      - setup flutter
      - flutter pub get
      - flutter test --coverage
      - upload coverage report

  firebase-test:
    runs-on: ubuntu-latest
    needs: test
    steps:
      - checkout
      - setup firebase emulators
      - run integration tests against emulators

  build-android:
    runs-on: ubuntu-latest
    needs: firebase-test
    if: github.ref == 'refs/heads/main'
    steps:
      - checkout
      - setup flutter
      - setup Java 17
      - flutter build apk --release
      - flutter build appbundle --release
      - upload artifacts

  build-ios:
    runs-on: macos-latest
    needs: firebase-test
    if: github.ref == 'refs/heads/main'
    steps:
      - checkout
      - setup flutter
      - setup Xcode
      - flutter build ios --release --no-codesign
      - upload artifacts

  deploy-android:
    runs-on: ubuntu-latest
    needs: build-android
    if: github.ref == 'refs/heads/main'
    steps:
      - download artifacts
      - deploy to Firebase App Distribution (internal testing)
      - deploy to Google Play Console (beta track)

  deploy-ios:
    runs-on: macos-latest
    needs: build-ios
    if: github.ref == 'refs/heads/main'
    steps:
      - download artifacts
      - deploy to TestFlight (internal testing)
```

## Pre-Commit Hooks

Using `husky` or similar:

```
pre-commit:
  - dart format .
  - flutter analyze
  - flutter test --quick (only changed files)
  
pre-push:
  - flutter test --coverage
  - flutter analyze --fatal-infos
```

---

# DEPLOYMENT STRATEGY

## Environments

| Environment | Firebase Project | API Keys | Purpose |
|-------------|-----------------|----------|---------|
| Development | mental-mantra-dev | Dev keys | Active development |
| Staging | mental-mantra-staging | Staging keys | QA, internal testing |
| Production | mental-mantra-prod | Prod keys | App Store, Play Store |

## Release Process

```
Feature branch → PR → Develop branch
  ↓
Automated tests pass
  ↓
Merge to develop
  ↓
Staging build deployed to Firebase App Distribution
  ↓
QA verification on staging
  ↓
Release branch from develop
  ↓
  ├── Android: Upload to Play Console (internal → closed → open)
  └── iOS: Upload to App Store Connect (TestFlight → review → release)
      ↓
Production build monitored for 48h (Crashlytics, Analytics)
```

## Rollback Plan

* Android: Use Play Console's "rollback to previous version" for staged rollouts
* iOS: Use App Store Connect's "remove from sale" then redeploy previous version
* Feature flags: Disable problematic features via Remote Config (no app update needed)

---

# TESTING & QA QUALITY CHECKLIST

✓ Unit tests for all models (100% coverage)

✓ Unit tests for services (90% coverage)

✓ Unit tests for repositories (90% coverage)

✓ Unit tests for providers/BLoCs (90% coverage)

✓ Widget tests for all reusable components

✓ Golden tests for critical screens

✓ Integration tests for all feature flows

✓ Firebase emulator security rule tests

✓ CI pipeline with analyze + test + build

✓ Pre-commit hooks configured

✓ Accessibility (WCAG 2.1 AA)

✓ Screen reader labels on all elements

✓ Large font support

✓ Color contrast compliance

✓ Reduced motion support

✓ Multi-environment deployment

✓ Release process documented

✓ Rollback plan in place

✓ Crash reporting active

✓ Performance monitoring active

✓ Production ready

---

## END OF PART 11

---

# PART 12 — FINAL AUDIT, ACCEPTANCE CRITERIA, BUILD VERIFICATION & ZERO-ERROR CHECKLIST

---

# FINAL AUDIT PHILOSOPHY

This is the final gate before production release.

Every item on every checklist must be verified.

Nothing is assumed.

If it is not verified, it is not done.

---

# GLOBAL VERIFICATION

## Zero-Error Codebase

```
□ `flutter analyze` passes with zero errors and zero warnings
□ `dart format .` passes with zero formatting issues
□ `flutter test` passes with 100% of tests green
□ Zero deprecated API usage
□ Zero dynamic types (where avoidable)
□ Zero unchecked null access
□ Zero `print()` statements in production code
□ Zero TODO/FIXME/HACK comments
□ Zero commented-out code blocks
□ Zero unused imports
□ Zero unused variables
□ Zero unused parameters
□ Zero unused local methods
```

## Dependency Audit

```
□ All dependencies on latest stable versions
□ Zero deprecated packages
□ Zero known-vulnerability packages (verify with `flutter pub outdated` + manual audit)
□ Minimum dependency count (no unnecessary packages)
□ All licenses compatible with project
□ All transitive dependencies vetted
□ Pin versions in pubspec.lock for production builds
```

---

# ARCHITECTURE VERIFICATION

## Clean Architecture Enforcement

```
□ Presentation layer depends only on Business Logic layer
□ Business Logic layer depends only on Repository layer
□ Repository layer depends only on Data Sources
□ Data Sources implement interfaces from Repository layer
□ No direct UI-to-Firebase communication
□ No business logic in widgets
□ No data layer imports in UI files
□ All layers use dependency injection
```

## Repository Pattern Verification

```
□ Every Firestore collection has a corresponding Repository
□ Every repository implements an abstract interface
□ Repositories handle: read, write, cache, sync, error handling
□ Repositories return domain models (not Firestore maps)
□ Repositories never expose Firestore types to BLoC/Provider
□ Offline fallback in every repository read method
□ Sync queue write in every repository write method
```

---

# FEATURE VERIFICATION

## Authentication

```
□ Email signup with validation
□ Email login with error handling
□ Google Sign-In (Android + iOS)
□ Apple Sign-In (iOS)
□ Email verification flow
□ Forgot password flow
□ Session persistence (Remember Me)
□ Secure logout (clear tokens, revoke sessions)
□ Account deletion with data export option
□ Biometric login (optional)
□ Rate limiting on auth attempts
□ Input validation on all auth forms
```

## Onboarding

```
□ All 30 questions implemented across 8 screens
□ Consent checkbox with wellness acknowledgment
□ Progress indicator (Step X of 8)
□ Back navigation preserves previous answers
□ Hive auto-save per screen
□ Firestore sync on completion
□ AI wellness profile generated on completion
□ Initial goals created from onboarding responses
□ Initial recommendations generated
□ PHQ-2 scoring with appropriate response
□ Crisis resources displayed when indicated
□ Adaptive branching based on responses
□ All screens responsive
□ All screens accessible
```

## Dashboard

```
□ Time-aware greeting
□ Wellness score ring (animated)
□ 6 quick action buttons
□ Mood quick-check (5 emoji)
□ Recommendations carousel (AI-generated)
□ Goals progress section
□ Mood trend sparkline (7-day)
□ Quick insights from AI
□ Pull-to-refresh
□ Skeleton loading states
□ Offline indicator
□ Empty state for new users
□ Error handling per section
```

## Mood Tracker

```
□ 10 mood options with emoji + label
□ Intensity slider (1-10)
□ Multi-select contributing factors
□ Optional notes with character limit
□ Voice note option
□ AI reflection generated in background
□ Mood calendar view (color-coded dots)
□ Mood trends (weekly, monthly)
□ AI-generated insights (patterns, correlations)
□ Mood history with filters
```

## Journal

```
□ Text journal with rich text editor
□ Voice journal with waveform recording
□ Voice transcription via AI service
□ Image journal with filters and captions
□ Prompt-based journal entries
□ Journal list with date grouping
□ Entry type icons (text, voice, image, prompt)
□ Search and filter
□ Calendar view with entry indicators
□ AI sentiment analysis on save
□ AI topic and theme extraction
□ Weekly AI journal summary
□ Auto-save drafts every 30 seconds
□ Privacy toggle per entry
```

## AI Companion

```
□ Chat interface with typing indicator
□ Emoji and markdown support
□ Contextual conversation starters
□ Tone adaptation based on user state
□ AI memory (preferences, patterns, triggers)
□ Crisis keyword detection (3 levels)
□ Crisis resource display with direct dial
□ Safety event logging
□ Conversation history with pagination
□ Voice input for chat
□ Offline queuing of messages
```

## Recommendation Engine

```
□ Mood-based recommendations (primary source)
□ Time-based recommendations (morning, evening, etc.)
□ History-based recommendations (engagement patterns)
□ Goal-aligned recommendations
□ Diversity exploration (new content types)
□ Recommendation feedback loop (tap, complete, dismiss)
□ AI-generated reasons for each recommendation
□ Dashboard recommendations carousel
```

## Meditation

```
□ Meditation browser with categories
□ Guided and unguided meditation support
□ Meditation player with full controls
□ Background audio support
□ Lock screen controls (iOS/Android)
□ Sleep timer
□ Download for offline playback
□ Session rating after completion
□ Streak tracking
□ Unguided timer with interval bells
```

## Music Therapy

```
□ Music player with full controls
□ Categorized music library (nature, classical, binaural, ambient, etc.)
□ Download for offline playback
□ Download progress indicator
□ System playlists (by mood, activity)
□ User-created playlists
□ AI-generated playlists
```

## Yoga

```
□ Yoga session browser with difficulty levels
□ Video or illustrated guidance
□ Voice instructions
□ Pose-by-pose timer
□ Session logging
```

## Breathing Exercises

```
□ 8 breathing exercise patterns
□ Animated visual guide (expanding/contracting circle)
□ Color changes per phase
□ Haptic feedback on phase changes
□ Progress through cycles
```

## Spiritual Wellness

```
□ Optional, inclusive spiritual section
□ Content based on user preference (secular, inclusive, tradition-specific)
□ Gratitude, loving-kindness, forgiveness practices
□ Mantras and affirmations
□ Daily reflections
```

## Community

```
□ Feed with infinite scroll and pagination
□ Category filters and sort options
□ Post creation with anonymous toggle
□ Comment system with nested replies
□ Real-time like and comment updates
□ Post reporting
□ Support groups with chat
□ Group moderation tools
□ AI content moderation pipeline
□ Human moderation queue
```

## Goals

```
□ Goal CRUD with categories
□ Daily, weekly, monthly, custom goal types
□ Progress tracking with animated bars
□ Streak tracking per goal
□ Reminder scheduling per goal
□ Goal lifecycle (active, paused, completed, failed)
```

## Gamification

```
□ Points system across all activities
□ Daily max limits per activity type
□ Level system with titles (12+ levels)
□ Streak multiplier (1x-5x)
□ Achievement system (bronze, silver, gold, platinum)
□ Achievement unlocked celebration animation
□ Reward shop with point costs
□ User level display on profile
```

## Notifications

```
□ All reminder types (mood, journal, meditation, sleep, hydration)
□ Motivational notifications (streaks, achievements)
□ Informational notifications (daily quote, tips, weekly summary)
□ Community notifications (replies, likes, group messages)
□ Critical notifications (crisis, missed check-in, long inactivity)
□ Local notification scheduling
□ Push notification via FCM
□ Notification channels (Android)
□ Full notification settings screen
□ Quiet hours support
```

## Offline

```
□ All features functional without internet
□ Hive cache for all data types
□ Sync queue for offline writes
□ Automatic sync on connectivity restore
□ Sync status indicators (offline, syncing, error)
□ Conflict resolution (auto-merge + user choice)
□ Retry logic (5 attempts)
□ Offline-available content (downloaded meditation/music)
```

## Analytics

```
□ All events tracked (session, auth, mood, journal, meditation, music, yoga, community, goals, notifications)
□ Analytics stored in Firestore analytics_events collection
□ Local queue before sync (every 50 events or 5 minutes)
□ No journal content or mood notes in analytics
□ User ID hashed for privacy
```

---

# PERFORMANCE VERIFICATION

```
□ Cold start < 2 seconds on reference device (Pixel 6 / iPhone 13)
□ UI remains at 60fps during scrolling (zero dropped frames)
□ Memory usage < 150MB under normal operation
□ Memory usage < 200MB under heavy operation
□ No memory leaks (verified with DevTools memory profiler)
□ Image cache limited to 50MB
□ Network requests < 200ms average response time
□ List pagination loads in < 100ms
□ AI responses show first token in < 2 seconds
□ Animations GPU-accelerated (no jank)
```

---

# SECURITY VERIFICATION

```
□ No secrets in codebase (API keys, tokens, passwords)
□ google-services.json / GoogleService-Info.plist in .gitignore
□ Firebase App Check enabled (Play Integrity, App Attest, reCAPTCHA)
□ Firestore security rules deny all unauthorized access
□ Firestore rules validated with emulator tests
□ All user inputs sanitized
□ No sensitive data in logs
□ Auth tokens stored in flutter_secure_storage
□ Hive sensitive boxes encrypted (if applicable)
□ HTTPS enforced for all network calls
```

---

# ACCESSIBILITY VERIFICATION

```
□ All interactive elements have Semantics labels
□ Screen reader (TalkBack) walkthrough on Android — all screens functional
□ Screen reader (VoiceOver) walkthrough on iOS — all screens functional
□ Text scaling to 200% — no layout breakage
□ Color contrast ratio >= 4.5:1 on all text
□ All touch targets >= 48x48dp
□ Reduced motion respected (disableAnimations)
□ High contrast mode respected
□ Bold text setting respected
□ No accessibility violations in automated scan
```

---

# LOCALIZATION VERIFICATION

```
□ English (en) — all strings localized
□ Hindi (hi) — all strings localized
□ Punjabi (pa) — all strings localized
□ RTL layout support verified (for future RTL languages)
□ Date/time formats locale-aware
□ Number formats locale-aware
□ Localization architecture supports adding new languages without code changes
```

---

# BUILD VERIFICATION

## Android Build

```
□ `flutter build apk --release` succeeds
□ `flutter build appbundle --release` succeeds
□ APK size < 40MB (with split APK)
│   ├── arm64-v8a: < 25MB
│   ├── armeabi-v7a: < 20MB
│   └── x86_64: < 30MB
□ ProGuard/R8 minification enabled
□ Android App Bundle using Play Feature Delivery
□ App signing configured in Play Console
□ All manifest permissions justified in comment
```

## iOS Build

```
□ `flutter build ios --release` succeeds
□ `flutter build ipa` succeeds
□ Archive succeeds in Xcode
□ App size < 150MB (App Store limit)
□ Bitcode disabled (deprecated)
□ All required plist entries present
□ Push notifications capability enabled
□ Sign-in with Apple capability enabled
□ All Info.plist usage descriptions present (camera, mic, photos, etc.)
```

---

# ACCEPTANCE CRITERIA

## Functional Acceptance

```
ALL features listed in Parts 1-11 are implemented and verified.

All user flows complete successfully:

1. First Launch → Onboarding → Dashboard (happy path)
2. Signup → Email Verification → Onboarding → Dashboard
3. Login → Dashboard → Mood Entry → Journal → Meditation → Music → Yoga
4. AI Chat → Crisis Detection → Resource Display
5. Community → Post → Comment → Like → Report
6. Goals → Create → Track → Complete → Achievement
7. Offline entry → Online sync → Data verified on Firestore
8. Push Notification → Tap → Deep link to correct screen
9. Settings → Privacy → Security → Delete Account
10. Light mode → Dark mode → System default
```

## Performance Acceptance

```
All performance thresholds met (see Performance Verification above).
```

## Platform Acceptance

```
□ Android 8.0+ (API 26+) — all features functional
□ iOS 15.0+ — all features functional
□ Tablet layout — adaptive layout renders correctly
□ Dark mode — all screens verified
□ Light mode — all screens verified
```

---

# PRE-LAUNCH CHECKLIST

## 24 Hours Before Launch

```
□ Final `flutter analyze` — zero issues
□ Final `flutter test` — 100% green
□ Final build (APK + App Bundle + IPA)
□ Build uploaded to Play Console + App Store Connect
□ Crashlytics confirmed receiving test crashes
□ Analytics confirmed receiving test events
□ Remote Config values set for production
□ Feature flags verified (all enabled)
□ Emergency contacts / crisis resources verified for all supported countries
□ App Store / Play Store listing updated
□ Privacy policy link updated
□ Terms of service link updated
□ Support email configured
```

## Launch

```
□ Release to Play Console (staged rollout: 1% → 10% → 50% → 100%)
□ Release to App Store (manual review, release after approval)
□ Monitor Crashlytics for first hour
□ Monitor Analytics for user engagement
□ Monitor server costs
□ Support team briefed and ready
```

## Post-Launch (48 Hours)

```
□ Review crash reports
□ Review user feedback
□ Address P0/P1 issues immediately
□ Monitor performance metrics
□ Monitor sync queue success rate
□ Review AI interaction quality
```

---

# MASTER BUILD PROMPT — COMPLETE

---

## Mental Mantra — 100/100 Production Master Prompt

| Version | 1.0 |
|---------|-----|
| Status | Production Ready |
| Parts | 12 |
| Sections | Architecture, Backend, Firebase, Auth, Firestore, Onboarding, Dashboard, AI, Journal, Meditation, Community, Goals, Notifications, Offline, Testing, Deployment |
| Last Updated | June 2026 |

---

**This master prompt defines every aspect of the Mental Mantra application.**

Any developer or AI can use this document as the single source of truth to build the complete application.

Every decision is documented.

Every feature is specified.

Every quality gate is defined.

Build with confidence.

---

## END OF PART 12

---

# MASTER BUILD PROMPT — END OF DOCUMENT
