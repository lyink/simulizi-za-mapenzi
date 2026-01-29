# Security Setup Guide

This guide will help you set up the sensitive files that are not included in the repository for security reasons.

## Required Files (NOT in Repository)

The following files are required to run the app but are excluded from git for security:

### 1. Firebase Configuration

#### Android: `android/app/google-services.json`
- Download from Firebase Console → Project Settings → Your Android App
- Place in: `android/app/google-services.json`

#### iOS: `ios/Runner/GoogleService-Info.plist`
- Download from Firebase Console → Project Settings → Your iOS App
- Place in: `ios/Runner/GoogleService-Info.plist`

#### Flutter: `lib/firebase_options.dart`
- Generate using FlutterFire CLI:
  ```bash
  flutter pub global activate flutterfire_cli
  flutterfire configure
  ```
- This will create `lib/firebase_options.dart` automatically

### 2. Firestore Configuration

Create these files in the project root:

#### `firebase.json`
```json
{
  "firestore": {
    "rules": "firestore.rules",
    "indexes": "firestore.indexes.json"
  }
}
```

#### `firestore.rules`
See [FIREBASE_SETUP_COMPLETE.md](FIREBASE_SETUP_COMPLETE.md) for the complete security rules.

#### `firestore.indexes.json`
```json
{
  "indexes": [],
  "fieldOverrides": []
}
```

### 3. Android Signing Keys

#### For Debug Builds
Debug builds use auto-generated debug keystore.

#### For Release Builds: `key.jks` or `upload-keystore.jks`

Create a keystore:
```bash
keytool -genkey -v -keystore key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias key
```

Then update `android/key.properties`:
```properties
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=key
storeFile=../key.jks
```

**NEVER commit these files to git!**

## Setup Checklist

- [ ] Download `google-services.json` from Firebase Console
- [ ] Place `google-services.json` in `android/app/`
- [ ] Run `flutterfire configure` to generate `firebase_options.dart`
- [ ] Create `firebase.json`, `firestore.rules`, and `firestore.indexes.json`
- [ ] Deploy Firestore rules: `firebase deploy --only firestore:rules`
- [ ] (Optional) Create signing key for release builds

## Security Notes

1. **Never commit these files to version control**
2. **Never share your keystores or Firebase config files publicly**
3. **Keep your Firebase API keys secure** (they're already restricted by Firebase security rules)
4. **Use environment variables or secure vaults in CI/CD pipelines**

## What's Safe to Share

- Source code (already in repository)
- Documentation files
- Asset files (logos, images, etc.)
- Firestore structure documentation

## Getting Help

If you need help setting up these files, refer to:
- [Firebase Setup Guide](FIREBASE_SETUP_COMPLETE.md)
- [Official Firebase Documentation](https://firebase.google.com/docs)
- [Flutter Firebase Setup](https://firebase.flutter.dev/docs/overview)
