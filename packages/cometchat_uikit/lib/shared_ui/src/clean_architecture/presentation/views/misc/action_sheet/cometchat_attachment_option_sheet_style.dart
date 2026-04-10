import 'package:flutter/material.dart';

///[CometChatAttachmentOptionSheetStyle] is a class that allows you to customize the attachment action sheet.
///It takes [backgroundColor], [border], [borderRadius], [titleTextStyle], [titleColor], [iconColor] as a parameter.
/// ```dart
/// CometChatAttachmentOptionSheetStyle(
///  backgroundColor: Colors.white,
///  );
///  ```
class CometChatAttachmentOptionSheetStyle
    extends ThemeExtension<CometChatAttachmentOptionSheetStyle> {
  const CometChatAttachmentOptionSheetStyle({
    this.backgroundColor,
    this.border,
    this.borderRadius,
    this.titleTextStyle,
    this.titleColor,
    this.iconColor,
  });

  ///[backgroundColor] background color of the avatar
  final Color? backgroundColor;

  ///[border] border of the avatar
  final Border? border;

  ///[borderRadius] border radius of the avatar
  final BorderRadiusGeometry? borderRadius;

  ///[titleTextStyle] place holder text style
  final TextStyle? titleTextStyle;

  ///[titleColor] place holder text color
  final Color? titleColor;

  ///[iconColor] icon color
  final Color? iconColor;

  static CometChatAttachmentOptionSheetStyle of(BuildContext context) =>
      const CometChatAttachmentOptionSheetStyle();

  @override
  CometChatAttachmentOptionSheetStyle copyWith({
    Color? backgroundColor,
    Border? border,
    BorderRadiusGeometry? borderRadius,
    TextStyle? titleTextStyle,
    Color? titleColor,
    Color? iconColor,
  }) {
    return CometChatAttachmentOptionSheetStyle(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      border: border ?? this.border,
      titleTextStyle: titleTextStyle ?? this.titleTextStyle,
      titleColor: titleColor ?? this.titleColor,
      borderRadius: borderRadius ?? this.borderRadius,
      iconColor: iconColor ?? this.iconColor,
    );
  }

  CometChatAttachmentOptionSheetStyle merge(
      CometChatAttachmentOptionSheetStyle? style) {
    if (style == null) return this;
    return copyWith(
      backgroundColor: style.backgroundColor,
      border: style.border,
      titleTextStyle: style.titleTextStyle,
      titleColor: style.titleColor,
      borderRadius: style.borderRadius,
      iconColor: style.iconColor,
    );
  }

  @override
  CometChatAttachmentOptionSheetStyle lerp(
      ThemeExtension<CometChatAttachmentOptionSheetStyle>? other, double t) {
    if (other is! CometChatAttachmentOptionSheetStyle) {
      return this;
    }
    return CometChatAttachmentOptionSheetStyle(
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t),
      border: Border.lerp(border, other.border, t),
      titleTextStyle: TextStyle.lerp(titleTextStyle, other.titleTextStyle, t),
      titleColor: Color.lerp(titleColor, other.titleColor, t),
      borderRadius:
          BorderRadiusGeometry.lerp(borderRadius, other.borderRadius, t),
      iconColor: Color.lerp(iconColor, other.iconColor, t),
    );
  }
}
