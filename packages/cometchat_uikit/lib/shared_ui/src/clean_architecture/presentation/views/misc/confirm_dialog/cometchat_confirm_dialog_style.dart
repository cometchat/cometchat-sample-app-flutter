import 'package:flutter/material.dart';

///[CometChatConfirmDialogStyle] is a data class that has styling-related properties
///to customize the appearance of [showCometChatConfirmDialog]
///``` dart
///CometChatConfirmDialogStyle(
/// backgroundColor: Colors.white,
/// shadow: Colors.black,
/// confirmButtonTextStyle: TextStyle(
/// color: Colors.white,
/// fontSize: 16,
/// fontWeight: FontWeight.bold,
/// ),
/// cancelButtonTextStyle: TextStyle(
/// color: Colors.white,
/// fontSize: 16,
/// fontWeight: FontWeight.bold,
/// ),
/// );
/// ```
class CometChatConfirmDialogStyle
    extends ThemeExtension<CometChatConfirmDialogStyle> {
  ///confirm dialog style
  const CometChatConfirmDialogStyle({
    this.backgroundColor,
    this.border,
    this.borderRadius,
    this.shadow,
    this.titleTextStyle,
    this.titleTextColor,
    this.messageTextStyle,
    this.messageTextColor,
    this.confirmButtonTextStyle,
    this.confirmButtonTextColor,
    this.confirmButtonBackground,
    this.cancelButtonTextStyle,
    this.cancelButtonTextColor,
    this.cancelButtonBackground,
    this.iconColor,
    this.iconBackgroundColor,
  });

  ///[backgroundColor] is a property that defines the background color of the dialog
  final Color? backgroundColor;

  ///[shadow] is a property that defines the shadow color of the dialog
  final Color? shadow;

  ///[confirmButtonTextStyle] is a property that defines the text style of the confirm button
  final TextStyle? confirmButtonTextStyle;

  ///[cancelButtonTextStyle] is a property that defines the text style of the cancel button
  final TextStyle? cancelButtonTextStyle;

  ///[confirmButtonBackground] is a property that defines the background color of the confirm button
  final Color? confirmButtonBackground;

  ///[cancelButtonBackground] is a property that defines the background color of the cancel button
  final Color? cancelButtonBackground;

  ///[cancelButtonTextColor] is a property that defines the background color of the cancel text
  final Color? cancelButtonTextColor;

  ///[confirmButtonTextColor] is a property that defines the background color of the confirm text
  final Color? confirmButtonTextColor;

  ///[border] is a property that defines the border of the dialog
  final BorderSide? border;

  ///[borderRadius] is a property that defines the border radius of the dialog
  final BorderRadiusGeometry? borderRadius;

  ///[titleTextStyle] is a property that defines the text style of the title
  final TextStyle? titleTextStyle;

  ///[titleTextColor] is a property that defines the color of the title
  final Color? titleTextColor;

  ///[messageTextStyle] is a property that defines the text style of the message
  final TextStyle? messageTextStyle;

  ///[messageTextColor] is a property that defines the color of the message
  final Color? messageTextColor;

  ///[iconColor] is a property that defines the color of the icon
  final Color? iconColor;

  ///[iconBackgroundColor] is a property that defines the background color of the icon
  final Color? iconBackgroundColor;

  static CometChatConfirmDialogStyle of(BuildContext context) =>
      const CometChatConfirmDialogStyle();

  @override
  CometChatConfirmDialogStyle copyWith({
    Color? backgroundColor,
    Color? shadow,
    TextStyle? confirmButtonTextStyle,
    TextStyle? cancelButtonTextStyle,
    Color? confirmButtonBackground,
    Color? cancelButtonBackground,
    Color? cancelButtonTextColor,
    Color? confirmButtonTextColor,
    BorderSide? border,
    BorderRadiusGeometry? borderRadius,
    TextStyle? titleTextStyle,
    Color? titleTextColor,
    Color? iconColor,
    Color? iconBackgroundColor,
    TextStyle? messageTextStyle,
    Color? messageTextColor,
  }) {
    return CometChatConfirmDialogStyle(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      shadow: shadow ?? this.shadow,
      confirmButtonTextStyle:
          confirmButtonTextStyle ?? this.confirmButtonTextStyle,
      cancelButtonTextStyle:
          cancelButtonTextStyle ?? this.cancelButtonTextStyle,
      confirmButtonBackground:
          confirmButtonBackground ?? this.confirmButtonBackground,
      cancelButtonBackground:
          cancelButtonBackground ?? this.cancelButtonBackground,
      border: border ?? this.border,
      borderRadius: borderRadius ?? this.borderRadius,
      titleTextStyle: titleTextStyle ?? this.titleTextStyle,
      titleTextColor: titleTextColor ?? this.titleTextColor,
      iconColor: iconColor ?? this.iconColor,
      iconBackgroundColor: iconBackgroundColor ?? this.iconBackgroundColor,
      messageTextStyle: messageTextStyle ?? this.messageTextStyle,
      messageTextColor: messageTextColor ?? this.messageTextColor,
      cancelButtonTextColor:
          cancelButtonTextColor ?? this.cancelButtonTextColor,
      confirmButtonTextColor:
          confirmButtonTextColor ?? this.confirmButtonTextColor,
    );
  }

  CometChatConfirmDialogStyle merge(CometChatConfirmDialogStyle? style) {
    if (style == null) return this;
    return copyWith(
      backgroundColor: style.backgroundColor,
      shadow: style.shadow,
      confirmButtonTextStyle: style.confirmButtonTextStyle,
      cancelButtonTextStyle: style.cancelButtonTextStyle,
      confirmButtonBackground: style.confirmButtonBackground,
      cancelButtonBackground: style.cancelButtonBackground,
      border: style.border,
      borderRadius: style.borderRadius,
      titleTextStyle: style.titleTextStyle,
      titleTextColor: style.titleTextColor,
      iconColor: style.iconColor,
      iconBackgroundColor: style.iconBackgroundColor,
      messageTextStyle: style.messageTextStyle,
      messageTextColor: style.messageTextColor,
      cancelButtonTextColor: style.cancelButtonTextColor,
      confirmButtonTextColor: style.confirmButtonTextColor,
    );
  }

  @override
  CometChatConfirmDialogStyle lerp(
      ThemeExtension<CometChatConfirmDialogStyle>? other, double t) {
    if (other is! CometChatConfirmDialogStyle) {
      return this;
    }
    return CometChatConfirmDialogStyle(
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t),
      shadow: Color.lerp(shadow, other.shadow, t),
      confirmButtonTextStyle: TextStyle.lerp(
          confirmButtonTextStyle, other.confirmButtonTextStyle, t),
      cancelButtonTextStyle:
          TextStyle.lerp(cancelButtonTextStyle, other.cancelButtonTextStyle, t),
      confirmButtonBackground:
          Color.lerp(confirmButtonBackground, other.confirmButtonBackground, t),
      cancelButtonBackground:
          Color.lerp(cancelButtonBackground, other.cancelButtonBackground, t),
      border: BorderSide.lerp(
          border ?? const BorderSide(), other.border ?? const BorderSide(), t),
      borderRadius:
          BorderRadiusGeometry.lerp(borderRadius, other.borderRadius, t),
      titleTextStyle: TextStyle.lerp(titleTextStyle, other.titleTextStyle, t),
      titleTextColor: Color.lerp(titleTextColor, other.titleTextColor, t),
      iconColor: Color.lerp(iconColor, other.iconColor, t),
      iconBackgroundColor:
          Color.lerp(iconBackgroundColor, other.iconBackgroundColor, t),
      messageTextStyle:
          TextStyle.lerp(messageTextStyle, other.messageTextStyle, t),
      messageTextColor: Color.lerp(messageTextColor, other.messageTextColor, t),
      cancelButtonTextColor:
          Color.lerp(cancelButtonTextColor, other.cancelButtonTextColor, t),
      confirmButtonTextColor:
          Color.lerp(confirmButtonTextColor, other.confirmButtonTextColor, t),
    );
  }
}
