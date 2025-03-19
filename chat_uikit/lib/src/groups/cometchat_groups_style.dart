import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';

///[CometChatGroupsStyle] is a data class that has styling-related properties
///to customize the appearance of [CometChatGroups]
class CometChatGroupsStyle extends ThemeExtension<CometChatGroupsStyle> {
  const CometChatGroupsStyle({
    this.backgroundColor,
    this.border,
    this.borderRadius,
    this.backIconColor,
    this.titleTextStyle,
    this.titleTextColor,
    this.emptyStateTextStyle,
    this.emptyStateTextColor,
    this.errorStateTextStyle,
    this.errorStateTextColor,
    this.emptyStateSubTitleTextStyle,
    this.emptyStateSubTitleTextColor,
    this.errorStateSubTitleTextStyle,
    this.errorStateSubTitleTextColor,
    this.itemTitleTextStyle,
    this.itemTitleTextColor,
    this.itemSubtitleTextStyle,
    this.itemSubtitleTextColor,
    this.separatorColor,
    this.separatorHeight,
    this.avatarStyle,
    this.statusIndicatorStyle,
    this.searchBackgroundColor,
    this.searchBorder,
    this.searchBorderRadius,
    this.searchIconColor,
    this.searchInputTextColor,
    this.searchInputTextStyle,
    this.searchPlaceHolderTextColor,
    this.searchPlaceHolderTextStyle,
    this.checkBoxBackgroundColor,
    this.checkBoxBorder,
    this.checkBoxBorderRadius,
    this.checkBoxCheckedBackgroundColor,
    this.listItemSelectedBackgroundColor,
    this.checkboxSelectedIconColor,
    this.submitIconColor,
    this.retryButtonBackgroundColor,
    this.retryButtonBorder,
    this.retryButtonBorderRadius,
    this.retryButtonTextColor,
    this.retryButtonTextStyle,
    this.protectedGroupIconBackground,
    this.privateGroupIconBackground,
  });

  ///[backgroundColor] provides background color for the widget
  final Color? backgroundColor;

  ///[border] provides border for the widget
  final Border? border;

  ///[borderRadius] provides border radius for the widget
  final BorderRadiusGeometry? borderRadius;

  ///[backIconColor] provides color for the back icon
  final Color? backIconColor;

  ///[title] provides title for the widget
  final TextStyle? titleTextStyle;

  ///[titleTextColor] provides text color for the title
  final Color? titleTextColor;

  ///[emptyStateTextStyle] provides text style for empty state
  final TextStyle? emptyStateTextStyle;

  ///[emptyStateTextColor] provides text color for empty state
  final Color? emptyStateTextColor;

  ///[emptyStateSubTitleTextStyle] provides text style for empty state
  final TextStyle? emptyStateSubTitleTextStyle;

  ///[emptyStateSubTitleTextColor] provides text color for empty state
  final Color? emptyStateSubTitleTextColor;

  ///[errorStateTextStyle] provides text style for error state
  final TextStyle? errorStateTextStyle;

  ///[errorStateTextStyle] provides sub-title text style for error state
  final TextStyle? errorStateSubTitleTextStyle;

  ///[errorStateTextColor] provides text color for error state
  final Color? errorStateTextColor;

  ///[errorStateSubTitleTextColor] provides sub-title text color for error state
  final Color? errorStateSubTitleTextColor;

  ///[itemTitleTextStyle] provides text style for item tile title
  final TextStyle? itemTitleTextStyle;

  ///[itemTitleTextColor] provides text color for item tile title
  final Color? itemTitleTextColor;

  ///[itemSubtitleTextStyle] provides text style for item tile title
  final TextStyle? itemSubtitleTextStyle;

  ///[itemSubtitleTextColor] provides text color for item tile title
  final Color? itemSubtitleTextColor;

  ///[separatorHeight] provides height for the separator
  final double? separatorHeight;

  ///[separatorColor] provides color for the separator
  final Color? separatorColor;

  ///[avatarStyle] set style for avatar
  final CometChatAvatarStyle? avatarStyle;

  ///[statusIndicatorStyle] set style for status indicator
  final CometChatStatusIndicatorStyle? statusIndicatorStyle;

  ///[searchBorder] provides border for search box
  final BorderSide? searchBorder;

  ///[searchBackgroundColor] provides background color for search box
  final Color? searchBackgroundColor;

  ///[searchIconColor] provides color for search icon
  final Color? searchIconColor;

  ///[searchPlaceHolderTextColor] provides placeholder text color for search box
  final Color? searchPlaceHolderTextColor;

  ///[searchPlaceHolderTextStyle] provides placeholder text style for search box
  final TextStyle? searchPlaceHolderTextStyle;

  ///[searchInputTextStyle] provides input text style for search box
  final TextStyle? searchInputTextStyle;

  ///[searchInputTextColor] provides input text color for search box
  final Color? searchInputTextColor;

  ///[searchContentPadding] provides padding for search box content
  final BorderRadius? searchBorderRadius;

  ///[checkBoxBorder] provides border for selected item
  final BorderSide? checkBoxBorder;

  ///[checkBoxBackgroundColor] provides background color for selected item
  final Color? checkBoxBackgroundColor;

  ///[checkBoxCheckedBackgroundColor] provides check color for selected item
  final Color? checkBoxCheckedBackgroundColor;

  ///[checkBoxBorderRadius] provides border radius for selected item
  final BorderRadiusGeometry? checkBoxBorderRadius;

  ///[listItemSelectedBackgroundColor] provides background color for selected item
  final Color? listItemSelectedBackgroundColor;

  ///[checkboxSelectedIconColor] provides color for selected item
  final Color? checkboxSelectedIconColor;

  ///[submitIconColor] provides color for submit icon
  final Color? submitIconColor;

  ///[retryButtonBackgroundColor] provides background color for retry button
  final Color? retryButtonBackgroundColor;

  ///[retryButtonTextColor] provides text color for retry button
  final Color? retryButtonTextColor;

  ///[retryButtonTextStyle] provides text style for retry button
  final TextStyle? retryButtonTextStyle;

  ///[retryButtonBorder] provides border for retry button
  final BorderSide? retryButtonBorder;

  ///[retryButtonBorderRadius] provides border radius for retry button
  final BorderRadiusGeometry? retryButtonBorderRadius;

  ///[privateGroupIconBackground] provides background color for private group icon
  final Color? privateGroupIconBackground;

  ///[protectedGroupIconBackground] provides background color for protected group icon
  final Color? protectedGroupIconBackground;


  static CometChatGroupsStyle of(BuildContext context) =>
      const CometChatGroupsStyle();

  @override
  CometChatGroupsStyle copyWith({
    Color? backgroundColor,
    Border? border,
    BorderRadiusGeometry? borderRadius,
    Color? backIconColor,
    TextStyle? titleTextStyle,
    Color? titleTextColor,
    TextStyle? emptyStateTextStyle,
    Color? emptyStateTextColor,
    TextStyle? errorStateTextStyle,
    Color? errorStateTextColor,
    TextStyle? emptyStateSubtitleTextStyle,
    Color? emptyStateSubtitleTextColor,
    TextStyle? errorStateSubTitleTextStyle,
    Color? errorStateSubTitleTextColor,
    TextStyle? itemTitleTextStyle,
    Color? itemTitleTextColor,
    TextStyle? itemSubtitleTextStyle,
    Color? itemSubtitleTextColor,
    double? separatorHeight,
    Color? separatorColor,
    CometChatAvatarStyle? avatarStyle,
    CometChatStatusIndicatorStyle? statusIndicatorStyle,
    Color? searchBackgroundColor,
    BorderSide? searchBorder,
    BorderRadius? searchBorderRadius,
    Color? searchIconColor,
    Color? searchInputTextColor,
    TextStyle? searchInputTextStyle,
    Color? searchPlaceHolderTextColor,
    TextStyle? searchPlaceHolderTextStyle,
    BorderSide? checkBoxBorder,
    Color? checkBoxBackgroundColor,
    Color? checkBoxCheckedBackgroundColor,
    BorderRadiusGeometry? checkBoxBorderRadius,
    Color? listItemSelectedBackgroundColor,
    Color? checkboxSelectedIconColor,
    Color? submitIconColor,
    Color? retryButtonBackgroundColor,
    Color? retryButtonTextColor,
    TextStyle? retryButtonTextStyle,
    BorderSide? retryButtonBorder,
    BorderRadiusGeometry? retryButtonBorderRadius,
    Color? privateGroupIconBackground,
    Color? protectedGroupIconBackground,
  }) {
    return CometChatGroupsStyle(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      border: border ?? this.border,
      borderRadius: borderRadius ?? this.borderRadius,
      backIconColor: backIconColor ?? this.backIconColor,
      titleTextStyle: titleTextStyle ?? this.titleTextStyle,
      titleTextColor: titleTextColor ?? this.titleTextColor,
      emptyStateTextStyle: emptyStateTextStyle ?? this.emptyStateTextStyle,
      emptyStateTextColor: emptyStateTextColor ?? this.emptyStateTextColor,
      errorStateTextStyle: errorStateTextStyle ?? this.errorStateTextStyle,
      errorStateTextColor: errorStateTextColor ?? this.errorStateTextColor,
      emptyStateSubTitleTextStyle:
          emptyStateSubtitleTextStyle ?? this.emptyStateSubTitleTextStyle,
      emptyStateSubTitleTextColor:
          emptyStateSubtitleTextColor ?? this.emptyStateSubTitleTextColor,
      errorStateSubTitleTextStyle:
          errorStateSubTitleTextStyle ?? this.errorStateSubTitleTextStyle,
      errorStateSubTitleTextColor:
          errorStateSubTitleTextColor ?? this.errorStateSubTitleTextColor,
      itemTitleTextStyle: itemTitleTextStyle ?? this.itemTitleTextStyle,
      itemTitleTextColor: itemTitleTextColor ?? this.itemTitleTextColor,
      itemSubtitleTextStyle:
          itemSubtitleTextStyle ?? this.itemSubtitleTextStyle,
      itemSubtitleTextColor:
          itemSubtitleTextColor ?? this.itemSubtitleTextColor,
      separatorHeight: separatorHeight ?? this.separatorHeight,
      separatorColor: separatorColor ?? this.separatorColor,
      avatarStyle: avatarStyle ?? this.avatarStyle,
      statusIndicatorStyle: statusIndicatorStyle ?? this.statusIndicatorStyle,
      searchBackgroundColor:
          searchBackgroundColor ?? this.searchBackgroundColor,
      searchBorder: searchBorder ?? this.searchBorder,
      searchBorderRadius: searchBorderRadius ?? this.searchBorderRadius,
      searchIconColor: searchIconColor ?? this.searchIconColor,
      searchInputTextColor: searchInputTextColor ?? this.searchInputTextColor,
      searchInputTextStyle: searchInputTextStyle ?? this.searchInputTextStyle,
      searchPlaceHolderTextColor:
          searchPlaceHolderTextColor ?? this.searchPlaceHolderTextColor,
      searchPlaceHolderTextStyle:
          searchPlaceHolderTextStyle ?? this.searchPlaceHolderTextStyle,
      checkBoxBorder: checkBoxBorder ?? this.checkBoxBorder,
      checkBoxBackgroundColor:
          checkBoxBackgroundColor ?? this.checkBoxBackgroundColor,
      checkBoxCheckedBackgroundColor:
          checkBoxCheckedBackgroundColor ?? this.checkBoxCheckedBackgroundColor,
      checkBoxBorderRadius: checkBoxBorderRadius ?? this.checkBoxBorderRadius,
      listItemSelectedBackgroundColor: listItemSelectedBackgroundColor ??
          this.listItemSelectedBackgroundColor,
      checkboxSelectedIconColor:
          checkboxSelectedIconColor ?? this.checkboxSelectedIconColor,
      submitIconColor: submitIconColor ?? this.submitIconColor,
      retryButtonBackgroundColor:
          retryButtonBackgroundColor ?? this.retryButtonBackgroundColor,
      retryButtonTextColor: retryButtonTextColor ?? this.retryButtonTextColor,
      retryButtonTextStyle: retryButtonTextStyle ?? this.retryButtonTextStyle,
      retryButtonBorder: retryButtonBorder ?? this.retryButtonBorder,
      retryButtonBorderRadius:
          retryButtonBorderRadius ?? this.retryButtonBorderRadius,
      privateGroupIconBackground:
          privateGroupIconBackground ?? this.privateGroupIconBackground,
      protectedGroupIconBackground:
          protectedGroupIconBackground ?? this.protectedGroupIconBackground,
    );
  }

  CometChatGroupsStyle merge(CometChatGroupsStyle? style) {
    if (style == null) return this;
    return copyWith(
      errorStateTextColor: style.errorStateTextColor,
      emptyStateSubtitleTextStyle: style.emptyStateSubTitleTextStyle,
      emptyStateSubtitleTextColor: style.emptyStateSubTitleTextColor,
      errorStateSubTitleTextStyle: style.errorStateSubTitleTextStyle,
      errorStateSubTitleTextColor: style.errorStateSubTitleTextColor,
      itemTitleTextStyle: style.itemTitleTextStyle,
      itemTitleTextColor: style.itemTitleTextColor,
      itemSubtitleTextStyle: style.itemSubtitleTextStyle,
      itemSubtitleTextColor: style.itemSubtitleTextColor,
      separatorHeight: style.separatorHeight,
      separatorColor: style.separatorColor,
      avatarStyle: style.avatarStyle,
      statusIndicatorStyle: style.statusIndicatorStyle,
      searchBackgroundColor: style.searchBackgroundColor,
      searchBorder: style.searchBorder,
      searchBorderRadius: style.searchBorderRadius,
      searchIconColor: style.searchIconColor,
      searchInputTextColor: style.searchInputTextColor,
      searchInputTextStyle: style.searchInputTextStyle,
      searchPlaceHolderTextColor: style.searchPlaceHolderTextColor,
      searchPlaceHolderTextStyle: style.searchPlaceHolderTextStyle,
      checkBoxBorder: style.checkBoxBorder,
      checkBoxBackgroundColor: style.checkBoxBackgroundColor,
      checkBoxCheckedBackgroundColor: style.checkBoxCheckedBackgroundColor,
      checkBoxBorderRadius: style.checkBoxBorderRadius,
      listItemSelectedBackgroundColor: style.listItemSelectedBackgroundColor,
      checkboxSelectedIconColor: style.checkboxSelectedIconColor,
      submitIconColor: style.submitIconColor,
      retryButtonBackgroundColor: style.retryButtonBackgroundColor,
      retryButtonTextColor: style.retryButtonTextColor,
      retryButtonTextStyle: style.retryButtonTextStyle,
      retryButtonBorder: style.retryButtonBorder,
      retryButtonBorderRadius: style.retryButtonBorderRadius,
      backgroundColor: style.backgroundColor,
      border: style.border,
      borderRadius: style.borderRadius,
      backIconColor: style.backIconColor,
      titleTextStyle: style.titleTextStyle,
      titleTextColor: style.titleTextColor,
      emptyStateTextStyle: style.emptyStateTextStyle,
      emptyStateTextColor: style.emptyStateTextColor,
      errorStateTextStyle: style.errorStateTextStyle,
      privateGroupIconBackground: style.privateGroupIconBackground,
      protectedGroupIconBackground: style.protectedGroupIconBackground,
    );
  }

  @override
  CometChatGroupsStyle lerp(
      ThemeExtension<CometChatGroupsStyle>? other, double t) {
    if (other is! CometChatGroupsStyle) {
      return this;
    }
    return CometChatGroupsStyle(
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t),
      border: Border.lerp(border, other.border, t),
      borderRadius:
          BorderRadiusGeometry.lerp(borderRadius, other.borderRadius, t),
      backIconColor: Color.lerp(backIconColor, other.backIconColor, t),
      titleTextStyle: TextStyle.lerp(titleTextStyle, other.titleTextStyle, t),
      titleTextColor: Color.lerp(titleTextColor, other.titleTextColor, t),
      emptyStateTextStyle:
          TextStyle.lerp(emptyStateTextStyle, other.emptyStateTextStyle, t),
      emptyStateTextColor:
          Color.lerp(emptyStateTextColor, other.emptyStateTextColor, t),
      errorStateTextStyle:
          TextStyle.lerp(errorStateTextStyle, other.errorStateTextStyle, t),
      errorStateTextColor:
          Color.lerp(errorStateTextColor, other.errorStateTextColor, t),
      emptyStateSubTitleTextStyle: TextStyle.lerp(
          emptyStateSubTitleTextStyle, other.emptyStateSubTitleTextStyle, t),
      emptyStateSubTitleTextColor: Color.lerp(
          emptyStateSubTitleTextColor, other.emptyStateSubTitleTextColor, t),
      errorStateSubTitleTextStyle: TextStyle.lerp(
          errorStateSubTitleTextStyle, other.errorStateSubTitleTextStyle, t),
      errorStateSubTitleTextColor: Color.lerp(
          errorStateSubTitleTextColor, other.errorStateSubTitleTextColor, t),
      itemTitleTextStyle:
          TextStyle.lerp(itemTitleTextStyle, other.itemTitleTextStyle, t),
      itemTitleTextColor:
          Color.lerp(itemTitleTextColor, other.itemTitleTextColor, t),
      itemSubtitleTextStyle:
          TextStyle.lerp(itemSubtitleTextStyle, other.itemSubtitleTextStyle, t),
      itemSubtitleTextColor:
          Color.lerp(itemSubtitleTextColor, other.itemSubtitleTextColor, t),
      separatorHeight: lerpDouble(separatorHeight, other.separatorHeight, t),
      separatorColor: Color.lerp(separatorColor, other.separatorColor, t),
      avatarStyle: avatarStyle?.lerp(other.avatarStyle, t),
      statusIndicatorStyle:
          statusIndicatorStyle?.lerp(other.statusIndicatorStyle, t),
      searchBackgroundColor:
          Color.lerp(searchBackgroundColor, other.searchBackgroundColor, t),
      searchBorder: BorderSide.lerp(searchBorder ?? BorderSide.none,
          other.searchBorder ?? BorderSide.none, t),
      searchBorderRadius: BorderRadius.lerp(
          searchBorderRadius, other.searchBorderRadius, t),
      searchIconColor: Color.lerp(searchIconColor, other.searchIconColor, t),
      searchInputTextColor:
          Color.lerp(searchInputTextColor, other.searchInputTextColor, t),
      searchInputTextStyle:
          TextStyle.lerp(searchInputTextStyle, other.searchInputTextStyle, t),
      searchPlaceHolderTextColor: Color.lerp(
          searchPlaceHolderTextColor, other.searchPlaceHolderTextColor, t),
      searchPlaceHolderTextStyle: TextStyle.lerp(
          searchPlaceHolderTextStyle, other.searchPlaceHolderTextStyle, t),
      checkBoxBorder: BorderSide.lerp(checkBoxBorder ?? BorderSide.none,
          other.checkBoxBorder ?? BorderSide.none, t),
      checkBoxBackgroundColor:
          Color.lerp(checkBoxBackgroundColor, other.checkBoxBackgroundColor, t),
      checkBoxCheckedBackgroundColor: Color.lerp(checkBoxCheckedBackgroundColor,
          other.checkBoxCheckedBackgroundColor, t),
      checkBoxBorderRadius: BorderRadiusGeometry.lerp(
          checkBoxBorderRadius, other.checkBoxBorderRadius, t),
      listItemSelectedBackgroundColor: Color.lerp(
          listItemSelectedBackgroundColor,
          other.listItemSelectedBackgroundColor,
          t),
      checkboxSelectedIconColor: Color.lerp(
          checkboxSelectedIconColor, other.checkboxSelectedIconColor, t),
      submitIconColor: Color.lerp(submitIconColor, other.submitIconColor, t),
      retryButtonBackgroundColor: Color.lerp(
          retryButtonBackgroundColor, other.retryButtonBackgroundColor, t),
      retryButtonTextColor:
          Color.lerp(retryButtonTextColor, other.retryButtonTextColor, t),
      retryButtonTextStyle:
          TextStyle.lerp(retryButtonTextStyle, other.retryButtonTextStyle, t),
      retryButtonBorder: BorderSide.lerp(
          retryButtonBorder ?? BorderSide.none,
          other.retryButtonBorder ?? BorderSide.none,
          t),
      retryButtonBorderRadius: BorderRadiusGeometry.lerp(
          retryButtonBorderRadius, other.retryButtonBorderRadius, t),
      privateGroupIconBackground: Color.lerp(
          privateGroupIconBackground, other.privateGroupIconBackground, t),
      protectedGroupIconBackground: Color.lerp(
          protectedGroupIconBackground, other.protectedGroupIconBackground, t),
    );
  }
}
