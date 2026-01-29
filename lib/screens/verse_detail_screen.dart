import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import '../models/bible_verse.dart';
import '../services/bible_service.dart';
import '../widgets/ad_banner_widget.dart';

class VerseDetailScreen extends StatefulWidget {
  final BibleVerse verse;

  const VerseDetailScreen({
    super.key,
    required this.verse,
  });

  @override
  State<VerseDetailScreen> createState() => _VerseDetailScreenState();
}

class _VerseDetailScreenState extends State<VerseDetailScreen> {
  List<BibleVerse> _chapterVerses = [];
  bool _isLoadingContext = false;

  @override
  void initState() {
    super.initState();
    _loadChapterContext();
  }

  Future<void> _loadChapterContext() async {
    setState(() {
      _isLoadingContext = true;
    });

    try {
      final bible = await BibleService.loadBible();
      final chapterVerses = BibleService.getVersesByChapter(
        bible.verses,
        widget.verse.bookName,
        widget.verse.chapter,
      );

      setState(() {
        _chapterVerses = chapterVerses;
        _isLoadingContext = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingContext = false;
      });
    }
  }

  void _shareVerse() {
    final text = '${widget.verse.fullReference}\n\n"${widget.verse.text}"\n\n- ${BibleService.currentBibleName}';
    Clipboard.setData(ClipboardData(text: text));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Verse copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.verse.fullReference),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareVerse,
            tooltip: 'Share verse',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoadingContext
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: _buildMainCard(),
                ),
          ),
          _buildNavigationControls(),
          const AdBannerWidget(),
        ],
      ),
    );
  }

  Widget _buildMainCard() {
    return Column(
      children: [
        // Main verse header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.format_quote,
                    color: Theme.of(context).primaryColor,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.verse.fullReference,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                widget.verse.text,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: 18,
                  height: 1.6,
                  letterSpacing: 0.3,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        // Verses container - main focus
        if (_chapterVerses.isNotEmpty)
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Chapter header
                  Row(
                    children: [
                      Icon(
                        Icons.book_outlined,
                        color: Theme.of(context).primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${widget.verse.bookName} ${widget.verse.chapter}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${_chapterVerses.length} Verse',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Verses content
                  Expanded(
                    child: SingleChildScrollView(
                      child: _buildVerseContent(),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildVerseContent() {
    return RichText(
      textAlign: TextAlign.justify,
      text: TextSpan(
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          height: 1.8,
          letterSpacing: 0.4,
          fontSize: 17,
          color: Colors.grey[800],
        ),
        children: _chapterVerses.map((verse) {
          final isCurrentVerse = verse.verse == widget.verse.verse;

          return TextSpan(
            children: [
              WidgetSpan(
                alignment: PlaceholderAlignment.baseline,
                baseline: TextBaseline.alphabetic,
                child: GestureDetector(
                  onTap: () => _onVersePressed(verse),
                  child: Container(
                    margin: const EdgeInsets.only(right: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isCurrentVerse
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).primaryColor.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: isCurrentVerse ? [
                        BoxShadow(
                          color: Theme.of(context).primaryColor.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ] : [],
                    ),
                    child: Text(
                      '${verse.verse}',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                        height: 1.2,
                      ),
                    ),
                  ),
                ),
              ),
              TextSpan(
                text: '${verse.text}${verse == _chapterVerses.last ? '' : ' '}',
                style: TextStyle(
                  height: 1.8,
                  letterSpacing: 0.4,
                  fontSize: 17,
                  color: isCurrentVerse ? Colors.grey[900] : Colors.grey[700],
                  fontWeight: isCurrentVerse ? FontWeight.w600 : FontWeight.w400,
                  backgroundColor: isCurrentVerse
                      ? Theme.of(context).primaryColor.withOpacity(0.1)
                      : null,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () => _onVersePressed(verse),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNavigationControls() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _canGoPrevious() ? _goToPreviousChapter : null,
              icon: const Icon(Icons.arrow_back_ios, size: 18),
              label: const Text('Previous'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                foregroundColor: Theme.of(context).primaryColor,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _canGoNext() ? _goToNextChapter : null,
              icon: const Icon(Icons.arrow_forward_ios, size: 18),
              label: const Text('Next'),
              iconAlignment: IconAlignment.end,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _canGoPrevious() {
    return widget.verse.chapter > 1;
  }

  bool _canGoNext() {
    // This is a simple check - you might want to implement proper book/chapter limits
    return true;
  }

  void _goToPreviousChapter() {
    if (_canGoPrevious()) {
      _navigateToChapter(widget.verse.chapter - 1);
    }
  }

  void _goToNextChapter() {
    if (_canGoNext()) {
      _navigateToChapter(widget.verse.chapter + 1);
    }
  }

  void _navigateToChapter(int newChapter) async {
    try {
      final bible = await BibleService.loadBible();
      final newChapterVerses = BibleService.getVersesByChapter(
        bible.verses,
        widget.verse.bookName,
        newChapter,
      );

      if (newChapterVerses.isNotEmpty) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => VerseDetailScreen(
              verse: newChapterVerses.first,
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Chapter $newChapter not found'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _onVersePressed(BibleVerse verse) async {
    if (verse.verse != widget.verse.verse) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => VerseDetailScreen(verse: verse),
        ),
      );
    }
  }
}