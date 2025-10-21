import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';

///[CometChatAIAssistantChatHistoryStyle] is a data class that has styling-related properties
///to customize the appearance of [CometChatAIAssistantChatHistory]
///
/// ```dart
/// ```
class CometChatAIAssistantChatHistoryStyle
    extends ThemeExtension<CometChatAIAssistantChatHistoryStyle> {
  const CometChatAIAssistantChatHistoryStyle({
    this.border,
    this.borderRadius,
    this.backgroundColor,
    this.emptyStateTextStyle,
    this.emptyStateTextColor,
    this.emptyStateSubtitleStyle,
    this.emptyStateSubtitleColor,
    this.errorStateTextStyle,
    this.errorStateTextColor,
    this.errorStateSubtitleStyle,
    this.errorStateSubtitleColor,
    this.dateSeparatorStyle,
    this.newChatIconColor,
    this.newChaTitleStyle,
    this.newChatTextColor,
    this.itemTextStyle,
    this.itemTextColor,
    this.headerBackgroundColor,
    this.headerTitleTextStyle,
    this.headerTitleTextColor,
    this.closeIconColor,
    this.separatorColor,
    this.separatorHeight,
    this.deleteChatHistoryDialogStyle,
  });

  ///[backgroundColor] defines the background color of the message list
  final Color? backgroundColor;

  ///[border] defines the border of the message list
  final BoxBorder? border;

  ///[borderRadius] defines the border radius of the message list
  final BorderRadiusGeometry? borderRadius;

  ///[emptyStateTextStyle] defines the style of the text to be displayed when the message list is empty
  final TextStyle? emptyStateTextStyle;

  ///[emptyStateTextColor] defines the color of the text to be displayed when the message list is empty
  final Color? emptyStateTextColor;

  ///[emptyStateSubtitleStyle] defines the style of the subtitle to be displayed when the message list is empty
  final TextStyle? emptyStateSubtitleStyle;

  ///[emptyStateSubtitleColor] defines the color of the subtitle to be displayed when the message list is empty
  final Color? emptyStateSubtitleColor;

  ///[errorStateTextStyle] defines the style of the text to be displayed when the message list is in error state
  final TextStyle? errorStateTextStyle;

  ///[errorStateTextColor] defines the color of the text to be displayed when the message list is in error state
  final Color? errorStateTextColor;

  ///[errorStateSubtitleStyle] defines the style of the subtitle to be displayed when the message list is in error state
  final TextStyle? errorStateSubtitleStyle;

  ///[errorStateSubtitleColor] defines the color of the subtitle to be displayed when the message list is in error state
  final Color? errorStateSubtitleColor;

  ///[dateSeparatorStyle] sets style for date separator
  final CometChatDateStyle? dateSeparatorStyle;

  ///[newChatTextColor] defines the color of the new chat text
  final Color? newChatTextColor;

  ///[newChaTitleStyle] defines the style of the title to be displayed when new chat is initiated
  final TextStyle? newChaTitleStyle;

  ///[newChatIconColor] defines the color of new chat icon
  final Color? newChatIconColor;

  ///[itemTextStyle] defines the style of the text to be displayed when the message list is empty
  final TextStyle? itemTextStyle;

  ///[itemTextColor] defines the color of the text to be displayed when the message list is empty
  final Color? itemTextColor;

  ///[headerBackgroundColor] defines the background color of the header of the message list
  final Color? headerBackgroundColor;

  ///[itemTextStyle] defines the style of the title text to be displayed in the header
  final TextStyle? headerTitleTextStyle;

  ///[itemTextColor] defines the color of the title text in the header
  final Color? headerTitleTextColor;

  ///[closeIconColor] defines the color of the close icon
  final Color? closeIconColor;

  ///[separatorHeight] provides height for the separator
  final double? separatorHeight;

  ///[separatorColor] provides color for the separator
  final Color? separatorColor;

  ///[deleteChatHistoryDialogStyle] sets the style for the dialog for deleting chat history
  final CometChatConfirmDialogStyle? deleteChatHistoryDialogStyle;


  /// Copy with some properties replaced
  @override
  CometChatAIAssistantChatHistoryStyle copyWith({
    Color? backgroundColor,
    BoxBorder? border,
    BorderRadiusGeometry? borderRadius,
    Widget? loadingStateIcon,
    double? loadingStateIconSize,
    Color? loadingStateIconColor,
    TextStyle? emptyStateTextStyle,
    Color? emptyStateTextColor,
    TextStyle? emptyStateSubtitleStyle,
    Color? emptyStateSubtitleColor,
    TextStyle? errorStateTextStyle,
    Color? errorStateTextColor,
    TextStyle? errorStateSubtitleStyle,
    Color? errorStateSubtitleColor,
    CometChatDateStyle? dateSeparatorStyle,
    Color? newChatIconColor,
    TextStyle? newChaTitleStyle,
    Color? newChatTextColor,
    TextStyle? itemTextStyle,
    Color? itemTextColor,
    Color? headerBackgroundColor,
    TextStyle? headerTitleTextStyle,
    Color? headerTitleTextColor,
    Color? closeIconColor,
    double? separatorHeight,
    Color? separatorColor,
    CometChatConfirmDialogStyle? deleteChatHistoryDialogStyle,
  }) {
    return CometChatAIAssistantChatHistoryStyle(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      border: border ?? this.border,
      borderRadius: borderRadius ?? this.borderRadius,
      emptyStateTextStyle: emptyStateTextStyle ?? this.emptyStateTextStyle,
      emptyStateTextColor: emptyStateTextColor ?? this.emptyStateTextColor,
      emptyStateSubtitleStyle:
          emptyStateSubtitleStyle ?? this.emptyStateSubtitleStyle,
      emptyStateSubtitleColor:
          emptyStateSubtitleColor ?? this.emptyStateSubtitleColor,
      errorStateTextStyle: errorStateTextStyle ?? this.errorStateTextStyle,
      errorStateTextColor: errorStateTextColor ?? this.errorStateTextColor,
      errorStateSubtitleStyle:
          errorStateSubtitleStyle ?? this.errorStateSubtitleStyle,
      errorStateSubtitleColor:
          errorStateSubtitleColor ?? this.errorStateSubtitleColor,
      dateSeparatorStyle: dateSeparatorStyle ?? this.dateSeparatorStyle,
      newChatIconColor: newChatIconColor ?? this.newChatIconColor,
      newChaTitleStyle: newChaTitleStyle ?? this.newChaTitleStyle,
      newChatTextColor: newChatTextColor ?? this.newChatTextColor,
      itemTextStyle: itemTextStyle ?? this.itemTextStyle,
      itemTextColor: itemTextColor ?? this.itemTextColor,
      headerBackgroundColor: headerBackgroundColor ?? this.headerBackgroundColor,
      headerTitleTextStyle: headerTitleTextStyle ?? this.headerTitleTextStyle,
      headerTitleTextColor: headerTitleTextColor ?? this.headerTitleTextColor,
      closeIconColor: closeIconColor ?? this.closeIconColor,
      separatorHeight: separatorHeight ?? this.separatorHeight,
      separatorColor: separatorColor ?? this.separatorColor,
      deleteChatHistoryDialogStyle: deleteChatHistoryDialogStyle ?? this.deleteChatHistoryDialogStyle,
    );
  }

  /// Merge with another MessageListStyle
  CometChatAIAssistantChatHistoryStyle merge(
      CometChatAIAssistantChatHistoryStyle? other) {
    if (other == null) return this;
    return copyWith(
      backgroundColor: other.backgroundColor,
      border: other.border,
      borderRadius: other.borderRadius,
      emptyStateTextStyle: other.emptyStateTextStyle,
      emptyStateTextColor: other.emptyStateTextColor,
      emptyStateSubtitleStyle: other.emptyStateSubtitleStyle,
      emptyStateSubtitleColor: other.emptyStateSubtitleColor,
      errorStateTextStyle: other.errorStateTextStyle,
      errorStateTextColor: other.errorStateTextColor,
      errorStateSubtitleStyle: other.errorStateSubtitleStyle,
      errorStateSubtitleColor: other.errorStateSubtitleColor,
      dateSeparatorStyle: other.dateSeparatorStyle,
      newChatIconColor: other.newChatIconColor,
      newChaTitleStyle: other.newChaTitleStyle,
      newChatTextColor: other.newChatTextColor,
      itemTextStyle: other.itemTextStyle,
      itemTextColor: other.itemTextColor,
      headerBackgroundColor: other.headerBackgroundColor,
      headerTitleTextStyle: other.headerTitleTextStyle,
      headerTitleTextColor: other.headerTitleTextColor,
      closeIconColor: other.closeIconColor,
      separatorHeight: other.separatorHeight,
      separatorColor: other.separatorColor,
      deleteChatHistoryDialogStyle: other.deleteChatHistoryDialogStyle,
    );
  }

  static CometChatAIAssistantChatHistoryStyle of(BuildContext context) =>
      const CometChatAIAssistantChatHistoryStyle();

  @override
  CometChatAIAssistantChatHistoryStyle lerp(
      CometChatAIAssistantChatHistoryStyle? other, double t) {
    if (other is! CometChatAIAssistantChatHistoryStyle) {
      return this;
    }
    return CometChatAIAssistantChatHistoryStyle(
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t),
      border: BoxBorder.lerp(border, other.border, t),
      borderRadius:
          BorderRadiusGeometry.lerp(borderRadius, other.borderRadius, t),
      emptyStateTextStyle:
          TextStyle.lerp(emptyStateTextStyle, other.emptyStateTextStyle, t),
      emptyStateTextColor:
          Color.lerp(emptyStateTextColor, other.emptyStateTextColor, t),
      emptyStateSubtitleStyle: TextStyle.lerp(
          emptyStateSubtitleStyle, other.emptyStateSubtitleStyle, t),
      emptyStateSubtitleColor:
          Color.lerp(emptyStateSubtitleColor, other.emptyStateSubtitleColor, t),
      errorStateTextStyle:
          TextStyle.lerp(errorStateTextStyle, other.errorStateTextStyle, t),
      errorStateTextColor:
          Color.lerp(errorStateTextColor, other.errorStateTextColor, t),
      errorStateSubtitleStyle: TextStyle.lerp(
          errorStateSubtitleStyle, other.errorStateSubtitleStyle, t),
      errorStateSubtitleColor:
          Color.lerp(errorStateSubtitleColor, other.errorStateSubtitleColor, t),
      dateSeparatorStyle: dateSeparatorStyle?.lerp(other.dateSeparatorStyle, t),
      newChatIconColor: Color.lerp(newChatIconColor, other.newChatIconColor, t),
      newChaTitleStyle:
          TextStyle.lerp(newChaTitleStyle, other.newChaTitleStyle, t),
      newChatTextColor:
          Color.lerp(newChatTextColor, other.newChatTextColor, t),
      itemTextStyle: TextStyle.lerp(itemTextStyle, other.itemTextStyle, t),
      itemTextColor: Color.lerp(itemTextColor, other.itemTextColor, t),
      headerBackgroundColor:
          Color.lerp(headerBackgroundColor, other.headerBackgroundColor, t),
      headerTitleTextStyle:
          TextStyle.lerp(headerTitleTextStyle, other.headerTitleTextStyle, t),
      headerTitleTextColor:
          Color.lerp(headerTitleTextColor, other.headerTitleTextColor, t),
      closeIconColor: Color.lerp(closeIconColor, other.closeIconColor, t),
      separatorHeight: lerpDouble(separatorHeight, other.separatorHeight, t),
      separatorColor: Color.lerp(separatorColor, other.separatorColor, t),
        deleteChatHistoryDialogStyle: deleteChatHistoryDialogStyle?.lerp(other.deleteChatHistoryDialogStyle, t),
    );
  }
}
