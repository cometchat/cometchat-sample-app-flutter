import 'package:cometchat_flutter_sample_app/utils/widget_card.dart';
import 'package:flutter/material.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';

WidgetProps getDeleteMessageBubbleContainer(BuildContext context) {
  return WidgetProps(
    leadingImageURL: "assets/icons/deleted-message.png",
    title: "Delete Message Bubble",
    description:
        "CometChatDeleteMessageBubble displays a placeholder if a message has been deleted"
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
                body: const Center(
                    child: DecoratedBox(
                  decoration: BoxDecoration(color: Colors.white),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:  [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CometChatDeleteMessageBubble(),
                      ),
                    ],
                  ),
                ))),
          ));
    },
  );
}
