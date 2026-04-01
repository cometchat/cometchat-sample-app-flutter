import 'package:flutter/material.dart';

/// [CometChatRichTextToolbarStyle] is a data class that has styling-related properties
/// to customize the appearance of [CometChatRichTextToolbar]
///
/// ```dart
/// CometChatRichTextToolbarStyle(
///   backgroundColor: Colors.white,
///   buttonIconColor: Colors.grey,
///   buttonActiveIconColor: Colors.blue,
///   buttonBackgroundColor: Colors.transparent,
///   buttonActiveBackgroundColor: Colors.blue.withOpacity(0.1),
///   dividerColor: Colors.grey.withOpacity(0.3),
///   border: Border.all(color: Colors.grey.withOpacity(0.2)),
///   borderRadius: BorderRadius.circular(8),
/// );
/// ```
class CometChatRichTextToolbarStyle
    extends ThemeExtension<CometChatRichTextToolbarStyle> {
  const CometChatRichTextToolbarStyle({
    this.backgroundColor,
    this.border,
    this.borderRadius,
    this.buttonIconColor,
    this.buttonActiveIconColor,
    this.buttonBackgroundColor,
    this.buttonActiveBackgroundColor,
    this.dividerColor,
    this.buttonBorderRadius,
    this.buttonPadding,
  });

  /// [backgroundColor] defines the background color of the toolbar
  final Color? backgroundColor;

  /// [border] defines the border of the toolbar
  final BoxBorder? border;

  /// [borderRadius] defines the border radius of the toolbar
  final BorderRadiusGeometry? borderRadius;

  /// [buttonIconColor] defines the icon color of inactive format buttons
  final Color? buttonIconColor;

  /// [buttonActiveIconColor] defines the icon color of active format buttons
  final Color? buttonActiveIconColor;

  /// [buttonBackgroundColor] defines the background color of inactive format buttons
  final Color? buttonBackgroundColor;

  /// [buttonActiveBackgroundColor] defines the background color of active format buttons
  final Color? buttonActiveBackgroundColor;

  /// [dividerColor] defines the color of dividers between button groups
  final Color? dividerColor;

  /// [buttonBorderRadius] defines the border radius of format buttons
  final BorderRadiusGeometry? buttonBorderRadius;

  /// [buttonPadding] defines the padding inside format buttons
  final EdgeInsetsGeometry? buttonPadding;

  /// Returns a default [CometChatRichTextToolbarStyle] instance
  static CometChatRichTextToolbarStyle of(BuildContext context) =>
      const CometChatRichTextToolbarStyle();

  @override
  CometChatRichTextToolbarStyle copyWith({
    Color? backgroundColor,
    BoxBorder? border,
    BorderRadiusGeometry? borderRadius,
    Color? buttonIconColor,
    Color? buttonActiveIconColor,
    Color? buttonBackgroundColor,
    Color? buttonActiveBackgroundColor,
    Color? dividerColor,
    BorderRadiusGeometry? buttonBorderRadius,
    EdgeInsetsGeometry? buttonPadding,
  }) {
    return CometChatRichTextToolbarStyle(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      border: border ?? this.border,
      borderRadius: borderRadius ?? this.borderRadius,
      buttonIconColor: buttonIconColor ?? this.buttonIconColor,
      buttonActiveIconColor:
          buttonActiveIconColor ?? this.buttonActiveIconColor,
      buttonBackgroundColor:
          buttonBackgroundColor ?? this.buttonBackgroundColor,
      buttonActiveBackgroundColor:
          buttonActiveBackgroundColor ?? this.buttonActiveBackgroundColor,
      dividerColor: dividerColor ?? this.dividerColor,
      buttonBorderRadius: buttonBorderRadius ?? this.buttonBorderRadius,
      buttonPadding: buttonPadding ?? this.buttonPadding,
    );
  }

  /// Merges this style with another [CometChatRichTextToolbarStyle].
  /// Properties from [style] take precedence over this instance's properties.
  CometChatRichTextToolbarStyle merge(CometChatRichTextToolbarStyle? style) {
    if (style == null) return this;
    return copyWith(
      backgroundColor: style.backgroundColor,
      border: style.border,
      borderRadius: style.borderRadius,
      buttonIconColor: style.buttonIconColor,
      buttonActiveIconColor: style.buttonActiveIconColor,
      buttonBackgroundColor: style.buttonBackgroundColor,
      buttonActiveBackgroundColor: style.buttonActiveBackgroundColor,
      dividerColor: style.dividerColor,
      buttonBorderRadius: style.buttonBorderRadius,
      buttonPadding: style.buttonPadding,
    );
  }

  @override
  CometChatRichTextToolbarStyle lerp(
      ThemeExtension<CometChatRichTextToolbarStyle>? other, double t) {
    if (other is! CometChatRichTextToolbarStyle) {
      return this;
    }
    return CometChatRichTextToolbarStyle(
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t),
      border: BoxBorder.lerp(border, other.border, t),
      borderRadius:
          BorderRadiusGeometry.lerp(borderRadius, other.borderRadius, t),
      buttonIconColor: Color.lerp(buttonIconColor, other.buttonIconColor, t),
      buttonActiveIconColor:
          Color.lerp(buttonActiveIconColor, other.buttonActiveIconColor, t),
      buttonBackgroundColor:
          Color.lerp(buttonBackgroundColor, other.buttonBackgroundColor, t),
      buttonActiveBackgroundColor: Color.lerp(
          buttonActiveBackgroundColor, other.buttonActiveBackgroundColor, t),
      dividerColor: Color.lerp(dividerColor, other.dividerColor, t),
      buttonBorderRadius: BorderRadiusGeometry.lerp(
          buttonBorderRadius, other.buttonBorderRadius, t),
      buttonPadding: EdgeInsetsGeometry.lerp(buttonPadding, other.buttonPadding, t),
    );
  }
}
