import 'package:flutter/material.dart';
import 'package:cometchat_sdk/cometchat_sdk.dart' hide CardMessage;
import '../../../../core/constants/enums.dart';
import '../../../../core/utils/thumbnail_extraction_util.dart';
import '../../../theme/colors/cometchat_color_palette.dart';
import '../../../theme/typography/cometchat_typography.dart';
import '../../../theme/spacing/cometchat_spacing.dart';
import '../image_bubble/cometchat_image_bubble.dart';
import '../image_bubble/cometchat_image_bubble_style.dart';
import 'bubble_factory.dart';

/// Factory for creating image message bubbles.
class ImageBubbleFactory extends BubbleFactory<MediaMessage> {
  final CometChatImageBubbleStyle? style;
  final String? placeholderImage;
  final String? placeholderImagePackageName;
  final Function()? onClick;

  ImageBubbleFactory({
    this.style,
    this.placeholderImage,
    this.placeholderImagePackageName,
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
    final thumbnailUrl = ThumbnailExtractionUtil.extractFromMetadata(
      message.metadata,
    );

    return CometChatImageBubble(
      imageUrl: message.attachment?.fileUrl,
      thumbnailUrl: thumbnailUrl,
      style: style,
      placeholderImage: placeholderImage,
      placeHolderImagePackageName: placeholderImagePackageName,
      onClick: onClick,
      metadata: message.metadata,
    );
  }
}
