import 'package:cometchat_flutter_sample_app/utils/widget_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_ui_kit/flutter_chat_ui_kit.dart';

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
                body: Center(
                    child: DecoratedBox(
              decoration: const BoxDecoration(color: Colors.white),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
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
