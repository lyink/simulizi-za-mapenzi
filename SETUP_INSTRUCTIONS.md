# Setup Instructions for Simulizi za Mapenzi

## What Has Been Done ✅

1. **App Configuration**
   - ✅ Changed app name to "Simulizi za Mapenzi"
   - ✅ Updated pubspec.yaml with Firebase dependencies
   - ✅ Added Google Services plugin to Android build files
   - ✅ Created Swahili UI translations in main.dart

2. **Firebase Structure**
   - ✅ Created Story model ([lib/models/story.dart](lib/models/story.dart))
   - ✅ Created StoryService for Firestore operations ([lib/services/story_service.dart](lib/services/story_service.dart))
   - ✅ Created StoryProvider for state management ([lib/providers/story_provider.dart](lib/providers/story_provider.dart))
   - ✅ Created sample stories data ([lib/utils/sample_stories_data.dart](lib/utils/sample_stories_data.dart))
   - ✅ Created upload script ([lib/utils/upload_sample_stories.dart](lib/utils/upload_sample_stories.dart))
   - ✅ Created Firestore documentation ([FIRESTORE_STRUCTURE.md](FIRESTORE_STRUCTURE.md))

## What You Need to Do

### Step 1: Configure Firebase (REQUIRED)

Run this command in your terminal:

```bash
flutterfire configure --project=bible-53642
```

**Select these platforms when prompted:**
- ✓ android
- ✓ ios (if needed)
- ✓ web (if needed)

**This will:**
- Generate `lib/firebase_options.dart`
- Download `android/app/google-services.json`
- Register your app in Firebase Console

### Step 2: Enable Firebase Initialization

After running the flutterfire command, uncomment these lines in [lib/main.dart](lib/main.dart#L11-L19):

```dart
import 'firebase_options.dart';

await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

### Step 3: Set Up Firestore Database

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select project: **bible-53642**
3. Click **Firestore Database** → **Create database**
4. Choose **Start in test mode** (we'll add security rules later)
5. Select your region (closest to Tanzania)

### Step 4: Add Security Rules

In Firebase Console, go to Firestore Database → Rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /stories/{storyId} {
      // Anyone can read stories
      allow read: if true;

      // Only authenticated admins can create/delete
      allow create, delete: if request.auth != null &&
        request.auth.token.admin == true;

      // Anyone can update views and likes
      allow update: if request.resource.data.diff(resource.data)
        .affectedKeys().hasOnly(['views', 'likes']);
    }
  }
}
```

Click **Publish** to save the rules.

### Step 5: Upload Sample Stories

You have 5 sample stories ready to upload. Here are two methods:

#### Method A: Using the Upload Script (Recommended)

1. Install dependencies:
```bash
flutter pub get
```

2. Create a temporary button in your app to trigger the upload:

```dart
// Add this to your main screen temporarily
import 'utils/upload_sample_stories.dart';

ElevatedButton(
  onPressed: () async {
    final uploader = StoryUploader();
    await uploader.uploadSampleStories();
  },
  child: Text('Upload Sample Stories'),
)
```

3. Run the app and click the button
4. Check Firebase Console to verify stories were uploaded
5. Remove the button after uploading

#### Method B: Manual Upload via Firebase Console

1. Go to Firestore Database in Firebase Console
2. Click **Start collection**
3. Collection ID: `stories`
4. Add documents manually using data from [lib/utils/sample_stories_data.dart](lib/utils/sample_stories_data.dart)

### Step 6: Create Firestore Indexes

For better query performance, create these composite indexes:

1. Go to Firestore Database → Indexes
2. Click **Create Index**

**Index 1: Category + PublishedDate**
- Collection ID: `stories`
- Field 1: `category` (Ascending)
- Field 2: `publishedDate` (Descending)
- Query scope: Collection

**Index 2: isFeatured + PublishedDate**
- Collection ID: `stories`
- Field 1: `isFeatured` (Ascending)
- Field 2: `publishedDate` (Descending)
- Query scope: Collection

### Step 7: Test the Configuration

Run these commands to verify everything works:

```bash
flutter pub get
flutter run
```

If you see any errors, check:
- Firebase is initialized in main.dart
- google-services.json exists in android/app/
- Internet connection is active
- Firestore database is created

## Sample Stories Included

Your app comes with 5 pre-written Swahili love stories:

1. **Penzi la Bahati** - First love story in Kariakoo market
2. **Mpenzi wa Shule** - School romance that lasted years
3. **Penzi Lililopatikana Upya** - Reconnected love after 10 years
4. **Mapenzi ya Ofisini** - Office romance
5. **Ahadi ya Milele** - Eternal promise in marriage

## Story Categories Available

- Mapenzi ya Kwanza (First Love)
- Mapenzi ya Shule (School Love)
- Mapenzi ya Kazi (Office Romance)
- Mapenzi ya Ndoa (Marriage Love)
- Mapenzi Yaliyopotea (Lost Love)

## Firebase Storage (Optional - For Images)

If you want to add cover images:

1. Go to Firebase Console → Storage
2. Click **Get Started**
3. Use test mode for now
4. Create folder structure:
   ```
   stories/
     └── covers/
   ```
5. Upload images and get their download URLs
6. Update the `coverImageUrl` field in your stories

## Troubleshooting

### App not showing in Firebase Console?
- Run `flutterfire configure --project=bible-53642`
- This registers your app package name with Firebase

### Build errors about google-services.json?
- Make sure `flutterfire configure` completed successfully
- Check that `google-services.json` exists in `android/app/`

### Firestore permission denied?
- Check security rules allow read access
- Make sure Firestore database is created

### Stories not loading?
- Check internet connection
- Verify stories exist in Firestore Database
- Check Flutter console for error messages

## Next Steps

After setup is complete, you can:

1. Create UI screens to display stories ([lib/screens/](lib/screens/))
2. Add story reading screen
3. Implement search functionality
4. Add favorites/bookmarks feature
5. Add more stories to Firestore

## Files Created

- ✅ [lib/models/story.dart](lib/models/story.dart) - Story data model
- ✅ [lib/services/story_service.dart](lib/services/story_service.dart) - Firestore operations
- ✅ [lib/providers/story_provider.dart](lib/providers/story_provider.dart) - State management
- ✅ [lib/utils/sample_stories_data.dart](lib/utils/sample_stories_data.dart) - Sample data
- ✅ [lib/utils/upload_sample_stories.dart](lib/utils/upload_sample_stories.dart) - Upload script
- ✅ [FIRESTORE_STRUCTURE.md](FIRESTORE_STRUCTURE.md) - Database documentation
- ✅ [SETUP_INSTRUCTIONS.md](SETUP_INSTRUCTIONS.md) - This file

## Need Help?

If you encounter any issues:
1. Check the error message in Flutter console
2. Verify all steps above are completed
3. Check Firebase Console for any configuration issues
4. Make sure all dependencies are installed with `flutter pub get`
