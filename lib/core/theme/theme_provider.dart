import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_theme.dart';

// Provides global access to the current theme state
final themeProvider = StateNotifierProvider<ThemeNotifier, AppThemeType>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<AppThemeType> {
  ThemeNotifier() : super(AppThemeType.defaultTheme) {
    _loadTheme();
  }

  // Load saved theme on startup
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt('app_theme_index') ?? 0;
    state = AppThemeType.values[themeIndex];
  }

  // Change theme and save to storage
  Future<void> setTheme(AppThemeType theme) async {
    state = theme;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('app_theme_index', theme.index);
  }
}