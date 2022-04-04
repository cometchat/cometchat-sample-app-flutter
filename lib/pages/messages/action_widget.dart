import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cometchat/cometchat_sdk.dart';
import 'package:cometchat/cometchat_sdk.dart' as action_Alias;
import 'package:sdk_tutorial/constants.dart';
import 'package:sdk_tutorial/pages/messages/message_functions.dart';
import 'package:sdk_tutorial/pages/messages/message_receipts.dart';

class ActionWidget extends StatefulWidget {
  action_Alias.Action passedMessage;
  ActionWidget(
      {Key? key,
        required this.passedMessage,
      })
      : super(key: key);

  @override
  _ActionWidgetState createState() => _ActionWidgetState();
}

class _ActionWidgetState extends State<ActionWidget> {
  String? text;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    text =widget.passedMessage.message;

    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment:CrossAxisAlignment.center,

          children: [
            GestureDetector(

              onTap: () async {
              },
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(text ?? "",
                    style:  TextStyle(color : Colors.black.withOpacity(0.5) ),
                  ),
                ),
              ),
            ),

          ],
        ));
  }

}
