# Simulizi za Mapenzi (Kamusi ya Kiswahili)

A comprehensive Swahili stories and Bible application built with Flutter. The app features love stories, Bible verses, categories, and an integrated dictionary with over 16,000 words.

## Features

### Stories & Reading
- **Story Categories**: Browse stories by category
- **Chapter Navigation**: Read stories chapter by chapter
- **Offline Reading**: Stories cached for offline access
- **Story Sync**: Background synchronization of new stories

### Bible Features
- **Bible Books**: Browse all books of the Bible
- **Chapter Reading**: Read Bible chapters with verse-by-verse display
- **Verse Details**: View individual verses with sharing capabilities
- **Offline Access**: Bible content cached for offline reading

### Notifications
- **Daily Notifications**: Customizable daily reminders
- **Smart Scheduling**: Morning, afternoon, and evening notification options
- **Story Updates**: Get notified when new stories are added

### Admin Panel
- **Category Management**: Add, edit, and delete story categories
- **Story Management**: Upload and manage stories with chapters
- **Image Upload**: Support for category and story images
- **Content Control**: Full administrative control over app content

### Additional Features
- **Light/Dark Theme**: Automatic theme switching based on system preferences
- **AdMob Integration**: Monetization with banner and interstitial ads
- **Material Design 3**: Modern UI with beautiful animations
- **Responsive Design**: Works on phones and tablets

## Getting Started

### Prerequisites
- Flutter SDK (3.9.0 or higher)
- Firebase account with Firestore enabled
- Android Studio / VS Code
- Android emulator or physical device

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/lyink/simulizi-za-mapenzi.git
   cd kamusi
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. **Set up Firebase** (Required):

   ⚠️ **Important**: Firebase configuration files are not included in the repository for security reasons.

   - Create a Firebase project in [Firebase Console](https://console.firebase.google.com/)
   - Download `google-services.json` and place it in `android/app/`
   - Run FlutterFire CLI to generate configuration:
     ```bash
     flutter pub global activate flutterfire_cli
     flutterfire configure
     ```
   - Copy example files and configure:
     ```bash
     cp firebase.json.example firebase.json
     cp firestore.rules.example firestore.rules
     cp firestore.indexes.json.example firestore.indexes.json
     ```
   - Deploy Firestore rules:
     ```bash
     firebase deploy --only firestore:rules
     ```

   📖 See [SECURITY_SETUP.md](SECURITY_SETUP.md) for detailed instructions.

4. Configure AdMob (optional):
   - Update Ad IDs in [lib/services/ad_service.dart](lib/services/ad_service.dart)

5. Run the app:
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── models/                    # Data models
│   ├── story.dart
│   ├── category.dart
│   ├── chapter.dart
│   └── bible_verse.dart
├── screens/                   # UI screens
│   ├── admin/                # Admin panel screens
│   ├── bible_screen.dart
│   ├── books_screen.dart
│   ├── chapters_screen.dart
│   ├── story_reading_screen.dart
│   └── verse_detail_screen.dart
├── services/                  # Business logic
│   ├── story_service.dart
│   ├── bible_service.dart
│   ├── category_service.dart
│   ├── cache_service.dart
│   ├── notification_service.dart
│   └── ad_service.dart
├── providers/                 # State management
├── theme/                     # Theme configuration
├── widgets/                   # Reusable widgets
└── main.dart                  # App entry point
```

## Documentation

- [Security Setup Guide](SECURITY_SETUP.md) ⚠️ **Start Here**
- [Quick Start Guide](QUICK_START.md)
- [Firebase Setup](FIREBASE_SETUP_COMPLETE.md)
- [Firestore Structure](FIRESTORE_STRUCTURE.md)
- [Admin Panel Guide](ADMIN_PANEL_COMPLETE.md)
- [Notification Setup](NOTIFICATION_QUICK_START.md)
- [Caching System](CACHING_SYSTEM_SUMMARY.md)

## Technical Details

- **Framework**: Flutter 3.9.0+
- **Language**: Dart
- **Backend**: Firebase Firestore
- **Local Storage**: SharedPreferences for caching
- **Notifications**: flutter_local_notifications
- **Ads**: google_mobile_ads (AdMob)
- **State Management**: Provider pattern
- **Architecture**: Service-based architecture with clean separation of concerns
