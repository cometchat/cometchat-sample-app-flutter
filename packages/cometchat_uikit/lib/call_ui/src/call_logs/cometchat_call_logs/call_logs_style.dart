import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../cometchat_chat_uikit.dart';


/// [CometChatCallLogsStyle] is a data class that has styling-related properties for [CometChatCallLogs]
/// This class is used to style CometChatCallLogs
/// ```dart
/// CometChatCallLogsStyle(
///  backgroundColor: Colors.white,
///  border: Border.all(color: Colors.red),
///  borderRadius: BorderRadius.circular(10),
///  backIconColor: Colors.red,
///  titleTextStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
///  titleTextColor: Colors.black,
///  emptyStateTextStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
///  );
///  ```
class CometChatCallLogsStyle extends ThemeExtension<CometChatCallLogsStyle> {
  const CometChatCallLogsStyle({
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
    this.separatorColor,
    this.separatorHeight,
    this.avatarStyle,
    this.dateStyle,
    this.retryButtonBackgroundColor,
    this.retryButtonBorder,
    this.retryButtonBorderRadius,
    this.retryButtonTextColor,
    this.retryButtonTextStyle,
    this.incomingCallIconColor,
    this.outgoingCallIconColor,
    this.missedCallIconColor,
    this.audioCallIconColor,
    this.videoCallIconColor,
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

  ///[separatorHeight] provides height for the separator
  final double? separatorHeight;

  ///[separatorColor] provides color for the separator
  final Color? separatorColor;

  ///[dateStyle] provides styling for CometChatDate
  final CometChatDateStyle? dateStyle;

  ///[avatarStyle] set style for avatar
  final CometChatAvatarStyle? avatarStyle;

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

  ///[incomingCallIconColor] incoming call icon color
  final Color? incomingCallIconColor;

  ///[outgoingCallIconColor] outgoing call icon color
  final Color? outgoingCallIconColor;

  ///[missedCallIconColor] missed call icon color
  final Color? missedCallIconColor;

  ///[audioCallIconColor] audio call icon color
  final Color? audioCallIconColor;

  ///[videoCallIconColor] video call icon color
  final Color? videoCallIconColor;

  static CometChatCallLogsStyle of(BuildContext context) =>
      const CometChatCallLogsStyle();

  @override
  CometChatCallLogsStyle copyWith({
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
    TextStyle? emptyStateSubTitleTextStyle,
    Color? emptyStateSubTitleTextColor,
    TextStyle? errorStateSubTitleTextStyle,
    Color? errorStateSubTitleTextColor,
    TextStyle? itemTitleTextStyle,
    Color? itemTitleTextColor,
    double? separatorHeight,
    Color? separatorColor,
    CometChatAvatarStyle? messageBubbleAvatarStyle,
    CometChatDateStyle? dateStyle,
    Color? retryButtonBackgroundColor,
    Color? retryButtonTextColor,
    TextStyle? retryButtonTextStyle,
    BorderSide? retryButtonBorder,
    BorderRadiusGeometry? retryButtonBorderRadius,
    Color? incomingCallIconColor,
    Color? outgoingCallIconColor,
    Color? missedCallIconColor,
    Color? audioCallIconColor,
    Color? videoCallIconColor,
  }) {
    return CometChatCallLogsStyle(
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
          emptyStateSubTitleTextStyle ?? this.emptyStateSubTitleTextStyle,
      emptyStateSubTitleTextColor:
          emptyStateSubTitleTextColor ?? this.emptyStateSubTitleTextColor,
      errorStateSubTitleTextStyle:
          errorStateSubTitleTextStyle ?? this.errorStateSubTitleTextStyle,
      errorStateSubTitleTextColor:
          errorStateSubTitleTextColor ?? this.errorStateSubTitleTextColor,
      itemTitleTextStyle: itemTitleTextStyle ?? this.itemTitleTextStyle,
      itemTitleTextColor: itemTitleTextColor ?? this.itemTitleTextColor,
      separatorHeight: separatorHeight ?? this.separatorHeight,
      separatorColor: separatorColor ?? this.separatorColor,
      avatarStyle: messageBubbleAvatarStyle ?? avatarStyle,
      dateStyle: dateStyle ?? this.dateStyle,
      retryButtonBackgroundColor:
          retryButtonBackgroundColor ?? this.retryButtonBackgroundColor,
      retryButtonTextColor: retryButtonTextColor ?? this.retryButtonTextColor,
      retryButtonTextStyle: retryButtonTextStyle ?? this.retryButtonTextStyle,
      retryButtonBorder: retryButtonBorder ?? this.retryButtonBorder,
      retryButtonBorderRadius:
          retryButtonBorderRadius ?? this.retryButtonBorderRadius,
      incomingCallIconColor:
          incomingCallIconColor ?? this.incomingCallIconColor,
      outgoingCallIconColor:
          outgoingCallIconColor ?? this.outgoingCallIconColor,
      missedCallIconColor: missedCallIconColor ?? this.missedCallIconColor,
      audioCallIconColor: audioCallIconColor ?? this.audioCallIconColor,
      videoCallIconColor: videoCallIconColor ?? this.videoCallIconColor,
    );
  }

  CometChatCallLogsStyle merge(CometChatCallLogsStyle? style) {
    if (style == null) return this;
    return copyWith(
      errorStateTextColor: style.errorStateTextColor,
      emptyStateSubTitleTextStyle: style.emptyStateSubTitleTextStyle,
      emptyStateSubTitleTextColor: style.emptyStateSubTitleTextColor,
      errorStateSubTitleTextStyle: style.errorStateSubTitleTextStyle,
      errorStateSubTitleTextColor: style.errorStateSubTitleTextColor,
      itemTitleTextStyle: style.itemTitleTextStyle,
      itemTitleTextColor: style.itemTitleTextColor,
      separatorHeight: style.separatorHeight,
      separatorColor: style.separatorColor,
      messageBubbleAvatarStyle: style.avatarStyle,
      dateStyle: style.dateStyle,
      backgroundColor: style.backgroundColor,
      border: style.border,
      borderRadius: style.borderRadius,
      backIconColor: style.backIconColor,
      titleTextStyle: style.titleTextStyle,
      titleTextColor: style.titleTextColor,
      emptyStateTextStyle: style.emptyStateTextStyle,
      emptyStateTextColor: style.emptyStateTextColor,
      errorStateTextStyle: style.errorStateTextStyle,
      retryButtonBackgroundColor: style.retryButtonBackgroundColor,
      retryButtonTextColor: style.retryButtonTextColor,
      retryButtonTextStyle: style.retryButtonTextStyle,
      retryButtonBorder: style.retryButtonBorder,
      retryButtonBorderRadius: style.retryButtonBorderRadius,
      incomingCallIconColor: style.incomingCallIconColor,
      outgoingCallIconColor: style.outgoingCallIconColor,
      missedCallIconColor: style.missedCallIconColor,
      audioCallIconColor: style.audioCallIconColor,
      videoCallIconColor: style.videoCallIconColor,
    );
  }

  @override
  CometChatCallLogsStyle lerp(
      ThemeExtension<CometChatCallLogsStyle>? other, double t) {
    if (other is! CometChatCallLogsStyle) {
      return this;
    }
    return CometChatCallLogsStyle(
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
      separatorHeight: lerpDouble(separatorHeight, other.separatorHeight, t),
      separatorColor: Color.lerp(separatorColor, other.separatorColor, t),
      avatarStyle: avatarStyle?.lerp(other.avatarStyle, t),
      dateStyle: dateStyle?.lerp(other.dateStyle, t),
      retryButtonBackgroundColor: Color.lerp(
          retryButtonBackgroundColor, other.retryButtonBackgroundColor, t),
      retryButtonTextColor:
          Color.lerp(retryButtonTextColor, other.retryButtonTextColor, t),
      retryButtonTextStyle:
          TextStyle.lerp(retryButtonTextStyle, other.retryButtonTextStyle, t),
      retryButtonBorder: BorderSide.lerp(retryButtonBorder ?? BorderSide.none,
          other.retryButtonBorder ?? BorderSide.none, t),
      retryButtonBorderRadius: BorderRadiusGeometry.lerp(
          retryButtonBorderRadius, other.retryButtonBorderRadius, t),
      incomingCallIconColor:
          Color.lerp(incomingCallIconColor, other.incomingCallIconColor, t),
      outgoingCallIconColor:
          Color.lerp(outgoingCallIconColor, other.outgoingCallIconColor, t),
      missedCallIconColor:
          Color.lerp(missedCallIconColor, other.missedCallIconColor, t),
      audioCallIconColor:
          Color.lerp(audioCallIconColor, other.audioCallIconColor, t),
      videoCallIconColor:
          Color.lerp(videoCallIconColor, other.videoCallIconColor, t),
    );
  }
}
