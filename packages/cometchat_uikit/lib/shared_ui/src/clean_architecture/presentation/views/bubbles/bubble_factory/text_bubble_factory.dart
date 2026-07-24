import 'package:flutter/material.dart';
import 'package:cometchat_sdk/cometchat_sdk.dart' hide CardMessage;
import '../../../../core/constants/enums.dart';
import '../../../../core/utils/emoji_utils.dart';
import '../../../theme/colors/cometchat_color_palette.dart';
import '../../../theme/typography/cometchat_typography.dart';
import '../../../theme/spacing/cometchat_spacing.dart';
import '../../../formatters/formatters.dart';
import '../text_bubble/cometchat_text_bubble.dart';
import '../text_bubble/cometchat_text_bubble_style.dart';
import 'bubble_factory.dart';

/// Factory for creating text message bubbles.
class TextBubbleFactory extends BubbleFactory<TextMessage> {
  /// Text formatters for styling mentions, links, etc.
  final List<CometChatTextFormatter>? textFormatters;

  /// Style for incoming (left-aligned) text bubbles.
  final CometChatTextBubbleStyle? incomingStyle;

  /// Style for outgoing (right-aligned) text bubbles.
  final CometChatTextBubbleStyle? outgoingStyle;

  TextBubbleFactory({
    this.textFormatters,
    this.incomingStyle,
    this.outgoingStyle,
  });

  @override
  Widget build(
    BuildContext context,
    TextMessage message,
    BubbleAlignment alignment, {
    CometChatColorPalette? colorPalette,
    CometChatTypography? typography,
    CometChatSpacing? spacing,
  }) {
    final style = alignment == BubbleAlignment.right
        ? outgoingStyle
        : incomingStyle;

    // Detect emoji-only messages for WhatsApp-style scaled rendering
    final count = EmojiUtils.emojiOnlyCount(message.text);
    final emojiCount = (count > 0 && count <= EmojiUtils.maxScaledCount)
        ? count
        : 0;

    return CometChatTextBubble(
      text: message.text,
      alignment: alignment,
      style: style,
      formatters: emojiCount > 0
          ? null
          : FormatterUtils.ensureMarkdownFormatter(textFormatters),
      emojiCount: emojiCount,
    );
  }
}
