# Mental Mantra Setup Guide

## Prerequisites

- Flutter SDK >= 3.3.0
- Dart SDK >= 3.3.0
- Node.js v18+ (for backend services)
- Android Studio / Xcode for emulators and devices

---

## Installation Steps

### 1. Repository Setup
```bash
git clone <repository-url>
cd mental-mantra
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Environment Configuration
Copy `.env.client.example` to `.env.client` and set your local variables:
```ini
API_BASE_URL=http://localhost:3000/api
GOOGLE_CLIENT_ID=your-client-id.apps.googleusercontent.com
```

### 4. Run the Application
```bash
flutter run
```
