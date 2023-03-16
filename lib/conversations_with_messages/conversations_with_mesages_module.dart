import 'package:cometchat_flutter_sample_app/utils/module_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_ui_kit/flutter_chat_ui_kit.dart';

class ConversationsWithMessagesModule extends StatelessWidget {
  const ConversationsWithMessagesModule({Key? key}) : super(key: key);

  navigateToConversationsWithMessages(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const CometChatConversationsWithMessages(),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return ModuleCard(
      title: "Conversations With Messages",
      leading: Image.asset(
        'assets/icons/conversations-with-messages.png',
        height: 48,
        width: 48,
      ),
      description:
          "Conversation Module helps you list the recent conversations between your users and groups. To learn more about this component tap here",
      onTap: () => navigateToConversationsWithMessages(context),
    );
  }
}
