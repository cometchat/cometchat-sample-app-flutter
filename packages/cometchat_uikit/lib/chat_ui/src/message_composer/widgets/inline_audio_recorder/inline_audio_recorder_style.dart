import 'package:flutter/material.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';

/// Style configuration for the inline audio recorder
@immutable
class CometChatInlineAudioRecorderStyle {
  /// Background color of the recorder container
  final Color? backgroundColor;

  /// Border of the recorder container
  final BoxBorder? border;

  /// Border radius of the recorder container
  final BorderRadiusGeometry? borderRadius;

  /// Color of the waveform bars
  final Color? waveformColor;

  /// Color of the waveform bars when recording
  final Color? waveformRecordingColor;

  /// Color of the waveform bars when playing
  final Color? waveformPlayingColor;

  /// Color of the duration text
  final Color? durationTextColor;

  /// Text style for the duration
  final TextStyle? durationTextStyle;

  /// Color of the record button icon
  final Color? recordButtonIconColor;

  /// Background color of the record button
  final Color? recordButtonBackgroundColor;

  /// Color of the pause button icon
  final Color? pauseButtonIconColor;

  /// Background color of the pause button
  final Color? pauseButtonBackgroundColor;

  /// Color of the stop button icon
  final Color? stopButtonIconColor;

  /// Background color of the stop button
  final Color? stopButtonBackgroundColor;

  /// Color of the delete button icon
  final Color? deleteButtonIconColor;

  /// Background color of the delete button
  final Color? deleteButtonBackgroundColor;

  /// Color of the send button icon
  final Color? sendButtonIconColor;

  /// Background color of the send button
  final Color? sendButtonBackgroundColor;

  /// Color of the play button icon
  final Color? playButtonIconColor;

  /// Background color of the play button
  final Color? playButtonBackgroundColor;

  /// Color of the recording indicator dot
  final Color? recordingIndicatorColor;

  const CometChatInlineAudioRecorderStyle({
    this.backgroundColor,
    this.border,
    this.borderRadius,
    this.waveformColor,
    this.waveformRecordingColor,
    this.waveformPlayingColor,
    this.durationTextColor,
    this.durationTextStyle,
    this.recordButtonIconColor,
    this.recordButtonBackgroundColor,
    this.pauseButtonIconColor,
    this.pauseButtonBackgroundColor,
    this.stopButtonIconColor,
    this.stopButtonBackgroundColor,
    this.deleteButtonIconColor,
    this.deleteButtonBackgroundColor,
    this.sendButtonIconColor,
    this.sendButtonBackgroundColor,
    this.playButtonIconColor,
    this.playButtonBackgroundColor,
    this.recordingIndicatorColor,
  });

  /// Creates a style from the current theme
  static CometChatInlineAudioRecorderStyle of(BuildContext context) {
    final colorPalette = CometChatThemeHelper.getColorPalette(context);
    final typography = CometChatThemeHelper.getTypography(context);

    return CometChatInlineAudioRecorderStyle(
      backgroundColor: colorPalette.background1,
      waveformColor: colorPalette.neutral400,
      waveformRecordingColor: colorPalette.primary,
      waveformPlayingColor: colorPalette.primary,
      durationTextColor: colorPalette.textSecondary,
      durationTextStyle: typography.caption1?.regular,
      recordButtonIconColor: colorPalette.error,
      recordButtonBackgroundColor: colorPalette.transparent,
      pauseButtonIconColor: colorPalette.error,
      pauseButtonBackgroundColor: colorPalette.transparent,
      stopButtonIconColor: colorPalette.iconSecondary,
      stopButtonBackgroundColor: colorPalette.transparent,
      deleteButtonIconColor: colorPalette.iconSecondary,
      deleteButtonBackgroundColor: colorPalette.transparent,
      sendButtonIconColor: colorPalette.white,
      sendButtonBackgroundColor: colorPalette.primary,
      playButtonIconColor: colorPalette.primary,
      playButtonBackgroundColor: colorPalette.transparent,
      recordingIndicatorColor: colorPalette.error,
    );
  }

  /// Merges this style with another, with the other taking precedence
  CometChatInlineAudioRecorderStyle merge(
      CometChatInlineAudioRecorderStyle? other) {
    if (other == null) return this;
    return CometChatInlineAudioRecorderStyle(
      backgroundColor: other.backgroundColor ?? backgroundColor,
      border: other.border ?? border,
      borderRadius: other.borderRadius ?? borderRadius,
      waveformColor: other.waveformColor ?? waveformColor,
      waveformRecordingColor:
          other.waveformRecordingColor ?? waveformRecordingColor,
      waveformPlayingColor: other.waveformPlayingColor ?? waveformPlayingColor,
      durationTextColor: other.durationTextColor ?? durationTextColor,
      durationTextStyle: other.durationTextStyle ?? durationTextStyle,
      recordButtonIconColor:
          other.recordButtonIconColor ?? recordButtonIconColor,
      recordButtonBackgroundColor:
          other.recordButtonBackgroundColor ?? recordButtonBackgroundColor,
      pauseButtonIconColor: other.pauseButtonIconColor ?? pauseButtonIconColor,
      pauseButtonBackgroundColor:
          other.pauseButtonBackgroundColor ?? pauseButtonBackgroundColor,
      stopButtonIconColor: other.stopButtonIconColor ?? stopButtonIconColor,
      stopButtonBackgroundColor:
          other.stopButtonBackgroundColor ?? stopButtonBackgroundColor,
      deleteButtonIconColor:
          other.deleteButtonIconColor ?? deleteButtonIconColor,
      deleteButtonBackgroundColor:
          other.deleteButtonBackgroundColor ?? deleteButtonBackgroundColor,
      sendButtonIconColor: other.sendButtonIconColor ?? sendButtonIconColor,
      sendButtonBackgroundColor:
          other.sendButtonBackgroundColor ?? sendButtonBackgroundColor,
      playButtonIconColor: other.playButtonIconColor ?? playButtonIconColor,
      playButtonBackgroundColor:
          other.playButtonBackgroundColor ?? playButtonBackgroundColor,
      recordingIndicatorColor:
          other.recordingIndicatorColor ?? recordingIndicatorColor,
    );
  }
}
