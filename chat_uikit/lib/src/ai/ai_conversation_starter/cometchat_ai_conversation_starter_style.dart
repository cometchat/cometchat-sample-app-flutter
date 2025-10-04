import 'package:flutter/material.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';

///[CometChatAIConversationStarterStyle] is a data class that has styling-related properties
///to customize the appearance of [AIConversationStarterExtension]
class CometChatAIConversationStarterStyle extends ThemeExtension<CometChatAIConversationStarterStyle> {
  const CometChatAIConversationStarterStyle({
    this.itemTextStyle,
    this.backgroundColor,
    this.emptyTextStyle,
    this.emptyIconTint,
    this.errorIconTint,
    this.errorTextStyle,
    this.shadowColor,
    this.border,
    this.borderRadius,
  });

  ///[itemTextStyle] changes style of suggested reply text
  final TextStyle? itemTextStyle;

  ///[backgroundColor] changes background color of reply list
  final Color? backgroundColor;

  ///[emptyTextStyle] provides styling for text to indicate replies list is empty
  final TextStyle? emptyTextStyle;

  ///[errorTextStyle] provides styling for text to indicate some error has occurred while fetching the replies list
  final TextStyle? errorTextStyle;

  ///[errorIconTint] provides color to error icon
  final Color? errorIconTint;

  ///[emptyIconTint] provides color to empty icon
  final Color? emptyIconTint;

  ///[shadowColor] changes shadow color of reply text chip/bubbles
  final Color? shadowColor;

  ///[borderRadius] changes border radius of the widget
  final BorderRadiusGeometry? borderRadius;

  ///[border] changes border of widget
  final BoxBorder? border;

  static CometChatAIConversationStarterStyle of(BuildContext context)=>const CometChatAIConversationStarterStyle();

  /// Copies current [CometChatAIConversationStarterStyle] with some changes
  @override
  CometChatAIConversationStarterStyle copyWith({
    TextStyle? itemTextStyle,
    Color? backgroundColor,
    TextStyle? emptyTextStyle,
    TextStyle? errorTextStyle,
    Color? errorIconTint,
    Color? emptyIconTint,
    Color? shadowColor,
    Color? background,
    BoxBorder? border,
    BorderRadiusGeometry? borderRadius,
  }) {
    return CometChatAIConversationStarterStyle(
      itemTextStyle: itemTextStyle ?? this.itemTextStyle,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      emptyTextStyle: emptyTextStyle ?? this.emptyTextStyle,
      errorTextStyle: errorTextStyle ?? this.errorTextStyle,
      errorIconTint: errorIconTint ?? this.errorIconTint,
      emptyIconTint: emptyIconTint ?? this.emptyIconTint,
      shadowColor: shadowColor ?? this.shadowColor,
      border: border ?? this.border,
      borderRadius: borderRadius ?? this.borderRadius,
    );
  }

  /// Merges current [CometChatAIConversationStarterStyle] with [other]
  CometChatAIConversationStarterStyle merge(CometChatAIConversationStarterStyle? other) {
    if (other == null) return this;
    return copyWith(
      itemTextStyle: other.itemTextStyle,
      backgroundColor: other.backgroundColor,
      emptyTextStyle: other.emptyTextStyle,
      errorTextStyle: other.errorTextStyle,
      errorIconTint: other.errorIconTint,
      emptyIconTint: other.emptyIconTint,
      shadowColor: other.shadowColor,
      border: other.border,
      borderRadius: other.borderRadius,
    );
  }

  @override
  ThemeExtension<CometChatAIConversationStarterStyle> lerp(covariant ThemeExtension<CometChatAIConversationStarterStyle>? other, double t) {
    if(other is! CometChatAIConversationStarterStyle) return this;
    return copyWith(
      itemTextStyle: TextStyle.lerp(itemTextStyle, other.itemTextStyle, t),
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t),
      emptyTextStyle: TextStyle.lerp(emptyTextStyle, other.emptyTextStyle, t),
      errorTextStyle: TextStyle.lerp(errorTextStyle, other.errorTextStyle, t),
      errorIconTint: Color.lerp(errorIconTint, other.errorIconTint, t),
      emptyIconTint: Color.lerp(emptyIconTint, other.emptyIconTint, t),
      shadowColor: Color.lerp(shadowColor, other.shadowColor, t),
      border: BoxBorder.lerp(border, other.border, t),
      borderRadius: BorderRadiusGeometry.lerp(borderRadius, other.borderRadius, t),
    );
  }


}
