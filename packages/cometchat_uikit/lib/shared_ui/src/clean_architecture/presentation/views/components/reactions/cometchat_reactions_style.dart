
import 'package:flutter/material.dart';

///[CometChatReactionsStyle] is a class which is used to set the style for the reactions
///It takes [emojiTextStyle], [countTextStyle], [width], [height], [background], [gradient], [border], [borderRadius] as a parameter
///
/// ```dart
/// ReactionsStyle(
/// reactionTextStyle: TextStyle(color: Colors.white),
/// reactionCountTextStyle: TextStyle(color: Colors.white),
/// backgroundColor: Colors.blue,
/// );
class CometChatReactionsStyle extends ThemeExtension<CometChatReactionsStyle> {
  CometChatReactionsStyle(
      {this.emojiTextStyle,
      this.countTextStyle,
      this.activeReactionBackgroundColor,
      this.activeReactionBorder,
      this.backgroundColor,
      this.border,
      this.borderRadius,
      this.countTextColor,
      });

  ///[emojiTextStyle] is the  text style applied to reactions
  TextStyle? emojiTextStyle;

  ///[countTextStyle] is the  text style applied to reaction count
  TextStyle? countTextStyle;

  ///[activeReactionBackgroundColor] is the  background color applied to selected reaction
  Color? activeReactionBackgroundColor;

  ///[activeReactionBorder] is the  border style applied to selected reaction
  BoxBorder? activeReactionBorder;

  ///[backgroundColor] provides background color to the message bubble of a received message
  final Color? backgroundColor;

  ///[border] provides border to the message bubble of a received message
  final BoxBorder? border;

  ///[borderRadius] provides border radius to the message bubble of a received message
  final BorderRadiusGeometry? borderRadius;

  ///[countTextColor] is the  text color applied to reaction count
  final Color? countTextColor;


  @override
  CometChatReactionsStyle copyWith(
      {TextStyle? emojiTextStyle,
      TextStyle? countTextStyle,
      BoxBorder? border,
      BorderRadiusGeometry? borderRadius,
      Color? activeReactionBackgroundColor,
      BoxBorder? activeReactionBorder,
      Color? backgroundColor,
      Color? emojiTextColor,
      Color? countTextColor,
      double? elevation
      }) {
    return CometChatReactionsStyle(
        emojiTextStyle: emojiTextStyle ?? this.emojiTextStyle,
        countTextStyle:
        countTextStyle ?? this.countTextStyle,
        border: border ?? this.border,
        borderRadius: borderRadius ?? this.borderRadius,
        activeReactionBackgroundColor:
        activeReactionBackgroundColor ?? this.activeReactionBackgroundColor,
        activeReactionBorder: activeReactionBorder ?? this.activeReactionBorder,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      countTextColor: countTextColor ?? this.countTextColor,
    );
  }

  CometChatReactionsStyle merge(CometChatReactionsStyle? style) {
    if (style == null) return this;
    return copyWith(
        emojiTextStyle: style.emojiTextStyle,
        countTextStyle: style.countTextStyle,
        border: style.border,
        borderRadius: style.borderRadius,
        activeReactionBorder: style.activeReactionBorder,
        activeReactionBackgroundColor: style.activeReactionBackgroundColor,
      backgroundColor: style.backgroundColor,
      countTextColor: style.countTextColor,
    );
  }

  @override
  CometChatReactionsStyle lerp(covariant ThemeExtension<CometChatReactionsStyle>? other, double t) {
    if (other is! CometChatReactionsStyle) {
      return this;
    }
      return CometChatReactionsStyle(
        emojiTextStyle: TextStyle.lerp(emojiTextStyle, other.emojiTextStyle, t),
        countTextStyle: TextStyle.lerp(countTextStyle, other.countTextStyle, t),
        border: Border.lerp(border as Border?, other.border as Border?, t),
        borderRadius: BorderRadiusGeometry.lerp(borderRadius, other.borderRadius, t),
        activeReactionBackgroundColor: Color.lerp(activeReactionBackgroundColor, other.activeReactionBackgroundColor, t),
        activeReactionBorder: Border.lerp(activeReactionBorder as Border?, other.activeReactionBorder as Border?, t),
        backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t),
        countTextColor: Color.lerp(countTextColor, other.countTextColor, t),
      );

  }

  static CometChatReactionsStyle of(BuildContext context) {
    return CometChatReactionsStyle();
  }


}
