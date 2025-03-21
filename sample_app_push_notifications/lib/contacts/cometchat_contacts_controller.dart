import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../utils/join_protected_group_util.dart';
import '../utils/page_manager.dart';

class CometChatContactsController extends GetxController {
  //--------------------Constructor-----------------------
  CometChatContactsController({
    this.tabVisibility = TabVisibility.usersAndGroups,
  }) : super();

  //-------------------------Variable Declaration-----------------------------

  int index = 0;
  late List<Widget> currentView;
  late TabController tabController;
  String tabType = CometChatStartConversationType.user;
  late BuildContext context;
  final TabVisibility tabVisibility;
  String? dateTime;

  late PageManager _pageController;

  _onItemTap({context, User? user, Group? group}) {
    if (user != null) {
      _pageController.navigateToMessages(
        context: context,
        user: user,
      );
    } else if (group != null) {
      final colorPalette = CometChatThemeHelper.getColorPalette(context);
      final typography = CometChatThemeHelper.getTypography(context);
      final spacing = CometChatThemeHelper.getSpacing(context);

      JoinProtectedGroupUtils.onGroupItemTap(context, group, colorPalette,
          typography, spacing, _pageController.selectedIndex);
    }
  }

  //-------------------------LifeCycle Methods-----------------------------
  @override
  void onInit() {
    _pageController = Get.find<PageManager>();
    dateTime = DateTime.now().microsecondsSinceEpoch.toString();
    currentView = [
      if (tabVisibility == TabVisibility.usersAndGroups ||
          tabVisibility == TabVisibility.users)
        CometChatUsers(
          hideAppbar: true,
          onItemTap: (context, user) {
            _onItemTap(context: context, user: user);
          },
        ),
      if (tabVisibility == TabVisibility.usersAndGroups ||
          tabVisibility == TabVisibility.groups)
        CometChatGroups(
          hideAppbar: true,
          onItemTap: (context, group) {
            _onItemTap(context: context, group: group);
          },
        ),
    ];
    super.onInit();
  }

  @override
  void dispose() {
    super.dispose();
    tabController.dispose();
    Get.delete<CometChatUsersController>(tag: dateTime);
    Get.delete<CometChatGroupsController>(tag: dateTime);
  }

  /// Tab controller listener
  void tabControllerListener() {
    if (tabController.index == 0) {
      tabType = CometChatStartConversationType.user;
    } else if (tabController.index == 1) {
      tabType = CometChatStartConversationType.group;
    }
    update();
  }
}
