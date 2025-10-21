import 'package:cometchat_calls_uikit/cometchat_calls_uikit.dart';
import 'package:cometchat_calls_uikit/cometchat_calls_uikit.dart' as cc;
import 'package:get/get.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';
import 'package:flutter/material.dart';

class CometChatMessagesController extends GetxController
    with
        UserListener,
        CometChatUserEventListener,
        GroupListener,
        CometChatGroupEventListener {
  CometChatMessagesController(
    this.user,
    this.group,
  ) {
    tag = "tag$counter";
    counter++;
  }

  static int counter = 0;
  late String tag;

  User? user;
  Group? group;

  late String _dateString;
  late String _userListener;
  late String _groupListener;
  late String _uiGroupListener;
  late BuildContext context;

  var isDeleteLoading = false.obs;
  var isBlockLoading = false.obs;

  int membersCount = 1;

  User? loggedInUser;

  Conversation? _conversation;

  String? _conversationId;

  bool? disableUsersPresence;

  //initialization methods--------------

  String presence = "";

  bool isUserBlocked = false;

  @override
  void onInit() {
    _dateString = DateTime.now().millisecondsSinceEpoch.toString();
    _userListener = "${_dateString}UsersListener";
    _groupListener = "${_dateString}GroupsListener";
    _uiGroupListener = "${_dateString}UIGroupListener";
    _addListeners();
    initializeLoggedInUser();
    userIsNotBlocked();
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
      presence = CometChatUserStatus.online;
      this.user?.status = CometChatUserStatus.online;
      update();
    }
  }

  @override
  void onUserOffline(User user) {
    if (this.user != null && user.uid == this.user?.uid) {
      presence = "";
      this.user?.status = CometChatUserStatus.offline;
      update();
    }
  }

  //------------View Methods-------------------

  _onUnBlockUser() {
    if (user == null) return;
    isBlockLoading.value = true;
    CometChat.unblockUser(
      [user!.uid],
      onSuccess: (Map<String, dynamic> map) {
        isBlockLoading.value = false;
        if (user != null) {
          user!.blockedByMe = false;
          update();
        }
        userIsNotBlocked();
        CometChatUserEvents.ccUserUnblocked(user!);
      },
      onError: (e) {
        isBlockLoading.value = false;
        debugPrint("Error blocking user: $e");
      },
    );
  }

  unBlockUser() async {
    if (user != null) {
      if (loggedInUser == null) return;
      _onUnBlockUser();
    }
  }

  bool userIsNotBlocked() {
    isUserBlocked = user != null &&
        (user?.blockedByMe != true && user?.hasBlockedMe != true);
    update();
    return isUserBlocked;
  }

  @override
  void ccUserBlocked(User user) {
    if (user.uid == this.user?.uid) {
      this.user?.blockedByMe = true;
      userIsNotBlocked();
      update();
    }
  }

  @override
  void ccUserUnblocked(User user) {
    if (user.uid == this.user?.uid) {
      this.user?.blockedByMe = false;
      userIsNotBlocked();
      update();
    }
  }

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
      group = kickedFrom;
      update();
    }
  }

  @override
  void onGroupMemberBanned(
      cc.Action action, User bannedUser, User bannedBy, Group bannedFrom) {
    if (bannedFrom.guid == group?.guid) {
      membersCount = bannedFrom.membersCount;
      group = bannedFrom;
      update();
    }
  }

  @override
  void onGroupMemberLeft(cc.Action action, User leftUser, Group leftGroup) {
    if (leftGroup.guid == group?.guid) {
      membersCount = leftGroup.membersCount;
      group = leftGroup;
      update();
    }
  }

  @override
  void onMemberAddedToGroup(
      cc.Action action, User addedby, User userAdded, Group addedTo) {
    if (addedTo.guid == group?.guid) {
      membersCount = addedTo.membersCount;
      group = addedTo;
      group?.hasJoined = true;
      update();
    }
  }

  @override
  void onGroupMemberJoined(
      cc.Action action, User joinedUser, Group joinedGroup) {
    if (joinedGroup.guid == group?.guid) {
      membersCount = joinedGroup.membersCount;
      group = joinedGroup;
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
      group = bannedFrom;
      update();
    }
  }

  @override
  void ccGroupMemberKicked(
      cc.Action message, User kickedUser, User kickedBy, Group kickedFrom) {
    if (group?.guid == kickedFrom.guid) {
      membersCount = kickedFrom.membersCount;
      group = kickedFrom;
      update();
    }
  }

  @override
  void ccGroupMemberAdded(List<cc.Action> messages, List<User> usersAdded,
      Group groupAddedIn, User addedBy) {
    if (groupAddedIn.guid == group?.guid) {
      membersCount = groupAddedIn.membersCount;
      group = groupAddedIn;
      update();
    }
  }
}
