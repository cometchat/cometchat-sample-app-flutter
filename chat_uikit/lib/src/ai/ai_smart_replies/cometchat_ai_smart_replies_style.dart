import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';
import 'package:flutter/material.dart';

///[CometChatAISmartRepliesStyle] is a data class that has styling-related properties
///to customize the appearance of [CometChatAISmartRepliesView]
class CometChatAISmartRepliesStyle extends ThemeExtension<CometChatAISmartRepliesStyle> {
  const CometChatAISmartRepliesStyle({
    this.itemTextStyle,
    this.backgroundColor,
    this.emptyTextStyle,
    this.errorTextStyle,
    this.emptyIconTint,
    this.itemBackgroundColor,
    this.border,
    this.borderRadius,
    this.itemBorder,
    this.itemBorderRadius,
    this.closeIconColor,
    this.titleStyle
  });

  ///[itemTextStyle] changes style of suggested reply text
  final TextStyle? itemTextStyle;

  ///[backgroundColor] changes background color of reply list
  final Color? backgroundColor;

  ///[emptyTextStyle] provides styling for text to indicate replies list is empty
  final TextStyle? emptyTextStyle;

  ///[errorTextStyle] provides styling for text to indicate some error has occurred while fetching the replies list
  final TextStyle? errorTextStyle;

  ///[emptyIconTint] provides color to empty icon
  final Color? emptyIconTint;

  ///[itemBackgroundColor] changes background color of reply list
  final Color? itemBackgroundColor;

  ///[border] changes border of widget
  final BoxBorder? border;

  ///[borderRadius] changes border radius of the widget
  final BorderRadiusGeometry? borderRadius;

  ///[itemBorder] changes border of widget
  final BoxBorder? itemBorder;

  ///[itemBorderRadius] changes border radius of the widget
  final BorderRadiusGeometry? itemBorderRadius;

  ///[closeIconColor] changes color of close icon
  final Color? closeIconColor;

  ///[titleStyle] title text style
  final TextStyle? titleStyle;

  static CometChatAISmartRepliesStyle of(BuildContext context)=>const CometChatAISmartRepliesStyle();


  /// Copies current [CometChatAISmartRepliesStyle] with some changes
  @override
  CometChatAISmartRepliesStyle copyWith({
    TextStyle? itemTextStyle,
    Color? backgroundColor,
    TextStyle? emptyTextStyle,
    TextStyle? errorTextStyle,
    Color? emptyIconTint,
    Color? itemBackgroundColor,
    BoxBorder? border,
    BorderRadiusGeometry? borderRadius,
    BoxBorder? itemBorder,
    BorderRadiusGeometry? itemBorderRadius,
    Color? closeIconColor,
    TextStyle? titleStyle
  }) {
    return CometChatAISmartRepliesStyle(
      itemTextStyle: itemTextStyle ?? this.itemTextStyle,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      emptyTextStyle: emptyTextStyle ?? this.emptyTextStyle,
      errorTextStyle: errorTextStyle ?? this.errorTextStyle,
      emptyIconTint: emptyIconTint ?? this.emptyIconTint,
      border: border ?? this.border,
      borderRadius: borderRadius ?? this.borderRadius,
      itemBackgroundColor: itemBackgroundColor ?? this.itemBackgroundColor,
      itemBorder: itemBorder ?? this.itemBorder,
      itemBorderRadius: itemBorderRadius ?? this.itemBorderRadius,
      closeIconColor: closeIconColor ?? this.closeIconColor,
      titleStyle: titleStyle ?? this.titleStyle
    );
  }

  /// Merges current [CometChatAISmartRepliesStyle] with [other]
  CometChatAISmartRepliesStyle merge(CometChatAISmartRepliesStyle? other) {
    if (other == null) return this;
    return copyWith(
      itemTextStyle: other.itemTextStyle,
      backgroundColor: other.backgroundColor,
      emptyTextStyle: other.emptyTextStyle,
      errorTextStyle: other.errorTextStyle,
      emptyIconTint: other.emptyIconTint,
      itemBorderRadius: other.itemBorderRadius,
      itemBorder: other.itemBorder,
      itemBackgroundColor: other.itemBackgroundColor,
      border: other.border,
      borderRadius: other.borderRadius,
      closeIconColor: other.closeIconColor,
      titleStyle: other.titleStyle
    );
  }

  @override
  CometChatAISmartRepliesStyle lerp(covariant CometChatAISmartRepliesStyle? other, double t) {
    if(other is! CometChatAISmartRepliesStyle) return this;
    return copyWith(
      itemTextStyle: TextStyle.lerp(itemTextStyle, other.itemTextStyle, t),
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t),
      emptyTextStyle: TextStyle.lerp(emptyTextStyle, other.emptyTextStyle, t),
      errorTextStyle: TextStyle.lerp(errorTextStyle, other.errorTextStyle, t),
      emptyIconTint: Color.lerp(emptyIconTint, other.emptyIconTint, t),
      itemBackgroundColor: Color.lerp(itemBackgroundColor, other.itemBackgroundColor, t),
      border: Border.lerp(border as Border, other.border as Border, t),
      borderRadius: BorderRadiusGeometry.lerp(borderRadius as BorderRadiusGeometry, other.borderRadius as BorderRadiusGeometry, t),
      itemBorder: Border.lerp(itemBorder as Border, other.itemBorder as Border, t),
      itemBorderRadius: BorderRadiusGeometry.lerp(itemBorderRadius as BorderRadiusGeometry, other.itemBorderRadius as BorderRadiusGeometry, t),
      closeIconColor: Color.lerp(closeIconColor, other.closeIconColor, t),
      titleStyle: TextStyle.lerp(titleStyle, other.titleStyle, t),
    );
  }

}
