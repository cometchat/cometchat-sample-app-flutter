import 'package:flutter/material.dart';
import '../../../../../../shared_ui/src/theme/theme/cometchat_theme_helper.dart';

/// Style configuration for the link edit dialog
@immutable
class CometChatLinkPreviewStyle
    extends ThemeExtension<CometChatLinkPreviewStyle> {
  const CometChatLinkPreviewStyle({
    this.backgroundColor,
    this.textFieldBackgroundColor,
    this.textFieldBorderColor,
    this.textFieldTextColor,
    this.textFieldHintColor,
    this.buttonBackgroundColor,
    this.buttonTextColor,
    this.cancelButtonTextColor,
    this.errorTextColor,
    this.borderRadius,
    this.labelTextStyle,
    this.titleTextStyle,
  });

  /// Background color of the dialog
  final Color? backgroundColor;

  /// Background color of text fields
  final Color? textFieldBackgroundColor;

  /// Border color of text fields
  final Color? textFieldBorderColor;

  /// Text color in text fields
  final Color? textFieldTextColor;

  /// Hint text color in text fields
  final Color? textFieldHintColor;

  /// Background color of the submit button
  final Color? buttonBackgroundColor;

  /// Text color of the submit button
  final Color? buttonTextColor;

  /// Text color of the cancel button
  final Color? cancelButtonTextColor;

  /// Color for error messages
  final Color? errorTextColor;

  /// Border radius of the dialog
  final BorderRadiusGeometry? borderRadius;

  /// Text style for labels
  final TextStyle? labelTextStyle;

  /// Text style for the dialog title
  final TextStyle? titleTextStyle;

  /// Factory for theme-based defaults
  static CometChatLinkPreviewStyle of(BuildContext context) {
    final colorPalette = CometChatThemeHelper.getColorPalette(context);
    final typography = CometChatThemeHelper.getTypography(context);
    final spacing = CometChatThemeHelper.getSpacing(context);

    return CometChatLinkPreviewStyle(
      backgroundColor: colorPalette.background1,
      textFieldBackgroundColor: colorPalette.background2,
      textFieldBorderColor: colorPalette.borderDefault,
      textFieldTextColor: colorPalette.textPrimary,
      textFieldHintColor: colorPalette.textTertiary,
      buttonBackgroundColor: colorPalette.primary,
      buttonTextColor: colorPalette.white,
      cancelButtonTextColor: colorPalette.textSecondary,
      errorTextColor: colorPalette.error,
      borderRadius: BorderRadius.circular(spacing.radius3 ?? 12),
      labelTextStyle: typography.body?.medium,
      titleTextStyle: typography.heading4?.bold,
    );
  }

  /// Merge with another style
  CometChatLinkPreviewStyle merge(CometChatLinkPreviewStyle? other) {
    if (other == null) return this;
    return copyWith(
      backgroundColor: other.backgroundColor,
      textFieldBackgroundColor: other.textFieldBackgroundColor,
      textFieldBorderColor: other.textFieldBorderColor,
      textFieldTextColor: other.textFieldTextColor,
      textFieldHintColor: other.textFieldHintColor,
      buttonBackgroundColor: other.buttonBackgroundColor,
      buttonTextColor: other.buttonTextColor,
      cancelButtonTextColor: other.cancelButtonTextColor,
      errorTextColor: other.errorTextColor,
      borderRadius: other.borderRadius,
      labelTextStyle: other.labelTextStyle,
      titleTextStyle: other.titleTextStyle,
    );
  }

  @override
  CometChatLinkPreviewStyle copyWith({
    Color? backgroundColor,
    Color? textFieldBackgroundColor,
    Color? textFieldBorderColor,
    Color? textFieldTextColor,
    Color? textFieldHintColor,
    Color? buttonBackgroundColor,
    Color? buttonTextColor,
    Color? cancelButtonTextColor,
    Color? errorTextColor,
    BorderRadiusGeometry? borderRadius,
    TextStyle? labelTextStyle,
    TextStyle? titleTextStyle,
  }) {
    return CometChatLinkPreviewStyle(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      textFieldBackgroundColor:
          textFieldBackgroundColor ?? this.textFieldBackgroundColor,
      textFieldBorderColor: textFieldBorderColor ?? this.textFieldBorderColor,
      textFieldTextColor: textFieldTextColor ?? this.textFieldTextColor,
      textFieldHintColor: textFieldHintColor ?? this.textFieldHintColor,
      buttonBackgroundColor:
          buttonBackgroundColor ?? this.buttonBackgroundColor,
      buttonTextColor: buttonTextColor ?? this.buttonTextColor,
      cancelButtonTextColor:
          cancelButtonTextColor ?? this.cancelButtonTextColor,
      errorTextColor: errorTextColor ?? this.errorTextColor,
      borderRadius: borderRadius ?? this.borderRadius,
      labelTextStyle: labelTextStyle ?? this.labelTextStyle,
      titleTextStyle: titleTextStyle ?? this.titleTextStyle,
    );
  }

  @override
  CometChatLinkPreviewStyle lerp(CometChatLinkPreviewStyle? other, double t) {
    return CometChatLinkPreviewStyle(
      backgroundColor: Color.lerp(backgroundColor, other?.backgroundColor, t),
      textFieldBackgroundColor: Color.lerp(
        textFieldBackgroundColor,
        other?.textFieldBackgroundColor,
        t,
      ),
      textFieldBorderColor: Color.lerp(
        textFieldBorderColor,
        other?.textFieldBorderColor,
        t,
      ),
      textFieldTextColor: Color.lerp(
        textFieldTextColor,
        other?.textFieldTextColor,
        t,
      ),
      textFieldHintColor: Color.lerp(
        textFieldHintColor,
        other?.textFieldHintColor,
        t,
      ),
      buttonBackgroundColor: Color.lerp(
        buttonBackgroundColor,
        other?.buttonBackgroundColor,
        t,
      ),
      buttonTextColor: Color.lerp(buttonTextColor, other?.buttonTextColor, t),
      cancelButtonTextColor: Color.lerp(
        cancelButtonTextColor,
        other?.cancelButtonTextColor,
        t,
      ),
      errorTextColor: Color.lerp(errorTextColor, other?.errorTextColor, t),
      borderRadius: BorderRadiusGeometry.lerp(
        borderRadius,
        other?.borderRadius,
        t,
      ),
      labelTextStyle: TextStyle.lerp(labelTextStyle, other?.labelTextStyle, t),
      titleTextStyle: TextStyle.lerp(titleTextStyle, other?.titleTextStyle, t),
    );
  }
}
