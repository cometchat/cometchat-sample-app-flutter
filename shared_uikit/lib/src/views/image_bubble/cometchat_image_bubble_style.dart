import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:cometchat_uikit_shared/cometchat_uikit_shared.dart';

///[CometChatImageBubbleStyle] is a data class that has styling-related properties
///to customize the appearance of [CometChatImageBubble]
///
/// ```dart
/// CometChatImageBubbleStyle(
/// backgroundColor: Colors.white,
/// border: Border.all(color: Colors.red),
/// borderRadius: BorderRadius.circular(10),
/// );
class CometChatImageBubbleStyle extends ThemeExtension<CometChatImageBubbleStyle> {
  const CometChatImageBubbleStyle({
    this.backgroundColor,
    this.border,
    this.borderRadius,
    this.messageBubbleAvatarStyle,
    this.messageBubbleDateStyle,
    this.messageBubbleBackgroundImage,
    this.threadedMessageIndicatorTextStyle,
    this.threadedMessageIndicatorIconColor,
    this.senderNameTextStyle,
    this.messageReceiptStyle,
  });

  ///[backgroundColor] provides background color to the image bubble
  final Color? backgroundColor;

  ///[border] provides border to the image bubble
  final BoxBorder? border;

  ///[borderRadius] provides border radius to the image bubble
  final BorderRadiusGeometry? borderRadius;

  ///[messageBubbleAvatarStyle] provides style to the avatar of the sender
  final CometChatAvatarStyle? messageBubbleAvatarStyle;

  ///[messageBubbleDateStyle] provides style to the date of the message bubble
  final CometChatDateStyle? messageBubbleDateStyle;

  ///[messageBubbleBackgroundImage] provides background image to the message bubble of the sent message
  final DecorationImage? messageBubbleBackgroundImage;

  ///[threadedMessageIndicatorTextStyle] provides text style to the threaded message indicator
  final TextStyle? threadedMessageIndicatorTextStyle;

  ///[threadedMessageIndicatorIconColor] provides color to the threaded message icon
  final Color? threadedMessageIndicatorIconColor;

  ///[senderNameTextStyle] provides style to the sender name of the message
  final TextStyle? senderNameTextStyle;

  ///[messageReceiptStyle] provides style to the message receipt
  final CometChatMessageReceiptStyle? messageReceiptStyle;

  @override
  CometChatImageBubbleStyle copyWith({
    Color? backgroundColor,
    BoxBorder? border,
    BorderRadiusGeometry? borderRadius,
    CometChatAvatarStyle? messageBubbleAvatarStyle,
    CometChatDateStyle? messageBubbleDateStyle,
    DecorationImage? messageBubbleBackgroundImage,
    TextStyle? threadedMessageIndicatorTextStyle,
    Color? threadedMessageIndicatorIconColor,
    TextStyle? senderNameTextStyle,
    CometChatMessageReceiptStyle? messageReceiptStyle,
  }) {
    return CometChatImageBubbleStyle(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      border: border ?? this.border,
      borderRadius: borderRadius ?? this.borderRadius,
      messageBubbleAvatarStyle: messageBubbleAvatarStyle ?? this.messageBubbleAvatarStyle,
      messageBubbleDateStyle: messageBubbleDateStyle ?? this.messageBubbleDateStyle,
      messageBubbleBackgroundImage: messageBubbleBackgroundImage ?? this.messageBubbleBackgroundImage,
      threadedMessageIndicatorTextStyle: threadedMessageIndicatorTextStyle ?? this.threadedMessageIndicatorTextStyle,
      threadedMessageIndicatorIconColor: threadedMessageIndicatorIconColor ?? this.threadedMessageIndicatorIconColor,
      senderNameTextStyle: senderNameTextStyle ?? this.senderNameTextStyle,
      messageReceiptStyle: messageReceiptStyle ?? this.messageReceiptStyle,
    );
  }

  @override
  CometChatImageBubbleStyle lerp(CometChatImageBubbleStyle? other, double t) {
    if (other == null) return this;
    return CometChatImageBubbleStyle(
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t),
      border: BoxBorder.lerp(border, other.border, t),
      borderRadius: BorderRadiusGeometry.lerp(borderRadius, other.borderRadius, t),
      messageBubbleAvatarStyle: messageBubbleAvatarStyle?.lerp(other.messageBubbleAvatarStyle, t),
      messageBubbleDateStyle: messageBubbleDateStyle?.lerp(other.messageBubbleDateStyle, t),
      messageBubbleBackgroundImage: DecorationImage.lerp(messageBubbleBackgroundImage, other.messageBubbleBackgroundImage, t),
      threadedMessageIndicatorTextStyle: TextStyle.lerp(threadedMessageIndicatorTextStyle, other.threadedMessageIndicatorTextStyle, t),
      threadedMessageIndicatorIconColor: Color.lerp(threadedMessageIndicatorIconColor, other.threadedMessageIndicatorIconColor, t),
      senderNameTextStyle: TextStyle.lerp(senderNameTextStyle, other.senderNameTextStyle, t),
      messageReceiptStyle: messageReceiptStyle?.lerp(other.messageReceiptStyle, t),
    );
  }

  static CometChatImageBubbleStyle of(BuildContext context) => const CometChatImageBubbleStyle();

  CometChatImageBubbleStyle merge(CometChatImageBubbleStyle? style) {
    if (style == null) return this;
    return copyWith(
      backgroundColor: style.backgroundColor,
      border: style.border,
      borderRadius: style.borderRadius,
      messageBubbleAvatarStyle: style.messageBubbleAvatarStyle,
      messageBubbleDateStyle: style.messageBubbleDateStyle,
      messageBubbleBackgroundImage: style.messageBubbleBackgroundImage,
      threadedMessageIndicatorTextStyle: style.threadedMessageIndicatorTextStyle,
      threadedMessageIndicatorIconColor: style.threadedMessageIndicatorIconColor,
      senderNameTextStyle: style.senderNameTextStyle,
      messageReceiptStyle: style.messageReceiptStyle,
    );
  }
}
