import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'story_service.dart';
import 'notification_service.dart';
import 'cache_service.dart';

/// Service to sync stories and notify about new ones
class StorySyncService {
  static final StorySyncService _instance = StorySyncService._internal();
  factory StorySyncService() => _instance;
  StorySyncService._internal();

  final StoryService _storyService = StoryService();
  final NotificationService _notificationService = NotificationService();
  final CacheService _cacheService = CacheService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  StreamSubscription<QuerySnapshot>? _storySubscription;

  /// Initialize story sync (listen for new stories in real-time)
  Future<void> initialize() async {
    // Listen to story collection for new additions
    _listenForNewStories();

    // Perform initial sync
    await performSync();
  }

  /// Listen for new stories in real-time
  void _listenForNewStories() {
    try {
      _storySubscription = _firestore
          .collection('stories')
          .orderBy('publishedDate', descending: true)
          .limit(1) // Only watch the latest story
          .snapshots()
          .listen((snapshot) async {
        if (snapshot.docs.isEmpty) return;

        final latestStory = snapshot.docs.first;
        final storyData = latestStory.data();
        final storyId = latestStory.id;

        // Check if this is a truly new story
        final lastKnownId = await _cacheService.getLastStoryId();

        if (lastKnownId != null && storyId != lastKnownId) {
          // New story detected!
          final title = storyData['title'] ?? 'Untitled';
          final author = storyData['author'] ?? 'Unknown';

          debugPrint('✨ New story detected: $title');

          // Send notification
          await _notificationService.notifyNewStory(
            storyTitle: title,
            storyAuthor: author,
            storyId: storyId,
          );

          // Update cache
          await _cacheService.saveLastStoryId(storyId);
        }
      });

      debugPrint('👂 Listening for new stories...');
    } catch (e) {
      debugPrint('❌ Failed to set up story listener: $e');
    }
  }

  /// Perform manual sync to check for new stories
  Future<void> performSync() async {
    try {
      debugPrint('🔄 Starting story sync...');

      final newStories = await _storyService.checkForNewStories();

      if (newStories.isEmpty) {
        debugPrint('✅ No new stories found');
        return;
      }

      debugPrint('✨ Found ${newStories.length} new stories');

      // Send appropriate notification
      if (newStories.length == 1) {
        await _notificationService.notifyNewStory(
          storyTitle: newStories.first.title,
          storyAuthor: newStories.first.author,
          storyId: newStories.first.id,
        );
      } else if (newStories.length > 1) {
        await _notificationService.notifyMultipleNewStories(newStories.length);
      }
    } catch (e) {
      debugPrint('❌ Story sync failed: $e');
    }
  }

  /// Dispose and clean up
  void dispose() {
    _storySubscription?.cancel();
  }

  /// Force refresh all stories and update cache
  Future<void> forceRefresh() async {
    try {
      debugPrint('🔄 Force refreshing stories...');

      final stories = await _storyService.getStoriesWithCache();

      if (stories.isNotEmpty) {
        await _cacheService.cacheStories(stories);
        await _cacheService.saveLastStoryId(stories.first.id);
        debugPrint('✅ Refreshed ${stories.length} stories');
      }
    } catch (e) {
      debugPrint('❌ Force refresh failed: $e');
    }
  }

  /// Get sync statistics
  Future<Map<String, dynamic>> getSyncStats() async {
    final cacheStats = await _cacheService.getCacheStats();
    final lastStoryId = await _cacheService.getLastStoryId();

    return {
      ...cacheStats,
      'lastStoryId': lastStoryId,
      'isListening': _storySubscription != null,
    };
  }
}
