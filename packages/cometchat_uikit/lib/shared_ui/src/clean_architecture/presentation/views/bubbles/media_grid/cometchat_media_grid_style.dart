import 'package:flutter/material.dart';

/// How the 3-image grid arranges its cells inside the square bubble.
/// [auto] picks [heroTop] or [heroLeft] from the hero image's aspect ratio
/// (a wide/landscape hero goes on top; a tall/portrait hero goes on the left).
enum MediaGridTripleLayout { auto, heroTop, heroLeft }

///[CometChatMediaGridStyle] styles the count-based media grid used by
///[CometChatImagesBubble] and [CometChatVideosBubble] — cell corners, the
///video play badge, the m:ss duration chip, the video file-name strip and the
///"+N" overflow cell. Null fields fall back to the grid's defaults. Supports
///[merge] like every other UIKit style class.
class CometChatMediaGridStyle extends ThemeExtension<CometChatMediaGridStyle> {
  const CometChatMediaGridStyle({
    this.cellBorderRadius,
    this.placeholderColor,
    this.playBadgeBackgroundColor,
    this.playBadgeIconColor,
    this.durationChipBackgroundColor,
    this.durationChipTextStyle,
    this.nameTextStyle,
    this.overflowTextStyle,
    this.overflowScrimColor,
    this.showVideoDuration,
    this.tripleLayout,
    this.heroFraction,
  });

  ///[cellBorderRadius] corner radius of each grid cell.
  final double? cellBorderRadius;

  ///[placeholderColor] fill of a cell with nothing to show yet — an image that
  ///failed to load, or a video with no poster frame.
  final Color? placeholderColor;

  ///[playBadgeBackgroundColor] the centered play badge circle on video cells.
  final Color? playBadgeBackgroundColor;

  ///[playBadgeIconColor] the play glyph.
  final Color? playBadgeIconColor;

  ///[durationChipBackgroundColor] the bottom-start m:ss pill on video cells.
  final Color? durationChipBackgroundColor;

  ///[durationChipTextStyle] the m:ss text.
  final TextStyle? durationChipTextStyle;

  ///[nameTextStyle] the video file-name strip along the cell bottom.
  final TextStyle? nameTextStyle;

  ///[overflowTextStyle] the "+N" text on the overflow cell.
  final TextStyle? overflowTextStyle;

  ///[overflowScrimColor] the dark scrim behind "+N".
  final Color? overflowScrimColor;

  ///[showVideoDuration] hides the m:ss pill when false (default true).
  final bool? showVideoDuration;

  ///[tripleLayout] arrangement of the 3-image grid (default [MediaGridTripleLayout.auto],
  ///which decides from the hero image's aspect ratio).
  final MediaGridTripleLayout? tripleLayout;

  ///[heroFraction] the hero cell's share of the square bubble in the 3-image
  ///grid (0..1, default 0.6). Applies to the [heroTop]/[heroLeft] layouts.
  final double? heroFraction;

  static CometChatMediaGridStyle of(BuildContext context) =>
      const CometChatMediaGridStyle();

  @override
  CometChatMediaGridStyle copyWith({
    double? cellBorderRadius,
    Color? placeholderColor,
    Color? playBadgeBackgroundColor,
    Color? playBadgeIconColor,
    Color? durationChipBackgroundColor,
    TextStyle? durationChipTextStyle,
    TextStyle? nameTextStyle,
    TextStyle? overflowTextStyle,
    Color? overflowScrimColor,
    bool? showVideoDuration,
    MediaGridTripleLayout? tripleLayout,
    double? heroFraction,
  }) {
    return CometChatMediaGridStyle(
      tripleLayout: tripleLayout ?? this.tripleLayout,
      heroFraction: heroFraction ?? this.heroFraction,
      cellBorderRadius: cellBorderRadius ?? this.cellBorderRadius,
      placeholderColor: placeholderColor ?? this.placeholderColor,
      playBadgeBackgroundColor:
          playBadgeBackgroundColor ?? this.playBadgeBackgroundColor,
      playBadgeIconColor: playBadgeIconColor ?? this.playBadgeIconColor,
      durationChipBackgroundColor:
          durationChipBackgroundColor ?? this.durationChipBackgroundColor,
      durationChipTextStyle:
          durationChipTextStyle ?? this.durationChipTextStyle,
      nameTextStyle: nameTextStyle ?? this.nameTextStyle,
      overflowTextStyle: overflowTextStyle ?? this.overflowTextStyle,
      overflowScrimColor: overflowScrimColor ?? this.overflowScrimColor,
      showVideoDuration: showVideoDuration ?? this.showVideoDuration,
    );
  }

  CometChatMediaGridStyle merge(CometChatMediaGridStyle? style) {
    if (style == null) return this;
    return copyWith(
      tripleLayout: style.tripleLayout,
      heroFraction: style.heroFraction,
      cellBorderRadius: style.cellBorderRadius,
      placeholderColor: style.placeholderColor,
      playBadgeBackgroundColor: style.playBadgeBackgroundColor,
      playBadgeIconColor: style.playBadgeIconColor,
      durationChipBackgroundColor: style.durationChipBackgroundColor,
      durationChipTextStyle: style.durationChipTextStyle,
      nameTextStyle: style.nameTextStyle,
      overflowTextStyle: style.overflowTextStyle,
      overflowScrimColor: style.overflowScrimColor,
      showVideoDuration: style.showVideoDuration,
    );
  }

  @override
  CometChatMediaGridStyle lerp(
    ThemeExtension<CometChatMediaGridStyle>? other,
    double t,
  ) {
    if (other is! CometChatMediaGridStyle) return this;
    return CometChatMediaGridStyle(
      tripleLayout: t < 0.5 ? tripleLayout : other.tripleLayout,
      heroFraction: t < 0.5 ? heroFraction : other.heroFraction,
      cellBorderRadius: t < 0.5 ? cellBorderRadius : other.cellBorderRadius,
      placeholderColor: Color.lerp(placeholderColor, other.placeholderColor, t),
      playBadgeBackgroundColor: Color.lerp(
        playBadgeBackgroundColor,
        other.playBadgeBackgroundColor,
        t,
      ),
      playBadgeIconColor: Color.lerp(
        playBadgeIconColor,
        other.playBadgeIconColor,
        t,
      ),
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
      nameTextStyle: TextStyle.lerp(nameTextStyle, other.nameTextStyle, t),
      overflowTextStyle: TextStyle.lerp(
        overflowTextStyle,
        other.overflowTextStyle,
        t,
      ),
      overflowScrimColor: Color.lerp(
        overflowScrimColor,
        other.overflowScrimColor,
        t,
      ),
      showVideoDuration: t < 0.5 ? showVideoDuration : other.showVideoDuration,
    );
  }
}
