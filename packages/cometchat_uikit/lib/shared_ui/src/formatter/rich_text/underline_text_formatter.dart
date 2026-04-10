import 'package:flutter/material.dart';
import '../../clean_architecture/core/constants/enums.dart';
import '../../theme/theme/cometchat_theme_helper.dart';
import 'rich_text_format_type.dart';
import 'rich_text_formatter_base.dart';

/// Formatter for underlined text using <u>text</u> syntax
// ignore: deprecated_member_use_from_same_package
class UnderlineTextFormatter extends RichTextFormatterBase {
  UnderlineTextFormatter()
      : super(
          trackingCharacter: '<',
          pattern: RegExp(r'<u>(.+?)</u>'),
          openingMarker: '<u>',
          closingMarker: '</u>',
          placeholderText: 'underlined',
        );

  @override
  // ignore: deprecated_member_use_from_same_package
  RichTextFormatType get formatType => RichTextFormatType.underline;

  @override
  TextStyle getInputFieldTextStyle(BuildContext context) {
    final colorPalette = CometChatThemeHelper.getColorPalette(context);
    return TextStyle(
      decoration: TextDecoration.underline,
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
      decoration: TextDecoration.underline,
      color: alignment == BubbleAlignment.right
          ? colorPalette.white
          : colorPalette.textPrimary,
    );
  }
}
