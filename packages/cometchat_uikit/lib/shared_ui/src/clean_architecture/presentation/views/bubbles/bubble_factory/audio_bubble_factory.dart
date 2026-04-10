import 'package:flutter/material.dart';
import 'package:cometchat_sdk/cometchat_sdk.dart';
import '../../../../core/constants/enums.dart';
import '../../../theme/colors/cometchat_color_palette.dart';
import '../../../theme/typography/cometchat_typography.dart';
import '../../../theme/spacing/cometchat_spacing.dart';
import '../audio_bubble/cometchat_audio_bubble_v2.dart';
import '../audio_bubble/cometchat_audio_bubble_style.dart';
import 'bubble_factory.dart';

/// Factory for creating audio message bubbles.
class AudioBubbleFactory extends BubbleFactory<MediaMessage> {
  final CometChatAudioBubbleStyle? style;
  final Icon? playIcon;
  final Icon? pauseIcon;

  AudioBubbleFactory({
    this.style,
    this.playIcon,
    this.pauseIcon,
  });

  @override
  Widget build(
    BuildContext context,
    MediaMessage message,
    BubbleAlignment alignment, {
    CometChatColorPalette? colorPalette,
    CometChatTypography? typography,
    CometChatSpacing? spacing,
  }) {
    return CometChatAudioBubbleV2(
      audioUrl: message.attachment?.fileUrl,
      title: message.attachment?.fileName,
      style: style,
      playIcon: playIcon,
      pauseIcon: pauseIcon,
      alignment: alignment,
      id: message.id,
      metadata: message.metadata,
      colorPalette: colorPalette,
      typography: typography,
      spacing: spacing,
    );
  }
}
