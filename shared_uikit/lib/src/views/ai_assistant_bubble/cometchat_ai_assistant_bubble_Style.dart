import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:cometchat_uikit_shared/cometchat_uikit_shared.dart';

///[CometChatAIAssistantBubbleStyle] is a data class that has styling-related properties
///to customize the appearance of [CometChatAIAssistantBubble]
///
/// ```dart
/// CometChatAiAssistantBubbleStyle(
/// textStyle: TextStyle(),
/// border: Border.all(color: Colors.red),
/// borderRadius: 10,
class CometChatAIAssistantBubbleStyle extends ThemeExtension<CometChatAIAssistantBubbleStyle> {
  const CometChatAIAssistantBubbleStyle({
    this.textStyle,
    this.border,
    this.borderRadius,
    this.textColor,
    this.backgroundColor,
    this.messageBubbleAvatarStyle,
    this.messageBubbleBackgroundImage,
  });

  ///[textStyle] provides style to text
  final TextStyle? textStyle;

  ///[border] provides border to the text bubble
  final BoxBorder? border;

  ///[borderRadius] provides border radius to the text bubble
  final BorderRadiusGeometry? borderRadius;

  ///[textColor] provides color to the text
  final Color? textColor;

  ///[backgroundColor] provides background color to the text bubble
  final Color? backgroundColor;

  ///[messageBubbleAvatarStyle] provides style to the avatar of the sender
  final CometChatAvatarStyle? messageBubbleAvatarStyle;

  ///[messageBubbleBackgroundImage] provides background image to the message bubble of the sent message
  final DecorationImage? messageBubbleBackgroundImage;


  static CometChatAIAssistantBubbleStyle of( BuildContext context) => const CometChatAIAssistantBubbleStyle( );


  @override
  CometChatAIAssistantBubbleStyle copyWith({
    TextStyle? textStyle,
    BoxBorder? border,
    BorderRadiusGeometry? borderRadius,
    Color? textColor,
    Color? backgroundColor,
    CometChatAvatarStyle? messageBubbleAvatarStyle,
    DecorationImage? messageBubbleBackgroundImage,
  }) {
    return CometChatAIAssistantBubbleStyle(
      textStyle: textStyle ?? this.textStyle,
      border: border ?? this.border,
      borderRadius: borderRadius ?? this.borderRadius,
      textColor: textColor ?? this.textColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      messageBubbleAvatarStyle: messageBubbleAvatarStyle ?? this.messageBubbleAvatarStyle,
      messageBubbleBackgroundImage: messageBubbleBackgroundImage ?? this.messageBubbleBackgroundImage,
    );
  }


  CometChatAIAssistantBubbleStyle merge(CometChatAIAssistantBubbleStyle? style) {
    if (style == null) return this;
    return copyWith(
      textStyle: style.textStyle,
      border: style.border,
      borderRadius: style.borderRadius,
      textColor: style.textColor,
      backgroundColor: style.backgroundColor,
      messageBubbleAvatarStyle: style.messageBubbleAvatarStyle,
      messageBubbleBackgroundImage: style.messageBubbleBackgroundImage,
    );
  }

  @override
  CometChatAIAssistantBubbleStyle lerp(CometChatAIAssistantBubbleStyle? other, double t) {
    return CometChatAIAssistantBubbleStyle(
      textStyle: TextStyle.lerp(textStyle, other?.textStyle, t),
      borderRadius: BorderRadiusGeometry.lerp(borderRadius, other?.borderRadius, t),
      textColor: Color.lerp(textColor, other?.textColor, t),
      backgroundColor: Color.lerp(backgroundColor, other?.backgroundColor, t),
      messageBubbleAvatarStyle: messageBubbleAvatarStyle?.lerp(other?.messageBubbleAvatarStyle, t),
      messageBubbleBackgroundImage: DecorationImage.lerp(messageBubbleBackgroundImage, other?.messageBubbleBackgroundImage, t),
    );
  }
}