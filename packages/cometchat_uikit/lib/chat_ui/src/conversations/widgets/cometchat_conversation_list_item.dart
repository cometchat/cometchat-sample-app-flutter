import 'package:flutter/material.dart';
import '../../../../cometchat_chat_uikit.dart';
import '../utils/status_indicator_helper.dart';
import '../utils/conversation_utils.dart' as conv_utils;
import '../utils/conversation_subtitle_utils.dart';

/// [CometChatConversationListItem] is a dedicated widget for displaying a single conversation list item.
///
/// This widget is purpose-built for conversations and provides conversation-specific features including:
/// - Avatar with status indicator (online status for users, group type icons for groups)
/// - Title (user name or group name)
/// - Subtitle (last message preview, typing indicator, thread indicator, message receipts)
/// - Trailing view (timestamp and unread count badge)
/// - Selection mode support with checkbox
/// - Tap and long-press gesture handling
/// - Full theme integration with CometChatTheme
/// - Extensive customization through style objects and individual parameters
///
/// Unlike the generic [CometChatListItem], this widget is specifically designed for conversation
/// display with conversation-specific features like typing indicators, message receipts, and
/// thread indicators.
///
/// ## Basic Usage
///
/// ```dart
/// CometChatConversationListItem(
///   conversation: conversation,
///   onItemClick: (conv) => navigateToChat(conv),
/// )
/// ```
///
/// ## With Styling
///
/// ```dart
/// CometChatConversationListItem(
///   conversation: conversation,
///   onItemClick: (conv) => navigateToChat(conv),
///   style: CometChatConversationListItemStyle(
///     backgroundColor: Colors.white,
///     titleTextColor: Colors.black,
///     avatarStyle: CometChatAvatarStyle(
///       borderRadius: BorderRadius.circular(8),
///     ),
///   ),
///   avatarHeight: 56,
///   avatarWidth: 56,
/// )
/// ```
///
/// ## With Selection Mode
///
/// ```dart
/// CometChatConversationListItem(
///   conversation: conversation,
///   onItemClick: (conv) => handleClick(conv),
///   selectionMode: SelectionMode.multiple,
///   isSelected: isSelected,
///   onSelectionToggle: () => toggleSelection(),
/// )
/// ```
///
/// ## With Custom Views
///
/// ```dart
/// CometChatConversationListItem(
///   conversation: conversation,
///   onItemClick: (conv) => handleClick(conv),
///   leadingView: (conv, typing) => CustomAvatar(conversation: conv),
///   subtitleView: (conv, typing) => CustomSubtitle(conversation: conv),
/// )
/// ```
///
/// ## Styling Priority
///
/// The widget follows a three-level styling priority:
/// 1. Individual style parameters (highest priority)
/// 2. Style object properties
/// 3. Theme defaults (lowest priority)
///
/// This allows for flexible customization at different levels of granularity.
///
/// See also:
/// - [CometChatConversationListItemStyle] for comprehensive styling options
/// - [ConversationsList] for displaying a list of conversations
/// - [CometChatListItem] for the generic list item widget
class CometChatConversationListItem extends StatelessWidget {
  const CometChatConversationListItem({
    super.key,
    required this.conversation,
    required this.onItemClick,
    this.onItemLongClick,
    this.onSelectionToggle,
    this.isSelected = false,
    this.selectionMode = SelectionMode.none,
    this.hideUserStatus = false,
    this.hideGroupType = false,
    this.hideReceipts = false,
    this.hideThreadIndicator = true,
    this.typingIndicators = const [],
    this.textFormatters,
    this.dateTimeFormatterCallback,
    this.style,
    this.avatarStyle,
    this.statusIndicatorStyle,
    this.receiptStyle,
    this.dateStyle,
    this.badgeStyle,
    this.typingIndicatorStyle,
    this.avatarHeight,
    this.avatarWidth,
    this.avatarPadding,
    this.avatarMargin,
    this.statusIndicatorHeight,
    this.statusIndicatorWidth,
    this.statusIndicatorBorderRadius,
    this.leadingView,
    this.titleView,
    this.subtitleView,
    this.trailingView,
    this.colorPalette,
    this.spacing,
    this.typography,
    this.privateGroupIcon,
    this.protectedGroupIcon,
    this.readIcon,
    this.deliveredIcon,
    this.sentIcon,
  });

  /// [conversation] is the conversation object to display
  final Conversation conversation;

  /// [onItemClick] callback triggered when the item is tapped
  final Function(Conversation) onItemClick;

  /// [onItemLongClick] callback triggered when the item is long-pressed
  final Function(Conversation)? onItemLongClick;

  /// [onSelectionToggle] callback triggered when the selection checkbox is toggled
  final VoidCallback? onSelectionToggle;

  /// [isSelected] whether this conversation is currently selected
  final bool isSelected;

  /// [selectionMode] determines the selection behavior (none, single, multiple)
  final SelectionMode selectionMode;

  /// [hideUserStatus] hides the online status indicator for user conversations
  final bool hideUserStatus;

  /// [hideGroupType] hides the group type indicator for group conversations
  final bool hideGroupType;

  /// [hideReceipts] hides message receipt indicators (sent, delivered, read)
  final bool hideReceipts;

  /// [hideThreadIndicator] hides the thread reply indicator
  final bool hideThreadIndicator;

  /// [typingIndicators] list of typing indicators for users currently typing
  /// Shows "Name is typing" for 1 user, "N people are typing" for multiple
  final List<TypingIndicator> typingIndicators;

  /// [textFormatters] list of formatters to apply to message text
  final List<CometChatTextFormatter>? textFormatters;

  /// [dateTimeFormatterCallback] custom callback for formatting date/time
  final DateTimeFormatterCallback? dateTimeFormatterCallback;

  /// [style] comprehensive style configuration for the list item
  final CometChatConversationListItemStyle? style;

  /// [avatarStyle] style configuration for the avatar (overrides style.avatarStyle)
  final CometChatAvatarStyle? avatarStyle;

  /// [statusIndicatorStyle] style configuration for the status indicator (overrides style.statusIndicatorStyle)
  final CometChatStatusIndicatorStyle? statusIndicatorStyle;

  /// [receiptStyle] style configuration for message receipts (overrides style.receiptStyle)
  final CometChatMessageReceiptStyle? receiptStyle;

  /// [dateStyle] style configuration for the date/time (overrides style.dateStyle)
  final CometChatDateStyle? dateStyle;

  /// [badgeStyle] style configuration for the unread badge (overrides style.badgeStyle)
  final CometChatBadgeStyle? badgeStyle;

  /// [typingIndicatorStyle] style configuration for typing indicator (overrides style.typingIndicatorStyle)
  final CometChatTypingIndicatorStyle? typingIndicatorStyle;

  /// [avatarHeight] provides height to the avatar widget
  final double? avatarHeight;

  /// [avatarWidth] provides width to the avatar widget
  final double? avatarWidth;

  /// [avatarPadding] provides padding to the avatar widget
  final EdgeInsetsGeometry? avatarPadding;

  /// [avatarMargin] provides margin to the avatar widget
  final EdgeInsetsGeometry? avatarMargin;

  /// [statusIndicatorHeight] provides height to the status indicator
  final double? statusIndicatorHeight;

  /// [statusIndicatorWidth] provides width to the status indicator
  final double? statusIndicatorWidth;

  /// [statusIndicatorBorderRadius] provides border radius to the status indicator
  final BorderRadiusGeometry? statusIndicatorBorderRadius;

  /// [leadingView] custom widget builder for the leading section (avatar area)
  final Widget? Function(Conversation, TypingIndicator?)? leadingView;

  /// [titleView] custom widget builder for the title section
  final Widget? Function(Conversation, TypingIndicator?)? titleView;

  /// [subtitleView] custom widget builder for the subtitle section
  final Widget? Function(Conversation, TypingIndicator?)? subtitleView;

  /// [trailingView] custom widget builder for the trailing section (timestamp and badge area)
  final Widget? Function(Conversation, TypingIndicator?)? trailingView;

  /// [colorPalette] custom color palette (overrides theme colors)
  final CometChatColorPalette? colorPalette;

  /// [spacing] custom spacing configuration (overrides theme spacing)
  final CometChatSpacing? spacing;

  /// [typography] custom typography configuration (overrides theme typography)
  final CometChatTypography? typography;

  /// [privateGroupIcon] custom icon for private group indicator
  final Widget? privateGroupIcon;

  /// [protectedGroupIcon] custom icon for protected (password) group indicator
  final Widget? protectedGroupIcon;

  /// [readIcon] custom icon for read receipt status
  final Widget? readIcon;

  /// [deliveredIcon] custom icon for delivered receipt status
  final Widget? deliveredIcon;

  /// [sentIcon] custom icon for sent receipt status
  final Widget? sentIcon;

  @override
  Widget build(BuildContext context) {
    final effectiveColorPalette =
        colorPalette ?? CometChatThemeHelper.getColorPalette(context);
    final effectiveSpacing =
        spacing ?? CometChatThemeHelper.getSpacing(context);
    final effectiveTypography =
        typography ?? CometChatThemeHelper.getTypography(context);
    final effectiveStyle =
        style ?? CometChatConversationListItemStyle.fromTheme(context);

    final backgroundColor = isSelected
        ? (effectiveStyle.selectedBackgroundColor ??
              effectiveColorPalette.background4)
        : (effectiveStyle.backgroundColor ?? effectiveColorPalette.background1);

    return Semantics(
      label: _buildAccessibilityLabel(context),
      button: true,
      selected: isSelected,
      child: InkWell(
        onTap: () => onItemClick(conversation),
        onLongPress: onItemLongClick != null
            ? () => onItemLongClick!(conversation)
            : null,
        child: Container(
          color: backgroundColor,
          padding: EdgeInsets.symmetric(
            horizontal: effectiveSpacing.padding4 ?? 16,
            vertical: effectiveSpacing.padding3 ?? 12,
          ),
          child: Row(
            children: [
              if (selectionMode != SelectionMode.none)
                _buildSelectionCheckbox(
                  effectiveStyle,
                  effectiveColorPalette,
                  effectiveSpacing,
                ),
              _buildLeadingView(
                context,
                effectiveStyle,
                effectiveColorPalette,
                effectiveSpacing,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildTitleView(
                      context,
                      effectiveStyle,
                      effectiveColorPalette,
                      effectiveTypography,
                    ),
                    const SizedBox(height: 2),
                    _buildSubtitleView(
                      context,
                      effectiveStyle,
                      effectiveColorPalette,
                      effectiveTypography,
                      effectiveSpacing,
                    ),
                  ],
                ),
              ),
              _buildTrailingView(
                context,
                effectiveStyle,
                effectiveColorPalette,
                effectiveTypography,
                effectiveSpacing,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _buildAccessibilityLabel(BuildContext context) {
    final conversationName = _getConversationTitle();
    final lastMessageText = conv_utils.ConversationUtils.getLastMessageText(
      context,
      conversation.lastMessage,
    );
    final parts = <String>[conversationName];
    if (lastMessageText.isNotEmpty) parts.add(lastMessageText);
    if (conversation.unreadMessageCount > 0) {
      parts.add('${conversation.unreadMessageCount} unread messages');
    }
    if (isSelected) parts.add('selected');
    return parts.join(', ');
  }

  Widget _buildSelectionCheckbox(
    CometChatConversationListItemStyle effectiveStyle,
    CometChatColorPalette effectiveColorPalette,
    CometChatSpacing effectiveSpacing,
  ) {
    return Padding(
      padding: EdgeInsets.only(
        left: effectiveSpacing.padding3 ?? 12,
        right: effectiveSpacing.padding2 ?? 8,
      ),
      child: SizedBox(
        width: 20,
        height: 20,
        child: Checkbox(
          value: isSelected,
          onChanged: (value) => onSelectionToggle?.call(),
          fillColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return effectiveStyle.checkBoxCheckedBackgroundColor ??
                  effectiveColorPalette.primary;
            }
            return effectiveStyle.checkBoxBackgroundColor ?? Colors.transparent;
          }),
          shape: RoundedRectangleBorder(
            borderRadius:
                effectiveStyle.checkBoxBorderRadius ??
                BorderRadius.circular(effectiveSpacing.radius1 ?? 4),
          ),
          side: BorderSide(
            color:
                effectiveStyle.checkBoxStrokeColor ??
                effectiveColorPalette.borderDefault ??
                Colors.grey,
            width: effectiveStyle.checkBoxStrokeWidth ?? 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildLeadingView(
    BuildContext context,
    CometChatConversationListItemStyle effectiveStyle,
    CometChatColorPalette effectiveColorPalette,
    CometChatSpacing effectiveSpacing,
  ) {
    if (leadingView != null) {
      final customView = leadingView!(
        conversation,
        typingIndicators.isNotEmpty ? typingIndicators.first : null,
      );
      return customView ?? const SizedBox.shrink();
    }

    final effectiveTypography =
        typography ?? CometChatThemeHelper.getTypography(context);

    // Create avatar style with explicit text size to match old behavior
    final effectiveAvatarStyle =
        (avatarStyle ??
                effectiveStyle.avatarStyle ??
                const CometChatAvatarStyle())
            .copyWith(
              placeHolderTextStyle: TextStyle(
                fontSize: effectiveTypography.heading2?.bold?.fontSize,
                fontWeight: effectiveTypography.heading2?.bold?.fontWeight,
                fontFamily: effectiveTypography.heading2?.bold?.fontFamily,
              ),
            );

    return Padding(
      padding: EdgeInsets.only(right: effectiveSpacing.padding3 ?? 12),
      child: Stack(
        children: [
          CometChatAvatar(
            image: _getConversationAvatar(),
            name: _getConversationTitle(),
            height: avatarHeight ?? 48,
            width: avatarWidth ?? 48,
            padding: avatarPadding,
            margin: avatarMargin,
            style: effectiveAvatarStyle,
          ),
          if (_shouldShowStatusIndicator())
            Positioned(
              right: 0,
              bottom: 0,
              child: CometChatStatusIndicator(
                height: statusIndicatorHeight ?? 14,
                width: statusIndicatorWidth ?? 14,
                backgroundImage: _getStatusIndicatorIcon(effectiveColorPalette),
                style: CometChatStatusIndicatorStyle(
                  border:
                      statusIndicatorStyle?.border ??
                      effectiveStyle.statusIndicatorStyle?.border ??
                      Border.all(
                        width: effectiveSpacing.spacing ?? 0,
                        color:
                            effectiveColorPalette.background1 ??
                            Colors.transparent,
                      ),
                  backgroundColor: _getStatusIndicatorBackgroundColor(
                    effectiveColorPalette,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTitleView(
    BuildContext context,
    CometChatConversationListItemStyle effectiveStyle,
    CometChatColorPalette effectiveColorPalette,
    CometChatTypography effectiveTypography,
  ) {
    if (titleView != null) {
      final customView = titleView!(
        conversation,
        typingIndicators.isNotEmpty ? typingIndicators.first : null,
      );
      return customView ?? const SizedBox.shrink();
    }

    return Text(
      _getConversationTitle(),
      style:
          (effectiveStyle.titleTextStyle ??
                  effectiveTypography.heading4?.medium)
              ?.copyWith(
                color:
                    effectiveStyle.titleTextColor ??
                    effectiveColorPalette.textPrimary,
              ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildSubtitleView(
    BuildContext context,
    CometChatConversationListItemStyle effectiveStyle,
    CometChatColorPalette effectiveColorPalette,
    CometChatTypography effectiveTypography,
    CometChatSpacing effectiveSpacing,
  ) {
    if (subtitleView != null) {
      final customView = subtitleView!(
        conversation,
        typingIndicators.isNotEmpty ? typingIndicators.first : null,
      );
      return customView ?? const SizedBox.shrink();
    }

    // Hide subtitle for AI agent conversations
    if (conversation.conversationWith is User) {
      final user = conversation.conversationWith as User;
      if (user.role == AIConstants.aiRole || user.role == 'ai') {
        return const SizedBox.shrink();
      }
    }

    if (typingIndicators.isNotEmpty) {
      final typingText = _getTypingText(context);

      return Text(
        typingText,
        style:
            (typingIndicatorStyle?.textStyle ??
                    effectiveStyle.typingIndicatorStyle?.textStyle ??
                    effectiveTypography.body?.regular)
                ?.copyWith(color: effectiveColorPalette.textHighlight),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    return Row(
      children: [
        // When hideThreadIndicator is false, show receipt + arrow (matching old GetX code behavior)
        if (!hideThreadIndicator) ...[
          if (_shouldShowReceipt()) ...[
            _buildReceiptIndicator(effectiveColorPalette),
            SizedBox(width: effectiveSpacing.padding1 ?? 4),
          ],
          Icon(
            Icons.subdirectory_arrow_right,
            color: effectiveColorPalette.iconSecondary,
            size: 16,
          ),
          SizedBox(width: effectiveSpacing.padding ?? 4),
        ]
        // When hideThreadIndicator is true, just show receipt
        else if (_shouldShowReceipt()) ...[
          _buildReceiptIndicator(effectiveColorPalette),
          SizedBox(width: effectiveSpacing.padding1 ?? 4),
        ],
        Expanded(
          child: _buildLastMessageText(
            context,
            effectiveStyle,
            effectiveColorPalette,
            effectiveTypography,
          ),
        ),
      ],
    );
  }

  /// Returns the appropriate typing indicator text based on number of typers
  /// - 1 user typing in user conversation: "is typing..."
  /// - 1 user typing in group: "Name is typing..."
  /// - 2+ users typing: "N people are typing..."
  String _getTypingText(BuildContext context) {
    final count = typingIndicators.length;

    if (count == 0) return '';

    if (count == 1) {
      // For user conversations, show just "is typing..."
      // For group conversations, show "Name is typing..."
      if (conversation.conversationWith is User) {
        return Translations.of(context).isTyping;
      } else {
        return '${typingIndicators.first.sender.name} ${Translations.of(context).isTyping}';
      }
    }
    // Multiple people typing - use simple format "N people are typing..."
    return '$count people are typing...';
  }

  Widget _buildLastMessageText(
    BuildContext context,
    CometChatConversationListItemStyle effectiveStyle,
    CometChatColorPalette effectiveColorPalette,
    CometChatTypography effectiveTypography,
  ) {
    TextStyle subtitleStyle =
        TextStyle(
              overflow: TextOverflow.ellipsis,
              color:
                  effectiveStyle.subtitleTextColor ??
                  effectiveColorPalette.textSecondary,
              fontSize: effectiveTypography.body?.regular?.fontSize,
              fontWeight: effectiveTypography.body?.regular?.fontWeight,
              fontFamily: effectiveTypography.body?.regular?.fontFamily,
              letterSpacing: 0,
            )
            .merge(effectiveStyle.subtitleTextStyle)
            .copyWith(color: effectiveStyle.subtitleTextColor);

    AdditionalConfigurations? configurations;

    if (conversation.lastMessage != null &&
        conversation.lastMessage is TextMessage) {
      // Pass all formatters including MarkdownTextFormatter so the conversation
      // subtitle renders with the same rich formatting as message bubbles
      // (bold, italic, code, etc.) but truncated to a single line.
      List<CometChatTextFormatter> allFormatters =
          textFormatters ?? MessageTemplateUtils.getDefaultTextFormatters();
      // Ensure MarkdownTextFormatter is present for rich text rendering
      if (!allFormatters.any((f) => f is MarkdownTextFormatter)) {
        allFormatters = [MarkdownTextFormatter(), ...allFormatters];
      }
      for (CometChatTextFormatter formatter in allFormatters) {
        if (formatter is CometChatMentionsFormatter) {
          formatter.message = conversation.lastMessage as TextMessage;
        }
      }
      configurations = AdditionalConfigurations(textFormatters: allFormatters);
    }

    return ConversationSubtitleUtils.getConversationSubtitle(
      conversation,
      context,
      subtitleStyle,
      effectiveStyle.messageTypeIconTint ?? effectiveColorPalette.iconSecondary,
      additionalConfigurations: configurations,
    );
  }

  Widget _buildReceiptIndicator(CometChatColorPalette effectiveColorPalette) {
    // If the last message was disapproved by moderation, show the error
    // receipt icon (matches message-bubble behavior).
    final lastMessage = conversation.lastMessage;
    if (lastMessage != null &&
        ModerationCheckUtil.instance.isMessageDisapprovedFromModeration(
          lastMessage,
        )) {
      return Icon(
        Icons.error_outline,
        size: 16,
        color: effectiveColorPalette.error,
      );
    }

    final receiptStatus = _getReceiptStatus();
    IconData? receiptIcon;
    Color? receiptColor;

    switch (receiptStatus) {
      case 'read':
        if (readIcon != null) return readIcon!;
        receiptIcon = Icons.done_all;
        receiptColor = effectiveColorPalette.primary;
        break;
      case 'delivered':
        if (deliveredIcon != null) return deliveredIcon!;
        receiptIcon = Icons.done_all;
        receiptColor = effectiveColorPalette.iconSecondary;
        break;
      case 'sent':
        if (sentIcon != null) return sentIcon!;
        receiptIcon = Icons.done;
        receiptColor = effectiveColorPalette.iconSecondary;
        break;
      default:
        receiptIcon = Icons.schedule;
        receiptColor = effectiveColorPalette.iconSecondary;
    }

    return Icon(receiptIcon, size: 16, color: receiptColor);
  }

  Widget _buildTrailingView(
    BuildContext context,
    CometChatConversationListItemStyle effectiveStyle,
    CometChatColorPalette effectiveColorPalette,
    CometChatTypography effectiveTypography,
    CometChatSpacing effectiveSpacing,
  ) {
    if (trailingView != null) {
      final customView = trailingView!(
        conversation,
        typingIndicators.isNotEmpty ? typingIndicators.first : null,
      );
      return customView ?? const SizedBox.shrink();
    }

    // Hide trailing view (timestamp + unread) for AI agent conversations
    if (conversation.conversationWith is User) {
      final user = conversation.conversationWith as User;
      if (user.role == AIConstants.aiRole || user.role == 'ai') {
        return const SizedBox.shrink();
      }
    }

    return Padding(
      padding: EdgeInsets.only(left: effectiveSpacing.padding2 ?? 0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: _buildTimestamp(
              context,
              effectiveStyle,
              effectiveColorPalette,
              effectiveTypography,
              effectiveSpacing,
            ),
          ),
          const SizedBox(height: 6.5),
          Flexible(child: _buildUnreadBadge(effectiveStyle)),
        ],
      ),
    );
  }

  Widget _buildTimestamp(
    BuildContext context,
    CometChatConversationListItemStyle effectiveStyle,
    CometChatColorPalette effectiveColorPalette,
    CometChatTypography effectiveTypography,
    CometChatSpacing effectiveSpacing,
  ) {
    DateTime? lastMessageTime =
        conversation.lastMessage?.updatedAt ?? conversation.lastMessage?.sentAt;
    if (lastMessageTime == null) return const SizedBox();

    return CometChatDate(
      date: lastMessageTime,
      padding: const EdgeInsets.all(0),
      isTransparentBackground: true,
      style: CometChatDateStyle(
        backgroundColor: effectiveColorPalette.transparent,
        textStyle:
            TextStyle(
                  color: effectiveColorPalette.textSecondary,
                  fontSize: effectiveTypography.caption1?.regular?.fontSize,
                  fontWeight: effectiveTypography.caption1?.regular?.fontWeight,
                  fontFamily: effectiveTypography.caption1?.regular?.fontFamily,
                )
                .merge(
                  dateStyle?.textStyle ?? effectiveStyle.dateStyle?.textStyle,
                )
                .copyWith(
                  color:
                      dateStyle?.textColor ??
                      effectiveStyle.dateStyle?.textColor,
                ),
        border: Border.all(width: 0, color: Colors.transparent),
        borderRadius:
            dateStyle?.borderRadius ?? effectiveStyle.dateStyle?.borderRadius,
        textColor: dateStyle?.textColor ?? effectiveStyle.dateStyle?.textColor,
      ),
      pattern: DateTimePattern.dayDateTimeFormat,
      dateTimeFormatterCallback: dateTimeFormatterCallback,
    );
  }

  Widget _buildUnreadBadge(CometChatConversationListItemStyle effectiveStyle) {
    final count = conversation.unreadMessageCount;
    return CometChatBadge(
      count: count,
      width: (count < 10)
          ? 20
          : null, // Fixed 20x20 circle for single digit, auto-width for multi-digit
      height: 20,
      style:
          badgeStyle ??
          effectiveStyle.badgeStyle ??
          const CometChatBadgeStyle(),
    );
  }

  String _getConversationTitle() {
    if (conversation.conversationWith is User) {
      return (conversation.conversationWith as User).name;
    } else if (conversation.conversationWith is Group) {
      return (conversation.conversationWith as Group).name;
    }
    return '';
  }

  String? _getConversationAvatar() {
    if (conversation.conversationWith is User) {
      return (conversation.conversationWith as User).avatar;
    } else if (conversation.conversationWith is Group) {
      return (conversation.conversationWith as Group).icon;
    }
    return null;
  }

  bool _shouldShowStatusIndicator() {
    final config = StatusIndicatorHelper.getStatusIndicator(
      conversation: conversation,
      hideUserStatus: hideUserStatus,
      hideGroupType: hideGroupType,
    );
    return config.show;
  }

  Color? _getStatusIndicatorBackgroundColor(
    CometChatColorPalette effectiveColorPalette,
  ) {
    final config = StatusIndicatorHelper.getStatusIndicator(
      conversation: conversation,
      hideUserStatus: hideUserStatus,
      hideGroupType: hideGroupType,
    );

    // If there's a color (for online users), use it
    if (config.color != null) {
      return config.color;
    }

    // If there's an icon (for group types), use specific colors based on group type
    if (config.icon != null && conversation.conversationWith is Group) {
      final group = conversation.conversationWith as Group;
      if (group.type == CometChatGroupType.password) {
        // Protected groups use success color (green)
        return effectiveColorPalette.success ?? Colors.green;
      } else if (group.type == CometChatGroupType.private) {
        // Private groups use warning color (yellow)
        return effectiveColorPalette.warning ?? Colors.yellow;
      }
    }

    return null;
  }

  Widget? _getStatusIndicatorIcon(CometChatColorPalette effectiveColorPalette) {
    final config = StatusIndicatorHelper.getStatusIndicator(
      conversation: conversation,
      hideUserStatus: hideUserStatus,
      hideGroupType: hideGroupType,
    );

    if (config.icon != null && conversation.conversationWith is Group) {
      final group = conversation.conversationWith as Group;

      // Use custom icons if provided, otherwise use default icons with proper color
      if (group.type == CometChatGroupType.private &&
          privateGroupIcon != null) {
        return privateGroupIcon;
      } else if (group.type == CometChatGroupType.password &&
          protectedGroupIcon != null) {
        return protectedGroupIcon;
      } else {
        // Return default icon with white color (background1)
        if (group.type == CometChatGroupType.private) {
          return Icon(
            Icons.shield,
            color: effectiveColorPalette.background1 ?? Colors.white,
            size: 7,
          );
        } else if (group.type == CometChatGroupType.password) {
          return Icon(
            Icons.lock,
            color: effectiveColorPalette.background1 ?? Colors.white,
            size: 7,
          );
        }
      }
    }

    return config.icon;
  }

  bool _shouldShowReceipt() {
    if (hideReceipts) return false;
    final lastMessage = conversation.lastMessage;
    if (lastMessage == null) return false;

    final loggedInUser = CometChatUIKit.loggedInUser;
    return lastMessage.sender?.uid == loggedInUser?.uid;
  }

  String _getReceiptStatus() {
    final lastMessage = conversation.lastMessage;
    if (lastMessage == null) return 'in_progress';

    if (lastMessage.readAt != null &&
        lastMessage.readAt!.millisecondsSinceEpoch > 0) {
      return 'read';
    }
    if (lastMessage.deliveredAt != null &&
        lastMessage.deliveredAt!.millisecondsSinceEpoch > 0) {
      return 'delivered';
    }
    if (lastMessage.sentAt != null &&
        lastMessage.sentAt!.millisecondsSinceEpoch > 0) {
      return 'sent';
    }
    return 'in_progress';
  }
}
