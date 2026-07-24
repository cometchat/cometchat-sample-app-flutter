import 'package:flutter/material.dart';
import '../../../cometchat_uikit_shared.dart';

/// Styling properties for [CometChatAIAssistantBubble].
class CometChatAIAssistantBubbleStyle
    extends ThemeExtension<CometChatAIAssistantBubbleStyle> {
  const CometChatAIAssistantBubbleStyle({
    this.textStyle,
    this.border,
    this.borderRadius,
    this.textColor,
    this.backgroundColor,
    this.messageBubbleAvatarStyle,
    this.messageBubbleBackgroundImage,
  });

  /// Style applied to the markdown text.
  final TextStyle? textStyle;

  /// Border around the bubble.
  final BoxBorder? border;

  /// Border radius of the bubble.
  final BorderRadiusGeometry? borderRadius;

  /// Color applied to the text.
  final Color? textColor;

  /// Background color of the bubble.
  final Color? backgroundColor;

  /// Style for the sender avatar.
  final CometChatAvatarStyle? messageBubbleAvatarStyle;

  /// Background image for the message bubble.
  final DecorationImage? messageBubbleBackgroundImage;

  static CometChatAIAssistantBubbleStyle of(BuildContext context) =>
      const CometChatAIAssistantBubbleStyle();

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
      messageBubbleAvatarStyle:
          messageBubbleAvatarStyle ?? this.messageBubbleAvatarStyle,
      messageBubbleBackgroundImage:
          messageBubbleBackgroundImage ?? this.messageBubbleBackgroundImage,
    );
  }

  CometChatAIAssistantBubbleStyle merge(
    CometChatAIAssistantBubbleStyle? style,
  ) {
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
  CometChatAIAssistantBubbleStyle lerp(
    CometChatAIAssistantBubbleStyle? other,
    double t,
  ) {
    return CometChatAIAssistantBubbleStyle(
      textStyle: TextStyle.lerp(textStyle, other?.textStyle, t),
      borderRadius: BorderRadiusGeometry.lerp(
        borderRadius,
        other?.borderRadius,
        t,
      ),
      textColor: Color.lerp(textColor, other?.textColor, t),
      backgroundColor: Color.lerp(backgroundColor, other?.backgroundColor, t),
      messageBubbleAvatarStyle: messageBubbleAvatarStyle?.lerp(
        other?.messageBubbleAvatarStyle,
        t,
      ),
      messageBubbleBackgroundImage: DecorationImage.lerp(
        messageBubbleBackgroundImage,
        other?.messageBubbleBackgroundImage,
        t,
      ),
    );
  }
}
