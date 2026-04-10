import 'package:flutter/material.dart';
import '../../../../cometchat_chat_uikit.dart';

/// A widget that displays the trailing area for a conversation list item.
///
/// This widget renders the trailing content which includes:
/// - Timestamp showing when the last message was sent/updated
/// - Unread message count badge
///
/// The widget handles AI user hiding by returning an empty SizedBox when
/// the conversation is with an AI role user.
///
/// The trailing view uses:
/// - [CometChatDate] for displaying the timestamp
/// - [CometChatBadge] for displaying the unread count
class ConversationsTrailingView extends StatelessWidget {
  const ConversationsTrailingView({
    super.key,
    required this.conversation,
    required this.style,
    required this.datesStyle,
    required this.colorPalette,
    required this.spacing,
    required this.typography,
    this.datePattern,
    this.datePadding,
    this.dateHeight,
    this.dateWidth,
    this.dateBackgroundIsTransparent,
    this.badgeWidth,
    this.badgeHeight,
    this.badgePadding,
    this.dateTimeFormatterCallback,
  });

  /// The conversation to display the trailing view for.
  final Conversation conversation;

  /// The style configuration for the conversations widget.
  final CometChatConversationsStyle style;

  /// The style configuration for the date widget.
  final CometChatDateStyle datesStyle;

  /// The color palette used for styling.
  final CometChatColorPalette colorPalette;

  /// The spacing configuration for padding and margins.
  final CometChatSpacing spacing;

  /// The typography configuration for text styles.
  final CometChatTypography typography;

  /// Custom date pattern callback for formatting the date.
  /// If provided, the returned string will be used as the custom date string.
  final String Function(Conversation)? datePattern;

  /// Padding for the date widget.
  final EdgeInsets? datePadding;

  /// Height for the date widget.
  final double? dateHeight;

  /// Width for the date widget.
  final double? dateWidth;

  /// Whether the date background should be transparent.
  final bool? dateBackgroundIsTransparent;

  /// Width for the badge widget.
  final double? badgeWidth;

  /// Height for the badge widget.
  final double? badgeHeight;

  /// Padding for the badge widget.
  final EdgeInsetsGeometry? badgePadding;

  /// Callback for custom date/time formatting.
  final DateTimeFormatterCallback? dateTimeFormatterCallback;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: spacing.padding2 ?? 0,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: _getTime(context),
          ),
          const SizedBox(
            height: 6.5,
          ),
          Flexible(
            child: _getUnreadCount(context),
          ),
        ],
      ),
    );
  }

  /// Returns the timestamp widget for the last message.
  Widget _getTime(BuildContext context) {
    DateTime? lastMessageTime =
        conversation.lastMessage?.updatedAt ?? conversation.lastMessage?.sentAt;

    String? customDateString;

    if (datePattern != null) {
      customDateString = datePattern!(conversation);
    }

    return CometChatDate(
      date: lastMessageTime,
      padding: datePadding ?? const EdgeInsets.all(0),
      height: dateHeight,
      isTransparentBackground: dateBackgroundIsTransparent,
      width: dateWidth,
      style: CometChatDateStyle(
        backgroundColor: datesStyle.backgroundColor ?? colorPalette.transparent,
        textStyle: TextStyle(
          color: datesStyle.textColor ?? colorPalette.textSecondary,
          fontSize: typography.caption1?.regular?.fontSize,
          fontWeight: typography.caption1?.regular?.fontWeight,
          fontFamily: typography.caption1?.regular?.fontFamily,
        ).merge(datesStyle.textStyle).copyWith(
              color: datesStyle.textColor,
            ),
        border: datesStyle.border ??
            Border.all(
              width: 0,
              color: Colors.transparent,
            ),
        borderRadius: datesStyle.borderRadius,
        textColor: datesStyle.textColor,
      ),
      customDateString: customDateString,
      pattern: DateTimePattern.dayDateTimeFormat,
      dateTimeFormatterCallback: dateTimeFormatterCallback,
    );
  }

  /// Returns the unread message count badge widget.
  Widget _getUnreadCount(BuildContext context) {
    return CometChatBadge(
      count: conversation.unreadMessageCount ?? 0,
      width: badgeWidth,
      height: badgeHeight ?? 20,
      style: style.badgeStyle ?? const CometChatBadgeStyle(),
      padding: badgePadding,
    );
  }
}
