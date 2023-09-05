import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';
import 'package:cometchat_flutter_sample_app/utils/module_card.dart';
import 'package:flutter/material.dart';

class MessageInformationModule extends StatelessWidget {
  const MessageInformationModule({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    User _sender = User(
        name: 'Kevin',
        uid: 'UID233',
        avatar:
            "https://data-us.cometchat.io/assets/images/avatars/spiderman.png",
        role: "test",
        status: "online",
        statusMessage: "This is now status");

    User _receiver = User(
        name: 'IronMan',
        uid: 'superhero1',
        avatar:
            "https://data-us.cometchat.io/assets/images/avatars/ironman.png",
        role: "test",
        status: "online",
        statusMessage: "This is now status");

    return ModuleCard(
      leading: Image.asset(
        'assets/icons/info.png',
        height: 48,
        width: 48,
      ),
      title: "Message Information",
      description:
          "CometChatMessageInformation is a widget that shows a separate view that displays comprehensive information about the message. This will enable users to easily access details such as the message content, recipient and delivery receipt information for a more informed communication experience.",
      onTap: () {
        BaseMessage _message = BaseMessage(
          receiverType: "user",
          receiverUid: "superhero1",
          readAt: DateTime.now(),
          sentAt: DateTime.now().subtract(const Duration(days: 1)),
          deliveredAt: DateTime.now().subtract(const Duration(days: 1)),
          type: "text",
          receiver: _receiver,
          sender: _sender,
          category: "text",
        );
        CometChatMessageTemplate _template = CometChatMessageTemplate(
          type: "text",
          category: "text",
          bubbleView: (message, context, alignment) {
            return Align(
              alignment: Alignment.bottomRight,
              child: Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Center(
                    child: Text(
                      "Hi",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            );
          },
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CometChatMessageInformation(
              message: _message,
              template: _template,
            ),
          ),
        );
      },
    );
  }
}
