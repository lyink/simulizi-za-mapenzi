import 'package:flutter/material.dart';
import '../../models/book.dart';
import '../../services/book_service.dart';
import '../../services/image_generation_service.dart';
import '../../services/notification_service.dart';
import '../../theme/app_theme.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.accent,
          indicatorWeight: 3,
          labelColor: AppTheme.accent,
          unselectedLabelColor: isDark ? AppTheme.textMuted : AppTheme.lightTextMuted,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          tabs: const [
            Tab(icon: Icon(Icons.auto_awesome_rounded), text: 'AI Generate'),
            Tab(icon: Icon(Icons.library_books_rounded), text: 'Manage Books'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _AIGenerateTab(),
          _ManageBooksTab(),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// AI Generate Tab
// ---------------------------------------------------------------------------
class _AIGenerateTab extends StatefulWidget {
  const _AIGenerateTab();

  @override
  State<_AIGenerateTab> createState() => _AIGenerateTabState();
}

class _AIGenerateTabState extends State<_AIGenerateTab> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _promptController = TextEditingController();
  final _storyTextController = TextEditingController();
  final _authorController = TextEditingController();
  final _synopsisController = TextEditingController();
  String _selectedCategory = 'Adventure';
  bool _isFeatured = false;
  bool _isGenerating = false;
  String _status = '';
  double _progress = 0.0;
  // true = user pastes their own story; false = AI generates from prompt
  bool _pasteMode = false;

  final List<String> _categories = [
    'Adventure',
    'Animals',
    'Fantasy',
    'Science',
    'Morals',
    'Nature',
    'Family',
  ];

  final BookService _bookService = BookService();
  final ImageGenerationService _imageService = ImageGenerationService();
  final NotificationService _notificationService = NotificationService();

  @override
  void dispose() {
    _titleController.dispose();
    _promptController.dispose();
    _storyTextController.dispose();
    _authorController.dispose();
    _synopsisController.dispose();
    super.dispose();
  }

  Future<void> _generateBook() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isGenerating = true;
      _progress = 0.0;
      _status = 'Starting book generation...';
    });

    try {
      final bookId = _bookService.generateId();
      final title = _titleController.text.trim();
      final author = _authorController.text.trim().isEmpty
          ? 'AI Generated'
          : _authorController.text.trim();

      final result = await _imageService.generateBookImages(
        storyTitle: title,
        bookId: bookId,
        storyPrompt: _pasteMode ? '' : _promptController.text.trim(),
        pastedStoryText:
            _pasteMode ? _storyTextController.text.trim() : null,
        onProgress: (status, progress) {
          if (mounted) {
            setState(() {
              _status = status;
              _progress = progress;
            });
          }
        },
      );

      if (mounted) {
        setState(() => _status = 'Saving book to database...');
      }

      // Build the complete book and save to Firestore in one call
      final finalBook = Book(
        id: bookId,
        title: title,
        author: author,
        synopsis: _synopsisController.text.trim(),
        coverImageUrl: result['coverUrl'] as String,
        pageImageUrls: List<String>.from(result['pageUrls'] as List),
        pageTexts: List<String>.from(result['pageTexts'] as List? ?? []),
        category: _selectedCategory,
        createdAt: DateTime.now(),
        isFeatured: _isFeatured,
      );

      await _bookService.setBook(finalBook).timeout(
        const Duration(seconds: 20),
        onTimeout: () => throw Exception(
            'Cannot reach Firebase. Images were generated but book could not be saved. Check your internet connection.'),
      );

      // Send notification to all subscribers
      await _notificationService.sendNewBookNotification(
        bookTitle: finalBook.title,
        bookSynopsis: finalBook.synopsis.isNotEmpty
            ? finalBook.synopsis
            : 'A new story is waiting for you!',
      );

      if (mounted) {
        setState(() {
          _isGenerating = false;
          _status = '';
          _progress = 0.0;
        });
        _clearForm();
        _showSuccess('Book "$title" generated and published!');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isGenerating = false;
          _status = '';
          _progress = 0.0;
        });
        _showError('Generation failed: ${e.toString()}');
      }
    }
  }

  void _clearForm() {
    _titleController.clear();
    _promptController.clear();
    _storyTextController.clear();
    _authorController.clear();
    _synopsisController.clear();
    setState(() {
      _selectedCategory = 'Adventure';
      _isFeatured = false;
      _pasteMode = false;
    });
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded,
                color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppTheme.success,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppTheme.accent,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 6),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? AppTheme.textLight : AppTheme.lightTextPrimary;
    final mutedColor = isDark ? AppTheme.textMuted : AppTheme.lightTextMuted;
    final inputBg = isDark ? AppTheme.cardBg : Colors.white;
    final cardColor = isDark ? AppTheme.cardBg : AppTheme.lightCardBg;
    final borderColor = isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.08);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card
            _sectionHeader(
              context: context,
              icon: Icons.auto_awesome_rounded,
              title: 'Book Publisher',
              subtitle: 'Paste your own story or let AI write one for you',
            ),
            const SizedBox(height: 24),

            // Mode toggle
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor),
              ),
              child: Row(
                children: [
                  _modeTab(
                    context: context,
                    label: 'Paste Story',
                    icon: Icons.content_paste_rounded,
                    active: _pasteMode,
                    onTap: () => setState(() => _pasteMode = true),
                  ),
                  _modeTab(
                    context: context,
                    label: 'AI Generate',
                    icon: Icons.auto_awesome_rounded,
                    active: !_pasteMode,
                    onTap: () => setState(() => _pasteMode = false),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // --- PASTE MODE: large text area ---
            if (_pasteMode) ...[
              _label(mutedColor, 'Story Text *'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _storyTextController,
                maxLines: 14,
                validator: (v) => _pasteMode && (v == null || v.trim().isEmpty)
                    ? 'Please paste your story text'
                    : null,
                style: TextStyle(
                    color: textColor, fontSize: 15, height: 1.6),
                decoration: InputDecoration(
                  hintText:
                      'Paste your full story here...\n\nYou can copy from anywhere — WhatsApp, documents, websites — and paste it here. The text will be automatically arranged into chapters and verses for reading.',
                  hintStyle: TextStyle(color: mutedColor),
                  alignLabelWithHint: true,
                  filled: true,
                  fillColor: inputBg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: borderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.accent, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.info_outline_rounded,
                      size: 13, color: mutedColor),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'AI will split your text into clean reading verses. Cover image is generated from the title.',
                      style: TextStyle(
                          color: mutedColor, fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],

            // --- AI MODE: prompt field ---
            if (!_pasteMode) ...[
              _label(mutedColor, 'Story Prompt *'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _promptController,
                maxLines: 5,
                validator: (v) => !_pasteMode &&
                        (v == null || v.trim().isEmpty)
                    ? 'Prompt is required'
                    : null,
                style: TextStyle(color: textColor, fontSize: 15, height: 1.6),
                decoration: InputDecoration(
                  hintText:
                      'Describe your story...\n\nExample: A brave lion cub named Simba goes on an adventure in the African savanna. He meets elephants, zebras, and learns about courage and friendship.',
                  hintStyle: TextStyle(color: mutedColor),
                  alignLabelWithHint: true,
                  filled: true,
                  fillColor: inputBg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: borderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.accent, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Title
            _label(mutedColor, 'Book Title *'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _titleController,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Title is required' : null,
              style: TextStyle(color: textColor, fontSize: 15),
              decoration: InputDecoration(
                hintText: 'e.g. The Brave Lion Cub',
                hintStyle: TextStyle(color: mutedColor),
                filled: true,
                fillColor: inputBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.accent, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Author (optional)
            _label(mutedColor, 'Author (optional)'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _authorController,
              style: TextStyle(color: textColor, fontSize: 15),
              decoration: InputDecoration(
                hintText: 'Leave blank for "AI Generated"',
                hintStyle: TextStyle(color: mutedColor),
                filled: true,
                fillColor: inputBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.accent, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Synopsis
            _label(mutedColor, 'Synopsis (optional)'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _synopsisController,
              maxLines: 3,
              style: TextStyle(color: textColor, fontSize: 15, height: 1.6),
              decoration: InputDecoration(
                hintText: 'Short description shown on book card',
                hintStyle: TextStyle(color: mutedColor),
                filled: true,
                fillColor: inputBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.accent, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Category
            _label(mutedColor, 'Category'),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: inputBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor),
              ),
              child: DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                dropdownColor: isDark ? AppTheme.cardBg : Colors.white,
                style: TextStyle(color: textColor, fontSize: 15),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: _categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedCategory = v!),
              ),
            ),
            const SizedBox(height: 20),

            // Featured toggle
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor),
              ),
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('Feature this book',
                    style: TextStyle(color: textColor, fontWeight: FontWeight.w600)),
                subtitle: Text('Show in Featured section on home',
                    style: TextStyle(color: mutedColor, fontSize: 12)),
                value: _isFeatured,
                activeTrackColor: AppTheme.accent,
                onChanged: (v) => setState(() => _isFeatured = v),
              ),
            ),
            const SizedBox(height: 32),

            // Generation progress
            if (_isGenerating) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: AppTheme.accent.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            value: _progress > 0 ? _progress : null,
                            color: AppTheme.accent,
                            strokeWidth: 2,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _status,
                            style: TextStyle(
                                color: textColor, fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: _progress,
                        backgroundColor: isDark ? AppTheme.primary : Colors.grey.shade200,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            AppTheme.accent),
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${(_progress * 100).toInt()}% complete',
                      style: TextStyle(
                          color: mutedColor, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Generate button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _isGenerating ? null : _generateBook,
                icon: _isGenerating
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.auto_awesome_rounded),
                label: Text(
                    _isGenerating ? 'Generating...' : 'Generate Book with AI'),
                style: ElevatedButton.styleFrom(
                  disabledBackgroundColor:
                      AppTheme.accent.withValues(alpha: 0.5),
                  disabledForegroundColor: Colors.white70,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                _pasteMode
                    ? 'Your story will be formatted into verses. Cover image generated from the title.'
                    : 'AI will write the story in Swahili. Cover image generated from the title.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader({
      required BuildContext context,
      required IconData icon,
      required String title,
      required String subtitle}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark ? AppTheme.cardBg : AppTheme.lightCardBg;
    final borderColor = isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.08);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppTheme.accent, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    )),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(Color color, String text) {
    return Text(text,
        style: TextStyle(
            color: color,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2));
  }

  Widget _modeTab({
    required BuildContext context,
    required String label,
    required IconData icon,
    required bool active,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final inactiveColor = isDark ? AppTheme.textMuted : AppTheme.lightTextMuted;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? AppTheme.accent : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 16,
                  color: active ? Colors.white : inactiveColor),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: active ? Colors.white : inactiveColor,
                  fontSize: 13,
                  fontWeight:
                      active ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Manage Books Tab
// ---------------------------------------------------------------------------
class _ManageBooksTab extends StatelessWidget {
  const _ManageBooksTab();

  @override
  Widget build(BuildContext context) {
    final bookService = BookService();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final mutedColor = isDark ? AppTheme.textMuted : AppTheme.lightTextMuted;

    return StreamBuilder<List<Book>>(
      stream: bookService.getBooks(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: AppTheme.accent));
        }

        final books = snapshot.data ?? [];

        if (books.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.library_books_rounded,
                    size: 72,
                    color: mutedColor.withValues(alpha: 0.5)),
                const SizedBox(height: 16),
                Text('No books yet',
                    style: TextStyle(color: mutedColor, fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text('Use the AI Generate tab to create your first book',
                    style: TextStyle(color: mutedColor, fontSize: 14)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: books.length,
          itemBuilder: (context, index) {
            final book = books[index];
            return _BookAdminTile(book: book, bookService: bookService);
          },
        );
      },
    );
  }
}

class _BookAdminTile extends StatelessWidget {
  final Book book;
  final BookService bookService;

  const _BookAdminTile({required this.book, required this.bookService});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark ? AppTheme.cardBg : AppTheme.lightCardBg;
    final textColor = isDark ? AppTheme.textLight : AppTheme.lightTextPrimary;
    final mutedColor = isDark ? AppTheme.textMuted : AppTheme.lightTextMuted;
    final borderColor = isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.08);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: isDark ? [] : [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: book.coverImageUrl.isNotEmpty
              ? Image.network(
                  book.coverImageUrl,
                  width: 56,
                  height: 72,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _coverPlaceholder(isDark),
                )
              : _coverPlaceholder(isDark),
        ),
        title: Text(
          book.title,
          style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w700,
              fontSize: 14),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${book.category} • ${book.pageImageUrls.length} pages',
              style: TextStyle(color: mutedColor, fontSize: 12),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.visibility_rounded,
                    size: 12, color: mutedColor),
                const SizedBox(width: 4),
                Text('${book.views} views',
                    style: TextStyle(
                        color: mutedColor, fontSize: 12)),
                if (book.isFeatured) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.gold.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('Featured',
                        style: TextStyle(
                            color: AppTheme.gold,
                            fontSize: 10,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          color: cardColor,
          icon: Icon(Icons.more_vert_rounded, color: mutedColor),
          onSelected: (value) async {
            if (value == 'delete') {
              _confirmDelete(context, book, bookService);
            } else if (value == 'feature') {
              await bookService.updateBook(
                  book.copyWith(isFeatured: !book.isFeatured));
            } else if (value == 'edit') {
              _showEditDialog(context, book, bookService);
            }
          },
          itemBuilder: (_) => [
            PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit_rounded, color: textColor, size: 18),
                  const SizedBox(width: 8),
                  Text('Edit', style: TextStyle(color: textColor)),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'feature',
              child: Row(
                children: [
                  Icon(
                    book.isFeatured
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    color: AppTheme.gold,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    book.isFeatured ? 'Unfeature' : 'Feature',
                    style: TextStyle(color: textColor),
                  ),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete_rounded, color: AppTheme.accent, size: 18),
                  SizedBox(width: 8),
                  Text('Delete',
                      style: TextStyle(color: AppTheme.accent)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _coverPlaceholder(bool isDark) {
    return Container(
      width: 56,
      height: 72,
      color: isDark ? AppTheme.secondary : AppTheme.lightSecondary,
      child: Icon(Icons.auto_stories_rounded,
          color: isDark ? AppTheme.textMuted : AppTheme.lightTextMuted, size: 24),
    );
  }

  void _showEditDialog(
      BuildContext context, Book book, BookService bookService) {
    showDialog(
      context: context,
      builder: (_) => _EditBookDialog(book: book, bookService: bookService),
    );
  }

  void _confirmDelete(
      BuildContext context, Book book, BookService bookService) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark ? AppTheme.cardBg : AppTheme.lightCardBg;
    final textColor = isDark ? AppTheme.textLight : AppTheme.lightTextPrimary;
    final mutedColor = isDark ? AppTheme.textMuted : AppTheme.lightTextMuted;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: cardColor,
        title: Text('Delete Book',
            style: TextStyle(color: textColor, fontWeight: FontWeight.w700)),
        content: Text(
          'Are you sure you want to delete "${book.title}"? This cannot be undone.',
          style: TextStyle(color: mutedColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: TextStyle(color: mutedColor)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await bookService.deleteBook(book.id);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accent),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Edit Book Dialog
// ---------------------------------------------------------------------------
class _EditBookDialog extends StatefulWidget {
  final Book book;
  final BookService bookService;

  const _EditBookDialog({required this.book, required this.bookService});

  @override
  State<_EditBookDialog> createState() => _EditBookDialogState();
}

class _EditBookDialogState extends State<_EditBookDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _authorController;
  late final TextEditingController _synopsisController;
  late final TextEditingController _storyTextController;
  late String _selectedCategory;
  late bool _isFeatured;

  final List<String> _categories = [
    'Adventure',
    'Animals',
    'Fantasy',
    'Science',
    'Morals',
    'Nature',
    'Family',
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.book.title);
    _authorController = TextEditingController(text: widget.book.author);
    _synopsisController = TextEditingController(text: widget.book.synopsis);
    // Join all verses with newlines for editing
    _storyTextController = TextEditingController(
      text: widget.book.pageTexts.join('\n\n'),
    );
    _selectedCategory = widget.book.category;
    _isFeatured = widget.book.isFeatured;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _synopsisController.dispose();
    _storyTextController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Title cannot be empty'),
          backgroundColor: AppTheme.accent,
        ),
      );
      return;
    }

    // Split the story text back into verses
    final storyText = _storyTextController.text.trim();
    final verses = storyText
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    final updatedBook = widget.book.copyWith(
      title: _titleController.text.trim(),
      author: _authorController.text.trim(),
      synopsis: _synopsisController.text.trim(),
      category: _selectedCategory,
      isFeatured: _isFeatured,
      pageTexts: verses,
    );

    try {
      await widget.bookService.updateBook(updatedBook);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Book updated successfully'),
            backgroundColor: AppTheme.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update book: ${e.toString()}'),
            backgroundColor: AppTheme.accent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark ? AppTheme.cardBg : AppTheme.lightCardBg;
    final inputBg = isDark ? AppTheme.primary : Colors.white;
    final textColor = isDark ? AppTheme.textLight : AppTheme.lightTextPrimary;
    final mutedColor = isDark ? AppTheme.textMuted : AppTheme.lightTextMuted;
    final borderColor = isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.08);

    return AlertDialog(
      backgroundColor: cardColor,
      title: Text('Edit Book',
          style: TextStyle(color: textColor, fontWeight: FontWeight.w700)),
      content: SingleChildScrollView(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Title',
                  style: TextStyle(
                      color: mutedColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextField(
                controller: _titleController,
                style: TextStyle(color: textColor, fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'Book title',
                  hintStyle: TextStyle(color: mutedColor),
                  filled: true,
                  fillColor: inputBg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: borderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.accent, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Author',
                  style: TextStyle(
                      color: mutedColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextField(
                controller: _authorController,
                style: TextStyle(color: textColor, fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'Author name',
                  hintStyle: TextStyle(color: mutedColor),
                  filled: true,
                  fillColor: inputBg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: borderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.accent, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Synopsis',
                  style: TextStyle(
                      color: mutedColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextField(
                controller: _synopsisController,
                maxLines: 3,
                style: TextStyle(color: textColor, fontSize: 15, height: 1.6),
                decoration: InputDecoration(
                  hintText: 'Short description',
                  hintStyle: TextStyle(color: mutedColor),
                  filled: true,
                  fillColor: inputBg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: borderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.accent, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Story Content',
                  style: TextStyle(
                      color: mutedColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextField(
                controller: _storyTextController,
                maxLines: 12,
                style: TextStyle(color: textColor, fontSize: 14, height: 1.6),
                decoration: InputDecoration(
                  hintText: 'Edit your story verses here...\n\nEach line will be a separate verse.',
                  hintStyle: TextStyle(color: mutedColor),
                  filled: true,
                  fillColor: inputBg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: borderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.accent, width: 2),
                  ),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 16),
              Text('Category',
                  style: TextStyle(
                      color: mutedColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: inputBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor),
                ),
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedCategory,
                  dropdownColor: isDark ? AppTheme.cardBg : Colors.white,
                  style: TextStyle(color: textColor, fontSize: 15),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: _categories
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedCategory = v!),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: inputBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor),
                ),
                child: SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Featured',
                      style: TextStyle(color: textColor, fontWeight: FontWeight.w600)),
                  subtitle: Text('Show in Featured section',
                      style: TextStyle(color: mutedColor, fontSize: 12)),
                  value: _isFeatured,
                  activeTrackColor: AppTheme.accent,
                  onChanged: (v) => setState(() => _isFeatured = v),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel',
              style: TextStyle(color: mutedColor)),
        ),
        ElevatedButton(
          onPressed: _saveChanges,
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accent),
          child: const Text('Save Changes'),
        ),
      ],
    );
  }
}
