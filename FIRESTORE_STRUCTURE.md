# Firestore Database Structure for Simulizi za Mapenzi

## Collection: `stories`

This collection stores all the love stories in the app.

### Document Structure

Each story document contains the following fields:

```json
{
  "title": "string",
  "author": "string",
  "content": "string",
  "synopsis": "string",
  "category": "string",
  "coverImageUrl": "string",
  "publishedDate": "string (ISO 8601 format)",
  "views": "number",
  "likes": "number",
  "tags": ["array", "of", "strings"],
  "isFeatured": "boolean",
  "readingTimeMinutes": "number"
}
```

### Field Descriptions

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `title` | String | Yes | The title of the story |
| `author` | String | Yes | Name of the story author |
| `content` | String | Yes | Full text content of the story |
| `synopsis` | String | Yes | Short description/summary (100-200 words) |
| `category` | String | Yes | Category of the story |
| `coverImageUrl` | String | Yes | URL to cover image (can be Firebase Storage URL) |
| `publishedDate` | String | Yes | ISO 8601 date string (e.g., "2024-01-27T10:00:00.000Z") |
| `views` | Number | No | Number of times the story has been viewed (default: 0) |
| `likes` | Number | No | Number of likes (default: 0) |
| `tags` | Array | No | Array of tags for categorization/search |
| `isFeatured` | Boolean | No | Whether story appears in featured section (default: false) |
| `readingTimeMinutes` | Number | Yes | Estimated reading time in minutes |

### Recommended Categories

- **Mapenzi ya Kwanza** (First Love)
- **Mapenzi ya Shule** (School Love)
- **Mapenzi ya Kazi** (Office Romance)
- **Mapenzi ya Ndoa** (Marriage Love)
- **Mapenzi Yaliyopotea** (Lost Love)
- **Mapenzi ya Ajabu** (Strange Love)
- **Mapenzi ya Kisasa** (Modern Love)
- **Mapenzi ya Jadi** (Traditional Love)

## How to Add Stories to Firestore

### Method 1: Using Firebase Console (Manual)

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project: `bible-53642`
3. Click on "Firestore Database" in the left menu
4. Click "Start collection"
5. Collection ID: `stories`
6. Add your first document with the fields above

### Method 2: Using the Admin Script (Recommended)

Create a script to bulk upload stories:

```dart
// Example story document
{
  "title": "Penzi la Bahati",
  "author": "Juma Ally",
  "content": "Bahati alikuwa msichana mrembo sana...[full story text here]",
  "synopsis": "Hadithi ya msichana mrembo aliyekutana na mpenzi wake kwa bahati nasibu katika soko la Kariakoo.",
  "category": "Mapenzi ya Kwanza",
  "coverImageUrl": "https://example.com/image.jpg",
  "publishedDate": "2024-01-27T10:00:00.000Z",
  "views": 0,
  "likes": 0,
  "tags": ["bahati", "kariakoo", "mapenzi"],
  "isFeatured": true,
  "readingTimeMinutes": 15
}
```

### Method 3: Using REST API

You can use the Firestore REST API to add stories programmatically:

```bash
POST https://firestore.googleapis.com/v1/projects/bible-53642/databases/(default)/documents/stories
```

## Firestore Security Rules

Add these security rules in Firebase Console:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /stories/{storyId} {
      // Anyone can read stories
      allow read: if true;

      // Only authenticated admins can write
      allow write: if request.auth != null && request.auth.token.admin == true;

      // Allow updating views and likes for all users
      allow update: if request.resource.data.diff(resource.data).affectedKeys()
        .hasOnly(['views', 'likes']);
    }
  }
}
```

## Indexes

Create composite indexes for better query performance:

1. **Category + PublishedDate**
   - Collection: `stories`
   - Fields: `category` (Ascending), `publishedDate` (Descending)

2. **isFeatured + PublishedDate**
   - Collection: `stories`
   - Fields: `isFeatured` (Ascending), `publishedDate` (Descending)

3. **Views (Popular Stories)**
   - Collection: `stories`
   - Fields: `views` (Descending)

## Example Stories Data

Here are some sample stories you can add:

### Story 1: Penzi la Bahati
```json
{
  "title": "Penzi la Bahati",
  "author": "Juma Ally",
  "content": "Bahati alikuwa msichana mrembo sana ambaye aliishi Kariakoo, Dar es Salaam...",
  "synopsis": "Hadithi ya msichana mrembo aliyekutana na mpenzi wake kwa bahati nasibu.",
  "category": "Mapenzi ya Kwanza",
  "coverImageUrl": "https://placeholder.com/800x600",
  "publishedDate": "2024-01-27T10:00:00.000Z",
  "views": 0,
  "likes": 0,
  "tags": ["bahati", "kariakoo", "mapenzi ya kwanza"],
  "isFeatured": true,
  "readingTimeMinutes": 15
}
```

### Story 2: Mpenzi wa Shule
```json
{
  "title": "Mpenzi wa Shule",
  "author": "Amina Hassan",
  "content": "Shule ya upili ya Azania ilikuwa maarufu kwa masomo mazuri...",
  "synopsis": "Hadithi ya wanafunzi wawili walioshiriki mapenzi ya siri shuleni.",
  "category": "Mapenzi ya Shule",
  "coverImageUrl": "https://placeholder.com/800x600",
  "publishedDate": "2024-01-26T10:00:00.000Z",
  "views": 0,
  "likes": 0,
  "tags": ["shule", "vijana", "siri"],
  "isFeatured": false,
  "readingTimeMinutes": 20
}
```

## Firebase Storage for Images

Store cover images in Firebase Storage:

### Structure:
```
stories/
  ├── covers/
  │   ├── story1.jpg
  │   ├── story2.jpg
  │   └── story3.jpg
  └── thumbnails/
      ├── story1_thumb.jpg
      ├── story2_thumb.jpg
      └── story3_thumb.jpg
```

### Get Download URL:
After uploading to Firebase Storage, get the download URL and use it as `coverImageUrl` in your story document.

## Next Steps

1. ✅ Model and Service classes created
2. ⏳ Run `flutterfire configure --project=bible-53642`
3. ⏳ Add security rules to Firestore
4. ⏳ Create initial story documents
5. ⏳ Upload cover images to Firebase Storage
6. ⏳ Create UI screens to display stories
