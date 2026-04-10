import 'package:flutter/material.dart';
import '../../clean_architecture/core/constants/enums.dart';
import '../../theme/theme/cometchat_theme_helper.dart';
import 'rich_text_format_type.dart';
import 'rich_text_formatter_base.dart';

/// Formatter for bold text using **text** syntax
class BoldTextFormatter extends RichTextFormatterBase {
  BoldTextFormatter()
      : super(
          trackingCharacter: '*',
          pattern: RegExp(r'\*\*(.+?)\*\*'),
          openingMarker: '**',
          closingMarker: '**',
          placeholderText: 'bold',
        );

  @override
  RichTextFormatType get formatType => RichTextFormatType.bold;

  @override
  TextStyle getInputFieldTextStyle(BuildContext context) {
    final colorPalette = CometChatThemeHelper.getColorPalette(context);
    return TextStyle(
      fontWeight: FontWeight.bold,
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
      fontWeight: FontWeight.bold,
      color: alignment == BubbleAlignment.right
          ? colorPalette.white
          : colorPalette.textPrimary,
    );
  }
}
