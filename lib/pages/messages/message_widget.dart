import 'package:flutter/material.dart';
import 'package:cometchat/cometchat_sdk.dart';
import 'package:sdk_tutorial/constants.dart';
import 'package:sdk_tutorial/pages/messages/message_functions.dart';
import 'package:sdk_tutorial/pages/messages/message_receipts.dart';

class MessageWidget extends StatefulWidget {
  final TextMessage passedMessage;
  final Function(BaseMessage msg) deleteFunction;
  final Function(BaseMessage, String) editFunction;
  final Conversation conversation;
  const MessageWidget(
      {Key? key,
      required this.passedMessage,
      required this.deleteFunction,
      required this.conversation,
      required this.editFunction})
      : super(key: key);

  @override
  _MessageWidgetState createState() => _MessageWidgetState();
}

class _MessageWidgetState extends State<MessageWidget> {
  String? text;
  bool sentByMe = false;

  @override
  Widget build(BuildContext context) {
    if (USERID == widget.passedMessage.sender!.uid) {
      sentByMe = true;
    } else {
      sentByMe = false;
    }

    text = widget.passedMessage.text;
    Color background = sentByMe == true
        ? const Color(0xff3399FF).withOpacity(0.92)
        : const Color(0xffF8F8F8).withOpacity(0.92);

    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment:
              sentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (widget.conversation.conversationType ==
                    CometChatConversationType.group &&
                sentByMe == false)
              Text(widget.passedMessage.sender!.name,
                  style: TextStyle(
                      color: const Color(0xff000000).withOpacity(0.6),
                      fontSize: 13)),
            GestureDetector(
              onTap: () async {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MessageFunctions(
                              passedMessage: widget.passedMessage,
                              sentByMe: sentByMe,
                              deleteMessage: widget.deleteFunction,
                              editMessage: widget.editFunction,
                            )));
              },
              child: Card(
                color: background,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    text ?? "",
                    style: TextStyle(
                      color: sentByMe == true
                          ? const Color(0xffFFFFFF).withOpacity(0.92)
                          : Colors.black,
                    ),
                  ),
                ),
              ),
            ),
            if (sentByMe == true)
              MessageReceipts(passedMessage: widget.passedMessage)
          ],
        ));
  }
}
