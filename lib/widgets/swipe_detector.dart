import 'package:flutter/material.dart';

/// A widget that detects horizontal swipe gestures and triggers callbacks.
class SwipeDetector extends StatelessWidget {
  final Widget child;
  final VoidCallback? onSwipeLeft;
  final VoidCallback? onSwipeRight;

  const SwipeDetector({
    super.key,
    required this.child,
    this.onSwipeLeft,
    this.onSwipeRight,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Use onHorizontalDragEnd to detect the end of a swipe gesture.
      onHorizontalDragEnd: (details) {
        // A primary velocity less than 0 indicates a swipe from right to left (next page).
        if (details.primaryVelocity != null && details.primaryVelocity! < 0) {
          onSwipeLeft?.call();
        }
        // A primary velocity greater than 0 indicates a swipe from left to right (previous page).
        else if (details.primaryVelocity != null && details.primaryVelocity! > 0) {
          onSwipeRight?.call();
        }
      },
      child: child,
    );
  }
}
