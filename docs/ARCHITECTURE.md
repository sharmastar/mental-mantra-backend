# Mental Mantra Architecture Guide

## System Overview

Mental Mantra follows **Clean Architecture** principles structured by feature layers to ensure modularity, scalability, and testability.

```
lib/
├── core/                   # Shared cross-cutting concerns
│   ├── config/             # App configuration & environment variables
│   ├── errors/             # Custom exception hierarchy
│   ├── network/            # Dio API client, interceptors, network status
│   ├── personalization/    # Dynamic user context & recommendation engine
│   ├── storage/            # Secure storage & local key-value persistence
│   ├── theme/              # Color schemes, typography, design system tokens
│   └── widgets/            # Reusable UI components (logo, empty state, loaders)
├── features/               # Feature modules (Domain-Driven Structure)
│   ├── ai/                 # AI Insights, Chat, and Coach state management
│   ├── analytics/          # Mental wellness trends and visual reporting
│   ├── auth/               # Firebase & Google authentication flows
│   ├── dashboard/          # Home dashboard & daily planner engines
│   ├── habits/             # Habit creation and completion tracking
│   ├── journal/            # Journal entries and NLP intelligence analysis
│   ├── meditation/         # Audio playback, breathing timers, sessions
│   └── mood/               # Daily mood check-in & emotional tracking
└── services/               # Core business calculation engines
    ├── ai/                 # AI Coach & Safety Detector engine
    └── wellness/           # Score engine & briefing calculation engine
```

## Data Flow Architecture

1. **Presentation Layer**: UI Screens request state via Riverpod providers (`ref.watch` / `ref.read`).
2. **Domain & Service Layer**: Business logic and intelligence engines (`ScoreEngine`, `SafetyDetector`, `JournalIntelligenceEngine`) process raw inputs.
3. **Data Layer**: Repositories fetch data from local Hive boxes or remote REST API / Firestore endpoints.
