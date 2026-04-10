import '../../../../core/constants/ui_kit_constants.dart';
import '../../../formatters/formatters.dart';
import '../text_bubble/cometchat_text_bubble_style.dart';
import '../image_bubble/cometchat_image_bubble_style.dart';
import '../video_bubble/cometchat_video_bubble_style.dart';
import '../audio_bubble/cometchat_audio_bubble_style.dart';
import '../file_bubble/cometchat_file_bubble_style.dart';
import 'bubble_factory.dart';
import 'text_bubble_factory.dart';
import 'image_bubble_factory.dart';
import 'video_bubble_factory.dart';
import 'audio_bubble_factory.dart';
import 'file_bubble_factory.dart';
import 'deleted_bubble_factory.dart';

/// Utility class providing default bubble factories for all message types.
class DefaultBubbleFactories {
  DefaultBubbleFactories._();

  /// Returns the complete map of default bubble factories.
  static Map<String, BubbleFactory> getDefaults({
    List<CometChatTextFormatter>? textFormatters,
    CometChatTextBubbleStyle? incomingTextStyle,
    CometChatTextBubbleStyle? outgoingTextStyle,
    CometChatImageBubbleStyle? imageStyle,
    CometChatVideoBubbleStyle? videoStyle,
    CometChatAudioBubbleStyle? audioStyle,
    CometChatFileBubbleStyle? fileStyle,
  }) {
    return {
      _key(MessageCategoryConstants.message, MessageTypeConstants.text):
          TextBubbleFactory(
        textFormatters: FormatterUtils.ensureMarkdownFormatter(textFormatters),
        incomingStyle: incomingTextStyle,
        outgoingStyle: outgoingTextStyle,
      ),
      _key(MessageCategoryConstants.message, MessageTypeConstants.image):
          ImageBubbleFactory(style: imageStyle),
      _key(MessageCategoryConstants.message, MessageTypeConstants.video):
          VideoBubbleFactory(style: videoStyle),
      _key(MessageCategoryConstants.message, MessageTypeConstants.audio):
          AudioBubbleFactory(style: audioStyle),
      _key(MessageCategoryConstants.message, MessageTypeConstants.file):
          FileBubbleFactory(style: fileStyle),
      'deleted': DeletedBubbleFactory(),
    };
  }

  static String _key(String category, String type) => '${category}_$type';
  static String createKey(String category, String type) => _key(category, type);
}
