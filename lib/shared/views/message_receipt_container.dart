import 'package:flutter/material.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';

class MessageReceiptContainer extends StatefulWidget {
  const MessageReceiptContainer({Key? key}) : super(key: key);

  @override
  State<MessageReceiptContainer> createState() =>
      _MessageReceiptContainerState();
}

class _MessageReceiptContainerState extends State<MessageReceiptContainer> {
  final TextMessage _waiting = TextMessage(
    text: "Send Message",
    type: '',
    receiverType: '',
    receiverUid: '',
  );

  final TextMessage _sentMessage = TextMessage(
      text: "Send Message",
      type: '',
      receiverType: '',
      receiverUid: '',
      sentAt: DateTime.now());

  final TextMessage _deliveredMessage = TextMessage(
      text: "Send Message",
      type: '',
      receiverType: '',
      receiverUid: '',
      sentAt: DateTime.now(),
      deliveredAt: DateTime.now());

  final TextMessage _readMessage = TextMessage(
      text: "Send Message",
      type: '',
      receiverType: '',
      receiverUid: '',
      sentAt: DateTime.now(),
      readAt: DateTime.now());

  final TextMessage _errorMessage = TextMessage(
      text: "Send Message",
      type: '',
      receiverType: '',
      receiverUid: '',
      sentAt: DateTime.now(),
      readAt: DateTime.now(),
      metadata: {"error": CometChatException('code', 'details', 'message')});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0.5,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Message Receipt",
                    style:
                        TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "CometChatMessageReceipt component renders the receipts such as sending , sent ,"
                    " delivered ,  read and error state indicator of messages .",
                  ),
                ),
                getCard(_waiting, "Waiting", scaleFactor: 1.8),
                getCard(_sentMessage, "Sent"),
                getCard(_deliveredMessage, "Delivered"),
                getCard(_readMessage, "Read"),
                getCard(_errorMessage, "Error")
              ],
            ),
          ),
        ));
  }

  getCard(BaseMessage _message, String title, {double? scaleFactor}) {
    ReceiptStatus _status = MessageReceiptUtils.getReceiptStatus(_message);

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Card(
        elevation: 4.0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Center(
                  child: SizedBox(
                height: 75,
                width: 75,
                child: Transform.scale(
                    scale: scaleFactor ?? 4,
                    child: CometChatReceipt(
                      status: _status,
                    )),
              ))
            ],
          ),
        ),
      ),
    );
  }
}
