import 'package:flutter/foundation.dart';

/// Toolbar display mode for rich text formatting
enum RichTextToolbarMode {
  /// Rich text formatting disabled
  disabled,

  /// Show toolbar when text is selected
  onSelection,

  /// Always show toolbar above compose box (default)
  alwaysVisible,
}

/// Preview display mode for rich text formatting
enum RichTextPreviewMode {
  /// Preview disabled
  disabled,

  /// Show preview only when text has formatting
  onFormatting,

  /// Always show preview when text is not empty
  alwaysVisible,
}

/// Configuration for rich text formatting in message composer
@immutable
class RichTextConfiguration {
  const RichTextConfiguration({
    this.toolbarMode = RichTextToolbarMode.alwaysVisible,
    this.previewMode = RichTextPreviewMode.onFormatting,
    this.enableAutoFormatting = true,
    this.enableBold = true,
    this.enableItalic = true,
    this.enableUnderline = true,
    this.enableStrikethrough = true,
    this.enableInlineCode = true,
    this.enableCodeBlock = true,
    this.enableLinks = true,
    this.enableBulletList = true,
    this.enableOrderedList = true,
    this.enableBlockquote = true,
  });

  /// How the toolbar should be displayed
  final RichTextToolbarMode toolbarMode;

  /// How the preview should be displayed
  final RichTextPreviewMode previewMode;

  /// Whether to auto-detect and format Markdown as user types
  final bool enableAutoFormatting;

  /// Enable bold formatting (**text**)
  final bool enableBold;

  /// Enable italic formatting (_text_)
  final bool enableItalic;

  /// Enable underline formatting (<u>text</u>)
  final bool enableUnderline;

  /// Enable strikethrough formatting (~~text~~)
  final bool enableStrikethrough;

  /// Enable inline code formatting (`code`)
  final bool enableInlineCode;

  /// Enable code block formatting (```code```)
  final bool enableCodeBlock;

  /// Enable link formatting ([text](url))
  final bool enableLinks;

  /// Enable bullet list formatting (- item)
  final bool enableBulletList;

  /// Enable ordered list formatting (1. item)
  final bool enableOrderedList;

  /// Enable blockquote formatting (> text)
  final bool enableBlockquote;

  /// Get effective bullet list enabled state
  /// Bullet list is enabled if explicitly enabled OR if code block is enabled
  bool get isBulletListEnabled => enableBulletList || enableCodeBlock;

  /// Get effective ordered list enabled state
  /// Ordered list is enabled if explicitly enabled OR if code block is enabled
  bool get isOrderedListEnabled => enableOrderedList || enableCodeBlock;

  /// Get effective blockquote enabled state
  /// Blockquote is enabled if explicitly enabled OR if code block is enabled
  bool get isBlockquoteEnabled => enableBlockquote || enableCodeBlock;

  /// Check if any formatting is enabled
  bool get hasAnyFormatEnabled =>
      enableBold ||
      enableItalic ||
      enableUnderline ||
      enableStrikethrough ||
      enableInlineCode ||
      enableCodeBlock ||
      enableLinks ||
      enableBulletList ||
      enableOrderedList ||
      enableBlockquote;

  /// Check if toolbar should be shown
  bool get shouldShowToolbar =>
      toolbarMode != RichTextToolbarMode.disabled && hasAnyFormatEnabled;

  /// Check if preview should be shown
  bool get shouldShowPreview =>
      previewMode != RichTextPreviewMode.disabled && hasAnyFormatEnabled;

  /// Create a copy with modified properties
  RichTextConfiguration copyWith({
    RichTextToolbarMode? toolbarMode,
    RichTextPreviewMode? previewMode,
    bool? enableAutoFormatting,
    bool? enableBold,
    bool? enableItalic,
    bool? enableUnderline,
    bool? enableStrikethrough,
    bool? enableInlineCode,
    bool? enableCodeBlock,
    bool? enableLinks,
    bool? enableBulletList,
    bool? enableOrderedList,
    bool? enableBlockquote,
  }) {
    return RichTextConfiguration(
      toolbarMode: toolbarMode ?? this.toolbarMode,
      previewMode: previewMode ?? this.previewMode,
      enableAutoFormatting: enableAutoFormatting ?? this.enableAutoFormatting,
      enableBold: enableBold ?? this.enableBold,
      enableItalic: enableItalic ?? this.enableItalic,
      enableUnderline: enableUnderline ?? this.enableUnderline,
      enableStrikethrough: enableStrikethrough ?? this.enableStrikethrough,
      enableInlineCode: enableInlineCode ?? this.enableInlineCode,
      enableCodeBlock: enableCodeBlock ?? this.enableCodeBlock,
      enableLinks: enableLinks ?? this.enableLinks,
      enableBulletList: enableBulletList ?? this.enableBulletList,
      enableOrderedList: enableOrderedList ?? this.enableOrderedList,
      enableBlockquote: enableBlockquote ?? this.enableBlockquote,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RichTextConfiguration &&
        other.toolbarMode == toolbarMode &&
        other.previewMode == previewMode &&
        other.enableAutoFormatting == enableAutoFormatting &&
        other.enableBold == enableBold &&
        other.enableItalic == enableItalic &&
        other.enableUnderline == enableUnderline &&
        other.enableStrikethrough == enableStrikethrough &&
        other.enableInlineCode == enableInlineCode &&
        other.enableCodeBlock == enableCodeBlock &&
        other.enableLinks == enableLinks &&
        other.enableBulletList == enableBulletList &&
        other.enableOrderedList == enableOrderedList &&
        other.enableBlockquote == enableBlockquote;
  }

  @override
  int get hashCode => Object.hash(
        toolbarMode,
        previewMode,
        enableAutoFormatting,
        enableBold,
        enableItalic,
        enableUnderline,
        enableStrikethrough,
        enableInlineCode,
        enableCodeBlock,
        enableLinks,
        enableBulletList,
        enableOrderedList,
        enableBlockquote,
      );
}
