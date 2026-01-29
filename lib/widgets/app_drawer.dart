import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/theme_provider.dart';
import '../services/ad_service.dart';
import '../screens/notification_preferences_screen.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Persistent state management
  String _selectedFontSize = 'medium';
  String _selectedColorScheme = 'default';
  bool _dailyStoriesEnabled = false;

  static const String _fontSizeKey = 'font_size';
  static const String _colorSchemeKey = 'color_scheme';
  static const String _dailyStoriesKey = 'daily_stories';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _loadSettings();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (mounted) {
        setState(() {
          _selectedFontSize = prefs.getString(_fontSizeKey) ?? 'medium';
          _selectedColorScheme = prefs.getString(_colorSchemeKey) ?? 'default';
          _dailyStoriesEnabled = prefs.getBool(_dailyStoriesKey) ?? false;
        });
      }
    } catch (e) {
      debugPrint('Error loading settings: $e');
    }
  }

  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_fontSizeKey, _selectedFontSize);
      await prefs.setString(_colorSchemeKey, _selectedColorScheme);
      await prefs.setBool(_dailyStoriesKey, _dailyStoriesEnabled);
    } catch (e) {
      debugPrint('Error saving settings: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: _buildDrawerContent(context, themeProvider),
    );
  }

  Widget _buildDrawerContent(
    BuildContext context,
    ThemeProvider themeProvider,
  ) {
    return Drawer(
      semanticLabel: 'Navigation drawer',
      child: Column(
        children: [
          _buildDrawerHeader(context),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildSection('Navigation', [
                  _buildDrawerItem(
                    icon: Icons.home,
                    title: 'Home',
                    onTap: () => Navigator.pop(context),
                  ),
                  _buildDrawerItem(
                    icon: Icons.category,
                    title: 'Categories',
                    onTap: () => _navigateToCategoriesScreen(context),
                  ),
                  _buildDrawerItem(
                    icon: Icons.search,
                    title: 'Search Stories',
                    onTap: () => _handleSearch(context),
                  ),
                ]),
                const Divider(height: 1),
                _buildSection('Personal', [
                  _buildDrawerItem(
                    icon: Icons.bookmark,
                    title: 'Bookmarks',
                    onTap: () => _handleBookmarks(context),
                  ),
                  _buildDrawerItem(
                    icon: Icons.history,
                    title: 'History',
                    onTap: () => _handleHistory(context),
                  ),
                  _buildDrawerItem(
                    icon: Icons.favorite,
                    title: 'Favorites',
                    onTap: () => _handleFavorites(context),
                  ),
                ]),
                const Divider(height: 1),
                _buildSection('Premium', [
                  _buildDrawerItem(
                    icon: Icons.diamond,
                    title: 'Unlock Premium Features',
                    subtitle: 'Watch ads for rewards',
                    onTap: () => _handlePremiumFeatures(context),
                  ),
                ]),
                const Divider(height: 1),
                _buildSection('Design', [
                  _buildThemeToggle(context, themeProvider),
                  Consumer<ThemeProvider>(
                    builder: (context, themeProvider, child) {
                      return _buildDrawerItem(
                        icon: Icons.text_fields,
                        title: 'Font Size',
                        subtitle: _getFontSizeLabel(themeProvider.fontSize),
                        onTap: () => _handleFontSize(context),
                      );
                    },
                  ),
                  Consumer<ThemeProvider>(
                    builder: (context, themeProvider, child) {
                      return _buildDrawerItem(
                        icon: Icons.color_lens,
                        title: 'Color Scheme',
                        subtitle: _getColorSchemeLabel(
                          themeProvider.colorScheme,
                        ),
                        onTap: () => _handleColorScheme(context),
                      );
                    },
                  ),
                ]),
                // const Divider(height: 1),
                // _buildSection('Management', [
                //   _buildDrawerItem(
                //     icon: Icons.admin_panel_settings,
                //     title: 'Admin Panel',
                //     subtitle: 'Manage stories',
                //     onTap: () => _handleAdminPanel(context),
                //   ),
                // ]),
                const Divider(height: 1),
                _buildSection('More', [
                  _buildDrawerItem(
                    icon: Icons.notifications_active,
                    title: 'Notifications',
                    subtitle: 'Manage reminders',
                    onTap: () => _handleNotifications(context),
                  ),
                  _buildDrawerItem(
                    icon: Icons.settings,
                    title: 'Settings',
                    onTap: () => _handleSettings(context),
                  ),
                  _buildDrawerItem(
                    icon: Icons.help,
                    title: 'Help',
                    onTap: () => _handleHelp(context),
                  ),
                  _buildDrawerItem(
                    icon: Icons.info,
                    title: 'About',
                    onTap: () => _handleAbout(context),
                  ),
                ]),
              ],
            ),
          ),
          _buildFooter(context),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.8),
          ],
        ),
      ),
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white.withOpacity(0.1),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    'assets/images/icon.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.menu_book,
                        color: Colors.white,
                        size: 20,
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Simulizi za Mapenzi',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Hadithi za Kuvutia',
                      style: TextStyle(color: Colors.white70, fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
        ...children,
      ],
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    String? subtitle,
    Widget? trailing,
  }) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).iconTheme.color),
      title: Text(
        title,
        style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            )
          : null,
      trailing: trailing,
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    );
  }

  Widget _buildThemeToggle(BuildContext context, ThemeProvider themeProvider) {
    return ListTile(
      leading: Icon(
        themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
        color: Theme.of(context).iconTheme.color,
      ),
      title: Text(
        'Dark Mode',
        style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
      ),
      trailing: Switch.adaptive(
        value: themeProvider.isDarkMode,
        onChanged: (value) {
          themeProvider.toggleTheme();
        },
        activeTrackColor: Theme.of(context).primaryColor,
        activeThumbColor: Colors.white,
      ),
      onTap: () => themeProvider.toggleTheme(),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Theme.of(context).dividerColor, width: 1),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.favorite, color: Colors.red, size: 14),
          const SizedBox(width: 6),
          Text(
            'Made with ♥',
            style: TextStyle(
              fontSize: 11,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
          const Spacer(),
          Text(
            'v1.0.0',
            style: TextStyle(
              fontSize: 11,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
        ],
      ),
    );
  }

  // Efficient handler methods
  void _navigateToCategoriesScreen(BuildContext context) {
    HapticFeedback.lightImpact();
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Story categories are available from the main menu'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _handleSearch(BuildContext context) {
    HapticFeedback.lightImpact();
    Navigator.pop(context);
    _showSearchDialog(context);
  }

  void _handleBookmarks(BuildContext context) {
    HapticFeedback.lightImpact();
    Navigator.pop(context);
    _showBookmarksDialog(context);
  }

  void _handleHistory(BuildContext context) {
    HapticFeedback.lightImpact();
    Navigator.pop(context);
    _showHistoryDialog(context);
  }

  void _handleFavorites(BuildContext context) {
    HapticFeedback.lightImpact();
    Navigator.pop(context);
    _showFavoritesDialog(context);
  }

  void _handlePremiumFeatures(BuildContext context) {
    HapticFeedback.lightImpact();
    Navigator.pop(context);
    _showRewardedAdDialog(context);
  }

  void _handleFontSize(BuildContext context) {
    HapticFeedback.lightImpact();
    Navigator.pop(context);
    _showFontSizeDialog(context);
  }

  void _handleColorScheme(BuildContext context) {
    HapticFeedback.lightImpact();
    Navigator.pop(context);
    _showColorSchemeDialog(context);
  }

  void _handleSettings(BuildContext context) async {
    HapticFeedback.lightImpact();
    Navigator.pop(context);

    try {
      if (AdService.isInterstitialAdReady) {
        AdService.showInterstitialAd(
          onAdClosed: () => _showSettingsDialog(context),
        );
      } else {
        _showSettingsDialog(context);
      }
    } catch (e) {
      debugPrint('Error handling settings: $e');
      _showSettingsDialog(context);
    }
  }

  void _handleHelp(BuildContext context) {
    HapticFeedback.lightImpact();
    Navigator.pop(context);
    _showHelpDialog(context);
  }

  void _handleAbout(BuildContext context) {
    HapticFeedback.lightImpact();
    Navigator.pop(context);
    _showAboutDialog(context);
  }

  void _handleAdminPanel(BuildContext context) {
    HapticFeedback.lightImpact();
    Navigator.pop(context);
    Navigator.pushNamed(context, '/admin');
  }

  void _handleNotifications(BuildContext context) {
    HapticFeedback.lightImpact();
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const NotificationPreferencesScreen(),
      ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    final searchController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.search, color: Theme.of(context).primaryColor),
              const SizedBox(width: 8),
              const Text('Search'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search for stories...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).primaryColor.withOpacity(0.05),
                ),
                onSubmitted: (value) => _performSearch(context, value),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Search through all love stories for keywords and themes.',
                  style: TextStyle(fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => _performSearch(context, searchController.text),
              child: const Text('Search'),
            ),
          ],
        );
      },
    );
  }

  void _performSearch(BuildContext context, String query) {
    Navigator.of(context).pop();
    if (query.trim().isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Searching for: "$query"'),
          backgroundColor: Theme.of(context).primaryColor,
        ),
      );
      // TODO: Implement actual search functionality
    }
  }

  void _showBookmarksDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.bookmark, color: Colors.amber),
              const SizedBox(width: 8),
              const Text('Bookmarks'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(Icons.bookmark_border, size: 48, color: Colors.amber),
                    const SizedBox(height: 12),
                    const Text(
                      'No bookmarks saved yet',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Mark your favorite love stories as bookmarks to quickly find them again.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Got it'),
            ),
          ],
        );
      },
    );
  }

  void _showHistoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('History'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.history, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text('History is empty'),
              const SizedBox(height: 8),
              const Text(
                'Your recently read love stories will be displayed here.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showFavoritesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Favorites'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.favorite_border, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text('No favorites saved'),
              const SizedBox(height: 8),
              const Text(
                'Mark your favorite love stories for easy access.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showFontSizeDialog(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    String tempSelectedSize = themeProvider.fontSize;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  Icon(
                    Icons.text_fields,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 8),
                  const Text('Font Size'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildFontSizeOption(
                    'Small',
                    'small',
                    14.0,
                    tempSelectedSize,
                    (newValue) {
                      setDialogState(() {
                        tempSelectedSize = newValue;
                      });
                    },
                  ),
                  _buildFontSizeOption(
                    'Medium',
                    'medium',
                    16.0,
                    tempSelectedSize,
                    (newValue) {
                      setDialogState(() {
                        tempSelectedSize = newValue;
                      });
                    },
                  ),
                  _buildFontSizeOption(
                    'Large',
                    'large',
                    18.0,
                    tempSelectedSize,
                    (newValue) {
                      setDialogState(() {
                        tempSelectedSize = newValue;
                      });
                    },
                  ),
                  _buildFontSizeOption(
                    'Extra Large',
                    'xlarge',
                    20.0,
                    tempSelectedSize,
                    (newValue) {
                      setDialogState(() {
                        tempSelectedSize = newValue;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    themeProvider.setFontSize(tempSelectedSize);
                    Navigator.of(context).pop();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Font size set to ${_getFontSizeLabel(tempSelectedSize)}',
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                  child: const Text('Apply'),
                ),
              ],
            );
          },
        );
      },
    ).then((_) {
      // Update the value used in the closure
      tempSelectedSize = themeProvider.fontSize;
    });
  }

  Widget _buildFontSizeOption(
    String title,
    String value,
    double fontSize,
    String selectedSize,
    ValueChanged<String> onChanged,
  ) {
    final isSelected = selectedSize == value;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: isSelected
            ? Theme.of(context).primaryColor.withOpacity(0.1)
            : null,
        borderRadius: BorderRadius.circular(8),
        border: isSelected
            ? Border.all(color: Theme.of(context).primaryColor)
            : null,
      ),
      child: ListTile(
        title: Text(title, style: TextStyle(fontSize: fontSize)),
        leading: Radio<String>(
          value: value,
          groupValue: selectedSize,
          onChanged: (newValue) {
            if (newValue != null) onChanged(newValue);
          },
        ),
        onTap: () {
          onChanged(value);
        },
      ),
    );
  }

  void _showColorSchemeDialog(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    String tempSelectedScheme = themeProvider.colorScheme;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  Icon(Icons.color_lens, color: Theme.of(context).primaryColor),
                  const SizedBox(width: 8),
                  const Text('Color Scheme'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildColorSchemeOption(
                    'Default (Brown)',
                    'default',
                    const Color(0xFF8D4E27),
                    tempSelectedScheme,
                    (newValue) {
                      setDialogState(() {
                        tempSelectedScheme = newValue;
                      });
                    },
                  ),
                  _buildColorSchemeOption(
                    'Blue',
                    'blue',
                    Colors.blue,
                    tempSelectedScheme,
                    (newValue) {
                      setDialogState(() {
                        tempSelectedScheme = newValue;
                      });
                    },
                  ),
                  _buildColorSchemeOption(
                    'Green',
                    'green',
                    Colors.green,
                    tempSelectedScheme,
                    (newValue) {
                      setDialogState(() {
                        tempSelectedScheme = newValue;
                      });
                    },
                  ),
                  _buildColorSchemeOption(
                    'Purple',
                    'purple',
                    Colors.purple,
                    tempSelectedScheme,
                    (newValue) {
                      setDialogState(() {
                        tempSelectedScheme = newValue;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    themeProvider.setColorScheme(tempSelectedScheme);
                    Navigator.of(context).pop();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Color scheme set to ${_getColorSchemeLabel(tempSelectedScheme)}',
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                  child: const Text('Apply'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildColorSchemeOption(
    String title,
    String value,
    Color color,
    String selectedScheme,
    ValueChanged<String> onChanged,
  ) {
    final isSelected = selectedScheme == value;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? color.withOpacity(0.1) : null,
        borderRadius: BorderRadius.circular(8),
        border: isSelected ? Border.all(color: color) : null,
      ),
      child: ListTile(
        title: Text(title),
        leading: CircleAvatar(backgroundColor: color, radius: 12),
        trailing: Radio<String>(
          value: value,
          groupValue: selectedScheme,
          onChanged: (newValue) {
            if (newValue != null) onChanged(newValue);
          },
        ),
        onTap: () {
          onChanged(value);
        },
      ),
    );
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  Icon(Icons.settings, color: Theme.of(context).primaryColor),
                  const SizedBox(width: 8),
                  const Text('Settings'),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.notifications),
                      title: const Text('Daily Stories'),
                      subtitle: const Text('Enable daily love stories'),
                      trailing: Switch.adaptive(
                        value: _dailyStoriesEnabled,
                        onChanged: (value) async {
                          setDialogState(() {
                            _dailyStoriesEnabled = value;
                          });
                          setState(() {
                            _dailyStoriesEnabled = value;
                          });
                          await _saveSettings();
                          HapticFeedback.lightImpact();
                        },
                      ),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.language),
                      title: const Text('Language'),
                      subtitle: const Text('English'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        HapticFeedback.lightImpact();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Language settings are available in a future version',
                            ),
                            backgroundColor: Colors.blue,
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.backup),
                      title: const Text('Backup'),
                      subtitle: const Text('Back up and restore data'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        HapticFeedback.lightImpact();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Backup features are available in a future version',
                            ),
                            backgroundColor: Colors.blue,
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.privacy_tip),
                      title: const Text('Privacy'),
                      subtitle: const Text('Privacy settings'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        HapticFeedback.lightImpact();
                        _showPrivacyDialog(context);
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showPrivacyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Privacy'),
          content: const SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Privacy and Security',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 12),
                Text('• All data is stored locally on your device'),
                Text('• No personal data is transmitted to servers'),
                Text('• Advertisements are provided by Google AdMob'),
                Text('• Bookmarks and settings remain private'),
                SizedBox(height: 16),
                Text(
                  'Data Collection:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text('• Only anonymous usage statistics for advertisements'),
                Text('• No tracking of personal data'),
                Text('• No sharing with third parties (except ad partners)'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Got it'),
            ),
          ],
        );
      },
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Help'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'How to use the Love Stories App?',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text('• Tap on "Categories" to browse story collections'),
                const Text('• Use "Search Stories" to find specific stories'),
                const Text('• Mark your favorite stories as bookmarks'),
                const Text('• Browse through different story categories'),
                const SizedBox(height: 16),
                const Text(
                  'Features:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text('• Access to heartwarming love stories'),
                const Text('• Multiple story categories'),
                const Text('• Advanced search functions'),
                const Text('• Bookmarks and reading history'),
                const Text('• Customizable themes and font sizes'),
                const Text('• Daily story notifications'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showRewardedAdDialog(BuildContext context) {
    if (!AdService.isRewardedAdReady) {
      _showAdNotReadyMessage(context);
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.amber, Colors.orange],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.diamond, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(child: Text('Unlock Premium')),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue.withOpacity(0.1),
                      Colors.purple.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.video_library,
                      size: 48,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Watch a short ad to unlock premium features:',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ..._buildPremiumFeatures(),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton.icon(
              onPressed: () => _watchRewardedAd(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              icon: const Icon(Icons.play_arrow),
              label: const Text('Watch Video'),
            ),
          ],
        );
      },
    );
  }

  List<Widget> _buildPremiumFeatures() {
    final features = [
      'Advanced search functions',
      'Unlimited bookmarks',
      'Offline synchronization',
    ];

    return features
        .map(
          (feature) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(feature, style: const TextStyle(fontSize: 13)),
                ),
              ],
            ),
          ),
        )
        .toList();
  }

  void _showAdNotReadyMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.hourglass_empty, color: Colors.white),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Rewarded ad is still loading. Please try again later.',
              ),
            ),
          ],
        ),
        backgroundColor: Colors.orange,
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  void _watchRewardedAd(BuildContext context) {
    Navigator.of(context).pop();
    AdService.showRewardedAd(
      onUserEarnedReward: (ad, reward) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.celebration, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Congratulations! You received ${reward.amount} ${reward.type}!',
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
      },
      onAdClosed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Premium features have been unlocked!'),
            backgroundColor: Colors.blue,
          ),
        );
      },
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Simulizi za Mapenzi',
      applicationVersion: '1.0.2',
      applicationIcon: const Icon(
        Icons.favorite,
        size: 48,
        color: Color(0xFF8D4E27),
      ),
      children: const [
        Text('A heartwarming collection of love stories for everyone.'),
        SizedBox(height: 16),
        Text(
          'Developed for everyone who loves touching romantic tales and heartwarming moments.',
        ),
        SizedBox(height: 16),
        Text('Features:', style: TextStyle(fontWeight: FontWeight.bold)),
        Text('• Collection of beautiful love stories'),
        Text('• Multiple story categories'),
        Text('• Advanced search functions'),
        Text('• Bookmarks and reading history'),
        Text('• Offline access to all stories'),
        Text('• Modern, user-friendly interface'),
        Text('• Dynamic themes and customizations'),
        Text('• Daily story notifications'),
      ],
    );
  }

  String _getFontSizeLabel(String size) {
    switch (size) {
      case 'small':
        return 'Small';
      case 'medium':
        return 'Medium';
      case 'large':
        return 'Large';
      case 'xlarge':
        return 'Extra Large';
      default:
        return 'Medium';
    }
  }

  String _getColorSchemeLabel(String scheme) {
    switch (scheme) {
      case 'default':
        return 'Default';
      case 'blue':
        return 'Blue';
      case 'green':
        return 'Green';
      case 'purple':
        return 'Purple';
      default:
        return 'Default';
    }
  }
}
