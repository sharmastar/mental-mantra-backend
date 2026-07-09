# Firebase Week 1 Setup Command Cheat Sheet

Use these copy-paste commands to configure, build, and troubleshoot Phase 1 of the Firebase integration for Mental Mantra.

---

## 🔑 1. Keystore & SHA-1/SHA-256 Fingerprints

Retrieve the SHA-1 and SHA-256 signatures of your local debug keystore:

### Windows (PowerShell)
```powershell
keytool -list -v -alias androiddebugkey -keystore C:\Users\kuldeep\.android\debug.keystore -storepass android
```

### macOS / Linux (Terminal)
```bash
keytool -list -v -alias androiddebugkey -keystore ~/.android/debug.keystore -storepass android
```

---

## 🛠️ 2. Package Dependency Management

Get the latest compatible Firebase plugin dependencies:

```bash
# Clean project build caches
flutter clean

# Fetch and link packages listed in pubspec.yaml
flutter pub get

# Check for outdated packages or conflicts
flutter pub outdated
```

---

## 🚀 3. FlutterFire CLI Configurator

Ensure the global FlutterFire CLI tool is configured on your system path to automatically create your options file:

```bash
# Install the FlutterFire CLI globally
dart pub global activate flutterfire_cli

# Configure the project dependencies and options (regenerates firebase_options.dart)
flutterfire configure --project=mental-mantra-2024
```

---

## 🧪 4. Static Code Verification

Run static code analysis to verify there are no compilation warnings, deprecated elements, or type mismatches:

```bash
flutter analyze
```

---

## 📦 5. Compilation & Build Release

Compile an optimized, obfuscated single release APK file containing all system targets:

```powershell
# Rebuild the final single APK
flutter build apk --release --obfuscate --split-debug-info build/debug-info

# Copy compiled APK to local Downloads folder
Copy-Item -Path "build\app\outputs\flutter-apk\app-release.apk" -Destination "C:\Users\kuldeep\Downloads" -Force
```
