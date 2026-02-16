import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/book.dart';
import '../services/ad_service.dart';
import '../services/favorites_service.dart';
import '../theme/app_theme.dart';
import '../widgets/banner_ad_widget.dart';

// Warm parchment colours used throughout the reader
class _ReaderColors {
  static const Color pageBg = Color(0xFFFAF6EE);       // warm cream
  static const Color inkPrimary = Color(0xFF1C1208);    // near-black ink
  static const Color inkSecondary = Color(0xFF4A3F2F);  // warm dark brown
  static const Color inkMuted = Color(0xFF8B7D6B);      // muted tan
  static const Color divider = Color(0xFFD4C9B0);       // aged paper line
  static const Color accentWarm = Color(0xFFB5390A);    // warm crimson (ink accent)
  static const Color chapterBg = Color(0xFFEFE8D8);     // slightly darker cream for header
  static const Color navBg = Color(0xFFF0EAD8);         // nav bar bg
  static const Color navBorder = Color(0xFFCFC3A8);
}

class BookReaderScreen extends StatefulWidget {
  final Book book;

  const BookReaderScreen({super.key, required this.book});

  @override
  State<BookReaderScreen> createState() => _BookReaderScreenState();
}

class _BookReaderScreenState extends State<BookReaderScreen> {
  late PageController _pageController;
  int _currentPage = 0;
  bool _showUI = true;
  int _chaptersReadSinceLastAd = 0;
  bool _isFavorite = false;
  final FavoritesService _favoritesService = FavoritesService();

  // Page 0 = cover. Pages 1+ = one chapter each (3 verses per chapter).
  late final List<List<String>> _chapters;
  static const int _versesPerChapter = 6;

  @override
  void initState() {
    super.initState();

    final texts = widget.book.pageTexts;
    _chapters = [];
    for (int i = 0; i < texts.length; i += _versesPerChapter) {
      _chapters.add(
        texts.sublist(i, (i + _versesPerChapter).clamp(0, texts.length)),
      );
    }
    if (_chapters.isEmpty) _chapters.add([]);

    _pageController = PageController();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _loadFavoriteStatus();
  }

  Future<void> _loadFavoriteStatus() async {
    final isFav = await _favoritesService.isFavorite(widget.book.id);
    if (mounted) {
      setState(() => _isFavorite = isFav);
    }
  }

  Future<void> _toggleFavorite() async {
    final newStatus = await _favoritesService.toggleFavorite(widget.book.id);

    // Show interstitial ad when toggling favorite
    AdService().showInterstitialAd();

    if (mounted) {
      setState(() => _isFavorite = newStatus);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            newStatus
                ? '${widget.book.title} added to favorites'
                : '${widget.book.title} removed from favorites',
          ),
          backgroundColor: newStatus ? AppTheme.success : AppTheme.accent,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    // Show interstitial ad when leaving the reader
    AdService().showInterstitialAd();

    super.dispose();
  }

  int get _totalPages => 1 + _chapters.length;

  void _toggleUI() => setState(() => _showUI = !_showUI);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _ReaderColors.pageBg,
      body: GestureDetector(
        onTap: _toggleUI,
        child: Stack(
          children: [
            // Plain PageView — no transitions, no blur, instant crisp swipe
            PageView.builder(
              controller: _pageController,
              physics: const ClampingScrollPhysics(),
              itemCount: _totalPages,
              onPageChanged: (i) {
                setState(() => _currentPage = i);

                // Show reward ad after every 3 chapters (not on cover page)
                if (i > 0) {
                  _chaptersReadSinceLastAd++;
                  if (_chaptersReadSinceLastAd >= 3) {
                    _chaptersReadSinceLastAd = 0;
                    // Show reward ad automatically without dialog
                    AdService().showRewardedAd();
                  }
                }
              },
              itemBuilder: (context, index) {
                if (index == 0) return _buildCoverPage();
                return _buildChapterPage(index - 1);
              },
            ),

            // Top bar — slides up/down instantly (no fade/blur)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              top: _showUI ? 0 : -120,
              left: 0,
              right: 0,
              child: _currentPage == 0
                  ? _buildCoverTopBar(context)
                  : _buildReaderTopBar(context),
            ),

            // Bottom nav — slides down/up instantly
            AnimatedPositioned(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              bottom: _showUI ? 0 : -100,
              left: 0,
              right: 0,
              child: _currentPage == 0
                  ? _buildCoverBottomNav()
                  : _buildReaderBottomNav(),
            ),

            // Minimal indicator when UI hidden
            if (!_showUI)
              Positioned(
                bottom: 14,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      color: _currentPage == 0
                          ? Colors.black54
                          : _ReaderColors.inkMuted.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _currentPage == 0
                          ? 'Jalada'
                          : 'Sura $_currentPage / ${_chapters.length}',
                      style: TextStyle(
                        color: _currentPage == 0
                            ? Colors.white70
                            : _ReaderColors.inkMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // COVER PAGE — dark/immersive, matches the generated cover image
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildCoverPage() {
    final imageUrl = widget.book.coverImageUrl;
    return Stack(
      fit: StackFit.expand,
      children: [
        imageUrl.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  color: const Color(0xFF1A1A2E),
                  child: const Center(
                    child: CircularProgressIndicator(
                        color: AppTheme.accent, strokeWidth: 2),
                  ),
                ),
                errorWidget: (_, __, ___) => _coverPlaceholder(),
              )
            : _coverPlaceholder(),

        // Dark gradient for readability
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0x44000000),
                Color(0x77000000),
                Color(0xE8000000),
                Colors.black,
              ],
              stops: [0.0, 0.3, 0.65, 1.0],
            ),
          ),
        ),

        // Title / author / synopsis / start button
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28, 48, 28, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.book.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                    letterSpacing: -0.3,
                    shadows: [
                      Shadow(
                          color: Colors.black54,
                          blurRadius: 10,
                          offset: Offset(0, 3))
                    ],
                  ),
                ),
                if (widget.book.synopsis.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    widget.book.synopsis,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.80),
                      fontSize: 14,
                      height: 1.6,
                    ),
                  ),
                ],
                const SizedBox(height: 28),
                GestureDetector(
                  onTap: () => _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppTheme.accent,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.accent.withValues(alpha: 0.45),
                          blurRadius: 14,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Anza Kusoma',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.menu_book_rounded,
                            color: Colors.white, size: 18),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // CHAPTER / STORY PAGE — warm paper, narrative style
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildChapterPage(int chapterIndex) {
    final verses = _chapters[chapterIndex];
    final chapterNumber = chapterIndex + 1;
    final isLast = chapterIndex == _chapters.length - 1;

    // Global verse number offset
    int verseOffset = 0;
    for (int i = 0; i < chapterIndex; i++) {
      verseOffset += _chapters[i].length;
    }

    return Container(
      color: _ReaderColors.pageBg,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          28,
          MediaQuery.of(context).padding.top + 72, // below top bar
          28,
          100, // above bottom nav
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Chapter heading ──────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
              decoration: BoxDecoration(
                color: _ReaderColors.chapterBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _ReaderColors.divider, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SURA ${chapterNumber.toString().padLeft(2, '0')}',
                    style: const TextStyle(
                      color: _ReaderColors.accentWarm,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.book.title,
                    style: const TextStyle(
                      color: _ReaderColors.inkPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // ── Verses ───────────────────────────────────────────────
            ...List.generate(verses.length, (i) {
              final verseNumber = verseOffset + i + 1;
              final text = verses[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: 26),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Verse number — small superscript style
                    Padding(
                      padding: const EdgeInsets.only(top: 3, right: 12),
                      child: Text(
                        '$verseNumber',
                        style: const TextStyle(
                          color: _ReaderColors.accentWarm,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          height: 1.9,
                        ),
                      ),
                    ),
                    // Verse body — narrative/book typography
                    Expanded(
                      child: Text(
                        text,
                        style: const TextStyle(
                          color: _ReaderColors.inkPrimary,
                          fontSize: 17,
                          fontWeight: FontWeight.w400,
                          height: 1.85,
                          letterSpacing: 0.15,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),

            // ── Banner Ad ─────────────────────────────────────────────
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: BannerAdWidget(),
            ),

            // ── Chapter divider (not on last chapter) ────────────────
            if (!isLast)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  children: [
                    Expanded(child: Divider(color: _ReaderColors.divider)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Text(
                        '—  —  —',
                        style: TextStyle(
                            color: _ReaderColors.inkMuted, fontSize: 11),
                      ),
                    ),
                    Expanded(child: Divider(color: _ReaderColors.divider)),
                  ],
                ),
              ),

            // ── End of story badge ────────────────────────────────────
            if (isLast)
              Padding(
                padding: const EdgeInsets.only(top: 28, bottom: 8),
                child: Center(
                  child: Column(
                    children: [
                      Divider(color: _ReaderColors.divider),
                      const SizedBox(height: 16),
                      Text(
                        '— Mwisho wa Hadithi —',
                        style: TextStyle(
                          color: _ReaderColors.inkMuted,
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.book.title,
                        style: TextStyle(
                          color: _ReaderColors.inkSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Banner ad at the end of story
                      const BannerAdWidget(),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // TOP BARS
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildCoverTopBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 16,
        right: 16,
        bottom: 10,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black87, Colors.transparent],
        ),
      ),
      child: Row(
        children: [
          _backButton(Colors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.book.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          // Favorite button
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: _isFavorite ? AppTheme.accent : Colors.white,
              size: 24,
            ),
            onPressed: _toggleFavorite,
          ),
        ],
      ),
    );
  }

  Widget _buildReaderTopBar(BuildContext context) {
    final chapterIndex = _currentPage - 1;
    final label =
        'Sura ${(chapterIndex + 1).toString().padLeft(2, '0')} / ${_chapters.length.toString().padLeft(2, '0')}';

    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 16,
        right: 16,
        bottom: 10,
      ),
      decoration: BoxDecoration(
        color: _ReaderColors.pageBg,
        border: Border(
          bottom: BorderSide(color: _ReaderColors.divider, width: 1),
        ),
      ),
      child: Row(
        children: [
          _backButton(_ReaderColors.inkPrimary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.book.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _ReaderColors.inkPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    color: _ReaderColors.inkMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
          ),
          // Favorite button
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: _isFavorite ? AppTheme.accent : _ReaderColors.inkMuted,
              size: 22,
            ),
            onPressed: _toggleFavorite,
          ),
          const SizedBox(width: 8),
          // Reading progress text
          Text(
            '${((_currentPage / (_totalPages - 1)) * 100).round()}%',
            style: const TextStyle(
              color: _ReaderColors.accentWarm,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _backButton(Color color) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color == Colors.white
              ? Colors.black26
              : _ReaderColors.chapterBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: color == Colors.white
                  ? Colors.white24
                  : _ReaderColors.divider),
        ),
        child: Icon(Icons.arrow_back_rounded, color: color, size: 20),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // BOTTOM NAV BARS
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildCoverBottomNav() {
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 12, 20, MediaQuery.of(context).padding.bottom + 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Colors.black87, Colors.transparent],
        ),
      ),
      child: _navRow(isDark: true),
    );
  }

  Widget _buildReaderBottomNav() {
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 10, 20, MediaQuery.of(context).padding.bottom + 14),
      decoration: BoxDecoration(
        color: _ReaderColors.navBg,
        border: Border(
          top: BorderSide(color: _ReaderColors.navBorder, width: 1),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Banner ad at top of bottom nav
          const BannerAdWidget(),
          const SizedBox(height: 8),
          // Thin progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: _totalPages > 1 ? _currentPage / (_totalPages - 1) : 0,
              backgroundColor: _ReaderColors.divider,
              valueColor: const AlwaysStoppedAnimation<Color>(
                  _ReaderColors.accentWarm),
              minHeight: 3,
            ),
          ),
          const SizedBox(height: 12),
          _navRow(isDark: false),
        ],
      ),
    );
  }

  Widget _navRow({required bool isDark}) {
    final prevEnabled = _currentPage > 0;
    final nextEnabled = _currentPage < _totalPages - 1;
    final fgColor = isDark ? Colors.white : _ReaderColors.inkPrimary;
    final borderColor =
        isDark ? Colors.white24 : _ReaderColors.navBorder;
    final bgEnabled =
        isDark ? Colors.white12 : _ReaderColors.chapterBg;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Previous
        _navBtn(
          label: '← Nyuma',
          enabled: prevEnabled,
          fgColor: fgColor,
          borderColor: borderColor,
          bgColor: bgEnabled,
          onTap: () => _pageController.previousPage(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
          ),
        ),

        // Page dots
        _buildDots(isDark: isDark),

        // Next
        _navBtn(
          label: 'Mbele →',
          enabled: nextEnabled,
          fgColor: nextEnabled ? _ReaderColors.accentWarm : fgColor,
          borderColor:
              nextEnabled ? _ReaderColors.accentWarm.withValues(alpha: 0.4) : borderColor,
          bgColor: nextEnabled
              ? _ReaderColors.accentWarm.withValues(alpha: isDark ? 0.18 : 0.08)
              : bgEnabled,
          onTap: () => _pageController.nextPage(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
          ),
        ),
      ],
    );
  }

  Widget _navBtn({
    required String label,
    required bool enabled,
    required Color fgColor,
    required Color borderColor,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 150),
        opacity: enabled ? 1.0 : 0.3,
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: fgColor,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDots({required bool isDark}) {
    final visibleCount = _totalPages.clamp(0, 8);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(visibleCount, (i) {
        final isActive = i == _currentPage.clamp(0, visibleCount - 1);
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: isActive ? 20 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: isActive
                ? (isDark ? Colors.white : _ReaderColors.accentWarm)
                : (isDark
                    ? Colors.white30
                    : _ReaderColors.divider),
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }

  Widget _coverPlaceholder() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.auto_stories_rounded,
          color: Colors.white.withValues(alpha: 0.18),
          size: 96,
        ),
      ),
    );
  }
}
