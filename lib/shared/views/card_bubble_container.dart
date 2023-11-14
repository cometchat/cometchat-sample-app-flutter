import 'package:cometchat_flutter_sample_app/utils/widget_card.dart';
import 'package:flutter/material.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';

WidgetProps getCardBubbleContainer(BuildContext context) {
  
  CardMessage cardMessage = CardMessage(text: "Chat & messaging\n"
      "Flexible, scalable and feature rich UI Kits and SDKs for your in-app messaging", cardActions: [
    ButtonElement(elementId: "navigation1", buttonText: "Check this", action:
    URLNavigationAction(url: "https://www.cometchat.com/")   ),
    ButtonElement(elementId: "navigation2", buttonText: "Check this", action:
    URLNavigationAction(url: "https://www.cometchat.com/")   ),
  ], receiverUid: "superhero2", receiverType: "user");
  
  
  return WidgetProps(
    leadingImageURL: "assets/icons/card.png",
    title: "Card Bubble",
    description:
    "CometChatCardBubble component is used to display a card within a chat bubble."
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
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CometChatCardBubble(
                         cardMessage: cardMessage,
                        ),
                      ],
                    ))),
          ));
    },
  );
}
