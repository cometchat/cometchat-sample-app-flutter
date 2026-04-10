import 'package:flutter/material.dart';

///[CometChatModerationStyle] is a data class that has styling-related properties for moderated view
class CometChatModerationStyle
    extends ThemeExtension<CometChatModerationStyle> {
  const CometChatModerationStyle({
    this.moderationBackgroundColor,
    this.moderationTextStyle,
    this.moderationIconTint,
  });

  ///[moderationBackgroundColor] provides background color to the moderated view
  final Color? moderationBackgroundColor;

  ///[moderationTextStyle] provides text style to the moderated view warning text
  final TextStyle? moderationTextStyle;

  ///[moderationIconTint] provides icon color for the moderated view warning icon
  final Color? moderationIconTint;

  static CometChatModerationStyle of(BuildContext context) =>
      const CometChatModerationStyle();

  @override
  CometChatModerationStyle copyWith({
    Color? moderationBackgroundColor,
    TextStyle? moderationTextStyle,
    Color? moderationIconTint,
  }) {
    return CometChatModerationStyle(
      moderationBackgroundColor:
          moderationBackgroundColor ?? this.moderationBackgroundColor,
      moderationTextStyle: moderationTextStyle ?? this.moderationTextStyle,
      moderationIconTint: moderationIconTint ?? this.moderationIconTint,
    );
  }

  CometChatModerationStyle merge(CometChatModerationStyle? style) {
    if (style == null) return this;
    return copyWith(
      moderationBackgroundColor: style.moderationBackgroundColor,
      moderationTextStyle: style.moderationTextStyle,
      moderationIconTint: style.moderationIconTint,
    );
  }

  @override
  CometChatModerationStyle lerp(
      covariant CometChatModerationStyle? other, double t) {
    return CometChatModerationStyle(
      moderationBackgroundColor: Color.lerp(
          moderationBackgroundColor, other?.moderationBackgroundColor, t),
      moderationTextStyle:
          TextStyle.lerp(moderationTextStyle, other?.moderationTextStyle, t),
      moderationIconTint:
          Color.lerp(moderationIconTint, other?.moderationIconTint, t),
    );
  }
}
