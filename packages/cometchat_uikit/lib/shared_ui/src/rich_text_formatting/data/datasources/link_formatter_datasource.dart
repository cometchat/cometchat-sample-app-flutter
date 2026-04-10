import 'package:flutter/material.dart';
import '../../domain/entities/format_type.dart';
import '../models/formatter_result.dart';
import '../models/attributed_text_data.dart';
import 'formatter_datasource.dart';


/// Formatter data source for links using [text](url) syntax.
///
/// This formatter handles link formatting in Markdown style:
/// - Pattern: `[text](url)`
/// - Opening marker: `[`
/// - Closing marker: `](`
/// - Placeholder: `link text`
///
/// Metadata:
/// - `url`: The URL for the link
/// - `displayText`: The display text for the link
///
/// Examples:
/// - `[Google](https://google.com)` renders as link "Google"
/// - Applying link with metadata produces `[displayText](url)`
/// - Applying link with no selection inserts `[link text](url)`
class LinkFormatterDataSource implements FormatterDataSource {
  @override
  RegExp get pattern => RegExp(r'\[([^\]]+)\]\(([^)]+)\)');

  @override
  FormatType get formatType => FormatType.link;

  @override
  String get openingMarker => '[';

  @override
  String get closingMarker => '](';

  @override
  String get placeholderText => 'link text';

  @override
  FormatterResult applyFormat({
    required String text,
    required TextSelection selection,
    Map<String, dynamic>? metadata,
  }) {
    final url = metadata?['url'] as String? ?? 'url';
    final displayText = metadata?['displayText'] as String?;

    // If inside a code block, insert raw URL only (no markdown link syntax)
    if (metadata != null && _isInsideCodeBlock(text, selection.start)) {
      final rawUrl = url;
      final newText = text.substring(0, selection.start) +
          rawUrl +
          text.substring(selection.end);
      final newCursorPos = selection.start + rawUrl.length;
      return FormatterResult(
        newText: newText,
        newCursorStart: newCursorPos,
        newCursorEnd: newCursorPos,
      );
    }

    if (selection.isCollapsed) {
      // No selection - insert placeholder with markers and URL
      final linkText = displayText ?? placeholderText;
      final insertText = '[$linkText]($url)';
      final newText = text.substring(0, selection.start) +
          insertText +
          text.substring(selection.end);

      // Position cursor to select the link text
      final newCursorStart = selection.start + 1; // After '['
      final newCursorEnd = newCursorStart + linkText.length;

      return FormatterResult(
        newText: newText,
        newCursorStart: newCursorStart,
        newCursorEnd: newCursorEnd,
      );
    } else {
      // Check if selection is already a link
      final beforeSelection = selection.start >= openingMarker.length
          ? text.substring(
              selection.start - openingMarker.length, selection.start)
          : '';

      // Find the closing marker after selection
      final afterSelectionStart = selection.end;
      final afterSelectionEnd = afterSelectionStart + closingMarker.length <= text.length
          ? afterSelectionStart + closingMarker.length
          : text.length;
      final afterSelection = text.substring(afterSelectionStart, afterSelectionEnd);

      if (beforeSelection == openingMarker && afterSelection == closingMarker) {
        // Already a link - check if we should remove it or update it
        // Find the URL part: ](url)
        final urlStart = selection.end + closingMarker.length;
        final urlEndMatch = text.indexOf(')', urlStart);
        
        if (urlEndMatch != -1) {
          if (metadata == null) {
            // Remove link formatting (toggle off)
            final linkText = text.substring(selection.start, selection.end);
            final newText = text.substring(0, selection.start - openingMarker.length) +
                linkText +
                text.substring(urlEndMatch + 1);

            final newCursorPos = selection.start - openingMarker.length + linkText.length;

            return FormatterResult(
              newText: newText,
              newCursorStart: newCursorPos,
              newCursorEnd: newCursorPos,
            );
          } else {
            // Update existing link with new URL/text
            final linkText = displayText ?? text.substring(selection.start, selection.end);
            final newLinkText = '[$linkText]($url)';
            final newText = text.substring(0, selection.start - openingMarker.length) +
                newLinkText +
                text.substring(urlEndMatch + 1);

            final newCursorPos = selection.start - openingMarker.length + newLinkText.length;

            return FormatterResult(
              newText: newText,
              newCursorStart: newCursorPos,
              newCursorEnd: newCursorPos,
            );
          }
        }
      }

      // Wrap selected text with link markers
      final linkText = displayText ?? text.substring(selection.start, selection.end);
      final wrappedText = '[$linkText]($url)';
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

  @override
  bool isActiveAt(String text, int position) {
    if (position < 0 || position > text.length) {
      return false;
    }

    // Check all matches to see if position is inside any link
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
      final displayText = match.group(1) ?? '';
      final url = match.group(2) ?? '';

      // Apply link attribute to the entire match (including markers)
      // This allows the UI to style the text appropriately
      attributedTexts.add(
        AttributedTextData(
          start: match.start,
          end: match.end,
          attributes: {
            'link': true,
            'url': url,
            'displayText': displayText,
          },
        ),
      );
    }

    return attributedTexts;
  }

  /// Code block pattern for detecting if cursor is inside a code block.
  static final RegExp _codeBlockPattern =
      RegExp(r'```(.+?)```', multiLine: true, dotAll: true);

  /// Check if a position in the text is inside a code block.
  bool _isInsideCodeBlock(String text, int position) {
    for (final match in _codeBlockPattern.allMatches(text)) {
      if (position >= match.start && position <= match.end) {
        return true;
      }
    }
    return false;
  }

  /// Apply link embedding on paste.
  ///
  /// When a URL is pasted while text is selected, wraps the selected text
  /// as `[selectedText](url)`. When pasted inside a code block, inserts
  /// the raw URL text only (no markdown link syntax).
  ///
  /// Parameters:
  /// - [text]: The full text content
  /// - [selection]: The current text selection
  /// - [url]: The URL from the clipboard
  ///
  /// Returns a [FormatterResult] with the new text and cursor position.
  FormatterResult applyLinkEmbed({
    required String text,
    required TextSelection selection,
    required String url,
  }) {
    // If inside a code block, insert raw URL only (no markdown link syntax)
    if (_isInsideCodeBlock(text, selection.start)) {
      final newText = text.substring(0, selection.start) +
          url +
          text.substring(selection.end);
      final newCursorPos = selection.start + url.length;
      return FormatterResult(
        newText: newText,
        newCursorStart: newCursorPos,
        newCursorEnd: newCursorPos,
      );
    }

    // If text is selected, wrap as [selectedText](url)
    if (!selection.isCollapsed) {
      final selectedText = text.substring(selection.start, selection.end);
      final linkText = '[$selectedText]($url)';
      final newText = text.substring(0, selection.start) +
          linkText +
          text.substring(selection.end);
      final newCursorPos = selection.start + linkText.length;
      return FormatterResult(
        newText: newText,
        newCursorStart: newCursorPos,
        newCursorEnd: newCursorPos,
      );
    }

    // No selection, not in code block — insert raw URL at cursor
    final newText = text.substring(0, selection.start) +
        url +
        text.substring(selection.end);
    final newCursorPos = selection.start + url.length;
    return FormatterResult(
      newText: newText,
      newCursorStart: newCursorPos,
      newCursorEnd: newCursorPos,
    );
  }
}
