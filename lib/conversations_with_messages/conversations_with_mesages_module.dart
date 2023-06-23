import 'package:cometchat_flutter_sample_app/utils/module_card.dart';
import 'package:flutter/material.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';

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
          "Conversations With Messages module helps you to view list of conversations that the logged in user is part of. On tapping on a conversation, you will be redirected to the Messages screen for that conversation. To learn more about this component, tap here.",
      onTap: () => navigateToConversationsWithMessages(context),
    );
  }
}
