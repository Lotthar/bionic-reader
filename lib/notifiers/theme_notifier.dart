import 'package:bionic_reader/services/settings_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class ThemeNotifier with ChangeNotifier {
  final SettingsService _settingsService;

  ThemeMode _themeMode = ThemeMode.system;
  Color _seedColor = Colors.blue;

  ThemeNotifier(this._settingsService) {
    _loadSettings();
  }

  ThemeMode get themeMode => _themeMode;
  Color get seedColor => _seedColor;

  /// Determines if the application is currently in dark mode.
  /// Handles the 'system' theme mode by checking the platform's brightness.
  bool isDarkMode(BuildContext context) {
    if (_themeMode == ThemeMode.system) {
      return SchedulerBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }

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
