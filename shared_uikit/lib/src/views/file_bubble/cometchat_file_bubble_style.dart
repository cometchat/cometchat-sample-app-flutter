import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:cometchat_uikit_shared/cometchat_uikit_shared.dart';

///[CometChatFileBubbleStyle] is a data class that has styling-related properties
///to customize the appearance of [CometChatFileBubble]
class CometChatFileBubbleStyle extends ThemeExtension<CometChatFileBubbleStyle> {
  const CometChatFileBubbleStyle(
      {this.titleTextStyle,
      this.subtitleTextStyle,
      this.backgroundColor,
      this.border,
      this.borderRadius,
      this.downloadIconTint,
      this.titleColor,
      this.subtitleColor,
      this.messageBubbleAvatarStyle,
      this.messageBubbleDateStyle,
      this.messageBubbleBackgroundImage,
      this.threadedMessageIndicatorTextStyle,
      this.threadedMessageIndicatorIconColor,
      this.senderNameTextStyle,
      this.messageReceiptStyle,
      });

  ///[titleTextStyle] file name text style
  final TextStyle? titleTextStyle;

  ///[subtitleTextStyle] subtitle text style
  final TextStyle? subtitleTextStyle;

  ///[downloadIconTint] video play pause icon
  final Color? downloadIconTint;

  ///[backgroundColor] provides background color to the image bubble
  final Color? backgroundColor;

  ///[border] provides border to the image bubble
  final BoxBorder? border;

  ///[borderRadius] provides border radius to the image bubble
  final BorderRadiusGeometry? borderRadius;

  ///[titleColor] provides color to the title
  final Color? titleColor;

  ///[subtitleColor] provides color to the subtitle
  final Color? subtitleColor;

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


  static CometChatFileBubbleStyle of(BuildContext context) => const CometChatFileBubbleStyle();

  @override
  CometChatFileBubbleStyle copyWith({
    TextStyle? titleTextStyle,
    TextStyle? subtitleTextStyle,
    Color? downloadIconTint,
    Color? backgroundColor,
    BoxBorder? border,
    BorderRadiusGeometry? borderRadius,
    Color? titleColor,
    Color? subtitleColor,
    CometChatAvatarStyle? messageBubbleAvatarStyle,
    CometChatDateStyle? messageBubbleDateStyle,
    DecorationImage? messageBubbleBackgroundImage,
    TextStyle? threadedMessageIndicatorTextStyle,
    Color? threadedMessageIndicatorIconColor,
    TextStyle? senderNameTextStyle,
    CometChatMessageReceiptStyle? messageReceiptStyle,
  }) {
    return CometChatFileBubbleStyle(
      titleTextStyle: titleTextStyle ?? this.titleTextStyle,
      subtitleTextStyle: subtitleTextStyle ?? this.subtitleTextStyle,
      downloadIconTint: downloadIconTint ?? this.downloadIconTint,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      border: border ?? this.border,
      borderRadius: borderRadius ?? this.borderRadius,
      titleColor: titleColor ?? this.titleColor,
      subtitleColor: subtitleColor ?? this.subtitleColor,
      messageBubbleAvatarStyle: messageBubbleAvatarStyle ?? this.messageBubbleAvatarStyle,
      messageBubbleDateStyle: messageBubbleDateStyle ?? this.messageBubbleDateStyle,
      messageBubbleBackgroundImage: messageBubbleBackgroundImage ?? this.messageBubbleBackgroundImage,
      threadedMessageIndicatorTextStyle: threadedMessageIndicatorTextStyle ?? this.threadedMessageIndicatorTextStyle,
      threadedMessageIndicatorIconColor: threadedMessageIndicatorIconColor ?? this.threadedMessageIndicatorIconColor,
      senderNameTextStyle: senderNameTextStyle ?? this.senderNameTextStyle,
      messageReceiptStyle: messageReceiptStyle ?? this.messageReceiptStyle,
    );
  }

  CometChatFileBubbleStyle merge(CometChatFileBubbleStyle? style) {
    if (style == null) return this;
    return copyWith(
      titleTextStyle: style.titleTextStyle,
      subtitleTextStyle: style.subtitleTextStyle,
      downloadIconTint: style.downloadIconTint,
      backgroundColor: style.backgroundColor,
      border: style.border,
      borderRadius: style.borderRadius,
      titleColor: style.titleColor,
      subtitleColor: style.subtitleColor,
      messageBubbleAvatarStyle: style.messageBubbleAvatarStyle,
      messageBubbleDateStyle: style.messageBubbleDateStyle,
      messageBubbleBackgroundImage: style.messageBubbleBackgroundImage,
      threadedMessageIndicatorTextStyle: style.threadedMessageIndicatorTextStyle,
      threadedMessageIndicatorIconColor: style.threadedMessageIndicatorIconColor,
      senderNameTextStyle: style.senderNameTextStyle,
      messageReceiptStyle: style.messageReceiptStyle,
    );
  }

  @override
  CometChatFileBubbleStyle lerp(CometChatFileBubbleStyle? other, double t) {
    if (other == null) return this;
    return CometChatFileBubbleStyle(
      titleTextStyle: TextStyle.lerp(titleTextStyle, other.titleTextStyle, t),
      subtitleTextStyle: TextStyle.lerp(subtitleTextStyle, other.subtitleTextStyle, t),
      downloadIconTint: Color.lerp(downloadIconTint, other.downloadIconTint, t),
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t),
      border: BoxBorder.lerp(border, other.border, t),
      borderRadius: BorderRadiusGeometry.lerp(borderRadius, other.borderRadius, t),
      titleColor: Color.lerp(titleColor, other.titleColor, t),
      subtitleColor: Color.lerp(subtitleColor, other.subtitleColor, t),
      messageBubbleAvatarStyle: messageBubbleAvatarStyle?.lerp(other.messageBubbleAvatarStyle, t),
      messageBubbleDateStyle: messageBubbleDateStyle?.lerp(other.messageBubbleDateStyle, t),
      messageBubbleBackgroundImage: DecorationImage.lerp(messageBubbleBackgroundImage, other.messageBubbleBackgroundImage, t),
      messageReceiptStyle: messageReceiptStyle?.lerp(other.messageReceiptStyle, t),
      senderNameTextStyle: TextStyle.lerp(senderNameTextStyle, other.senderNameTextStyle, t),
      threadedMessageIndicatorIconColor: Color.lerp(threadedMessageIndicatorIconColor, other.threadedMessageIndicatorIconColor, t),
      threadedMessageIndicatorTextStyle: TextStyle.lerp(threadedMessageIndicatorTextStyle, other.threadedMessageIndicatorTextStyle, t),
    );
  }
}
