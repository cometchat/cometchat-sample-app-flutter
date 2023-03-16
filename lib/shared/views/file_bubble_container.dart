import 'package:cometchat_flutter_sample_app/utils/widget_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_ui_kit/flutter_chat_ui_kit.dart';

WidgetProps getFileBubbleContainer(BuildContext context) {
  return WidgetProps(
    leadingImageURL: "assets/icons/folder.png",
    title: "File Bubble",
    description:
        "CometChatTextBubble displays a media message containing a fille"
        "To learn more about this component tap here",
    onTap: () {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Scaffold(
                body: Center(
                    child: CometChatFileBubble(
              theme: cometChatTheme,
              fileUrl:
                  'https://images.pexels.com/photos/1496372/pexels-photo-1496372.jpeg',
              title: 'File bubble',
              style: const FileBubbleStyle(borderRadius: 6),
            ))),
          ));
    },
  );
}
