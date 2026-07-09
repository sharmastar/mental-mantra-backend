# Week 1 Sprint Plan: Firebase Phase 1 Setup

This document outlines the day-by-day detailed tasks to execute Phase 1 of the Firebase integration for Mental Mantra.

---

## 📅 Daily Task Breakdown

### 🔴 Monday: Firebase Console & Registration
**Goal:** Create the Firebase cloud resources and register the mobile applications.

1. **Create Firebase Project:**
   - Go to [Firebase Console](https://console.firebase.google.com).
   - Create a project named `mental-mantra-2024` (or select your existing project if one is pre-created).
2. **Register Android Application:**
   - Add a new Android application to the project.
   - Use package name: `com.mentalmantra.mental_mantra` (as defined in your `android/app/build.gradle.kts` namespace).
3. **Register iOS Application:**
   - Add an iOS application.
   - Use bundle ID: `com.mentalmantra.mentalMantra` (as configured in your Xcode workspace).
4. **Download configuration files:**
   - Download `google-services.json` and save it to `android/app/`.
   - Download `GoogleService-Info.plist` (if applicable) and keep it for iOS setup.
5. **Enable Firebase Products in Console:**
   - **Authentication:** Enable Email/Password, Google, and Apple providers.
   - **Firestore Database:** Enable Database in production mode.
   - **Analytics & Crashlytics:** Enable monitoring.

---

### 🟠 Tuesday: SHA-1 Fingerprints & Gradle Plugins
**Goal:** Configure local Android project parameters to authenticate with Firebase services.

1. **Retrieve SHA-1 and SHA-256 Fingerprints:**
   - Run the following keytool command to extract the debug keystore fingerprints:
     ```powershell
     keytool -list -v -alias androiddebugkey -keystore C:\Users\kuldeep\.android\debug.keystore -storepass android
     ```
2. **Add Fingerprints to Firebase App:**
   - Go to Project Settings in the Firebase Console.
   - Scroll down to your Android app configuration.
   - Click "Add fingerprint" and paste your SHA-1 and SHA-256 hashes.
3. **Configure Android Build Files:**
   - Re-enable the Google Services plugin in `android/settings.gradle.kts`:
     ```kotlin
     plugins {
         id("com.google.gms.google-services") version("4.4.4") apply false
     }
     ```
   - Re-enable the Google Services plugin in `android/app/build.gradle.kts`:
     ```kotlin
     plugins {
         id("com.google.gms.google-services")
     }
     ```

---

### 🟡 Wednesday: Reverting pubspec.yaml & CLI Configuration
**Goal:** Reconnect the application codebase to the live Firebase SDK dependencies.

1. **Restore Package Definitions in pubspec.yaml:**
   - Open `pubspec.yaml` and update the dependency overrides back to remote pub versions:
     ```yaml
     dependencies:
       firebase_core: ^4.10.0
       cloud_firestore: ^6.5.0
       firebase_auth: ^6.5.2
       firebase_analytics: ^12.4.2
       firebase_crashlytics: ^5.2.3
       firebase_storage: ^13.4.2
       cloud_functions: ^6.3.2
     ```
2. **Fetch Dependencies:**
   - Run `flutter pub get` to download and link the official plugins.
3. **Run FlutterFire CLI (Optional/Alternative):**
   - Alternatively, you can use the official `flutterfire configure` command in the root folder to update options and configure build gradle parameters automatically.

---

### 🟢 Thursday: Firebase Initialization & Error Cleanup
**Goal:** Connect the app startup logic to Firebase.

1. **Re-add Options in main.dart:**
   - Restore the Firebase Options import and configure options during initialization in [lib/main.dart](file:///c:/Users/kuldeep/OneDrive/Desktop/mental%20mantra/lib/main.dart):
     ```dart
     import 'firebase_options.dart';
     
     void main() async {
       WidgetsFlutterBinding.ensureInitialized();
       await Firebase.initializeApp(
         options: DefaultFirebaseOptions.currentPlatform,
       );
       ...
     }
     ```
2. **Verify Compilation:**
   - Run `flutter analyze` to ensure all references, types, and dependencies build without warnings.

---

### 🔵 Friday: Testing & Validation
**Goal:** Verify integration and build release binaries.

1. **Test Offline Fallback:**
   - Verify the app still launches and runs locally if internet is disabled.
2. **Check Firebase Connection:**
   - Inspect console logs during startup to ensure Firestore database client registers with the cloud servers.
3. **Build Final Binary:**
   - Compile a fresh release APK to test on physical devices:
     ```powershell
     flutter build apk --release --obfuscate --split-debug-info build/debug-info
     ```
