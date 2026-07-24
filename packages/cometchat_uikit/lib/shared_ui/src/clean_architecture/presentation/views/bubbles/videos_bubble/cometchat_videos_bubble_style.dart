import 'package:flutter/material.dart';

///[CometChatVideosBubbleStyle] styles the multi-attachment video message
///bubble — the grid fields (tile corners, spacing, placeholder, "+N"
///overflow) plus the video-specific chrome: the centered play badge, the
///bottom file-name strip, the m:ss duration chip (and its
///[showVideoDuration] toggle) and the caption below the grid. Null fields
///fall back to the bubble's defaults. Registered as a [ThemeExtension] it
///applies app-wide; passed as the bubble's `style:` it applies per instance
///(widget values win). Supports [merge] like every other UIKit style class.
class CometChatVideosBubbleStyle
    extends ThemeExtension<CometChatVideosBubbleStyle> {
  const CometChatVideosBubbleStyle({
    this.tileBorderRadius,
    this.gridSpacing,
    this.placeholderColor,
    this.playIconBackgroundColor,
    this.playIconColor,
    this.nameTextStyle,
    this.durationChipBackgroundColor,
    this.durationChipTextStyle,
    this.showVideoDuration,
    this.overflowScrimColor,
    this.overflowTextStyle,
    this.captionTextStyle,
  });

  ///[tileBorderRadius] corner radius of each grid tile.
  final double? tileBorderRadius;

  ///[gridSpacing] gap between grid tiles.
  final double? gridSpacing;

  ///[placeholderColor] fill of a tile with no poster frame yet.
  final Color? placeholderColor;

  ///[playIconBackgroundColor] the centered play badge circle.
  final Color? playIconBackgroundColor;

  ///[playIconColor] the play glyph inside the badge.
  final Color? playIconColor;

  ///[nameTextStyle] the file-name strip along the tile bottom.
  final TextStyle? nameTextStyle;

  ///[durationChipBackgroundColor] the bottom-start m:ss pill.
  final Color? durationChipBackgroundColor;

  ///[durationChipTextStyle] the m:ss text.
  final TextStyle? durationChipTextStyle;

  ///[showVideoDuration] hides the m:ss pill when false (default true).
  final bool? showVideoDuration;

  ///[overflowScrimColor] the scrim behind "+N" on the overflow tile.
  final Color? overflowScrimColor;

  ///[overflowTextStyle] the "+N" text on the overflow tile.
  final TextStyle? overflowTextStyle;

  ///[captionTextStyle] overrides for the caption text under the grid.
  final TextStyle? captionTextStyle;

  static CometChatVideosBubbleStyle of(BuildContext context) =>
      const CometChatVideosBubbleStyle();

  @override
  CometChatVideosBubbleStyle copyWith({
    double? tileBorderRadius,
    double? gridSpacing,
    Color? placeholderColor,
    Color? playIconBackgroundColor,
    Color? playIconColor,
    TextStyle? nameTextStyle,
    Color? durationChipBackgroundColor,
    TextStyle? durationChipTextStyle,
    bool? showVideoDuration,
    Color? overflowScrimColor,
    TextStyle? overflowTextStyle,
    TextStyle? captionTextStyle,
  }) {
    return CometChatVideosBubbleStyle(
      tileBorderRadius: tileBorderRadius ?? this.tileBorderRadius,
      gridSpacing: gridSpacing ?? this.gridSpacing,
      placeholderColor: placeholderColor ?? this.placeholderColor,
      playIconBackgroundColor:
          playIconBackgroundColor ?? this.playIconBackgroundColor,
      playIconColor: playIconColor ?? this.playIconColor,
      nameTextStyle: nameTextStyle ?? this.nameTextStyle,
      durationChipBackgroundColor:
          durationChipBackgroundColor ?? this.durationChipBackgroundColor,
      durationChipTextStyle:
          durationChipTextStyle ?? this.durationChipTextStyle,
      showVideoDuration: showVideoDuration ?? this.showVideoDuration,
      overflowScrimColor: overflowScrimColor ?? this.overflowScrimColor,
      overflowTextStyle: overflowTextStyle ?? this.overflowTextStyle,
      captionTextStyle: captionTextStyle ?? this.captionTextStyle,
    );
  }

  CometChatVideosBubbleStyle merge(CometChatVideosBubbleStyle? style) {
    if (style == null) return this;
    return copyWith(
      tileBorderRadius: style.tileBorderRadius,
      gridSpacing: style.gridSpacing,
      placeholderColor: style.placeholderColor,
      playIconBackgroundColor: style.playIconBackgroundColor,
      playIconColor: style.playIconColor,
      nameTextStyle: style.nameTextStyle,
      durationChipBackgroundColor: style.durationChipBackgroundColor,
      durationChipTextStyle: style.durationChipTextStyle,
      showVideoDuration: style.showVideoDuration,
      overflowScrimColor: style.overflowScrimColor,
      overflowTextStyle: style.overflowTextStyle,
      captionTextStyle: style.captionTextStyle,
    );
  }

  @override
  CometChatVideosBubbleStyle lerp(
    ThemeExtension<CometChatVideosBubbleStyle>? other,
    double t,
  ) {
    if (other is! CometChatVideosBubbleStyle) return this;
    return CometChatVideosBubbleStyle(
      tileBorderRadius: t < 0.5 ? tileBorderRadius : other.tileBorderRadius,
      gridSpacing: t < 0.5 ? gridSpacing : other.gridSpacing,
      placeholderColor: Color.lerp(placeholderColor, other.placeholderColor, t),
      playIconBackgroundColor: Color.lerp(
        playIconBackgroundColor,
        other.playIconBackgroundColor,
        t,
      ),
      playIconColor: Color.lerp(playIconColor, other.playIconColor, t),
      nameTextStyle: TextStyle.lerp(nameTextStyle, other.nameTextStyle, t),
      durationChipBackgroundColor: Color.lerp(
        durationChipBackgroundColor,
        other.durationChipBackgroundColor,
        t,
      ),
      durationChipTextStyle: TextStyle.lerp(
        durationChipTextStyle,
        other.durationChipTextStyle,
        t,
      ),
      showVideoDuration: t < 0.5 ? showVideoDuration : other.showVideoDuration,
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
