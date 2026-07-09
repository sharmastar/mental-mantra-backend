# Mental Mantra Deployment Guide

## Mobile App Deployment (Android & iOS)

### Android Release Build

Run the automated release build script:
```powershell
.\build_release.ps1
```
Or build manually via Flutter CLI:
```bash
flutter build apk --release --obfuscate --split-debug-info=build/debug-info --dart-define-from-file=.env.client
```

### iOS Release Build

1. Open `ios/Runner.xcworkspace` in Xcode.
2. Ensure signing certs and provisioning profiles are configured.
3. Archive and publish to App Store Connect:
```bash
flutter build ipa --release
```

---

## Backend Deployment (Firebase App Hosting)

Deploy the Node.js backend services to Firebase App Hosting:
```bash
firebase deploy
```
