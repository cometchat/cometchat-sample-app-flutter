import 'package:flutter/material.dart';

///[CometChatAttachmentTrayStyle] styles the composer's attachment staging tray
///and its tiles (media thumbnails, the audio player card and the file card).
///All fields are optional — null falls back to the tray's theme-driven
///defaults. Supports [merge] like every other UIKit style class.
/// ```dart
/// CometChatAttachmentTrayStyle(
///   tileBackgroundColor: Colors.white,
///   errorBorderColor: Colors.red,
/// );
/// ```
class CometChatAttachmentTrayStyle
    extends ThemeExtension<CometChatAttachmentTrayStyle> {
  const CometChatAttachmentTrayStyle({
    this.tileBackgroundColor,
    this.tileBorderColor,
    this.errorBorderColor,
    this.tileBorderRadius,
    this.iconBorderRadius,
    this.nameTextStyle,
    this.subtitleTextStyle,
    this.errorTextStyle,
    this.scrimColor,
    this.progressColor,
    this.removeBadgeBackgroundColor,
    this.removeBadgeIconColor,
    this.playButtonColor,
    this.playIconColor,
    this.sliderActiveColor,
    this.sliderInactiveColor,
    this.clockTextStyle,
    this.durationChipBackgroundColor,
    this.durationChipTextStyle,
    this.showVideoDuration,
  });

  ///[tileBackgroundColor] background of the file / audio cards.
  final Color? tileBackgroundColor;

  ///[tileBorderColor] card border in the default (non-error) states.
  final Color? tileBorderColor;

  ///[errorBorderColor] card border in the failed / rejected states.
  final Color? errorBorderColor;

  ///[tileBorderRadius] corner radius of the tiles/cards.
  final double? tileBorderRadius;

  ///[iconBorderRadius] corner radius of the leading type-icon container.
  final double? iconBorderRadius;

  ///[nameTextStyle] file name text on the cards.
  final TextStyle? nameTextStyle;

  ///[subtitleTextStyle] type subtitle ("PDF") on the file card.
  final TextStyle? subtitleTextStyle;

  ///[errorTextStyle] "Upload failed" / "Tap to retry" subtitle.
  final TextStyle? errorTextStyle;

  ///[scrimColor] dark overlay behind the upload state indicators.
  final Color? scrimColor;

  ///[progressColor] the upload progress spinner.
  final Color? progressColor;

  ///[removeBadgeBackgroundColor] the ✕ badge circle.
  final Color? removeBadgeBackgroundColor;

  ///[removeBadgeIconColor] the ✕ glyph.
  final Color? removeBadgeIconColor;

  ///[playButtonColor] the audio tile's play/pause circle.
  final Color? playButtonColor;

  ///[playIconColor] the audio tile's play/pause glyph.
  final Color? playIconColor;

  ///[sliderActiveColor] the audio tile's played track segment.
  final Color? sliderActiveColor;

  ///[sliderInactiveColor] the audio tile's remaining track segment.
  final Color? sliderInactiveColor;

  ///[clockTextStyle] the audio tile's "pos/total" clock.
  final TextStyle? clockTextStyle;

  ///[durationChipBackgroundColor] the video thumbnail's m:ss pill.
  final Color? durationChipBackgroundColor;

  ///[durationChipTextStyle] the video thumbnail's m:ss text.
  final TextStyle? durationChipTextStyle;

  ///[showVideoDuration] hides the video m:ss pill when false (default true).
  final bool? showVideoDuration;

  static CometChatAttachmentTrayStyle of(BuildContext context) =>
      const CometChatAttachmentTrayStyle();

  @override
  CometChatAttachmentTrayStyle copyWith({
    Color? tileBackgroundColor,
    Color? tileBorderColor,
    Color? errorBorderColor,
    double? tileBorderRadius,
    double? iconBorderRadius,
    TextStyle? nameTextStyle,
    TextStyle? subtitleTextStyle,
    TextStyle? errorTextStyle,
    Color? scrimColor,
    Color? progressColor,
    Color? removeBadgeBackgroundColor,
    Color? removeBadgeIconColor,
    Color? playButtonColor,
    Color? playIconColor,
    Color? sliderActiveColor,
    Color? sliderInactiveColor,
    TextStyle? clockTextStyle,
    Color? durationChipBackgroundColor,
    TextStyle? durationChipTextStyle,
    bool? showVideoDuration,
  }) {
    return CometChatAttachmentTrayStyle(
      tileBackgroundColor: tileBackgroundColor ?? this.tileBackgroundColor,
      tileBorderColor: tileBorderColor ?? this.tileBorderColor,
      errorBorderColor: errorBorderColor ?? this.errorBorderColor,
      tileBorderRadius: tileBorderRadius ?? this.tileBorderRadius,
      iconBorderRadius: iconBorderRadius ?? this.iconBorderRadius,
      nameTextStyle: nameTextStyle ?? this.nameTextStyle,
      subtitleTextStyle: subtitleTextStyle ?? this.subtitleTextStyle,
      errorTextStyle: errorTextStyle ?? this.errorTextStyle,
      scrimColor: scrimColor ?? this.scrimColor,
      progressColor: progressColor ?? this.progressColor,
      removeBadgeBackgroundColor:
          removeBadgeBackgroundColor ?? this.removeBadgeBackgroundColor,
      removeBadgeIconColor: removeBadgeIconColor ?? this.removeBadgeIconColor,
      playButtonColor: playButtonColor ?? this.playButtonColor,
      playIconColor: playIconColor ?? this.playIconColor,
      sliderActiveColor: sliderActiveColor ?? this.sliderActiveColor,
      sliderInactiveColor: sliderInactiveColor ?? this.sliderInactiveColor,
      clockTextStyle: clockTextStyle ?? this.clockTextStyle,
      durationChipBackgroundColor:
          durationChipBackgroundColor ?? this.durationChipBackgroundColor,
      durationChipTextStyle:
          durationChipTextStyle ?? this.durationChipTextStyle,
      showVideoDuration: showVideoDuration ?? this.showVideoDuration,
    );
  }

  CometChatAttachmentTrayStyle merge(CometChatAttachmentTrayStyle? style) {
    if (style == null) return this;
    return copyWith(
      tileBackgroundColor: style.tileBackgroundColor,
      tileBorderColor: style.tileBorderColor,
      errorBorderColor: style.errorBorderColor,
      tileBorderRadius: style.tileBorderRadius,
      iconBorderRadius: style.iconBorderRadius,
      nameTextStyle: style.nameTextStyle,
      subtitleTextStyle: style.subtitleTextStyle,
      errorTextStyle: style.errorTextStyle,
      scrimColor: style.scrimColor,
      progressColor: style.progressColor,
      removeBadgeBackgroundColor: style.removeBadgeBackgroundColor,
      removeBadgeIconColor: style.removeBadgeIconColor,
      playButtonColor: style.playButtonColor,
      playIconColor: style.playIconColor,
      sliderActiveColor: style.sliderActiveColor,
      sliderInactiveColor: style.sliderInactiveColor,
      clockTextStyle: style.clockTextStyle,
      durationChipBackgroundColor: style.durationChipBackgroundColor,
      durationChipTextStyle: style.durationChipTextStyle,
      showVideoDuration: style.showVideoDuration,
    );
  }

  @override
  CometChatAttachmentTrayStyle lerp(
    ThemeExtension<CometChatAttachmentTrayStyle>? other,
    double t,
  ) {
    if (other is! CometChatAttachmentTrayStyle) return this;
    return CometChatAttachmentTrayStyle(
      tileBackgroundColor: Color.lerp(
        tileBackgroundColor,
        other.tileBackgroundColor,
        t,
      ),
      tileBorderColor: Color.lerp(tileBorderColor, other.tileBorderColor, t),
      errorBorderColor: Color.lerp(errorBorderColor, other.errorBorderColor, t),
      tileBorderRadius: t < 0.5 ? tileBorderRadius : other.tileBorderRadius,
      iconBorderRadius: t < 0.5 ? iconBorderRadius : other.iconBorderRadius,
      nameTextStyle: TextStyle.lerp(nameTextStyle, other.nameTextStyle, t),
      subtitleTextStyle: TextStyle.lerp(
        subtitleTextStyle,
        other.subtitleTextStyle,
        t,
      ),
      errorTextStyle: TextStyle.lerp(errorTextStyle, other.errorTextStyle, t),
      scrimColor: Color.lerp(scrimColor, other.scrimColor, t),
      progressColor: Color.lerp(progressColor, other.progressColor, t),
      removeBadgeBackgroundColor: Color.lerp(
        removeBadgeBackgroundColor,
        other.removeBadgeBackgroundColor,
        t,
      ),
      removeBadgeIconColor: Color.lerp(
        removeBadgeIconColor,
        other.removeBadgeIconColor,
        t,
      ),
      playButtonColor: Color.lerp(playButtonColor, other.playButtonColor, t),
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
      clockTextStyle: TextStyle.lerp(clockTextStyle, other.clockTextStyle, t),
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
    );
  }
}
