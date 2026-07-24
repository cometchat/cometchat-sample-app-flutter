import 'package:flutter/material.dart';
import '../../domain/entities/format_type.dart';
import '../models/formatter_result.dart';
import '../models/attributed_text_data.dart';
import 'formatter_datasource.dart';

/// Formatter data source for ordered lists using 1. item syntax.
///
/// This formatter handles ordered list formatting in Markdown style:
/// - Pattern: `^\d+\. (.+)$` (multiline)
/// - Opening marker: `1. ` (with number increment)
/// - Closing marker: (none)
/// - Placeholder: `list item`
///
/// Special behavior:
/// - Enter key at end of list item creates new numbered item (increments number)
/// - Enter key on empty list item exits the list
///
/// Examples:
/// - `1. hello` renders as ordered list item "hello"
/// - Applying ordered list to "world" produces `1. world`
/// - Applying ordered list with no selection inserts `1. list item`
class OrderedListFormatterDataSource implements FormatterDataSource {
  @override
  RegExp get pattern => RegExp(r'^(\d+)\. (.+)$', multiLine: true);

  @override
  FormatType get formatType => FormatType.orderedList;

  @override
  String get openingMarker => '1. ';

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

      // Check if already an ordered list item
      final match = RegExp(r'^(\d+)\. ').firstMatch(currentLine);
      if (match != null) {
        // Remove ordered list marker (toggle off)
        final markerLength = match.group(0)!.length;
        final newText =
            text.substring(0, lineStart) +
            currentLine.substring(markerLength) +
            text.substring(lineEnd);

        final newCursorPos = selection.start - markerLength;

        return FormatterResult(
          newText: newText,
          newCursorStart: newCursorPos,
          newCursorEnd: newCursorPos,
        );
      } else {
        // Add ordered list marker at start of line
        final newText =
            text.substring(0, lineStart) +
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
      // Apply ordered list to each line in selection
      final lines = text.split('\n');
      final selectionStartLine = _getLineNumber(text, selection.start);
      final selectionEndLine = _getLineNumber(text, selection.end);

      int number = 1;
      int totalMarkerLength = 0;

      for (int i = selectionStartLine; i <= selectionEndLine; i++) {
        if (i < lines.length && lines[i].isNotEmpty) {
          final match = RegExp(r'^(\d+)\. ').firstMatch(lines[i]);
          if (match == null) {
            final marker = '$number. ';
            lines[i] = '$marker${lines[i]}';
            totalMarkerLength += marker.length;
            number++;
          }
        }
      }

      final newText = lines.join('\n');
      final newCursorPos = selection.end + totalMarkerLength;

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

    return RegExp(r'^(\d+)\. ').hasMatch(currentLine);
  }

  @override
  List<AttributedTextData> getAttributedText(String text) {
    final List<AttributedTextData> attributedTexts = [];
    final matches = pattern.allMatches(text);

    for (final match in matches) {
      final number = match.group(1) ?? '1';

      // Apply ordered list attribute to the entire match (including marker)
      // This allows the UI to style the text appropriately
      attributedTexts.add(
        AttributedTextData(
          start: match.start,
          end: match.end,
          attributes: {'orderedList': true, 'number': number},
        ),
      );
    }

    return attributedTexts;
  }

  /// Handle Enter key press inside ordered list.
  ///
  /// When Enter is pressed at the end of an ordered list item:
  /// - If item has content: Create new ordered list item (increment number)
  /// - If item is empty: Exit the list (remove ordered list marker)
  ///
  /// Returns null if cursor is not in an ordered list.
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

    // Check if current line is an ordered list item
    final match = RegExp(r'^(\d+)\. ').firstMatch(currentLine);
    if (match == null) {
      return null;
    }

    final currentNumber = int.tryParse(match.group(1) ?? '1') ?? 1;
    final markerLength = match.group(0)!.length;
    final lineContent = currentLine.substring(markerLength).trim();

    if (lineContent.isEmpty) {
      // Empty list item - exit the list
      final newText = text.substring(0, lineStart) + text.substring(lineEnd);

      final newCursorPos = lineStart;

      return FormatterResult(
        newText: newText,
        newCursorStart: newCursorPos,
        newCursorEnd: newCursorPos,
      );
    } else {
      // Non-empty list item - create new ordered item with incremented number
      final nextNumber = currentNumber + 1;
      final nextMarker = '$nextNumber. ';
      final newText =
          '${text.substring(0, position)}\n$nextMarker${text.substring(position)}';

      final newCursorPos = position + 1 + nextMarker.length;

      // Renumber subsequent ordered list items
      final renumbered = _renumberFrom(newText, newCursorPos, nextNumber + 1);

      return FormatterResult(
        newText: renumbered,
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

  /// Renumber ordered list items starting from [startPos] in [text].
  /// [expectedNumber] is the number the next ordered list line should have.
  /// Continues renumbering contiguous ordered list lines until a non-list line
  /// is found or the text ends.
  String _renumberFrom(String text, int startPos, int expectedNumber) {
    final lines = text.split('\n');
    final orderedListRegex = RegExp(r'^(\d+)\. ');

    // Find which line startPos falls on
    int charCount = 0;
    int startLine = 0;
    for (int i = 0; i < lines.length; i++) {
      final lineLen = lines[i].length + 1; // +1 for '\n'
      if (charCount + lineLen > startPos) {
        startLine = i;
        break;
      }
      charCount += lineLen;
    }

    // Start renumbering from the line after the inserted one
    int num = expectedNumber;
    for (int i = startLine + 1; i < lines.length; i++) {
      final match = orderedListRegex.firstMatch(lines[i]);
      if (match == null) break; // End of contiguous list block
      final existingNum = int.tryParse(match.group(1)!) ?? 0;
      if (existingNum != num) {
        lines[i] = '$num. ${lines[i].substring(match.end)}';
      }
      num++;
    }

    return lines.join('\n');
  }
}
