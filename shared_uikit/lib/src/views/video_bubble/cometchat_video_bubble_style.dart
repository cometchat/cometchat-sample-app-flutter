import 'package:flutter/material.dart';
import 'package:cometchat_uikit_shared/cometchat_uikit_shared.dart';

///[CometChatVideoBubbleStyle] is a data class that has styling-related properties
///to customize the appearance of [CometChatVideoBubble]
///
/// ```dart
/// CometChatVideoBubbleStyle(
///      playIconColor: Colors.white,
///      playIconBackgroundColor: Colors.red,
///      backgroundColor: Colors.white,
///      border: Border.all(color: Colors.red),
///      borderRadius: BorderRadius.circular(10),
///  );
/// ```
class CometChatVideoBubbleStyle
    extends ThemeExtension<CometChatVideoBubbleStyle> {
  const CometChatVideoBubbleStyle({
    this.playIconColor,
    this.playIconBackgroundColor,
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

  ///[playIconColor] provides color to the play icon
  final Color? playIconColor;

  ///[playIconBackgroundColor] provides background color to the play icon
  final Color? playIconBackgroundColor;

  ///[backgroundColor] provides background color to the video bubble
  final Color? backgroundColor;

  ///[border] provides border to the video bubble
  final BoxBorder? border;

  ///[borderRadius] provides border radius to the video bubble
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
  CometChatVideoBubbleStyle copyWith({
    Color? playIconColor,
    Color? playIconBackgroundColor,
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
    return CometChatVideoBubbleStyle(
      playIconColor: playIconColor ?? this.playIconColor,
      playIconBackgroundColor:
          playIconBackgroundColor ?? this.playIconBackgroundColor,
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
  CometChatVideoBubbleStyle lerp(CometChatVideoBubbleStyle? other, double t) {
    if (other == null) return this;
    return CometChatVideoBubbleStyle(
      playIconColor: Color.lerp(playIconColor, other.playIconColor, t),
      playIconBackgroundColor:
          Color.lerp(playIconBackgroundColor, other.playIconBackgroundColor, t),
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t),
      border: BoxBorder.lerp(border, other.border, t),
      borderRadius:
          BorderRadiusGeometry.lerp(borderRadius, other.borderRadius, t),
      messageBubbleAvatarStyle: messageBubbleAvatarStyle?.lerp(other.messageBubbleAvatarStyle, t),
      messageBubbleDateStyle: messageBubbleDateStyle?.lerp(other.messageBubbleDateStyle, t),
      messageBubbleBackgroundImage: DecorationImage.lerp(messageBubbleBackgroundImage, other.messageBubbleBackgroundImage, t),
      threadedMessageIndicatorTextStyle: TextStyle.lerp(threadedMessageIndicatorTextStyle, other.threadedMessageIndicatorTextStyle, t),
      threadedMessageIndicatorIconColor: Color.lerp(threadedMessageIndicatorIconColor, other.threadedMessageIndicatorIconColor, t),
      senderNameTextStyle: TextStyle.lerp(senderNameTextStyle, other.senderNameTextStyle, t),
      messageReceiptStyle: messageReceiptStyle?.lerp(other.messageReceiptStyle, t),
    );
  }

  static CometChatVideoBubbleStyle of(BuildContext context) =>
      const CometChatVideoBubbleStyle();

  CometChatVideoBubbleStyle merge(CometChatVideoBubbleStyle? style) {
    if (style == null) return this;
    return copyWith(
      playIconColor: style.playIconColor,
      playIconBackgroundColor: style.playIconBackgroundColor,
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
