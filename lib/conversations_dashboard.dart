import 'package:cometchat_flutter_sample_app/contacts/contacts_module.dart';
import 'package:cometchat_flutter_sample_app/conversations/conversations_module.dart';
import 'package:cometchat_flutter_sample_app/conversations_with_messages/conversations_with_mesages_module.dart';
import 'package:flutter/material.dart';

class ConversationsDashboard extends StatelessWidget {
  const ConversationsDashboard({Key? key}) : super(key: key);

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
                      "Conversations",
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              // WidgetCard(
              //   widgets: moduleList,
              // ),
              const ConversationModule(),
              const ConversationsWithMessagesModule(),
              const ContactsModule(),
            ],
          ),
        ),
      ),
    );
  }
}
