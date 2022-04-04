import 'dart:io' show Platform;
import 'package:cometchat/cometchat_sdk.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Future<void> showMessageOptions(BuildContext context,
    Function(BaseMessage) deleteMessage, BaseMessage message) async {
  Widget title = const Text("Message Actions");

  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return Platform.isAndroid
          ? AlertDialog(
              title: title,
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Card(
                      child: ListTile(
                        onTap: () {
                          deleteMessage(message);
                          Navigator.of(context).pop();
                        },
                        title: const Text("Delete Message"),
                      ),
                    )
                  ],
                ),
              ))
          : CupertinoAlertDialog(
              title: title,
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Card(
                      child: ListTile(
                        onTap: () {
                          deleteMessage(message);
                          Navigator.of(context).pop();
                        },
                        title: const Text("Delete Message"),
                      ),
                    )
                  ],
                ),
              ),
            );
    },
  );
}
