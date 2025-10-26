
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../screens/reader_screen.dart';

mixin ReaderScreenStyles on State<ReaderScreen> {
  // --- Configuration for Book Format ---
  final double horizontalPadding = 25.0;
  final double verticalTopPadding = 32.0; // Explicit constant for top padding
  final double verticalBottomPadding = 80.0; // Explicit, larger constant for bottom padding
  // Standard max width for comfortable reading on large screens
  static const double maxContentWidth = 700.0;

  late final isDarkMode = Theme.of(context).brightness == Brightness.dark;

  EdgeInsets get paddingLTRB => EdgeInsets.fromLTRB(
      horizontalPadding,
      verticalTopPadding,
      horizontalPadding,
      verticalBottomPadding);

  double get totalVerticalPadding => verticalTopPadding + verticalBottomPadding;

  // NEW: Utility Styles for Bionic Conversion
  TextStyle get baseTextStyle => Theme.of(context).textTheme.bodyLarge!.copyWith(
    fontSize: 16.0,
    height: 1.5,
    color: isDarkMode ? Colors.white : Colors.black, // Default color for unbolded text
  );

  TextStyle get boldTextStyle => baseTextStyle.copyWith(
    fontWeight: FontWeight.w900,
    color: Theme.of(context).colorScheme.primary, // Highlight color
  );

  static Widget loadingSpinner(double size) => SpinKitHourGlass(
        color: Colors.white,
        size: size,
  );
}