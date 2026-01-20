import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:cometchat_uikit_shared/cometchat_uikit_shared.dart';

class CometchatFlagMessageStyle
    extends ThemeExtension<CometchatFlagMessageStyle> {
  const CometchatFlagMessageStyle({
    this.backgroundColor,
    this.border,
    this.borderRadius,
    this.titleTextColor,
    this.titleTextStyle,
    this.closeIconTint,
    this.subTitleTextColor,
    this.subTitleTextStyle,
    this.chipBackgroundColor,
    this.chipBorder,
    this.chipBorderRadius,
    this.chipTitleTextStyle,
    this.chipTitleTextColor,
    this.chipActiveBackgroundColor,
    this.chipActiveTitleTextColor,
    this.chipActiveTitleTextStyle,
    this.chipActiveBorder,
    this.chipActiveBorderRadius,
    this.remarkFieldBackgroundColor,
    this.remarkFieldHintTextColor,
    this.remarkFieldHintTextStyle,
    this.remarkFieldSubTitleTextColor,
    this.remarkFieldSubTitleTextStyle,
    this.remarkFieldTextColor,
    this.remarkFieldTextStyle,
    this.remarkFieldTitleTextColor,
    this.remarkFieldTitleTextStyle,
    this.cancelButtonBackgroundColor,
    this.cancelButtonTextStyle,
    this.cancelButtonTextColor,
    this.cancelButtonBorder,
    this.cancelButtonShape,
    this.reportButtonBackgroundColor,
    this.reportButtonActiveBackgroundColor,
    this.reportButtonTextStyle,
    this.reportButtonTextColor,
    this.reportButtonBorder,
    this.reportButtonShape,
    this.errorTextColor,
    this.errorTextStyle,
  });

  ///[backgroundColor] provides background color to the flag message dialog
  final Color? backgroundColor;

  ///[border] provides border to the flag message dialog
  final BorderSide? border;

  ///[borderRadius] provides border radius to the flag message dialog
  final BorderRadiusGeometry? borderRadius;

  ///[titleTextStyle] provides text style to the title of the flag message dialog
  final TextStyle? titleTextStyle;

  ///[titleTextColor] provides text color to the title of the flag message dialog
  final Color? titleTextColor;

  ///[closeIconTint] provides color to the close icon of the flag message dialog
  final Color? closeIconTint;

  ///[subTitleTextStyle] provides text style to the sub title of the flag message dialog
  final TextStyle? subTitleTextStyle;

  ///[subTitleTextColor] provides text color to the sub title of the flag message dialog
  final Color? subTitleTextColor;

  ///[chipBackgroundColor] provides background color to the chip in flag message dialog
  final Color? chipBackgroundColor;

  ///[chipBorder] provides border to the chip in flag message dialog
  final BoxBorder? chipBorder;

  ///[chipBorderRadius] provides border radius to the chip in flag message dialog
  final BorderRadiusGeometry? chipBorderRadius;

  ///[chipTitleTextStyle] provides text style to the title of the chip in flag message dialog
  final TextStyle? chipTitleTextStyle;

  ///[chipTitleTextColor] provides text color to the title of the chip in flag message dialog
  final Color? chipTitleTextColor;

  ///[chipActiveBackgroundColor] provides background color to the active chip in flag message dialog
  final Color? chipActiveBackgroundColor;

  ///[chipActiveTitleTextColor] provides text color to the active chip title in flag message dialog
  final Color? chipActiveTitleTextColor;

  ///[chipActiveTitleTextStyle] provides text style to the active chip title in flag message dialog
  final TextStyle? chipActiveTitleTextStyle;

  ///[chipActiveBorder] provides border to the active chip in flag message dialog
  final BoxBorder? chipActiveBorder;

  ///[chipActiveBorderRadius] provides border radius to the active chip in flag message dialog
  final BorderRadiusGeometry? chipActiveBorderRadius;

  ///[remarkFieldTitleTextStyle] provides text style to the remark field title of the flag message dialog
  final TextStyle? remarkFieldTitleTextStyle;

  ///[remarkFieldTitleTextColor] provides text color to the remark field title of the flag message dialog
  final Color? remarkFieldTitleTextColor;

  ///[remarkFieldSubTitleTextStyle] provides text style to the remark field sub title of the flag message dialog
  final TextStyle? remarkFieldSubTitleTextStyle;

  ///[remarkFieldSubTitleTextColor] provides text color to the remark field sub title of the flag message dialog
  final Color? remarkFieldSubTitleTextColor;

  ///[remarkFieldHintTextStyle] provides text style to the remark field hint text of the flag message dialog
  final TextStyle? remarkFieldHintTextStyle;

  ///[remarkFieldHintTextColor] provides text color to the remark field title hint text of the flag message dialog
  final Color? remarkFieldHintTextColor;

  ///[remarkFieldTextStyle] provides text style to the remark field text of the flag message dialog
  final TextStyle? remarkFieldTextStyle;

  ///[remarkFieldTextColor] provides text color to the remark field text of the flag message dialog
  final Color? remarkFieldTextColor;

  ///[remarkFieldBackgroundColor] provides background color to the remark field of the flag message dialog
  final Color? remarkFieldBackgroundColor;

  /// [cancelButtonBackgroundColor] provides background color to the cancel button of the flag message dialog
  final Color? cancelButtonBackgroundColor;

  /// [cancelButtonTextStyle] provides text style to the cancel button of the flag message dialog
  final TextStyle? cancelButtonTextStyle;

  /// [cancelButtonTextColor] provides text color to the cancel button of the flag message dialog
  final Color? cancelButtonTextColor;

  /// [cancelButtonBorder] provides border to the cancel button of the flag message dialog
  final WidgetStateProperty<BorderSide?>? cancelButtonBorder;

  /// [cancelButtonShape] provides shape to the cancel button of the flag message dialog
  final WidgetStateProperty<OutlinedBorder?>? cancelButtonShape;

  /// [reportButtonBackgroundColor] provides background color to the report button of the flag message dialog
  final Color? reportButtonBackgroundColor;

  /// [reportButtonActiveBackgroundColor] provides background color to the report button in active state of the flag message dialog
  final Color? reportButtonActiveBackgroundColor;

  /// [reportButtonTextStyle] provides text style to the report button of the flag message dialog
  final TextStyle? reportButtonTextStyle;

  /// [reportButtonTextColor] provides text color to the report button of the flag message dialog
  final Color? reportButtonTextColor;

  /// [reportButtonBorder] provides border to the report button of the flag message dialog
  final WidgetStateProperty<BorderSide?>? reportButtonBorder;

  /// [reportButtonShape] provides shape to the report button of the flag message dialog
  final WidgetStateProperty<OutlinedBorder?>? reportButtonShape;

  ///[errorTextStyle] provides text style to the error text of the flag message dialog
  final TextStyle? errorTextStyle;

  ///[errorTextColor] provides text color to the error text of the flag message dialog
  final Color? errorTextColor;

  @override
  CometchatFlagMessageStyle copyWith({
    Color? backgroundColor,
    BorderSide? border,
    BorderRadiusGeometry? borderRadius,
    TextStyle? titleTextStyle,
    Color? titleTextColor,
    Color? closeIconTint,
    Color? subTitleTextColor,
    TextStyle? subTitleTextStyle,
    Color? chipBackgroundColor,
    BoxBorder? chipBorder,
    BorderRadiusGeometry? chipBorderRadius,
    TextStyle? chipTitleTextStyle,
    Color? chipTitleTextColor,
    Color? chipActiveBackgroundColor,
    Color? chipActiveTitleTextColor,
    TextStyle? chipActiveTitleTextStyle,
    BoxBorder? chipActiveBorder,
    BorderRadiusGeometry? chipActiveBorderRadius,
    TextStyle? remarkFieldTitleTextStyle,
    Color? remarkFieldTitleTextColor,
    TextStyle? remarkFieldSubTitleTextStyle,
    Color? remarkFieldSubTitleTextColor,
    TextStyle? remarkFieldHintTextStyle,
    Color? remarkFieldHintTextColor,
    TextStyle? remarkFieldTextStyle,
    Color? remarkFieldTextColor,
    Color? remarkFieldBackgroundColor,
    Color? cancelButtonBackgroundColor,
    TextStyle? cancelButtonTextStyle,
    Color? cancelButtonTextColor,
    WidgetStateProperty<BorderSide?>? cancelButtonBorder,
    WidgetStateProperty<OutlinedBorder?>? cancelButtonShape,
    Color? reportButtonBackgroundColor,
    Color? reportButtonActiveBackgroundColor,
    TextStyle? reportButtonTextStyle,
    Color? reportButtonTextColor,
    WidgetStateProperty<BorderSide?>? reportButtonBorder,
    WidgetStateProperty<OutlinedBorder?>? reportButtonShape,
    TextStyle? errorTextStyle,
    Color? errorTextColor,
  }) {
    return CometchatFlagMessageStyle(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      border: border ?? this.border,
      borderRadius: borderRadius ?? this.borderRadius,
      titleTextStyle: titleTextStyle ?? this.titleTextStyle,
      titleTextColor: titleTextColor ?? this.titleTextColor,
      closeIconTint: closeIconTint ?? this.closeIconTint,
      subTitleTextColor: subTitleTextColor ?? this.subTitleTextColor,
      subTitleTextStyle: subTitleTextStyle ?? this.subTitleTextStyle,
      chipBackgroundColor: chipBackgroundColor ?? this.chipBackgroundColor,
      chipBorder: chipBorder ?? this.chipBorder,
      chipBorderRadius: chipBorderRadius ?? this.chipBorderRadius,
      chipTitleTextStyle: chipTitleTextStyle ?? this.chipTitleTextStyle,
      chipTitleTextColor: chipTitleTextColor ?? this.chipTitleTextColor,
      chipActiveBackgroundColor:
          chipActiveBackgroundColor ?? this.chipActiveBackgroundColor,
      chipActiveTitleTextColor:
          chipActiveTitleTextColor ?? this.chipActiveTitleTextColor,
      chipActiveTitleTextStyle:
          chipActiveTitleTextStyle ?? this.chipActiveTitleTextStyle,
      chipActiveBorder: chipActiveBorder ?? this.chipActiveBorder,
      chipActiveBorderRadius:
          chipActiveBorderRadius ?? this.chipActiveBorderRadius,
      remarkFieldTitleTextStyle:
          remarkFieldTitleTextStyle ?? this.remarkFieldTitleTextStyle,
      remarkFieldTitleTextColor:
          remarkFieldTitleTextColor ?? this.remarkFieldTitleTextColor,
      remarkFieldSubTitleTextStyle:
          remarkFieldSubTitleTextStyle ?? this.remarkFieldSubTitleTextStyle,
      remarkFieldSubTitleTextColor:
          remarkFieldSubTitleTextColor ?? this.remarkFieldSubTitleTextColor,
      remarkFieldHintTextStyle:
          remarkFieldHintTextStyle ?? this.remarkFieldHintTextStyle,
      remarkFieldHintTextColor:
          remarkFieldHintTextColor ?? this.remarkFieldHintTextColor,
      remarkFieldTextStyle: remarkFieldTextStyle ?? this.remarkFieldTextStyle,
      remarkFieldTextColor: remarkFieldTextColor ?? this.remarkFieldTextColor,
      remarkFieldBackgroundColor:
          remarkFieldBackgroundColor ?? this.remarkFieldBackgroundColor,
      cancelButtonBackgroundColor:
          cancelButtonBackgroundColor ?? this.cancelButtonBackgroundColor,
      cancelButtonTextStyle:
          cancelButtonTextStyle ?? this.cancelButtonTextStyle,
      cancelButtonTextColor:
          cancelButtonTextColor ?? this.cancelButtonTextColor,
      cancelButtonBorder: cancelButtonBorder ?? this.cancelButtonBorder,
      cancelButtonShape: cancelButtonShape ?? this.cancelButtonShape,
      reportButtonBackgroundColor:
          reportButtonBackgroundColor ?? this.reportButtonBackgroundColor,
      reportButtonActiveBackgroundColor: reportButtonActiveBackgroundColor ??
          this.reportButtonActiveBackgroundColor,
      reportButtonTextStyle:
          reportButtonTextStyle ?? this.reportButtonTextStyle,
      reportButtonTextColor:
          reportButtonTextColor ?? this.reportButtonTextColor,
      reportButtonBorder: reportButtonBorder ?? this.reportButtonBorder,
      reportButtonShape: reportButtonShape ?? this.reportButtonShape,
      errorTextStyle: errorTextStyle ?? this.errorTextStyle,
      errorTextColor: errorTextColor ?? this.errorTextColor,
    );
  }

  @override
  CometchatFlagMessageStyle lerp(CometchatFlagMessageStyle? other, double t) {
    if (other == null) return this;
    return CometchatFlagMessageStyle(
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t),
      border: BorderSide.lerp(
          border ?? BorderSide.none, other.border ?? BorderSide.none, t),
      borderRadius:
          BorderRadiusGeometry.lerp(borderRadius, other.borderRadius, t),
      titleTextStyle: TextStyle.lerp(titleTextStyle, other.titleTextStyle, t),
      titleTextColor: Color.lerp(titleTextColor, other.titleTextColor, t),
      closeIconTint: Color.lerp(closeIconTint, other.closeIconTint, t),
      subTitleTextColor:
          Color.lerp(subTitleTextColor, other.subTitleTextColor, t),
      subTitleTextStyle:
          TextStyle.lerp(subTitleTextStyle, other.subTitleTextStyle, t),
      chipBackgroundColor:
          Color.lerp(chipBackgroundColor, other.chipBackgroundColor, t),
      chipBorder: BoxBorder.lerp(chipBorder, other.chipBorder, t),
      chipBorderRadius: BorderRadiusGeometry.lerp(
          chipBorderRadius, other.chipBorderRadius, t),
      chipTitleTextStyle:
          TextStyle.lerp(chipTitleTextStyle, other.chipTitleTextStyle, t),
      chipTitleTextColor:
          Color.lerp(chipTitleTextColor, other.chipTitleTextColor, t),
      chipActiveBackgroundColor: Color.lerp(
          chipActiveBackgroundColor, other.chipActiveBackgroundColor, t),
      chipActiveTitleTextColor: Color.lerp(
          chipActiveTitleTextColor, other.chipActiveTitleTextColor, t),
      chipActiveTitleTextStyle: TextStyle.lerp(
          chipActiveTitleTextStyle, other.chipActiveTitleTextStyle, t),
      chipActiveBorder:
          BoxBorder.lerp(chipActiveBorder, other.chipActiveBorder, t),
      chipActiveBorderRadius: BorderRadiusGeometry.lerp(
          chipActiveBorderRadius, other.chipActiveBorderRadius, t),
      remarkFieldBackgroundColor: Color.lerp(
          remarkFieldBackgroundColor, other.remarkFieldBackgroundColor, t),
      remarkFieldHintTextColor: Color.lerp(
          remarkFieldHintTextColor, other.remarkFieldHintTextColor, t),
      remarkFieldHintTextStyle: TextStyle.lerp(
          remarkFieldHintTextStyle, other.remarkFieldHintTextStyle, t),
      remarkFieldSubTitleTextColor: Color.lerp(
          remarkFieldSubTitleTextColor, other.remarkFieldSubTitleTextColor, t),
      remarkFieldSubTitleTextStyle: TextStyle.lerp(
          remarkFieldSubTitleTextStyle, other.remarkFieldSubTitleTextStyle, t),
      remarkFieldTextColor:
          Color.lerp(remarkFieldTextColor, other.remarkFieldTextColor, t),
      remarkFieldTextStyle:
          TextStyle.lerp(remarkFieldTextStyle, other.remarkFieldTextStyle, t),
      remarkFieldTitleTextColor: Color.lerp(
          remarkFieldTitleTextColor, other.remarkFieldTitleTextColor, t),
      remarkFieldTitleTextStyle: TextStyle.lerp(
          remarkFieldTitleTextStyle, other.remarkFieldTitleTextStyle, t),
      cancelButtonBackgroundColor: Color.lerp(
          cancelButtonBackgroundColor, other.cancelButtonBackgroundColor, t),
      cancelButtonTextStyle: TextStyle.lerp(
          cancelButtonTextStyle, other.cancelButtonTextStyle, t),
      cancelButtonTextColor:
          Color.lerp(cancelButtonTextColor, other.cancelButtonTextColor, t),
      reportButtonBackgroundColor: Color.lerp(
          reportButtonBackgroundColor, other.reportButtonBackgroundColor, t),
      reportButtonActiveBackgroundColor: Color.lerp(
          reportButtonActiveBackgroundColor,
          other.reportButtonActiveBackgroundColor,
          t),
      reportButtonTextStyle:
          TextStyle.lerp(reportButtonTextStyle, other.reportButtonTextStyle, t),
      reportButtonTextColor:
          Color.lerp(reportButtonTextColor, other.reportButtonTextColor, t),
      cancelButtonBorder: WidgetStateProperty.lerp<BorderSide?>(
        cancelButtonBorder ?? const WidgetStatePropertyAll<BorderSide?>(null),
        other.cancelButtonBorder ??
            const WidgetStatePropertyAll<BorderSide?>(null),
        t,
        (a, b, t) {
          // Safe lerp: handles null → null or default output
          if (a == null && b == null) return null;
          if (a == null) return b;
          if (b == null) return a;

          return BorderSide.lerp(a, b, t);
        },
      ),
      cancelButtonShape: WidgetStateProperty.lerp<OutlinedBorder?>(
        cancelButtonShape,
        other.cancelButtonShape,
        t,
        (a, b, t) => OutlinedBorder.lerp(a, b, t),
      ),
      reportButtonBorder: WidgetStateProperty.lerp<BorderSide?>(
        reportButtonBorder ?? const WidgetStatePropertyAll<BorderSide?>(null),
        other.reportButtonBorder ??
            const WidgetStatePropertyAll<BorderSide?>(null),
        t,
        (a, b, t) {
          // Safe lerp: handles null → null or default output
          if (a == null && b == null) return null;
          if (a == null) return b;
          if (b == null) return a;

          return BorderSide.lerp(a, b, t);
        },
      ),
      reportButtonShape: WidgetStateProperty.lerp<OutlinedBorder?>(
        reportButtonShape,
        other.reportButtonShape,
        t,
        (a, b, t) => OutlinedBorder.lerp(a, b, t),
      ),
      errorTextStyle: TextStyle.lerp(errorTextStyle, other.errorTextStyle, t),
      errorTextColor: Color.lerp(errorTextColor, other.errorTextColor, t),
    );
  }

  static CometchatFlagMessageStyle of(BuildContext context) =>
      const CometchatFlagMessageStyle();

  CometchatFlagMessageStyle merge(CometchatFlagMessageStyle? style) {
    if (style == null) return this;
    return copyWith(
      backgroundColor: style.backgroundColor,
      border: style.border,
      borderRadius: style.borderRadius,
      titleTextStyle: style.titleTextStyle,
      titleTextColor: style.titleTextColor,
      closeIconTint: style.closeIconTint,
      subTitleTextColor: style.subTitleTextColor,
      subTitleTextStyle: style.subTitleTextStyle,
      chipBackgroundColor: style.chipBackgroundColor,
      chipBorder: style.chipBorder,
      chipBorderRadius: style.chipBorderRadius,
      chipTitleTextStyle: style.chipTitleTextStyle,
      chipTitleTextColor: style.chipTitleTextColor,
      chipActiveBackgroundColor: style.chipActiveBackgroundColor,
      chipActiveTitleTextColor: style.chipActiveTitleTextColor,
      chipActiveTitleTextStyle: style.chipActiveTitleTextStyle,
      chipActiveBorder: style.chipActiveBorder,
      chipActiveBorderRadius: style.chipActiveBorderRadius,
      remarkFieldTitleTextStyle: style.remarkFieldTitleTextStyle,
      remarkFieldTitleTextColor: style.remarkFieldTitleTextColor,
      remarkFieldSubTitleTextStyle: style.remarkFieldSubTitleTextStyle,
      remarkFieldSubTitleTextColor: style.remarkFieldSubTitleTextColor,
      remarkFieldHintTextStyle: style.remarkFieldHintTextStyle,
      remarkFieldHintTextColor: style.remarkFieldHintTextColor,
      remarkFieldTextStyle: style.remarkFieldTextStyle,
      remarkFieldTextColor: style.remarkFieldTextColor,
      remarkFieldBackgroundColor: style.remarkFieldBackgroundColor,
      cancelButtonBackgroundColor: style.cancelButtonBackgroundColor,
      cancelButtonTextStyle: style.cancelButtonTextStyle,
      cancelButtonTextColor: style.cancelButtonTextColor,
      cancelButtonBorder: style.cancelButtonBorder,
      cancelButtonShape: style.cancelButtonShape,
      reportButtonBackgroundColor: style.reportButtonBackgroundColor,
      reportButtonActiveBackgroundColor:
          style.reportButtonActiveBackgroundColor,
      reportButtonTextStyle: style.reportButtonTextStyle,
      reportButtonTextColor: style.reportButtonTextColor,
      reportButtonBorder: style.reportButtonBorder,
      reportButtonShape: style.reportButtonShape,
      errorTextStyle: style.errorTextStyle,
      errorTextColor: style.errorTextColor,
    );
  }
}
