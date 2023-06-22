import 'package:cometchat_flutter_sample_app/utils/widget_card.dart';
import 'package:flutter/material.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';

WidgetProps getAudioBubbleContainer(BuildContext context) {
  return WidgetProps(
    leadingImageURL: "assets/icons/volume.png",
    title: "Audio Bubble",
    description:
        "CometChatAudioBubble displays a media message containing an audio"
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
                body: Center(
                    child: CometChatAudioBubble(
                  theme: cometChatTheme,
                  audioUrl:
                      'https://data-us.cometchat.io/2379614bd4db65dd/media/1682517916_1406731591_130612180fb2e657699814eb52817574.mp3',
                  title: 'Sample Audio',
                ))),
          ));
    },
  );
}
