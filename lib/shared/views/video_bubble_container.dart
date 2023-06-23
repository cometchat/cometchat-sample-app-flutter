import 'package:cometchat_flutter_sample_app/utils/widget_card.dart';
import 'package:flutter/material.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';

WidgetProps getVideoBubbleContainer(BuildContext context) {
  return WidgetProps(
    leadingImageURL: "assets/icons/video.png",
    title: "Video Bubble",
    description:
        "CometChatVideoBubble displays a media message containing an video"
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
                  child: CometChatVideoBubble(
                    theme: cometChatTheme,
                    thumbnailUrl:
                        'https://data-us.cometchat.io/2379614bd4db65dd/media/1682666720_1080372877_5efc5c9d02a7133f3d25e67e7eca4572.png',
                    videoUrl:
                        'https://data-us.cometchat.io/2379614bd4db65dd/media/1682517886_527585446_3e8e02fc506fa535eecfe0965e1a2024.mp4',
                    style: const VideoBubbleStyle(borderRadius: 8),
                  ),
                )),
          ));
    },
  );
}
