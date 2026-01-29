# JSON Import Feature - Complete Guide

## Overview
Your admin panel now supports importing stories via JSON with a structured chapter and verse format. This is perfect for organizing story content in a hierarchical way.

## Features Added

### 1. **Story Model Updates** ([lib/models/story.dart](lib/models/story.dart))
- Added `chapters` field to support structured story content
- Backward compatible with existing `content` field
- Added helper methods:
  - `hasChapters` - Check if story uses chapter structure
  - `chapterCount` - Get total number of chapters
  - `totalVerseCount` - Get total verses across all chapters

### 2. **Chapter & Verse Models** ([lib/models/chapter.dart](lib/models/chapter.dart))
- **Verse**: Contains verse number and text
- **Chapter**: Contains chapter number, title, and list of verses
- Both models include:
  - `fromMap()` - Parse from JSON/Firestore
  - `toMap()` - Convert to JSON/Firestore format

### 3. **Import Screen** ([lib/screens/admin/import_stories_screen.dart](lib/screens/admin/import_stories_screen.dart))
Features:
- **Dual Input Methods**:
  - ✅ Paste JSON directly into a text field
  - ✅ Upload JSON file from device
- **Real-time Validation**: Checks required fields and structure
- **Preview**: Shows all stories with chapter/verse counts before import
- **Progress Tracking**: Displays success/failure counts after import
- **Error Handling**: Clear error messages for invalid JSON

### 4. **Updated Services** ([lib/services/story_service.dart](lib/services/story_service.dart))
- Added `importStoriesFromJson()` method for batch imports
- Full support for chapter-based stories in Firestore

## JSON Format

### Required Structure

```json
[
  {
    "title": "Story Title",
    "author": "Author Name",
    "category": "Romance",
    "coverImageUrl": "https://example.com/image.jpg",
    "synopsis": "Brief story description",
    "readingTimeMinutes": 15,
    "tags": ["love", "drama"],
    "isFeatured": false,
    "chapters": [
      {
        "number": 1,
        "title": "Chapter One Title",
        "verses": [
          {
            "number": 1,
            "text": "First verse content..."
          },
          {
            "number": 2,
            "text": "Second verse content..."
          }
        ]
      },
      {
        "number": 2,
        "title": "Chapter Two Title",
        "verses": [
          {
            "number": 1,
            "text": "Chapter 2, verse 1..."
          }
        ]
      }
    ]
  }
]
```

### Field Requirements

#### Required Fields:
- `title` - Story title
- `author` - Author name
- `category` - Story category (e.g., "Romance", "Drama")
- `synopsis` - Brief description
- `chapters` - Array of chapters (must have at least one)
  - Each chapter must have:
    - `number` - Chapter number
    - `title` - Chapter title
    - `verses` - Array of verses (must have at least one)
      - Each verse must have:
        - `number` - Verse number
        - `text` - Verse content

#### Optional Fields:
- `coverImageUrl` - Cover image URL (defaults to empty string)
- `readingTimeMinutes` - Estimated reading time (defaults to 0)
- `tags` - Array of tags (defaults to empty array)
- `isFeatured` - Featured status (defaults to false)

## How to Use

### Method 1: Paste JSON

1. Navigate to Admin Panel
2. Tap "Import Stories from JSON"
3. Select "Paste JSON" tab
4. Paste your JSON content into the text field
5. Tap "Parse & Preview"
6. Review the stories preview
7. Tap "Import X Stories" to complete

### Method 2: Upload File

1. Navigate to Admin Panel
2. Tap "Import Stories from JSON"
3. Select "Upload File" tab
4. Tap "Choose JSON File"
5. Select your .json file
6. Review the stories preview (auto-displayed)
7. Tap "Import X Stories" to complete

## Sample File

A complete sample JSON file has been created at [sample_stories_format.json](sample_stories_format.json) with two example stories showing proper structure.

## Validation

The import feature validates:
- ✅ JSON is properly formatted
- ✅ JSON is an array of objects
- ✅ All required fields are present
- ✅ Chapters array exists and has content
- ✅ Each chapter has verses
- ✅ Each verse has number and text

## Error Handling

Common errors and solutions:

| Error | Solution |
|-------|----------|
| "JSON must be an array" | Wrap your story objects in `[...]` |
| "Missing required field: chapters" | Add chapters array to each story |
| "Each chapter must have verses" | Ensure each chapter has at least one verse |
| "Invalid JSON format" | Check for syntax errors (missing commas, quotes, etc.) |

## Firestore Structure

Stories are saved with this structure:
```
stories/
  └── {storyId}/
      ├── title
      ├── author
      ├── category
      ├── synopsis
      ├── coverImageUrl
      ├── readingTimeMinutes
      ├── tags[]
      ├── isFeatured
      ├── publishedDate
      ├── views
      ├── likes
      ├── content (empty for chapter-based)
      └── chapters[]
          └── {chapterIndex}/
              ├── number
              ├── title
              └── verses[]
                  └── {verseIndex}/
                      ├── number
                      └── text
```

## Next Steps

To display chapters properly in your app, you'll need to update:
1. Story reading screens to show chapter navigation
2. Verse-by-verse display functionality
3. Chapter selection UI

Would you like me to implement the chapter display screens next?

## Dependencies Added

- `file_picker: ^8.0.0+1` - For file selection functionality

Run `flutter pub get` to ensure all dependencies are installed (already completed).
