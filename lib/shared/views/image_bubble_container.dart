import 'package:cometchat_flutter_sample_app/utils/widget_card.dart';
import 'package:flutter/material.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';

WidgetProps getImageBubbleContainer(BuildContext context) {
  return WidgetProps(
    leadingImageURL: "assets/icons/image.png",
    title: "Image Bubble",
    description:
        "CometChatImageBubble displays a media message containing an image"
        "To learn more about this component tap here",
    onTap: () {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Scaffold(
                appBar: AppBar(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  elevation: 0.5,
                ),
                backgroundColor: cometChatTheme.palette.getBackground(),
                body: Center(
                    child: CometChatImageBubble(
                  theme: cometChatTheme,
                  imageUrl:
                      'https://data-us.cometchat.io/2379614bd4db65dd/media/1682517838_2050398854_08d684e835e3c003f70f2478f937ed57.jpeg',
                  style: const ImageBubbleStyle(
                    borderRadius: 8,
                  ),
                ))),
          ));
    },
  );
}
