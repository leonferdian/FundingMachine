import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  static const String _themeModeKey = 'theme_mode';
  
  ThemeMode _themeMode = ThemeMode.system;
  bool _isDarkMode = false;
  
  // Getters
  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _isDarkMode;
  
  // Initialize the theme from shared preferences
  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeModeIndex = prefs.getInt(_themeModeKey) ?? ThemeMode.system.index;
      _themeMode = ThemeMode.values[themeModeIndex];
      _isDarkMode = _shouldUseDarkMode();
      notifyListeners();
    } catch (e) {
      // Fallback to system theme if there's an error
      _themeMode = ThemeMode.system;
      _isDarkMode = _shouldUseDarkMode();
    }
  }
  
  // Set the theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    
    _themeMode = mode;
    _isDarkMode = _shouldUseDarkMode();
    
    // Save to preferences
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeModeKey, mode.index);
    } catch (e) {
      debugPrint('Failed to save theme preference: $e');
    }
    
    notifyListeners();
  }
  
  // Toggle between light and dark theme
  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.system) {
      // If in system mode, toggle to light or dark based on current state
      await setThemeMode(_isDarkMode ? ThemeMode.light : ThemeMode.dark);
    } else {
      // Toggle between light and dark
      await setThemeMode(_themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light);
    }
  }
  
  // Check if dark mode should be used
  bool _shouldUseDarkMode() {
    switch (_themeMode) {
      case ThemeMode.system:
        final brightness = WidgetsBinding.instance.window.platformBrightness;
        return brightness == Brightness.dark;
      case ThemeMode.light:
        return false;
      case ThemeMode.dark:
        return true;
    }
  }
  
  // Get the current theme data based on the theme mode
  ThemeData getTheme(BuildContext context) {
    return _isDarkMode ? ThemeData.dark() : ThemeData.light();
  }
  
  // Get the current theme mode as a string
  String getThemeModeName() {
    switch (_themeMode) {
      case ThemeMode.system:
        return 'System';
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
    }
  }
  
  // Get the icon for the current theme mode
  IconData getThemeIcon() {
    switch (_themeMode) {
      case ThemeMode.system:
        return Icons.brightness_auto;
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
    }
  }
}
