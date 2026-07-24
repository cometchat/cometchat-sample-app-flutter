import 'package:flutter/material.dart';

///[CometChatFilesBubbleStyle] styles the multi-attachment file message bubble —
///the stacked file cards (background, radius, spacing, icon plate, name/meta
///text, the busy/download spinner tint), the "+N more / Show less" toggle and
///the caption below the stack. Null fields fall back to the bubble's
///alignment-aware theme defaults. Registered as a [ThemeExtension] it applies
///app-wide; passed as the bubble's `style:` it applies per instance (widget
///values win). Supports [merge] like every other UIKit style class.
class CometChatFilesBubbleStyle
    extends ThemeExtension<CometChatFilesBubbleStyle> {
  const CometChatFilesBubbleStyle({
    this.backgroundColor,
    this.cardBorderRadius,
    this.cardSpacing,
    this.iconPlateColor,
    this.titleTextStyle,
    this.subtitleTextStyle,
    this.downloadIconTint,
    this.toggleTextStyle,
    this.captionTextStyle,
  });

  ///[backgroundColor] each file card's fill (applies to both alignments
  ///when set; null keeps the incoming/outgoing defaults).
  final Color? backgroundColor;

  ///[cardBorderRadius] outer corner radius of the card stack.
  final double? cardBorderRadius;

  ///[cardSpacing] vertical gap between stacked cards.
  final double? cardSpacing;

  ///[iconPlateColor] fill behind the leading file-type icon (default: none —
  ///the coloured badge sits directly on the card).
  final Color? iconPlateColor;

  ///[titleTextStyle] the file name.
  final TextStyle? titleTextStyle;

  ///[subtitleTextStyle] the "size • TYPE" line.
  final TextStyle? subtitleTextStyle;

  ///[downloadIconTint] tint of the busy spinner shown while a tapped card
  ///downloads / opens.
  final Color? downloadIconTint;

  ///[toggleTextStyle] the "+N more" / "Show less" toggle.
  final TextStyle? toggleTextStyle;

  ///[captionTextStyle] overrides for the caption text under the card stack.
  final TextStyle? captionTextStyle;

  static CometChatFilesBubbleStyle of(BuildContext context) =>
      const CometChatFilesBubbleStyle();

  @override
  CometChatFilesBubbleStyle copyWith({
    Color? backgroundColor,
    double? cardBorderRadius,
    double? cardSpacing,
    Color? iconPlateColor,
    TextStyle? titleTextStyle,
    TextStyle? subtitleTextStyle,
    Color? downloadIconTint,
    TextStyle? toggleTextStyle,
    TextStyle? captionTextStyle,
  }) {
    return CometChatFilesBubbleStyle(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      cardBorderRadius: cardBorderRadius ?? this.cardBorderRadius,
      cardSpacing: cardSpacing ?? this.cardSpacing,
      iconPlateColor: iconPlateColor ?? this.iconPlateColor,
      titleTextStyle: titleTextStyle ?? this.titleTextStyle,
      subtitleTextStyle: subtitleTextStyle ?? this.subtitleTextStyle,
      downloadIconTint: downloadIconTint ?? this.downloadIconTint,
      toggleTextStyle: toggleTextStyle ?? this.toggleTextStyle,
      captionTextStyle: captionTextStyle ?? this.captionTextStyle,
    );
  }

  CometChatFilesBubbleStyle merge(CometChatFilesBubbleStyle? style) {
    if (style == null) return this;
    return copyWith(
      backgroundColor: style.backgroundColor,
      cardBorderRadius: style.cardBorderRadius,
      cardSpacing: style.cardSpacing,
      iconPlateColor: style.iconPlateColor,
      titleTextStyle: style.titleTextStyle,
      subtitleTextStyle: style.subtitleTextStyle,
      downloadIconTint: style.downloadIconTint,
      toggleTextStyle: style.toggleTextStyle,
      captionTextStyle: style.captionTextStyle,
    );
  }

  @override
  CometChatFilesBubbleStyle lerp(
    ThemeExtension<CometChatFilesBubbleStyle>? other,
    double t,
  ) {
    if (other is! CometChatFilesBubbleStyle) return this;
    return CometChatFilesBubbleStyle(
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t),
      cardBorderRadius: t < 0.5 ? cardBorderRadius : other.cardBorderRadius,
      cardSpacing: t < 0.5 ? cardSpacing : other.cardSpacing,
      iconPlateColor: Color.lerp(iconPlateColor, other.iconPlateColor, t),
      titleTextStyle: TextStyle.lerp(titleTextStyle, other.titleTextStyle, t),
      subtitleTextStyle: TextStyle.lerp(
        subtitleTextStyle,
        other.subtitleTextStyle,
        t,
      ),
      downloadIconTint: Color.lerp(downloadIconTint, other.downloadIconTint, t),
      toggleTextStyle: TextStyle.lerp(
        toggleTextStyle,
        other.toggleTextStyle,
        t,
      ),
      captionTextStyle: TextStyle.lerp(
        captionTextStyle,
        other.captionTextStyle,
        t,
      ),
    );
  }
}
