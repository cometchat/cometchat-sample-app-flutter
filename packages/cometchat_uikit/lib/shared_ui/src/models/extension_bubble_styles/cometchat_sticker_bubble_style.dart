import '../../../cometchat_uikit_shared.dart';
import 'package:flutter/material.dart';

///[CometChatStickerBubbleStyle] is a data class that has styling-related properties fo [CometChatStickerBubble]
class CometChatStickerBubbleStyle
    extends ThemeExtension<CometChatStickerBubbleStyle> {
  const CometChatStickerBubbleStyle({
    this.messageBubbleBackgroundImage,
    this.backgroundColor,
    this.border,
    this.borderRadius,
    this.threadedMessageIndicatorTextStyle,
    this.threadedMessageIndicatorIconColor,
    this.messageBubbleAvatarStyle,
    this.messageReceiptStyle,
    this.messageBubbleDateStyle,
    this.senderNameTextStyle,
  });

  ///[backgroundColor] provides background color to the message bubble of the sent message
  final Color? backgroundColor;

  ///[border] provides border to the message bubble of the sent message
  final BoxBorder? border;

  ///[borderRadius] provides border radius to the message bubble of the sent message
  final BorderRadiusGeometry? borderRadius;

  ///[threadedMessageIndicatorTextStyle] provides text style to the threaded message indicator
  final TextStyle? threadedMessageIndicatorTextStyle;

  ///[threadedMessageIndicatorIconColor] provides color to the threaded message icon
  final Color? threadedMessageIndicatorIconColor;

  ///[senderNameTextStyle] provides style to the sender name of the message
  final TextStyle? senderNameTextStyle;

  ///[messageReceiptStyle] provides style to the message receipt
  final CometChatMessageReceiptStyle? messageReceiptStyle;

  ///[messageBubbleAvatarStyle] provides style to the avatar of the sender
  final CometChatAvatarStyle? messageBubbleAvatarStyle;

  ///[messageBubbleDateStyle] provides style to the date of the message bubble
  final CometChatDateStyle? messageBubbleDateStyle;

  ///[messageBubbleBackgroundImage] provides background image to the message bubble of the sent message
  final DecorationImage? messageBubbleBackgroundImage;

  static CometChatStickerBubbleStyle of(BuildContext context) =>
      const CometChatStickerBubbleStyle();

  @override
  CometChatStickerBubbleStyle copyWith({
    DecorationImage? messageBubbleBackgroundImage,
    Color? backgroundColor,
    BoxBorder? border,
    BorderRadiusGeometry? borderRadius,
    TextStyle? threadedMessageIndicatorTextStyle,
    Color? threadedMessageIndicatorIconColor,
    CometChatAvatarStyle? messageBubbleAvatarStyle,
    CometChatMessageReceiptStyle? messageReceiptStyle,
    CometChatDateStyle? messageBubbleDateStyle,
    TextStyle? senderNameTextStyle,
  }) {
    return CometChatStickerBubbleStyle(
      messageBubbleBackgroundImage:
          messageBubbleBackgroundImage ?? this.messageBubbleBackgroundImage,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      border: border ?? this.border,
      borderRadius: borderRadius ?? this.borderRadius,
      threadedMessageIndicatorTextStyle:
          threadedMessageIndicatorTextStyle ??
          this.threadedMessageIndicatorTextStyle,
      threadedMessageIndicatorIconColor:
          threadedMessageIndicatorIconColor ??
          this.threadedMessageIndicatorIconColor,
      messageBubbleAvatarStyle:
          messageBubbleAvatarStyle ?? this.messageBubbleAvatarStyle,
      messageReceiptStyle: messageReceiptStyle ?? this.messageReceiptStyle,
      messageBubbleDateStyle:
          messageBubbleDateStyle ?? this.messageBubbleDateStyle,
      senderNameTextStyle: senderNameTextStyle ?? this.senderNameTextStyle,
    );
  }

  CometChatStickerBubbleStyle merge(CometChatStickerBubbleStyle? style) {
    if (style == null) return this;
    return copyWith(
      messageBubbleBackgroundImage: style.messageBubbleBackgroundImage,
      backgroundColor: style.backgroundColor,
      border: style.border,
      borderRadius: style.borderRadius,
      messageBubbleAvatarStyle: style.messageBubbleAvatarStyle,
      messageBubbleDateStyle: style.messageBubbleDateStyle,
      messageReceiptStyle: style.messageReceiptStyle,
      threadedMessageIndicatorIconColor:
          style.threadedMessageIndicatorIconColor,
      threadedMessageIndicatorTextStyle:
          style.threadedMessageIndicatorTextStyle,
      senderNameTextStyle: style.senderNameTextStyle,
    );
  }

  @override
  CometChatStickerBubbleStyle lerp(
    covariant CometChatStickerBubbleStyle? other,
    double t,
  ) {
    return CometChatStickerBubbleStyle(
      messageBubbleBackgroundImage: DecorationImage.lerp(
        messageBubbleBackgroundImage,
        other!.messageBubbleBackgroundImage,
        t,
      ),
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t),
      border: Border.lerp(border as Border?, other.border as Border?, t),
      borderRadius: BorderRadiusGeometry.lerp(
        borderRadius,
        other.borderRadius,
        t,
      ),
      threadedMessageIndicatorTextStyle: TextStyle.lerp(
        threadedMessageIndicatorTextStyle,
        other.threadedMessageIndicatorTextStyle,
        t,
      ),
      threadedMessageIndicatorIconColor: Color.lerp(
        threadedMessageIndicatorIconColor,
        other.threadedMessageIndicatorIconColor,
        t,
      ),
      messageBubbleAvatarStyle: messageBubbleAvatarStyle?.lerp(
        other.messageBubbleAvatarStyle,
        t,
      ),
      messageReceiptStyle: messageReceiptStyle?.lerp(
        other.messageReceiptStyle,
        t,
      ),
      messageBubbleDateStyle: messageBubbleDateStyle?.lerp(
        other.messageBubbleDateStyle,
        t,
      ),
      senderNameTextStyle: TextStyle.lerp(
        senderNameTextStyle,
        other.senderNameTextStyle,
        t,
      ),
    );
  }
}
