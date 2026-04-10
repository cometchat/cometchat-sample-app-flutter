import 'package:flutter/material.dart';
import '../../clean_architecture/core/constants/enums.dart';
import '../../theme/theme/cometchat_theme_helper.dart';
import 'rich_text_format_type.dart';
import 'rich_text_formatter_base.dart';

/// Formatter for inline code using `code` syntax
class InlineCodeTextFormatter extends RichTextFormatterBase {
  InlineCodeTextFormatter()
      : super(
          trackingCharacter: '`',
          pattern: RegExp(r'`([^`]+)`'),
          openingMarker: '`',
          closingMarker: '`',
          placeholderText: 'code',
        );

  @override
  RichTextFormatType get formatType => RichTextFormatType.inlineCode;

  @override
  TextStyle getInputFieldTextStyle(BuildContext context) {
    final colorPalette = CometChatThemeHelper.getColorPalette(context);
    return TextStyle(
      fontFamily: 'monospace',
      backgroundColor: colorPalette.background3,
      color: colorPalette.textPrimary,
    );
  }

  @override
  TextStyle getMessageBubbleTextStyle(
    BuildContext context,
    BubbleAlignment? alignment, {
    bool forConversation = false,
  }) {
    final colorPalette = CometChatThemeHelper.getColorPalette(context);
    return TextStyle(
      fontFamily: 'monospace',
      backgroundColor: colorPalette.background3,
      color: alignment == BubbleAlignment.right
          ? colorPalette.white
          : colorPalette.textPrimary,
    );
  }
}
