import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Central theme controller for PennyPal.
/// Manages reactive theme toggling, SharedPreferences persistence,
/// and provides clean helpers for Light, Dark, and System modes.
class ThemeService extends ChangeNotifier {
  ThemeService._internal();
  static final ThemeService instance = ThemeService._internal();

  static const String _prefKey = 'pennypal_theme_mode';

  ThemeMode _themeMode = ThemeMode.light;
  bool _initialized = false;

  ThemeMode get themeMode => _themeMode;

  /// Returns true if currently explicitly set to dark mode.
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  /// Returns true if the active theme resolved by context is dark
  /// (handles ThemeMode.system by inspecting platform brightness).
  bool isDark(BuildContext context) {
    if (_themeMode == ThemeMode.system) {
      return MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }

  /// Human-friendly display string for the current mode.
  String get themeModeName {
    switch (_themeMode) {
      case ThemeMode.dark:
        return 'Midnight Sapphire';
      case ThemeMode.light:
        return 'Crisp Light';
      case ThemeMode.system:
        return 'System Auto';
    }
  }

  /// Initialize and restore user's saved preference from local storage.
  Future<void> init() async {
    if (_initialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedMode = prefs.getString(_prefKey);
      if (savedMode == 'dark') {
        _themeMode = ThemeMode.dark;
      } else if (savedMode == 'system') {
        _themeMode = ThemeMode.system;
      } else {
        _themeMode = ThemeMode.light;
      }
    } catch (e) {
      debugPrint('[ThemeService] Failed to load saved theme: $e');
      _themeMode = ThemeMode.light;
    } finally {
      _initialized = true;
      notifyListeners();
    }
  }

  /// Set specific ThemeMode (Light, Dark, or System) and persist choice.
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      String val = 'light';
      if (mode == ThemeMode.dark) val = 'dark';
      if (mode == ThemeMode.system) val = 'system';
      await prefs.setString(_prefKey, val);
    } catch (e) {
      debugPrint('[ThemeService] Failed to persist theme: $e');
    }
  }

  /// Direct boolean toggle for dark mode (used by standard switches).
  Future<void> setDarkMode(bool enabled) async {
    await setThemeMode(enabled ? ThemeMode.dark : ThemeMode.light);
  }

  /// Toggle between Light and Dark mode.
  Future<void> toggleTheme([BuildContext? context]) async {
    final currentlyDark = context != null ? isDark(context) : isDarkMode;
    await setDarkMode(!currentlyDark);
  }
}
