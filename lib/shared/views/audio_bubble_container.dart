import 'package:cometchat_flutter_sample_app/utils/widget_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_ui_kit/flutter_chat_ui_kit.dart';

WidgetProps getAudioBubbleContainer(BuildContext context) {
  return WidgetProps(
    leadingImageURL: "assets/icons/volume.png",
    title: "Audio Bubble",
    description:
        "CometChatTextBubble displays a media message containing an audio"
        "To learn more about this component tap here",
    onTap: () {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Scaffold(
                body: Center(
                    child: CometChatAudioBubble(
              theme: cometChatTheme,
              audioUrl:
                  'https://data-us.cometchat.io/208434241880dc4d/media/1676385385_2121040948_0a18fc37cb5afbe4cf833020017274e0.mp3',
              title: 'Sample Audio',
            ))),
          ));
    },
  );
}
