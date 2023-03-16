import 'package:cometchat_flutter_sample_app/message_composer/message_composer_module.dart';
import 'package:cometchat_flutter_sample_app/message_header/message_header_module.dart';
import 'package:cometchat_flutter_sample_app/message_list/message_list_module.dart';
import 'package:cometchat_flutter_sample_app/messages/messages_dashboard.dart';
import 'package:flutter/material.dart';

class MessagesDashboard extends StatelessWidget {
  const MessagesDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 2, 10, 2),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.black,
                      ),
                    ),
                    const Text(
                      "Messages",
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              // WidgetCard(
              //   widgets: moduleList,
              // ),
              const MessagesModule(),
              const MessageHeaderModule(),
              const MessageListModule(),
              const MessageComposerModule(),
            ],
          ),
        ),
      ),
    );
  }
}
