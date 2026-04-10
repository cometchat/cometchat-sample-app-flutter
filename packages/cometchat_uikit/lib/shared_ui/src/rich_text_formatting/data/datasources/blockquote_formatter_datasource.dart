import 'package:flutter/material.dart';
import '../../domain/entities/format_type.dart';
import '../models/formatter_result.dart';
import '../models/attributed_text_data.dart';
import 'formatter_datasource.dart';

/// Formatter data source for blockquotes using > text syntax.
///
/// This formatter handles blockquote formatting in Markdown style:
/// - Pattern: `^> (.+)$` (multiline)
/// - Opening marker: `> `
/// - Closing marker: (none)
/// - Placeholder: `quote`
///
/// Special behavior:
/// - Enter key at end of blockquote line continues the blockquote
///
/// Examples:
/// - `> hello` renders as blockquote "hello"
/// - Applying blockquote to "world" produces `> world`
/// - Applying blockquote with no selection inserts `> quote`
class BlockquoteFormatterDataSource implements FormatterDataSource {
  @override
  RegExp get pattern => RegExp(r'^> (.+)$', multiLine: true);

  @override
  FormatType get formatType => FormatType.blockquote;

  @override
  String get openingMarker => '> ';

  @override
  String get closingMarker => '';

  @override
  String get placeholderText => 'quote';

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

      // Check if already a blockquote
      if (currentLine.startsWith(openingMarker)) {
        // Remove blockquote marker (toggle off)
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
        // Add blockquote marker at start of line
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
      // Apply blockquote to each line in selection
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
      // Apply blockquote attribute to the entire match (including marker)
      // This allows the UI to style the text appropriately
      attributedTexts.add(
        AttributedTextData(
          start: match.start,
          end: match.end,
          attributes: {
            'blockquote': true,
          },
        ),
      );
    }

    return attributedTexts;
  }

  /// Handle Enter key press inside blockquote.
  ///
  /// When Enter is pressed at the end of a blockquote line,
  /// continue the blockquote on the next line.
  ///
  /// Returns null if cursor is not in a blockquote.
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

    // Check if current line is a blockquote
    if (!currentLine.startsWith(openingMarker)) {
      return null;
    }

    // Continue blockquote on next line
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
