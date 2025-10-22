
import 'package:flutter/material.dart';

import '../home_screen.dart';

mixin BionicReaderScreenStyles on State<BionicReaderHomeScreen> {
  // --- Configuration for Book Format ---
  final double horizontalPadding = 32.0;
  final double verticalTopPadding = 32.0; // Explicit constant for top padding
  final double verticalBottomPadding = 64.0; // Explicit, larger constant for bottom padding
  // Standard max width for comfortable reading on large screens
  static const double maxContentWidth = 700.0;

  EdgeInsets get paddingLTRB => EdgeInsets.fromLTRB(
      horizontalPadding,
      verticalTopPadding,
      horizontalPadding,
      verticalBottomPadding);

  double get totalVerticalPadding => verticalTopPadding + verticalBottomPadding;

  // NEW: Utility Styles for Bionic Conversion
  TextStyle get baseTextStyle => Theme.of(context).textTheme.bodyLarge!.copyWith(
    fontSize: 18.0,
    height: 1.5,
    color: Colors.black, // Default color for unbolded text
  );

  TextStyle get boldTextStyle => baseTextStyle.copyWith(
    fontWeight: FontWeight.w900,
    color: Theme.of(context).colorScheme.primary, // Highlight color
  );
}