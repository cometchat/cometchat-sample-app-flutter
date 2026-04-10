import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';

///[CometChatGroupMembersStyle] is a data class that has styling-related properties
///to customize the appearance of [CometChatGroupMembers]
class CometChatGroupMembersStyle extends ThemeExtension<CometChatGroupMembersStyle> {
  const CometChatGroupMembersStyle({
    this.titleStyle,
    this.backIconColor,
    this.searchBackground,
    this.searchBorderRadius,
    this.searchIconColor,
    this.searchPlaceholderStyle,
    this.searchTextStyle,
    this.loadingIconColor,
    this.emptyStateTextStyle,
    this.emptyStateTextColor,
    this.emptyStateSubtitleTextStyle,
    this.emptyStateSubtitleTextColor,
    this.errorStateTextStyle,
    this.errorStateSubtitleStyle,
    this.onlineStatusColor,
    this.listPadding,
    this.backgroundColor,
    this.border,
    this.borderRadius,
    this.checkboxCheckedBackgroundColor,
    this.checkboxBackgroundColor,
    this.checkboxSelectedIconColor,
    this.checkboxBorder,
    this.checkboxBorderRadius,
    this.listItemSelectedBackgroundColor,
    this.confirmDialogStyle,
    this.listItemStyle,
    this.avatarStyle,
    this.statusIndicatorStyle,
    this.retryButtonBackgroundColor,
    this.retryButtonTextColor,
    this.retryButtonTextStyle,
    this.retryButtonBorder,
    this.retryButtonBorderRadius,
    this.separatorHeight,
    this.separatorColor,
    this.ownerMemberScopeBackgroundColor,
    this.moderatorMemberScopeBackgroundColor,
    this.adminMemberScopeBackgroundColor,
    this.ownerMemberScopeTextColor,
    this.moderatorMemberScopeTextColor,
    this.adminMemberScopeTextColor,
    this.ownerMemberScopeBorder,
    this.moderatorMemberScopeBorder,
    this.adminMemberScopeBorder,
    this.adminMemberScopeTextStyle,
    this.moderatorMemberScopeTextStyle,
    this.ownerMemberScopeTextStyle,
    this.submitIconColor,
    this.changeScopeStyle,
    this.optionsBackgroundColor,
    this.optionsIconColor,
    this.optionsTextStyle,
  });

  ///[titleStyle] provides styling for title text
  final TextStyle? titleStyle;

  ///[backIconColor] provides color to close button
  final Color? backIconColor;

  ///[searchBackground] provides color to background of search box
  final Color? searchBackground;

  ///[searchBorderRadius] provides radius to border of search box
  final BorderRadius? searchBorderRadius;

  ///[searchTextStyle] provides styling for text inside the search box
  final TextStyle? searchTextStyle;

  ///[titleStyle] provides styling for text inside the placeholder
  final TextStyle? searchPlaceholderStyle;

  ///[searchIconColor] provides color to search button
  final Color? searchIconColor;

  ///[loadingIconColor] provides color to loading icon
  final Color? loadingIconColor;

  ///[emptyStateTextStyle] provides styling for text to indicate user list is empty
  final TextStyle? emptyStateTextStyle;

  ///[emptyStateTextColor] provides color for empty state text
  final Color? emptyStateTextColor;

  ///[errorStateTextStyle] defines the style of the text to be displayed when the members list is in error state
  final TextStyle? errorStateTextStyle;

  ///[errorStateSubtitleStyle] defines the style of the subtitle to be displayed when the members list is in error state
  final TextStyle? errorStateSubtitleStyle;

  ///[onlineStatusColor] set online status color
  final Color? onlineStatusColor;

  ///[listPadding] padding for list
  final EdgeInsetsGeometry? listPadding;

  ///[backgroundColor] provides background color to the widget
  final Color? backgroundColor;

  ///[borderRadius] provides border radius to the widget
  final BorderRadiusGeometry? borderRadius;

  ///[border] provides border to the widget
  final BoxBorder? border;

  ///[checkboxCheckedBackgroundColor] provides background color to the checkbox when checked
  final Color? checkboxCheckedBackgroundColor;

  ///[checkboxBackgroundColor] provides background color to the checkbox
  final Color? checkboxBackgroundColor;

  ///[checkboxSelectedIconColor] provides color to the checkbox icon when selected
  final Color? checkboxSelectedIconColor;

  ///[checkboxBorder] provides border to the checkbox
  final BorderSide? checkboxBorder;

  ///[checkboxBorderRadius] provides border radius to the checkbox
  final BorderRadiusGeometry? checkboxBorderRadius;

  ///[listItemSelectedBackgroundColor] provides background color to the selected item in the list
  final Color? listItemSelectedBackgroundColor;

  ///[confirmDialogStyle] provides styling for the confirm dialog
  final CometChatConfirmDialogStyle? confirmDialogStyle;

  ///[listItemStyle] style for every list item
  final ListItemStyle? listItemStyle;

  ///[avatarStyle] set style for avatar
  final CometChatAvatarStyle? avatarStyle;

  ///[statusIndicatorStyle] set style for status indicator
  final CometChatStatusIndicatorStyle? statusIndicatorStyle;

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

  ///[separatorHeight] provides height for the separator
  final double? separatorHeight;

  ///[separatorColor] provides color for the separator
  final Color? separatorColor;

  ///[emptyStateSubtitleTextStyle] provides styling for subtitle text to indicate user list is empty
  final TextStyle? emptyStateSubtitleTextStyle;
  
  ///[emptyStateSubtitleTextColor] provides color for empty state subtitle text
  final Color? emptyStateSubtitleTextColor;

  ///[ownerMemberScopeBackgroundColor] provides background color for owner member scope
  final Color? ownerMemberScopeBackgroundColor;

  ///[moderatorMemberScopeBackgroundColor] provides background color for moderator member scope
  final Color? moderatorMemberScopeBackgroundColor;

  ///[adminMemberScopeBackgroundColor] provides background color for admin member scope
  final Color? adminMemberScopeBackgroundColor;

  ///[ownerMemberScopeTextColor] provides text color for owner member scope
  final Color? ownerMemberScopeTextColor;

  ///[moderatorMemberScopeTextColor] provides text color for moderator member scope
  final Color? moderatorMemberScopeTextColor;

  ///[adminMemberScopeTextColor] provides text color for admin member scope
  final Color? adminMemberScopeTextColor;

  ///[ownerMemberScopeBorder] provides border color for owner member scope
  final BoxBorder? ownerMemberScopeBorder;

  ///[moderatorMemberScopeBorder] provides border color for moderator member scope
  final BoxBorder? moderatorMemberScopeBorder;

  ///[adminMemberScopeBorder] provides border color for admin member scope
  final BoxBorder? adminMemberScopeBorder;

  ///[ownerMemberScopeTextStyle] provides text style for owner member scope
  final TextStyle? ownerMemberScopeTextStyle;

  ///[moderatorMemberScopeTextStyle] provides text style for moderator member scope
  final TextStyle? moderatorMemberScopeTextStyle;

  ///[adminMemberScopeTextStyle] provides text style for admin member scope
  final TextStyle? adminMemberScopeTextStyle;

  ///[submitIconColor] provides color for submit icon
  final Color? submitIconColor;

  ///[changeScopeStyle] provides styling for change scope
  final CometChatChangeScopeStyle? changeScopeStyle;

  ///[optionsBackgroundColor] provides background color for options
  final Color? optionsBackgroundColor;

  ///[optionsIconColor] provides color for options icon
  final Color? optionsIconColor;

  ///[optionsTextStyle] provides text style for options
  final TextStyle? optionsTextStyle;


  @override
  CometChatGroupMembersStyle copyWith(
  {
    TextStyle? titleStyle,
    Color? backIconColor,
    Color? searchBackground,
    BorderRadius? searchBorderRadius,
    TextStyle? searchTextStyle,
    TextStyle? searchPlaceholderStyle,
    Color? searchIconColor,
    Color? loadingIconColor,
    TextStyle? emptyStateTextStyle,
    Color? emptyStateTextColor,
    TextStyle? emptyStateSubtitleTextStyle,
    Color? emptyStateSubtitleTextColor,
    TextStyle? errorStateTextStyle,
    Color? onlineStatusColor,
    Color? separatorColor,
    EdgeInsetsGeometry? listPadding,
    Color? backgroundColor,
    BoxBorder? border,
    BorderRadiusGeometry? borderRadius,
    Color? checkboxCheckedBackgroundColor,
    Color? checkboxBackgroundColor,
    Color? checkboxSelectedIconColor,
    BorderSide? checkboxBorder,
    BorderRadiusGeometry? checkboxBorderRadius,
    Color? listItemSelectedBackgroundColor,
    CometChatConfirmDialogStyle? confirmDialogStyle,
    ListItemStyle? listItemStyle,
    CometChatAvatarStyle? avatarStyle,
    CometChatStatusIndicatorStyle? statusIndicatorStyle,
    TextStyle? errorStateSubtitleStyle,
    Color? retryButtonBackgroundColor,
    Color? retryButtonTextColor,
    TextStyle? retryButtonTextStyle,
    BorderSide? retryButtonBorder,
    BorderRadiusGeometry? retryButtonBorderRadius,
    double? separatorHeight,
    Color? ownerMemberScopeBackgroundColor,
    Color? moderatorMemberScopeBackgroundColor,
    Color? adminMemberScopeBackgroundColor,
    Color? ownerMemberScopeTextColor,
    Color? moderatorMemberScopeTextColor,
    Color? adminMemberScopeTextColor,
    BoxBorder? ownerMemberScopeBorder,
    BoxBorder? moderatorMemberScopeBorder,
    BoxBorder? adminMemberScopeBorder,
    TextStyle? ownerMemberScopeTextStyle,
    TextStyle? moderatorMemberScopeTextStyle,
    TextStyle? adminMemberScopeTextStyle,
    Color? submitIconColor,
    CometChatChangeScopeStyle? changeScopeStyle,
    Color? optionsBackgroundColor,
    Color? optionsIconColor,
    TextStyle? optionsTextStyle,
  }) {
    return CometChatGroupMembersStyle(
      titleStyle: titleStyle ?? this.titleStyle,
      backIconColor: backIconColor ?? this.backIconColor,
      searchBackground: searchBackground ?? this.searchBackground,
      searchBorderRadius: searchBorderRadius ?? this.searchBorderRadius,
      searchTextStyle: searchTextStyle ?? this.searchTextStyle,
      searchPlaceholderStyle: searchPlaceholderStyle ?? this.searchPlaceholderStyle,
      searchIconColor: searchIconColor ?? this.searchIconColor,
      loadingIconColor: loadingIconColor ?? this.loadingIconColor,
      onlineStatusColor: onlineStatusColor ?? this.onlineStatusColor,
      listPadding: listPadding ?? this.listPadding,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      border: border ?? this.border,
      borderRadius: borderRadius ?? this.borderRadius,
      checkboxCheckedBackgroundColor: checkboxCheckedBackgroundColor ?? this.checkboxCheckedBackgroundColor,
      checkboxBackgroundColor: checkboxBackgroundColor ?? this.checkboxBackgroundColor,
      checkboxSelectedIconColor: checkboxSelectedIconColor ?? this.checkboxSelectedIconColor,
      checkboxBorder: checkboxBorder ?? this.checkboxBorder,
      checkboxBorderRadius: checkboxBorderRadius ?? this.checkboxBorderRadius,
        listItemSelectedBackgroundColor: listItemSelectedBackgroundColor ?? this.listItemSelectedBackgroundColor,
        confirmDialogStyle: confirmDialogStyle ?? this.confirmDialogStyle,
      errorStateSubtitleStyle: errorStateSubtitleStyle ?? this.errorStateSubtitleStyle,
        avatarStyle: avatarStyle ?? this.avatarStyle,
        statusIndicatorStyle: statusIndicatorStyle ?? this.statusIndicatorStyle,
      errorStateTextStyle: errorStateTextStyle ?? this.errorStateTextStyle,
      listItemStyle: listItemStyle ?? this.listItemStyle,
      retryButtonBackgroundColor: retryButtonBackgroundColor ?? this.retryButtonBackgroundColor,
      retryButtonTextColor: retryButtonTextColor ?? this.retryButtonTextColor,
      retryButtonTextStyle: retryButtonTextStyle ?? this.retryButtonTextStyle,
      retryButtonBorder: retryButtonBorder ?? this.retryButtonBorder,
      retryButtonBorderRadius: retryButtonBorderRadius ?? this.retryButtonBorderRadius,
      separatorHeight: separatorHeight ?? this.separatorHeight,
      separatorColor: separatorColor ?? this.separatorColor,
      emptyStateTextStyle: emptyStateTextStyle ?? this.emptyStateTextStyle,
      emptyStateTextColor: emptyStateTextColor ?? this.emptyStateTextColor,
      emptyStateSubtitleTextStyle: emptyStateSubtitleTextStyle ?? this.emptyStateSubtitleTextStyle,
      emptyStateSubtitleTextColor: emptyStateSubtitleTextColor ?? this.emptyStateSubtitleTextColor,
      adminMemberScopeBackgroundColor: adminMemberScopeBackgroundColor ?? this.adminMemberScopeBackgroundColor,
      moderatorMemberScopeBackgroundColor: moderatorMemberScopeBackgroundColor ?? this.moderatorMemberScopeBackgroundColor,
      ownerMemberScopeBackgroundColor: ownerMemberScopeBackgroundColor ?? this.ownerMemberScopeBackgroundColor,
      adminMemberScopeTextColor: adminMemberScopeTextColor ?? this.adminMemberScopeTextColor,
      moderatorMemberScopeTextColor: moderatorMemberScopeTextColor ?? this.moderatorMemberScopeTextColor,
      ownerMemberScopeTextColor: ownerMemberScopeTextColor ?? this.ownerMemberScopeTextColor,
      adminMemberScopeBorder: adminMemberScopeBorder ?? this.adminMemberScopeBorder,
      moderatorMemberScopeBorder: moderatorMemberScopeBorder ?? this.moderatorMemberScopeBorder,
      adminMemberScopeTextStyle: adminMemberScopeTextStyle ?? this.adminMemberScopeTextStyle,
      moderatorMemberScopeTextStyle: moderatorMemberScopeTextStyle ?? this.moderatorMemberScopeTextStyle,
      ownerMemberScopeTextStyle: ownerMemberScopeTextStyle ?? this.ownerMemberScopeTextStyle,
      ownerMemberScopeBorder: ownerMemberScopeBorder ?? this.ownerMemberScopeBorder,
      submitIconColor: submitIconColor ?? this.submitIconColor,
      changeScopeStyle: changeScopeStyle ?? this.changeScopeStyle,
      optionsBackgroundColor: optionsBackgroundColor ?? this.optionsBackgroundColor,
      optionsIconColor: optionsIconColor ?? this.optionsIconColor,
      optionsTextStyle: optionsTextStyle ?? this.optionsTextStyle,
    );
  }

  @override
  CometChatGroupMembersStyle lerp(covariant CometChatGroupMembersStyle? other, double t) {
    if (other is! CometChatGroupMembersStyle) return this;
    return CometChatGroupMembersStyle(
      titleStyle: TextStyle.lerp(titleStyle, other.titleStyle, t),
      backIconColor: Color.lerp(backIconColor, other.backIconColor, t),
      searchBackground: Color.lerp(searchBackground, other.searchBackground, t),
      searchBorderRadius: BorderRadius.lerp(searchBorderRadius, other.searchBorderRadius, t),
      searchTextStyle: TextStyle.lerp(searchTextStyle, other.searchTextStyle, t),
      searchPlaceholderStyle: TextStyle.lerp(searchPlaceholderStyle, other.searchPlaceholderStyle, t),
      searchIconColor: Color.lerp(searchIconColor, other.searchIconColor, t),
      loadingIconColor: Color.lerp(loadingIconColor, other.loadingIconColor, t),
     onlineStatusColor: Color.lerp(onlineStatusColor, other.onlineStatusColor, t),
      listPadding: EdgeInsetsGeometry.lerp(listPadding, other.listPadding, t),
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t),
      border: BoxBorder.lerp(border, other.border, t),
      borderRadius: BorderRadiusGeometry.lerp(borderRadius, other.borderRadius, t),
      checkboxCheckedBackgroundColor: Color.lerp(checkboxCheckedBackgroundColor, other.checkboxCheckedBackgroundColor, t),
      checkboxBackgroundColor: Color.lerp(checkboxBackgroundColor, other.checkboxBackgroundColor, t),
      checkboxSelectedIconColor: Color.lerp(checkboxSelectedIconColor, other.checkboxSelectedIconColor, t),
      checkboxBorderRadius: BorderRadiusGeometry.lerp(checkboxBorderRadius, other.checkboxBorderRadius, t),
      checkboxBorder: BorderSide.lerp(checkboxBorder ?? const BorderSide(), other.checkboxBorder ?? const BorderSide(), t),
        listItemSelectedBackgroundColor: Color.lerp(listItemSelectedBackgroundColor, other.listItemSelectedBackgroundColor, t),
        confirmDialogStyle: confirmDialogStyle?.lerp(other.confirmDialogStyle, t),
      errorStateTextStyle: TextStyle.lerp(errorStateTextStyle, other.errorStateTextStyle, t),
      errorStateSubtitleStyle: TextStyle.lerp(errorStateSubtitleStyle, other.errorStateSubtitleStyle, t),
        avatarStyle: avatarStyle?.lerp(other.avatarStyle, t),
        statusIndicatorStyle: statusIndicatorStyle?.lerp(other.statusIndicatorStyle, t),
      listItemStyle: ListItemStyle(
        separatorColor: Color.lerp(listItemStyle?.separatorColor, other.listItemStyle?.separatorColor, t),
        titleStyle: TextStyle.lerp(listItemStyle?.titleStyle, other.listItemStyle?.titleStyle, t),
        borderRadius: BorderRadiusGeometry.lerp(listItemStyle?.borderRadius, other.listItemStyle?.borderRadius, t),
        border: BoxBorder.lerp(listItemStyle?.border, other.listItemStyle?.border, t),
        background: Color.lerp(listItemStyle?.background, other.listItemStyle?.background, t),
      ),
      retryButtonBackgroundColor: Color.lerp(retryButtonBackgroundColor, other.retryButtonBackgroundColor, t),
      retryButtonTextColor: Color.lerp(retryButtonTextColor, other.retryButtonTextColor, t),
      retryButtonBorder: BorderSide.lerp(retryButtonBorder ?? const BorderSide(), other.retryButtonBorder ?? const BorderSide(), t),
      separatorColor: Color.lerp(separatorColor, other.separatorColor, t),
      retryButtonBorderRadius: BorderRadiusGeometry.lerp(retryButtonBorderRadius, other.retryButtonBorderRadius, t),
      retryButtonTextStyle: TextStyle.lerp(retryButtonTextStyle, other.retryButtonTextStyle, t),
      separatorHeight: lerpDouble(separatorHeight, other.separatorHeight, t),
      emptyStateTextStyle: TextStyle.lerp(emptyStateTextStyle, other.emptyStateTextStyle, t),
      emptyStateTextColor: Color.lerp(emptyStateTextColor, other.emptyStateTextColor, t),
      emptyStateSubtitleTextStyle: TextStyle.lerp(emptyStateSubtitleTextStyle, other.emptyStateSubtitleTextStyle, t),
      emptyStateSubtitleTextColor: Color.lerp(emptyStateSubtitleTextColor, other.emptyStateSubtitleTextColor, t),
      ownerMemberScopeBackgroundColor: Color.lerp(ownerMemberScopeBackgroundColor, other.ownerMemberScopeBackgroundColor, t),
      moderatorMemberScopeBackgroundColor: Color.lerp(moderatorMemberScopeBackgroundColor, other.moderatorMemberScopeBackgroundColor, t),
      adminMemberScopeBackgroundColor: Color.lerp(adminMemberScopeBackgroundColor, other.adminMemberScopeBackgroundColor, t),
      ownerMemberScopeTextColor: Color.lerp(ownerMemberScopeTextColor, other.ownerMemberScopeTextColor, t),
      moderatorMemberScopeTextColor: Color.lerp(moderatorMemberScopeTextColor, other.moderatorMemberScopeTextColor, t),
      adminMemberScopeTextColor: Color.lerp(adminMemberScopeTextColor, other.adminMemberScopeTextColor, t),
      ownerMemberScopeBorder: BoxBorder.lerp(ownerMemberScopeBorder ?? const Border(), other.ownerMemberScopeBorder ?? const Border(), t),
      moderatorMemberScopeBorder: BoxBorder.lerp(moderatorMemberScopeBorder ?? const Border(), other.moderatorMemberScopeBorder ?? const Border(), t),
      adminMemberScopeBorder: BoxBorder.lerp(adminMemberScopeBorder ?? const Border(), other.adminMemberScopeBorder ?? const Border(), t),
      adminMemberScopeTextStyle: TextStyle.lerp(adminMemberScopeTextStyle, other.adminMemberScopeTextStyle, t),
      moderatorMemberScopeTextStyle: TextStyle.lerp(moderatorMemberScopeTextStyle, other.moderatorMemberScopeTextStyle, t),
      ownerMemberScopeTextStyle: TextStyle.lerp(ownerMemberScopeTextStyle, other.ownerMemberScopeTextStyle, t),
      submitIconColor: Color.lerp(submitIconColor, other.submitIconColor, t),
      changeScopeStyle: changeScopeStyle?.lerp(other.changeScopeStyle, t),
      optionsBackgroundColor: Color.lerp(optionsBackgroundColor, other.optionsBackgroundColor, t),
      optionsIconColor: Color.lerp(optionsIconColor, other.optionsIconColor, t),
      optionsTextStyle: TextStyle.lerp(optionsTextStyle, other.optionsTextStyle, t),
    );
  }

  CometChatGroupMembersStyle merge(CometChatGroupMembersStyle? other) {
    if (other == null) return this;
    return copyWith(
      titleStyle: other.titleStyle,
      backIconColor: other.backIconColor,
      searchBackground: other.searchBackground,
      searchBorderRadius: other.searchBorderRadius,
      searchTextStyle: other.searchTextStyle,
      searchPlaceholderStyle: other.searchPlaceholderStyle,
      searchIconColor: other.searchIconColor,
      loadingIconColor: other.loadingIconColor,
      emptyStateTextStyle: other.emptyStateTextStyle,
      emptyStateTextColor: other.emptyStateTextColor,
      emptyStateSubtitleTextStyle: other.emptyStateSubtitleTextStyle,
      emptyStateSubtitleTextColor: other.emptyStateSubtitleTextColor,
      errorStateTextStyle: other.errorStateTextStyle,
      onlineStatusColor: other.onlineStatusColor,
      listPadding: other.listPadding,
      backgroundColor: other.backgroundColor,
      border: other.border,
      borderRadius: other.borderRadius,
      checkboxCheckedBackgroundColor: other.checkboxCheckedBackgroundColor,
      checkboxBackgroundColor: other.checkboxBackgroundColor,
      checkboxSelectedIconColor: other.checkboxSelectedIconColor,
      checkboxBorder: other.checkboxBorder,
      checkboxBorderRadius: other.checkboxBorderRadius,
      listItemSelectedBackgroundColor: other.listItemSelectedBackgroundColor,
      confirmDialogStyle: other.confirmDialogStyle,
      errorStateSubtitleStyle: other.errorStateSubtitleStyle,
      avatarStyle: other.avatarStyle,
      statusIndicatorStyle: other.statusIndicatorStyle,
      listItemStyle: other.listItemStyle,
      retryButtonBackgroundColor: other.retryButtonBackgroundColor,
      retryButtonTextColor: other.retryButtonTextColor,
      retryButtonTextStyle: other.retryButtonTextStyle,
      retryButtonBorder: other.retryButtonBorder,
      retryButtonBorderRadius: other.retryButtonBorderRadius,
      separatorHeight: other.separatorHeight,
      separatorColor: other.separatorColor,
      adminMemberScopeTextStyle: other.adminMemberScopeTextStyle,
      moderatorMemberScopeTextStyle: other.moderatorMemberScopeTextStyle,
      ownerMemberScopeTextStyle: other.ownerMemberScopeTextStyle,
      ownerMemberScopeBackgroundColor: other.ownerMemberScopeBackgroundColor,
      moderatorMemberScopeBackgroundColor: other.moderatorMemberScopeBackgroundColor,
      adminMemberScopeBackgroundColor: other.adminMemberScopeBackgroundColor,
      ownerMemberScopeTextColor: other.ownerMemberScopeTextColor,
      moderatorMemberScopeTextColor: other.moderatorMemberScopeTextColor,
      adminMemberScopeTextColor: other.adminMemberScopeTextColor,
      ownerMemberScopeBorder: other.ownerMemberScopeBorder,
      moderatorMemberScopeBorder: other.moderatorMemberScopeBorder,
      adminMemberScopeBorder: other.adminMemberScopeBorder,
      submitIconColor: other.submitIconColor,
      changeScopeStyle: other.changeScopeStyle,
      optionsBackgroundColor: other.optionsBackgroundColor,
      optionsIconColor: other.optionsIconColor,
      optionsTextStyle: other.optionsTextStyle,
    );
  }

  static CometChatGroupMembersStyle of(BuildContext context) =>
      const CometChatGroupMembersStyle();

}
