import 'package:flutter/material.dart';

///[CometChatImagesBubbleStyle] styles the multi-attachment image message
///bubble — grid tile corners and spacing, the load-failure placeholder, the
///"+N" overflow overlay and the caption below the grid. Null fields fall back
///to the bubble's defaults. Registered as a [ThemeExtension] it applies
///app-wide; passed as the bubble's `style:` it applies per instance (widget
///values win). Supports [merge] like every other UIKit style class.
class CometChatImagesBubbleStyle
    extends ThemeExtension<CometChatImagesBubbleStyle> {
  const CometChatImagesBubbleStyle({
    this.tileBorderRadius,
    this.gridSpacing,
    this.placeholderColor,
    this.overflowScrimColor,
    this.overflowTextStyle,
    this.captionTextStyle,
  });

  ///[tileBorderRadius] corner radius of each grid tile.
  final double? tileBorderRadius;

  ///[gridSpacing] gap between grid tiles.
  final double? gridSpacing;

  ///[placeholderColor] fill of a tile whose image failed to load.
  final Color? placeholderColor;

  ///[overflowScrimColor] the scrim behind "+N" on the overflow tile.
  final Color? overflowScrimColor;

  ///[overflowTextStyle] the "+N" text on the overflow tile.
  final TextStyle? overflowTextStyle;

  ///[captionTextStyle] overrides for the caption text under the grid.
  final TextStyle? captionTextStyle;

  static CometChatImagesBubbleStyle of(BuildContext context) =>
      const CometChatImagesBubbleStyle();

  @override
  CometChatImagesBubbleStyle copyWith({
    double? tileBorderRadius,
    double? gridSpacing,
    Color? placeholderColor,
    Color? overflowScrimColor,
    TextStyle? overflowTextStyle,
    TextStyle? captionTextStyle,
  }) {
    return CometChatImagesBubbleStyle(
      tileBorderRadius: tileBorderRadius ?? this.tileBorderRadius,
      gridSpacing: gridSpacing ?? this.gridSpacing,
      placeholderColor: placeholderColor ?? this.placeholderColor,
      overflowScrimColor: overflowScrimColor ?? this.overflowScrimColor,
      overflowTextStyle: overflowTextStyle ?? this.overflowTextStyle,
      captionTextStyle: captionTextStyle ?? this.captionTextStyle,
    );
  }

  CometChatImagesBubbleStyle merge(CometChatImagesBubbleStyle? style) {
    if (style == null) return this;
    return copyWith(
      tileBorderRadius: style.tileBorderRadius,
      gridSpacing: style.gridSpacing,
      placeholderColor: style.placeholderColor,
      overflowScrimColor: style.overflowScrimColor,
      overflowTextStyle: style.overflowTextStyle,
      captionTextStyle: style.captionTextStyle,
    );
  }

  @override
  CometChatImagesBubbleStyle lerp(
    ThemeExtension<CometChatImagesBubbleStyle>? other,
    double t,
  ) {
    if (other is! CometChatImagesBubbleStyle) return this;
    return CometChatImagesBubbleStyle(
      tileBorderRadius: t < 0.5 ? tileBorderRadius : other.tileBorderRadius,
      gridSpacing: t < 0.5 ? gridSpacing : other.gridSpacing,
      placeholderColor: Color.lerp(placeholderColor, other.placeholderColor, t),
      overflowScrimColor: Color.lerp(
        overflowScrimColor,
        other.overflowScrimColor,
        t,
      ),
      overflowTextStyle: TextStyle.lerp(
        overflowTextStyle,
        other.overflowTextStyle,
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
