import 'package:flutter/foundation.dart';
import '../models/story.dart';
import '../services/story_service.dart';
import '../services/cache_service.dart';

class StoryProvider extends ChangeNotifier {
  final StoryService _storyService = StoryService();
  final CacheService _cacheService = CacheService();

  List<Story> _stories = [];
  List<Story> _featuredStories = [];
  List<Story> _popularStories = [];
  Story? _currentStory;
  String _selectedCategory = 'Yote';
  bool _isLoading = false;
  bool _isLoadingFromCache = false;
  String? _error;

  // Getters
  List<Story> get stories => _stories;
  List<Story> get featuredStories => _featuredStories;
  List<Story> get popularStories => _popularStories;
  Story? get currentStory => _currentStory;
  String get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  bool get isLoadingFromCache => _isLoadingFromCache;
  String? get error => _error;

  // Set loading state
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Set error
  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  // Load all stories with cache-first strategy
  Future<void> loadStoriesWithCache() async {
    _setLoading(true);
    _isLoadingFromCache = true;

    try {
      // First load from cache
      final cachedStories = await _storyService.getCachedStories();

      if (cachedStories.isNotEmpty) {
        _stories = cachedStories;
        _isLoadingFromCache = false;
        _setError(null);
        notifyListeners();
        debugPrint('📦 Loaded ${cachedStories.length} stories from cache');
      }

      // Then sync with server in background
      final newStories = await _storyService.checkForNewStories();

      if (newStories.isNotEmpty) {
        debugPrint('✨ Found ${newStories.length} new stories');
        // Reload from cache to get updated list
        final updatedStories = await _storyService.getCachedStories();
        _stories = updatedStories;
        notifyListeners();
      }

      _setLoading(false);
    } catch (e) {
      _setError('Failed to load stories: $e');
      _setLoading(false);
      _isLoadingFromCache = false;
    }
  }

  // Load all stories (streaming version for real-time updates)
  void loadStories() {
    _setLoading(true);
    _storyService.getStories().listen(
      (stories) {
        _stories = stories;
        _setLoading(false);
        _setError(null);
        notifyListeners();
      },
      onError: (error) {
        _setError('Failed to load stories: $error');
        _setLoading(false);
      },
    );
  }

  // Check for new stories manually
  Future<int> checkForUpdates() async {
    try {
      final newStories = await _storyService.checkForNewStories();

      if (newStories.isNotEmpty) {
        // Refresh the list
        final updatedStories = await _storyService.getCachedStories();
        _stories = updatedStories;
        notifyListeners();
      }

      return newStories.length;
    } catch (e) {
      debugPrint('❌ Error checking for updates: $e');
      return 0;
    }
  }

  // Force refresh from server
  Future<void> forceRefresh() async {
    _setLoading(true);

    try {
      final stories = await _storyService.getStoriesWithCache();
      _stories = stories;
      _setLoading(false);
      _setError(null);
      notifyListeners();
    } catch (e) {
      _setError('Failed to refresh stories: $e');
      _setLoading(false);
    }
  }

  // Load featured stories
  void loadFeaturedStories() {
    _storyService.getFeaturedStories().listen(
      (stories) {
        _featuredStories = stories;
        notifyListeners();
      },
      onError: (error) {
        _setError('Failed to load featured stories: $error');
      },
    );
  }

  // Load popular stories
  void loadPopularStories() {
    _storyService.getPopularStories(limit: 10).listen(
      (stories) {
        _popularStories = stories;
        notifyListeners();
      },
      onError: (error) {
        _setError('Failed to load popular stories: $error');
      },
    );
  }

  // Load stories by category
  void loadStoriesByCategory(String category) {
    _selectedCategory = category;
    _setLoading(true);

    if (category == 'Yote') {
      loadStories();
      return;
    }

    _storyService.getStoriesByCategory(category).listen(
      (stories) {
        _stories = stories;
        _setLoading(false);
        _setError(null);
        notifyListeners();
      },
      onError: (error) {
        _setError('Failed to load stories: $error');
        _setLoading(false);
      },
    );
  }

  // Load single story
  Future<void> loadStory(String storyId) async {
    _setLoading(true);
    try {
      _currentStory = await _storyService.getStoryById(storyId);
      if (_currentStory != null) {
        // Increment views when story is loaded
        await _storyService.incrementViews(storyId);
      }
      _setLoading(false);
      _setError(null);
      notifyListeners();
    } catch (e) {
      _setError('Failed to load story: $e');
      _setLoading(false);
    }
  }

  // Search stories
  void searchStories(String query) {
    if (query.isEmpty) {
      loadStories();
      return;
    }

    _setLoading(true);
    _storyService.searchStories(query).listen(
      (stories) {
        _stories = stories;
        _setLoading(false);
        _setError(null);
        notifyListeners();
      },
      onError: (error) {
        _setError('Failed to search stories: $error');
        _setLoading(false);
      },
    );
  }

  // Like a story
  Future<void> likeStory(String storyId) async {
    try {
      await _storyService.incrementLikes(storyId);

      // Update local state
      if (_currentStory?.id == storyId) {
        _currentStory = _currentStory!.copyWith(
          likes: _currentStory!.likes + 1,
        );
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to like story: $e');
    }
  }

  // Unlike a story
  Future<void> unlikeStory(String storyId) async {
    try {
      await _storyService.decrementLikes(storyId);

      // Update local state
      if (_currentStory?.id == storyId) {
        _currentStory = _currentStory!.copyWith(
          likes: _currentStory!.likes - 1,
        );
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to unlike story: $e');
    }
  }

  // Get categories
  Future<List<String>> getCategories() async {
    try {
      return await _storyService.getCategories();
    } catch (e) {
      _setError('Failed to load categories: $e');
      return [];
    }
  }

  // Clear current story
  void clearCurrentStory() {
    _currentStory = null;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
