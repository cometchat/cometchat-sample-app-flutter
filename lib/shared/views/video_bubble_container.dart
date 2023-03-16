import 'package:cometchat_flutter_sample_app/utils/widget_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_ui_kit/flutter_chat_ui_kit.dart';

WidgetProps getVideoBubbleContainer(BuildContext context) {
  return WidgetProps(
    leadingImageURL: "assets/icons/video.png",
    title: "Video Bubble",
    description:
        "CometChatTextBubble displays a media message containing an video"
        "To learn more about this component tap here",
    onTap: () {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Scaffold(
                backgroundColor: cometChatTheme.palette.getBackground(),
                body: Center(
                  child: CometChatVideoBubble(
                    theme: cometChatTheme,
                    videoUrl:
                        'https://data-us.cometchat.io/208434241880dc4d/media/1676278931_975451502_6f3b8b7e82f806de85fe924361e2087d.mp4',
                    style: const VideoBubbleStyle(borderRadius: 8),
                  ),
                )),
          ));
    },
  );
}
