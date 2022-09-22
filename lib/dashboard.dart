import 'package:cometchat_flutter_sample_app/conversations/conversations_dashboard.dart';
import 'package:cometchat_flutter_sample_app/groups/groups_dashboard.dart';
import 'package:cometchat_flutter_sample_app/shared/shared_dashboard.dart';
import 'package:cometchat_flutter_sample_app/users/users_dashboard.dart';
import 'package:cometchat_flutter_sample_app/utils/alert.dart';
import 'package:cometchat_flutter_sample_app/utils/module_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_ui_kit/flutter_chat_ui_kit.dart';

import 'messages/messages_dashboard.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffeeeeee),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 2, 10, 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "UI Components",
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                        onPressed: () {
                          Alert.showLoadingIndicatorDialog(context);
                          logout();
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(Icons.power_settings_new_rounded))
                  ],
                ),
              ),
              ModuleCard(
                title: "Chats",
                description:
                    "Conversation Module helps you list the recent conversations between your users and groups. To learn more about this component click here",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ConversationDashboard()),
                  );
                },
              ),
              ModuleCard(
                title: "Messages",
                description:
                    "Messages module helps you to send and receive in a conversation between a user and a group . To learn more about this component click here",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const MessagesDashboard()),
                  );
                },
              ),
              ModuleCard(
                title: "Users",
                description:
                    "Users Module helps you list all the users available in your app . To learn more about this component click here",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const UsersDashboard()),
                  );
                },
              ),
              ModuleCard(
                title: "Groups",
                description:
                    "Groups Module helps you list all the groups you are part of in your app. To learn more about this component click here",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const GroupsDashboard()),
                  );
                },
              ),
              ModuleCard(
                title: "Shared",
                description:
                    "Shared module contains several reusable components that are divided into Primary, Secondary and SDK derived components. To learn more about this component click here",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SharedDashboard()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> logout() async {
    await CometChat.logout(onSuccess: (onSuccess) {}, onError: (_) {});
  }
}
