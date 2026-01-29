import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import '../../services/story_service.dart';
import '../../models/story.dart';
import '../../models/chapter.dart';
import '../../widgets/ad_banner_widget.dart';

class ImportStoriesScreen extends StatefulWidget {
  const ImportStoriesScreen({super.key});

  @override
  State<ImportStoriesScreen> createState() => _ImportStoriesScreenState();
}

class _ImportStoriesScreenState extends State<ImportStoriesScreen> {
  final StoryService _storyService = StoryService();
  final TextEditingController _jsonController = TextEditingController();
  bool _isImporting = false;
  String? _selectedFileName;
  List<Map<String, dynamic>>? _parsedStories;
  String? _errorMessage;
  int _selectedInputMethod = 0; // 0 = Paste, 1 = File

  @override
  void dispose() {
    _jsonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Import Stories from JSON'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildInstructionCard(),
                  const SizedBox(height: 24),
                  _buildInputMethodToggle(),
                  const SizedBox(height: 16),
                  if (_selectedInputMethod == 0)
                    _buildPasteSection()
                  else
                    _buildFilePickerSection(),
                  if (_parsedStories != null) ...[
                    const SizedBox(height: 24),
                    _buildStoriesPreview(),
                  ],
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 16),
                    _buildErrorCard(),
                  ],
                  const SizedBox(height: 24),
                  _buildImportButton(),
                ],
              ),
            ),
          ),
          const AdBannerWidget(),
        ],
      ),
    );
  }

  Widget _buildInstructionCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'JSON Format with Chapters & Verses',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Stories with chapters/verses. Add multiple chapters for series/continuations:',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: const Text(
                  '''[
  {
    "title": "Simulizi ya Mapenzi - Sehemu ya 1",
    "author": "Hassan Mwinyi",
    "category": "Romance",
    "coverImageUrl": "https://example.com/image.jpg",
    "synopsis": "Hadithi ya mapenzi kati ya mtu mwenye shauku...",
    "readingTimeMinutes": 20,
    "tags": ["love", "drama"],
    "isFeatured": false,
    "chapters": [
      {
        "number": 1,
        "title": "Sura ya Kwanza: Kuonana",
        "verses": [
          {
            "number": 1,
            "text": "Ilikuwa jioni ya siku ya Jumamosi..."
          },
          {
            "number": 2,
            "text": "Alipoingia kwenye mgahawa..."
          }
        ]
      },
      {
        "number": 2,
        "title": "Sura ya Pili: Mwanzo wa Upendo",
        "verses": [
          {
            "number": 1,
            "text": "Wiki iliyofuata, walionana tena..."
          },
          {
            "number": 2,
            "text": "Hadithi inaendelea..."
          }
        ]
      },
      {
        "number": 3,
        "title": "Sura ya Tatu: Kuendelea (Continuation)",
        "verses": [
          {
            "number": 1,
            "text": "Sasa upendo ulikuwa umekua..."
          }
        ]
      }
    ]
  }
]

TIP: Add more chapters (4, 5, 6...) for longer series!''',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber, size: 20, color: Colors.orange.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Required: title, author, category, synopsis, chapters (with verses). Optional: tags, isFeatured',
                      style: TextStyle(fontSize: 12, color: Colors.orange.shade900),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputMethodToggle() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _selectedInputMethod = 0;
                    _selectedFileName = null;
                    _errorMessage = null;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedInputMethod == 0
                      ? Theme.of(context).primaryColor
                      : Colors.grey.shade200,
                  foregroundColor:
                      _selectedInputMethod == 0 ? Colors.white : Colors.black87,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  elevation: _selectedInputMethod == 0 ? 2 : 0,
                ),
                icon: const Icon(Icons.content_paste),
                label: const Text('Paste JSON'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _selectedInputMethod = 1;
                    _jsonController.clear();
                    _errorMessage = null;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedInputMethod == 1
                      ? Theme.of(context).primaryColor
                      : Colors.grey.shade200,
                  foregroundColor:
                      _selectedInputMethod == 1 ? Colors.white : Colors.black87,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  elevation: _selectedInputMethod == 1 ? 2 : 0,
                ),
                icon: const Icon(Icons.folder_open),
                label: const Text('Upload File'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasteSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Paste JSON Content',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _jsonController,
              maxLines: 12,
              decoration: InputDecoration(
                hintText: 'Paste your JSON array here...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isImporting ? null : _parseFromTextField,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Parse & Preview'),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    _jsonController.clear();
                    setState(() {
                      _parsedStories = null;
                      _errorMessage = null;
                    });
                  },
                  icon: const Icon(Icons.clear),
                  tooltip: 'Clear',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilePickerSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Select JSON File',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isImporting ? null : _pickFile,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.folder_open),
              label: Text(_selectedFileName ?? 'Choose JSON File'),
            ),
            if (_selectedFileName != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'File selected: $_selectedFileName',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.green.shade900,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: _clearSelection,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStoriesPreview() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.preview, color: Colors.purple),
                const SizedBox(width: 8),
                Text(
                  'Stories Preview',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Found ${_parsedStories!.length} stories',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _parsedStories!.length,
              itemBuilder: (context, index) {
                final story = _parsedStories![index];
                final chapters = story['chapters'] as List? ?? [];
                final totalVerses = chapters.fold<int>(
                  0,
                  (sum, chapter) =>
                      sum + ((chapter['verses'] as List?)?.length ?? 0),
                );

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).primaryColor,
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(
                      story['title'] ?? 'Untitled',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'by ${story['author'] ?? 'Unknown'} • ${story['category'] ?? 'No category'}',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${chapters.length} chapters • $totalVerses verses',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    trailing: Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 20,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard() {
    return Card(
      elevation: 2,
      color: Colors.red.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Error',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _errorMessage!,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.red.shade800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImportButton() {
    final canImport = _parsedStories != null &&
                      _parsedStories!.isNotEmpty &&
                      !_isImporting;

    return ElevatedButton.icon(
      onPressed: canImport ? _importStories : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      icon: _isImporting
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : const Icon(Icons.upload),
      label: Text(
        _isImporting
            ? 'Importing stories...'
            : 'Import ${_parsedStories?.length ?? 0} Stories',
      ),
    );
  }

  void _parseFromTextField() {
    final jsonText = _jsonController.text.trim();
    if (jsonText.isEmpty) {
      setState(() {
        _errorMessage = 'Please paste JSON content';
        _parsedStories = null;
      });
      return;
    }

    setState(() {
      _selectedFileName = null;
    });

    _parseJson(jsonText);
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.single.bytes != null) {
        final jsonContent = utf8.decode(result.files.single.bytes!);
        setState(() {
          _selectedFileName = result.files.single.name;
          _errorMessage = null;
        });
        _parseJson(jsonContent);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to read file: $e';
        _parsedStories = null;
      });
    }
  }

  void _parseJson(String jsonContent) {
    try {
      final dynamic decoded = jsonDecode(jsonContent);

      if (decoded is! List) {
        setState(() {
          _errorMessage = 'JSON must be an array of story objects';
          _parsedStories = null;
        });
        return;
      }

      final List<Map<String, dynamic>> stories = [];
      for (var item in decoded) {
        if (item is Map<String, dynamic>) {
          // Validate required fields
          final requiredFields = [
            'title',
            'author',
            'category',
            'synopsis',
            'chapters'
          ];

          for (var field in requiredFields) {
            if (!item.containsKey(field) || item[field] == null) {
              setState(() {
                _errorMessage =
                    'Missing required field: $field in story "${item['title'] ?? 'unknown'}"';
                _parsedStories = null;
              });
              return;
            }
          }

          // Validate chapters structure
          if (item['chapters'] is! List || (item['chapters'] as List).isEmpty) {
            setState(() {
              _errorMessage =
                  'Story "${item['title']}" must have at least one chapter with verses';
              _parsedStories = null;
            });
            return;
          }

          // Validate each chapter has verses
          for (var chapter in item['chapters']) {
            if (chapter is! Map<String, dynamic>) {
              setState(() {
                _errorMessage = 'Invalid chapter format in story "${item['title']}"';
                _parsedStories = null;
              });
              return;
            }

            if (!chapter.containsKey('verses') ||
                chapter['verses'] is! List ||
                (chapter['verses'] as List).isEmpty) {
              setState(() {
                _errorMessage =
                    'Each chapter must have at least one verse in story "${item['title']}"';
                _parsedStories = null;
              });
              return;
            }
          }

          stories.add(item);
        }
      }

      if (stories.isEmpty) {
        setState(() {
          _errorMessage = 'No valid stories found in JSON';
          _parsedStories = null;
        });
        return;
      }

      setState(() {
        _parsedStories = stories;
        _errorMessage = null;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Invalid JSON format: $e';
        _parsedStories = null;
      });
    }
  }

  void _clearSelection() {
    setState(() {
      _selectedFileName = null;
      _parsedStories = null;
      _errorMessage = null;
    });
  }

  Future<void> _importStories() async {
    if (_parsedStories == null || _parsedStories!.isEmpty) return;

    setState(() {
      _isImporting = true;
      _errorMessage = null;
    });

    try {
      int successCount = 0;
      int failCount = 0;

      for (var storyData in _parsedStories!) {
        try {
          // Parse chapters
          final List<Chapter> chapters = [];
          if (storyData['chapters'] != null) {
            for (var chapterData in storyData['chapters']) {
              final List<Verse> verses = [];
              if (chapterData['verses'] != null) {
                for (var verseData in chapterData['verses']) {
                  verses.add(Verse(
                    number: verseData['number'] ?? 0,
                    text: verseData['text'] ?? '',
                  ));
                }
              }

              chapters.add(Chapter(
                number: chapterData['number'] ?? 0,
                title: chapterData['title'] ?? '',
                verses: verses,
              ));
            }
          }

          final story = Story(
            id: '', // Will be generated by Firestore
            title: storyData['title'],
            author: storyData['author'],
            content: '', // Empty since we're using chapters
            category: storyData['category'],
            coverImageUrl: storyData['coverImageUrl'] ?? '',
            synopsis: storyData['synopsis'],
            readingTimeMinutes: storyData['readingTimeMinutes'] is int
                ? storyData['readingTimeMinutes']
                : int.tryParse(storyData['readingTimeMinutes']?.toString() ?? '0') ?? 0,
            publishedDate: DateTime.now(),
            tags: storyData['tags'] != null
                ? List<String>.from(storyData['tags'])
                : [],
            isFeatured: storyData['isFeatured'] ?? false,
            views: 0,
            likes: 0,
            chapters: chapters,
          );

          final result = await _storyService.addStory(story);
          if (result != null) {
            successCount++;
          } else {
            failCount++;
          }
        } catch (e) {
          debugPrint('Error importing story: ${storyData['title']}: $e');
          failCount++;
        }
      }

      setState(() {
        _isImporting = false;
      });

      if (mounted) {
        _showResultDialog(successCount, failCount);
      }
    } catch (e) {
      setState(() {
        _isImporting = false;
        _errorMessage = 'Failed to import stories: $e';
      });
    }
  }

  void _showResultDialog(int successCount, int failCount) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                failCount == 0 ? Icons.check_circle : Icons.warning,
                color: failCount == 0 ? Colors.green : Colors.orange,
              ),
              const SizedBox(width: 8),
              const Text('Import Complete'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Successfully imported: $successCount stories'),
              if (failCount > 0) ...[
                const SizedBox(height: 8),
                Text(
                  'Failed to import: $failCount stories',
                  style: TextStyle(color: Colors.red.shade700),
                ),
              ],
            ],
          ),
          actions: [
            if (successCount > 0)
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Go back to admin panel
                },
                child: const Text('View Stories'),
              ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                if (successCount > 0) {
                  _clearSelection();
                  _jsonController.clear();
                }
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
