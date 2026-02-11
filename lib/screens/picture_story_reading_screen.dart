import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/story.dart';
import '../models/chapter.dart';
import '../services/ad_service.dart';

/// Picture book style reading screen
/// Each verse is displayed as a full-screen image with text overlay
/// Perfect for children's storytelling experience
class PictureStoryReadingScreen extends StatefulWidget {
  final Story story;
  final bool startWithChapters;

  const PictureStoryReadingScreen({
    super.key,
    required this.story,
    this.startWithChapters = true,
  });

  @override
  State<PictureStoryReadingScreen> createState() =>
      _PictureStoryReadingScreenState();
}

class _PictureStoryReadingScreenState extends State<PictureStoryReadingScreen> {
  late PageController _pageController;
  int _currentPage = 0;
  bool _showText = true;
  List<StoryPage> _pages = [];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _buildPages();
    AdService.showInterstitialAd();

    // Set immersive mode
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }

  @override
  void dispose() {
    _pageController.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  /// Build list of pages from story chapters/verses
  void _buildPages() {
    _pages = [];

    if (widget.story.hasChapters) {
      // Add cover page
      _pages.add(StoryPage(
        type: PageType.cover,
        imageUrl: widget.story.coverImageUrl,
        title: widget.story.title,
        subtitle: 'By ${widget.story.author}',
      ));

      // Add chapter pages
      for (var chapter in widget.story.chapters) {
        // Chapter title page
        _pages.add(StoryPage(
          type: PageType.chapterTitle,
          imageUrl: chapter.imageUrl ?? widget.story.coverImageUrl,
          title: chapter.title,
          subtitle: 'Chapter ${chapter.number}',
        ));

        // Verse pages
        for (var verse in chapter.verses) {
          _pages.add(StoryPage(
            type: PageType.verse,
            imageUrl: chapter.imageUrl ?? widget.story.coverImageUrl,
            text: verse.text,
            verseNumber: verse.number,
            chapterNumber: chapter.number,
          ));
        }
      }

      // Add end page
      _pages.add(StoryPage(
        type: PageType.end,
        imageUrl: widget.story.coverImageUrl,
        title: 'The End',
        subtitle: 'Mwisho',
      ));
    } else {
      // Simple story - split content into pages
      _pages.add(StoryPage(
        type: PageType.cover,
        imageUrl: widget.story.coverImageUrl,
        title: widget.story.title,
        subtitle: 'By ${widget.story.author}',
      ));

      // Split content by paragraphs
      final paragraphs = widget.story.content.split('\n\n');
      for (var i = 0; i < paragraphs.length; i++) {
        if (paragraphs[i].trim().isNotEmpty) {
          _pages.add(StoryPage(
            type: PageType.verse,
            imageUrl: widget.story.coverImageUrl,
            text: paragraphs[i].trim(),
            verseNumber: i + 1,
          ));
        }
      }

      _pages.add(StoryPage(
        type: PageType.end,
        imageUrl: widget.story.coverImageUrl,
        title: 'The End',
        subtitle: 'Mwisho',
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Page viewer
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              return _buildPage(_pages[index]);
            },
          ),

          // Top bar with controls
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildTopBar(),
          ),

          // Bottom progress indicator
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomBar(),
          ),

          // Navigation hints (for first page)
          if (_currentPage == 0) _buildNavigationHints(),
        ],
      ),
    );
  }

  Widget _buildPage(StoryPage page) {
    return GestureDetector(
      onTap: () {
        if (page.type == PageType.verse) {
          setState(() {
            _showText = !_showText;
          });
        }
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          Image.network(
            page.imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey[900],
                child: Center(
                  child: Icon(
                    Icons.image_not_supported,
                    size: 64,
                    color: Colors.grey[700],
                  ),
                ),
              );
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                color: Colors.grey[900],
                child: Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                    color: Colors.white,
                  ),
                ),
              );
            },
          ),

          // Gradient overlay for better text readability
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.3),
                  Colors.transparent,
                  Colors.black.withOpacity(0.7),
                ],
                stops: const [0.0, 0.3, 1.0],
              ),
            ),
          ),

          // Content based on page type
          if (page.type == PageType.cover) _buildCoverContent(page),
          if (page.type == PageType.chapterTitle) _buildChapterTitleContent(page),
          if (page.type == PageType.verse && _showText) _buildVerseContent(page),
          if (page.type == PageType.end) _buildEndContent(page),
        ],
      ),
    );
  }

  Widget _buildCoverContent(StoryPage page) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Text(
                  page.title ?? '',
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        offset: Offset(2, 2),
                        blurRadius: 4,
                        color: Colors.black,
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  page.subtitle ?? '',
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.white70,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 32,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Swipe to begin',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChapterTitleContent(StoryPage page) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(32),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              page.subtitle ?? '',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              page.title ?? '',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerseContent(StoryPage page) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.75),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Theme.of(context).primaryColor.withOpacity(0.5),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (page.chapterNumber != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Chapter ${page.chapterNumber} • Verse ${page.verseNumber}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Text(
              page.text ?? '',
              style: const TextStyle(
                fontSize: 20,
                color: Colors.white,
                height: 1.6,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                'Tap to hide text • Swipe for next',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.6),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEndContent(StoryPage page) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_stories,
              size: 80,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            page.title ?? '',
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  offset: Offset(2, 2),
                  blurRadius: 4,
                  color: Colors.black,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            page.subtitle ?? '',
            style: const TextStyle(
              fontSize: 32,
              color: Colors.white70,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 48),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.home),
            label: const Text('Back to Stories'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              textStyle: const TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.only(top: 40, left: 16, right: 16, bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.7),
            Colors.transparent,
          ],
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              widget.story.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: Icon(
              _showText ? Icons.visibility : Icons.visibility_off,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _showText = !_showText;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    final progress = (_currentPage + 1) / _pages.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.black.withOpacity(0.7),
            Colors.transparent,
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: Colors.white.withOpacity(0.3),
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Page counter
            Text(
              '${_currentPage + 1} / ${_pages.length}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationHints() {
    return Positioned.fill(
      child: IgnorePointer(
        child: Row(
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(left: 20, top: 200, bottom: 200),
                alignment: Alignment.centerLeft,
                child: AnimatedOpacity(
                  opacity: 0.5,
                  duration: const Duration(seconds: 2),
                  child: const Icon(
                    Icons.arrow_back_ios,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(right: 20, top: 200, bottom: 200),
                alignment: Alignment.centerRight,
                child: AnimatedOpacity(
                  opacity: 0.5,
                  duration: const Duration(seconds: 2),
                  child: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Page type enum
enum PageType {
  cover,
  chapterTitle,
  verse,
  end,
}

/// Story page model
class StoryPage {
  final PageType type;
  final String imageUrl;
  final String? title;
  final String? subtitle;
  final String? text;
  final int? verseNumber;
  final int? chapterNumber;

  StoryPage({
    required this.type,
    required this.imageUrl,
    this.title,
    this.subtitle,
    this.text,
    this.verseNumber,
    this.chapterNumber,
  });
}
