import 'package:flutter/material.dart';

///[CometChatChangeScopeStyle] is a class that defines the styling for the CometChatChangeScope widget
///
/// ```dart
/// CometChatChangeScope(
///  style: CometChatChangeScopeStyle(
///  backgroundColor: Colors.white,
///  borderRadius: BorderRadius.circular(10),
///  border: Border.all(color: Colors.red),
///  radioButtonColor: Colors.red,
///  radioButtonSelectedColor: Colors.green,
///  scopeTextStyle: TextStyle(color: Colors.red),
///  selectedScopeTextStyle: TextStyle(color: Colors.green),
///  cancelButtonBackgroundColor: Colors.red,
///  cancelButtonBorder: BorderSide(color: Colors.green),
///  cancelButtonTextStyle: TextStyle(color: Colors.red),
///  cancelButtonBorderRadius: BorderRadius.circular(10),
///  saveButtonBackgroundColor: Colors.red,
///  saveButtonBorder: BorderSide(color: Colors.green),
///  saveButtonTextStyle: TextStyle(color: Colors.red),
///  saveButtonBorderRadius: BorderRadius.circular(10),
///  scopeSectionBorder: Border.all(color: Colors.red),
///  titleTextStyle: TextStyle(color: Colors.red),
///  subtitleTextStyle: TextStyle(color: Colors.red),
///  iconColor: Colors.red,
///  iconBackgroundColor: Colors.red,
///  tileColor: Colors.red,
///  selectedTileColor: Colors.red,
///  ),
///  );
///  ```
class CometChatChangeScopeStyle extends ThemeExtension<CometChatChangeScopeStyle> {
  ///[backgroundColor] defines the background color of the widget
  final Color? backgroundColor;

  ///[borderRadius] defines the border radius of the widget
  final BorderRadiusGeometry? borderRadius;

  ///[border] defines the border of the widget
  final BoxBorder? border;

  ///[radioButtonColor] defines the color of the radio button
  final Color? radioButtonColor;

  ///[radioButtonSelectedColor] defines the color of the selected radio button
  final Color? radioButtonSelectedColor;

  ///[scopeTextStyle] defines the text style of the scope
  final TextStyle? scopeTextStyle;

  ///[selectedScopeTextStyle] defines the text style of the selected scope
  final TextStyle? selectedScopeTextStyle;

  ///[cancelButtonBackgroundColor] defines the background color of the cancel button
  final Color? cancelButtonBackgroundColor;

  ///[cancelButtonBorder] defines the border of the cancel button
  final BorderSide? cancelButtonBorder;

  ///[cancelButtonTextStyle] defines the text style of the cancel button
  final TextStyle? cancelButtonTextStyle;

  ///[cancelButtonBorderRadius] defines the border radius of the cancel button
  final BorderRadiusGeometry? cancelButtonBorderRadius;

  ///[saveButtonBackgroundColor] defines the background color of the save button
  final Color? saveButtonBackgroundColor;

  ///[saveButtonBorder] defines the border of the save button
  final BorderSide? saveButtonBorder;

  ///[saveButtonTextStyle] defines the text style of the save button
  final TextStyle? saveButtonTextStyle;

  ///[saveButtonBorderRadius] defines the border radius of the save button
  final BorderRadiusGeometry? saveButtonBorderRadius;

  ///[scopeSectionBorder] defines the border of the scope section
  final BoxBorder? scopeSectionBorder;

  ///[titleTextStyle] defines the text style of the title
  final TextStyle? titleTextStyle;

  ///[subtitleTextStyle] defines the text style of the subtitle
  final TextStyle? subtitleTextStyle;

  ///[iconColor] defines the color of the icon
  final Color? iconColor;

  ///[iconBackgroundColor] defines the background color of the icon
  final Color? iconBackgroundColor;

  ///[tileColor] defines the color of the tile
  final Color? tileColor;

  ///[selectedTileColor] defines the color of the selected tile
  final Color? selectedTileColor;

  static CometChatChangeScopeStyle of(BuildContext context) =>
       CometChatChangeScopeStyle();

  CometChatChangeScopeStyle({
    this.backgroundColor,
    this.borderRadius,
    this.border,
    this.radioButtonColor,
    this.radioButtonSelectedColor,
    this.scopeTextStyle,
    this.selectedScopeTextStyle,
    this.cancelButtonBackgroundColor,
    this.cancelButtonBorder,
    this.cancelButtonTextStyle,
    this.cancelButtonBorderRadius,
    this.saveButtonBackgroundColor,
    this.saveButtonBorder,
    this.saveButtonTextStyle,
    this.saveButtonBorderRadius,
    this.scopeSectionBorder,
    this.titleTextStyle,
    this.subtitleTextStyle,
    this.iconColor,
    this.iconBackgroundColor,
    this.tileColor,
    this.selectedTileColor,
  });

  @override
  CometChatChangeScopeStyle copyWith({
    Color? backgroundColor,
    BorderRadiusGeometry? borderRadius,
    BoxBorder? border,
    Color? radioButtonColor,
    Color? radioButtonSelectedColor,
    TextStyle? scopeTextStyle,
    TextStyle? selectedScopeTextStyle,
    Color? cancelButtonBackgroundColor,
    BorderSide? cancelButtonBorder,
    TextStyle? cancelButtonTextStyle,
    BorderRadiusGeometry? cancelButtonBorderRadius,
    Color? saveButtonBackgroundColor,
    BorderSide? saveButtonBorder,
    TextStyle? saveButtonTextStyle,
    BorderRadiusGeometry? saveButtonBorderRadius,
    BoxBorder? scopeSectionBorder,
    TextStyle? titleTextStyle,
    TextStyle? subtitleTextStyle,
    Color? iconColor,
    Color? iconBackgroundColor,
    Color? tileColor,
    Color? selectedTileColor,
  }) {
    return CometChatChangeScopeStyle(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      borderRadius: borderRadius ?? this.borderRadius,
      border: border ?? this.border,
      radioButtonColor: radioButtonColor ?? this.radioButtonColor,
      radioButtonSelectedColor: radioButtonSelectedColor ?? this.radioButtonSelectedColor,
      scopeTextStyle: scopeTextStyle ?? this.scopeTextStyle,
      selectedScopeTextStyle: selectedScopeTextStyle ?? this.selectedScopeTextStyle,
      cancelButtonBackgroundColor: cancelButtonBackgroundColor ?? this.cancelButtonBackgroundColor,
      cancelButtonBorder: cancelButtonBorder ?? this.cancelButtonBorder,
      cancelButtonTextStyle: cancelButtonTextStyle ?? this.cancelButtonTextStyle,
      cancelButtonBorderRadius: cancelButtonBorderRadius ?? this.cancelButtonBorderRadius,
      saveButtonBackgroundColor: saveButtonBackgroundColor ?? this.saveButtonBackgroundColor,
      saveButtonBorder: saveButtonBorder ?? this.saveButtonBorder,
      saveButtonTextStyle: saveButtonTextStyle ?? this.saveButtonTextStyle,
      saveButtonBorderRadius: saveButtonBorderRadius ?? this.saveButtonBorderRadius,
      scopeSectionBorder: scopeSectionBorder ?? this.scopeSectionBorder,
      titleTextStyle: titleTextStyle ?? this.titleTextStyle,
      subtitleTextStyle: subtitleTextStyle ?? this.subtitleTextStyle,
      iconColor: iconColor ?? this.iconColor,
      iconBackgroundColor: iconBackgroundColor ?? this.iconBackgroundColor,
      tileColor: tileColor ?? this.tileColor,
      selectedTileColor: selectedTileColor ?? this.selectedTileColor,
    );
  }

  CometChatChangeScopeStyle merge(CometChatChangeScopeStyle? other) {
    if (other == null) return this;
    return copyWith(
      backgroundColor: other.backgroundColor,
      borderRadius: other.borderRadius,
      radioButtonColor: other.radioButtonColor,
      radioButtonSelectedColor: other.radioButtonSelectedColor,
      scopeTextStyle: other.scopeTextStyle,
      selectedScopeTextStyle: other.selectedScopeTextStyle,
      cancelButtonBackgroundColor: other.cancelButtonBackgroundColor,
      cancelButtonBorder: other.cancelButtonBorder,
      cancelButtonTextStyle: other.cancelButtonTextStyle,
      cancelButtonBorderRadius: other.cancelButtonBorderRadius,
      saveButtonBackgroundColor: other.saveButtonBackgroundColor,
      saveButtonBorder: other.saveButtonBorder,
      saveButtonTextStyle: other.saveButtonTextStyle,
      saveButtonBorderRadius: other.saveButtonBorderRadius,
      scopeSectionBorder: other.scopeSectionBorder,
      titleTextStyle: other.titleTextStyle,
      subtitleTextStyle: other.subtitleTextStyle,
      iconColor: other.iconColor,
      iconBackgroundColor: other.iconBackgroundColor,
      border: other.border,
      selectedTileColor: other.selectedTileColor,
      tileColor: other.tileColor,
    );
  }

  @override
  CometChatChangeScopeStyle lerp(ThemeExtension<CometChatChangeScopeStyle>? other, double t) {
  if (other is! CometChatChangeScopeStyle) {
  return this;
  }
  return CometChatChangeScopeStyle(
  backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t),
  borderRadius: BorderRadiusGeometry.lerp(borderRadius, other.borderRadius, t),
  radioButtonColor: Color.lerp(radioButtonColor, other.radioButtonColor, t),
  radioButtonSelectedColor: Color.lerp(radioButtonSelectedColor, other.radioButtonSelectedColor, t),
  scopeTextStyle: TextStyle.lerp(scopeTextStyle, other.scopeTextStyle, t),
  selectedScopeTextStyle: TextStyle.lerp(selectedScopeTextStyle, other.selectedScopeTextStyle, t),
  cancelButtonBackgroundColor: Color.lerp(cancelButtonBackgroundColor, other.cancelButtonBackgroundColor, t),
  cancelButtonBorder: BorderSide.lerp(cancelButtonBorder ?? BorderSide.none, other.cancelButtonBorder ?? BorderSide.none, t),
  cancelButtonTextStyle: TextStyle.lerp(cancelButtonTextStyle, other.cancelButtonTextStyle, t),
  cancelButtonBorderRadius: BorderRadiusGeometry.lerp(cancelButtonBorderRadius, other.cancelButtonBorderRadius, t),
  saveButtonBackgroundColor: Color.lerp(saveButtonBackgroundColor, other.saveButtonBackgroundColor, t),
  saveButtonBorder: BorderSide.lerp(saveButtonBorder ?? BorderSide.none, other.saveButtonBorder ?? BorderSide.none, t),
  saveButtonTextStyle: TextStyle.lerp(saveButtonTextStyle, other.saveButtonTextStyle, t),
  saveButtonBorderRadius: BorderRadiusGeometry.lerp(saveButtonBorderRadius, other.saveButtonBorderRadius, t),
  scopeSectionBorder: BoxBorder.lerp(scopeSectionBorder, other.scopeSectionBorder, t),
  titleTextStyle: TextStyle.lerp(titleTextStyle, other.titleTextStyle, t),
  subtitleTextStyle: TextStyle.lerp(subtitleTextStyle, other.subtitleTextStyle, t),
  iconColor: Color.lerp(iconColor, other.iconColor, t),
  iconBackgroundColor: Color.lerp(iconBackgroundColor, other.iconBackgroundColor, t),
    tileColor: Color.lerp(tileColor, other.tileColor, t),
    selectedTileColor: Color.lerp(selectedTileColor, other.selectedTileColor, t),
    border: BoxBorder.lerp(border ?? Border.all(), other.border ?? Border.all(), t),

  );
  }
}