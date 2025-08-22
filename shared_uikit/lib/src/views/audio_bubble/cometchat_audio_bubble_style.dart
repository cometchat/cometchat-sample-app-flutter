import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:cometchat_uikit_shared/cometchat_uikit_shared.dart';

///[CometChatAudioBubbleStyle] is a data class that has styling-related properties
///to customize the appearance of [CometChatAudioBubble]
///
/// ```dart
/// CometChatAudioBubbleStyle(
/// playIconColor: Colors.white,
/// playIconBackgroundColor: Colors.red,
/// backgroundColor: Colors.white,
/// border: Border.all(color: Colors.red),
/// borderRadius: BorderRadius.circular(10),
/// );
/// ```
class CometChatAudioBubbleStyle
    extends ThemeExtension<CometChatAudioBubbleStyle> {
  const CometChatAudioBubbleStyle({
    this.playIconColor,
    this.playIconBackgroundColor,
    this.backgroundColor,
    this.border,
    this.borderRadius,
    this.downloadIconColor,
    this.audioBarColor,
    this.messageBubbleAvatarStyle,
    this.messageBubbleDateStyle,
    this.messageBubbleBackgroundImage,
    this.threadedMessageIndicatorTextStyle,
    this.threadedMessageIndicatorIconColor,
    this.senderNameTextStyle,
    this.messageReceiptStyle,
    this.durationTextColor,
    this.durationTextStyle,
  });

  ///[playIconColor] provides color to the audio play/pause icon
  final Color? playIconColor;

  ///[playIconBackgroundColor] provides background color to the audio bubble
  final Color? playIconBackgroundColor;

  ///[backgroundColor] provides background color to the audio bubble
  final Color? backgroundColor;

  ///[border] provides border to the audio bubble
  final BoxBorder? border;

  ///[borderRadius] provides border radius to the audio bubble
  final BorderRadiusGeometry? borderRadius;

  ///[downloadIconColor] provides color to the download icon
  final Color? downloadIconColor;

  ///[audioBarColor] provides color to the audio bar visualizer
  final Color? audioBarColor;

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

  ///[durationTextColor] provides color to the duration text
  final Color? durationTextColor;

  ///[durationTextStyle] provides style to the duration text
  final TextStyle? durationTextStyle;

  static CometChatAudioBubbleStyle of(BuildContext context) =>
      const CometChatAudioBubbleStyle();

  @override
  CometChatAudioBubbleStyle copyWith({
    Color? playIconColor,
    Color? backgroundColor,
    BoxBorder? border,
    BorderRadiusGeometry? borderRadius,
    Color? playIconBackgroundColor,
    Color? downloadIconColor,
    Color? audioBarColor,
    CometChatAvatarStyle? messageBubbleAvatarStyle,
    CometChatDateStyle? messageBubbleDateStyle,
    DecorationImage? messageBubbleBackgroundImage,
    TextStyle? threadedMessageIndicatorTextStyle,
    Color? threadedMessageIndicatorIconColor,
    TextStyle? senderNameTextStyle,
    CometChatMessageReceiptStyle? messageReceiptStyle,
    Color? durationTextColor,
    TextStyle? durationTextStyle,
  }) =>
      CometChatAudioBubbleStyle(
        playIconColor: playIconColor ?? this.playIconColor,
        backgroundColor: backgroundColor ?? this.backgroundColor,
        border: border ?? this.border,
        borderRadius: borderRadius ?? this.borderRadius,
        playIconBackgroundColor:
            playIconBackgroundColor ?? this.playIconBackgroundColor,
        audioBarColor: audioBarColor ?? this.audioBarColor,
        downloadIconColor: downloadIconColor ?? this.downloadIconColor,
        messageBubbleAvatarStyle:
            messageBubbleAvatarStyle ?? this.messageBubbleAvatarStyle,
        messageBubbleDateStyle:
            messageBubbleDateStyle ?? this.messageBubbleDateStyle,
        messageBubbleBackgroundImage:
            messageBubbleBackgroundImage ?? this.messageBubbleBackgroundImage,
        threadedMessageIndicatorTextStyle: threadedMessageIndicatorTextStyle ??
            this.threadedMessageIndicatorTextStyle,
        threadedMessageIndicatorIconColor: threadedMessageIndicatorIconColor ??
            this.threadedMessageIndicatorIconColor,
        senderNameTextStyle: senderNameTextStyle ?? this.senderNameTextStyle,
        messageReceiptStyle: messageReceiptStyle ?? this.messageReceiptStyle,
        durationTextColor: durationTextColor ?? this.durationTextColor,
        durationTextStyle: durationTextStyle ?? this.durationTextStyle,
      );

  CometChatAudioBubbleStyle merge(CometChatAudioBubbleStyle? style) {
    if (style == null) return this;
    return copyWith(
      backgroundColor: style.backgroundColor,
      border: style.border,
      borderRadius: style.borderRadius,
      playIconColor: style.playIconColor,
      playIconBackgroundColor: style.playIconBackgroundColor,
      audioBarColor: style.audioBarColor,
      downloadIconColor: style.downloadIconColor,
      messageBubbleAvatarStyle: style.messageBubbleAvatarStyle,
      messageBubbleDateStyle: style.messageBubbleDateStyle,
      messageBubbleBackgroundImage: style.messageBubbleBackgroundImage,
      threadedMessageIndicatorTextStyle:
          style.threadedMessageIndicatorTextStyle,
      threadedMessageIndicatorIconColor:
          style.threadedMessageIndicatorIconColor,
      senderNameTextStyle: style.senderNameTextStyle,
      messageReceiptStyle: style.messageReceiptStyle,
      durationTextColor: style.durationTextColor,
      durationTextStyle: style.durationTextStyle,
    );
  }

  @override
  CometChatAudioBubbleStyle lerp(CometChatAudioBubbleStyle? other, double t) {
    if (other == null) return this;
    return CometChatAudioBubbleStyle(
      playIconColor: Color.lerp(playIconColor, other.playIconColor, t),
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t),
      border: BoxBorder.lerp(border, other.border, t),
      borderRadius:
          BorderRadiusGeometry.lerp(borderRadius, other.borderRadius, t),
      playIconBackgroundColor:
          Color.lerp(playIconBackgroundColor, other.playIconBackgroundColor, t),
      audioBarColor: Color.lerp(audioBarColor, other.audioBarColor, t),
      downloadIconColor:
          Color.lerp(downloadIconColor, other.downloadIconColor, t),
      messageBubbleAvatarStyle:
          messageBubbleAvatarStyle?.lerp(other.messageBubbleAvatarStyle, t),
      messageBubbleDateStyle:
          messageBubbleDateStyle?.lerp(other.messageBubbleDateStyle, t),
      messageBubbleBackgroundImage: DecorationImage.lerp(
          messageBubbleBackgroundImage, other.messageBubbleBackgroundImage, t),
      threadedMessageIndicatorTextStyle: TextStyle.lerp(
          threadedMessageIndicatorTextStyle,
          other.threadedMessageIndicatorTextStyle,
          t),
      threadedMessageIndicatorIconColor: Color.lerp(
          threadedMessageIndicatorIconColor,
          other.threadedMessageIndicatorIconColor,
          t),
      senderNameTextStyle:
          TextStyle.lerp(senderNameTextStyle, other.senderNameTextStyle, t),
      messageReceiptStyle:
          messageReceiptStyle?.lerp(other.messageReceiptStyle, t),
      durationTextColor:
          Color.lerp(durationTextColor, other.durationTextColor, t),
      durationTextStyle:
          TextStyle.lerp(durationTextStyle, other.durationTextStyle, t),
    );
  }
}
