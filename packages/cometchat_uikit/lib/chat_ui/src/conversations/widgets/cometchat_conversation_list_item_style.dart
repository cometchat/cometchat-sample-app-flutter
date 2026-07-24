import 'package:flutter/material.dart';
import '../../../../cometchat_chat_uikit.dart';

/// Style configuration for [CometChatConversationListItem] component.
///
/// This class encapsulates all visual styling properties for the conversation list item,
/// integrating with the CometChatTheme system for consistent styling.
class CometChatConversationListItemStyle {
  /// Background color for the list item.
  final Color? backgroundColor;

  /// Background color when the item is selected.
  final Color? selectedBackgroundColor;

  /// Text color for the conversation title.
  final Color? titleTextColor;

  /// Text style for the conversation title.
  final TextStyle? titleTextStyle;

  /// Text color for the subtitle (last message preview).
  final Color? subtitleTextColor;

  /// Text style for the subtitle.
  final TextStyle? subtitleTextStyle;

  /// Tint color for message type icons (photo, video, etc.).
  final Color? messageTypeIconTint;

  /// Stroke width for the selection checkbox.
  final double? checkBoxStrokeWidth;

  /// Corner radius for the selection checkbox.
  final BorderRadius? checkBoxBorderRadius;

  /// Stroke color for the unselected checkbox.
  final Color? checkBoxStrokeColor;

  /// Background color for the unselected checkbox.
  final Color? checkBoxBackgroundColor;

  /// Background color for the selected checkbox.
  final Color? checkBoxCheckedBackgroundColor;

  /// Icon to display when checkbox is selected.
  final Widget? checkBoxSelectIcon;

  /// Tint color for the checkbox select icon.
  final Color? checkBoxSelectIconTint;

  /// Color for the item separator line.
  final Color? separatorColor;

  /// Height of the item separator line.
  final double? separatorHeight;

  /// Style configuration for the avatar component.
  final CometChatAvatarStyle? avatarStyle;

  /// Style configuration for the status indicator.
  final CometChatStatusIndicatorStyle? statusIndicatorStyle;

  /// Style configuration for the date component.
  final CometChatDateStyle? dateStyle;

  /// Style configuration for the unread badge component.
  final CometChatBadgeStyle? badgeStyle;

  /// Style configuration for message receipts.
  final CometChatMessageReceiptStyle? receiptStyle;

  /// Style configuration for typing indicator.
  final CometChatTypingIndicatorStyle? typingIndicatorStyle;

  const CometChatConversationListItemStyle({
    this.backgroundColor,
    this.selectedBackgroundColor,
    this.titleTextColor,
    this.titleTextStyle,
    this.subtitleTextColor,
    this.subtitleTextStyle,
    this.messageTypeIconTint,
    this.checkBoxStrokeWidth,
    this.checkBoxBorderRadius,
    this.checkBoxStrokeColor,
    this.checkBoxBackgroundColor,
    this.checkBoxCheckedBackgroundColor,
    this.checkBoxSelectIcon,
    this.checkBoxSelectIconTint,
    this.separatorColor,
    this.separatorHeight,
    this.avatarStyle,
    this.statusIndicatorStyle,
    this.dateStyle,
    this.badgeStyle,
    this.receiptStyle,
    this.typingIndicatorStyle,
  });

  /// Creates a default style with values sourced from CometChatTheme.
  factory CometChatConversationListItemStyle.fromTheme(BuildContext context) {
    final colorPalette = CometChatThemeHelper.getColorPalette(context);
    final typography = CometChatThemeHelper.getTypography(context);
    final spacing = CometChatThemeHelper.getSpacing(context);

    return CometChatConversationListItemStyle(
      backgroundColor: colorPalette.background1,
      selectedBackgroundColor: colorPalette.background4,
      titleTextColor: colorPalette.textPrimary,
      titleTextStyle: typography.heading4?.medium,
      subtitleTextColor: colorPalette.textSecondary,
      subtitleTextStyle: typography.body?.regular,
      messageTypeIconTint: colorPalette.iconSecondary,
      checkBoxStrokeWidth: 1.5,
      checkBoxBorderRadius: BorderRadius.circular(spacing.radius1 ?? 4),
      checkBoxStrokeColor: colorPalette.borderDefault,
      checkBoxBackgroundColor: Colors.transparent,
      checkBoxCheckedBackgroundColor: colorPalette.primary,
      checkBoxSelectIcon: Icon(
        Icons.check,
        size: 14,
        color: colorPalette.white,
      ),
      checkBoxSelectIconTint: colorPalette.white,
      separatorColor: colorPalette.borderLight,
      separatorHeight: 1,
      avatarStyle: const CometChatAvatarStyle(),
      statusIndicatorStyle: const CometChatStatusIndicatorStyle(),
      dateStyle: CometChatDateStyle(
        textColor: colorPalette.textSecondary,
        textStyle: typography.caption1?.regular,
      ),
      badgeStyle: CometChatBadgeStyle(
        borderRadius: BorderRadius.circular(spacing.radius3?.toDouble() ?? 12),
      ),
      receiptStyle: CometChatMessageReceiptStyle(),
      typingIndicatorStyle: CometChatTypingIndicatorStyle(
        textStyle: typography.body?.regular,
      ),
    );
  }

  /// Merges this style with another style, with the other style taking precedence.
  CometChatConversationListItemStyle merge(
    CometChatConversationListItemStyle? other,
  ) {
    if (other == null) return this;

    return CometChatConversationListItemStyle(
      backgroundColor: other.backgroundColor ?? backgroundColor,
      selectedBackgroundColor:
          other.selectedBackgroundColor ?? selectedBackgroundColor,
      titleTextColor: other.titleTextColor ?? titleTextColor,
      titleTextStyle: other.titleTextStyle ?? titleTextStyle,
      subtitleTextColor: other.subtitleTextColor ?? subtitleTextColor,
      subtitleTextStyle: other.subtitleTextStyle ?? subtitleTextStyle,
      messageTypeIconTint: other.messageTypeIconTint ?? messageTypeIconTint,
      checkBoxStrokeWidth: other.checkBoxStrokeWidth ?? checkBoxStrokeWidth,
      checkBoxBorderRadius: other.checkBoxBorderRadius ?? checkBoxBorderRadius,
      checkBoxStrokeColor: other.checkBoxStrokeColor ?? checkBoxStrokeColor,
      checkBoxBackgroundColor:
          other.checkBoxBackgroundColor ?? checkBoxBackgroundColor,
      checkBoxCheckedBackgroundColor:
          other.checkBoxCheckedBackgroundColor ??
          checkBoxCheckedBackgroundColor,
      checkBoxSelectIcon: other.checkBoxSelectIcon ?? checkBoxSelectIcon,
      checkBoxSelectIconTint:
          other.checkBoxSelectIconTint ?? checkBoxSelectIconTint,
      separatorColor: other.separatorColor ?? separatorColor,
      separatorHeight: other.separatorHeight ?? separatorHeight,
      avatarStyle: other.avatarStyle ?? avatarStyle,
      statusIndicatorStyle: other.statusIndicatorStyle ?? statusIndicatorStyle,
      dateStyle: other.dateStyle ?? dateStyle,
      badgeStyle: other.badgeStyle ?? badgeStyle,
      receiptStyle: other.receiptStyle ?? receiptStyle,
      typingIndicatorStyle: other.typingIndicatorStyle ?? typingIndicatorStyle,
    );
  }

  /// Creates a copy of this style with the given fields replaced.
  CometChatConversationListItemStyle copyWith({
    Color? backgroundColor,
    Color? selectedBackgroundColor,
    Color? titleTextColor,
    TextStyle? titleTextStyle,
    Color? subtitleTextColor,
    TextStyle? subtitleTextStyle,
    Color? messageTypeIconTint,
    double? checkBoxStrokeWidth,
    BorderRadius? checkBoxBorderRadius,
    Color? checkBoxStrokeColor,
    Color? checkBoxBackgroundColor,
    Color? checkBoxCheckedBackgroundColor,
    Widget? checkBoxSelectIcon,
    Color? checkBoxSelectIconTint,
    Color? separatorColor,
    double? separatorHeight,
    CometChatAvatarStyle? avatarStyle,
    CometChatStatusIndicatorStyle? statusIndicatorStyle,
    CometChatDateStyle? dateStyle,
    CometChatBadgeStyle? badgeStyle,
    CometChatMessageReceiptStyle? receiptStyle,
    CometChatTypingIndicatorStyle? typingIndicatorStyle,
  }) {
    return CometChatConversationListItemStyle(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      selectedBackgroundColor:
          selectedBackgroundColor ?? this.selectedBackgroundColor,
      titleTextColor: titleTextColor ?? this.titleTextColor,
      titleTextStyle: titleTextStyle ?? this.titleTextStyle,
      subtitleTextColor: subtitleTextColor ?? this.subtitleTextColor,
      subtitleTextStyle: subtitleTextStyle ?? this.subtitleTextStyle,
      messageTypeIconTint: messageTypeIconTint ?? this.messageTypeIconTint,
      checkBoxStrokeWidth: checkBoxStrokeWidth ?? this.checkBoxStrokeWidth,
      checkBoxBorderRadius: checkBoxBorderRadius ?? this.checkBoxBorderRadius,
      checkBoxStrokeColor: checkBoxStrokeColor ?? this.checkBoxStrokeColor,
      checkBoxBackgroundColor:
          checkBoxBackgroundColor ?? this.checkBoxBackgroundColor,
      checkBoxCheckedBackgroundColor:
          checkBoxCheckedBackgroundColor ?? this.checkBoxCheckedBackgroundColor,
      checkBoxSelectIcon: checkBoxSelectIcon ?? this.checkBoxSelectIcon,
      checkBoxSelectIconTint:
          checkBoxSelectIconTint ?? this.checkBoxSelectIconTint,
      separatorColor: separatorColor ?? this.separatorColor,
      separatorHeight: separatorHeight ?? this.separatorHeight,
      avatarStyle: avatarStyle ?? this.avatarStyle,
      statusIndicatorStyle: statusIndicatorStyle ?? this.statusIndicatorStyle,
      dateStyle: dateStyle ?? this.dateStyle,
      badgeStyle: badgeStyle ?? this.badgeStyle,
      receiptStyle: receiptStyle ?? this.receiptStyle,
      typingIndicatorStyle: typingIndicatorStyle ?? this.typingIndicatorStyle,
    );
  }
}
