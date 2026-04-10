import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';

///[ImageModerationConfiguration] is a data class that has configuration properties
///to customize the functionality and appearance of [ImageModerationExtension]
///can be used by a component where [ImageModerationExtension] is a child component
///
/// ```dart
/// ImageModerationConfiguration(
///      style: ImageModerationFilterStyle(), warningText: "warning"
///  );
/// ```
class ImageModerationConfiguration {
  ImageModerationConfiguration({this.warningText, this.style});

  ///[warningText] text shown if image has sensitive/graphic content
  final String? warningText;

  ///[style] provides styling to this ImageModerationFilter
  final ImageModerationFilterStyle? style;
}
