import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart' as cc;
import 'package:flutter/material.dart';
import 'package:sample_app/banned_members/cometchat_banned_members.dart';
import 'package:sample_app/transfer_ownership/cometchat_transfer_ownership.dart';

import '../add_memebers/cometchat_add_members.dart';

class CometChatGroupInfoController extends GetxController
    with
        UserListener,
        GroupListener,
        CometChatGroupEventListener,
        CometChatUserEventListener {
  CometChatGroupInfoController(
    this.user,
    this.group,
    this.colorPalette,
    this.typography,
    this.spacing,
  );

  final User? user;

  final CometChatColorPalette colorPalette;
  final CometChatTypography typography;
  final CometChatSpacing spacing;

  Group? group;

  late String _dateString;
  late String _userListener;
  late String _groupListener;
  late String _uiGroupListener;
  late BuildContext context;

  var isDeleteLoading = false.obs;
  var isLeaveGroupLoading = false.obs;

  int membersCount = 1;

  User? loggedInUser;

  Conversation? _conversation;

  String? _conversationId;

  bool? disableUsersPresence;

  //initialization methods--------------

  @override
  void onInit() {
    _dateString = DateTime.now().millisecondsSinceEpoch.toString();
    _userListener = "${_dateString}UsersListener";
    _groupListener = "${_dateString}GroupsListener";
    _uiGroupListener = "${_dateString}UIGroupListener";
    _addListeners();
    initializeLoggedInUser();
    if (group != null && group?.membersCount != null) {
      membersCount = group?.membersCount ?? 1;
    }
    super.onInit();
  }

  initializeLoggedInUser() async {
    if (loggedInUser == null) {
      loggedInUser = await CometChat.getLoggedInUser();
      String id;
      String conversationType;
      if (user != null) {
        id = user!.uid;
        conversationType = ConversationType.user;
      } else {
        id = group!.guid;
        conversationType = ConversationType.group;
      }
      _conversation ??= (await CometChat.getConversation(id, conversationType,
          onSuccess: (conversation) {
        if (conversation.lastMessage != null) {}
      }, onError: (_) {}));
      _conversationId ??= _conversation?.conversationId;
      update();
    }
  }

  @override
  void onClose() {
    _removeListeners();
    super.onClose();
  }

  _addListeners() {
    CometChat.addUserListener(_userListener, this);
    CometChatUserEvents.addUsersListener(_userListener, this);
    CometChat.addGroupListener(_groupListener, this);
    CometChatGroupEvents.addGroupsListener(_uiGroupListener, this);
  }

  _removeListeners() {
    CometChat.removeUserListener(_userListener);
    CometChat.removeGroupListener(_groupListener);
    CometChatGroupEvents.removeGroupsListener(_uiGroupListener);
    CometChatUserEvents.removeUsersListener(_userListener);
  }

  //initialization methods end--------------

  //--------SDK User Listeners

  @override
  void onUserOnline(User user) {
    if (this.user != null && user.uid == this.user?.uid) {
      this.user?.status = CometChatUserStatus.online;
    }
    update();
  }

  @override
  void onUserOffline(User user) {
    if (this.user != null && user.uid == this.user?.uid) {
      this.user?.status = CometChatUserStatus.offline;
    }
    update();
  }

  //------------------SDK user listeners end---------

  //-----------Group SDK listeners---------------------------------
  @override
  void onGroupMemberScopeChanged(
      cc.Action action,
      User updatedBy,
      User updatedUser,
      String scopeChangedTo,
      String scopeChangedFrom,
      Group group) {
    if (group.guid == this.group?.guid &&
        updatedUser.uid == loggedInUser?.uid) {
      this.group?.scope = scopeChangedTo;
      update();
    }
  }

  @override
  void onGroupMemberKicked(
      cc.Action action, User kickedUser, User kickedBy, Group kickedFrom) {
    if (kickedFrom.guid == group?.guid) {
      membersCount = kickedFrom.membersCount;
      update();
    }
  }

  @override
  void onGroupMemberBanned(
      cc.Action action, User bannedUser, User bannedBy, Group bannedFrom) {
    if (bannedFrom.guid == group?.guid) {
      membersCount = bannedFrom.membersCount;
      update();
    }
  }

  @override
  void onGroupMemberLeft(cc.Action action, User leftUser, Group leftGroup) {
    if (leftGroup.guid == group?.guid) {
      membersCount = leftGroup.membersCount;
      update();
    }
  }

  @override
  void onMemberAddedToGroup(
      cc.Action action, User addedby, User userAdded, Group addedTo) {
    if (addedTo.guid == group?.guid) {
      membersCount = addedTo.membersCount;
      update();
    }
  }

  @override
  void onGroupMemberJoined(
      cc.Action action, User joinedUser, Group joinedGroup) {
    if (joinedGroup.guid == group?.guid) {
      membersCount = joinedGroup.membersCount;
      update();
    }
  }

  @override
  void ccOwnershipChanged(Group group, GroupMember newOwner) {
    if (group.guid == this.group?.guid) {
      this.group?.owner = newOwner.uid;
      update();
    }
  }

  //-------------Group SDK listeners end---------------

  //From UI listeners

  @override
  void ccGroupMemberBanned(
      cc.Action message, User bannedUser, User bannedBy, Group bannedFrom) {
    if (group?.guid == bannedFrom.guid) {
      membersCount = bannedFrom.membersCount;
      update();
    }
  }

  @override
  void ccGroupMemberKicked(
      cc.Action message, User kickedUser, User kickedBy, Group kickedFrom) {
    if (group?.guid == kickedFrom.guid) {
      membersCount = kickedFrom.membersCount;
      update();
    }
  }

  @override
  void ccGroupMemberAdded(List<cc.Action> messages, List<User> usersAdded,
      Group groupAddedIn, User addedBy) {
    if (groupAddedIn.guid == group?.guid) {
      membersCount = groupAddedIn.membersCount;
      update();
    }
  }


  _leaveGroup({String? value}) async {
    if (group != null) {
      if (loggedInUser == null) return;

      if (group!.owner == loggedInUser?.uid) {
        debugPrint("Owner cannot leave group");
      } else {
        _onLeaveGroupConfirmed(value);
      }
    }
  }


  _onLeaveGroupConfirmed(String? value) {
    if (group == null) return;
    isLeaveGroupLoading.value = true;
    CometChat.leaveGroup(
      group!.guid,
      onSuccess: (String response) {
        isLeaveGroupLoading.value = false;
        group?.membersCount--;
        CometChatGroupEvents.ccGroupLeft(
            cc.Action(
              conversationId: _conversationId!,
              message: '${loggedInUser?.name} left',
              oldScope: group!.scope ?? GroupMemberScope.participant,
              newScope: '',
              muid: DateTime.now().microsecondsSinceEpoch.toString(),
              sender: loggedInUser!,
              receiverUid: group!.guid,
              type: MessageTypeConstants.groupActions,
              receiverType: ReceiverTypeConstants.group,
              parentMessageId: 0,
            ),
            loggedInUser!,
            group!);
        membersCount = group!.membersCount;
        if(value == "LeaveGroup") {
          Navigator.of(context)..pop()..pop();
          return;
        }
        Navigator.of(context)..pop()..pop()..pop();
      },
      onError: (excep) {
        isLeaveGroupLoading.value = false;
        try {
          isDeleteLoading.value = false;
          Navigator.of(context).pop();
          var snackBar = SnackBar(
            backgroundColor: colorPalette.error,
            content: Text(
              "Error, Unable to leave group",
              style: TextStyle(
                color: colorPalette.white,
                fontSize: typography.button?.medium?.fontSize,
                fontWeight: typography.button?.medium?.fontWeight,
                fontFamily: typography.button?.medium?.fontFamily,
              ),
            ),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        } catch (e) {
          if (kDebugMode) {
            debugPrint("Error while displaying snackBar: $e");
          }
        }
        debugPrint("Error Leaving Group: $excep");
      },
    );
  }

  _onDeleteGroupConfirmed() {
    if (group == null) return;
    isDeleteLoading.value = true;
    CometChat.deleteGroup(
      group!.guid,
      onSuccess: (String message) {
        isDeleteLoading.value = false;
        CometChatGroupEvents.ccGroupDeleted(group!);
        Navigator.of(context).pop(1);
        Navigator.of(context).pop();
        Navigator.of(context).pop();
      },
      onError: (excep) {
        try {
          isDeleteLoading.value = false;
          Navigator.of(context).pop();
          var snackBar = SnackBar(
            backgroundColor: colorPalette.error,
            content: Text(
              "Error, Unable to delete group",
              style: TextStyle(
                color: colorPalette.white,
                fontSize: typography.button?.medium?.fontSize,
                fontWeight: typography.button?.medium?.fontWeight,
                fontFamily: typography.button?.medium?.fontFamily,
              ),
            ),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        } catch (e) {
          if (kDebugMode) {
            debugPrint("Error while displaying snackBar: $e");
          }
        }
      },
    );
  }

  bool hideUserPresence() {
    return user != null &&
        (disableUsersPresence == true || !userIsNotBlocked());
  }

  bool userIsNotBlocked() {
    return user != null &&
        user?.blockedByMe != true &&
        user?.hasBlockedMe != true;
  }

  @override
  void ccUserBlocked(User user) {
    if (user.uid == this.user?.uid) {
      this.user?.blockedByMe = true;
    }
  }

  @override
  void ccUserUnblocked(User user) {
    if (user.uid == this.user?.uid) {
      this.user?.blockedByMe = false;
    }
  }

  leaveGroupDialog({
    required CometChatColorPalette colorPalette,
    required CometChatTypography typography,
    required BuildContext context,
  }) {
    CometChatConfirmDialog(
      context: context,
      icon: Icon(
        Icons.logout,
        color: colorPalette.error,
        size: 48,
      ),
      title: Text(
        "Leave this group?",
        style: TextStyle(
          fontSize: typography.heading2?.medium?.fontSize,
          fontFamily: typography.heading2?.medium?.fontFamily,
          fontWeight: typography.heading2?.medium?.fontWeight,
          color: colorPalette.textPrimary,
        ),
      ),
      messageText: Text(
        "Are you sure you want to leave this group? You won't receive any more messages from this chat.",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: typography.body?.regular?.fontSize,
          fontFamily: typography.body?.regular?.fontFamily,
          fontWeight: typography.body?.regular?.fontWeight,
          color: colorPalette.textSecondary,
        ),
      ),
      confirmButtonText: cc.Translations.of(context).leave,
      cancelButtonText: cc.Translations.of(context).cancel,
      onConfirm: _leaveGroup,
      style: CometChatConfirmDialogStyle(
        confirmButtonBackground: colorPalette.error,
        confirmButtonTextColor: colorPalette.white,
      ),
      confirmButtonTextWidget: Obx(
        () => (isLeaveGroupLoading.value)
            ? SizedBox(
                height: 25,
                width: 25,
                child: CircularProgressIndicator(
                  color: colorPalette.white,
                ),
              )
            : Text(
                cc.Translations.of(context).leave,
                style: TextStyle(
                  color: colorPalette.white,
                  fontSize: typography.button?.medium?.fontSize,
                  fontWeight: typography.button?.medium?.fontWeight,
                  fontFamily: typography.button?.medium?.fontFamily,
                ),
              ),
      ),
    ).show();
  }

  deleteGroupDialog({
    required CometChatColorPalette colorPalette,
    required CometChatTypography typography,
    required BuildContext context,
  }) {
    CometChatConfirmDialog(
      context: context,
      icon: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Image.asset(
          AssetConstants.deleteIcon,
          color: colorPalette.error,
          package: UIConstants.packageName,
          width: 48,
          height: 48,
        ),
      ),
      title: Text(
        "Delete and Exit?",
        style: TextStyle(
          fontSize: typography.heading2?.medium?.fontSize,
          fontFamily: typography.heading2?.medium?.fontFamily,
          fontWeight: typography.heading2?.medium?.fontWeight,
          color: colorPalette.textPrimary,
        ),
      ),
      messageText: Text(
        "Are you sure you want to delete this chat and exit the group? This action cannot be undone.",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: typography.body?.regular?.fontSize,
          fontFamily: typography.body?.regular?.fontFamily,
          fontWeight: typography.body?.regular?.fontWeight,
          color: colorPalette.textSecondary,
        ),
      ),
      confirmButtonText: cc.Translations.of(context).deleteAndExit,
      cancelButtonText: cc.Translations.of(context).cancel,
      style: CometChatConfirmDialogStyle(
        confirmButtonBackground: colorPalette.error,
        confirmButtonTextColor: colorPalette.white,
      ),
      onConfirm: _onDeleteGroupConfirmed,
      intentPadding: EdgeInsets.symmetric(
        horizontal: spacing.padding2 ?? 0,
      ),
      confirmButtonTextWidget: Obx(
        () => (isDeleteLoading.value)
            ? SizedBox(
                height: 25,
                width: 25,
                child: CircularProgressIndicator(
                  color: colorPalette.white,
                ),
              )
            : Text(
                cc.Translations.of(context).deleteAndExit,
                style: TextStyle(
                  color: colorPalette.white,
                  fontSize: typography.button?.medium?.fontSize,
                  fontWeight: typography.button?.medium?.fontWeight,
                  fontFamily: typography.button?.medium?.fontFamily,
                ),
              ),
      ),
    ).show();
  }

  bool canAccessOption(String optionId) {
    String loggedInUserScope = loggedInUser?.uid == group?.owner
        ? GroupMemberScope.owner
        : group?.scope ?? GroupMemberScope.participant;

    return DetailUtils.validateDetailOptions(
        loggedInUserScope: loggedInUserScope, optionId: optionId);
  }

  onAddMemberClicked(Group group) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CometChatAddMembers(
          group: group,
        ),
      ),
    );
  }

  onBannedMembersClicked(Group? group) {
    if(group != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CometChatBannedMembers(
            group: group,
          ),
        ),
      );
    }
  }

  transferOwnershipDialog(BuildContext context,Group group, CometChatColorPalette colorPalette,
      CometChatTypography typography, CometChatSpacing spacing,
      ) {
    CometChatConfirmDialog(
      context: context,
      confirmButtonText: "Continue",
      cancelButtonText: "Cancel",
      title: const Text(
        "Ownership Transfer",
        textAlign: TextAlign.center,
      ),
      messageText: const Text(
        "Are you sure you want to transfer ownership? This can't be undone, and the new owner will take full control.",
        textAlign: TextAlign.center,
      ),
      onCancel: () {
        Navigator.pop(context);
      },
      showIcon: false,
      onConfirm: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CometChatTransferOwnership(
                group: group
            ),
          ),
        ).then(
              (value) {
            if (value != null && value == "LeaveGroup") {
              _leaveGroup(value: value);
            }
          },
        );
      },
      style: CometChatConfirmDialogStyle(
        iconColor: colorPalette.error,
        cancelButtonBackground:
        colorPalette.background1,
        confirmButtonBackground: colorPalette.primary,
        titleTextStyle: TextStyle(
          color:
          colorPalette.textPrimary,
          fontSize: typography.heading2?.medium?.fontSize,
          fontWeight: typography.heading2?.medium?.fontWeight,
          fontFamily: typography.heading2?.medium?.fontFamily,
        )
        ,
        messageTextStyle: TextStyle(
          color: colorPalette.textSecondary,
          fontSize: typography.body?.regular?.fontSize,
          fontWeight: typography.body?.regular?.fontWeight,
          fontFamily: typography.body?.regular?.fontFamily,
        ),
        confirmButtonTextStyle: TextStyle(
          color:
          colorPalette.white,
          fontSize: typography.button?.medium?.fontSize,
          fontWeight: typography.button?.medium?.fontWeight,
          fontFamily: typography.button?.medium?.fontFamily,
        ),
        cancelButtonTextStyle: TextStyle(
          color: colorPalette.textPrimary,
          fontSize: typography.button?.medium?.fontSize,
          fontWeight: typography.button?.medium?.fontWeight,
          fontFamily: typography.button?.medium?.fontFamily,
        ),
      ),
      confirmButtonTextWidget: Text(
          "Continue",
          style: TextStyle(
            color:  colorPalette.white,
            fontSize: typography.button?.medium?.fontSize,
            fontWeight: typography.button?.medium?.fontWeight,
            fontFamily: typography.button?.medium?.fontFamily,
          ),
        ),


    ).show();
  }
}
