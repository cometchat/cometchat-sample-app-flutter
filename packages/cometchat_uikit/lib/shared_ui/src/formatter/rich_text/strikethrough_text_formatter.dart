import 'package:flutter/material.dart';
import '../../clean_architecture/core/constants/enums.dart';
import '../../theme/theme/cometchat_theme_helper.dart';
import 'rich_text_format_type.dart';
import 'rich_text_formatter_base.dart';

/// Formatter for strikethrough text using ~~text~~ syntax
class StrikethroughTextFormatter extends RichTextFormatterBase {
  StrikethroughTextFormatter()
      : super(
          trackingCharacter: '~',
          pattern: RegExp(r'~~(.+?)~~'),
          openingMarker: '~~',
          closingMarker: '~~',
          placeholderText: 'strikethrough',
        );

  @override
  RichTextFormatType get formatType => RichTextFormatType.strikethrough;

  @override
  TextStyle getInputFieldTextStyle(BuildContext context) {
    final colorPalette = CometChatThemeHelper.getColorPalette(context);
    return TextStyle(
      decoration: TextDecoration.lineThrough,
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
      decoration: TextDecoration.lineThrough,
      color: alignment == BubbleAlignment.right
          ? colorPalette.white
          : colorPalette.textPrimary,
    );
  }
}
