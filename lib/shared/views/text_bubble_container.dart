import 'package:cometchat_flutter_sample_app/utils/widget_card.dart';
import 'package:flutter/material.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';

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
                appBar: AppBar(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  elevation: 0.5,
                ),
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
                                background:
                                    cometChatTheme.palette.getAccent100()),
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
                                  background:
                                      cometChatTheme.palette.getPrimary()),
                            )),
                      ],
                    )
                  ],
                ))),
          ));
    },
  );
}
