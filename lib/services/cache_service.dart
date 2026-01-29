import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/story.dart';

/// Service for caching stories locally for faster load times and offline access
class CacheService {
  static const String _keyStoriesCache = 'stories_cache';
  static const String _keyLastSync = 'last_sync_time';
  static const String _keyLastStoryId = 'last_story_id';
  static const String _keyStoryIds = 'story_ids_list';

  /// Save stories to local cache
  Future<void> cacheStories(List<Story> stories) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Convert stories to JSON
      final storiesJson = stories.map((story) {
        final map = story.toFirestore();
        map['id'] = story.id;
        return map;
      }).toList();

      // Store as string
      final jsonString = jsonEncode(storiesJson);
      await prefs.setString(_keyStoriesCache, jsonString);

      // Store story IDs for quick checking
      final storyIds = stories.map((s) => s.id).toList();
      await prefs.setStringList(_keyStoryIds, storyIds);

      // Update last sync time
      await prefs.setString(_keyLastSync, DateTime.now().toIso8601String());

      debugPrint('✅ Cached ${stories.length} stories');
    } catch (e) {
      debugPrint('❌ Error caching stories: $e');
    }
  }

  /// Get cached stories
  Future<List<Story>?> getCachedStories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_keyStoriesCache);

      if (jsonString == null) {
        debugPrint('📭 No cached stories found');
        return null;
      }

      final List<dynamic> storiesJson = jsonDecode(jsonString);
      final stories = storiesJson.map((json) {
        final id = json['id'] as String;
        return Story.fromFirestore(json, id);
      }).toList();

      debugPrint('📦 Retrieved ${stories.length} cached stories');
      return stories;
    } catch (e) {
      debugPrint('❌ Error retrieving cached stories: $e');
      return null;
    }
  }

  /// Get last sync time
  Future<DateTime?> getLastSyncTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final syncTimeString = prefs.getString(_keyLastSync);

      if (syncTimeString == null) return null;

      return DateTime.parse(syncTimeString);
    } catch (e) {
      debugPrint('❌ Error retrieving last sync time: $e');
      return null;
    }
  }

  /// Check if cache exists
  Future<bool> hasCachedData() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_keyStoriesCache);
  }

  /// Get cached story IDs
  Future<List<String>> getCachedStoryIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList(_keyStoryIds) ?? [];
    } catch (e) {
      debugPrint('❌ Error retrieving cached story IDs: $e');
      return [];
    }
  }

  /// Save last known story ID for checking new stories
  Future<void> saveLastStoryId(String storyId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyLastStoryId, storyId);
      debugPrint('💾 Saved last story ID: $storyId');
    } catch (e) {
      debugPrint('❌ Error saving last story ID: $e');
    }
  }

  /// Get last known story ID
  Future<String?> getLastStoryId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyLastStoryId);
    } catch (e) {
      debugPrint('❌ Error retrieving last story ID: $e');
      return null;
    }
  }

  /// Clear all cached data
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyStoriesCache);
      await prefs.remove(_keyLastSync);
      await prefs.remove(_keyStoryIds);
      await prefs.remove(_keyLastStoryId);
      debugPrint('🗑️ Cache cleared');
    } catch (e) {
      debugPrint('❌ Error clearing cache: $e');
    }
  }

  /// Check if cache is stale (older than specified hours)
  Future<bool> isCacheStale({int maxAgeHours = 24}) async {
    final lastSync = await getLastSyncTime();
    if (lastSync == null) return true;

    final age = DateTime.now().difference(lastSync);
    return age.inHours > maxAgeHours;
  }

  /// Get cache age in hours
  Future<int> getCacheAgeHours() async {
    final lastSync = await getLastSyncTime();
    if (lastSync == null) return -1;

    return DateTime.now().difference(lastSync).inHours;
  }

  /// Cache a single story
  Future<void> cacheSingleStory(Story story) async {
    try {
      final cachedStories = await getCachedStories() ?? [];

      // Remove existing story with same ID if present
      cachedStories.removeWhere((s) => s.id == story.id);

      // Add new story
      cachedStories.insert(0, story);

      // Save back to cache
      await cacheStories(cachedStories);

      debugPrint('💾 Cached single story: ${story.title}');
    } catch (e) {
      debugPrint('❌ Error caching single story: $e');
    }
  }

  /// Update cache with new stories only (merge strategy)
  Future<void> mergeNewStories(List<Story> newStories) async {
    try {
      final cachedStories = await getCachedStories() ?? [];
      final cachedIds = cachedStories.map((s) => s.id).toSet();

      // Find truly new stories
      final actuallyNewStories = newStories.where((story) =>
        !cachedIds.contains(story.id)
      ).toList();

      if (actuallyNewStories.isEmpty) {
        debugPrint('✅ No new stories to merge');
        return;
      }

      // Merge: new stories first, then cached stories
      final mergedStories = [...actuallyNewStories, ...cachedStories];

      // Save merged data
      await cacheStories(mergedStories);

      debugPrint('🔄 Merged ${actuallyNewStories.length} new stories into cache');
    } catch (e) {
      debugPrint('❌ Error merging stories: $e');
    }
  }

  /// Get cache statistics
  Future<Map<String, dynamic>> getCacheStats() async {
    final hasCachedData = await this.hasCachedData();
    final lastSync = await getLastSyncTime();
    final cacheAge = await getCacheAgeHours();
    final cachedStories = await getCachedStories();

    return {
      'hasCachedData': hasCachedData,
      'lastSync': lastSync?.toIso8601String(),
      'cacheAgeHours': cacheAge,
      'cachedStoriesCount': cachedStories?.length ?? 0,
      'isCacheStale': await isCacheStale(),
    };
  }
}
