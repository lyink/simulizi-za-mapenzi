import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/story.dart';
import '../../services/story_service.dart';
import '../../services/category_service.dart';
import '../../services/instagram_image_service.dart';
import '../../widgets/ad_banner_widget.dart';

class AddEditStoryScreen extends StatefulWidget {
  final Story? story;

  const AddEditStoryScreen({super.key, this.story});

  @override
  State<AddEditStoryScreen> createState() => _AddEditStoryScreenState();
}

class _AddEditStoryScreenState extends State<AddEditStoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _synopsisController = TextEditingController();
  final _contentController = TextEditingController();
  final _coverImageUrlController = TextEditingController();
  final _instagramUrlController = TextEditingController();
  final _readingTimeController = TextEditingController();

  String _selectedCategory = '';
  bool _isFeatured = false;
  List<String> _tags = [];
  final _tagController = TextEditingController();
  bool _isSaving = false;
  bool _isLoadingCategories = true;
  bool _isFetchingInstagramImage = false;

  List<String> _categories = [];
  final CategoryService _categoryService = CategoryService();

  @override
  void initState() {
    super.initState();
    _loadCategories();
    if (widget.story != null) {
      _populateFields(widget.story!);
    }
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoadingCategories = true;
    });

    try {
      final categories = await _categoryService.getCategoryNames();
      setState(() {
        _categories = categories;
        if (_categories.isNotEmpty && _selectedCategory.isEmpty) {
          _selectedCategory = _categories.first;
        }
        _isLoadingCategories = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingCategories = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading categories: $e'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  void _populateFields(Story story) {
    _titleController.text = story.title;
    _authorController.text = story.author;
    _synopsisController.text = story.synopsis;
    _contentController.text = story.content;
    _coverImageUrlController.text = story.coverImageUrl;
    _readingTimeController.text = story.readingTimeMinutes.toString();
    _selectedCategory = story.category;
    _isFeatured = story.isFeatured;
    _tags = List.from(story.tags);
  }

  Future<void> _fetchInstagramImage() async {
    final instagramUrl = _instagramUrlController.text.trim();

    if (instagramUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter an Instagram URL'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (!InstagramImageService.isValidInstagramUrl(instagramUrl)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid Instagram URL. Use format: https://instagram.com/p/CODE'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isFetchingInstagramImage = true;
    });

    try {
      // Generate storage path based on story title or post code
      final postCode = InstagramImageService.getPostCode(instagramUrl) ?? 'image';
      final storagePath = 'covers/${postCode}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Process Instagram URL (extract and upload to Firebase)
      final firebaseUrl = await InstagramImageService.processInstagramUrl(
        instagramUrl: instagramUrl,
        firebaseStoragePath: storagePath,
      );

      setState(() {
        _isFetchingInstagramImage = false;
      });

      if (firebaseUrl != null) {
        setState(() {
          _coverImageUrlController.text = firebaseUrl;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✓ Image uploaded to Firebase successfully!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to fetch Instagram image. Try using a direct CDN URL instead.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isFetchingInstagramImage = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _synopsisController.dispose();
    _contentController.dispose();
    _coverImageUrlController.dispose();
    _instagramUrlController.dispose();
    _readingTimeController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.story != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Story' : 'Add Story'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _confirmDelete,
              tooltip: 'Delete',
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildSectionHeader('Basic Information'),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _titleController,
                    label: 'Story Title',
                    hint: 'Enter the story title',
                    icon: Icons.title,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _authorController,
                    label: 'Author',
                    hint: 'Author name',
                    icon: Icons.person,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the author name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildCategoryDropdown(),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _synopsisController,
                    label: 'Synopsis',
                    hint: 'Brief synopsis of the story (100-200 words)',
                    icon: Icons.description,
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a synopsis';
                      }
                      if (value.length < 50) {
                        return 'Synopsis must be at least 50 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildInstagramUrlSection(),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _coverImageUrlController,
                    label: 'Cover Image URL',
                    hint: 'Firebase URL (auto-filled from Instagram or enter manually)',
                    icon: Icons.image,
                    keyboardType: TextInputType.url,
                  ),
                  const SizedBox(height: 24),
                  _buildSectionHeader('Story Content'),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _contentController,
                    label: 'Full Content',
                    hint: 'Write your story here...',
                    icon: Icons.article,
                    maxLines: 15,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter story content';
                      }
                      if (value.length < 200) {
                        return 'Story must be at least 200 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  _buildSectionHeader('Additional Information'),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _readingTimeController,
                    label: 'Reading Time (Minutes)',
                    hint: '5',
                    icon: Icons.schedule,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter reading time';
                      }
                      final time = int.tryParse(value);
                      if (time == null || time <= 0) {
                        return 'Enter a valid number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTagsSection(),
                  const SizedBox(height: 16),
                  _buildFeaturedSwitch(),
                  const SizedBox(height: 32),
                  _buildSaveButton(isEditing),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          const AdBannerWidget(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  Widget _buildInstagramUrlSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.camera_alt, color: Colors.blue[700]),
              const SizedBox(width: 8),
              Text(
                'Fetch from Instagram',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[900],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _instagramUrlController,
            decoration: InputDecoration(
              labelText: 'Instagram Post URL',
              hintText: 'https://instagram.com/p/ABC123/',
              prefixIcon: const Icon(Icons.link),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              filled: true,
              fillColor: Colors.white,
              helperText: 'Paste Instagram post URL to auto-fetch image',
              helperMaxLines: 2,
            ),
            keyboardType: TextInputType.url,
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isFetchingInstagramImage ? null : _fetchInstagramImage,
              icon: _isFetchingInstagramImage
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.download),
              label: Text(
                _isFetchingInstagramImage
                    ? 'Fetching & Uploading...'
                    : 'Fetch Image & Upload to Firebase',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '💡 Tip: Image will be downloaded and uploaded to Firebase Storage automatically',
            style: TextStyle(
              fontSize: 12,
              color: Colors.blue[800],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    if (_isLoadingCategories) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey[50],
        ),
        child: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 12),
            Text(
              'Loading categories...',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    if (_categories.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.orange[300]!),
          borderRadius: BorderRadius.circular(12),
          color: Colors.orange[50],
        ),
        child: Row(
          children: [
            Icon(Icons.warning, color: Colors.orange[700]),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'No categories',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange[900],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Add categories first before adding stories',
                    style: TextStyle(fontSize: 12, color: Colors.orange[700]),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return DropdownButtonFormField<String>(
      initialValue: _selectedCategory.isEmpty ? null : _selectedCategory,
      decoration: InputDecoration(
        labelText: 'Category',
        prefixIcon: const Icon(Icons.category),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      items: _categories.map((category) {
        return DropdownMenuItem(value: category, child: Text(category));
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedCategory = value;
          });
        }
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a category';
        }
        return null;
      },
    );
  }

  Widget _buildTagsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _tagController,
          decoration: InputDecoration(
            labelText: 'Add Tags',
            hintText: 'Type a tag and press "Add"',
            prefixIcon: const Icon(Icons.label),
            suffixIcon: IconButton(
              icon: const Icon(Icons.add_circle),
              onPressed: _addTag,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          onFieldSubmitted: (_) => _addTag(),
        ),
        if (_tags.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _tags.map((tag) {
              return Chip(
                label: Text(tag),
                deleteIcon: const Icon(Icons.close, size: 18),
                onDeleted: () {
                  setState(() {
                    _tags.remove(tag);
                  });
                },
                backgroundColor: Theme.of(
                  context,
                ).primaryColor.withOpacity(0.1),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildFeaturedSwitch() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SwitchListTile(
        title: const Text('Featured Story'),
        subtitle: const Text(
          'This story will appear in the featured stories section',
        ),
        value: _isFeatured,
        onChanged: (value) {
          setState(() {
            _isFeatured = value;
          });
          HapticFeedback.selectionClick();
        },
        secondary: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.amber.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.star, color: Colors.amber),
        ),
      ),
    );
  }

  Widget _buildSaveButton(bool isEditing) {
    return ElevatedButton.icon(
      onPressed: _isSaving ? null : _saveStory,
      icon: _isSaving
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Icon(isEditing ? Icons.save : Icons.add),
      label: Text(
        _isSaving
            ? 'Saving...'
            : isEditing
            ? 'Save Changes'
            : 'Publish Story',
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _addTag() {
    final tag = _tagController.text.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagController.clear();
      });
      HapticFeedback.lightImpact();
    }
  }

  Future<void> _saveStory() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final storyService = StoryService();

      final story = Story(
        id: widget.story?.id ?? '',
        title: _titleController.text.trim(),
        author: _authorController.text.trim(),
        content: _contentController.text.trim(),
        synopsis: _synopsisController.text.trim(),
        category: _selectedCategory,
        coverImageUrl: _coverImageUrlController.text.trim(),
        publishedDate: widget.story?.publishedDate ?? DateTime.now(),
        views: widget.story?.views ?? 0,
        likes: widget.story?.likes ?? 0,
        tags: _tags,
        isFeatured: _isFeatured,
        readingTimeMinutes: int.parse(_readingTimeController.text.trim()),
      );

      if (widget.story == null) {
        // Add new story
        final id = await storyService.addStory(story);
        if (id != null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white),
                    SizedBox(width: 8),
                    Text('Story published!'),
                  ],
                ),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context, true);
          }
        } else {
          throw Exception('Failed to add story');
        }
      } else {
        // Update existing story
        final success = await storyService.updateStory(widget.story!.id, story);
        if (success) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white),
                    SizedBox(width: 8),
                    Text('Changes saved!'),
                  ],
                ),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context, true);
          }
        } else {
          throw Exception('Failed to update story');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('Error: $e')),
              ],
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.warning, color: Colors.red),
              SizedBox(width: 8),
              Text('Confirm Delete'),
            ],
          ),
          content: Text(
            'Are you sure you want to delete "${_titleController.text}"?\n\nThis action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteStory();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteStory() async {
    if (widget.story == null) return;

    try {
      final storyService = StoryService();
      final success = await storyService.deleteStory(widget.story!.id);

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Story deleted'),
                ],
              ),
              backgroundColor: Colors.red,
            ),
          );
          Navigator.pop(context, true);
        }
      } else {
        throw Exception('Failed to delete story');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('Error: $e')),
              ],
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
