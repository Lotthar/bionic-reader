import 'package:flutter/widgets.dart'; // Contains TextPainter, TextStyle, BoxConstraints

/// A service class responsible for splitting a large body of text into
/// page-sized chunks based on visual constraints (screen size, padding, and text style).
class TextPaginationService {
  final double horizontalPadding;
  final double verticalPadding;
  final TextStyle textStyle;
  final double appBarHeight;

  TextPaginationService({
    required this.horizontalPadding,
    required this.verticalPadding,
    required this.textStyle,
    required this.appBarHeight,
  });

  List<String> paginateTextToFit(String fullText, BoxConstraints constraints) {
    if (fullText.isEmpty) {
      return ['Document is empty.'];
    }

    final double contentWidth = constraints.maxWidth - (horizontalPadding * 2);
    // Ensure content height accounts for the space occupied by the app bar
    final double contentHeight = constraints.maxHeight - (verticalPadding * 2) - appBarHeight;

    // Calculate the max lines that fit vertically
    // We use a dummy character to get the line height measurement.
    final TextPainter lineMeasure = TextPainter(
      text: TextSpan(text: 'M', style: textStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    final int maxLines = (contentHeight / lineMeasure.height).floor();

    if (maxLines <= 1) {
      return [fullText];
    }

    // --- Dynamic Paging Loop ---
    final List<String> pages = [];
    String remainingText = fullText.trim();

    while (remainingText.isNotEmpty) {
      final TextPainter textPainter = TextPainter(
        text: TextSpan(text: remainingText, style: textStyle),
        textDirection: TextDirection.ltr,
        maxLines: maxLines, // Constrain by calculated max lines
      )..layout(maxWidth: contentWidth); // Constrain by width

      // Get the position where the text reaches the end of the content area
      int endPosition = textPainter.getPositionForOffset(
          Offset(contentWidth, contentHeight)
      ).offset;

      // If the text fits entirely on the page
      if (endPosition == 0 && !textPainter.didExceedMaxLines) {
        endPosition = remainingText.length;
      }

      // Find the last word boundary before the cutoff point for clean segmentation
      String pageContent = remainingText.substring(0, endPosition);
      int lastSpaceIndex = pageContent.lastIndexOf(' ');

      // Adjust the cut to the last space to avoid splitting words
      if (lastSpaceIndex > 0 && lastSpaceIndex < endPosition) {
        endPosition = lastSpaceIndex + 1;
        pageContent = remainingText.substring(0, endPosition);
      } else if (endPosition > 0 && lastSpaceIndex == -1) {
        // If a single word fills the entire page height, just take the segment
        endPosition = pageContent.length;
      }

      // Add the page and update the remaining text
      pages.add(pageContent.trim());
      remainingText = remainingText.substring(endPosition).trim();
    }

    return pages.isEmpty ? [fullText.trim()] : pages;
  }
}
