/*
import 'package:cometchat_flutter_sample_app/utils/background_card.dart';
import 'package:flutter/material.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';

class ConversationListItemContainer extends StatelessWidget {
  const ConversationListItemContainer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const BackGroundCard(
        title: "Conversation List Item",
        description: "CometChatConversationListItem is a reusable component "
            "which is used to display the conversation list item in conversation list. ",
        child: ConversationListItemView());
  }
}

class ConversationListItemView extends StatefulWidget {
  const ConversationListItemView({Key? key}) : super(key: key);

  @override
  _ConversationListItemViewState createState() =>
      _ConversationListItemViewState();
}

class _ConversationListItemViewState extends State<ConversationListItemView> {
  final User _sender = User(
      name: 'Kevin',
      uid: 'UID233',
      avatar:
          "https://data-us.cometchat.io/assets/images/avatars/spiderman.png",
      role: "test",
      status: "online",
      statusMessage: "This is now status");

  final TextMessage _message = TextMessage(
      receiverType: CometChatReceiverType.user,
      receiverUid: "superhero1",
      type: MessageTypeConstants.text,
      text: "HI HOW ARE YOU?",
      conversationId: "conver_Id",
      id: 2344,
      muid: "UniqueIdentifier");

  late Conversation _conversation;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _conversation = Conversation(
        conversationWith: _sender,
        conversationType: "user",
        conversationId: "conver_Id",
        lastMessage: _message,
        unreadMessageCount: 2);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Column(
        children: [
          // CometChatConversationListItem(
          //   showTypingIndicator: false,
          //   onTap: () {},
          //   conversation: _conversation,
          // ),
        ],
      ),
    );
  }
}
*/
