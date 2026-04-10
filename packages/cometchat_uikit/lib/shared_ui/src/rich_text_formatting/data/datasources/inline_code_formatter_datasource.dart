import 'package:flutter/material.dart';
import '../../domain/entities/format_type.dart';
import '../models/formatter_result.dart';
import '../models/attributed_text_data.dart';
import 'formatter_datasource.dart';

/// Formatter data source for inline code using `code` syntax.
///
/// This formatter handles inline code formatting in Markdown style:
/// - Pattern: `` `code` ``
/// - Opening marker: `` ` ``
/// - Closing marker: `` ` ``
/// - Placeholder: `code`
///
/// Examples:
/// - `` `hello` `` renders as inline code "hello"
/// - Applying inline code to "world" produces `` `world` ``
/// - Applying inline code with no selection inserts `` `code` ``
class InlineCodeFormatterDataSource implements FormatterDataSource {
  @override
  RegExp get pattern => RegExp(r'`(.+?)`');

  @override
  FormatType get formatType => FormatType.inlineCode;

  @override
  String get openingMarker => '`';

  @override
  String get closingMarker => '`';

  @override
  String get placeholderText => 'code';

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
      // Check if selection is already wrapped with inline code markers
      final beforeSelection = selection.start >= openingMarker.length
          ? text.substring(
              selection.start - openingMarker.length, selection.start)
          : '';
      final afterSelection = selection.end + closingMarker.length <= text.length
          ? text.substring(selection.end, selection.end + closingMarker.length)
          : '';

      if (beforeSelection == openingMarker && afterSelection == closingMarker) {
        // Remove inline code markers (toggle off)
        final newText = text.substring(0, selection.start - openingMarker.length) +
            text.substring(selection.start, selection.end) +
            text.substring(selection.end + closingMarker.length);

        final newCursorPos = selection.end - openingMarker.length;

        return FormatterResult(
          newText: newText,
          newCursorStart: newCursorPos,
          newCursorEnd: newCursorPos,
        );
      } else {
        // Wrap selected text with inline code markers
        final selectedText = text.substring(selection.start, selection.end);
        final wrappedText = '$openingMarker$selectedText$closingMarker';
        final newText = text.substring(0, selection.start) +
            wrappedText +
            text.substring(selection.end);

        final newCursorPos = selection.start + wrappedText.length;

        return FormatterResult(
          newText: newText,
          newCursorStart: newCursorPos,
          newCursorEnd: newCursorPos,
        );
      }
    }
  }

  @override
  bool isActiveAt(String text, int position) {
    if (position < 0 || position > text.length) {
      return false;
    }

    // Check all matches to see if position is inside any inline code text
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
      // Apply inline code attribute to the entire match (including markers)
      // This allows the UI to style the text appropriately
      attributedTexts.add(
        AttributedTextData(
          start: match.start,
          end: match.end,
          attributes: {
            'inlineCode': true,
          },
        ),
      );
    }

    return attributedTexts;
  }
}
