import 'package:cloud_firestore/cloud_firestore.dart';
import 'sample_stories_data.dart';

/// This script uploads sample stories to Firestore
/// Run this once after Firebase is configured to populate the database
///
/// To run this script:
/// 1. Uncomment the Firebase initialization in main.dart
/// 2. Add a button in your app that calls uploadSampleStories()
/// 3. Or create a separate script file that runs this function

class StoryUploader {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'stories';

  /// Upload all sample stories to Firestore
  Future<void> uploadSampleStories() async {
    try {
      print('Starting to upload sample stories...');

      final stories = getAllSampleStories();
      int successCount = 0;
      int failCount = 0;

      for (int i = 0; i < stories.length; i++) {
        final story = stories[i];

        try {
          // Check if story with same title already exists
          final existingStories = await _firestore
              .collection(_collectionName)
              .where('title', isEqualTo: story['title'])
              .limit(1)
              .get();

          if (existingStories.docs.isNotEmpty) {
            print('Story "${story['title']}" already exists. Skipping...');
            continue;
          }

          // Add the story
          await _firestore.collection(_collectionName).add(story);
          successCount++;
          print('✓ Uploaded: ${story['title']}');
        } catch (e) {
          failCount++;
          print('✗ Failed to upload: ${story['title']} - Error: $e');
        }
      }

      print('\n=== Upload Complete ===');
      print('Success: $successCount');
      print('Failed: $failCount');
      print('Skipped: ${stories.length - successCount - failCount}');
      print('Total: ${stories.length}');
    } catch (e) {
      print('Error uploading stories: $e');
      rethrow;
    }
  }

  /// Upload a single story by index
  Future<bool> uploadStoryByIndex(int index) async {
    try {
      final story = getSampleStoryByIndex(index);

      if (story == null) {
        print('Invalid story index: $index');
        return false;
      }

      // Check if story already exists
      final existingStories = await _firestore
          .collection(_collectionName)
          .where('title', isEqualTo: story['title'])
          .limit(1)
          .get();

      if (existingStories.docs.isNotEmpty) {
        print('Story "${story['title']}" already exists.');
        return false;
      }

      await _firestore.collection(_collectionName).add(story);
      print('✓ Uploaded: ${story['title']}');
      return true;
    } catch (e) {
      print('✗ Failed to upload story: $e');
      return false;
    }
  }

  /// Clear all stories from Firestore (use with caution!)
  Future<void> clearAllStories() async {
    try {
      print('⚠ WARNING: This will delete all stories from Firestore!');

      final snapshot = await _firestore.collection(_collectionName).get();

      for (final doc in snapshot.docs) {
        await doc.reference.delete();
      }

      print('✓ Deleted ${snapshot.docs.length} stories');
    } catch (e) {
      print('✗ Error clearing stories: $e');
      rethrow;
    }
  }

  /// Get story count from Firestore
  Future<int> getFirestoreStoriesCount() async {
    try {
      final snapshot = await _firestore.collection(_collectionName).get();
      return snapshot.docs.length;
    } catch (e) {
      print('Error getting story count: $e');
      return 0;
    }
  }
}

// Example usage:
//
// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
//
//   final uploader = StoryUploader();
//   await uploader.uploadSampleStories();
// }
