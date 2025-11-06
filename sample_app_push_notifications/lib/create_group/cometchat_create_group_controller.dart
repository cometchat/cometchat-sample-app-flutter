import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sample_app_push_notifications/messages/messages.dart';

class CometChatCreateGroupController extends GetxController {
  BuildContext? context;
  late TabController tabController;

  CometChatCreateGroupController() {
    tag = "tag$counter";
    counter++;
  }

  @override
  void dispose() {
    super.dispose();
    tabController.dispose();
  }

  void tabControllerListener() {
    if (tabController.index == 0) {
      groupType = GroupTypeConstants.public;
    } else if (tabController.index == 1) {
      groupType = GroupTypeConstants.private;
    } else if (tabController.index == 2) {
      groupType = GroupTypeConstants.password;
    }
    update();
  }

  static int counter = 0;
  late String tag;

  String groupType = GroupTypeConstants.public;

  String groupName = '';

  String groupPassword = '';

  bool isLoading = false;

  bool isEmpty = false;
  bool isError = false;

  onPasswordChange(String val) {
    groupPassword = val;
    update();
  }

  onNameChange(String val) {
    groupName = val;
    update();
  }

  onEmpty(bool val) {
    isEmpty = val;
    update();
  }

  createGroup(BuildContext context, CometChatColorPalette colorPalette, CometChatTypography typography, CometChatSpacing spacing,) async {
    String gUid = "group_${DateTime.now().millisecondsSinceEpoch.toString()}";

    isLoading = true;

    update();

    Group group = Group(
        guid: gUid,
        name: groupName,
        type: groupType,
        hasJoined: true,
        password:
        groupType == GroupTypeConstants.password ? groupPassword : null);
    CometChat.createGroup(
        group: group,
        onSuccess: (Group group) {
          if (kDebugMode) {
            debugPrint("Group Created Successfully : $group ");
          }
          isLoading = false;
          isError = false;
          Navigator.pop(context);
          CometChatGroupEvents.ccGroupCreated(group);
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
          debugPrint("Group Creation failed with exception: ${e.message}");
        });
  }
}