import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/book.dart';
import '../services/book_service.dart';
import '../services/favorites_service.dart';
import '../services/ad_service.dart';
import '../theme/app_theme.dart';
import '../widgets/banner_ad_widget.dart';
import 'book_reader_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final FavoritesService _favoritesService = FavoritesService();
  final BookService _bookService = BookService();
  Set<String> _favoriteIds = {};
  List<Book> _favoriteBooks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() => _isLoading = true);

    _favoriteIds = await _favoritesService.getFavoriteIds();

    if (_favoriteIds.isEmpty) {
      setState(() {
        _favoriteBooks = [];
        _isLoading = false;
      });
      return;
    }

    // Get all books and filter by favorite IDs
    _bookService.getBooks().listen((allBooks) {
      if (mounted) {
        setState(() {
          _favoriteBooks = allBooks
              .where((book) => _favoriteIds.contains(book.id))
              .toList();
          _isLoading = false;
        });
      }
    });
  }

  Future<void> _removeFavorite(Book book) async {
    // Show interstitial ad when removing from favorites
    AdService().showInterstitialAd();

    await _favoritesService.removeFavorite(book.id);
    await _loadFavorites();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${book.title} removed from favorites'),
          backgroundColor: AppTheme.accent,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _openBook(Book book) {
    _bookService.incrementViews(book.id);

    // Track story open for rewarded ads
    AdService().trackStoryOpen();

    // Show interstitial ad before opening book
    AdService().showInterstitialAd();

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => BookReaderScreen(book: book)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark ? AppTheme.cardBg : AppTheme.lightCardBg;
    final textColor = isDark ? AppTheme.textLight : AppTheme.lightTextPrimary;
    final mutedColor = isDark ? AppTheme.textMuted : AppTheme.lightTextMuted;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Favorites'),
        actions: [
          if (_favoriteBooks.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_rounded),
              tooltip: 'Clear all favorites',
              onPressed: () => _confirmClearAll(),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.accent),
            )
          : _favoriteBooks.isEmpty
              ? _buildEmptyState(mutedColor)
              : Column(
                  children: [
                    // Top banner ad
                    const BannerAdWidget(),
                    const SizedBox(height: 8),

                    // Favorites count
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      child: Row(
                        children: [
                          Icon(Icons.favorite_rounded,
                              color: AppTheme.accent, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            '${_favoriteBooks.length} favorite ${_favoriteBooks.length == 1 ? 'story' : 'stories'}',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Favorites list
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        itemCount: _favoriteBooks.length + 1,
                        itemBuilder: (context, index) {
                          // Insert banner ad every 4 items
                          if ((index + 1) % 5 == 0 &&
                              index < _favoriteBooks.length) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: BannerAdWidget(),
                            );
                          }

                          final bookIndex =
                              index - (index ~/ 5); // Adjust for ads
                          if (bookIndex >= _favoriteBooks.length) {
                            // Bottom banner ad
                            return const Padding(
                              padding: EdgeInsets.only(top: 12),
                              child: BannerAdWidget(),
                            );
                          }

                          final book = _favoriteBooks[bookIndex];
                          return _buildFavoriteCard(
                              book, cardColor, textColor, mutedColor, isDark);
                        },
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildEmptyState(Color mutedColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border_rounded,
            size: 80,
            color: mutedColor.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 20),
          Text(
            'No favorites yet',
            style: TextStyle(
              color: mutedColor,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Tap the heart icon on any story to add it to your favorites',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: mutedColor,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteCard(Book book, Color cardColor, Color textColor,
      Color mutedColor, bool isDark) {
    final pageCount = book.pageTexts.isNotEmpty
        ? book.pageTexts.length
        : book.pageImageUrls.length;

    return GestureDetector(
      onTap: () => _openBook(book),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.06),
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              child: book.coverImageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: book.coverImageUrl,
                      width: 100,
                      height: 140,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => _shimmerBox(),
                      errorWidget: (_, __, ___) => _placeholderCover(book),
                    )
                  : _placeholderCover(book),
            ),

            // Book info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            book.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: textColor,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              height: 1.3,
                            ),
                          ),
                        ),
                        // Remove favorite button
                        IconButton(
                          icon: const Icon(Icons.favorite_rounded,
                              color: AppTheme.accent, size: 22),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () => _removeFavorite(book),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Author
                    if (book.author.isNotEmpty && book.author != 'AI Generated')
                      Text(
                        book.author,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: mutedColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    const SizedBox(height: 8),

                    // Category chip
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.accent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppTheme.accent.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Text(
                        book.category,
                        style: const TextStyle(
                          color: AppTheme.accent,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Pages and views
                    Row(
                      children: [
                        Icon(Icons.menu_book_rounded,
                            size: 13, color: mutedColor),
                        const SizedBox(width: 4),
                        Text(
                          '$pageCount pages',
                          style: TextStyle(
                            color: mutedColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.visibility_rounded,
                            size: 13, color: mutedColor),
                        const SizedBox(width: 4),
                        Text(
                          '${book.views} views',
                          style: TextStyle(
                            color: mutedColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _shimmerBox() {
    return Container(
      width: 100,
      height: 140,
      color: AppTheme.secondary,
    );
  }

  Widget _placeholderCover(Book book) {
    return Container(
      width: 100,
      height: 140,
      color: AppTheme.secondary,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            book.title,
            textAlign: TextAlign.center,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppTheme.textLight,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
          ),
        ),
      ),
    );
  }

  void _confirmClearAll() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark ? AppTheme.cardBg : AppTheme.lightCardBg;
    final textColor = isDark ? AppTheme.textLight : AppTheme.lightTextPrimary;
    final mutedColor = isDark ? AppTheme.textMuted : AppTheme.lightTextMuted;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: cardColor,
        title: Text('Clear All Favorites',
            style: TextStyle(color: textColor, fontWeight: FontWeight.w700)),
        content: Text(
          'Are you sure you want to remove all ${_favoriteBooks.length} stories from your favorites?',
          style: TextStyle(color: mutedColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: mutedColor)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              // Show interstitial ad when clearing all
              AdService().showInterstitialAd();

              await _favoritesService.clearFavorites();
              await _loadFavorites();

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All favorites cleared'),
                    backgroundColor: AppTheme.success,
                    behavior: SnackBarBehavior.floating,
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accent),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}
