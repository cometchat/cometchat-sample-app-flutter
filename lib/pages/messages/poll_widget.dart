import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cometchat/cometchat_sdk.dart';
import 'package:sdk_tutorial/constants.dart';
import 'package:sdk_tutorial/pages/messages/message_functions.dart';
import 'package:sdk_tutorial/pages/messages/message_receipts.dart';

class PollWidget extends StatefulWidget {
  final CustomMessage passedMessage;
  final Conversation conversation;
  final Function(String vote , String id) votePoll;
  const PollWidget(
      {Key? key, required this.passedMessage, required this.conversation, required this.votePoll})
      : super(key: key);

  @override
  _PollWidgetState createState() => _PollWidgetState();
}

class _PollWidgetState extends State<PollWidget> {
  String? text;
  bool sentByMe = false;
  late String question;
  String chosenId = "";
  Map options = {};
  late  String pollId;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    question = widget.passedMessage.customData?["question"] ?? "";
    var ansList = widget.passedMessage.customData?["options"];
    print("ansList .datatype ${ansList.runtimeType}");
    if (ansList != null) {
      options = Map<String, dynamic>.from(ansList);
      for (var item in options.values) {
        print(item);
      }
    }
    pollId = widget.passedMessage.customData?["id"];
  }

  @override
  Widget build(BuildContext context) {
    if (USERID == widget.passedMessage.sender!.uid) {
      sentByMe = true;
    } else {
      sentByMe = false;
    }

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
                      color: Color(0xff000000).withOpacity(0.6), fontSize: 13)),
            GestureDetector(
              onTap: () async {},
              child: Card(
                color: background,
                child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          question,
                          style: TextStyle(
                            color: sentByMe == true
                                ? const Color(0xffFFFFFF).withOpacity(0.92)
                                : Colors.black,
                          ),
                        ),

                        ...options.keys.map(( e) => getRadio(e, options[e] ))

                      ],
                    )),
              ),
            ),
            if (sentByMe == true)
              MessageReceipts(passedMessage: widget.passedMessage)
          ],
        ));
  }

  getRadio(String id, String value) {
    var count  = widget.passedMessage.metadata?["@injected"]?["extensions"]?["polls"]?["results"]?["options"]?[id]?["count"]??0;

    return 
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            fit: FlexFit.loose,
            child: Radio(
            value: id,
            groupValue: chosenId,
            activeColor: sentByMe == true
                ? const Color(0xffFFFFFF).withOpacity(0.92)
                : Colors.black,

            onChanged: (String? chosen) {
        if (chosen != null) {

            widget.votePoll(id, widget.passedMessage.customData?["id"]);
            setState(() {
              chosenId = chosen;
            });
        }
      }),
          ), Text("$value ($count)", style: TextStyle(color: sentByMe == true
              ? const Color(0xffFFFFFF).withOpacity(0.92)
              : Colors.black),)
        ],
      );
      
  }
}
