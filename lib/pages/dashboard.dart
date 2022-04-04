import 'package:cometchat/cometchat_sdk.dart';
import 'package:flutter/material.dart';
import 'package:sdk_tutorial/constants.dart';
import 'package:sdk_tutorial/pages/conversation_list.dart';
import 'package:sdk_tutorial/pages/group/group_list.dart';
import 'package:sdk_tutorial/pages/users/update_user.dart';
import 'package:sdk_tutorial/pages/users/user_list.dart';

import '../Utils/loading_indicator.dart';

class DashBoard extends StatelessWidget {
  const DashBoard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await CometChat.logout(
            onError: (CometChatException exception) {},
            onSuccess: (Map<String, Map<String, int>> message) {});
        Navigator.of(context).pop();
        USERID = "";
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("SDK Tutorial"),
          actions: [
            PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == 'Update Profile') {
                  User? loggedInUser = await CometChat.getLoggedInUser();
                  if (loggedInUser != null) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => UpdateUser(
                                  user: loggedInUser,
                                  updateLoggedInUser: true,
                                )));
                  }
                } else if (value == 'Logout') {
                  showLoadingIndicatorDialog(context);
                  await CometChat.logout(
                      onError: (CometChatException exception) {},
                      onSuccess: (Map<String, Map<String, int>> message) {});
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                  USERID = "";
                }
              },
              itemBuilder: (BuildContext context) {
                return {'Update Profile', 'Logout'}.map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
                }).toList();
              },
            )
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              //-------Conversation List-------
              SizedBox(
                height: 72,
                child: Card(
                  elevation: 5,
                  child: Center(
                    child: ListTile(
                      leading: Icon(Icons.chat),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const ConversationList()));
                      },
                      title: const Text("Conversation List"),
                    ),
                  ),
                ),
              ),

              //-------User List-------
              SizedBox(
                height: 72,
                child: Card(
                  elevation: 5,
                  child: Center(
                    child: ListTile(
                      leading: Icon(Icons.people),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const CometChatUserList(
                                      navigateFrom: NavigateFrom.userList,
                                    )));
                      },
                      title: const Text("User List"),
                    ),
                  ),
                ),
              ),

              //-------Group List-------
              SizedBox(
                height: 72,
                child: Card(
                  elevation: 5,
                  child: Center(
                    child: ListTile(
                      leading: Icon(Icons.groups),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const CometChatGroupList()));
                      },
                      title: const Text("Group List"),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
