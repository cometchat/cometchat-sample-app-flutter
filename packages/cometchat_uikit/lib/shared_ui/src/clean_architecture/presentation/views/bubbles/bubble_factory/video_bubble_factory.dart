import 'package:flutter/material.dart';
import 'package:cometchat_sdk/cometchat_sdk.dart';
import '../../../../core/constants/enums.dart';
import '../../../theme/colors/cometchat_color_palette.dart';
import '../../../theme/typography/cometchat_typography.dart';
import '../../../theme/spacing/cometchat_spacing.dart';
import '../video_bubble/cometchat_video_bubble.dart';
import '../video_bubble/cometchat_video_bubble_style.dart';
import 'bubble_factory.dart';

/// Factory for creating video message bubbles.
class VideoBubbleFactory extends BubbleFactory<MediaMessage> {
  final CometChatVideoBubbleStyle? style;
  final String? placeHolderImage;
  final String? placeHolderImagePackageName;
  final Icon? playIcon;
  final Function()? onClick;

  VideoBubbleFactory({
    this.style,
    this.placeHolderImage,
    this.placeHolderImagePackageName,
    this.playIcon,
    this.onClick,
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
    String? thumbnailUrl;
    if (message.metadata != null) {
      thumbnailUrl = message.metadata?['thumbnail'] as String?;
    }

    return CometChatVideoBubble(
      videoUrl: message.attachment?.fileUrl,
      thumbnailUrl: thumbnailUrl,
      style: style,
      placeHolderImage: placeHolderImage,
      placeHolderImagePackageName: placeHolderImagePackageName,
      playIcon: playIcon,
      onClick: onClick,
      metadata: message.metadata,
    );
  }
}
