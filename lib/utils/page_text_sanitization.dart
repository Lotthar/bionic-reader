
class PageTextSanitizer {

  final String text;

  PageTextSanitizer(this.text);

  String get sanitizedText {
    // 1. Preserve Page Breaks (e.g., a line with only "2")
    // Replaces a line containing only a number with a special marker.
    return text.replaceAll(
      RegExp(r'^\s*[0-9]+\s*$', multiLine: true),
      '__PAGE_BREAK__',
    )
    // 2. Preserve Chapter Headings (e.g., "CHAPTER ONE" or "THE BOY WHO LIVED")
    // Replaces all-caps lines (>= 5 chars) with the text + a marker.
    // We use $1 to keep the matched text (the chapter title).
    .replaceAllMapped(
      RegExp(r'^\s*([A-Z][A-Z0-9 ]{4,})\s*$', multiLine: true),
          (match) => '__CHAPTER_BREAK__${match.group(1)}__CHAPTER_BREAK__',
    )
    // 3. Preserve "Bigger Gaps" (Explicit Paragraphs)
    // Replaces any 2+ newlines (which you described as bigger gaps)
    // with a special marker.
    .replaceAll(
      RegExp(r'\n{2,}'),
      '__PARAGRAPH_BREAK__',
    )
    // 4. Remove all remaining (soft) newlines.
    // This is your original flattening step.
    .replaceAll('\n', ' ')
    // 5. Restore all preserved breaks with a standard double newline.
    // The TextPainter will now render this as a proper paragraph/chapter break.
    // We add spaces around them to ensure word separation.
    .replaceAll('__PAGE_BREAK__', '\n\n')
    .replaceAll('__CHAPTER_BREAK__', '\n\n')
    .replaceAll('__PARAGRAPH_BREAK__', '\n\n')
    .trim();
  }

}