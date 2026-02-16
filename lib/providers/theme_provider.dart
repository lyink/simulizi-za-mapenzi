import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _key = 'isDarkMode';

  bool _isDark = false; // default: light theme

  bool get isDark => _isDark;

  ThemeProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _isDark = prefs.getBool(_key) ?? false;
    notifyListeners();
  }

  Future<void> setDark(bool value) async {
    _isDark = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, value);
  }

  void toggle() => setDark(!_isDark);
}
