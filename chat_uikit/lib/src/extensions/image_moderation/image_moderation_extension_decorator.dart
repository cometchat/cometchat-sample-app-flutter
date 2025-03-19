import 'package:flutter/material.dart';
import '../../../../../cometchat_chat_uikit.dart';

///[ImageModerationExtensionDecorator] is a the view model for [ImageModerationExtension] it contains all the relevant business logic
///it is also a sub-class of [DataSourceDecorator] which allows any extension to override the default methods provided by [MessagesDataSource]
class ImageModerationExtensionDecorator extends DataSourceDecorator {
  User? loggedInUser;
  ImageModerationConfiguration? configuration;

  ImageModerationExtensionDecorator(super.dataSource, {this.configuration}) {
    getLoggedInUser();
  }

  getLoggedInUser() async {
    loggedInUser = await CometChat.getLoggedInUser();
  }

  @override
  Widget getImageMessageContentView(MediaMessage message, BuildContext context,
      BubbleAlignment alignment,{AdditionalConfigurations? additionalConfigurations}) {
    Widget child =
        super.getImageMessageContentView(message, context, alignment,additionalConfigurations: additionalConfigurations);
    if (message.sender?.uid == loggedInUser?.uid) {
      return child;
    }

    return getImageContent(message, child);
  }

  getImageContent(MediaMessage message, Widget child) {
    return ImageModerationFilter(
      key: UniqueKey(),
      message: message,
      warningText: configuration?.warningText,
      style: configuration?.style,
      child: child,
    );
  }

  @override
  String getId() {
    return "ImageModeration";
  }
}
