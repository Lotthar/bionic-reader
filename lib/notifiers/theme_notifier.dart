import 'package:flutter/material.dart';

class ThemeNotifier with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  MaterialColor _seedColor = Colors.amber;

  ThemeMode get themeMode => _themeMode;
  MaterialColor get seedColor => _seedColor;

  // List of available seed colors
  final List<MaterialColor> _availableColors = [
    Colors.amber,
    Colors.blue,
    Colors.green,
    Colors.red,
    Colors.purple,
    Colors.orange,
  ];
  List<MaterialColor> get availableColors => _availableColors;

  set themeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  set seedColor(MaterialColor color) {
    _seedColor = color;
    notifyListeners();
  }
}
