import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sample_app_push_notifications/utils/page_manager.dart';

import '../join_protected_group/cometchat_join_protected_group.dart';

class JoinProtectedGroupUtils {
  static void navigateToJoinProtectedGroupScreen({
    required Group group,
    required BuildContext context,
    required CometChatColorPalette colorPalette,
    required CometChatTypography typography,
    required CometChatSpacing spacing,
  }) {
    showJoinProtectedGroup(
      context: context,
      colorPalette: colorPalette,
      typography: typography,
      spacing: spacing,
      group: group,
    );
  }

  static void joinGroup({
    required context,
    required String guid,
    required String groupType,
    String password = "",
    required CometChatColorPalette colorPalette,
    required CometChatTypography typography,
    required CometChatSpacing spacing,
  }) {
    _showLoaderDialog(context, colorPalette, typography, spacing);
    CometChat.joinGroup(
      guid,
      groupType,
      password: password,
      onSuccess: (Group group) async {
        User? user = await CometChat.getLoggedInUser();
        if (kDebugMode) debugPrint("Group Joined Successfully: $group");

        Navigator.pop(context); // Dismiss loading dialog
        //ToDo: remove after sdk issue solve
        if (group.hasJoined == false) {
          group.hasJoined = true;
        }

        CometChatGroupEvents.ccGroupMemberJoined(user!, group);

        _navigateToMessages(
          group: group,
          user: user,
          context: context,
          colorPalette: colorPalette,
          typography: typography,
          spacing: spacing,
        );
      },
      onError: (CometChatException e) {
        Navigator.pop(context);
        _showSnackBar(
            context, "Error, Unable to join group.", colorPalette, typography);
        if (kDebugMode) debugPrint("Group join error: $e");
      },
    );
  }

  static void onGroupItemTap(
    BuildContext context,
    Group group,
    CometChatColorPalette colorPalette,
    CometChatTypography typography,
    CometChatSpacing spacing,
    int id,
  ) {
    if (group.hasJoined) {
      _navigateToMessages(
        group: group,
        context: context,
        colorPalette: colorPalette,
        typography: typography,
        spacing: spacing,
      );
    } else if (group.type == GroupTypeConstants.password) {
      navigateToJoinProtectedGroupScreen(
        group: group,
        context: context,
        colorPalette: colorPalette,
        typography: typography,
        spacing: spacing,
      );
    } else if (group.type == GroupTypeConstants.public) {
      joinGroup(
        guid: group.guid,
        groupType: group.type,
        context: context,
        colorPalette: colorPalette,
        typography: typography,
        spacing: spacing,
      );
    }
  }

  static void _showLoaderDialog(
    BuildContext context,
    CometChatColorPalette colorPalette,
    CometChatTypography typography,
    CometChatSpacing spacing,
  ) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => AlertDialog(
        shape: RoundedRectangleBorder(
          side:
              BorderSide(color: colorPalette.borderLight ?? Colors.transparent),
          borderRadius: BorderRadius.circular(spacing.radius4 ?? 0),
        ),
        backgroundColor: colorPalette.background1,
        content: SizedBox(
          height: 30,
          width: 30,
          child: Center(
            child: CircularProgressIndicator(color: colorPalette.iconHighlight),
          ),
        ),
      ),
    );
  }

  static void _showSnackBar(
    BuildContext context,
    String message,
    CometChatColorPalette colorPalette,
    CometChatTypography typography,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: colorPalette.error,
        content: Text(
          message,
          style: TextStyle(
            color: colorPalette.white,
            fontSize: typography.button?.medium?.fontSize,
            fontWeight: typography.button?.medium?.fontWeight,
            fontFamily: typography.button?.medium?.fontFamily,
          ),
        ),
      ),
    );
  }

  static void _navigateToMessages({
    User? user,
    Group? group,
    required BuildContext context,
    required CometChatColorPalette colorPalette,
    required CometChatTypography typography,
    required CometChatSpacing spacing,
  }) {
    final pageManager = Get.find<PageManager>();
    pageManager.navigateToMessages(context: context, group: group);
  }
}
