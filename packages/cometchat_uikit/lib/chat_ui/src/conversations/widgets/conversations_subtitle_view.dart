import 'package:flutter/material.dart';
import '../../../../cometchat_chat_uikit.dart';
import '../../../../cometchat_chat_uikit.dart' as cc;
import '../utils/conversation_subtitle_utils.dart';

/// A widget that displays the subtitle area for a conversation list item.
///
/// This widget renders the subtitle content which can include:
/// - Receipt icons (sent, delivered, read) for messages sent by the logged-in user
/// - Typing indicator when another user is typing
/// - Thread indicator (arrow icon) for messages with replies
/// - Last message text with proper formatting
///
/// The widget handles AI user hiding by returning an empty SizedBox when
/// the conversation is with an AI role user.
///
/// The subtitle rendering logic follows this priority:
/// 1. If the conversation is with an AI user, return empty SizedBox
/// 2. If typing indicator is active, show typing text
/// 3. Otherwise, show receipt icon (if applicable) and last message
///
/// Note: Typing indicators are now managed per-conversation via ValueNotifier
/// in the BLoC for optimized rebuilds. Pass the typing indicators list directly.
class ConversationsSubtitleView extends StatelessWidget {
  const ConversationsSubtitleView({
    super.key,
    required this.conversation,
    required this.style,
    required this.receiptStyle,
    required this.typingStyle,
    required this.colorPalette,
    required this.spacing,
    required this.typography,
    this.typingIndicators = const [],
    this.hideThreadIndicator = true,
    this.receiptsVisibility = true,
    this.typingIndicatorText,
    this.readIcon,
    this.deliveredIcon,
    this.sentIcon,
    this.textFormatters,
  });

  /// The conversation to display the subtitle for.
  final Conversation conversation;

  /// The list of typing indicators for this conversation (empty if no one is typing).
  final List<TypingIndicator> typingIndicators;

  /// The style configuration for the conversations widget.
  final CometChatConversationsStyle style;

  /// The style configuration for message receipts.
  final CometChatMessageReceiptStyle receiptStyle;

  /// The style configuration for typing indicator.
  final CometChatTypingIndicatorStyle typingStyle;

  /// The color palette used for styling.
  final CometChatColorPalette colorPalette;

  /// The spacing configuration for padding and margins.
  final CometChatSpacing spacing;

  /// The typography configuration for text styles.
  final CometChatTypography typography;

  /// Whether to hide the thread indicator arrow icon.
  /// Defaults to true (hidden).
  final bool? hideThreadIndicator;

  /// Whether to show receipt icons.
  /// Defaults to true (visible).
  final bool? receiptsVisibility;

  /// Custom text to display for typing indicator.
  /// If null, uses default "is typing" text.
  final String? typingIndicatorText;

  /// Custom icon for read receipt status.
  final Widget? readIcon;

  /// Custom icon for delivered receipt status.
  final Widget? deliveredIcon;

  /// Custom icon for sent receipt status.
  final Widget? sentIcon;

  /// List of text formatters for message formatting.
  final List<CometChatTextFormatter>? textFormatters;

  @override
  Widget build(BuildContext context) {
    // Hide subtitle for AI agent conversations
    if (conversation.conversationWith is User) {
      final user = conversation.conversationWith as User;
      if (user.role == AIConstants.aiRole || user.role == 'ai') {
        return const SizedBox();
      }
    }

    // Calculate prefix for thread indicator
    String prefix = "";
    if (hideThreadIndicator != null && hideThreadIndicator == false) {
      if (conversation.conversationWith is User) {
        if (conversation.lastMessage?.sender?.uid !=
            CometChatUIKit.loggedInUser?.uid) {
          prefix = "${conversation.lastMessage?.sender?.name}: ";
        } else {
          prefix = "";
        }
      }
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Show receipt icon and thread indicator when hideThreadIndicator is false
        // and the message was sent by the logged-in user
        if (hideThreadIndicator != null &&
            hideThreadIndicator == false &&
            conversation.lastMessage?.sender?.uid ==
                CometChatUIKit.loggedInUser?.uid)
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _getReceiptIcon(
                context,
                conversation: conversation,
                hideReceipt: !(receiptsVisibility ?? true),
              ),
              // Show thread indicator arrow if message has replies
              if ((conversation.lastMessage?.replyCount ?? 0) > 0) ...[
                Icon(
                  Icons.subdirectory_arrow_right,
                  color: colorPalette.iconSecondary,
                  size: 16,
                ),
                Padding(
                  padding: EdgeInsets.only(
                    left: spacing.padding ?? 0,
                    right: spacing.padding ?? 0,
                  ),
                  child: Text(
                    prefix,
                    style: TextStyle(
                      color: style.itemSubtitleTextColor ??
                          colorPalette.textSecondary,
                      fontWeight: typography.body?.regular?.fontWeight,
                      fontSize: typography.body?.regular?.fontSize,
                      fontFamily: typography.body?.regular?.fontFamily,
                      letterSpacing: 0,
                    )
                        .merge(style.itemSubtitleTextStyle)
                        .copyWith(color: style.itemSubtitleTextColor),
                  ),
                ),
              ],
            ],
          ),
        // Show receipt icon when not showing typing indicator and hideThreadIndicator is not false
        if (typingIndicators.isEmpty &&
            hideThreadIndicator != null &&
            hideThreadIndicator != false)
          _getReceiptIcon(
            context,
            conversation: conversation,
            hideReceipt: _getHideReceipt(conversation),
          ),
        // Show typing indicator text when someone is typing
        if (typingIndicators.isNotEmpty)
          Expanded(
            child: Text(
              typingIndicatorText ?? _getTypingText(context),
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: colorPalette.textHighlight,
                fontWeight: typography.body?.regular?.fontWeight,
                fontSize: typography.body?.regular?.fontSize,
                fontFamily: typography.body?.regular?.fontFamily,
              ).merge(typingStyle.textStyle),
            ),
          )
        // Show last message subtitle when not typing
        else
          Expanded(
            child: _getSubtitle(context, conversation),
          ),
      ],
    );
  }

  /// Determines whether to hide the receipt icon based on conversation state.
  bool _getHideReceipt(Conversation conversation) {
    if (receiptsVisibility == false || conversation.lastMessage == null) {
      return true;
    } else if (conversation.lastMessage!.category ==
        MessageCategoryConstants.call) {
      return true;
    } else if (conversation.lastMessage!.sender != null) {
      // Show receipt only for messages sent by logged in user
      return false;
    } else {
      return true;
    }
  }

  /// Returns the receipt icon widget based on message status.
  Widget _getReceiptIcon(
    BuildContext context, {
    required Conversation conversation,
    bool? hideReceipt,
  }) {
    if (hideReceipt != null && hideReceipt) {
      return const SizedBox();
    } else if (conversation.lastMessage != null &&
        conversation.lastMessage?.sender != null &&
        conversation.lastMessage!.deletedAt == null &&
        conversation.lastMessage!.type != "groupMember" &&
        conversation.lastMessage!.sender?.uid ==
            CometChatUIKit.loggedInUser?.uid) {
      ReceiptStatus status =
          MessageReceiptUtils.getReceiptStatus(conversation.lastMessage!);

      return Padding(
        padding: EdgeInsets.only(
          right: spacing.padding1 ?? 0,
        ),
        child: CometChatReceipt(
          status: status,
          style: receiptStyle,
          deliveredIcon: deliveredIcon ??
              Icon(
                Icons.done_all,
                color:
                    receiptStyle.deliveredIconColor ?? colorPalette.iconSecondary,
                size: 16,
              ),
          readIcon: readIcon ??
              Icon(
                Icons.done_all,
                color: receiptStyle.readIconColor ?? colorPalette.iconHighlight,
                size: 16,
              ),
          sentIcon: sentIcon ??
              Icon(
                Icons.check,
                color: receiptStyle.sentIconColor ?? colorPalette.iconSecondary,
                size: 16,
              ),
          errorIcon: Icon(
            Icons.error_outlined,
            color: receiptStyle.errorIconColor ?? colorPalette.error,
            size: 16,
          ),
        ),
      );
    } else {
      return const SizedBox();
    }
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
        return cc.Translations.of(context).isTyping;
      } else {
        return '${typingIndicators.first.sender.name} ${cc.Translations.of(context).isTyping}';
      }
    }
    
    // Multiple people typing
    return '$count people are typing...';
  }

  /// Returns the subtitle widget with the last message text.
  Widget _getSubtitle(BuildContext context, Conversation conversation) {
    TextStyle subtitleStyle = TextStyle(
      overflow: TextOverflow.ellipsis,
      color: style.itemSubtitleTextColor ?? colorPalette.textSecondary,
      fontSize: typography.body?.regular?.fontSize,
      fontWeight: typography.body?.regular?.fontWeight,
      fontFamily: typography.body?.regular?.fontFamily,
      letterSpacing: 0,
    )
        .merge(style.itemSubtitleTextStyle)
        .copyWith(color: style.itemSubtitleTextColor);

    AdditionalConfigurations? configurations;

    if (conversation.lastMessage != null &&
        conversation.lastMessage is TextMessage) {
      // Pass all formatters including MarkdownTextFormatter so the conversation
      // subtitle renders with the same rich formatting as message bubbles
      // (bold, italic, code, etc.) but truncated to a single line.
      List<CometChatTextFormatter> allFormatters = textFormatters ??
          MessageTemplateUtils.getDefaultTextFormatters();
      // Ensure MarkdownTextFormatter is present for rich text rendering
      if (!allFormatters.any((f) => f is MarkdownTextFormatter)) {
        allFormatters = [MarkdownTextFormatter(), ...allFormatters];
      }
      for (CometChatTextFormatter formatter in allFormatters) {
        if (formatter is CometChatMentionsFormatter) {
          formatter.message = conversation.lastMessage as TextMessage;
        }
      }
      configurations = AdditionalConfigurations(
        textFormatters: allFormatters,
      );
    }

    Widget subtitle = ConversationSubtitleUtils.getConversationSubtitle(
      conversation,
      context,
      subtitleStyle,
      style.messageTypeIconColor ?? colorPalette.iconSecondary,
      additionalConfigurations: configurations,
    );

    return subtitle;
  }
}
