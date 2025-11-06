import 'package:flutter/material.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';

///[ThumbnailGenerationExtensionDecorator] is a the view model for [ThumbnailGenerationExtension] it contains all the relevant business logic
///it is also a sub-class of [DataSourceDecorator] which allows any extension to override the default methods provided by [MessagesDataSource]
class ThumbnailGenerationExtensionDecorator extends DataSourceDecorator {
  String thumbnailGenerationTypeConstant =
      ExtensionConstants.thumbnailGeneration;
  ThumbnailGenerationConfiguration? configuration;

  ThumbnailGenerationExtensionDecorator(super.dataSource, {this.configuration});

  @override
  Widget getVideoMessageBubble(
      String? videoUrl,
      String? thumbnailUrl,
      MediaMessage message,
      Function()? onClick,
      BuildContext context,
      CometChatVideoBubbleStyle? style) {
    String? thumbnailUrl0 = checkForThumbnail(message);
    return super.getVideoMessageBubble(videoUrl, thumbnailUrl0, message, null,
        context, configuration?.style ?? style);
  }

  @override
  Widget getImageMessageBubble(
      String? imageUrl,
      String? placeholderImage,
      String? caption,
      CometChatImageBubbleStyle? style,
      MediaMessage message,
      Function()? onClick,
      BuildContext context,) {
    String? thumbnailUrl = checkForThumbnail(message);
    return super.getImageMessageBubble(
        thumbnailUrl ?? imageUrl,
        placeholderImage,
        caption,
        style,
        message,
        () => openImageInFullScreenMode(imageUrl, context),
        context,
        );
  }

  @override
  String getId() {
    return "ThumbnailGeneration";
  }

  String? getThumbnailGeneration(BaseMessage baseMessage) {
    String? resultUrl;
    try {
      Map<String, Map>? extensionList =
          ExtensionModerator.extensionCheck(baseMessage);
      if (extensionList != null &&
          extensionList.containsKey(ExtensionConstants.thumbnailGeneration)) {
        Map? thumbnailGeneration =
            extensionList[ExtensionConstants.thumbnailGeneration];
        if (thumbnailGeneration != null) {
          resultUrl = thumbnailGeneration["url_medium"];
        }
      }
    } catch (e, stack) {
      debugPrint("$stack");
    }
    return resultUrl;
  }

  String? checkForThumbnail(MediaMessage message) {
    try {
      String? smallUrl = getThumbnailGeneration(message);
      Attachment? attachment = message.attachment;
      if (attachment != null) {
        if (smallUrl != null) {
          return smallUrl;
        }
      }
    } catch (_) {}

    return null;
  }

  openImageInFullScreenMode(
      String? imageUrl, BuildContext context) {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImageViewer(
            imageUrl: imageUrl,
          ),
        ),
      );
    }
  }
}
