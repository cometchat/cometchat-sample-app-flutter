import 'package:cometchat_calls_uikit/cometchat_calls_uikit.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';
import 'package:flutter/material.dart';

class CometChatMessagesController extends GetxController
    with UserListener, CometChatUserEventListener {
  CometChatMessagesController(
    this.user,
    this.group,
  );

  final User? user;
  final Group? group;

  late String _dateString;
  late String _userListener;
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
  }

  _removeListeners() {
    CometChat.removeUserListener(_userListener);
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
}
