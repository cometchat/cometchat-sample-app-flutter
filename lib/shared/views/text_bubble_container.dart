import 'package:cometchat_flutter_sample_app/utils/widget_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_ui_kit/flutter_chat_ui_kit.dart';

WidgetProps getTextBubbleContainer(BuildContext context) {
  return WidgetProps(
    leadingImageURL: "assets/icons/message.png",
    title: "Text Bubble",
    description: "CometChatTextBubble displays a text message "
        "To learn more about this component tap here",
    onTap: () {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Scaffold(
                body: Center(
                    child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CometChatTextBubble(
                        text: 'Hi! how are you?',
                        alignment: BubbleAlignment.left,
                        theme: cometChatTheme,
                        style: TextBubbleStyle(
                            background: cometChatTheme.palette.getAccent100()),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CometChatTextBubble(
                          text: 'I\'m good, how are you?',
                          alignment: BubbleAlignment.right,
                          theme: cometChatTheme,
                          style: TextBubbleStyle(
                              background: cometChatTheme.palette.getPrimary()),
                        )),
                  ],
                )
              ],
            ))),
          ));
    },
  );
}
