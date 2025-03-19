import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart' as cc;
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';

class CometChatAddMembersController extends GetxController {
  CometChatAddMembersController({required this.group});

  ///[group] provide group to add members to
  final Group group;

  User? _loggedInUser;

  Conversation? _conversation;

  String? _conversationId;

  final RxList<User> selectedUsers = <User>[].obs;

  bool isLoading = false;

  // Update the list of selected users
  void updateSelectedUsers(List<User> users) {
    selectedUsers.value = users;
    update(); // Notify the UI about the changes
  }

  @override
  void onInit() {
    initializeLoggedInUser();
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
