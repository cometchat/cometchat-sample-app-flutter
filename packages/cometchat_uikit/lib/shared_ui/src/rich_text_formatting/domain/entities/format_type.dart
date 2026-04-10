import 'package:flutter/material.dart';

/// Enum representing different text formatting types supported by the rich text editor.
///
/// Each format type corresponds to a specific Markdown-style formatting option.
enum FormatType {
  /// Bold text formatting (**text**)
  bold,

  /// Italic text formatting (*text* or _text_)
  italic,

  /// Strikethrough text formatting (~~text~~)
  strikethrough,

  /// Inline code formatting (`code`)
  inlineCode,

  /// Code block formatting (```code```)
  codeBlock,

  /// Hyperlink formatting ([text](url))
  link,

  /// Bullet list formatting (- item)
  bulletList,

  /// Ordered list formatting (1. item)
  orderedList,

  /// Blockquote formatting (> quote)
  blockquote,

  /// Underline text formatting (<u>text</u>)
  underline,
}

/// Extension providing icons and labels for format types
extension FormatTypeExtension on FormatType {
  /// Get the icon for this format type
  IconData get icon {
    switch (this) {
      case FormatType.bold:
        return Icons.format_bold;
      case FormatType.italic:
        return Icons.format_italic;
      case FormatType.strikethrough:
        return Icons.strikethrough_s;
      case FormatType.inlineCode:
        return Icons.code;
      case FormatType.codeBlock:
        return Icons.integration_instructions_outlined;
      case FormatType.link:
        return Icons.link;
      case FormatType.bulletList:
        return Icons.format_list_bulleted;
      case FormatType.orderedList:
        return Icons.format_list_numbered;
      case FormatType.blockquote:
        return Icons.format_align_left_outlined;
      case FormatType.underline:
        return Icons.format_underline;
    }
  }

  /// Get the tooltip/label for this format type
  String get label {
    switch (this) {
      case FormatType.bold:
        return 'Bold';
      case FormatType.italic:
        return 'Italic';
      case FormatType.strikethrough:
        return 'Strikethrough';
      case FormatType.inlineCode:
        return 'Inline Code';
      case FormatType.codeBlock:
        return 'Code Block';
      case FormatType.link:
        return 'Link';
      case FormatType.bulletList:
        return 'Bullet List';
      case FormatType.orderedList:
        return 'Numbered List';
      case FormatType.blockquote:
        return 'Quote';
      case FormatType.underline:
        return 'Underline';
    }
  }
}
