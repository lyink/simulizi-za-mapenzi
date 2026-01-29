import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/bible_verse.dart';

class BibleService {
  static Bible? _bible;
  static bool _isLoaded = false;
  static String _currentBibleFile = 'assets/DE-German/luther_1912.json';

  static List<String> get availableBibles => [
    'assets/DE-German/deutsche_bibel_unified.json',
    'assets/DE-German/luther_1912.json',
    'assets/DE-German/luther.json',
    'assets/DE-German/elberfelder_1871.json',
    'assets/DE-German/elberfelder_1905.json',
    'assets/DE-German/schlachter.json',
  ];

  static Map<String, String> get bibleNames => {
    'assets/DE-German/deutsche_bibel_unified.json': 'Deutsche Bibel (Vereint)',
    'assets/DE-German/luther_1912.json': 'Luther Bibel (1912)',
    'assets/DE-German/luther.json': 'Luther Bibel (1545)',
    'assets/DE-German/elberfelder_1871.json': 'Elberfelder (1871)',
    'assets/DE-German/elberfelder_1905.json': 'Elberfelder (1905)',
    'assets/DE-German/schlachter.json': 'Schlachter Bibel',
  };

  static Future<Bible> loadBible({String? bibleFile}) async {
    final fileToLoad = bibleFile ?? _currentBibleFile;

    if (_isLoaded && _bible != null && fileToLoad == _currentBibleFile) {
      return _bible!;
    }

    try {
      final String jsonString = await rootBundle.loadString(fileToLoad);
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      _bible = Bible.fromJson(jsonData);
      _currentBibleFile = fileToLoad;
      _isLoaded = true;

      return _bible!;
    } catch (e) {
      print('Error loading Bible: $e');
      return Bible(
        metadata: BibleMetadata(
          name: 'Error',
          shortname: 'Error',
          module: 'error',
          year: '0',
          description: 'Failed to load Bible',
          lang: 'German',
          langShort: 'de',
          copyright: 0,
          copyrightStatement: 'Error loading Bible',
        ),
        verses: [],
      );
    }
  }

  static Future<void> switchBible(String bibleFile) async {
    _isLoaded = false;
    _bible = null;
    await loadBible(bibleFile: bibleFile);
  }

  static List<BibleVerse> searchVerses(List<BibleVerse> verses, String query) {
    if (query.isEmpty) return verses;

    final lowerQuery = query.toLowerCase();
    return verses.where((verse) {
      return verse.text.toLowerCase().contains(lowerQuery) ||
             verse.bookName.toLowerCase().contains(lowerQuery) ||
             verse.reference.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  static List<BibleVerse> getVersesByBook(List<BibleVerse> verses, String bookName) {
    return verses.where((verse) =>
        verse.bookName.toLowerCase() == bookName.toLowerCase()
    ).toList();
  }

  static List<BibleVerse> getVersesByChapter(List<BibleVerse> verses, String bookName, int chapter) {
    return verses.where((verse) =>
        verse.bookName.toLowerCase() == bookName.toLowerCase() &&
        verse.chapter == chapter
    ).toList();
  }

  static List<String> getUniqueBooks(List<BibleVerse> verses) {
    final Set<String> books = {};
    for (final verse in verses) {
      books.add(verse.bookName);
    }
    return books.toList()..sort();
  }

  static List<int> getChaptersForBook(List<BibleVerse> verses, String bookName) {
    final Set<int> chapters = {};
    for (final verse in verses.where((v) => v.bookName.toLowerCase() == bookName.toLowerCase())) {
      chapters.add(verse.chapter);
    }
    return chapters.toList()..sort();
  }

  static Map<String, List<int>> getBooksWithChapters(List<BibleVerse> verses) {
    final Map<String, Set<int>> booksWithChapters = {};

    for (final verse in verses) {
      if (!booksWithChapters.containsKey(verse.bookName)) {
        booksWithChapters[verse.bookName] = <int>{};
      }
      booksWithChapters[verse.bookName]!.add(verse.chapter);
    }

    final result = <String, List<int>>{};
    booksWithChapters.forEach((book, chapters) {
      result[book] = chapters.toList()..sort();
    });

    return result;
  }

  static List<BibleVerse> getRandomVerses(List<BibleVerse> verses, int count) {
    if (verses.length <= count) return verses;

    final shuffled = List<BibleVerse>.from(verses)..shuffle();
    return shuffled.take(count).toList();
  }

  static String getBookCategory(String bookName) {
    const oldTestament = [
      '1 Mose', '2 Mose', '3 Mose', '4 Mose', '5 Mose',
      'Josua', 'Richter', 'Rut', '1 Samuel', '2 Samuel',
      '1 Koenige', '2 Koenige', '1 Chronik', '2 Chronik',
      'Esra', 'Nehemia', 'Ester', 'Job', 'Psalm', 'Sprueche',
      'Prediger', 'Hohelied', 'Jesaja', 'Jeremia', 'Klagelieder',
      'Hesekiel', 'Daniel', 'Hosea', 'Joel', 'Amos', 'Obadja',
      'Jona', 'Mica', 'Nahum', 'Habakuk', 'Zephanja', 'Haggai',
      'Sacharja', 'Maleachi'
    ];

    return oldTestament.contains(bookName) ? 'Altes Testament' : 'Neues Testament';
  }

  static String get currentBibleName => bibleNames[_currentBibleFile] ?? 'Unknown Bible';
  static String get currentBibleFile => _currentBibleFile;
}