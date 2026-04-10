import 'package:flutter/material.dart';

/// Supported rich text format types
///
/// @Deprecated: Use [FormatType] from the rich_text_formatting module instead.
///
/// Migration guide:
/// ```dart
/// // Old way:
/// RichTextFormatType.bold
///
/// // New way:
/// import 'package:cometchat_chat_uikit/shared_ui/src/rich_text_formatting/rich_text_formatting.dart';
/// FormatType.bold
/// ```
@Deprecated(
  'Use FormatType from rich_text_formatting module instead. '
  'The new FormatType enum provides the same values with Clean Architecture support.',
)
enum RichTextFormatType {
  bold,
  italic,
  strikethrough,
  inlineCode,
  codeBlock,
  link,
  bulletList,
  orderedList,
  blockquote,
  underline,
}

/// Extension providing icons and labels for format types
extension RichTextFormatTypeExtension on RichTextFormatType {
  /// Get the icon for this format type
  IconData get icon {
    switch (this) {
      case RichTextFormatType.bold:
        return Icons.format_bold;
      case RichTextFormatType.italic:
        return Icons.format_italic;
      case RichTextFormatType.strikethrough:
        return Icons.strikethrough_s;
      case RichTextFormatType.inlineCode:
        return Icons.code;
      case RichTextFormatType.codeBlock:
        return Icons.integration_instructions;
      case RichTextFormatType.link:
        return Icons.link;
      case RichTextFormatType.bulletList:
        return Icons.format_list_bulleted;
      case RichTextFormatType.orderedList:
        return Icons.format_list_numbered;
      case RichTextFormatType.blockquote:
        return Icons.format_quote;
      case RichTextFormatType.underline:
        return Icons.format_underline;
    }
  }

  /// Get the tooltip/label for this format type
  String get label {
    switch (this) {
      case RichTextFormatType.bold:
        return 'Bold';
      case RichTextFormatType.italic:
        return 'Italic';
      case RichTextFormatType.strikethrough:
        return 'Strikethrough';
      case RichTextFormatType.inlineCode:
        return 'Inline Code';
      case RichTextFormatType.codeBlock:
        return 'Code Block';
      case RichTextFormatType.link:
        return 'Link';
      case RichTextFormatType.bulletList:
        return 'Bullet List';
      case RichTextFormatType.orderedList:
        return 'Numbered List';
      case RichTextFormatType.blockquote:
        return 'Quote';
      case RichTextFormatType.underline:
        return 'Underline';
    }
  }

  /// Get the opening marker for this format type
  String get openingMarker {
    switch (this) {
      case RichTextFormatType.bold:
        return '**';
      case RichTextFormatType.italic:
        return '_';
      case RichTextFormatType.strikethrough:
        return '~~';
      case RichTextFormatType.inlineCode:
        return '`';
      case RichTextFormatType.codeBlock:
        return '```\n';
      case RichTextFormatType.link:
        return '[';
      case RichTextFormatType.bulletList:
        return '- ';
      case RichTextFormatType.orderedList:
        return '1. ';
      case RichTextFormatType.blockquote:
        return '> ';
      case RichTextFormatType.underline:
        return '<u>';
    }
  }

  /// Get the closing marker for this format type
  String get closingMarker {
    switch (this) {
      case RichTextFormatType.bold:
        return '**';
      case RichTextFormatType.italic:
        return '_';
      case RichTextFormatType.strikethrough:
        return '~~';
      case RichTextFormatType.inlineCode:
        return '`';
      case RichTextFormatType.codeBlock:
        return '\n```';
      case RichTextFormatType.link:
        return ')';
      case RichTextFormatType.bulletList:
        return '';
      case RichTextFormatType.orderedList:
        return '';
      case RichTextFormatType.blockquote:
        return '';
      case RichTextFormatType.underline:
        return '</u>';
    }
  }
}
