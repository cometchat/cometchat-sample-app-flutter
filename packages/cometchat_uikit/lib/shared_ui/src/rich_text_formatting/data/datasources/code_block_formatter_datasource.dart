import 'package:flutter/material.dart';
import '../../domain/entities/format_type.dart';
import '../models/formatter_result.dart';
import '../models/attributed_text_data.dart';
import 'formatter_datasource.dart';

/// Formatter data source for code blocks using ```code``` syntax.
///
/// This formatter handles code block formatting in Markdown style:
/// - Pattern: ` ```code``` `
/// - Opening marker: ` ``` `
/// - Closing marker: ` ``` `
/// - Placeholder: `code block`
///
/// Special behavior:
/// - Enter key inside code block inserts newline without exiting
///
/// Examples:
/// - ` ```hello``` ` renders as code block "hello"
/// - Applying code block to "world" produces ` ```world``` `
/// - Applying code block with no selection inserts ` ```code block``` `
class CodeBlockFormatterDataSource implements FormatterDataSource {
  @override
  RegExp get pattern => RegExp(r'```(.+?)```', multiLine: true, dotAll: true);

  @override
  FormatType get formatType => FormatType.codeBlock;

  @override
  String get openingMarker => '```';

  @override
  String get closingMarker => '```';

  @override
  String get placeholderText => 'code block';

  @override
  FormatterResult applyFormat({
    required String text,
    required TextSelection selection,
    Map<String, dynamic>? metadata,
  }) {
    if (selection.isCollapsed) {
      // No selection - insert placeholder with markers
      final insertText = '$openingMarker$placeholderText$closingMarker';
      final newText = text.substring(0, selection.start) +
          insertText +
          text.substring(selection.end);

      // Position cursor to select the placeholder text
      final newCursorStart = selection.start + openingMarker.length;
      final newCursorEnd = newCursorStart + placeholderText.length;

      return FormatterResult(
        newText: newText,
        newCursorStart: newCursorStart,
        newCursorEnd: newCursorEnd,
      );
    } else {
      // Check if selection is inside an existing code block (toggle off)
      final toggleOffResult = _tryToggleOff(text, selection, metadata);
      if (toggleOffResult != null) {
        return toggleOffResult;
      } else {
        // Wrap selected text with code block markers
        final selectedText = text.substring(selection.start, selection.end);

        // Strip mention syntax (@displayName → displayName) within the selection
        final strippedResult = _stripMentions(selectedText, selection.start, metadata);
        final processedText = strippedResult.text;
        final preservedMentions = strippedResult.preservedMentions;

        final wrappedText = '$openingMarker$processedText$closingMarker';
        final newText = text.substring(0, selection.start) +
            wrappedText +
            text.substring(selection.end);

        final newCursorPos = selection.start + wrappedText.length;

        return FormatterResult(
          newText: newText,
          newCursorStart: newCursorPos,
          newCursorEnd: newCursorPos,
          metadata: preservedMentions.isNotEmpty
              ? {'preservedMentions': preservedMentions}
              : null,
        );
      }
    }
  }

  @override
  bool isActiveAt(String text, int position) {
    if (position < 0 || position > text.length) {
      return false;
    }

    // Check all matches to see if position is inside any code block
    for (final match in pattern.allMatches(text)) {
      // Check if position is within the match (including markers)
      if (position >= match.start && position <= match.end) {
        return true;
      }
    }

    return false;
  }

  @override
  List<AttributedTextData> getAttributedText(String text) {
    final List<AttributedTextData> attributedTexts = [];
    final matches = pattern.allMatches(text);

    for (final match in matches) {
      // Apply code block attribute to the entire match (including markers)
      // This allows the UI to style the text appropriately
      attributedTexts.add(
        AttributedTextData(
          start: match.start,
          end: match.end,
          attributes: {
            'codeBlock': true,
          },
        ),
      );
    }

    return attributedTexts;
  }

  /// Attempts to toggle off a code block if the selection falls inside one.
  ///
  /// Uses pattern matching to find code block boundaries, then removes the
  /// markers and cleans up the inner text (strips inline formatting markers,
  /// restores mentions from preserved data).
  ///
  /// Returns null if the selection is not inside a code block.
  FormatterResult? _tryToggleOff(
    String text,
    TextSelection selection,
    Map<String, dynamic>? metadata,
  ) {
    for (final match in pattern.allMatches(text)) {
      final contentStart = match.start + openingMarker.length;
      final contentEnd = match.end - closingMarker.length;

      // Check if the selection overlaps with this code block's content
      if (selection.start >= contentStart && selection.start <= contentEnd) {
        // Selection is inside this code block — toggle it off
        var innerText = text.substring(contentStart, contentEnd);

        // Strip inline formatting markers (Bug 1.15)
        innerText = _stripInlineFormattingMarkers(innerText);

        // Restore mentions from preserved data if available (Bug 1.18)
        if (metadata != null && metadata.containsKey('preservedMentions')) {
          innerText = _restoreMentions(innerText, metadata['preservedMentions']);
        }

        final newText = text.substring(0, match.start) +
            innerText +
            text.substring(match.end);

        final newCursorPos = match.start + innerText.length;

        return FormatterResult(
          newText: newText,
          newCursorStart: newCursorPos,
          newCursorEnd: newCursorPos,
        );
      }
    }
    return null;
  }

  /// Strips inline formatting markers from text during code block toggle-off.
  ///
  /// Removes bold (`**`), italic (`*`), strikethrough (`~~`), underline
  /// (`<u>`, `</u>`), and inline code (`` ` ``) markers from the text.
  /// Code block should have stripped these when applied, so they should not
  /// survive toggle-off.
  String _stripInlineFormattingMarkers(String text) {
    var result = text;
    // Order matters: strip multi-char markers before single-char ones
    // Bold ** before italic * to avoid partial stripping
    result = result.replaceAll('**', '');
    result = result.replaceAll('~~', '');
    result = result.replaceAll('</u>', '');
    result = result.replaceAll('<u>', '');
    result = result.replaceAll('`', '');
    // Strip remaining single * (italic) — but only matching pairs
    // Use regex to remove paired italic markers
    result = result.replaceAllMapped(
      RegExp(r'\*(.+?)\*'),
      (match) => match.group(1)!,
    );
    return result;
  }

  /// Restores mentions from preserved data by re-adding `@` prefix.
  ///
  /// When code block was applied, mentions were stripped from `@Name` to `Name`.
  /// This method restores them by finding the display name in the text and
  /// re-adding the `@` prefix.
  String _restoreMentions(String text, dynamic preservedMentionsData) {
    if (preservedMentionsData is! List) return text;

    final mentions = preservedMentionsData
        .cast<Map<String, dynamic>>()
        .toList()
      // Sort in reverse order so offset adjustments don't affect later mentions
      ..sort((a, b) => (b['start'] as int).compareTo(a['start'] as int));

    var result = text;
    for (final mention in mentions) {
      final name = mention['name'] as String? ?? '';
      if (name.isEmpty) continue;

      // Find the display name in the text and restore the @ prefix
      final index = result.indexOf(name);
      if (index != -1) {
        result = '${result.substring(0, index)}@$name${result.substring(index + name.length)}';
      }
    }
    return result;
  }

  /// Strips mention syntax from text, converting `@displayName` to `displayName`.
  ///
  /// Returns the processed text and a list of preserved mention data for
  /// potential restoration when code block is toggled off.
  ///
  /// If [metadata] contains `mentionRanges`, those exact ranges are used.
  /// Otherwise, falls back to regex detection of `@word` patterns.
  _StripMentionsResult _stripMentions(
    String selectedText,
    int selectionStart,
    Map<String, dynamic>? metadata,
  ) {
    final preservedMentions = <Map<String, dynamic>>[];

    // Use mention ranges from metadata if available
    if (metadata != null && metadata.containsKey('mentionRanges')) {
      final ranges = metadata['mentionRanges'] as List<dynamic>;
      var processedText = selectedText;
      var offset = 0;

      final sortedRanges = ranges
          .cast<Map<String, dynamic>>()
          .toList()
        ..sort((a, b) => (a['start'] as int).compareTo(b['start'] as int));

      for (final range in sortedRanges) {
        final mStart = (range['start'] as int) - selectionStart;
        final mEnd = (range['end'] as int) - selectionStart;
        final uid = range['uid'] as String?;
        final name = range['name'] as String?;

        if (mStart + offset >= 0 && mEnd + offset <= processedText.length) {
          final mentionText = processedText.substring(mStart + offset, mEnd + offset);
          if (mentionText.startsWith('@')) {
            final plainName = mentionText.substring(1);
            processedText = processedText.substring(0, mStart + offset) +
                plainName +
                processedText.substring(mEnd + offset);

            preservedMentions.add({
              'start': mStart + selectionStart + offset,
              'end': mStart + selectionStart + offset + plainName.length,
              'uid': uid ?? '',
              'name': name ?? plainName,
            });

            offset -= 1; // Removed one '@' character
          }
        }
      }

      return _StripMentionsResult(text: processedText, preservedMentions: preservedMentions);
    }

    // Fallback: regex-based detection of @mention patterns
    final mentionPattern = RegExp(r'@(\w+)');
    var processedText = selectedText;
    var offset = 0;

    for (final match in mentionPattern.allMatches(selectedText)) {
      final displayName = match.group(1)!;
      final adjustedStart = match.start + offset;

      preservedMentions.add({
        'start': adjustedStart + selectionStart,
        'end': adjustedStart + selectionStart + displayName.length,
        'uid': '',
        'name': displayName,
      });

      processedText = processedText.substring(0, adjustedStart) +
          displayName +
          processedText.substring(adjustedStart + match.group(0)!.length);

      offset -= 1; // Removed one '@' character
    }

    return _StripMentionsResult(text: processedText, preservedMentions: preservedMentions);
  }

  /// Handle Enter key press inside code block.
  ///
  /// When Enter is pressed inside a code block, insert a newline
  /// without exiting the block.
  ///
  /// Returns null if cursor is not inside a code block.
  FormatterResult? handleEnterKey({
    required String text,
    required TextSelection selection,
  }) {
    if (!selection.isCollapsed) {
      return null; // Only handle collapsed cursor
    }

    final position = selection.start;

    // Find if cursor is inside a code block
    for (final match in pattern.allMatches(text)) {
      final contentStart = match.start + openingMarker.length;
      final contentEnd = match.end - closingMarker.length;

      // Check if cursor is inside the code block content
      if (position >= contentStart && position <= contentEnd) {
        // Insert newline at cursor position
        final newText = text.substring(0, position) +
            '\n' +
            text.substring(position);

        final newCursorPos = position + 1;

        return FormatterResult(
          newText: newText,
          newCursorStart: newCursorPos,
          newCursorEnd: newCursorPos,
        );
      }
    }

    return null; // Not inside a code block
  }
}

/// Helper class for the result of stripping mentions from text.
class _StripMentionsResult {
  final String text;
  final List<Map<String, dynamic>> preservedMentions;

  const _StripMentionsResult({
    required this.text,
    required this.preservedMentions,
  });
}
