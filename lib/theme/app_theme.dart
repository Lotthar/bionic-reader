import 'package:bionic_reader/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

/// Extension to provide easy access to custom app text styles.
extension AppThemeExtension on ThemeData {
  /// Usage: Theme.of(context).xTextStyles.body
  AppTextStyles get xTextStyles => extension<AppTextStyles>()!;
}
