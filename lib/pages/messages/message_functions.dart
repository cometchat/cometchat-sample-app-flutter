import 'package:cometchat/cometchat_sdk.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sdk_tutorial/constants.dart';

class MessageFunctions extends StatefulWidget {
  const MessageFunctions({
    Key? key,
    required this.passedMessage,
    required this.sentByMe,
    required this.deleteMessage,
    required this.editMessage,
  }) : super(key: key);

  final BaseMessage passedMessage;
  final bool sentByMe;
  final Function(BaseMessage) deleteMessage;
  final Function(BaseMessage, String) editMessage;

  @override
  _MessageFunctionsState createState() => _MessageFunctionsState();
}

class _MessageFunctionsState extends State<MessageFunctions> {
  late String name;
  late Widget title;
  String editMessageText = "";

  @override
  void initState() {
    super.initState();

    if (widget.passedMessage.type == CometChatMessageType.text) {
      title = Text((widget.passedMessage as TextMessage).text);
    } else {
      title = Text(widget.passedMessage.type);
    }
  }

  deleteMessage() async {
    widget.deleteMessage(widget.passedMessage);
    Navigator.of(context).pop();
  }

  showEditMessageDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Edit Message",
            textAlign: TextAlign.center,
          ),
          content: Padding(
              padding: const EdgeInsets.all(5.0),
              child: TextField(
                onChanged: (val) {
                  editMessageText = val;
                },
                maxLines: null,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Message',
                  hintText: 'Updated Message',
                ),
              )),
          actions: [
            TextButton(
              child: const Text(
                'Cancel',
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: const Text("Confirm"),
              onPressed: () {
                widget.editMessage(widget.passedMessage, editMessageText);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String? iconUrl = widget.passedMessage.sender!.avatar;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Message Details"),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              Card(
                child: SizedBox(
                    height: 72,
                    child: Center(
                      child: ListTile(
                        leading: CircleAvatar(
                            child: iconUrl != null && iconUrl.trim() != ''
                                ? Image.network(
                                    iconUrl,
                                  )
                                : Center(
                                    child:
                                        Text(widget.passedMessage.sender!.name),
                                  )),
                        title: title,
                      ),
                    )),
              ),
              if (widget.passedMessage.sentAt != null)
                Card(
                  child: SizedBox(
                      height: 50,
                      child: ListTile(
                        trailing: Text(
                            '${DateFormat("yyyy-MM-dd hh:mm:ss").format(widget.passedMessage.sentAt!)}'),
                        title: const Text(
                          "Sent At",
                          style: TextStyle(color: Colors.blue),
                        ),
                      )),
                ),
              if (widget.passedMessage.deliveredAt != null)
                Card(
                  child: SizedBox(
                      height: 50,
                      child: ListTile(
                        trailing: Text(
                            '${DateFormat("yyyy-MM-dd hh:mm:ss").format(widget.passedMessage.deliveredAt!)}'),
                        title: const Text(
                          "Delivered At",
                          style: TextStyle(color: Colors.blue),
                        ),
                      )),
                ),
              if (widget.passedMessage.readAt != null)
                Card(
                  child: SizedBox(
                      height: 50,
                      child: ListTile(
                        trailing: Text(
                            '${DateFormat("yyyy-MM-dd hh:mm:ss").format(widget.passedMessage.readAt!)}'),
                        title: const Text(
                          "Read At",
                          style: TextStyle(color: Colors.blue),
                        ),
                      )),
                ),
              if (widget.passedMessage.sender!.uid == USERID)
                Card(
                  child: SizedBox(
                      height: 50,
                      child: ListTile(
                        leading: const Icon(
                          Icons.edit,
                          color: Colors.blue,
                        ),
                        onTap: showEditMessageDialog,
                        title: const Text(
                          "Edit Message",
                          style: TextStyle(color: Colors.blue),
                        ),
                      )),
                ),
              if (widget.passedMessage.sender!.uid == USERID)
                Card(
                  child: SizedBox(
                      height: 50,
                      child: ListTile(
                        leading: const Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                        onTap: deleteMessage,
                        title: const Text(
                          "Delete Message",
                          style: TextStyle(color: Colors.red),
                        ),
                      )),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
