import 'package:flutter/material.dart';
import '../models/bible_verse.dart';
import '../services/bible_service.dart';
import '../services/ad_service.dart';
import '../widgets/ad_banner_widget.dart';
import 'chapters_screen.dart';
import 'reading_screen.dart';

class BooksScreen extends StatelessWidget {
  final String testament;
  final List<String> books;
  final Map<String, List<int>> booksWithChapters;
  final List<BibleVerse> allVerses;

  const BooksScreen({
    super.key,
    required this.testament,
    required this.books,
    required this.booksWithChapters,
    required this.allVerses,
  });

  @override
  Widget build(BuildContext context) {
    final testamentColor = testament == 'Old Testament'
        ? Theme.of(context).primaryColor
        : Theme.of(context).primaryColor.withOpacity(0.8);

    return Scaffold(
      appBar: AppBar(
        title: Text(testament),
        backgroundColor: testamentColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF8F9FA),
        ),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: testamentColor.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    testament == 'Old Testament' ? Icons.book : Icons.auto_stories,
                    size: 48,
                    color: testamentColor,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    testament,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: testamentColor,
                    ),
                  ),
                  Text(
                    '${books.length} Books',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: testamentColor.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: books.length,
                itemBuilder: (context, index) {
                  final book = books[index];
                  final chapters = booksWithChapters[book] ?? [];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: testamentColor.withOpacity(0.15),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Card(
                      elevation: 0,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: testamentColor,
                            width: 2,
                          ),
                        ),
                        child: InkWell(
                          onTap: () {
                            AdService.showInterstitialAd(
                              onAdClosed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChaptersScreen(
                                      book: book,
                                      testament: testament,
                                      chapters: chapters,
                                      allVerses: allVerses,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          borderRadius: BorderRadius.circular(18),
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Row(
                              children: [
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: testamentColor,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: testamentColor.withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.book,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        book,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 17,
                                          color: testamentColor,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: testamentColor,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          '${chapters.length} Chapters',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: testamentColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    Icons.arrow_forward_ios,
                                    color: testamentColor,
                                    size: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const AdBannerWidget(),
          ],
        ),
      ),
    );
  }
}