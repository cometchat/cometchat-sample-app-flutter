import 'dart:ui';

import 'package:cometchat_uikit_shared/cometchat_uikit_shared.dart';
import 'package:flutter/material.dart';

///[CometChatIncomingMessageBubbleStyle] is a data class that has styling-related properties
///to customize the appearance of the incoming message bubble
///
/// ```dart
/// CometChatIncomingMessageBubbleStyle(
///  backgroundColor: Colors.white,
///  border: Border.all(color: Colors.red),
///  borderRadius: BorderRadius.circular(10),
///  messageBubbleAvatarStyle: CometChatAvatarStyle(),
///  messageReceiptStyle: CometChatMessageReceiptStyle(),
///  messageBubbleDateStyle: CometChatDateStyle(),
///  textBubbleStyle: CometChatTextBubbleStyle(),
///  imageBubbleStyle: CometChatImageBubbleStyle(),
///  videoBubbleStyle: CometChatVideoBubbleStyle(),
///  audioBubbleStyle: CometChatAudioBubbleStyle(),
///  fileBubbleStyle: CometChatFileBubbleStyle(),
/// );
/// ```
class CometChatIncomingMessageBubbleStyle extends ThemeExtension<CometChatIncomingMessageBubbleStyle>{

  const CometChatIncomingMessageBubbleStyle({
    this.messageBubbleBackgroundImage,
    this.backgroundColor,
    this.border,
    this.borderRadius,
    this.threadedMessageIndicatorTextStyle,
    this.threadedMessageIndicatorIconColor,
    this.messageBubbleAvatarStyle,
    this.messageBubbleReactionStyle,
    this.messageBubbleDateStyle,
    this.textBubbleStyle,
    this.imageBubbleStyle,
    this.videoBubbleStyle,
    this.audioBubbleStyle,
    this.fileBubbleStyle,
    this.collaborativeDocumentBubbleStyle,
    this.collaborativeWhiteboardBubbleStyle,
    this.pollsBubbleStyle,
    this.deletedBubbleStyle,
    this.linkPreviewBubbleStyle,
    this.messageTranslationBubbleStyle,
    this.stickerBubbleStyle,
    this.senderNameTextStyle,
    this.voiceCallBubbleStyle,
    this.videoCallBubbleStyle,
    this.aiAssistantBubbleStyle,
  });

  ///[messageBubbleBackgroundImage] provides background image to the message bubble of a received message
  final DecorationImage? messageBubbleBackgroundImage;

  ///[backgroundColor] provides background color to the message bubble of a received message
  final Color? backgroundColor;

  ///[border] provides border to the message bubble of a received message
  final BoxBorder? border;

  ///[borderRadius] provides border radius to the message bubble of a received message
  final BorderRadiusGeometry? borderRadius;

  ///[threadedMessageIndicatorTextStyle] provides text style to the threaded message indicator
  final TextStyle? threadedMessageIndicatorTextStyle;

  ///[threadedMessageIndicatorIconColor] provides color to the threaded message icon
  final Color? threadedMessageIndicatorIconColor;

  ///[messageBubbleAvatarStyle] provides style to the avatar of the sender
  final CometChatAvatarStyle? messageBubbleAvatarStyle;

  ///[messageBubbleReactionStyle] provides style to the reactions of the message bubble
  final CometChatReactionsStyle? messageBubbleReactionStyle;

  ///[messageBubbleDateStyle] provides style to the date of the message bubble
  final CometChatDateStyle? messageBubbleDateStyle;

  ///[textBubbleStyle] provides style to the text bubble of the received message
  final CometChatTextBubbleStyle? textBubbleStyle;

  ///[imageBubbleStyle] provides style to the image bubble of the received message
  final CometChatImageBubbleStyle? imageBubbleStyle;

  ///[videoBubbleStyle] provides style to the video bubble of the received message
  final CometChatVideoBubbleStyle? videoBubbleStyle;

  ///[audioBubbleStyle] provides style to the audio bubble of the received message
  final CometChatAudioBubbleStyle? audioBubbleStyle;

  ///[fileBubbleStyle] provides style to the file bubble of the received message
  final CometChatFileBubbleStyle? fileBubbleStyle;

  ///[collaborativeDocumentBubbleStyle] provides style to the collaborative document bubble of the sent message
  final CometChatCollaborativeBubbleStyle? collaborativeDocumentBubbleStyle;

  ///[collaborativeWhiteboardBubbleStyle] provides style to the collaborative whiteboard bubble of the sent message
  final CometChatCollaborativeBubbleStyle? collaborativeWhiteboardBubbleStyle;

  ///[pollsBubbleStyle] provides style to the polls bubble of the sent message
  final CometChatPollsBubbleStyle? pollsBubbleStyle;

  ///[deletedBubbleStyle] provides style to the deleted bubble of the received message
  final CometChatDeletedBubbleStyle? deletedBubbleStyle;

  ///[linkPreviewBubbleStyle] provides style to the link preview bubble of the sent message
  final CometChatLinkPreviewBubbleStyle? linkPreviewBubbleStyle;

  ///[messageTranslationBubbleStyle] provides style to the message translation bubble of the sent message
  final CometChatMessageTranslationBubbleStyle? messageTranslationBubbleStyle;

  ///[stickerBubbleStyle] provides style to the sticker bubble of the sent message
  final CometChatStickerBubbleStyle? stickerBubbleStyle;

  ///[senderNameTextStyle] provides style to the sender name of the received message
  final TextStyle? senderNameTextStyle;

  ///[voiceCallBubbleStyle] is a [CometChatCallBubbleStyle] that can be used to style voice call bubble
  final CometChatCallBubbleStyle? voiceCallBubbleStyle;

  ///[videoCallBubbleStyle] is a [CometChatCallBubbleStyle] that can be used to style video call bubble
  final CometChatCallBubbleStyle? videoCallBubbleStyle;

  ///[aiAssistantBubbleStyle] is a [CometChatAIAssistantBubbleStyle] that can be used to style ai assistant bubble
  final CometChatAIAssistantBubbleStyle? aiAssistantBubbleStyle;


  static CometChatIncomingMessageBubbleStyle of(BuildContext context)=> const CometChatIncomingMessageBubbleStyle();

  @override
  CometChatIncomingMessageBubbleStyle copyWith({
    DecorationImage? messageBubbleBackgroundImage,
    Color? backgroundColor,
    BoxBorder? border,
    BorderRadiusGeometry? borderRadius,
    TextStyle? threadedMessageIndicatorTextStyle,
    Color? threadedMessageIndicatorIconColor,
    CometChatAvatarStyle? messageBubbleAvatarStyle,
    CometChatMessageReceiptStyle? messageReceiptStyle,
    CometChatReactionsStyle? messageBubbleReactionStyle,
    CometChatDateStyle? messageBubbleDateStyle,
    CometChatTextBubbleStyle? textBubbleStyle,
    CometChatImageBubbleStyle? imageBubbleStyle,
    CometChatVideoBubbleStyle? videoBubbleStyle,
    CometChatAudioBubbleStyle? audioBubbleStyle,
    CometChatFileBubbleStyle? fileBubbleStyle,
    CometChatCollaborativeBubbleStyle? collaborativeDocumentBubbleStyle,
    CometChatCollaborativeBubbleStyle? collaborativeWhiteboardBubbleStyle,
   CometChatPollsBubbleStyle? pollsBubbleStyle,
    CometChatDeletedBubbleStyle? deletedBubbleStyle,
    CometChatLinkPreviewBubbleStyle? linkPreviewBubbleStyle,
    CometChatMessageTranslationBubbleStyle? messageTranslationBubbleStyle,
    CometChatStickerBubbleStyle? stickerBubbleStyle,
    TextStyle? senderNameTextStyle,
    CometChatCallBubbleStyle? voiceCallBubbleStyle,
    CometChatCallBubbleStyle? videoCallBubbleStyle,
    CometChatAIAssistantBubbleStyle? aiAssistantBubbleStyle,
  }) {
    return CometChatIncomingMessageBubbleStyle(
      messageBubbleBackgroundImage: messageBubbleBackgroundImage ?? this.messageBubbleBackgroundImage,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      border: border ?? this.border,
      borderRadius: borderRadius ?? this.borderRadius,
      threadedMessageIndicatorTextStyle: threadedMessageIndicatorTextStyle ?? this.threadedMessageIndicatorTextStyle,
      threadedMessageIndicatorIconColor: threadedMessageIndicatorIconColor ?? this.threadedMessageIndicatorIconColor,
      messageBubbleAvatarStyle: messageBubbleAvatarStyle ?? this.messageBubbleAvatarStyle,
      messageBubbleReactionStyle: messageBubbleReactionStyle ?? this.messageBubbleReactionStyle,
      messageBubbleDateStyle: messageBubbleDateStyle ?? this.messageBubbleDateStyle,
      textBubbleStyle: textBubbleStyle ?? this.textBubbleStyle,
      imageBubbleStyle: imageBubbleStyle ?? this.imageBubbleStyle,
      videoBubbleStyle: videoBubbleStyle ?? this.videoBubbleStyle,
      audioBubbleStyle: audioBubbleStyle ?? this.audioBubbleStyle,
      fileBubbleStyle: fileBubbleStyle ?? this.fileBubbleStyle,
      collaborativeDocumentBubbleStyle: collaborativeDocumentBubbleStyle ?? this.collaborativeDocumentBubbleStyle,
      collaborativeWhiteboardBubbleStyle: collaborativeWhiteboardBubbleStyle ?? this.collaborativeWhiteboardBubbleStyle,
      pollsBubbleStyle: pollsBubbleStyle ?? this.pollsBubbleStyle,
      deletedBubbleStyle: deletedBubbleStyle ?? this.deletedBubbleStyle,
      linkPreviewBubbleStyle: linkPreviewBubbleStyle ?? this.linkPreviewBubbleStyle,
      messageTranslationBubbleStyle: messageTranslationBubbleStyle ?? this.messageTranslationBubbleStyle,
      stickerBubbleStyle: stickerBubbleStyle ?? this.stickerBubbleStyle,
      senderNameTextStyle: senderNameTextStyle ?? this.senderNameTextStyle,
      voiceCallBubbleStyle: voiceCallBubbleStyle ?? this.voiceCallBubbleStyle,
      videoCallBubbleStyle: videoCallBubbleStyle ?? this.videoCallBubbleStyle,
      aiAssistantBubbleStyle: aiAssistantBubbleStyle ?? this.aiAssistantBubbleStyle,
    );
  }


  CometChatIncomingMessageBubbleStyle merge(CometChatIncomingMessageBubbleStyle? style) {
    if (style == null) return this;
    return copyWith(
      messageBubbleBackgroundImage: style.messageBubbleBackgroundImage,
      backgroundColor: style.backgroundColor,
      border: style.border,
      borderRadius: style.borderRadius,
      audioBubbleStyle: style.audioBubbleStyle,
      messageBubbleAvatarStyle: style.messageBubbleAvatarStyle,
      fileBubbleStyle: style.fileBubbleStyle,
      imageBubbleStyle: style.imageBubbleStyle,
      messageBubbleDateStyle: style.messageBubbleDateStyle,
      messageBubbleReactionStyle: style.messageBubbleReactionStyle,
      textBubbleStyle: style.textBubbleStyle,
      threadedMessageIndicatorIconColor: style.threadedMessageIndicatorIconColor,
      threadedMessageIndicatorTextStyle: style.threadedMessageIndicatorTextStyle,
      videoBubbleStyle: style.videoBubbleStyle,
      collaborativeDocumentBubbleStyle: style.collaborativeDocumentBubbleStyle,
      collaborativeWhiteboardBubbleStyle: style.collaborativeWhiteboardBubbleStyle,
      pollsBubbleStyle: style.pollsBubbleStyle,
      deletedBubbleStyle: style.deletedBubbleStyle,
      messageTranslationBubbleStyle: style.messageTranslationBubbleStyle,
      linkPreviewBubbleStyle: style.linkPreviewBubbleStyle,
      stickerBubbleStyle: style.stickerBubbleStyle,
      senderNameTextStyle: style.senderNameTextStyle,
      voiceCallBubbleStyle: style.voiceCallBubbleStyle,
      videoCallBubbleStyle: style.videoCallBubbleStyle,
      aiAssistantBubbleStyle: style.aiAssistantBubbleStyle,
    );}

  @override
  CometChatIncomingMessageBubbleStyle lerp(covariant CometChatIncomingMessageBubbleStyle? other, double t) {
    if (other is! CometChatIncomingMessageBubbleStyle) {
      return this;
    }
    return CometChatIncomingMessageBubbleStyle(
      messageBubbleBackgroundImage: DecorationImage.lerp(messageBubbleBackgroundImage, other.messageBubbleBackgroundImage, t),
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t),
      border: Border.lerp(border as Border?, other.border as Border?, t),
      borderRadius: BorderRadiusGeometry.lerp(borderRadius, other.borderRadius, t),
      threadedMessageIndicatorTextStyle: TextStyle.lerp(threadedMessageIndicatorTextStyle, other.threadedMessageIndicatorTextStyle, t),
      threadedMessageIndicatorIconColor: Color.lerp(threadedMessageIndicatorIconColor, other.threadedMessageIndicatorIconColor, t),
      messageBubbleAvatarStyle: messageBubbleAvatarStyle?.lerp(other.messageBubbleAvatarStyle, t),
      messageBubbleDateStyle: messageBubbleDateStyle?.lerp(other.messageBubbleDateStyle, t),
      textBubbleStyle: textBubbleStyle?.lerp(other.textBubbleStyle, t),
      imageBubbleStyle: imageBubbleStyle?.lerp(other.imageBubbleStyle, t),
      videoBubbleStyle: videoBubbleStyle?.lerp(other.videoBubbleStyle, t),
      audioBubbleStyle: audioBubbleStyle?.lerp(other.audioBubbleStyle, t),
      fileBubbleStyle: fileBubbleStyle?.lerp(other.fileBubbleStyle, t),
      collaborativeDocumentBubbleStyle: collaborativeDocumentBubbleStyle?.lerp(other.collaborativeDocumentBubbleStyle, t),
      collaborativeWhiteboardBubbleStyle: collaborativeWhiteboardBubbleStyle?.lerp(other.collaborativeWhiteboardBubbleStyle, t),
      pollsBubbleStyle: pollsBubbleStyle?.lerp(other.pollsBubbleStyle, t),
      deletedBubbleStyle: deletedBubbleStyle?.lerp(other.deletedBubbleStyle, t),
      messageBubbleReactionStyle: messageBubbleReactionStyle?.lerp(other.messageBubbleReactionStyle, t),
      messageTranslationBubbleStyle: messageTranslationBubbleStyle?.lerp(other.messageTranslationBubbleStyle, t),
      linkPreviewBubbleStyle: linkPreviewBubbleStyle?.lerp(other.linkPreviewBubbleStyle, t),
      stickerBubbleStyle: stickerBubbleStyle?.lerp(other.stickerBubbleStyle, t),
      senderNameTextStyle: TextStyle.lerp(senderNameTextStyle, other.senderNameTextStyle, t),
      voiceCallBubbleStyle: voiceCallBubbleStyle?.lerp(other.voiceCallBubbleStyle, t),
      videoCallBubbleStyle: videoCallBubbleStyle?.lerp(other.videoCallBubbleStyle, t),
      aiAssistantBubbleStyle: aiAssistantBubbleStyle?.lerp(other.aiAssistantBubbleStyle, t),
    );
  }
}