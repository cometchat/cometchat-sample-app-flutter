import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../shared_ui/cometchat_uikit_shared.dart';

/// Style class for [CometChatAIAssistantChatHistory].
///
/// Follows the UIKit ThemeExtension pattern with `merge()`, `of()`, `lerp()`.
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
    this.newChatTitleStyle,
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

  final Color? backgroundColor;
  final BoxBorder? border;
  final BorderRadiusGeometry? borderRadius;
  final TextStyle? emptyStateTextStyle;
  final Color? emptyStateTextColor;
  final TextStyle? emptyStateSubtitleStyle;
  final Color? emptyStateSubtitleColor;
  final TextStyle? errorStateTextStyle;
  final Color? errorStateTextColor;
  final TextStyle? errorStateSubtitleStyle;
  final Color? errorStateSubtitleColor;
  final CometChatDateStyle? dateSeparatorStyle;
  final Color? newChatTextColor;
  final TextStyle? newChatTitleStyle;
  final Color? newChatIconColor;
  final TextStyle? itemTextStyle;
  final Color? itemTextColor;
  final Color? headerBackgroundColor;
  final TextStyle? headerTitleTextStyle;
  final Color? headerTitleTextColor;
  final Color? closeIconColor;
  final double? separatorHeight;
  final Color? separatorColor;
  final CometChatConfirmDialogStyle? deleteChatHistoryDialogStyle;

  @override
  CometChatAIAssistantChatHistoryStyle copyWith({
    Color? backgroundColor,
    BoxBorder? border,
    BorderRadiusGeometry? borderRadius,
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
    TextStyle? newChatTitleStyle,
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
      newChatTitleStyle: newChatTitleStyle ?? this.newChatTitleStyle,
      newChatTextColor: newChatTextColor ?? this.newChatTextColor,
      itemTextStyle: itemTextStyle ?? this.itemTextStyle,
      itemTextColor: itemTextColor ?? this.itemTextColor,
      headerBackgroundColor:
          headerBackgroundColor ?? this.headerBackgroundColor,
      headerTitleTextStyle: headerTitleTextStyle ?? this.headerTitleTextStyle,
      headerTitleTextColor: headerTitleTextColor ?? this.headerTitleTextColor,
      closeIconColor: closeIconColor ?? this.closeIconColor,
      separatorHeight: separatorHeight ?? this.separatorHeight,
      separatorColor: separatorColor ?? this.separatorColor,
      deleteChatHistoryDialogStyle:
          deleteChatHistoryDialogStyle ?? this.deleteChatHistoryDialogStyle,
    );
  }

  CometChatAIAssistantChatHistoryStyle merge(
    CometChatAIAssistantChatHistoryStyle? other,
  ) {
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
      newChatTitleStyle: other.newChatTitleStyle,
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
    CometChatAIAssistantChatHistoryStyle? other,
    double t,
  ) {
    if (other is! CometChatAIAssistantChatHistoryStyle) return this;
    return CometChatAIAssistantChatHistoryStyle(
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t),
      border: BoxBorder.lerp(border, other.border, t),
      borderRadius: BorderRadiusGeometry.lerp(
        borderRadius,
        other.borderRadius,
        t,
      ),
      emptyStateTextStyle: TextStyle.lerp(
        emptyStateTextStyle,
        other.emptyStateTextStyle,
        t,
      ),
      emptyStateTextColor: Color.lerp(
        emptyStateTextColor,
        other.emptyStateTextColor,
        t,
      ),
      emptyStateSubtitleStyle: TextStyle.lerp(
        emptyStateSubtitleStyle,
        other.emptyStateSubtitleStyle,
        t,
      ),
      emptyStateSubtitleColor: Color.lerp(
        emptyStateSubtitleColor,
        other.emptyStateSubtitleColor,
        t,
      ),
      errorStateTextStyle: TextStyle.lerp(
        errorStateTextStyle,
        other.errorStateTextStyle,
        t,
      ),
      errorStateTextColor: Color.lerp(
        errorStateTextColor,
        other.errorStateTextColor,
        t,
      ),
      errorStateSubtitleStyle: TextStyle.lerp(
        errorStateSubtitleStyle,
        other.errorStateSubtitleStyle,
        t,
      ),
      errorStateSubtitleColor: Color.lerp(
        errorStateSubtitleColor,
        other.errorStateSubtitleColor,
        t,
      ),
      dateSeparatorStyle: dateSeparatorStyle?.lerp(other.dateSeparatorStyle, t),
      newChatIconColor: Color.lerp(newChatIconColor, other.newChatIconColor, t),
      newChatTitleStyle: TextStyle.lerp(
        newChatTitleStyle,
        other.newChatTitleStyle,
        t,
      ),
      newChatTextColor: Color.lerp(newChatTextColor, other.newChatTextColor, t),
      itemTextStyle: TextStyle.lerp(itemTextStyle, other.itemTextStyle, t),
      itemTextColor: Color.lerp(itemTextColor, other.itemTextColor, t),
      headerBackgroundColor: Color.lerp(
        headerBackgroundColor,
        other.headerBackgroundColor,
        t,
      ),
      headerTitleTextStyle: TextStyle.lerp(
        headerTitleTextStyle,
        other.headerTitleTextStyle,
        t,
      ),
      headerTitleTextColor: Color.lerp(
        headerTitleTextColor,
        other.headerTitleTextColor,
        t,
      ),
      closeIconColor: Color.lerp(closeIconColor, other.closeIconColor, t),
      separatorHeight: lerpDouble(separatorHeight, other.separatorHeight, t),
      separatorColor: Color.lerp(separatorColor, other.separatorColor, t),
      deleteChatHistoryDialogStyle: deleteChatHistoryDialogStyle?.lerp(
        other.deleteChatHistoryDialogStyle,
        t,
      ),
    );
  }
}
