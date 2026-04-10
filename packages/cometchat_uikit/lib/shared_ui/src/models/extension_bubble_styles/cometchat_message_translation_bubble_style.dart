import 'package:flutter/material.dart';


///[CometChatMessageTranslationBubbleStyle] is a data class that has styling-related properties
///to customize the appearance of [MessageTranslationBubble]
///
/// ```dart
/// CometChatMessageTranslationBubbleStyle(
///     infoTextStyle: TextStyle(),
///     translatedTextStyle: TextStyle(),
///     dividerColor: Colors.red,
///     );
/// ```
class CometChatMessageTranslationBubbleStyle
    extends ThemeExtension<CometChatMessageTranslationBubbleStyle> {
  CometChatMessageTranslationBubbleStyle(
      {this.infoTextStyle,
      this.translatedTextStyle,
      this.dividerColor,
      });

  ///[infoTextStyle] provides styling for the text "Translated message"
  final TextStyle? infoTextStyle;

  ///[translatedTextStyle] provides styling for the translated text
  final TextStyle? translatedTextStyle;

  ///[dividerColor] provides color to the divider
  final Color? dividerColor;

  @override
  CometChatMessageTranslationBubbleStyle copyWith({
    TextStyle? infoTextStyle,
    TextStyle? translatedTextStyle,
    Color? dividerColor,
  }) {
    return CometChatMessageTranslationBubbleStyle(
      infoTextStyle: infoTextStyle ?? this.infoTextStyle,
      translatedTextStyle: translatedTextStyle ?? this.translatedTextStyle,
      dividerColor: dividerColor ?? this.dividerColor,
    );
  }

  CometChatMessageTranslationBubbleStyle merge(
      CometChatMessageTranslationBubbleStyle? other) {
    if (other == null) return this;
    return copyWith(
      infoTextStyle: other.infoTextStyle,
      translatedTextStyle: other.translatedTextStyle,
      dividerColor: other.dividerColor,
    );
  }

  @override
  CometChatMessageTranslationBubbleStyle lerp(
    covariant CometChatMessageTranslationBubbleStyle? other,
    double t,
  ) {
    if (other == null) return this;
    return copyWith(
      infoTextStyle: TextStyle.lerp(infoTextStyle, other.infoTextStyle, t),
      translatedTextStyle:
          TextStyle.lerp(translatedTextStyle, other.translatedTextStyle, t),
      dividerColor: Color.lerp(dividerColor, other.dividerColor, t),
    );
  }

  static CometChatMessageTranslationBubbleStyle of(BuildContext context) {
    return CometChatMessageTranslationBubbleStyle();
  }
}
