import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart' as cc;
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';

class CometChatAddMembersController extends GetxController
    with
        UserListener,
        GroupListener,
        CometChatGroupEventListener,
        CometChatUserEventListener{
  CometChatAddMembersController({required this.group});

  ///[group] provide group to add members to
  final Group group;

  User? _loggedInUser;

  Conversation? _conversation;

  String? _conversationId;

  late String _dateString;
  late String _userListener;
  late String _groupListener;
  late String _uiGroupListener;

  final RxList<User> selectedUsers = <User>[].obs;

  bool isLoading = false;

  int membersCount = 1;

  // Update the list of selected users
  void updateSelectedUsers(List<User> users) {
    selectedUsers.value = users;
    update(); // Notify the UI about the changes
  }

  @override
  void onInit() {
    _dateString = DateTime.now().millisecondsSinceEpoch.toString();
    _userListener = "${_dateString}UsersListener";
    _groupListener = "${_dateString}GroupsListener";
    _uiGroupListener = "${_dateString}UIGroupListener";
    _addListeners();
    initializeLoggedInUser();
    membersCount = group.membersCount;
      super.onInit();
  }

  initializeLoggedInUser() async {
    _loggedInUser = await CometChat.getLoggedInUser();
    _conversation ??= (await CometChat.getConversation(
        group.guid, ConversationType.group, onSuccess: (conversation) {
      if (conversation.lastMessage != null) {}
    }, onError: (_) {}));
    _conversationId ??= _conversation?.conversationId;
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
        updatedUser.uid == _loggedInUser?.uid) {
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

  addMember(
      List<User>? users,
      BuildContext context,
      CometChatColorPalette colorPalette,
      CometChatSpacing spacing,
      CometChatTypography typography,
      {CometChatUsersController? userController}) {
    List<GroupMember> members = [];
    List<User> addedMembers = [];

    isLoading = true;

    update();

    if (users == null) return;

    for (User user in users) {
      members.add(GroupMember(
          scope: GroupMemberScope.participant,
          name: user.name,
          role: user.role ?? "",
          status: user.status ?? "",
          uid: user.uid,
          avatar: user.avatar,
          blockedByMe: user.blockedByMe,
          joinedAt: DateTime.now(),
          hasBlockedMe: user.hasBlockedMe,
          lastActiveAt: user.lastActiveAt,
          link: user.link,
          metadata: user.metadata,
          statusMessage: user.statusMessage,
          tags: user.tags));
    }

    CometChat.addMembersToGroup(
        guid: group.guid,
        groupMembers: members,
        onSuccess: (Map<String?, String?> result) {
          List<cc.Action> messages = [];
          for (GroupMember member in members) {
            if (result[member.uid] == "success") {
              addedMembers.add(member);
              messages.add(cc.Action(
                conversationId: _conversationId!,
                message: '${_loggedInUser?.name} added ${member.name}',
                oldScope: '',
                newScope: GroupMemberScope.participant,
                muid: DateTime.now().microsecondsSinceEpoch.toString(),
                sender: _loggedInUser!,
                receiverUid: group.guid,
                type: MessageTypeConstants.groupActions,
                receiverType: ReceiverTypeConstants.group,
                parentMessageId: 0,
                receiver: group,
              ));
            }
          }
          if(messages.isEmpty || addedMembers.isEmpty){
            var snackBar = SnackBar(
              backgroundColor: colorPalette.error,
              content: Text(
                "Unable to add members. Please check if they already exist.",
                style: TextStyle(
                  color: colorPalette.white,
                  fontSize: typography.button?.medium?.fontSize,
                  fontWeight: typography.button?.medium?.fontWeight,
                  fontFamily: typography.button?.medium?.fontFamily,
                ),
              ),
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
            isLoading = false;
            update();
          }else{
            group.membersCount = membersCount;
            group.membersCount += addedMembers.length;
            CometChatGroupEvents.ccGroupMemberAdded(
                messages, addedMembers, group, _loggedInUser!);
            isLoading = false;
            userController?.clearSelection();
            Navigator.of(context).pop();
            update();
          }

        },
        onError: (CometChatException e) {
          isLoading = false;
          update();
          debugPrint("Add Member failed with exception: ${e.message}");
          try {
            var snackBar = SnackBar(
              backgroundColor: colorPalette.error,
              content: Text(
                "Error, Unable to add members.",
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
        });
  }
}
