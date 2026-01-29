import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:shimmer/shimmer.dart';
import '../models/bible_verse.dart';
import '../services/bible_service.dart';
import '../services/ad_service.dart';
import 'verse_detail_screen.dart';
import 'books_screen.dart';

class BibleScreen extends StatefulWidget {
  const BibleScreen({super.key});

  @override
  State<BibleScreen> createState() => _BibleScreenState();
}

class _BibleScreenState extends State<BibleScreen> with TickerProviderStateMixin {
  List<BibleVerse> _allVerses = [];
  List<BibleVerse> _filteredVerses = [];
  List<String> _books = [];
  Map<String, List<int>> _booksWithChapters = {};
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  String _selectedBook = '';
  int _selectedChapter = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  int _verseViewCount = 0;
  String _currentBibleName = '';
  bool _showBooksList = false;
  String _selectedTestament = '';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _loadBible();
    AdService.showAppOpenAd();
  }

  Future<void> _loadBible() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final bible = await BibleService.loadBible();
      setState(() {
        _allVerses = bible.verses;
        _filteredVerses = bible.verses.take(50).toList();
        _books = BibleService.getUniqueBooks(bible.verses);
        _booksWithChapters = BibleService.getBooksWithChapters(bible.verses);
        _currentBibleName = bible.metadata.name;
        _isLoading = false;
      });
      _animationController.forward();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Laden der Bibel: $e')),
        );
      }
    }
  }

  Future<void> _switchBible() async {
    final String? selectedBible = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Bibel auswählen'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: BibleService.availableBibles.length,
              itemBuilder: (context, index) {
                final bibleFile = BibleService.availableBibles[index];
                final bibleName = BibleService.bibleNames[bibleFile] ?? 'Unbekannt';
                final isSelected = bibleFile == BibleService.currentBibleFile;

                return ListTile(
                  title: Text(bibleName),
                  leading: Icon(
                    isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                    color: Theme.of(context).primaryColor,
                  ),
                  onTap: () {
                    Navigator.of(context).pop(bibleFile);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Abbrechen'),
            ),
          ],
        );
      },
    );

    if (selectedBible != null && selectedBible != BibleService.currentBibleFile) {
      setState(() {
        _isLoading = true;
      });
      await BibleService.switchBible(selectedBible);
      await _loadBible();
    }
  }

  void _searchVerses(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredVerses = _selectedBook.isEmpty
            ? _allVerses.take(50).toList()
            : BibleService.getVersesByBook(_allVerses, _selectedBook);
      });
    } else {
      final searchResults = BibleService.searchVerses(_allVerses, query);
      setState(() {
        _filteredVerses = searchResults;
      });
    }
  }

  void _filterByBook(String book) {
    setState(() {
      _selectedBook = book;
      _selectedChapter = 0;
      if (book.isEmpty) {
        _filteredVerses = _searchController.text.isEmpty
            ? _allVerses.take(50).toList()
            : BibleService.searchVerses(_allVerses, _searchController.text);
      } else {
        final bookVerses = BibleService.getVersesByBook(_allVerses, book);
        _filteredVerses = _searchController.text.isEmpty
            ? bookVerses
            : BibleService.searchVerses(bookVerses, _searchController.text);
      }
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _selectedBook = '';
      _selectedChapter = 0;
      _selectedTestament = '';
      _filteredVerses = [];
    });
  }

  Future<void> _showSearchDialog() async {
    final result = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        final searchController = TextEditingController(text: _searchController.text);
        return AlertDialog(
          title: const Text('Erweiterte Suche'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: searchController,
                decoration: const InputDecoration(
                  labelText: 'Suchbegriff eingeben',
                  hintText: 'z.B. Liebe, Glaube, Jesus...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              const Text(
                'Suchen Sie nach Wörtern, Begriffen oder Phrasen in der gesamten Bibel.',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Abbrechen'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(searchController.text),
              child: const Text('Suchen'),
            ),
          ],
        );
      },
    );

    if (result != null) {
      setState(() {
        _searchController.text = result;
        _selectedBook = '';
        _selectedChapter = 0;
      });
      _searchVerses(result);
    }
  }

  Future<void> _showBooksDialog() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.8,
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.library_books, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Bücher der Bibel',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: _buildBooksGrid(),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Schließen'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (result != null) {
      final book = result['book'] as String;
      final chapter = result['chapter'] as int?;

      setState(() {
        _selectedBook = book;
        _selectedChapter = chapter ?? 0;
        _searchController.clear();

        if (chapter != null && chapter > 0) {
          _filteredVerses = BibleService.getVersesByChapter(_allVerses, book, chapter);
        } else {
          _filteredVerses = BibleService.getVersesByBook(_allVerses, book);
        }
      });
    }
  }

  Widget _buildBooksGrid() {
    final oldTestamentBooks = _books.where((book) =>
      BibleService.getBookCategory(book) == 'Altes Testament').toList();
    final newTestamentBooks = _books.where((book) =>
      BibleService.getBookCategory(book) == 'Neues Testament').toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (oldTestamentBooks.isNotEmpty) ...[
            Text(
              'Altes Testament',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            _buildBookSection(oldTestamentBooks),
            const SizedBox(height: 16),
          ],
          if (newTestamentBooks.isNotEmpty) ...[
            Text(
              'Neues Testament',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            _buildBookSection(newTestamentBooks),
          ],
        ],
      ),
    );
  }

  Widget _buildBookSection(List<String> books) {
    return Column(
      children: books.map((book) {
        final chapters = _booksWithChapters[book] ?? [];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: Theme.of(context).primaryColor.withOpacity(0.2),
            ),
          ),
          child: ExpansionTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.book,
                color: Theme.of(context).primaryColor,
                size: 20,
              ),
            ),
            title: Text(
              book,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).primaryColor,
              ),
            ),
            subtitle: Text(
              '${chapters.length} Kapitel',
              style: TextStyle(
                color: Theme.of(context).primaryColor.withOpacity(0.7),
              ),
            ),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.02),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(15),
                    bottomRight: Radius.circular(15),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop({
                            'book': book,
                          });
                        },
                        icon: const Icon(Icons.auto_stories, size: 18),
                        label: Text('Ganzes Buch lesen'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Kapitel auswählen:',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).primaryColor,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: chapters.map((chapter) {
                        return InkWell(
                          onTap: () {
                            Navigator.of(context).pop({
                              'book': book,
                              'chapter': chapter,
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Theme.of(context).primaryColor.withOpacity(0.1),
                                  Theme.of(context).primaryColor.withOpacity(0.05),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Theme.of(context).primaryColor.withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              '$chapter',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
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

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).scaffoldBackgroundColor,
            Theme.of(context).primaryColor.withOpacity(0.05),
          ],
        ),
      ),
      child: Column(
        children: [
          _buildBibleHeader(),
          Expanded(
            child: _isLoading ? _buildLoadingState() : _buildBibleContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildBibleHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).primaryColor.withOpacity(0.1),
            Theme.of(context).primaryColor.withOpacity(0.05),
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.menu_book,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Deutsche Bibel',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    Text(
                      _currentBibleName.isNotEmpty ? _currentBibleName : 'Gottes Wort',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).primaryColor.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: IconButton(
                      onPressed: _showBooksDialog,
                      icon: const Icon(Icons.library_books),
                      tooltip: 'Bücher durchsuchen',
                      style: IconButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                        foregroundColor: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: IconButton(
                      onPressed: _showSearchDialog,
                      icon: const Icon(Icons.search),
                      tooltip: 'Suchen',
                      style: IconButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                        foregroundColor: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'switch':
                          _switchBible();
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'switch',
                        child: ListTile(
                          leading: Icon(Icons.swap_horiz),
                          title: Text('Bibel wechseln'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.more_vert),
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (_selectedBook.isNotEmpty || _searchController.text.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Theme.of(context).primaryColor.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.filter_list,
                    size: 16,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${_filteredVerses.length} Verse'
                      '${_selectedBook.isNotEmpty ? ' in $_selectedBook' : ''}'
                      '${_selectedChapter > 0 ? ' Kapitel $_selectedChapter' : ''}'
                      '${_searchController.text.isNotEmpty ? ' für "${_searchController.text}"' : ''}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (_selectedBook.isNotEmpty || _searchController.text.isNotEmpty)
                    GestureDetector(
                      onTap: _clearSearch,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.close,
                          size: 14,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }


  Widget _buildBibleContent() {
    return _buildTestamentsView();
  }

  Widget _buildChapterHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).primaryColor.withOpacity(0.1),
            Theme.of(context).primaryColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.book,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedBook,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                if (_selectedChapter > 0)
                  Text(
                    'Kapitel $_selectedChapter',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).primaryColor.withOpacity(0.8),
                    ),
                  )
                else
                  Text(
                    'Vollständiges Buch',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).primaryColor.withOpacity(0.7),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookText() {
    return RichText(
      text: TextSpan(
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          height: 1.8,
          letterSpacing: 0.5,
          fontSize: 16,
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
        children: _buildVerseSpans(),
      ),
    );
  }

  List<TextSpan> _buildVerseSpans() {
    List<TextSpan> spans = [];

    for (int i = 0; i < _filteredVerses.length; i++) {
      final verse = _filteredVerses[i];
      final isNewChapter = i == 0 || _filteredVerses[i - 1].chapter != verse.chapter;

      if (isNewChapter && _selectedBook.isNotEmpty && _selectedChapter == 0) {
        spans.add(
          TextSpan(
            text: '\n\nKapitel ${verse.chapter}\n\n',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
              height: 2.0,
            ),
          ),
        );
      }

      spans.add(
        TextSpan(
          children: [
            TextSpan(
              text: '${verse.verse} ',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
                height: 1.8,
              ),
            ),
            TextSpan(
              text: '${verse.text} ',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                height: 1.8,
                letterSpacing: 0.3,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () => _onVersePressed(verse),
            ),
          ],
        ),
      );
    }

    return spans;
  }

  Widget _buildTestamentsView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            'Wählen Sie ein Testament',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Entdecken Sie Gottes Wort im Alten und Neuen Testament',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).primaryColor.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          _buildTestamentCard(
            'Altes Testament',
            '39 Bücher',
            'Von 1. Mose bis Maleachi',
            Icons.book,
            Colors.deepOrange,
          ),
          const SizedBox(height: 20),
          _buildTestamentCard(
            'Neues Testament',
            '27 Bücher',
            'Von Matthäus bis Offenbarung',
            Icons.auto_stories,
            Colors.blue,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildTestamentCard(
    String title,
    String bookCount,
    String description,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        onTap: () => _onTestamentSelected(title),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.1),
                color.withOpacity(0.05),
              ],
            ),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: color.withOpacity(0.9),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        bookCount,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: color.withOpacity(0.8),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: color.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: color.withOpacity(0.6),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onTestamentSelected(String testament) {
    final oldTestamentBooks = _books.where((book) =>
      BibleService.getBookCategory(book) == 'Altes Testament').toList();
    final newTestamentBooks = _books.where((book) =>
      BibleService.getBookCategory(book) == 'Neues Testament').toList();

    final booksToShow = testament == 'Altes Testament'
        ? oldTestamentBooks
        : newTestamentBooks;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BooksScreen(
          testament: testament,
          books: booksToShow,
          booksWithChapters: _booksWithChapters,
          allVerses: _allVerses,
        ),
      ),
    );
  }

  Future<void> _showBooksForTestament(String testament) async {
    final oldTestamentBooks = _books.where((book) =>
      BibleService.getBookCategory(book) == 'Altes Testament').toList();
    final newTestamentBooks = _books.where((book) =>
      BibleService.getBookCategory(book) == 'Neues Testament').toList();

    final booksToShow = testament == 'Altes Testament'
        ? oldTestamentBooks
        : newTestamentBooks;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.8,
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: testament == 'Altes Testament'
                            ? Colors.deepOrange
                            : Colors.blue,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        testament == 'Altes Testament'
                            ? Icons.book
                            : Icons.auto_stories,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            testament,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          Text(
                            '${booksToShow.length} Bücher',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).primaryColor.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: _buildBooksGridForTestament(booksToShow),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Schließen'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (result != null) {
      final book = result['book'] as String;
      final chapter = result['chapter'] as int?;

      setState(() {
        _selectedBook = book;
        _selectedChapter = chapter ?? 0;
        _searchController.clear();

        if (chapter != null && chapter > 0) {
          _filteredVerses = BibleService.getVersesByChapter(_allVerses, book, chapter);
        } else {
          _filteredVerses = BibleService.getVersesByBook(_allVerses, book);
        }
      });
    }
  }

  Widget _buildBooksGridForTestament(List<String> books) {
    return SingleChildScrollView(
      child: Column(
        children: books.map((book) {
          final chapters = _booksWithChapters[book] ?? [];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: Theme.of(context).primaryColor.withOpacity(0.2),
              ),
            ),
            child: ExpansionTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.book,
                  color: Theme.of(context).primaryColor,
                  size: 20,
                ),
              ),
              title: Text(
                book,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              subtitle: Text(
                '${chapters.length} Kapitel',
                style: TextStyle(
                  color: Theme.of(context).primaryColor.withOpacity(0.7),
                ),
              ),
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.02),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(15),
                      bottomRight: Radius.circular(15),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).pop({
                              'book': book,
                            });
                          },
                          icon: const Icon(Icons.auto_stories, size: 18),
                          label: Text('Ganzes Buch lesen'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Kapitel auswählen:',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).primaryColor,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: chapters.map((chapter) {
                          return InkWell(
                            onTap: () {
                              Navigator.of(context).pop({
                                'book': book,
                                'chapter': chapter,
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Theme.of(context).primaryColor.withOpacity(0.1),
                                    Theme.of(context).primaryColor.withOpacity(0.05),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Theme.of(context).primaryColor.withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                '$chapter',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBackButton() {
    return Container(
      alignment: Alignment.centerLeft,
      child: ElevatedButton.icon(
        onPressed: () {
          setState(() {
            _selectedBook = '';
            _selectedChapter = 0;
            _selectedTestament = '';
            _filteredVerses = [];
            _searchController.clear();
          });
        },
        icon: const Icon(Icons.arrow_back, size: 18),
        label: const Text('Zurück zu Testamenten'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
          foregroundColor: Theme.of(context).primaryColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(
              Icons.menu_book,
              size: 64,
              color: Theme.of(context).primaryColor.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Keine Verse gefunden',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Wählen Sie ein Buch aus oder starten Sie eine Suche',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).primaryColor.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: _showBooksDialog,
                icon: const Icon(Icons.library_books),
                label: const Text('Bücher durchsuchen'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              OutlinedButton.icon(
                onPressed: _showSearchDialog,
                icon: const Icon(Icons.search),
                label: const Text('Suchen'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


  Widget _buildLoadingState() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 20),
        itemCount: 8,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Shimmer.fromColors(
                baseColor: Theme.of(context).colorScheme.surface,
                highlightColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 80,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          const Spacer(),
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        height: 16,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.7,
                        height: 16,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.5,
                        height: 12,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}