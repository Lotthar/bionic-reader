import 'package:bionic_reader/services/settings_service.dart';
import 'package:flutter/material.dart';

class ThemeNotifier with ChangeNotifier {
  final SettingsService _settingsService;

  ThemeMode _themeMode = ThemeMode.system;
  Color _seedColor = Colors.blue;

  ThemeNotifier(this._settingsService) {
    _loadSettings();
  }

  ThemeMode get themeMode => _themeMode;
  Color get seedColor => _seedColor;

  set themeMode(ThemeMode mode) {
    _themeMode = mode;
    _settingsService.setThemeMode(mode);
    notifyListeners();
  }

  set seedColor(Color color) {
    _seedColor = color;
    _settingsService.setSeedColor(color);
    notifyListeners();
  }

  void _loadSettings() async {
    _themeMode = await _settingsService.getThemeMode();
    _seedColor = await _settingsService.getSeedColor();
    notifyListeners();
  }
}
