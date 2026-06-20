# Recovery Management App — Complete Setup Guide
## Play Store + App Store Deployment

---

## WHAT YOU HAVE

A complete Flutter + Firebase app with:
- Manager Dashboard with achievement ring, AI recommendations
- Excel/CSV upload (9 fields: Name, Father Name, Customer ID, Account No, Village, Sanctioned Amount, Outstanding, ROI, Penal Rate)
- Yearly target setting
- Analytics: Village-wise, Agent-wise, Status breakdown
- Recovery Agent app with GPS + photo visit logging
- NPA/PTP/Active account management
- AdMob banner ads for income

---

## STEP 1 — Install Required Software (One Time)

### A. Flutter SDK
1. Go to https://flutter.dev/docs/get-started/install/windows
2. Download Flutter SDK → Extract to `C:\flutter`
3. Add `C:\flutter\bin` to your Windows PATH
4. Open Command Prompt → run: `flutter doctor`
5. Fix any issues shown in red

### B. Android Studio
1. Download from https://developer.android.com/studio
2. Install with default settings
3. Open Android Studio → SDK Manager → Install Android SDK 34
4. Accept all licenses: run `flutter doctor --android-licenses`

### C. VS Code (Recommended Editor)
1. Download from https://code.visualstudio.com
2. Install extensions: Flutter, Dart

---

## STEP 2 — Set Up Firebase Project

### A. Create Firebase Project
1. Go to https://console.firebase.google.com
2. Click "Add Project" → Name it: `recovery-management-app`
3. Disable Google Analytics (optional) → Create project

### B. Enable Firebase Services
In Firebase Console, enable:
- **Authentication** → Email/Password (Sign-in method)
- **Firestore Database** → Create database → Production mode
- **Storage** → Get started

### C. Add Android App to Firebase
1. Click Android icon in Firebase console
2. Package name: `com.recoverymanagement.app`
3. App nickname: Recovery Management
4. Download `google-services.json`
5. Place it in: `android/app/google-services.json`

### D. Add iOS App to Firebase
1. Click iOS icon in Firebase console
2. Bundle ID: `com.recoverymanagement.app`
3. Download `GoogleService-Info.plist`
4. Place it in: `ios/Runner/GoogleService-Info.plist`

### E. Auto-configure firebase_options.dart
```
dart pub global activate flutterfire_cli
flutterfire configure --project=recovery-management-app
```
This replaces the placeholder `lib/firebase_options.dart` automatically.

---

## STEP 3 — Set Up Firestore Security Rules

In Firebase Console → Firestore → Rules, paste:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      allow read: if request.auth != null;
    }
    match /customers/{doc} {
      allow read, write: if request.auth != null;
    }
    match /visits/{doc} {
      allow read, write: if request.auth != null;
    }
    match /collections/{doc} {
      allow read, write: if request.auth != null;
    }
  }
}
```

---

## STEP 4 — Create First Manager Account

In Firebase Console → Authentication → Users → Add user:
- Email: your manager email
- Password: strong password

Then in Firestore → users → Add document (use the UID as document ID):
```json
{
  "name": "Your Name",
  "email": "your@email.com",
  "mobile": "9XXXXXXXXX",
  "role": "manager",
  "employeeId": "MGR-001",
  "zone": "Delhi",
  "managerId": "",
  "isActive": true,
  "createdAt": (server timestamp)
}
```

---

## STEP 5 — Set Up AdMob for Income

### A. Create AdMob Account
1. Go to https://admob.google.com
2. Sign in with Google account
3. Add app → Android → App name: Recovery Management
4. Copy your **App ID** (ca-app-pub-XXXXXXXX~YYYYYYY)

### B. Replace Ad IDs
In `android/app/src/main/AndroidManifest.xml`:
```xml
<meta-data android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="YOUR_REAL_ADMOB_APP_ID"/>
```

In `ios/Runner/Info.plist`:
```xml
<key>GADApplicationIdentifier</key>
<string>YOUR_REAL_ADMOB_APP_ID</string>
```

In `lib/services/ad_service.dart`:
- Replace the production Ad Unit ID with your real banner ad unit ID

### INCOME ESTIMATE
- 1,000 daily active users → ₹500–2,000/month from ads
- For banking/NBFC target audience eCPM is typically higher (₹50–150)
- Sell the app as SaaS to banks: ₹2,000–5,000/month per bank

---

## STEP 6 — Build the App

### Open project in VS Code / terminal:
```bash
cd D:\recovery_management
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### Test the app:
```bash
flutter run
```

---

## STEP 7 — Build Release APK (Android)

### A. Create Keystore (One Time Only)
```bash
keytool -genkey -v -keystore D:\recovery_management\android\app\release.keystore -alias recovery -keyalg RSA -keysize 2048 -validity 10000
```
Save the password safely — you need it forever.

### B. Add Signing Config
In `android/app/build.gradle`, replace `signingConfig signingConfigs.debug` with:
```groovy
signingConfigs {
    release {
        storeFile file('release.keystore')
        storePassword 'YOUR_PASSWORD'
        keyAlias 'recovery'
        keyPassword 'YOUR_PASSWORD'
    }
}
buildTypes {
    release { signingConfig signingConfigs.release }
}
```

### C. Build Release APK
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk

# Or build App Bundle (recommended for Play Store):
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

---

## STEP 8 — Build iOS IPA (iPhone)

**Requires a Mac computer and Apple Developer account ($99/year)**

```bash
flutter build ios --release
```

Then open Xcode → Product → Archive → Distribute App → App Store Connect

---

## STEP 9 — Publish to Google Play Store

### A. Create Developer Account
1. Go to https://play.google.com/console
2. Pay one-time $25 fee
3. Complete developer profile

### B. Create App Listing
1. Create app → App name: Recovery Management
2. Category: Business
3. Content rating: Everyone
4. Fill store listing:
   - Short description: "Smart loan recovery management for banks and NBFCs"
   - Full description: (describe features)
   - Screenshots: Take from your phone
   - App icon: 512x512 PNG

### C. Upload AAB
1. Production → Create new release
2. Upload `app-release.aab`
3. Release notes → Submit for review

**Review time: 3–7 days**

---

## STEP 10 — Publish to Apple App Store

### A. Apple Developer Account
1. Go to https://developer.apple.com
2. Enroll for $99/year
3. Create App ID: com.recoverymanagement.app

### B. App Store Connect
1. Go to https://appstoreconnect.apple.com
2. My Apps → New App → Fill details
3. Upload IPA via Xcode or Transporter
4. Submit for review

**Review time: 1–3 days**

---

## FILE STRUCTURE

```
recovery_management/
├── lib/
│   ├── main.dart                    ← App entry point
│   ├── firebase_options.dart        ← Configure with your Firebase
│   ├── models/
│   │   ├── customer_model.dart      ← All 9 Excel fields
│   │   ├── visit_model.dart         ← GPS + photo visit log
│   │   └── user_model.dart          ← Manager / Agent roles
│   ├── providers/
│   │   ├── auth_provider.dart       ← Login / logout
│   │   ├── customer_provider.dart   ← Customer data + analytics
│   │   └── target_provider.dart     ← Yearly target tracking
│   ├── services/
│   │   ├── excel_service.dart       ← Parse Excel/CSV uploads
│   │   └── ad_service.dart          ← AdMob banner ads
│   ├── screens/
│   │   ├── auth/                    ← Splash + Login
│   │   ├── manager/                 ← Dashboard, Customers, Analytics, Reports, Upload
│   │   └── agent/                   ← Dashboard, Customers, Visit Log
│   ├── widgets/                     ← Reusable UI components
│   └── utils/                       ← Theme, colors
├── android/                         ← Android build config
├── ios/                             ← iOS build config
├── assets/
│   └── sample/sample_customers.csv ← Sample Excel template
└── pubspec.yaml                     ← All dependencies
```

---

## QUICK CHECKLIST BEFORE GOING LIVE

- [ ] Firebase project created
- [ ] google-services.json placed in android/app/
- [ ] GoogleService-Info.plist placed in ios/Runner/
- [ ] firebase_options.dart configured (run flutterfire configure)
- [ ] Firestore rules set
- [ ] First manager account created in Firebase Auth + Firestore
- [ ] AdMob app ID replaced in AndroidManifest.xml and Info.plist
- [ ] Keystore created and signing config added
- [ ] flutter pub get run successfully
- [ ] App tested on real device
- [ ] Screenshots taken for store listing
- [ ] Play Store developer account created ($25)
- [ ] App Store developer account created ($99/year, Mac required)

---

## MONETIZATION STRATEGY

1. **AdMob Ads** — Banner on dashboard (₹500–3,000/month per 1K users)
2. **SaaS Pricing** — Sell to banks: ₹2,000–5,000/month per organization
3. **Per-Agent Pricing** — ₹200–500/agent/month
4. **Premium Features** — OTS settlement module, bulk SMS, WhatsApp integration

---

## SUPPORT

For any build errors, share the exact error message and we can fix it step by step.

