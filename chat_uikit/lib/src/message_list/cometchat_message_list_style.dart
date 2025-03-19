import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';

///[CometChatMessageListStyle] is a data class that has styling-related properties
///to customize the appearance of [CometChatMessageList]
///
/// ```dart
/// CometChatMessageListStyle(
/// border: Border.all(color: Colors.red, width: 2),
/// borderRadius: BorderRadius.circular(10),
/// backgroundColor: Colors.green,
/// errorStateSubtitleColor: Colors.blue,
/// errorStateSubtitleStyle: TextStyle(
/// color: Colors.red,
/// fontSize: 16,
/// fontWeight: FontWeight.bold,
/// ),
/// errorStateTextColor: Colors.yellow,
/// errorStateTextStyle: TextStyle(
/// color: Colors.green,
/// fontSize: 16,
/// fontWeight: FontWeight.bold,
/// ),
///
/// outgoingMessageBubbleStyle: CometChatOutgoingMessageBubbleStyle(
/// backgroundColor: Colors.blue,
/// border: Border.all(color: Colors.red, width: 2),
/// ),
/// emptyStateSubtitleColor: Colors.purple,
/// emptyStateSubtitleStyle: TextStyle(
/// color: Colors.yellow,
/// fontSize: 16,
/// fontWeight: FontWeight.bold,
/// ),
/// emptyStateTextColor: Colors.red,
/// emptyStateTextStyle: TextStyle(
/// color: Colors.green,
/// fontSize: 16,
/// fontWeight: FontWeight.bold,
/// ),
/// incomingMessageBubbleStyle: CometChatIncomingMessageBubbleStyle(
/// backgroundColor: Colors.green,
/// border: Border.all(color: Colors.red, width: 2),
/// ),
/// messageInformationStyle: CometChatMessageInformationStyle(
/// backgroundColor: Colors.green,
/// border: Border.all(color: Colors.red, width: 2),
/// borderRadius: BorderRadius.circular(10),
/// ),
/// CometChatMessageOptionSheetStyle(
///       backgroundColor: Colors.green,
///       border: Border.all(color: Colors.red, width: 2),
///       borderRadius: BorderRadius.circular(10),
///    )
///  0
/// ```
class CometChatMessageListStyle
    extends ThemeExtension<CometChatMessageListStyle> {
  const CometChatMessageListStyle({
    this.border,
    this.borderRadius,
    this.backgroundColor,
    this.avatarStyle,
    this.emptyStateTextStyle,
    this.emptyStateTextColor,
    this.emptyStateSubtitleStyle,
    this.emptyStateSubtitleColor,
    this.errorStateTextStyle,
    this.errorStateTextColor,
    this.errorStateSubtitleStyle,
    this.errorStateSubtitleColor,
    this.incomingMessageBubbleStyle,
    this.outgoingMessageBubbleStyle,
    this.messageInformationStyle,
    this.messageOptionSheetStyle,
    this.mentionsStyle,
    this.actionBubbleStyle,
    this.reactionListStyle,
    this.reactionsStyle,
    this.aiSmartRepliesStyle,
    this.aiConversationStarterStyle,
  });

  ///[backgroundColor] defines the background color of the message list
  final Color? backgroundColor;

  ///[border] defines the border of the message list
  final BoxBorder? border;

  ///[borderRadius] defines the border radius of the message list
  final BorderRadiusGeometry? borderRadius;

  ///[avatarStyle] set style for avatar visible in leading view of message bubble
  final CometChatAvatarStyle? avatarStyle;

  // ///[emptyStateTextStyle] defines the style of the text to be displayed when the message list is empty
  final TextStyle? emptyStateTextStyle;
  //
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

  ///[incomingMessageBubbleStyle] defines the style of the incoming message bubble
  final CometChatIncomingMessageBubbleStyle? incomingMessageBubbleStyle;

  ///[outgoingMessageBubbleStyle] defines the style of the outgoing message bubble
  final CometChatOutgoingMessageBubbleStyle? outgoingMessageBubbleStyle;

  ///[messageInformationStyle] is a parameter used to set the style for the message information
  final CometChatMessageInformationStyle? messageInformationStyle;

  ///[messageOptionSheetStyle] that can be used to style message option sheet
  final CometChatMessageOptionSheetStyle? messageOptionSheetStyle;

  ///[mentionsStyle] is a parameter used to set the style for mentions
  final CometChatMentionsStyle? mentionsStyle;

  ///[actionBubbleStyle] is a parameter used to set the style for group actions
  final CometChatActionBubbleStyle? actionBubbleStyle;

  ///[reactionListStyle] is used to set the style for the reaction list
  final CometChatReactionListStyle? reactionListStyle;

  ///[reactionsStyle] is a parameter used to set the style for the reactions
  final CometChatReactionsStyle? reactionsStyle;

  ///[aiSmartRepliesStyle] is a parameter used to set the style for the smart replies
  final CometChatAISmartRepliesStyle? aiSmartRepliesStyle;

  ///[aiConversationStarterStyle] is a parameter used to set the style for the conversation starter
  final CometChatAIConversationStarterStyle? aiConversationStarterStyle;

  /// Copy with some properties replaced
  @override
  CometChatMessageListStyle copyWith({
    Color? backgroundColor,
    BoxBorder? border,
    BorderRadiusGeometry? borderRadius,
    CometChatAvatarStyle? messageBubbleAvatarStyle,
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
    CometChatOutgoingMessageBubbleStyle? outgoingMessageBubbleStyle,
    CometChatIncomingMessageBubbleStyle? incomingMessageBubbleStyle,
    CometChatMessageInformationStyle? messageInformationStyle,
    CometChatMessageOptionSheetStyle? messageOptionSheetStyle,
    CometChatMentionsStyle? mentionsStyle,
    CometChatActionBubbleStyle? actionBubbleStyle,
    CometChatReactionListStyle? reactionListStyle,
    CometChatReactionsStyle? reactionsStyle,
    CometChatAISmartRepliesStyle? aiSmartRepliesStyle,
    CometChatAIConversationStarterStyle? aiConversationStarterStyle,
  }) {
    return CometChatMessageListStyle(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      border: border ?? this.border,
      borderRadius: borderRadius ?? this.borderRadius,
      avatarStyle: messageBubbleAvatarStyle ?? this.avatarStyle,
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
      incomingMessageBubbleStyle:
          incomingMessageBubbleStyle ?? this.incomingMessageBubbleStyle,
      outgoingMessageBubbleStyle:
          outgoingMessageBubbleStyle ?? this.outgoingMessageBubbleStyle,
      messageInformationStyle:
          messageInformationStyle ?? this.messageInformationStyle,
      messageOptionSheetStyle:
          messageOptionSheetStyle ?? this.messageOptionSheetStyle,
      mentionsStyle: mentionsStyle ?? this.mentionsStyle,
      actionBubbleStyle: actionBubbleStyle ?? this.actionBubbleStyle,
      reactionListStyle: reactionListStyle ?? this.reactionListStyle,
      reactionsStyle: reactionsStyle ?? this.reactionsStyle,
      aiSmartRepliesStyle: aiSmartRepliesStyle ?? this.aiSmartRepliesStyle,
      aiConversationStarterStyle: aiConversationStarterStyle ?? this.aiConversationStarterStyle,
    );
  }

  /// Merge with another MessageListStyle
  CometChatMessageListStyle merge(CometChatMessageListStyle? other) {
    if (other == null) return this;
    return copyWith(
      backgroundColor: other.backgroundColor,
      border: other.border,
      borderRadius: other.borderRadius,
      messageBubbleAvatarStyle: other.avatarStyle,
      emptyStateTextStyle: other.emptyStateTextStyle,
      emptyStateTextColor: other.emptyStateTextColor,
      emptyStateSubtitleStyle: other.emptyStateSubtitleStyle,
      emptyStateSubtitleColor: other.emptyStateSubtitleColor,
      errorStateTextStyle: other.errorStateTextStyle,
      errorStateTextColor: other.errorStateTextColor,
      errorStateSubtitleStyle: other.errorStateSubtitleStyle,
      errorStateSubtitleColor: other.errorStateSubtitleColor,
      incomingMessageBubbleStyle: other.incomingMessageBubbleStyle,
      outgoingMessageBubbleStyle: other.outgoingMessageBubbleStyle,
      messageInformationStyle: other.messageInformationStyle,
      messageOptionSheetStyle: other.messageOptionSheetStyle,
      mentionsStyle: other.mentionsStyle,
      actionBubbleStyle: other.actionBubbleStyle,
      reactionListStyle: other.reactionListStyle,
      reactionsStyle: other.reactionsStyle,
      aiSmartRepliesStyle: other.aiSmartRepliesStyle,
      aiConversationStarterStyle: aiConversationStarterStyle,
    );
  }

  static CometChatMessageListStyle of(BuildContext context) =>
      const CometChatMessageListStyle();

  @override
  CometChatMessageListStyle lerp(CometChatMessageListStyle? other, double t) {
    if (other is! CometChatMessageListStyle) {
      return this;
    }
    return CometChatMessageListStyle(
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t),
      border: BoxBorder.lerp(border, other.border, t),
      borderRadius:
          BorderRadiusGeometry.lerp(borderRadius, other.borderRadius, t),
      avatarStyle: avatarStyle?.lerp(other.avatarStyle, t),
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
      incomingMessageBubbleStyle:
          incomingMessageBubbleStyle?.lerp(other.incomingMessageBubbleStyle, t),
      outgoingMessageBubbleStyle:
          outgoingMessageBubbleStyle?.lerp(other.outgoingMessageBubbleStyle, t),
      messageInformationStyle:
          messageInformationStyle?.lerp(other.messageInformationStyle, t),
      messageOptionSheetStyle:
          messageOptionSheetStyle?.lerp(other.messageOptionSheetStyle, t),
      mentionsStyle: mentionsStyle?.lerp(other.mentionsStyle, t),
      actionBubbleStyle: actionBubbleStyle?.lerp(other.actionBubbleStyle, t),
      reactionListStyle: reactionListStyle?.lerp(other.reactionListStyle, t),
      reactionsStyle: reactionsStyle?.lerp(other.reactionsStyle, t),
      aiSmartRepliesStyle:
          aiSmartRepliesStyle?.lerp(other.aiSmartRepliesStyle, t),
      aiConversationStarterStyle:
          aiConversationStarterStyle?.lerp(other.aiConversationStarterStyle, t),
    );
  }
}
