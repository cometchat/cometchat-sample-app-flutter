import 'package:flutter/material.dart';

import '../../../cometchat_uikit_shared.dart';

class StatusIndicatorUtils {
  StatusIndicatorUtils({this.icon, this.statusIndicatorColor});

  static StatusIndicatorUtils getStatusIndicatorFromParams(
      {required BuildContext context,
      bool? isSelected,
      User? user,
      Group? group,
      GroupMember? groupMember,
      Widget? protectedGroupIcon,
      Widget? privateGroupIcon,
      Color? onlineStatusIndicatorColor,
      Color? privateGroupIconBackground,
      Color? protectedGroupIconBackground,
      bool? usersStatusVisibility,
        bool? groupTypeVisibility,
      Widget? selectIcon,
      Color? selectIconTint}) {
    Color? backgroundColor;
    Widget? icon;
    final colorPalette = CometChatThemeHelper.getColorPalette(context);
    //TODO add icons color to other icons when needed
    if (isSelected == true) {
      icon = selectIcon ??
          Icon(
            Icons.check,
            color: selectIconTint ?? Colors.white,
            size: 12,
          );
    } else if (user != null && usersStatusVisibility != true) {
      backgroundColor =
          user.status != null && user.status == UserStatusConstants.online
              ? (onlineStatusIndicatorColor)
              : null;
    } else if (group != null && groupTypeVisibility != true) {
      if (group.type == GroupTypeConstants.password) {
        backgroundColor = protectedGroupIconBackground ?? colorPalette.success;
        icon = protectedGroupIcon ??
            Icon(
              Icons.lock,
              color: colorPalette.background1,
              size: 7,
            );
      } else if (group.type == GroupTypeConstants.private) {
        backgroundColor = privateGroupIconBackground ?? colorPalette.warning;
        icon = privateGroupIcon ??
            Icon(
              Icons.shield,
              color: colorPalette.background1,
              size: 7,
            );
      }
    } else if (groupMember != null) {
      backgroundColor = groupMember.status != null &&
              groupMember.status == UserStatusConstants.online
          ? onlineStatusIndicatorColor
          : null;
    }
    StatusIndicatorUtils utility = StatusIndicatorUtils();
    utility.icon = icon;
    utility.statusIndicatorColor = backgroundColor;
    return utility;
  }

  Widget? icon;
  Color? statusIndicatorColor;
}
