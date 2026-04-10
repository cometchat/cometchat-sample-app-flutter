import 'package:flutter/material.dart';
import '../../clean_architecture/core/constants/enums.dart';
import '../../theme/theme/cometchat_theme_helper.dart';
import 'rich_text_format_type.dart';
import 'rich_text_formatter_base.dart';

/// Formatter for italic text using _text_ syntax
class ItalicTextFormatter extends RichTextFormatterBase {
  ItalicTextFormatter()
      : super(
          trackingCharacter: '_',
          pattern: RegExp(r'_(.+?)_'),
          openingMarker: '_',
          closingMarker: '_',
          placeholderText: 'italic',
        );

  @override
  RichTextFormatType get formatType => RichTextFormatType.italic;

  @override
  TextStyle getInputFieldTextStyle(BuildContext context) {
    final colorPalette = CometChatThemeHelper.getColorPalette(context);
    return TextStyle(
      fontStyle: FontStyle.italic,
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
      fontStyle: FontStyle.italic,
      color: alignment == BubbleAlignment.right
          ? colorPalette.white
          : colorPalette.textPrimary,
    );
  }
}
