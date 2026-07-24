import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../cometchat_chat_uikit.dart';

import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart' as kit;

///[CometChatGroupsController] is the view model for [CometChatGroups]
///it contains all the business logic involved in changing the state of the UI of [CometChatGroups]
class CometChatGroupsController
    extends CometChatSearchListController<Group, String>
    with
        CometChatSelectable,
        CometChatGroupEventListener,
        GroupListener,
        ConnectionListener,
        WidgetsBindingObserver {
  //Class members
  late GroupsBuilderProtocol groupsBuilderProtocol;
  late String dateStamp;
  late BuildContext context;
  late String groupSDKListenerID;
  late String groupUIListenerID;

  //Constructor
  CometChatGroupsController({
    required this.groupsBuilderProtocol,
    this.groupTypeVisibility = true,
    SelectionMode? mode,
    super.onError,
    super.onEmpty,
    super.onLoad,
  }) : super(builderProtocol: groupsBuilderProtocol) {
    selectionMode = mode ?? SelectionMode.none;
    dateStamp = DateTime.now().microsecondsSinceEpoch.toString();

    groupSDKListenerID = "${dateStamp}group_sdk_listener";
    groupUIListenerID = "${dateStamp}_ui_FromGroup_listener";
  }

  bool? groupTypeVisibility;

  CometChatColorPalette? colorPalette;
  CometChatSpacing? spacing;
  CometChatTypography? typography;

  /// Cancellable retry timer for connection recovery
  Timer? _retryTimer;

  //initialization functions
  @override
  void onInit() {
    CometChatGroupEvents.addGroupsListener(groupUIListenerID, this);
    CometChat.addGroupListener(groupSDKListenerID, this);
    CometChat.addConnectionListener(groupSDKListenerID, this);
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      WidgetsBinding.instance.addObserver(this);
    }
    super.onInit();
  }

  @override
  void onClose() {
    _retryTimer?.cancel();
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      WidgetsBinding.instance.removeObserver(this);
    }
    CometChat.removeGroupListener(groupSDKListenerID);
    CometChatGroupEvents.removeGroupsListener(groupUIListenerID);
    CometChat.removeConnectionListener(groupSDKListenerID);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && hasError && !isLoading) {
      resetGroups();
    }
  }

  @override
  bool match(Group elementA, Group elementB) {
    return elementA.guid == elementB.guid;
  }

  @override
  String getKey(Group element) {
    return element.guid;
  }

  @override
  void ccGroupCreated(Group group) {
    addElement(group);
  }

  @override
  void ccGroupMemberJoined(User joinedUser, Group joinedGroup) {
    updateElement(joinedGroup);
  }

  @override
  ccOwnershipChanged(Group group, GroupMember newOwner) {
    updateElement(group);
  }

  @override
  void ccGroupMemberAdded(
    List<kit.Action> messages,
    List<User> usersAdded,
    Group groupAddedIn,
    User addedBy,
  ) {
    updateElement(groupAddedIn);
  }

  @override
  ccGroupLeft(kit.Action message, User leftUser, Group leftGroup) {
    if (leftGroup.type == GroupTypeConstants.private) {
      removeElement(leftGroup);
    } else {
      leftGroup.hasJoined = false;
      leftGroup.scope = null;
      updateElement(leftGroup);
    }
  }

  @override
  void ccGroupMemberBanned(
    kit.Action message,
    User bannedUser,
    User bannedBy,
    Group bannedFrom,
  ) {
    updateElement(bannedFrom);
  }

  @override
  onGroupMemberKicked(
    kit.Action action,
    User kickedUser,
    User kickedBy,
    Group kickedFrom,
  ) {
    updateElement(kickedFrom);
  }

  @override
  onGroupMemberJoined(kit.Action action, User joinedUser, Group joinedGroup) {
    updateElement(joinedGroup);
  }

  @override
  onGroupMemberLeft(kit.Action action, User leftUser, Group leftGroup) {
    updateElement(leftGroup);
  }

  @override
  onGroupMemberBanned(
    kit.Action action,
    User bannedUser,
    User bannedBy,
    Group bannedFrom,
  ) {
    updateElement(bannedFrom);
  }

  @override
  onGroupMemberScopeChanged(
    kit.Action action,
    User updatedBy,
    User updatedUser,
    String scopeChangedTo,
    String scopeChangedFrom,
    Group group,
  ) {
    updateElement(group);
  }

  @override
  onMemberAddedToGroup(
    kit.Action action,
    User addedby,
    User userAdded,
    Group addedTo,
  ) {
    int matchedIndex;
    matchedIndex = getMatchingIndex(addedTo);
    if (matchedIndex == -1) {
      //TODO: once hasJoined has been fixed in sdk the following override will be removed
      addedTo.hasJoined = true;
      addElement(addedTo);
    } else {
      updateElement(addedTo);
    }
  }

  @override
  void ccGroupDeleted(Group group) {
    removeElement(group);
  }

  @override
  void ccGroupMemberKicked(
    kit.Action message,
    User kickedUser,
    User kickedBy,
    Group kickedFrom,
  ) {
    updateElement(kickedFrom);
  }

  //TODO: once hasJoined has been fixed in sdk the following override will be removed
  @override
  updateElement(Group element, {int? index}) {
    int matchedIndex;
    if (index == null) {
      matchedIndex = getMatchingIndex(element);
    } else {
      matchedIndex = index;
    }
    if (matchedIndex != -1) {
      list[matchedIndex].hasJoined = element.hasJoined;
    }
    super.updateElement(element, index: matchedIndex);
  }

  @override
  void onConnected() {
    if (hasError) {
      resetGroups();
    } else if (!isLoading) {
      request = groupsBuilderProtocol.getRequest();
      list = [];
      loadMoreElements();
    }
  }

  void clearSelection() {
    selectionMap.clear();
    update();
  }

  dynamic resetGroups({int retryCount = 0}) {
    _retryTimer?.cancel();
    // reset values
    list.clear();
    error = null;
    hasError = false;
    hasMoreItems = true;
    isFetching = false;
    isLoading = true;
    request = groupsBuilderProtocol.getRequest();
    update();
    loadMoreElements().then((_) {
      if (hasError && retryCount < 3) {
        _retryTimer = Timer(const Duration(seconds: 2), () {
          if (hasError) {
            resetGroups(retryCount: retryCount + 1);
          }
        });
      }
    });
  }

  bool hideGroupIconVisibility(Group? group) {
    return group != null && (groupTypeVisibility != true);
  }

  // Function to show pop-up menu on long press
  void showPopupMenu(
    BuildContext context,
    List<CometChatOption> options,
    GlobalKey widgetKey,
  ) {
    if (options.isEmpty) {
      return;
    }
    RelativeRect? position = WidgetPositionUtil.getWidgetPosition(
      context,
      widgetKey,
    );
    showMenu(
      context: context,
      position: position ?? const RelativeRect.fromLTRB(0, 0, 0, 0),
      shadowColor: colorPalette?.background1 ?? Colors.transparent,
      color: colorPalette?.transparent ?? Colors.transparent,
      menuPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(spacing?.radius2 ?? 0),
        side: BorderSide(
          color: colorPalette?.borderLight ?? Colors.transparent,
          width: 1,
        ),
      ),
      items: options.map((CometChatOption option) {
        return CustomPopupMenuItem<CometChatOption>(
          value: option,
          child: GetMenuView(option: option),
        );
      }).toList(),
    ).then((selectedOption) {
      if (selectedOption != null) {
        selectedOption.onClick?.call();
      }
    });
  }
}
