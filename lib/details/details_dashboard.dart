import 'package:cometchat_flutter_sample_app/utils/widget_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_ui_kit/flutter_chat_ui_kit.dart';

class DetailsDashboard extends StatelessWidget {
  const DetailsDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<WidgetProps> moduleList = [
      WidgetProps(
        leadingImageURL: "assets/icons/user.png",
        leadingImageDimensions: 36,
        title: "User",
        description: "CometChatDetails component for a user "
            "To learn more about this component tap here",
        onTap: () {
          User _user = User(
              name: 'Kevin',
              uid: 'UID233',
              avatar:
                  "https://data-us.cometchat.io/assets/images/avatars/spiderman.png",
              role: "test",
              status: "online",
              statusMessage: "This is now status");

          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Scaffold(
                    body: Center(
                  child: CometChatDetails(user: _user),
                )),
              ));
        },
      ),
      WidgetProps(
        leadingImageURL: "assets/icons/group.png",
        title: "Group",
        description: "CometChatDetails component for a group "
            "To learn more about this component tap here",
        onTap: () {
          Group _group = Group(
              guid: "supergroup",
              owner: "superhero1",
              name: "Comic Hero's Hangout",
              icon:
                  "https://data-us.cometchat.io/assets/images/avatars/supergroup.png",
              description: "null",
              hasJoined: true,
              membersCount: 4,
              createdAt: DateTime.now(),
              joinedAt: DateTime.now(),
              updatedAt: DateTime.now(),
              type: "private");

          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Scaffold(
                    body: Center(
                  child: CometChatDetails(group: _group),
                )),
              ));
        },
      )
    ];

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
                      "CometChatDetails",
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              WidgetCard(
                widgets: moduleList,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
