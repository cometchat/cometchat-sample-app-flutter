
import 'package:flutter/material.dart';
import '../../../../../../cometchat_uikit_shared.dart';

///[CometChatMessageBubbleStyle] is a data class that has styling-related properties
///to customize the appearance of [CometChatMessageBubble]
///
/// ```dart
/// CometChatMessageBubbleStyle(
/// backgroundImage: DecorationImage(),
/// backgroundColor: Colors.white,
/// border: Border.all(color: Colors.red),
/// borderRadius: BorderRadius.circular(10),
/// )
/// ```
class CometChatMessageBubbleStyle extends ThemeExtension<CometChatMessageBubbleStyle> {
  ///[CometChatMessageBubbleStyle] constructor requires [width], [height], [background], [border], [borderRadius], [gradient] and [padding] while initializing.
  const CometChatMessageBubbleStyle(
      {this.backgroundImage,
      this.backgroundColor,
      this.border,
      this.borderRadius
      });


  ///[backgroundImage] provides background image to the message bubble
  final DecorationImage? backgroundImage;

  ///[backgroundColor] provides background color to the message bubble
  final Color? backgroundColor;

  ///[border] provides border to the message bubble
  final BoxBorder? border;

  ///[borderRadius] provides border radius to the message bubble
  final BorderRadiusGeometry? borderRadius;

  @override
  CometChatMessageBubbleStyle copyWith({
    DecorationImage? messageBubbleBackgroundImage,
    Color? backgroundColor,
    BoxBorder? border,
    BorderRadiusGeometry? borderRadius,
    double? widthFlex,
    EdgeInsets? contentPadding,
  }) {
    return CometChatMessageBubbleStyle(
      backgroundImage: messageBubbleBackgroundImage ?? backgroundImage,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      border: border ?? this.border,
      borderRadius: borderRadius ?? this.borderRadius,
    );
  }

  @override
  CometChatMessageBubbleStyle lerp(CometChatMessageBubbleStyle? other, double t) {
    if (other == null) return this;
    return CometChatMessageBubbleStyle(
      backgroundImage: other.backgroundImage ?? backgroundImage,
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t),
      border: BoxBorder.lerp(border, other.border, t),
      borderRadius: BorderRadiusGeometry.lerp(borderRadius, other.borderRadius, t),
    );
  }

  static CometChatMessageBubbleStyle of(BuildContext context) => const CometChatMessageBubbleStyle();

  CometChatMessageBubbleStyle merge(CometChatMessageBubbleStyle? style) {
    if (style == null) return this;
    return copyWith(
      messageBubbleBackgroundImage: style.backgroundImage,
      backgroundColor: style.backgroundColor,
      border: style.border,
      borderRadius: style.borderRadius,
    );
  }

}
