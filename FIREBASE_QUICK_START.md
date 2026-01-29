# Firebase Quick Start Guide

## 🚀 Quick Setup (3 Steps)

### 1️⃣ Configure Firebase
```bash
flutterfire configure --project=bible-53642
```
Select platforms: android, ios, web

### 2️⃣ Uncomment Firebase Init in main.dart
```dart
import 'firebase_options.dart';

await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

### 3️⃣ Create Firestore Database
- Go to Firebase Console
- Create Firestore Database in test mode
- Your app is ready!

---

## 📊 Firestore Collection: `stories`

### Document Example:
```json
{
  "title": "Penzi la Bahati",
  "author": "Juma Ally",
  "content": "[Full story text...]",
  "synopsis": "Short description...",
  "category": "Mapenzi ya Kwanza",
  "coverImageUrl": "https://...",
  "publishedDate": "2024-01-27T10:00:00.000Z",
  "views": 150,
  "likes": 45,
  "tags": ["bahati", "kariakoo"],
  "isFeatured": true,
  "readingTimeMinutes": 5
}
```

---

## 📝 Sample Stories Ready to Upload

5 complete Swahili love stories are ready in:
- [lib/utils/sample_stories_data.dart](lib/utils/sample_stories_data.dart)

### To Upload Stories:

**Option 1: Using Script**
```dart
import 'utils/upload_sample_stories.dart';

final uploader = StoryUploader();
await uploader.uploadSampleStories();
```

**Option 2: Firebase Console**
- Copy data from sample_stories_data.dart
- Paste into Firestore Console manually

---

## 🔐 Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /stories/{storyId} {
      allow read: if true;
      allow update: if request.resource.data.diff(resource.data)
        .affectedKeys().hasOnly(['views', 'likes']);
    }
  }
}
```

---

## 🎯 Categories Included

- **Mapenzi ya Kwanza** (First Love)
- **Mapenzi ya Shule** (School Love)
- **Mapenzi ya Kazi** (Office Romance)
- **Mapenzi ya Ndoa** (Marriage Love)
- **Mapenzi Yaliyopotea** (Lost Love)

---

## 📱 Available Services

### StoryService ([lib/services/story_service.dart](lib/services/story_service.dart))
- ✅ `getStories()` - Get all stories
- ✅ `getFeaturedStories()` - Get featured stories
- ✅ `getStoriesByCategory()` - Filter by category
- ✅ `getStoryById()` - Get single story
- ✅ `searchStories()` - Search by title/author
- ✅ `getPopularStories()` - Most viewed stories
- ✅ `incrementViews()` - Track story views
- ✅ `incrementLikes()` - Track likes

### StoryProvider ([lib/providers/story_provider.dart](lib/providers/story_provider.dart))
State management with Provider pattern

---

## 🎨 Ready to Use

### Models
- ✅ Story model with Firestore serialization
- ✅ Complete CRUD operations
- ✅ View and like tracking

### Services
- ✅ StoryService for Firestore
- ✅ Real-time data streams
- ✅ Error handling

### Sample Data
- ✅ 5 complete love stories in Swahili
- ✅ Upload script included
- ✅ Multiple categories

---

## ⚡ Next Steps After Setup

1. **Create Story List Screen**
   - Display all stories
   - Show featured stories
   - Filter by category

2. **Create Story Reading Screen**
   - Full story content
   - Track views automatically
   - Like/unlike functionality

3. **Add Search**
   - Search by title
   - Search by author
   - Filter by tags

4. **Add Favorites**
   - Save favorite stories locally
   - Sync with user account

---

## 📦 Files Created for You

✅ `lib/models/story.dart` - Data model
✅ `lib/services/story_service.dart` - Firestore service
✅ `lib/providers/story_provider.dart` - State management
✅ `lib/utils/sample_stories_data.dart` - 5 sample stories
✅ `lib/utils/upload_sample_stories.dart` - Upload helper
✅ `FIRESTORE_STRUCTURE.md` - Complete documentation
✅ `SETUP_INSTRUCTIONS.md` - Detailed setup guide
✅ `FIREBASE_QUICK_START.md` - This quick reference

---

## 🎉 Your App Package

- **Name:** `simulizi_za_mapenzi`
- **Firebase Project:** `bible-53642`
- **Package ID:** `com.lyinkjr.kamusi`
- **Collection:** `stories`

Everything is ready! Just run the 3 setup steps above and your stories app will be live! 🚀
