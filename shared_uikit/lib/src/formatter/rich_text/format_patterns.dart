import 'package:cometchat_uikit_shared/cometchat_uikit_shared.dart';

/// Centralized regex patterns for rich text formatting.
class FormatPatterns {
  FormatPatterns._();

  /// Pattern for bold text: **text**
  static final RegExp bold = RegExp(r'\*\*([^*]+)\*\*');

  /// Pattern for italic text: _text_
  /// Uses [a-zA-Z0-9] instead of \w for boundary checks so that adjacent
  /// italic segments separated by _ (e.g. _text1__**text2**_) are parsed
  /// correctly. \w includes underscore which causes the lookaround to fail
  /// when two italic markers are adjacent.
  static final RegExp italic = RegExp(r'(?<![a-zA-Z0-9])_([^_]+)_(?![a-zA-Z0-9])');

  /// Pattern for underline text: <u>text</u>
  static final RegExp underline = RegExp(r'<u>(.+?)<\/u>');

  /// Pattern for strikethrough text: ~~text~~
  static final RegExp strikethrough = RegExp(r'~~(.+?)~~');

  /// Pattern for inline code: `code` (but not inside code blocks)
  static final RegExp inlineCode = RegExp(r'(?<!`)`([^`]+)`(?!`)');

  /// Pattern for code blocks: ```code```
  static final RegExp codeBlock = RegExp(r'```([\s\S]*?)```');

  /// Pattern for links: [text](url)
  static final RegExp link = RegExp(r'\[([^\]]+)\]\(([^)]+)\)');

  /// Pattern for blockquotes: > text
  static final RegExp blockquote = RegExp(r'^>\s*(.+)$', multiLine: true);

  /// Pattern for bullet lists: - item
  static final RegExp bulletList = RegExp(r'^-\s+(.+)$', multiLine: true);

  /// Pattern for ordered lists: 1. item
  static final RegExp orderedList = RegExp(r'^\d+\.\s+(.+)$', multiLine: true);

  /// Combined pattern that matches all inline formats.
  static final RegExp combined = RegExp(
    r'\*\*([^*]+)\*\*|'
    r'(?<![a-zA-Z0-9])_([^_]+)_(?![a-zA-Z0-9])|'
    r'<u>(.+?)<\/u>|'
    r'~~(.+?)~~|'
    r'(?<!`)`([^`]+)`(?!`)|'
    r'```([\s\S]*?)```|'
    r'\[([^\]]+)\]\(([^)]+)\)',
  );

  /// Pattern for detecting emoji characters.
  static final RegExp emoji = RegExp(
    r'[\u{1F600}-\u{1F64F}]|'
    r'[\u{1F300}-\u{1F5FF}]|'
    r'[\u{1F680}-\u{1F6FF}]|'
    r'[\u{1F1E0}-\u{1F1FF}]|'
    r'[\u{2600}-\u{26FF}]|'
    r'[\u{2700}-\u{27BF}]|'
    r'[\u{FE00}-\u{FE0F}]|'
    r'[\u{1F900}-\u{1F9FF}]|'
    r'[\u{1FA00}-\u{1FA6F}]|'
    r'[\u{1FA70}-\u{1FAFF}]',
    unicode: true,
  );

  /// Returns the regex pattern for the given format type.
  static RegExp getPattern(FormatType formatType) {
    switch (formatType) {
      case FormatType.bold:
        return bold;
      case FormatType.italic:
        return italic;
      case FormatType.underline:
        return underline;
      case FormatType.strikethrough:
        return strikethrough;
      case FormatType.inlineCode:
        return inlineCode;
      case FormatType.codeBlock:
        return codeBlock;
      case FormatType.link:
        return link;
      case FormatType.blockquote:
        return blockquote;
      case FormatType.bulletList:
        return bulletList;
      case FormatType.orderedList:
        return orderedList;
    }
  }

  /// Checks if the cursor position is inside a pattern match.
  static bool isInsidePattern(String text, int position, RegExp pattern) {
    for (final match in pattern.allMatches(text)) {
      if (position > match.start && position < match.end) {
        return true;
      }
    }
    return false;
  }

  /// Checks if the cursor position is inside a line-level format.
  static bool isInsideLineFormat(String text, int position, RegExp pattern) {
    int lineStart = text.lastIndexOf('\n', position > 0 ? position - 1 : 0);
    lineStart = lineStart == -1 ? 0 : lineStart + 1;
    int lineEnd = text.indexOf('\n', position);
    lineEnd = lineEnd == -1 ? text.length : lineEnd;
    final currentLine = text.substring(lineStart, lineEnd);
    return pattern.hasMatch(currentLine);
  }

  /// Returns ranges of text that are not emoji characters.
  static List<({int start, int end})> getNonEmojiRanges(
    String text,
    int start,
    int end,
  ) {
    final ranges = <({int start, int end})>[];
    final substring = text.substring(start, end);
    final emojiMatches = emoji.allMatches(substring).toList();

    if (emojiMatches.isEmpty) {
      return [(start: start, end: end)];
    }

    int currentStart = 0;
    for (final match in emojiMatches) {
      if (match.start > currentStart) {
        ranges.add((start: start + currentStart, end: start + match.start));
      }
      currentStart = match.end;
    }

    if (currentStart < substring.length) {
      ranges.add((start: start + currentStart, end: end));
    }

    return ranges;
  }

  /// Strips all formatting markers from text, keeping only the content.
  static String stripFormatting(String text) {
    if (text.isEmpty) return text;

    String result = text;
    result = result.replaceAllMapped(codeBlock, (m) => m.group(1) ?? '');
    result = result.replaceAllMapped(inlineCode, (m) => m.group(1) ?? '');
    result = result.replaceAllMapped(link, (m) => m.group(1) ?? '');
    result = result.replaceAllMapped(bold, (m) => m.group(1) ?? '');
    result = result.replaceAllMapped(italic, (m) => m.group(1) ?? '');
    result = result.replaceAllMapped(underline, (m) => m.group(1) ?? '');
    result = result.replaceAllMapped(strikethrough, (m) => m.group(1) ?? '');
    result = result.replaceAllMapped(blockquote, (m) => m.group(1) ?? '');
    result = result.replaceAllMapped(bulletList, (m) => m.group(1) ?? '');
    result = result.replaceAllMapped(orderedList, (m) => m.group(1) ?? '');
    return result;
  }
}
