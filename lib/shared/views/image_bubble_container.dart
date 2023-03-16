import 'package:cometchat_flutter_sample_app/utils/widget_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_ui_kit/flutter_chat_ui_kit.dart';

WidgetProps getImageBubbleContainer(BuildContext context) {
  return WidgetProps(
    leadingImageURL: "assets/icons/image.png",
    title: "Image Bubble",
    description:
        "CometChatTextBubble displays a media message containing an image"
        "To learn more about this component tap here",
    onTap: () {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Scaffold(
                backgroundColor: cometChatTheme.palette.getBackground(),
                body: Center(
                    child: CometChatImageBubble(
                  theme: cometChatTheme,
                  imageUrl:
                      'https://data-us.cometchat.io/208434241880dc4d/media/1676951632_1179067617_0bb4ab5734e38db8b6fce07a5a912b84.jpg',
                  style: const ImageBubbleStyle(
                    borderRadius: 8,
                  ),
                ))),
          ));
    },
  );
}
