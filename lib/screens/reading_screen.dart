import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../models/bible_verse.dart';
import '../services/ad_service.dart';
import '../widgets/ad_banner_widget.dart';
import 'verse_detail_screen.dart';

class ReadingScreen extends StatefulWidget {
  final String book;
  final int chapter;
  final String testament;
  final List<BibleVerse> verses;

  const ReadingScreen({
    super.key,
    required this.book,
    required this.chapter,
    required this.testament,
    required this.verses,
  });

  @override
  State<ReadingScreen> createState() => _ReadingScreenState();
}

class _ReadingScreenState extends State<ReadingScreen> {
  int _verseViewCount = 0;

  @override
  Widget build(BuildContext context) {
    final testamentColor = widget.testament == 'Old Testament'
        ? Theme.of(context).primaryColor
        : Theme.of(context).primaryColor.withOpacity(0.8);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chapter > 0
            ? '${widget.book} ${widget.chapter}'
            : widget.book),
        backgroundColor: testamentColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF8F9FA),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: testamentColor.withOpacity(0.3),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: testamentColor.withOpacity(0.1),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildChapterHeader(testamentColor),
                      const SizedBox(height: 20),
                      _buildBookText(),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const AdBannerWidget(),
        ],
      ),
    );
  }

  Widget _buildChapterHeader(Color testamentColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: testamentColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: testamentColor,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: testamentColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.book,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.book,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: testamentColor,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                if (widget.chapter > 0)
                  Text(
                    'Chapter ${widget.chapter}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w600,
                    ),
                  )
                else
                  Text(
                    'Full Book',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: testamentColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${widget.verses.length} Verses',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookText() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _buildVerseParagraphs(),
      ),
    );
  }

  List<Widget> _buildVerseParagraphs() {
    List<Widget> paragraphs = [];

    // Group verses by chapter for better organization
    Map<int, List<BibleVerse>> chapterGroups = {};
    for (var verse in widget.verses) {
      chapterGroups[verse.chapter] ??= [];
      chapterGroups[verse.chapter]!.add(verse);
    }

    for (var entry in chapterGroups.entries) {
      final chapterNumber = entry.key;
      final chapterVerses = entry.value;

      // Add chapter header for full book reading
      if (widget.chapter == 0 && chapterGroups.length > 1) {
        paragraphs.add(
          Container(
            margin: const EdgeInsets.only(top: 24, bottom: 16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).primaryColor.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$chapterNumber',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Chapter $chapterNumber',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      // Create paragraph with verses
      paragraphs.add(_buildChapterParagraph(chapterVerses));
    }

    return paragraphs;
  }

  Widget _buildChapterParagraph(List<BibleVerse> verses) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Create paragraphs by grouping verses
          ..._buildParagraphsFromVerses(verses),
        ],
      ),
    );
  }

  List<Widget> _buildParagraphsFromVerses(List<BibleVerse> verses) {
    List<Widget> paragraphs = [];
    List<BibleVerse> currentParagraph = [];

    for (int i = 0; i < verses.length; i++) {
      currentParagraph.add(verses[i]);

      // Create a new paragraph every 4-6 verses or at natural breaks
      bool shouldBreak = currentParagraph.length >= 4 &&
                        (i == verses.length - 1 ||
                         currentParagraph.length >= 6 ||
                         _isNaturalBreak(verses[i], i < verses.length - 1 ? verses[i + 1] : null));

      if (shouldBreak) {
        paragraphs.add(_buildSingleParagraph(currentParagraph));
        currentParagraph = [];
      }
    }

    // Add any remaining verses as a final paragraph
    if (currentParagraph.isNotEmpty) {
      paragraphs.add(_buildSingleParagraph(currentParagraph));
    }

    return paragraphs;
  }

  bool _isNaturalBreak(BibleVerse current, BibleVerse? next) {
    if (next == null) return true;

    // Check for natural paragraph breaks in text
    String text = current.text.toLowerCase();
    return text.endsWith('.') || text.endsWith('!') || text.endsWith('?') ||
           text.contains('said') || text.contains('then') || text.contains('and it came to pass');
  }

  Widget _buildSingleParagraph(List<BibleVerse> verses) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: RichText(
        textAlign: TextAlign.justify,
        text: TextSpan(
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            height: 1.9,
            letterSpacing: 0.4,
            fontSize: 18,
            color: Colors.grey[800],
            fontWeight: FontWeight.w400,
          ),
          children: verses.asMap().entries.map((entry) {
            int index = entry.key;
            BibleVerse verse = entry.value;
            bool isLastInParagraph = index == verses.length - 1;

            return TextSpan(
              children: [
                // Verse number with improved styling
                WidgetSpan(
                  alignment: PlaceholderAlignment.baseline,
                  baseline: TextBaseline.alphabetic,
                  child: GestureDetector(
                    onTap: () => _onVersePressed(verse),
                    child: Container(
                      margin: const EdgeInsets.only(right: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: Theme.of(context).primaryColor.withOpacity(0.3),
                          width: 0.5,
                        ),
                      ),
                      child: Text(
                        '${verse.verse}',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ),
                ),
                // Verse text with improved paragraph formatting
                TextSpan(
                  text: '${verse.text}${isLastInParagraph ? '' : ' '}',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    height: 1.9,
                    letterSpacing: 0.4,
                    fontSize: 18,
                    color: Colors.grey[800],
                    fontWeight: FontWeight.w400,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () => _onVersePressed(verse),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  void _onVersePressed(BibleVerse verse) async {
    _verseViewCount++;

    if (_verseViewCount % 3 == 0) {
      AdService.showInterstitialAd(
        onAdClosed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VerseDetailScreen(verse: verse),
            ),
          );
        },
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VerseDetailScreen(verse: verse),
        ),
      );
    }
  }
}