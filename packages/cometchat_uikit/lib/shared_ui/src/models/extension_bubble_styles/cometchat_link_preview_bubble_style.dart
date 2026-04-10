import 'package:flutter/material.dart';

///[CometChatLinkPreviewBubbleStyle] is a data class that has styling-related properties
///to customize the appearance of [CometChatLinkPreviewBubble]
///
/// ```dart
/// CometChatLinkPreviewBubbleStyle(
///  titleStyle: TextStyle(
///  color: Colors.white,
///  fontWeight: FontWeight.bold,
///  fontSize: 16),
///  urlStyle: TextStyle(
///  color: Colors.white,
///  fontSize: 14),
///  tileColor: Colors.grey,
///  backgroundColor: Colors.black,
///  );
///  ```
class CometChatLinkPreviewBubbleStyle extends ThemeExtension<CometChatLinkPreviewBubbleStyle> {
  const CometChatLinkPreviewBubbleStyle(
      {this.titleStyle, this.urlStyle, this.tileColor, this.backgroundColor, this.descriptionStyle,
      this.borderRadius, this.border
      });

  ///[titleStyle] styles the name of the website
  final TextStyle? titleStyle;

  ///[urlStyle] styles the url link
  final TextStyle? urlStyle;

  ///[tileColor] changes the color of the tile containing website name, link and favicon
  final Color? tileColor;

  ///[backgroundColor] changes the color of the bubble
  final Color? backgroundColor;

  ///[descriptionStyle] styles the description of the website
  final TextStyle? descriptionStyle;

  ///[border] sets the border
  final BoxBorder? border;

  ///[borderRadius] sets the border radius
  final BorderRadius? borderRadius;

  @override
  CometChatLinkPreviewBubbleStyle copyWith(
      {TextStyle? titleStyle,
      TextStyle? urlStyle,
      Color? tileColor,
      Color? backgroundColor,
        TextStyle? descriptionStyle,
      BoxBorder? border,
      BorderRadius? borderRadius
      }) {
    return CometChatLinkPreviewBubbleStyle(
        titleStyle: titleStyle ?? this.titleStyle,
        urlStyle: urlStyle ?? this.urlStyle,
        tileColor: tileColor ?? this.tileColor,
        backgroundColor: backgroundColor ?? this.backgroundColor,
        descriptionStyle: descriptionStyle ?? this.descriptionStyle,
        border: border ?? this.border,
        borderRadius: borderRadius ?? this.borderRadius
    );
  }

  CometChatLinkPreviewBubbleStyle merge(CometChatLinkPreviewBubbleStyle? other) {
    if (other == null) return this;
    return copyWith(
      titleStyle: other.titleStyle,
      urlStyle: other.urlStyle,
      tileColor: other.tileColor,
      backgroundColor: other.backgroundColor,
      descriptionStyle: other.descriptionStyle,
      border: other.border,
      borderRadius: other.borderRadius
    );
  }

 static CometChatLinkPreviewBubbleStyle of(BuildContext context) {
    return const CometChatLinkPreviewBubbleStyle();
  }

  @override
  CometChatLinkPreviewBubbleStyle lerp(CometChatLinkPreviewBubbleStyle? other, double t) {
    return CometChatLinkPreviewBubbleStyle(
      titleStyle: TextStyle.lerp(titleStyle, other?.titleStyle, t),
      urlStyle: TextStyle.lerp(urlStyle, other?.urlStyle, t),
      tileColor: Color.lerp(tileColor, other?.tileColor, t),
      backgroundColor: Color.lerp(backgroundColor, other?.backgroundColor, t),
      descriptionStyle: TextStyle.lerp(descriptionStyle, other?.descriptionStyle, t),
      border: BoxBorder.lerp(border, other?.border, t),
      borderRadius: BorderRadius.lerp(borderRadius, other?.borderRadius, t)
    );
  }
}
