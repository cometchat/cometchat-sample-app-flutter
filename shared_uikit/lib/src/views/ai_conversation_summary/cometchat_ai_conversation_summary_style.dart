import 'package:flutter/material.dart';

import '../../../cometchat_uikit_shared.dart';

///[CometChatAIConversationSummaryStyle] is a data class that has styling-related properties
///to customize the appearance of [CometChatAIConversationSummaryStyle]
class CometChatAIConversationSummaryStyle extends ThemeExtension<CometChatAIConversationSummaryStyle> {
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
    this.titleStyle
  });

 ///[backgroundColor] changes background color of reply list
  final Color? backgroundColor;

  ///[emptyTextStyle] provides styling for text tin empty state
  final TextStyle? emptyTextStyle;

  ///[errorTextStyle] provides styling for text to indicate error state
  final TextStyle? errorTextStyle;

  ///[emptyIconTint] provides color to empty icon
  final Color? emptyIconTint;

  ///[shadowColor] changes shadow color of reply text chip/bubbles
  final Color? shadowColor;

  ///[border] changes border of widget
  final BoxBorder? border;

  ///[borderRadius] changes border radius of the widget
  final BorderRadiusGeometry? borderRadius;

  ///[summaryTextStyle] changes style of summary text
  final TextStyle? summaryTextStyle;

  ///[closeIconColor] changes color of close icon
  final Color? closeIconColor;

  ///[titleStyle] title text style
  final TextStyle? titleStyle;

  static CometChatAIConversationSummaryStyle of(BuildContext context)=>const CometChatAIConversationSummaryStyle();

  /// Copies current [CometChatAIConversationSummaryStyle] with some changes
  @override
  CometChatAIConversationSummaryStyle copyWith({
    TextStyle? replyTextStyle,
    Color? backgroundColor,
    TextStyle? emptyTextStyle,
    TextStyle? errorTextStyle,
    Color? emptyIconTint,
    Color? shadowColor,
    BoxBorder? border,
    BorderRadiusGeometry? borderRadius,
    DecoratedContainerStyle? decoratedContainerSummaryStyle,
    TextStyle? summaryTextStyle,
    Color? closeIconColor,
    TextStyle? titleStyle
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
      titleStyle: titleStyle ?? this.titleStyle
    );
  }

  /// Merges current [CometChatAIConversationSummaryStyle] with [other]
  CometChatAIConversationSummaryStyle merge(CometChatAIConversationSummaryStyle? other) {
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
      titleStyle: other.titleStyle
    );
  }

  @override
  CometChatAIConversationSummaryStyle lerp(covariant ThemeExtension<CometChatAIConversationSummaryStyle>? other, double t) {
    if(other is! CometChatAIConversationSummaryStyle){
      return this;
    }
    return CometChatAIConversationSummaryStyle(
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t),
      emptyTextStyle: TextStyle.lerp(emptyTextStyle, other.emptyTextStyle, t),
      errorTextStyle: TextStyle.lerp(errorTextStyle, other.errorTextStyle, t),
      emptyIconTint: Color.lerp(emptyIconTint, other.emptyIconTint, t),
      shadowColor: Color.lerp(shadowColor, other.shadowColor, t),
      border: BoxBorder.lerp(border, other.border, t),
      borderRadius: BorderRadiusGeometry.lerp(borderRadius, other.borderRadius, t),
      summaryTextStyle: TextStyle.lerp(summaryTextStyle, other.summaryTextStyle, t),
      closeIconColor: Color.lerp(closeIconColor, other.closeIconColor, t),
      titleStyle: TextStyle.lerp(titleStyle, other.titleStyle, t)
    );
  }
}
