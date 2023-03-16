import 'package:cometchat_flutter_sample_app/utils/module_card.dart';
import 'package:cometchat_flutter_sample_app/utils/widget_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_ui_kit/flutter_chat_ui_kit.dart';
import 'package:cometchat_flutter_sample_app/add_members/add_members_module.dart';
import 'package:cometchat_flutter_sample_app/banned_members/banned_members_module.dart';
import 'package:cometchat_flutter_sample_app/create_group/create_group_module.dart';
import 'package:cometchat_flutter_sample_app/group_members/group_members_dashboard.dart';
import 'package:cometchat_flutter_sample_app/groups/groups_module.dart';
import 'package:cometchat_flutter_sample_app/groups_with_messages/groups_with_mesages_module.dart';
import 'package:cometchat_flutter_sample_app/join_protected_group/join_protected_group_module.dart';
import 'package:cometchat_flutter_sample_app/transfer_ownership/transfer_ownership_module.dart';

class GroupsDashboard extends StatelessWidget {
  const GroupsDashboard({Key? key}) : super(key: key);

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
                      "Groups",
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              // WidgetCard(
              //   widgets: moduleList,
              // ),
              const GroupsModule(),
              const GroupsWithMessagesModule(),
              const CreateGroupModule(),
              const JoinProtectedGroupModule(),
              const GroupMembersModule(),
              const AddMembersModule(),
              const TransferOwnershipModule(),
              const BannedMembersModule(),
               ModuleCard(
                title: "CometChatDetails",
                leading: Image.asset(
                  'assets/icons/account.png',
                  height: 48,
                  width: 48,
                ),
                description:
                    'This component can be used to view information about a group'
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
