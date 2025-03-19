import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';
import 'package:get/get_state_manager/get_state_manager.dart';

import '../messages/messages.dart';

///[CometChatJoinProtectedGroupController] is the view model for [CometChatJoinProtectedGroup]
///it contains all the business logic involved in changing the state of the UI of [CometChatJoinProtectedGroup]
class CometChatJoinProtectedGroupController extends GetxController {
  CometChatJoinProtectedGroupController({
    required this.group,
  });

  ///[group] the group to join
  final Group group;
  final GlobalKey<FormState> passwordsFieldKey = GlobalKey<FormState>();

  final TextEditingController textEditingController = TextEditingController();

  String groupPassword = '';

  bool isLoading = false;

  bool isEmpty = false;
  bool isError = false;

  onEmpty(bool val) {
    isEmpty = val;
    update();
  }

  String getGroupName(BuildContext context) {
    final String groupName = group.name;

    if (groupName.isNotEmpty) {
      return '$groupName ${Translations.of(context).group}';
    } else {
      return Translations.of(context).protectedGroup;
    }
  }

  onPasswordChange(String val) {
    groupPassword = val;
    update();
  }

  _joinGroup(
      {required String guid,
      required String groupType,
      String password = "",
      required context}) {
    isLoading = true;
    update();
    CometChat.joinGroup(
      guid,
      groupType,
      password: password,
      onSuccess: (Group group) async {
        isLoading = false;
        isError = false;
        Navigator.pop(context);
        if (kDebugMode) {
          debugPrint("Group Joined Successfully : $group ");
        }
        User? user = await CometChat.getLoggedInUser();
        if (group.hasJoined == false) {
          group.hasJoined = true;
        }
        CometChatGroupEvents.ccGroupMemberJoined(user!, group);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return MessagesSample(
                group: group,
              );
            },
          ),
        );
      },
      onError: (CometChatException e) {
        isLoading = false;
        isError = true;
        update();
        debugPrint("Group Joining failed with exception: ${e.message}");
      },
    );
  }

  requestJoinGroup(context) async {
    if (passwordsFieldKey.currentState!.validate()) {
      final String guid = group.guid;
      _joinGroup(
        guid: guid,
        groupType: GroupTypeConstants.password,
        password: textEditingController.text,
        context: context,
      );
    }
  }
}
