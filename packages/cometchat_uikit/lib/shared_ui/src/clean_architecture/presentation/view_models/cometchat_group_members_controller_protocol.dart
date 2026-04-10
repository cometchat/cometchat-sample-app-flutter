import '../../../../cometchat_uikit_shared.dart';
import 'package:flutter/material.dart';

abstract class CometChatGroupMembersControllerProtocol
    extends CometChatSearchListControllerProtocol<GroupMember> {
  //default functions
  List<CometChatOption> defaultFunction(Group group, GroupMember member, BuildContext context,
      CometChatColorPalette colorPalette,
      CometChatTypography typography,
      CometChatSpacing spacing,
      );
}
