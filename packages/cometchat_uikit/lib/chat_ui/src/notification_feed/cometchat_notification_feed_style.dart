import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';

/// Style class for [CometChatNotificationFeed] widget.
///
/// Provides styling properties for all visual elements of the notification feed
/// including header, filter chips, badges, timestamps, cards, and unread indicators.
class CometChatNotificationFeedStyle
    extends ThemeExtension<CometChatNotificationFeedStyle> {
  const CometChatNotificationFeedStyle({
    this.backgroundColor,
    this.headerTitleColor,
    this.headerTitleTextStyle,
    this.backIconColor,
    this.chipActiveBackgroundColor,
    this.chipActiveTextColor,
    this.chipInactiveBackgroundColor,
    this.chipInactiveTextColor,
    this.chipBorderColor,
    this.chipTextStyle,
    this.badgeBackgroundColor,
    this.badgeTextColor,
    this.badgeTextStyle,
    this.separatorColor,
    this.timestampTextColor,
    this.timestampTextStyle,
    this.timestampHeaderTextStyle,
    this.timestampHeaderTextColor,
    this.cardBackgroundColor,
    this.cardBorderColor,
    this.cardBorderRadius,
    this.cardBorderWidth,
    this.unreadIndicatorColor,
    this.emptyStateTextStyle,
    this.emptyStateTextColor,
    this.emptyStateSubtitleTextStyle,
    this.emptyStateSubtitleTextColor,
    this.errorStateTextStyle,
    this.errorStateTextColor,
    this.errorStateSubtitleTextStyle,
    this.errorStateSubtitleTextColor,
    this.retryButtonTextStyle,
    this.retryButtonTextColor,
    this.retryButtonBackgroundColor,
    this.connectivityBannerBackgroundColor,
    this.connectivityBannerTextColor,
    this.connectivityBannerTextStyle,
  });

  // Screen
  final Color? backgroundColor;

  // Header
  final Color? headerTitleColor;
  final TextStyle? headerTitleTextStyle;
  final Color? backIconColor;

  // Filter Chips
  final Color? chipActiveBackgroundColor;
  final Color? chipActiveTextColor;
  final Color? chipInactiveBackgroundColor;
  final Color? chipInactiveTextColor;
  final Color? chipBorderColor;
  final TextStyle? chipTextStyle;

  // Badge
  final Color? badgeBackgroundColor;
  final Color? badgeTextColor;
  final TextStyle? badgeTextStyle;

  // Content
  final Color? separatorColor;
  final Color? timestampTextColor;
  final TextStyle? timestampTextStyle;
  final TextStyle? timestampHeaderTextStyle;
  final Color? timestampHeaderTextColor;

  // Cards
  final Color? cardBackgroundColor;
  final Color? cardBorderColor;
  final double? cardBorderRadius;
  final double? cardBorderWidth;

  // Unread indicator
  final Color? unreadIndicatorColor;

  // Empty state
  final TextStyle? emptyStateTextStyle;
  final Color? emptyStateTextColor;
  final TextStyle? emptyStateSubtitleTextStyle;
  final Color? emptyStateSubtitleTextColor;

  // Error state
  final TextStyle? errorStateTextStyle;
  final Color? errorStateTextColor;
  final TextStyle? errorStateSubtitleTextStyle;
  final Color? errorStateSubtitleTextColor;

  // Retry button
  final TextStyle? retryButtonTextStyle;
  final Color? retryButtonTextColor;
  final Color? retryButtonBackgroundColor;

  // Connectivity banner
  final Color? connectivityBannerBackgroundColor;
  final Color? connectivityBannerTextColor;
  final TextStyle? connectivityBannerTextStyle;

  static CometChatNotificationFeedStyle of(BuildContext context) {
    final colorPalette = CometChatThemeHelper.getColorPalette(context);
    final typography = CometChatThemeHelper.getTypography(context);

    return CometChatNotificationFeedStyle(
      // Screen
      backgroundColor: colorPalette.background1,
      // Header
      headerTitleColor: colorPalette.textPrimary,
      headerTitleTextStyle: typography.heading3?.bold,
      backIconColor: colorPalette.iconPrimary,
      // Filter Chips
      chipActiveBackgroundColor: colorPalette.primary,
      chipActiveTextColor: colorPalette.textWhite,
      chipInactiveBackgroundColor: Colors.transparent,
      chipInactiveTextColor: colorPalette.textPrimary,
      chipBorderColor: colorPalette.borderDefault,
      chipTextStyle: typography.body?.medium,
      // Badge
      badgeBackgroundColor: colorPalette.background3,
      badgeTextColor: colorPalette.textSecondary,
      badgeTextStyle: typography.caption2?.medium,
      // Content
      separatorColor: colorPalette.borderLight,
      timestampTextColor: colorPalette.textTertiary,
      timestampTextStyle: typography.caption2?.regular,
      timestampHeaderTextStyle: typography.caption1?.medium,
      timestampHeaderTextColor: colorPalette.textSecondary,
      // Cards
      cardBackgroundColor: colorPalette.background2,
      cardBorderColor: colorPalette.borderLight,
      cardBorderRadius: 12,
      cardBorderWidth: 0.5,
      // Unread indicator
      unreadIndicatorColor: colorPalette.primary,
      // Empty state
      emptyStateTextStyle: typography.heading4?.medium,
      emptyStateTextColor: colorPalette.textSecondary,
      emptyStateSubtitleTextStyle: typography.body?.regular,
      emptyStateSubtitleTextColor: colorPalette.textTertiary,
      // Error state
      errorStateTextStyle: typography.heading4?.medium,
      errorStateTextColor: colorPalette.textSecondary,
      errorStateSubtitleTextStyle: typography.body?.regular,
      errorStateSubtitleTextColor: colorPalette.textTertiary,
      // Retry button
      retryButtonTextStyle: typography.button?.medium,
      retryButtonTextColor: colorPalette.buttonText,
      retryButtonBackgroundColor: colorPalette.primary,
      // Connectivity banner
      connectivityBannerBackgroundColor: colorPalette.warning?.withValues(alpha: 0.15),
      connectivityBannerTextColor: colorPalette.warning,
      connectivityBannerTextStyle: typography.caption1?.regular,
    );
  }

  @override
  CometChatNotificationFeedStyle copyWith({
    Color? backgroundColor,
    Color? headerTitleColor,
    TextStyle? headerTitleTextStyle,
    Color? backIconColor,
    Color? chipActiveBackgroundColor,
    Color? chipActiveTextColor,
    Color? chipInactiveBackgroundColor,
    Color? chipInactiveTextColor,
    Color? chipBorderColor,
    TextStyle? chipTextStyle,
    Color? badgeBackgroundColor,
    Color? badgeTextColor,
    TextStyle? badgeTextStyle,
    Color? separatorColor,
    Color? timestampTextColor,
    TextStyle? timestampTextStyle,
    TextStyle? timestampHeaderTextStyle,
    Color? timestampHeaderTextColor,
    Color? cardBackgroundColor,
    Color? cardBorderColor,
    double? cardBorderRadius,
    double? cardBorderWidth,
    Color? unreadIndicatorColor,
    TextStyle? emptyStateTextStyle,
    Color? emptyStateTextColor,
    TextStyle? emptyStateSubtitleTextStyle,
    Color? emptyStateSubtitleTextColor,
    TextStyle? errorStateTextStyle,
    Color? errorStateTextColor,
    TextStyle? errorStateSubtitleTextStyle,
    Color? errorStateSubtitleTextColor,
    TextStyle? retryButtonTextStyle,
    Color? retryButtonTextColor,
    Color? retryButtonBackgroundColor,
    Color? connectivityBannerBackgroundColor,
    Color? connectivityBannerTextColor,
    TextStyle? connectivityBannerTextStyle,
  }) {
    return CometChatNotificationFeedStyle(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      headerTitleColor: headerTitleColor ?? this.headerTitleColor,
      headerTitleTextStyle: headerTitleTextStyle ?? this.headerTitleTextStyle,
      backIconColor: backIconColor ?? this.backIconColor,
      chipActiveBackgroundColor:
          chipActiveBackgroundColor ?? this.chipActiveBackgroundColor,
      chipActiveTextColor: chipActiveTextColor ?? this.chipActiveTextColor,
      chipInactiveBackgroundColor:
          chipInactiveBackgroundColor ?? this.chipInactiveBackgroundColor,
      chipInactiveTextColor:
          chipInactiveTextColor ?? this.chipInactiveTextColor,
      chipBorderColor: chipBorderColor ?? this.chipBorderColor,
      chipTextStyle: chipTextStyle ?? this.chipTextStyle,
      badgeBackgroundColor: badgeBackgroundColor ?? this.badgeBackgroundColor,
      badgeTextColor: badgeTextColor ?? this.badgeTextColor,
      badgeTextStyle: badgeTextStyle ?? this.badgeTextStyle,
      separatorColor: separatorColor ?? this.separatorColor,
      timestampTextColor: timestampTextColor ?? this.timestampTextColor,
      timestampTextStyle: timestampTextStyle ?? this.timestampTextStyle,
      timestampHeaderTextStyle:
          timestampHeaderTextStyle ?? this.timestampHeaderTextStyle,
      timestampHeaderTextColor:
          timestampHeaderTextColor ?? this.timestampHeaderTextColor,
      cardBackgroundColor: cardBackgroundColor ?? this.cardBackgroundColor,
      cardBorderColor: cardBorderColor ?? this.cardBorderColor,
      cardBorderRadius: cardBorderRadius ?? this.cardBorderRadius,
      cardBorderWidth: cardBorderWidth ?? this.cardBorderWidth,
      unreadIndicatorColor: unreadIndicatorColor ?? this.unreadIndicatorColor,
      emptyStateTextStyle: emptyStateTextStyle ?? this.emptyStateTextStyle,
      emptyStateTextColor: emptyStateTextColor ?? this.emptyStateTextColor,
      emptyStateSubtitleTextStyle:
          emptyStateSubtitleTextStyle ?? this.emptyStateSubtitleTextStyle,
      emptyStateSubtitleTextColor:
          emptyStateSubtitleTextColor ?? this.emptyStateSubtitleTextColor,
      errorStateTextStyle: errorStateTextStyle ?? this.errorStateTextStyle,
      errorStateTextColor: errorStateTextColor ?? this.errorStateTextColor,
      errorStateSubtitleTextStyle:
          errorStateSubtitleTextStyle ?? this.errorStateSubtitleTextStyle,
      errorStateSubtitleTextColor:
          errorStateSubtitleTextColor ?? this.errorStateSubtitleTextColor,
      retryButtonTextStyle: retryButtonTextStyle ?? this.retryButtonTextStyle,
      retryButtonTextColor: retryButtonTextColor ?? this.retryButtonTextColor,
      retryButtonBackgroundColor:
          retryButtonBackgroundColor ?? this.retryButtonBackgroundColor,
      connectivityBannerBackgroundColor: connectivityBannerBackgroundColor ??
          this.connectivityBannerBackgroundColor,
      connectivityBannerTextColor:
          connectivityBannerTextColor ?? this.connectivityBannerTextColor,
      connectivityBannerTextStyle:
          connectivityBannerTextStyle ?? this.connectivityBannerTextStyle,
    );
  }

  /// Merge another style on top of this one (non-null values override).
  CometChatNotificationFeedStyle merge(
      CometChatNotificationFeedStyle? other) {
    if (other == null) return this;
    return copyWith(
      backgroundColor: other.backgroundColor,
      headerTitleColor: other.headerTitleColor,
      headerTitleTextStyle: other.headerTitleTextStyle,
      backIconColor: other.backIconColor,
      chipActiveBackgroundColor: other.chipActiveBackgroundColor,
      chipActiveTextColor: other.chipActiveTextColor,
      chipInactiveBackgroundColor: other.chipInactiveBackgroundColor,
      chipInactiveTextColor: other.chipInactiveTextColor,
      chipBorderColor: other.chipBorderColor,
      chipTextStyle: other.chipTextStyle,
      badgeBackgroundColor: other.badgeBackgroundColor,
      badgeTextColor: other.badgeTextColor,
      badgeTextStyle: other.badgeTextStyle,
      separatorColor: other.separatorColor,
      timestampTextColor: other.timestampTextColor,
      timestampTextStyle: other.timestampTextStyle,
      timestampHeaderTextStyle: other.timestampHeaderTextStyle,
      timestampHeaderTextColor: other.timestampHeaderTextColor,
      cardBackgroundColor: other.cardBackgroundColor,
      cardBorderColor: other.cardBorderColor,
      cardBorderRadius: other.cardBorderRadius,
      cardBorderWidth: other.cardBorderWidth,
      unreadIndicatorColor: other.unreadIndicatorColor,
      emptyStateTextStyle: other.emptyStateTextStyle,
      emptyStateTextColor: other.emptyStateTextColor,
      emptyStateSubtitleTextStyle: other.emptyStateSubtitleTextStyle,
      emptyStateSubtitleTextColor: other.emptyStateSubtitleTextColor,
      errorStateTextStyle: other.errorStateTextStyle,
      errorStateTextColor: other.errorStateTextColor,
      errorStateSubtitleTextStyle: other.errorStateSubtitleTextStyle,
      errorStateSubtitleTextColor: other.errorStateSubtitleTextColor,
      retryButtonTextStyle: other.retryButtonTextStyle,
      retryButtonTextColor: other.retryButtonTextColor,
      retryButtonBackgroundColor: other.retryButtonBackgroundColor,
      connectivityBannerBackgroundColor:
          other.connectivityBannerBackgroundColor,
      connectivityBannerTextColor: other.connectivityBannerTextColor,
      connectivityBannerTextStyle: other.connectivityBannerTextStyle,
    );
  }

  @override
  CometChatNotificationFeedStyle lerp(
      ThemeExtension<CometChatNotificationFeedStyle>? other, double t) {
    if (other is! CometChatNotificationFeedStyle) {
      return this;
    }
    return CometChatNotificationFeedStyle(
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t),
      headerTitleColor:
          Color.lerp(headerTitleColor, other.headerTitleColor, t),
      headerTitleTextStyle:
          TextStyle.lerp(headerTitleTextStyle, other.headerTitleTextStyle, t),
      backIconColor: Color.lerp(backIconColor, other.backIconColor, t),
      chipActiveBackgroundColor: Color.lerp(
          chipActiveBackgroundColor, other.chipActiveBackgroundColor, t),
      chipActiveTextColor:
          Color.lerp(chipActiveTextColor, other.chipActiveTextColor, t),
      chipInactiveBackgroundColor: Color.lerp(
          chipInactiveBackgroundColor, other.chipInactiveBackgroundColor, t),
      chipInactiveTextColor:
          Color.lerp(chipInactiveTextColor, other.chipInactiveTextColor, t),
      chipBorderColor: Color.lerp(chipBorderColor, other.chipBorderColor, t),
      chipTextStyle: TextStyle.lerp(chipTextStyle, other.chipTextStyle, t),
      badgeBackgroundColor:
          Color.lerp(badgeBackgroundColor, other.badgeBackgroundColor, t),
      badgeTextColor: Color.lerp(badgeTextColor, other.badgeTextColor, t),
      badgeTextStyle: TextStyle.lerp(badgeTextStyle, other.badgeTextStyle, t),
      separatorColor: Color.lerp(separatorColor, other.separatorColor, t),
      timestampTextColor:
          Color.lerp(timestampTextColor, other.timestampTextColor, t),
      timestampTextStyle:
          TextStyle.lerp(timestampTextStyle, other.timestampTextStyle, t),
      timestampHeaderTextStyle: TextStyle.lerp(
          timestampHeaderTextStyle, other.timestampHeaderTextStyle, t),
      timestampHeaderTextColor: Color.lerp(
          timestampHeaderTextColor, other.timestampHeaderTextColor, t),
      cardBackgroundColor:
          Color.lerp(cardBackgroundColor, other.cardBackgroundColor, t),
      cardBorderColor: Color.lerp(cardBorderColor, other.cardBorderColor, t),
      cardBorderRadius:
          lerpDouble(cardBorderRadius, other.cardBorderRadius, t),
      cardBorderWidth: lerpDouble(cardBorderWidth, other.cardBorderWidth, t),
      unreadIndicatorColor:
          Color.lerp(unreadIndicatorColor, other.unreadIndicatorColor, t),
      emptyStateTextStyle:
          TextStyle.lerp(emptyStateTextStyle, other.emptyStateTextStyle, t),
      emptyStateTextColor:
          Color.lerp(emptyStateTextColor, other.emptyStateTextColor, t),
      emptyStateSubtitleTextStyle: TextStyle.lerp(
          emptyStateSubtitleTextStyle, other.emptyStateSubtitleTextStyle, t),
      emptyStateSubtitleTextColor: Color.lerp(
          emptyStateSubtitleTextColor, other.emptyStateSubtitleTextColor, t),
      errorStateTextStyle:
          TextStyle.lerp(errorStateTextStyle, other.errorStateTextStyle, t),
      errorStateTextColor:
          Color.lerp(errorStateTextColor, other.errorStateTextColor, t),
      errorStateSubtitleTextStyle: TextStyle.lerp(
          errorStateSubtitleTextStyle, other.errorStateSubtitleTextStyle, t),
      errorStateSubtitleTextColor: Color.lerp(
          errorStateSubtitleTextColor, other.errorStateSubtitleTextColor, t),
      retryButtonTextStyle:
          TextStyle.lerp(retryButtonTextStyle, other.retryButtonTextStyle, t),
      retryButtonTextColor:
          Color.lerp(retryButtonTextColor, other.retryButtonTextColor, t),
      retryButtonBackgroundColor: Color.lerp(
          retryButtonBackgroundColor, other.retryButtonBackgroundColor, t),
      connectivityBannerBackgroundColor: Color.lerp(
          connectivityBannerBackgroundColor,
          other.connectivityBannerBackgroundColor,
          t),
      connectivityBannerTextColor: Color.lerp(
          connectivityBannerTextColor, other.connectivityBannerTextColor, t),
      connectivityBannerTextStyle: TextStyle.lerp(
          connectivityBannerTextStyle, other.connectivityBannerTextStyle, t),
    );
  }
}
