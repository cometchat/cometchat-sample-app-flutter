import 'package:flutter/material.dart';

/// [CometChatCallButtonsStyle] is the data class that contains style configuration for [CometChatCallButtons]
///
/// ```dart
/// CallButtonsStyle(
/// voiceCallIconTint: Colors.red,
/// videoCallIconTint: Colors.red,
/// );
/// ```

class CometChatCallButtonsStyle
    extends ThemeExtension<CometChatCallButtonsStyle> {
  const CometChatCallButtonsStyle({
    this.voiceCallIconColor,
    this.videoCallIconColor,
    this.voiceCallButtonColor,
    this.videoCallButtonColor,
    this.voiceCallButtonBorder,
    this.videoCallButtonBorder,
    this.voiceCallButtonBorderRadius,
    this.videoCallButtonBorderRadius,
    this.voiceCallButtonPadding,
    this.videoCallButtonPadding,
  });

  ///[voiceCallIconColor] sets the color of the voice call icon
  final Color? voiceCallIconColor;

  ///[videoCallIconColor] sets the color of the video call icon
  final Color? videoCallIconColor;

  ///[voiceCallButtonColor] sets the color of the voice call button
  final Color? voiceCallButtonColor;

  ///[videoCallButtonColor] sets the color of the video call button
  final Color? videoCallButtonColor;

  ///[voiceCallButtonBorder] sets the border of the voice call button
  final BorderSide? voiceCallButtonBorder;

  ///[videoCallButtonBorder] sets the border of the video call button
  final BorderSide? videoCallButtonBorder;

  ///[voiceCallButtonBorderRadius] sets the border radius of the voice call button
  final BorderRadiusGeometry? voiceCallButtonBorderRadius;

  ///[videoCallButtonBorderRadius] sets the border radius of the video call button
  final BorderRadiusGeometry? videoCallButtonBorderRadius;

  ///[voiceCallButtonPadding] sets the padding of the voice call button
  final EdgeInsetsGeometry? voiceCallButtonPadding;

  ///[videoCallButtonPadding] sets the padding of the video call button
  final EdgeInsetsGeometry? videoCallButtonPadding;

  static CometChatCallButtonsStyle of(BuildContext context) =>
      const CometChatCallButtonsStyle();

  @override
  CometChatCallButtonsStyle copyWith({
    Color? voiceCallIconColor,
    Color? videoCallIconColor,
    Color? voiceCallButtonColor,
    Color? videoCallButtonColor,
    BorderSide? voiceCallButtonBorder,
    BorderSide? videoCallButtonBorder,
    BorderRadiusGeometry? voiceCallButtonBorderRadius,
    BorderRadiusGeometry? videoCallButtonBorderRadius,
    EdgeInsetsGeometry? voiceCallButtonPadding,
    EdgeInsetsGeometry? videoCallButtonPadding,
  }) {
    return CometChatCallButtonsStyle(
      voiceCallIconColor: voiceCallIconColor ?? this.voiceCallIconColor,
      videoCallIconColor: videoCallIconColor ?? this.videoCallIconColor,
      voiceCallButtonColor: voiceCallButtonColor ?? this.voiceCallButtonColor,
      videoCallButtonColor: videoCallButtonColor ?? this.videoCallButtonColor,
      voiceCallButtonBorder: voiceCallButtonBorder ?? this.voiceCallButtonBorder,
      videoCallButtonBorder: videoCallButtonBorder ?? this.videoCallButtonBorder,
      videoCallButtonBorderRadius: videoCallButtonBorderRadius ?? this.videoCallButtonBorderRadius,
      voiceCallButtonBorderRadius: voiceCallButtonBorderRadius ?? this.voiceCallButtonBorderRadius,
      voiceCallButtonPadding: voiceCallButtonPadding ?? this.voiceCallButtonPadding,
      videoCallButtonPadding: videoCallButtonPadding ?? this.videoCallButtonPadding,
    );
  }

  CometChatCallButtonsStyle merge(CometChatCallButtonsStyle? style) {
    if (style == null) return this;
    return copyWith(
      voiceCallIconColor: style.voiceCallIconColor,
      videoCallIconColor: style.videoCallIconColor,
      voiceCallButtonColor: style.voiceCallButtonColor,
      videoCallButtonColor: style.videoCallButtonColor,
      voiceCallButtonBorder: style.voiceCallButtonBorder,
      videoCallButtonBorder: style.videoCallButtonBorder,
      voiceCallButtonBorderRadius: style.voiceCallButtonBorderRadius,
      videoCallButtonBorderRadius: style.videoCallButtonBorderRadius,
      voiceCallButtonPadding: style.voiceCallButtonPadding,
      videoCallButtonPadding: style.videoCallButtonPadding,
    );
  }

  @override
  CometChatCallButtonsStyle lerp(
      ThemeExtension<CometChatCallButtonsStyle>? other, double t) {
    if (other is! CometChatCallButtonsStyle) {
      return this;
    }
    return CometChatCallButtonsStyle(
      voiceCallIconColor:
          Color.lerp(voiceCallIconColor, other.voiceCallIconColor, t),
      videoCallIconColor:
          Color.lerp(videoCallIconColor, other.videoCallIconColor, t),
      voiceCallButtonColor:
          Color.lerp(voiceCallButtonColor, other.voiceCallButtonColor, t),
      videoCallButtonColor:
          Color.lerp(videoCallButtonColor, other.videoCallButtonColor, t),
      voiceCallButtonBorder:
        BorderSide.lerp(voiceCallButtonBorder ?? BorderSide.none, other.voiceCallButtonBorder ?? BorderSide.none , t),
      videoCallButtonBorder:
        BorderSide.lerp(videoCallButtonBorder ?? BorderSide.none , other.videoCallButtonBorder ?? BorderSide.none, t),
      voiceCallButtonBorderRadius: BorderRadiusGeometry.lerp(
          voiceCallButtonBorderRadius, other.voiceCallButtonBorderRadius, t),
      videoCallButtonBorderRadius: BorderRadiusGeometry.lerp(
          videoCallButtonBorderRadius, other.videoCallButtonBorderRadius, t),
      voiceCallButtonPadding: EdgeInsetsGeometry.lerp(
          voiceCallButtonPadding, other.voiceCallButtonPadding, t),
      videoCallButtonPadding: EdgeInsetsGeometry.lerp(
          videoCallButtonPadding, other.videoCallButtonPadding, t),
    );
  }
}
