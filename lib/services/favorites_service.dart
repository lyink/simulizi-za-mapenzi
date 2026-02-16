import 'package:shared_preferences/shared_preferences.dart';

class FavoritesService {
  static final FavoritesService _instance = FavoritesService._internal();
  factory FavoritesService() => _instance;
  FavoritesService._internal();

  static const String _favoritesKey = 'favorite_book_ids';

  /// Get all favorite book IDs
  Future<Set<String>> getFavoriteIds() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> favoriteIds = prefs.getStringList(_favoritesKey) ?? [];
    return Set<String>.from(favoriteIds);
  }

  /// Check if a book is favorited
  Future<bool> isFavorite(String bookId) async {
    final favoriteIds = await getFavoriteIds();
    return favoriteIds.contains(bookId);
  }

  /// Toggle favorite status for a book
  Future<bool> toggleFavorite(String bookId) async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteIds = await getFavoriteIds();

    if (favoriteIds.contains(bookId)) {
      favoriteIds.remove(bookId);
      await prefs.setStringList(_favoritesKey, favoriteIds.toList());
      return false; // No longer a favorite
    } else {
      favoriteIds.add(bookId);
      await prefs.setStringList(_favoritesKey, favoriteIds.toList());
      return true; // Now a favorite
    }
  }

  /// Remove a book from favorites
  Future<void> removeFavorite(String bookId) async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteIds = await getFavoriteIds();
    favoriteIds.remove(bookId);
    await prefs.setStringList(_favoritesKey, favoriteIds.toList());
  }

  /// Add a book to favorites
  Future<void> addFavorite(String bookId) async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteIds = await getFavoriteIds();
    favoriteIds.add(bookId);
    await prefs.setStringList(_favoritesKey, favoriteIds.toList());
  }

  /// Clear all favorites
  Future<void> clearFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_favoritesKey);
  }
}
