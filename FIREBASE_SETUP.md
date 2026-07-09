# Firebase Setup Guide — Mental Mantra

This guide walks you through creating a real Firebase project, connecting your Android app, and configuring Google Sign-In end-to-end.

---

## 1. Create a Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click **Create a project** (or select an existing one)
3. Enter a project name (e.g. `Mental Mantra`)
4. Disable **Google Analytics** (optional)
5. Wait for provisioning (~30s), then click **Continue**

---

## 2. Register Your Android App

1. In Firebase Console, click the **Android** icon to add an Android app
2. **Android package name:** `com.mentalmantra.mental_mantra`
3. **App nickname:** `Mental Mantra`
4. **Debug signing certificate SHA-1:** leave blank for now
5. Click **Register app**
6. Click **Download google-services.json**
7. **Replace** the placeholder file at `android/app/google-services.json`
8. Click **Next** (skip SDK setup), then **Continue to console**

---

## 3. Enable Google Sign-In

1. Firebase Console → **Authentication** → **Sign-in method**
2. Click **Google**, toggle **Enable**, select support email, **Save**

---

## 4. Get the Web Client ID

1. Firebase Console → **Project settings** → **General** → **Your apps**
2. Find the **Web client ID** (auto-created by Firebase):
   ```
   123456789012-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx.apps.googleusercontent.com
   ```
3. Copy it and update both:

   **`.env` (root):**
   ```
   GOOGLE_CLIENT_ID=123456789012-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx.apps.googleusercontent.com
   ```

   **`backend/.env`:**
   ```
   GOOGLE_CLIENT_ID=123456789012-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx.apps.googleusercontent.com
   ```

---

## 5. Generate SHA Fingerprints

Prerequisite: Install **JDK 11+** from [Adoptium](https://adoptium.net).

```powershell
keytool -list -v -alias androiddebugkey `
  -keystore "$env:USERPROFILE\.android\debug.keystore" `
  -storepass android -keypass android
```

Copy the **SHA1** and **SHA256** lines.

---

## 6. Add SHA Fingerprints to Firebase Console

1. Firebase Console → **Project settings** → **Your apps** → Android app
2. Click **Add fingerprint**, paste SHA-1, **Save**
3. Click **Add fingerprint**, paste SHA-256, **Save**

---

## 7. Validate Setup

```powershell
.\setup_firebase.ps1
```

---

## 8. Build & Test

```powershell
flutter clean
flutter pub get
flutter build apk --release
```

---

## Troubleshooting

| Error | Likely Cause | Fix |
|-------|-------------|------|
| `28444` | SHA fingerprint missing/wrong | Steps 5–6 |
| `12500` | Wrong Web Client ID | Step 4 |
| `10` / `DEVELOPER_ERROR` | Placeholder google-services.json | Step 2 |
| `7` / `INTERNAL_ERROR` | Google Sign-In not enabled | Step 3 |

---

## Reference Links

- [Firebase Console](https://console.firebase.google.com)
- [Add Firebase to Android](https://firebase.google.com/docs/android/setup)
- [Google Sign-In for Android](https://firebase.google.com/docs/auth/android/google-signin)
- [Generating SHA fingerprints](https://developers.google.com/android/guides/client-auth)
- [Download JDK (Temurin)](https://adoptium.net)
