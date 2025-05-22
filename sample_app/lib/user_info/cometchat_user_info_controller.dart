import 'package:cometchat_calls_uikit/cometchat_calls_uikit.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart' as cc;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CometChatUserInfoController extends GetxController
    with UserListener, CometChatUserEventListener {
  CometChatUserInfoController(
    this.user,
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

  updateUserStatue(User user) {
    if (user.status == CometChatUserStatus.online) {
      presence = "Online";
    } else {
      presence = getLastSeenText(user.lastActiveAt);
    }
  }

  String getLastSeenText(DateTime? lastActiveAt) {
    if(lastActiveAt == null) {
      return "";
    }
    final DateTime now = DateTime.now();
    final Duration difference = now.difference(lastActiveAt);

    if (difference.inMinutes <= 1) {
      // Less than or equal to a minute ago
      return "${cc.Translations.of(context).lastSeen} 1 ${cc.Translations.of(context).minuteAgo}";
    } else if (difference.inMinutes < 60) {
      // Less than an hour ago
      return "${cc.Translations.of(context).lastSeen} ${difference.inMinutes} ${cc.Translations.of(context).minuteAgo}";
    } else {
      // More than an hour ago
      String formattedDate = DateFormat.MMMd().format(lastActiveAt);
      String formattedTime = DateFormat.jm().format(lastActiveAt);
      return "${cc.Translations.of(context).lastSeen} $formattedDate ${cc.Translations.of(context).at} $formattedTime";
    }
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
      presence = getLastSeenText(user.lastActiveAt!);
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
        Navigator.of(context).pop(1);
      },
      onError: (excep) {
        isBlockLoading.value = false;
        try {
          isBlockLoading.value = false;
          Navigator.of(context).pop();
          var snackBar = SnackBar(
            backgroundColor: colorPalette.error,
            content: Text(
              "Error, Unable to block user",
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
        debugPrint("Error blocking user: $excep");
      },
    );
  }

  _onBlockUser() {
    if (user == null) return;
    isBlockLoading.value = true;
    CometChat.blockUser(
      [user!.uid],
      onSuccess: (Map<String, dynamic> map) {
        isBlockLoading.value = false;
        if (user != null) {
          user!.blockedByMe = true;
          update();
        }
        userIsNotBlocked();
        CometChatUserEvents.ccUserBlocked(user!);
        Navigator.of(context).pop(1);
      },
      onError: (excep) {
        isBlockLoading.value = false;
        try {
          isBlockLoading.value = false;
          Navigator.of(context).pop();
          var snackBar = SnackBar(
            backgroundColor: colorPalette.error,
            content: Text(
              "Error, Unable to block user",
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
        debugPrint("Error blocking user: $excep");
      },
    );
  }

  _onDeleteUserConfirmed() {
    if (user == null || _conversation == null) {
      debugPrint("Error: user or conversation is null.");
      return;
    }
    isDeleteLoading.value = true;
    CometChat.deleteConversation(
      user!.uid,
      _conversation!.conversationType,
      onSuccess: (String message) {
        isDeleteLoading.value = false;
        CometChatConversationEvents.ccConversationDeleted(_conversation!);
        Navigator.of(context)..pop()..pop()..pop();
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

  _unBlockUser() async {
    if (user != null) {
      if (loggedInUser == null) return;
      _onUnBlockUser();
    }
  }

  _blockUser() async {
    if (user != null) {
      if (loggedInUser == null) return;
      _onBlockUser();
    }
  }

  bool hideUserPresence() {
    return user != null &&
        (disableUsersPresence == true || !userIsNotBlocked());
  }

  bool userIsNotBlocked() {
    isUserBlocked =
        user != null && (user?.blockedByMe != true && user?.hasBlockedMe != true);
    update();
    return isUserBlocked;
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

  blockUserDialog({
    required CometChatColorPalette colorPalette,
    required CometChatTypography typography,
    required BuildContext context,
  }) {
    CometChatConfirmDialog(
      context: context,
      icon: Icon(
        Icons.block,
        color: colorPalette.error,
        size: 48,
      ),
      title: Text(
        "Block this contact?",
        style: TextStyle(
          fontSize: typography.heading2?.medium?.fontSize,
          fontFamily: typography.heading2?.medium?.fontFamily,
          fontWeight: typography.heading2?.medium?.fontWeight,
          color: colorPalette.textPrimary,
        ),
      ),
      messageText: Text(
        "Are you sure you want to block this contact? You won’t receive messages from them anymore.",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: typography.body?.regular?.fontSize,
          fontFamily: typography.body?.regular?.fontFamily,
          fontWeight: typography.body?.regular?.fontWeight,
          color: colorPalette.textSecondary,
        ),
      ),
      confirmButtonText: cc.Translations.of(context).blockUser,
      cancelButtonText: cc.Translations.of(context).cancel,
      onConfirm: _blockUser,
      style: CometChatConfirmDialogStyle(
        confirmButtonBackground: colorPalette.error,
        confirmButtonTextColor: colorPalette.white,
      ),
      confirmButtonTextWidget: Obx(
        () => (isBlockLoading.value)
            ? SizedBox(
                height: 25,
                width: 25,
                child: CircularProgressIndicator(
                  color: colorPalette.white,
                ),
              )
            : Text(
                cc.Translations.of(context).blockUser,
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

  unblockUserDialog({
    required CometChatColorPalette colorPalette,
    required CometChatTypography typography,
    required BuildContext context,
  }) {
    CometChatConfirmDialog(
      context: context,
      icon: Icon(
        Icons.block,
        color: colorPalette.error,
        size: 48,
      ),
      title: Text(
        "Unblock this contact?",
        style: TextStyle(
          fontSize: typography.heading2?.medium?.fontSize,
          fontFamily: typography.heading2?.medium?.fontFamily,
          fontWeight: typography.heading2?.medium?.fontWeight,
          color: colorPalette.textPrimary,
        ),
      ),
      messageText: Text(
        "Are you sure you want to unblock this contact?",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: typography.body?.regular?.fontSize,
          fontFamily: typography.body?.regular?.fontFamily,
          fontWeight: typography.body?.regular?.fontWeight,
          color: colorPalette.textSecondary,
        ),
      ),
      confirmButtonText: cc.Translations.of(context).unblockUser,
      cancelButtonText: cc.Translations.of(context).cancel,
      onConfirm: _unBlockUser,
      style: CometChatConfirmDialogStyle(
        confirmButtonBackground: colorPalette.error,
        confirmButtonTextColor: colorPalette.white,
      ),
      confirmButtonTextWidget: Obx(
        () => (isBlockLoading.value)
            ? SizedBox(
                height: 25,
                width: 25,
                child: CircularProgressIndicator(
                  color: colorPalette.white,
                ),
              )
            : Text(
                cc.Translations.of(context).unblockUser,
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

  deleteChatDialog({
    required CometChatColorPalette colorPalette,
    required CometChatTypography typography,
    required BuildContext context,
  }) {
    CometChatConfirmDialog(
      context: context,
      icon: Image.asset(
        AssetConstants.delete,
        color: colorPalette.error,
        package: UIConstants.packageName,
        width: 48,
        height: 48,
      ),
      title: Text(
        "Delete this chat?",
        style: TextStyle(
          fontSize: typography.heading2?.medium?.fontSize,
          fontFamily: typography.heading2?.medium?.fontFamily,
          fontWeight: typography.heading2?.medium?.fontWeight,
          color: colorPalette.textPrimary,
        ),
      ),
      messageText: Text(
        "Are you sure you want to delete this chat? This action cannot be undone.",
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
      onConfirm: _onDeleteUserConfirmed,
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
                cc.Translations.of(context).delete,
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

  void initiateCallWorkflow(String callType, context) {
    if (user == null) {
      return;
    }
    Call call = Call(
      receiverUid: user!.uid,
      receiverType: ReceiverTypeConstants.user,
      type: callType,
    );

    CometChatUIKitCalls.initiateCall(
      call,
      onSuccess: (Call returnedCall) {
        returnedCall.category = MessageCategoryConstants.call;
        CometChatCallEvents.ccOutgoingCall(returnedCall);
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CometChatOutgoingCall(
                call: returnedCall,
                user: user,
              ),
            ));
      },
      onError: (CometChatException e) {
        debugPrint('Error in initiating call: ${e.message}');
      },
    );
  }

  bool getBlockedByMe() {
    return user?.blockedByMe != null && user?.blockedByMe! == true;
  }
}
