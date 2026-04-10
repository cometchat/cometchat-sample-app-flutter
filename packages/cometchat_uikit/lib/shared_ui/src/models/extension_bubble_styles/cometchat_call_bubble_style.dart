import '../../../cometchat_uikit_shared.dart';
import 'package:flutter/material.dart';

///[CometChatCallBubbleStyle] is a data class that has styling-related properties
///to customize the appearance of [CometChatCallBubble]
///
/// ```dart
///  CallBubbleStyle(
///  backgroundColor: Colors.blue,
///  iconColor: Colors.grey,
///  titleStyle: TextStyle(
///  color: Colors.red,
///  fontSize: 16,
///  fontWeight: FontWeight.bold,
///  ),
///  subtitleStyle: TextStyle(
///  color: Colors.red,
///  fontSize: 14,
///  fontWeight: FontWeight.bold,
///  ),
///  buttonTextStyle: TextStyle(
///  color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold
///  ),
///  );
///
class CometChatCallBubbleStyle extends ThemeExtension<CometChatCallBubbleStyle> {
  ///[CometChatCallBubbleStyle] constructor requires [titleStyle], [subtitleStyle], [buttonTextStyle], [iconColor] and [background] while initializing.
  const CometChatCallBubbleStyle({
    this.titleStyle,
    this.subtitleStyle,
    this.buttonTextStyle,
    this.buttonBackgroundColor,
    this.iconColor,
    this.backgroundColor,
    this.border,
    this.borderRadius,
    this.iconBackgroundColor,
    this.messageBubbleAvatarStyle,
    this.messageBubbleDateStyle,
    this.messageBubbleBackgroundImage,
    this.messageReceiptStyle,
    this.threadedMessageIndicatorTextStyle,
    this.senderNameTextStyle,
    this.threadedMessageIndicatorIconColor,
    this.dividerColor
  });

  ///[titleStyle] title text style
  final TextStyle? titleStyle;

  ///[subtitleStyle] subtitle text style
  final TextStyle? subtitleStyle;

  ///[buttonTextStyle] buttonText text style
  final TextStyle? buttonTextStyle;

  ///[iconColor] default Call bubble icon
  final Color? iconColor;

  ///[buttonBackgroundColor] sets the Call bubble button background
  final Color? buttonBackgroundColor;

  ///[backgroundColor] sets the Call bubble background
  final Color? backgroundColor;

  ///[border] sets the Call bubble border
  final BoxBorder? border;

  ///[borderRadius] sets the Call bubble border radius
  final BorderRadiusGeometry? borderRadius;
  
  ///[iconBackgroundColor] sets the Call bubble icon background color
  final Color? iconBackgroundColor;

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

  ///[dividerColor] provides color to the divider
  final Color? dividerColor;

  /// Copies current [CometChatCallBubbleStyle] with some changes
  @override
  CometChatCallBubbleStyle copyWith({
    TextStyle? titleStyle,
    TextStyle? subtitleStyle,
    TextStyle? buttonTextStyle,
    Color? buttonBackgroundColor,
    Color? iconColor,
    Color? backgroundColor,
    BoxBorder? border,
    BorderRadiusGeometry? borderRadius,
    Color? iconBackgroundColor,
    CometChatAvatarStyle? messageBubbleAvatarStyle,
    CometChatDateStyle? messageBubbleDateStyle,
    DecorationImage? messageBubbleBackgroundImage,
    TextStyle? threadedMessageIndicatorTextStyle,
    Color? threadedMessageIndicatorIconColor,
    TextStyle? senderNameTextStyle,
    CometChatMessageReceiptStyle? messageReceiptStyle,
    Color? dividerColor
  }) {
    return CometChatCallBubbleStyle(
      titleStyle: titleStyle ?? this.titleStyle,
      subtitleStyle: subtitleStyle ?? this.subtitleStyle,
      buttonTextStyle: buttonTextStyle ?? this.buttonTextStyle,
      buttonBackgroundColor: buttonBackgroundColor ?? this.buttonBackgroundColor,
      iconColor: iconColor ?? this.iconColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      border: border ?? this.border,
      borderRadius: borderRadius ?? this.borderRadius,
      iconBackgroundColor: iconBackgroundColor ?? this.iconBackgroundColor,
      messageBubbleAvatarStyle: messageBubbleAvatarStyle ?? this.messageBubbleAvatarStyle,
      messageBubbleDateStyle: messageBubbleDateStyle ?? this.messageBubbleDateStyle,
      messageBubbleBackgroundImage: messageBubbleBackgroundImage ?? this.messageBubbleBackgroundImage,
      threadedMessageIndicatorTextStyle: threadedMessageIndicatorTextStyle ?? this.threadedMessageIndicatorTextStyle,
      threadedMessageIndicatorIconColor: threadedMessageIndicatorIconColor ?? this.threadedMessageIndicatorIconColor,
      messageReceiptStyle: messageReceiptStyle ?? this.messageReceiptStyle,
      senderNameTextStyle: senderNameTextStyle ?? this.senderNameTextStyle,
      dividerColor: dividerColor ?? this.dividerColor
    );
  }

  /// Merges current [CometChatCallBubbleStyle] with [other]
  CometChatCallBubbleStyle merge(CometChatCallBubbleStyle? other) {
    if (other == null) return this;
    return copyWith(
      titleStyle: other.titleStyle,
      subtitleStyle: other.subtitleStyle,
      buttonTextStyle: other.buttonTextStyle,
      buttonBackgroundColor: other.buttonBackgroundColor,
      iconColor: other.iconColor,
      backgroundColor: other.backgroundColor,
      border: other.border,
      borderRadius: other.borderRadius,
      iconBackgroundColor: other.iconBackgroundColor,
      senderNameTextStyle: other.senderNameTextStyle,
      messageReceiptStyle: other.messageReceiptStyle,
      messageBubbleAvatarStyle: other.messageBubbleAvatarStyle,
      messageBubbleBackgroundImage: other.messageBubbleBackgroundImage,
      messageBubbleDateStyle: other.messageBubbleDateStyle,
      threadedMessageIndicatorIconColor: other.threadedMessageIndicatorIconColor,
      threadedMessageIndicatorTextStyle: other.threadedMessageIndicatorTextStyle,
      dividerColor: other.dividerColor
    );
  }

  @override
  CometChatCallBubbleStyle lerp(covariant ThemeExtension<CometChatCallBubbleStyle>? other, double t) {
    if (other is! CometChatCallBubbleStyle) {
      return this;
    }
    return CometChatCallBubbleStyle(
      titleStyle: TextStyle.lerp(titleStyle, other.titleStyle, t),
      subtitleStyle: TextStyle.lerp(subtitleStyle, other.subtitleStyle, t),
      buttonTextStyle: TextStyle.lerp(buttonTextStyle, other.buttonTextStyle, t),
      buttonBackgroundColor: Color.lerp(buttonBackgroundColor, other.buttonBackgroundColor, t),
      iconColor: Color.lerp(iconColor, other.iconColor, t),
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t),
      border: BoxBorder.lerp(border, other.border, t),
      borderRadius: BorderRadiusGeometry.lerp(borderRadius, other.borderRadius, t),
      iconBackgroundColor: Color.lerp(iconBackgroundColor, other.iconBackgroundColor, t),
      threadedMessageIndicatorTextStyle: TextStyle.lerp(threadedMessageIndicatorTextStyle, other.threadedMessageIndicatorTextStyle, t),
      threadedMessageIndicatorIconColor: Color.lerp(threadedMessageIndicatorIconColor, other.threadedMessageIndicatorIconColor, t),
      senderNameTextStyle: TextStyle.lerp(senderNameTextStyle, other.senderNameTextStyle, t),
      messageReceiptStyle: messageReceiptStyle?.lerp(other.messageReceiptStyle, t),
      messageBubbleAvatarStyle: messageBubbleAvatarStyle?.lerp(other.messageBubbleAvatarStyle, t),
      messageBubbleBackgroundImage: DecorationImage.lerp(messageBubbleBackgroundImage, other.messageBubbleBackgroundImage, t),
      messageBubbleDateStyle: messageBubbleDateStyle?.lerp(other.messageBubbleDateStyle, t),
      dividerColor: Color.lerp(dividerColor, other.dividerColor, t)
    );
  }

  static CometChatCallBubbleStyle of(BuildContext context) =>
      const CometChatCallBubbleStyle();
}
