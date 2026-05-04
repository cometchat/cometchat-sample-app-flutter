import 'package:flutter/material.dart';

/// Styling properties for [CometChatAIConversationSummaryView].
class CometChatAIConversationSummaryStyle
    extends ThemeExtension<CometChatAIConversationSummaryStyle> {
  const CometChatAIConversationSummaryStyle({
    this.backgroundColor,
    this.emptyTextStyle,
    this.emptyIconTint,
    this.errorTextStyle,
    this.shadowColor,
    this.border,
    this.borderRadius,
    this.summaryTextStyle,
    this.closeIconColor,
    this.titleStyle,
  });

  final Color? backgroundColor;
  final TextStyle? emptyTextStyle;
  final TextStyle? errorTextStyle;
  final Color? emptyIconTint;
  final Color? shadowColor;
  final BoxBorder? border;
  final BorderRadiusGeometry? borderRadius;
  final TextStyle? summaryTextStyle;
  final Color? closeIconColor;
  final TextStyle? titleStyle;

  static CometChatAIConversationSummaryStyle of(BuildContext context) =>
      const CometChatAIConversationSummaryStyle();

  @override
  CometChatAIConversationSummaryStyle copyWith({
    Color? backgroundColor,
    TextStyle? emptyTextStyle,
    TextStyle? errorTextStyle,
    Color? emptyIconTint,
    Color? shadowColor,
    BoxBorder? border,
    BorderRadiusGeometry? borderRadius,
    TextStyle? summaryTextStyle,
    Color? closeIconColor,
    TextStyle? titleStyle,
  }) {
    return CometChatAIConversationSummaryStyle(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      emptyTextStyle: emptyTextStyle ?? this.emptyTextStyle,
      errorTextStyle: errorTextStyle ?? this.errorTextStyle,
      emptyIconTint: emptyIconTint ?? this.emptyIconTint,
      shadowColor: shadowColor ?? this.shadowColor,
      border: border ?? this.border,
      borderRadius: borderRadius ?? this.borderRadius,
      summaryTextStyle: summaryTextStyle ?? this.summaryTextStyle,
      closeIconColor: closeIconColor ?? this.closeIconColor,
      titleStyle: titleStyle ?? this.titleStyle,
    );
  }

  CometChatAIConversationSummaryStyle merge(
      CometChatAIConversationSummaryStyle? other) {
    if (other == null) return this;
    return copyWith(
      backgroundColor: other.backgroundColor,
      emptyTextStyle: other.emptyTextStyle,
      errorTextStyle: other.errorTextStyle,
      emptyIconTint: other.emptyIconTint,
      shadowColor: other.shadowColor,
      border: other.border,
      borderRadius: other.borderRadius,
      summaryTextStyle: other.summaryTextStyle,
      closeIconColor: other.closeIconColor,
      titleStyle: other.titleStyle,
    );
  }

  @override
  CometChatAIConversationSummaryStyle lerp(
      covariant ThemeExtension<CometChatAIConversationSummaryStyle>? other,
      double t) {
    if (other is! CometChatAIConversationSummaryStyle) return this;
    return CometChatAIConversationSummaryStyle(
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t),
      emptyTextStyle: TextStyle.lerp(emptyTextStyle, other.emptyTextStyle, t),
      errorTextStyle: TextStyle.lerp(errorTextStyle, other.errorTextStyle, t),
      emptyIconTint: Color.lerp(emptyIconTint, other.emptyIconTint, t),
      shadowColor: Color.lerp(shadowColor, other.shadowColor, t),
      border: BoxBorder.lerp(border, other.border, t),
      borderRadius:
          BorderRadiusGeometry.lerp(borderRadius, other.borderRadius, t),
      summaryTextStyle:
          TextStyle.lerp(summaryTextStyle, other.summaryTextStyle, t),
      closeIconColor: Color.lerp(closeIconColor, other.closeIconColor, t),
      titleStyle: TextStyle.lerp(titleStyle, other.titleStyle, t),
    );
  }
}
