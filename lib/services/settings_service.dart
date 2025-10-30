import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _themeModeKey = 'theme_mode';
  static const String _seedColorKey = 'seed_color';

  Future<ThemeMode> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final themeModeIndex = prefs.getInt(_themeModeKey) ?? 0;
    return ThemeMode.values[themeModeIndex];
  }

  Future<void> setThemeMode(ThemeMode themeMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeModeKey, themeMode.index);
  }

  Future<Color> getSeedColor() async {
    final prefs = await SharedPreferences.getInstance();
    final seedColorValue = prefs.getInt(_seedColorKey) ?? Colors.blue.shade200.value;
    return Color(seedColorValue);
  }

  Future<void> setSeedColor(Color color) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_seedColorKey, color.value);
  }
}
