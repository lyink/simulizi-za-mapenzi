import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _fontSizeKey = 'font_size';
  static const String _colorSchemeKey = 'color_scheme';

  String _fontSize = 'medium';
  String _colorScheme = 'default';

  ThemeMode get themeMode => ThemeMode.light; // Always return light theme
  String get fontSize => _fontSize;
  String get colorScheme => _colorScheme;

  // Always return false for dark mode
  bool get isDarkMode => false;

  // Font size multiplier
  double get fontSizeMultiplier {
    switch (_fontSize) {
      case 'small':
        return 0.875; // 87.5%
      case 'medium':
        return 1.0; // 100%
      case 'large':
        return 1.125; // 112.5%
      case 'xlarge':
        return 1.25; // 125%
      default:
        return 1.0;
    }
  }

  // Primary color based on color scheme
  Color get primaryColor {
    switch (_colorScheme) {
      case 'default':
        return const Color(0xFF8D4E27);
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'purple':
        return Colors.purple;
      default:
        return const Color(0xFF8D4E27);
    }
  }

  ThemeProvider() {
    _loadSettings();
  }

  void _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    // Always force light theme
    _fontSize = prefs.getString(_fontSizeKey) ?? 'medium';
    _colorScheme = prefs.getString(_colorSchemeKey) ?? 'default';
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) async {
    // Always force light theme, ignore the parameter
    notifyListeners();
  }

  void toggleTheme() {
    // Do nothing, always keep light theme
  }

  void setFontSize(String size) async {
    _fontSize = size;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_fontSizeKey, size);
  }

  void setColorScheme(String scheme) async {
    _colorScheme = scheme;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_colorSchemeKey, scheme);
  }
}