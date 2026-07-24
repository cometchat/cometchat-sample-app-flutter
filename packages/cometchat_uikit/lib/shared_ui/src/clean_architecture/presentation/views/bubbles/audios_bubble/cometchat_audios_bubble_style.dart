import 'package:flutter/material.dart';

///[CometChatAudiosBubbleStyle] styles the multi-attachment audio message
///bubble's inline player rows — the play circle, seek slider, name/clock text
///and the download affordance. Null fields fall back to the row's
///alignment-aware theme defaults. Supports [merge] like every other UIKit
///style class.
class CometChatAudiosBubbleStyle
    extends ThemeExtension<CometChatAudiosBubbleStyle> {
  const CometChatAudiosBubbleStyle({
    this.rowBackgroundColor,
    this.rowBorderRadius,
    this.rowSpacing,
    this.playIconBackgroundColor,
    this.playIconColor,
    this.sliderActiveColor,
    this.sliderInactiveColor,
    this.sliderThumbColor,
    this.nameTextStyle,
    this.durationTextStyle,
    this.downloadIconColor,
    this.captionTextStyle,
  });

  ///[rowBackgroundColor] each player row's fill (applies to both alignments
  ///when set; null keeps the incoming/outgoing defaults).
  final Color? rowBackgroundColor;

  ///[rowBorderRadius] outer corner radius of the row stack.
  final double? rowBorderRadius;

  ///[rowSpacing] vertical gap between stacked player rows.
  final double? rowSpacing;

  ///[playIconBackgroundColor] the play/pause circle.
  final Color? playIconBackgroundColor;

  ///[playIconColor] the play/pause glyph (and busy spinner).
  final Color? playIconColor;

  ///[sliderActiveColor] the played track segment.
  final Color? sliderActiveColor;

  ///[sliderInactiveColor] the remaining track segment.
  final Color? sliderInactiveColor;

  ///[sliderThumbColor] the seek knob.
  final Color? sliderThumbColor;

  ///[nameTextStyle] the file name.
  final TextStyle? nameTextStyle;

  ///[durationTextStyle] the "pos/dur" clock under the slider.
  final TextStyle? durationTextStyle;

  ///[downloadIconColor] the trailing ↓ button shown while uncached.
  final Color? downloadIconColor;

  ///[captionTextStyle] overrides for the caption text under the row stack.
  final TextStyle? captionTextStyle;

  static CometChatAudiosBubbleStyle of(BuildContext context) =>
      const CometChatAudiosBubbleStyle();

  @override
  CometChatAudiosBubbleStyle copyWith({
    Color? rowBackgroundColor,
    double? rowBorderRadius,
    double? rowSpacing,
    Color? playIconBackgroundColor,
    Color? playIconColor,
    Color? sliderActiveColor,
    Color? sliderInactiveColor,
    Color? sliderThumbColor,
    TextStyle? nameTextStyle,
    TextStyle? durationTextStyle,
    Color? downloadIconColor,
    TextStyle? captionTextStyle,
  }) {
    return CometChatAudiosBubbleStyle(
      rowBackgroundColor: rowBackgroundColor ?? this.rowBackgroundColor,
      rowBorderRadius: rowBorderRadius ?? this.rowBorderRadius,
      rowSpacing: rowSpacing ?? this.rowSpacing,
      playIconBackgroundColor:
          playIconBackgroundColor ?? this.playIconBackgroundColor,
      playIconColor: playIconColor ?? this.playIconColor,
      sliderActiveColor: sliderActiveColor ?? this.sliderActiveColor,
      sliderInactiveColor: sliderInactiveColor ?? this.sliderInactiveColor,
      sliderThumbColor: sliderThumbColor ?? this.sliderThumbColor,
      nameTextStyle: nameTextStyle ?? this.nameTextStyle,
      durationTextStyle: durationTextStyle ?? this.durationTextStyle,
      downloadIconColor: downloadIconColor ?? this.downloadIconColor,
      captionTextStyle: captionTextStyle ?? this.captionTextStyle,
    );
  }

  CometChatAudiosBubbleStyle merge(CometChatAudiosBubbleStyle? style) {
    if (style == null) return this;
    return copyWith(
      rowBackgroundColor: style.rowBackgroundColor,
      rowBorderRadius: style.rowBorderRadius,
      rowSpacing: style.rowSpacing,
      playIconBackgroundColor: style.playIconBackgroundColor,
      playIconColor: style.playIconColor,
      sliderActiveColor: style.sliderActiveColor,
      sliderInactiveColor: style.sliderInactiveColor,
      sliderThumbColor: style.sliderThumbColor,
      nameTextStyle: style.nameTextStyle,
      durationTextStyle: style.durationTextStyle,
      downloadIconColor: style.downloadIconColor,
      captionTextStyle: style.captionTextStyle,
    );
  }

  @override
  CometChatAudiosBubbleStyle lerp(
    ThemeExtension<CometChatAudiosBubbleStyle>? other,
    double t,
  ) {
    if (other is! CometChatAudiosBubbleStyle) return this;
    return CometChatAudiosBubbleStyle(
      rowBackgroundColor: Color.lerp(
        rowBackgroundColor,
        other.rowBackgroundColor,
        t,
      ),
      rowBorderRadius: t < 0.5 ? rowBorderRadius : other.rowBorderRadius,
      rowSpacing: t < 0.5 ? rowSpacing : other.rowSpacing,
      playIconBackgroundColor: Color.lerp(
        playIconBackgroundColor,
        other.playIconBackgroundColor,
        t,
      ),
      playIconColor: Color.lerp(playIconColor, other.playIconColor, t),
      sliderActiveColor: Color.lerp(
        sliderActiveColor,
        other.sliderActiveColor,
        t,
      ),
      sliderInactiveColor: Color.lerp(
        sliderInactiveColor,
        other.sliderInactiveColor,
        t,
      ),
      sliderThumbColor: Color.lerp(sliderThumbColor, other.sliderThumbColor, t),
      nameTextStyle: TextStyle.lerp(nameTextStyle, other.nameTextStyle, t),
      durationTextStyle: TextStyle.lerp(
        durationTextStyle,
        other.durationTextStyle,
        t,
      ),
      downloadIconColor: Color.lerp(
        downloadIconColor,
        other.downloadIconColor,
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
