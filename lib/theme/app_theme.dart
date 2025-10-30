import 'package:bionic_reader/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

/// Extension to provide easy access to custom app text styles.
extension AppThemeExtension on ThemeData {
  /// Usage: Theme.of(context).xTextStyles.body
  AppTextStyles get xTextStyles => extension<AppTextStyles>()!;
}

/// Centralized place for the application's theme data.
class AppTheme {
  /// The main font family for the app.
  static const String _fontFamily = 'Inter';

  static bool isDarkMode(BuildContext context) => Theme.of(context).brightness == Brightness.dark;

  /// Generates the light theme data for the application.
  static ThemeData light(Color seedColor) {
    return ThemeData(
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(seedColor: seedColor),
      useMaterial3: true,
      fontFamily: _fontFamily,
      extensions: <ThemeExtension<dynamic>>[
        _lightTextStyles,
      ],
    );
  }

  /// Generates the dark theme data for the application.
  static ThemeData dark(Color seedColor) {
    return ThemeData(
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
      fontFamily: _fontFamily,
      extensions: <ThemeExtension<dynamic>>[
        _darkTextStyles(seedColor),
      ],
    );
  }

  /// Custom text styles for the light theme.
  static const AppTextStyles _lightTextStyles = AppTextStyles(
    body: TextStyle(
      fontSize: 16.0,
      height: 1.5,
      color: Colors.black,
    ),
    bodyBold: TextStyle(
      fontSize: 16.0,
      height: 1.5,
      color: Colors.black,
      fontWeight: FontWeight.w900,
    ),
    caption: TextStyle(
      fontSize: 12.0,
      color: Colors.black54,
    ),
  );

  /// Custom text styles for the dark theme.
  static AppTextStyles _darkTextStyles(Color seedColor) {
    return AppTextStyles(
      body: const TextStyle(
        fontSize: 16.0,
        height: 1.5,
        color: Colors.white,
      ),
      bodyBold: TextStyle(
        fontSize: 16.0,
        height: 1.5,
        color: seedColor, // Use seed color for highlights in dark mode
        fontWeight: FontWeight.w900,
      ),
      caption: const TextStyle(
        fontSize: 12.0,
        color: Colors.white70,
      ),
    );
  }
}
