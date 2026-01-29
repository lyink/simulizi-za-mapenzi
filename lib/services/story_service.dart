import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/story.dart';
import 'cache_service.dart';

class StoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'stories';
  final CacheService _cacheService = CacheService();

  // Get all stories with caching support
  Stream<List<Story>> getStories() {
    return _firestore
        .collection(_collectionName)
        .orderBy('publishedDate', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      final stories = snapshot.docs
          .map((doc) => Story.fromFirestore(doc.data(), doc.id))
          .toList();

      // Cache stories in background
      _cacheService.cacheStories(stories).catchError((e) {
        debugPrint('❌ Background cache failed: $e');
      });

      return stories;
    });
  }

  /// Get cached stories (for offline/first load)
  Future<List<Story>> getCachedStories() async {
    return await _cacheService.getCachedStories() ?? [];
  }

  /// Check if there are new stories since last check
  Future<List<Story>> checkForNewStories() async {
    try {
      final lastStoryId = await _cacheService.getLastStoryId();

      if (lastStoryId == null) {
        // First time - get all stories
        final snapshot = await _firestore
            .collection(_collectionName)
            .orderBy('publishedDate', descending: true)
            .get();

        final stories = snapshot.docs
            .map((doc) => Story.fromFirestore(doc.data(), doc.id))
            .toList();

        if (stories.isNotEmpty) {
          await _cacheService.saveLastStoryId(stories.first.id);
        }

        return stories;
      }

      // Get the last known story to find its timestamp
      final lastStoryDoc = await _firestore
          .collection(_collectionName)
          .doc(lastStoryId)
          .get();

      if (!lastStoryDoc.exists) {
        // Last story was deleted, fetch all
        return await _getAllStoriesForUpdate();
      }

      final lastStoryDate = DateTime.parse(lastStoryDoc.data()!['publishedDate']);

      // Get stories published after the last known story
      final snapshot = await _firestore
          .collection(_collectionName)
          .where('publishedDate', isGreaterThan: lastStoryDate.toIso8601String())
          .orderBy('publishedDate', descending: true)
          .get();

      final newStories = snapshot.docs
          .map((doc) => Story.fromFirestore(doc.data(), doc.id))
          .toList();

      if (newStories.isNotEmpty) {
        // Update last story ID
        await _cacheService.saveLastStoryId(newStories.first.id);

        // Merge new stories into cache
        await _cacheService.mergeNewStories(newStories);

        debugPrint('✨ Found ${newStories.length} new stories');
      } else {
        debugPrint('✅ No new stories found');
      }

      return newStories;
    } catch (e) {
      debugPrint('❌ Error checking for new stories: $e');
      return [];
    }
  }

  /// Helper to get all stories for update
  Future<List<Story>> _getAllStoriesForUpdate() async {
    final snapshot = await _firestore
        .collection(_collectionName)
        .orderBy('publishedDate', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => Story.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  /// Get stories with cache-first strategy
  Future<List<Story>> getStoriesWithCache() async {
    // First return cached data if available
    final cachedStories = await getCachedStories();

    if (cachedStories.isNotEmpty) {
      debugPrint('📦 Returning ${cachedStories.length} cached stories');

      // Check for updates in background
      checkForNewStories().catchError((e) {
        debugPrint('❌ Background update check failed: $e');
      });

      return cachedStories;
    }

    // No cache, fetch from server
    try {
      final snapshot = await _firestore
          .collection(_collectionName)
          .orderBy('publishedDate', descending: true)
          .get();

      final stories = snapshot.docs
          .map((doc) => Story.fromFirestore(doc.data(), doc.id))
          .toList();

      // Cache the results
      await _cacheService.cacheStories(stories);

      if (stories.isNotEmpty) {
        await _cacheService.saveLastStoryId(stories.first.id);
      }

      debugPrint('🌐 Fetched ${stories.length} stories from server');
      return stories;
    } catch (e) {
      debugPrint('❌ Error fetching stories: $e');
      return [];
    }
  }

  // Get featured stories
  Stream<List<Story>> getFeaturedStories() {
    return _firestore
        .collection(_collectionName)
        .where('isFeatured', isEqualTo: true)
        .orderBy('publishedDate', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Story.fromFirestore(doc.data(), doc.id))
          .toList();
    });
  }

  // Get stories by category
  Stream<List<Story>> getStoriesByCategory(String category) {
    return _firestore
        .collection(_collectionName)
        .where('category', isEqualTo: category)
        .orderBy('publishedDate', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Story.fromFirestore(doc.data(), doc.id))
          .toList();
    });
  }

  // Get single story by ID
  Future<Story?> getStoryById(String id) async {
    try {
      final doc = await _firestore.collection(_collectionName).doc(id).get();
      if (doc.exists && doc.data() != null) {
        return Story.fromFirestore(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      print('Error fetching story: $e');
      return null;
    }
  }

  // Search stories by title or author
  Stream<List<Story>> searchStories(String query) {
    return _firestore
        .collection(_collectionName)
        .orderBy('title')
        .startAt([query])
        .endAt(['$query\uf8ff'])
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Story.fromFirestore(doc.data(), doc.id))
          .toList();
    });
  }

  // Get popular stories (by views)
  Stream<List<Story>> getPopularStories({int limit = 10}) {
    return _firestore
        .collection(_collectionName)
        .orderBy('views', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Story.fromFirestore(doc.data(), doc.id))
          .toList();
    });
  }

  // Increment story views
  Future<void> incrementViews(String storyId) async {
    try {
      await _firestore.collection(_collectionName).doc(storyId).update({
        'views': FieldValue.increment(1),
      });
    } catch (e) {
      print('Error incrementing views: $e');
    }
  }

  // Increment story likes
  Future<void> incrementLikes(String storyId) async {
    try {
      await _firestore.collection(_collectionName).doc(storyId).update({
        'likes': FieldValue.increment(1),
      });
    } catch (e) {
      print('Error incrementing likes: $e');
    }
  }

  // Decrement story likes
  Future<void> decrementLikes(String storyId) async {
    try {
      await _firestore.collection(_collectionName).doc(storyId).update({
        'likes': FieldValue.increment(-1),
      });
    } catch (e) {
      print('Error decrementing likes: $e');
    }
  }

  // Add a new story (admin function)
  Future<String?> addStory(Story story) async {
    try {
      final docRef = await _firestore
          .collection(_collectionName)
          .add(story.toFirestore());
      return docRef.id;
    } catch (e) {
      print('Error adding story: $e');
      return null;
    }
  }

  // Update story (admin function)
  Future<bool> updateStory(String storyId, Story story) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(storyId)
          .update(story.toFirestore());
      return true;
    } catch (e) {
      print('Error updating story: $e');
      return false;
    }
  }

  // Delete story (admin function)
  Future<bool> deleteStory(String storyId) async {
    try {
      await _firestore.collection(_collectionName).doc(storyId).delete();
      return true;
    } catch (e) {
      print('Error deleting story: $e');
      return false;
    }
  }

  // Get all categories
  Future<List<String>> getCategories() async {
    try {
      final snapshot = await _firestore.collection(_collectionName).get();
      final categories = snapshot.docs
          .map((doc) => doc.data()['category'] as String?)
          .where((category) => category != null)
          .toSet()
          .toList();
      return categories.cast<String>();
    } catch (e) {
      print('Error fetching categories: $e');
      return [];
    }
  }

  // Batch import stories from JSON (admin function)
  Future<Map<String, int>> importStoriesFromJson(List<Story> stories) async {
    int successCount = 0;
    int failCount = 0;

    for (var story in stories) {
      try {
        final result = await addStory(story);
        if (result != null) {
          successCount++;
        } else {
          failCount++;
        }
      } catch (e) {
        print('Error importing story ${story.title}: $e');
        failCount++;
      }
    }

    return {
      'success': successCount,
      'failed': failCount,
    };
  }
}
