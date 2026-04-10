import 'package:flutter/material.dart';
import '../../domain/entities/format_type.dart';
import '../models/formatter_result.dart';
import '../models/attributed_text_data.dart';
import 'formatter_datasource.dart';

/// Formatter data source for bullet lists using - item syntax.
///
/// This formatter handles bullet list formatting in Markdown style:
/// - Pattern: `^- (.+)$` (multiline)
/// - Opening marker: `- `
/// - Closing marker: (none)
/// - Placeholder: `list item`
///
/// Special behavior:
/// - Enter key at end of list item creates new bullet
/// - Enter key on empty list item exits the list
///
/// Examples:
/// - `- hello` renders as bullet list item "hello"
/// - Applying bullet list to "world" produces `- world`
/// - Applying bullet list with no selection inserts `- list item`
class BulletListFormatterDataSource implements FormatterDataSource {
  @override
  RegExp get pattern => RegExp(r'^- (.+)$', multiLine: true);

  @override
  FormatType get formatType => FormatType.bulletList;

  @override
  String get openingMarker => '- ';

  @override
  String get closingMarker => '';

  @override
  String get placeholderText => 'list item';

  @override
  FormatterResult applyFormat({
    required String text,
    required TextSelection selection,
    Map<String, dynamic>? metadata,
  }) {
    if (selection.isCollapsed) {
      // Find the start of the current line
      final lineStart = _findLineStart(text, selection.start);
      final lineEnd = _findLineEnd(text, selection.start);
      final currentLine = text.substring(lineStart, lineEnd);

      // Check if already a bullet list item
      if (currentLine.startsWith(openingMarker)) {
        // Remove bullet marker (toggle off)
        final newText = text.substring(0, lineStart) +
            currentLine.substring(openingMarker.length) +
            text.substring(lineEnd);

        final newCursorPos = selection.start - openingMarker.length;

        return FormatterResult(
          newText: newText,
          newCursorStart: newCursorPos,
          newCursorEnd: newCursorPos,
        );
      } else {
        // Add bullet marker at start of line
        final newText = text.substring(0, lineStart) +
            openingMarker +
            text.substring(lineStart);

        final newCursorPos = selection.start + openingMarker.length;

        return FormatterResult(
          newText: newText,
          newCursorStart: newCursorPos,
          newCursorEnd: newCursorPos,
        );
      }
    } else {
      // Apply bullet list to each line in selection
      final lines = text.split('\n');
      final selectionStartLine = _getLineNumber(text, selection.start);
      final selectionEndLine = _getLineNumber(text, selection.end);

      for (int i = selectionStartLine; i <= selectionEndLine; i++) {
        if (i < lines.length && lines[i].isNotEmpty && !lines[i].startsWith(openingMarker)) {
          lines[i] = '$openingMarker${lines[i]}';
        }
      }

      final newText = lines.join('\n');
      final newCursorPos = selection.end + (openingMarker.length * (selectionEndLine - selectionStartLine + 1));

      return FormatterResult(
        newText: newText,
        newCursorStart: newCursorPos,
        newCursorEnd: newCursorPos,
      );
    }
  }

  @override
  bool isActiveAt(String text, int position) {
    if (position < 0 || position > text.length) {
      return false;
    }

    // Find the current line
    final lineStart = _findLineStart(text, position);
    final lineEnd = _findLineEnd(text, position);
    final currentLine = text.substring(lineStart, lineEnd);

    return currentLine.startsWith(openingMarker);
  }

  @override
  List<AttributedTextData> getAttributedText(String text) {
    final List<AttributedTextData> attributedTexts = [];
    final matches = pattern.allMatches(text);

    for (final match in matches) {
      // Apply bullet list attribute to the entire match (including marker)
      // This allows the UI to style the text appropriately
      attributedTexts.add(
        AttributedTextData(
          start: match.start,
          end: match.end,
          attributes: {
            'bulletList': true,
          },
        ),
      );
    }

    return attributedTexts;
  }

  /// Handle Enter key press inside bullet list.
  ///
  /// When Enter is pressed at the end of a bullet list item:
  /// - If item has content: Create new bullet list item
  /// - If item is empty: Exit the list (remove bullet marker)
  ///
  /// Returns null if cursor is not in a bullet list.
  FormatterResult? handleEnterKey({
    required String text,
    required TextSelection selection,
  }) {
    if (!selection.isCollapsed) {
      return null; // Only handle collapsed cursor
    }

    final position = selection.start;
    final lineStart = _findLineStart(text, position);
    final lineEnd = _findLineEnd(text, position);
    final currentLine = text.substring(lineStart, lineEnd);

    // Check if current line is a bullet list item
    if (!currentLine.startsWith(openingMarker)) {
      return null;
    }

    final lineContent = currentLine.substring(openingMarker.length).trim();

    if (lineContent.isEmpty) {
      // Empty list item - exit the list
      final newText = text.substring(0, lineStart) +
          text.substring(lineEnd);

      final newCursorPos = lineStart;

      return FormatterResult(
        newText: newText,
        newCursorStart: newCursorPos,
        newCursorEnd: newCursorPos,
      );
    } else {
      // Non-empty list item - create new bullet
      final newText = text.substring(0, position) +
          '\n$openingMarker' +
          text.substring(position);

      final newCursorPos = position + 1 + openingMarker.length;

      return FormatterResult(
        newText: newText,
        newCursorStart: newCursorPos,
        newCursorEnd: newCursorPos,
      );
    }
  }

  int _findLineStart(String text, int position) {
    final lastNewline = text.lastIndexOf('\n', position - 1);
    return lastNewline == -1 ? 0 : lastNewline + 1;
  }

  int _findLineEnd(String text, int position) {
    final nextNewline = text.indexOf('\n', position);
    return nextNewline == -1 ? text.length : nextNewline;
  }

  int _getLineNumber(String text, int position) {
    return text.substring(0, position).split('\n').length - 1;
  }
}
