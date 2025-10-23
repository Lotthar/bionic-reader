import 'dart:async';
import 'package:flutter/widgets.dart';


/// Service to paginate text based on visual constraints.
class TextPaginationService {
  final TextStyle textStyle;
  final _LayoutMetrics _layoutMetrics;

  TextPaginationService({
    required this.textStyle,
    required double horizontalPadding,
    required double verticalPadding,
    required double appBarHeight,
    required BoxConstraints boxConstraints,
  }) : _layoutMetrics = _LayoutMetrics.fromConstraints(
    constraints: boxConstraints,
    horizontalPadding: horizontalPadding,
    verticalPadding: verticalPadding,
    appBarHeight: appBarHeight,
    textStyle: textStyle,
  );

  /// Splits the text into a stream of pages.
  Stream<String> paginateText(String fullText) async* {
    final sanitizedText = fullText.trim().replaceAll('\n', ' ');
    if (sanitizedText.trim().isEmpty) {
      yield 'Document is empty.';
      return;
    }

    if (_layoutMetrics.maxLines <= 1) {
      yield sanitizedText;
      return;
    }

    String remainingText = sanitizedText.trim();
    while (remainingText.isNotEmpty) {
      await Future.delayed(Duration.zero);
      final split = _splitNextPage(remainingText);
      yield split.pageContent;
      remainingText = split.remainingText;
    }
  }

  // Splits the next page from the remaining text.
  _PageSplit _splitNextPage(String remainingText) {
    final textPainter = TextPainter(
      text: TextSpan(text: remainingText, style: textStyle),
      textDirection: TextDirection.ltr,
      maxLines: _layoutMetrics.maxLines,
    )..layout(maxWidth: _layoutMetrics.contentWidth);

    int endPosition = textPainter
        .getPositionForOffset(
        Offset(_layoutMetrics.contentWidth, _layoutMetrics.contentHeight))
        .offset;

    if (endPosition == 0 && !textPainter.didExceedMaxLines) {
      endPosition = remainingText.length;
    } else {
      endPosition = _findWordBoundary(remainingText, endPosition);
    }

    final pageContent = remainingText.substring(0, endPosition).trim();
    final newRemainingText = remainingText.substring(endPosition).trim();

    return _PageSplit(pageContent, newRemainingText);
  }

  // Finds the last word boundary before the cutoff point.
  int _findWordBoundary(String text, int cutoff) {
    if (cutoff >= text.length) return text.length;

    final pageContent = text.substring(0, cutoff);
    final lastSpace = pageContent.lastIndexOf(' ');

    if (lastSpace > 0) return lastSpace + 1;

    return cutoff;
  }
}

// Helper class to hold the result of a page split
class _PageSplit {
  final String pageContent;
  final String remainingText;

  _PageSplit(this.pageContent, this.remainingText);
}

// Helper class to encapsulate layout-related calculations
class _LayoutMetrics {
  final double contentWidth;
  final double contentHeight;
  final int maxLines;

  _LayoutMetrics(this.contentWidth, this.contentHeight, this.maxLines);

  factory _LayoutMetrics.fromConstraints({
    required BoxConstraints constraints,
    required double horizontalPadding,
    required double verticalPadding,
    required double appBarHeight,
    required TextStyle textStyle,
  }) {
    final contentWidth = constraints.maxWidth - (horizontalPadding * 2);
    final contentHeight = constraints.maxHeight - (verticalPadding * 2) - appBarHeight;

    final lineMeasure = TextPainter(
      text: TextSpan(text: 'M', style: textStyle),
      textDirection: TextDirection.ltr,
    )..layout();

    final maxLines = (contentHeight / lineMeasure.height).floor();

    return _LayoutMetrics(contentWidth, contentHeight, maxLines);
  }
}
