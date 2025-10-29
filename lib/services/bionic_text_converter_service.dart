import 'package:flutter/material.dart';

/// A utility class responsible for applying the Bionic Reading transformation
/// to a plain text string, returning a list of TextSpans for RichText rendering.
///
class BionicTextConverterService {
  final TextStyle baseTextStyle;
  final TextStyle boldTextStyle;
  final int fixateLength;

  BionicTextConverterService(
    this.baseTextStyle,
    this.boldTextStyle,
  { this.fixateLength = 3} // Number of initial characters to bold
  );

  /// Converts the input text string into a list of TextSpan widgets,
  /// bolding the first [fixateLength] characters of meaningful words.
  List<TextSpan> convert(String plainText) {
    if (plainText.isEmpty) return [spanWithText('')];

    final List<TextSpan> spans = [];
    var (wordParts, wordBoundary) = separateWordPartsAndBoundaryFrom(plainText);

    for (String part in wordParts) {
      if (part.trim().isEmpty || wordBoundary.hasMatch(part)) {
        spans.add(spanWithText(part));
        continue;
      }
      final (:length, :boldLength) = getRegularAndBoldLengthFor(part);
      spans.add(spanWithText(part.substring(0, boldLength), boldTextStyle));

      if (length > boldLength) spans.add(spanWithText(part.substring(boldLength)));
    }
    return spans;
  }

  (List<String>, RegExp) separateWordPartsAndBoundaryFrom(String text) {
    // Regular expression to identify delimiters (spaces and common punctuation)
    final RegExp wordBoundary = RegExp(r'(\s+|[.,!?;:\-–\—()"\[\]])');
    var parts = <String>[];
    int current = 0;
    for (final match in wordBoundary.allMatches(text)) {
      // 1. Add the non-match part (the word)
      final nonMatch = text.substring(current, match.start);
      if (nonMatch.isNotEmpty) parts.add(nonMatch);
      // 2. Add the match part (the delimiter/space)
      parts.add(match.group(0)!);
      current = match.end;
    }
    // 3. Add any remaining text after the last match
    if (current < text.length) parts.add(text.substring(current));

    return (parts, wordBoundary);
  }

  ({int length, int boldLength}) getRegularAndBoldLengthFor(String wordPart) {
    int len = wordPart.length;
    return (length: wordPart.length, boldLength: len > fixateLength ? fixateLength : len);
  }
  
  TextSpan spanWithText(String text, [TextStyle? style]) {
    return TextSpan(
      text: text,
      style: style ?? baseTextStyle
    );
  }
}
