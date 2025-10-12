import 'package:flutter/material.dart';

/// A utility class responsible for applying the Bionic Reading transformation
/// to a plain text string, returning a list of TextSpans for RichText rendering.
class BionicTextConverter {
  final TextStyle baseStyle;
  final TextStyle boldStyle;
  final int fixateLength;

  BionicTextConverter({
    required this.baseStyle,
    required this.boldStyle,
    this.fixateLength = 3, // Number of initial characters to bold
  });

  /// Converts the input text string into a list of TextSpan widgets,
  /// bolding the first [fixateLength] characters of meaningful words.
  List<TextSpan> convert(String plainText) {
    if (plainText.isEmpty) {
      return [TextSpan(text: '', style: baseStyle)];
    }

    final List<TextSpan> spans = [];
    // Regular expression to identify delimiters (spaces and common punctuation)
    final RegExp wordBoundary = RegExp(r'(\s+|[.,!?;:\-–\—()"\[\]])');

    // --- FIX: Manual accumulation of parts to ensure 'parts' is an iterable List<String> ---
    final List<String> parts = [];
    int current = 0;

    for (final match in wordBoundary.allMatches(plainText)) {
      // 1. Add the non-match part (the word)
      final nonMatch = plainText.substring(current, match.start);
      if (nonMatch.isNotEmpty) {
        parts.add(nonMatch);
      }

      // 2. Add the match part (the delimiter/space)
      parts.add(match.group(0)!);

      current = match.end;
    }

    // 3. Add any remaining text after the last match
    if (current < plainText.length) {
      parts.add(plainText.substring(current));
    }
    // ------------------------------------------------------------------------------------

    for (String part in parts) {
      // Check if the part is only whitespace or delimiter
      if (part.trim().isEmpty) {
        spans.add(TextSpan(text: part, style: baseStyle));
        continue;
      }

      // We rely on the `parts` list structure; if it's a word, apply bionic logic
      if (!wordBoundary.hasMatch(part)) {
        final int length = part.length;
        final int boldLen = length > fixateLength ? fixateLength : length;

        // 1. Bold part
        spans.add(
          TextSpan(
            text: part.substring(0, boldLen),
            style: boldStyle,
          ),
        );

        // 2. Regular part
        if (length > boldLen) {
          spans.add(
            TextSpan(
              text: part.substring(boldLen),
              style: baseStyle,
            ),
          );
        }
      } else {
        // Fallback for any missed delimiters that weren't captured explicitly
        spans.add(TextSpan(text: part, style: baseStyle));
      }
    }

    return spans;
  }
}
