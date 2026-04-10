import 'package:flutter/material.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';

///[CometChatThreadedHeaderStyle] is a data class that has styling-related properties
///to customize the appearance of [CometChatThreadedHeader]
class CometChatThreadedHeaderStyle
    extends ThemeExtension<CometChatThreadedHeaderStyle> {
  const CometChatThreadedHeaderStyle({
    this.bubbleContainerBackGroundColor,
    this.bubbleContainerBorder,
    this.bubbleContainerBorderRadius,
    this.countTextStyle,
    this.countTextColor,
    this.countContainerBackGroundColor,
    this.countContainerBorder,
    this.constraints,
    this.incomingMessageBubbleStyle,
    this.outgoingMessageBubbleStyle,
  });

  ///[bubbleContainerBackGroundColor] sets backGround Color for bubble container
  final Color? bubbleContainerBackGroundColor;

  ///[bubbleContainerBorder] sets border for bubble container
  final BoxBorder? bubbleContainerBorder;

  ///[bubbleContainerBorderRadius] sets border radius for bubble container
  final BorderRadiusGeometry? bubbleContainerBorderRadius;

  ///[countTextStyle] sets TextStyle for reply count
  final TextStyle? countTextStyle;

  ///[countTextColor] sets color for reply count
  final Color? countTextColor;

  ///[countContainerBackGroundColor] sets backGround Color for count container
  final Color? countContainerBackGroundColor;

  ///[countContainerBorder] sets border for count container
  final BoxBorder? countContainerBorder;

  ///[constraints] sets constraints for the message container
  final BoxConstraints? constraints;

  ///[incomingMessageBubbleStyle] sets style for incoming message bubble
  final CometChatIncomingMessageBubbleStyle? incomingMessageBubbleStyle;

  ///[outgoingMessageBubbleStyle] sets style for outgoing message bubble
  final CometChatOutgoingMessageBubbleStyle? outgoingMessageBubbleStyle;

  static CometChatThreadedHeaderStyle of(BuildContext context) =>
      const CometChatThreadedHeaderStyle();

  @override
  CometChatThreadedHeaderStyle copyWith({
    Color? bubbleContainerBackGroundColor,
    BoxBorder? bubbleContainerBorder,
    BorderRadiusGeometry? bubbleContainerBorderRadius,
    TextStyle? countTextStyle,
    Color? countTextColor,
    Color? countContainerBackGroundColor,
    BoxBorder? countContainerBorder,
    BoxConstraints? constraints,
    CometChatIncomingMessageBubbleStyle? incomingMessageBubbleStyle,
    CometChatOutgoingMessageBubbleStyle? outgoingMessageBubbleStyle,
  }) {
    return CometChatThreadedHeaderStyle(
      bubbleContainerBackGroundColor:
          bubbleContainerBackGroundColor ?? this.bubbleContainerBackGroundColor,
      bubbleContainerBorder:
          bubbleContainerBorder ?? this.bubbleContainerBorder,
      bubbleContainerBorderRadius:
          bubbleContainerBorderRadius ?? this.bubbleContainerBorderRadius,
      countTextStyle: countTextStyle ?? this.countTextStyle,
      countTextColor: countTextColor ?? this.countTextColor,
      countContainerBackGroundColor:
          countContainerBackGroundColor ?? this.countContainerBackGroundColor,
      countContainerBorder: countContainerBorder ?? this.countContainerBorder,
      constraints: constraints ?? this.constraints,
      incomingMessageBubbleStyle: incomingMessageBubbleStyle ?? this.incomingMessageBubbleStyle,
      outgoingMessageBubbleStyle: outgoingMessageBubbleStyle ?? this.outgoingMessageBubbleStyle,
    );
  }

  CometChatThreadedHeaderStyle merge(CometChatThreadedHeaderStyle? style) {
    if (style == null) return this;
    return copyWith(
      bubbleContainerBackGroundColor: style.bubbleContainerBackGroundColor,
      bubbleContainerBorder: style.bubbleContainerBorder,
      bubbleContainerBorderRadius: style.bubbleContainerBorderRadius,
      countTextStyle: style.countTextStyle,
      countTextColor: style.countTextColor,
      countContainerBackGroundColor: style.countContainerBackGroundColor,
      countContainerBorder: style.countContainerBorder,
      constraints: style.constraints,
      incomingMessageBubbleStyle: style.incomingMessageBubbleStyle,
      outgoingMessageBubbleStyle: style.outgoingMessageBubbleStyle,
    );
  }

  @override
  CometChatThreadedHeaderStyle lerp(
      ThemeExtension<CometChatThreadedHeaderStyle>? other, double t) {
    if (other is! CometChatThreadedHeaderStyle) {
      return this;
    }
    return CometChatThreadedHeaderStyle(
      bubbleContainerBackGroundColor: Color.lerp(bubbleContainerBackGroundColor,
          other.bubbleContainerBackGroundColor, t),
      bubbleContainerBorder:
          BoxBorder.lerp(bubbleContainerBorder, other.bubbleContainerBorder, t),
      bubbleContainerBorderRadius: BorderRadiusGeometry.lerp(
          bubbleContainerBorderRadius, other.bubbleContainerBorderRadius, t),
      countTextStyle: TextStyle.lerp(countTextStyle, other.countTextStyle, t),
      countTextColor: Color.lerp(countTextColor, other.countTextColor, t),
      countContainerBackGroundColor: Color.lerp(countContainerBackGroundColor,
          other.countContainerBackGroundColor, t),
      countContainerBorder:
          BoxBorder.lerp(countContainerBorder, other.countContainerBorder, t),
      constraints: BoxConstraints.lerp(constraints, other.constraints, t),
      incomingMessageBubbleStyle: incomingMessageBubbleStyle?.lerp(other.incomingMessageBubbleStyle,t),
      outgoingMessageBubbleStyle: outgoingMessageBubbleStyle?.lerp(other.outgoingMessageBubbleStyle,t),
    );
  }
}
