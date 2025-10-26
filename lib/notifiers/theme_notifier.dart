import 'package:flutter/material.dart';

class ThemeNotifier with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  Color _seedColor = Colors.amber; // Changed to Color

  ThemeMode get themeMode => _themeMode;
  Color get seedColor => _seedColor; // Changed to Color

  set themeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  set seedColor(Color color) { // Changed to Color
    _seedColor = color;
    notifyListeners();
  }
}
