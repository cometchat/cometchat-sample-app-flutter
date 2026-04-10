import 'package:flutter/material.dart';
import '../../clean_architecture/presentation/formatters/cometchat_text_formatter.dart';
import '../../clean_architecture/presentation/formatters/attributed_text.dart';
import '../../clean_architecture/core/constants/enums.dart';
import 'format_result.dart';
import 'rich_text_format_type.dart';

/// Base class for rich text formatters with common functionality
///
/// @Deprecated: Use [FormatterDataSource] from the rich_text_formatting module instead.
///
/// Migration guide:
/// ```dart
/// // Old way:
/// class MyFormatter extends RichTextFormatterBase { ... }
///
/// // New way:
/// class MyFormatterDataSource implements FormatterDataSource { ... }
/// ```
@Deprecated(
  'Use FormatterDataSource from rich_text_formatting module instead. '
  'The new data source pattern provides better separation of concerns.',
)
abstract class RichTextFormatterBase extends CometChatTextFormatter {
  RichTextFormatterBase({
    required String trackingCharacter,
    required RegExp pattern,
    required this.openingMarker,
    required this.closingMarker,
    required this.placeholderText,
  }) : super(
          trackingCharacter: trackingCharacter,
          pattern: pattern,
        );

  /// Opening marker for the format (e.g., "**" for bold)
  final String openingMarker;

  /// Closing marker for the format (e.g., "**" for bold)
  final String closingMarker;

  /// Placeholder text when no selection
  final String placeholderText;

  /// The format type this formatter handles
  RichTextFormatType get formatType;

  /// Apply format to selected text or insert at cursor
  FormatResult applyToSelection(String text, TextSelection selection) {
    if (selection.isCollapsed) {
      // No selection - insert placeholder
      final insertText = '$openingMarker$placeholderText$closingMarker';
      final newText = text.substring(0, selection.start) +
          insertText +
          text.substring(selection.end);

      // Position cursor to select the placeholder text
      final newCursorPos = selection.start + openingMarker.length;
      return FormatResult(
        newText: newText,
        newSelection: TextSelection(
          baseOffset: newCursorPos,
          extentOffset: newCursorPos + placeholderText.length,
        ),
        formatApplied: formatType,
      );
    } else {
      // Wrap selected text
      final selectedText = text.substring(selection.start, selection.end);
      final wrappedText = '$openingMarker$selectedText$closingMarker';
      final newText = text.substring(0, selection.start) +
          wrappedText +
          text.substring(selection.end);

      return FormatResult(
        newText: newText,
        newSelection: TextSelection.collapsed(
          offset: selection.start + wrappedText.length,
        ),
        formatApplied: formatType,
      );
    }
  }

  /// Check if format is active at the given position
  bool isActiveAtPosition(String text, int position) {
    if (pattern == null) return false;

    for (final match in pattern!.allMatches(text)) {
      if (position >= match.start && position <= match.end) {
        return true;
      }
    }
    return false;
  }

  @override
  void init() {
    // Initialize formatter - no-op for rich text formatters
  }

  @override
  void handlePreMessageSend(BuildContext context, dynamic baseMessage) {
    // Markdown syntax is preserved in message text - no transformation needed
  }

  @override
  void onScrollToBottom(TextEditingController textEditingController) {
    // Not used for rich text formatters
  }

  @override
  void onChange(
      TextEditingController textEditingController, String previousText) {
    // Can be overridden for auto-formatting behavior
  }

  @override
  TextStyle getMessageInputTextStyle(BuildContext context) {
    // Return default text style for input field
    return const TextStyle();
  }

  /// Get the text style for this format type in the input field
  /// Subclasses should override this to provide format-specific styling
  TextStyle getInputFieldTextStyle(BuildContext context) {
    return getMessageInputTextStyle(context);
  }

  @override
  List<AttributedText> buildInputFieldText({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
    required String text,
    List<AttributedText>? existingAttributes,
  }) {
    if (pattern == null) {
      return existingAttributes ?? [];
    }

    final List<AttributedText> attributedTexts = [];
    final matches = pattern!.allMatches(text);

    for (final match in matches) {
      // Apply style to the entire match (including markers)
      final start = match.start;
      final end = match.end;

      // Get the style for this format
      final formatStyle = getInputFieldTextStyle(context);

      // Extract the content without markers for WYSIWYG display
      // Group 1 contains the text between markers (e.g., "bold" from "**bold**")
      final contentText = match.group(1);

      attributedTexts.add(
        AttributedText(
          start: start,
          end: end,
          // Set underlyingText to show only the content without markers (WYSIWYG)
          underlyingText: contentText,
          // Format style should override the base style
          style: formatStyle,
        ),
      );
    }

    // Merge with existing attributes
    if (existingAttributes != null && existingAttributes.isNotEmpty) {
      return mergeAttributedText(attributedTexts, existingAttributes);
    }

    return attributedTexts;
  }

  @override
  List<AttributedText> getAttributedText(
      String text, BuildContext context, BubbleAlignment? alignment,
      {List<AttributedText>? existingAttributes,
      Function(String)? onTap,
      bool forConversation = false}) {
    if (pattern == null) {
      return existingAttributes ?? [];
    }

    List<AttributedText> attributedTexts = [];
    final matches = pattern!.allMatches(text);
    attributedTexts = matches.map((match) {
      int start = match.start;
      int end = match.end;

      // Extract the content without markers for WYSIWYG display
      // Group 1 contains the text between markers (e.g., "bold" from "**bold**")
      String? contentText = match.group(1);
      
      // Recursively strip any nested markdown markers from the content
      if (contentText != null) {
        contentText = _stripAllMarkdownMarkers(contentText);
      }

      return AttributedText(
          start: start,
          end: end,
          // Set underlyingText to show only the content without markers (WYSIWYG)
          underlyingText: contentText,
          style: getMessageBubbleTextStyle(context, alignment,
              forConversation: forConversation),
          onTap: onTap);
    }).toList();
    if (existingAttributes != null && existingAttributes.isNotEmpty) {
      return mergeAttributedText(attributedTexts, existingAttributes);
    } else {
      return attributedTexts;
    }
  }
  
  /// Strip all markdown markers from text (for nested formats)
  static String _stripAllMarkdownMarkers(String text) {
    String result = text;
    
    // Strip bold markers **text** -> text
    result = result.replaceAllMapped(
      RegExp(r'\*\*(.+?)\*\*'),
      (m) => m.group(1) ?? '',
    );
    
    // Strip italic markers _text_ -> text
    result = result.replaceAllMapped(
      RegExp(r'_(.+?)_'),
      (m) => m.group(1) ?? '',
    );
    
    // Strip strikethrough markers ~~text~~ -> text
    result = result.replaceAllMapped(
      RegExp(r'~~(.+?)~~'),
      (m) => m.group(1) ?? '',
    );
    
    // Strip inline code markers `text` -> text
    result = result.replaceAllMapped(
      RegExp(r'`([^`]+)`'),
      (m) => m.group(1) ?? '',
    );
    
    return result;
  }
}
