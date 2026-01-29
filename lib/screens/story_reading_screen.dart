import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/story.dart';
import '../models/chapter.dart';
import '../services/ad_service.dart';
import '../widgets/ad_banner_widget.dart';

class StoryReadingScreen extends StatefulWidget {
  final Story story;

  const StoryReadingScreen({
    super.key,
    required this.story,
  });

  @override
  State<StoryReadingScreen> createState() => _StoryReadingScreenState();
}

class _StoryReadingScreenState extends State<StoryReadingScreen> {
  int _currentChapterIndex = 0;
  final ScrollController _scrollController = ScrollController();
  int _chaptersReadCount = 0;

  @override
  void initState() {
    super.initState();
    // Show interstitial ad on screen open
    AdService.showInterstitialAd();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  bool get _hasChapters => widget.story.chapters.isNotEmpty;
  Chapter? get _currentChapter => _hasChapters ? widget.story.chapters[_currentChapterIndex] : null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.story.title),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_hasChapters && widget.story.chapters.length > 1)
            IconButton(
              icon: const Icon(Icons.list),
              onPressed: _showChapterList,
              tooltip: 'Chapters',
            ),
        ],
      ),
      body: Column(
        children: [
          // Chapter navigation
          if (_hasChapters && widget.story.chapters.length > 1) _buildChapterNavigation(),

          // Content
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
              ),
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.all(20),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).shadowColor.withOpacity(0.1),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_hasChapters) ...[
                        _buildChapterHeader(),
                        const SizedBox(height: 24),
                        _buildVerses(),
                      ] else ...[
                        _buildSimpleStoryHeader(),
                        const SizedBox(height: 24),
                        _buildSimpleContent(),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Ad banner
          const AdBannerWidget(),
        ],
      ),
    );
  }

  Widget _buildChapterNavigation() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Previous chapter
          IconButton(
            onPressed: _currentChapterIndex > 0
                ? () {
                    // Show interstitial ad when navigating to previous chapter
                    AdService.showInterstitialAd(
                      onAdClosed: () {
                        setState(() {
                          _currentChapterIndex--;
                        });
                        _scrollController.jumpTo(0);
                        HapticFeedback.lightImpact();
                      },
                    );
                  }
                : null,
            icon: Icon(
              Icons.chevron_left,
              color: _currentChapterIndex > 0
                  ? Theme.of(context).iconTheme.color
                  : Theme.of(context).disabledColor,
            ),
            tooltip: 'Previous Chapter',
          ),

          // Chapter indicator
          Expanded(
            child: TextButton(
              onPressed: _showChapterList,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Chapter ${_currentChapter!.number}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    _currentChapter!.title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          // Next chapter
          IconButton(
            onPressed: _currentChapterIndex < widget.story.chapters.length - 1
                ? () {
                    _navigateToNextChapter();
                  }
                : null,
            icon: Icon(
              Icons.chevron_right,
              color: _currentChapterIndex < widget.story.chapters.length - 1
                  ? Theme.of(context).iconTheme.color
                  : Theme.of(context).disabledColor,
            ),
            tooltip: 'Next Chapter',
          ),
        ],
      ),
    );
  }

  // For simple stories without chapters
  Widget _buildSimpleStoryHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor.withValues(alpha: 0.1),
            Theme.of(context).primaryColor.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  widget.story.category,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Theme.of(context).primaryColor,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.schedule, size: 14, color: Theme.of(context).primaryColor),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.story.readingTimeMinutes} min read',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.story.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'By ${widget.story.author}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleContent() {
    return SelectableText(
      widget.story.content,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
        height: 1.8,
        letterSpacing: 0.3,
      ),
    );
  }

  Widget _buildChapterHeader() {
    final chapter = _currentChapter!;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor.withValues(alpha: 0.1),
            Theme.of(context).primaryColor.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Chapter ${chapter.number}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Theme.of(context).primaryColor,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.article, size: 14, color: Theme.of(context).primaryColor),
                    const SizedBox(width: 4),
                    Text(
                      '${chapter.verses.length} verses',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            chapter.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerses() {
    final textTheme = Theme.of(context).textTheme;
    final textColor = textTheme.bodyLarge?.color ?? Colors.black87;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _currentChapter!.verses.map((verse) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '${verse.number}. ',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18 * (textTheme.bodyLarge?.fontSize ?? 16) / 16,
                  ),
                ),
                TextSpan(
                  text: verse.text,
                  style: TextStyle(
                    color: textColor,
                    fontSize: textTheme.bodyLarge?.fontSize ?? 16,
                    height: 1.6,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  void _navigateToNextChapter() {
    _chaptersReadCount++;

    // Show rewarded ad every 3 chapters
    if (_chaptersReadCount % 3 == 0 && AdService.isRewardedAdReady) {
      AdService.showRewardedAd(
        onUserEarnedReward: (ad, reward) {
          debugPrint('User earned reward: ${reward.amount} ${reward.type}');
        },
        onAdClosed: () {
          setState(() {
            _currentChapterIndex++;
          });
          _scrollController.jumpTo(0);
          HapticFeedback.lightImpact();
        },
      );
    } else {
      // Show interstitial ad on every chapter navigation
      AdService.showInterstitialAd(
        onAdClosed: () {
          setState(() {
            _currentChapterIndex++;
          });
          _scrollController.jumpTo(0);
          HapticFeedback.lightImpact();
        },
      );
    }
  }

  void _showChapterList() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(Icons.list, color: Theme.of(context).primaryColor),
                  const SizedBox(width: 12),
                  Text(
                    'Chapters',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: widget.story.chapters.length,
                  itemBuilder: (context, index) {
                    final chapter = widget.story.chapters[index];
                    final isSelected = index == _currentChapterIndex;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      color: isSelected
                          ? Theme.of(context).primaryColor.withOpacity(0.1)
                          : null,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isSelected
                              ? Theme.of(context).primaryColor
                              : Colors.grey.shade300,
                          child: Text(
                            '${chapter.number}',
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.grey.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          chapter.title,
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? Theme.of(context).primaryColor : null,
                          ),
                        ),
                        subtitle: Text('${chapter.verses.length} verses'),
                        trailing: isSelected
                            ? Icon(Icons.check_circle, color: Theme.of(context).primaryColor)
                            : const Icon(Icons.chevron_right),
                        onTap: () {
                          // Show interstitial ad when selecting a chapter from the list
                          AdService.showInterstitialAd(
                            onAdClosed: () {
                              setState(() {
                                _currentChapterIndex = index;
                              });
                              _scrollController.jumpTo(0);
                              Navigator.pop(context);
                              HapticFeedback.mediumImpact();
                            },
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
