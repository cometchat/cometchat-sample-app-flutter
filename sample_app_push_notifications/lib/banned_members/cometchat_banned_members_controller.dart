import 'package:flutter/material.dart' as material;
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart' as cc;
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';
import 'banned_member_builder_protocol.dart';
import 'package:get/get.dart';

///[CometChatBannedMembersController] is the view model for [CometChatBannedMembers]
///it contains all the business logic involved in changing the state of the UI of [CometChatBannedMembers]
class CometChatBannedMembersController
    extends CometChatSearchListController<GroupMember, String>
    with
        CometChatSelectable,
        GroupListener,
        UserListener,
        CometChatGroupEventListener {
  late BannedMemberBuilderProtocol bannedMemberBuilderProtocol;
  late String dateStamp;
  late String groupSDKListenerID;
  late String userSDKListenerID;
  late String groupUIListenerID;
  bool disableUsersPresence;
  bool? isOwner;
  late Group group;
  User? loggedInUser;
  Conversation? _conversation;

  String? _conversationId;

  ///[unbanIconUrl] is a custom icon for the default option
  final String? unbanIconUrl;

  ///[unbanIconUrlPackageName] is the package for the asset image to show as custom icon for the default option
  final String? unbanIconUrlPackageName;

  CometChatBannedMembersController(
      {required this.bannedMemberBuilderProtocol,
      SelectionMode? mode,
      required this.group,
      required this.disableUsersPresence,
      this.unbanIconUrl,
      this.unbanIconUrlPackageName})
      : super(builderProtocol: bannedMemberBuilderProtocol) {
    selectionMode = mode ?? SelectionMode.none;
    dateStamp = DateTime.now().microsecondsSinceEpoch.toString();
    groupSDKListenerID = "${dateStamp}group_sdk_listener";
    userSDKListenerID = "${dateStamp}user_sdk_listener";
    groupUIListenerID = "${dateStamp}_ui_group_listener";
  }

  // TODO: Implement the retry logic later.
  // Retry configuration
  final int maxRetries = 3;
  final Duration retryDelay = const Duration(seconds: 3);
  int _currentRetryCount = 0;

  @override
  void onInit() {
    CometChat.addGroupListener(groupSDKListenerID, this);
    CometChatGroupEvents.addGroupsListener(groupUIListenerID, this);
    if (disableUsersPresence != true) {
      //Adding listener when presence is needed
      CometChat.addUserListener(userSDKListenerID, this);
    }
    initializeInternalDependencies();
    super.onInit();
  }

  void initializeInternalDependencies() async {
    _conversation ??= (await CometChat.getConversation(
        group.guid, ConversationType.group, onSuccess: (conversation) {
      if (conversation.lastMessage != null) {}
    }, onError: (_) {}));
    _conversationId ??= _conversation?.conversationId;
  }

  @override
  void onClose() {
    CometChat.removeGroupListener(groupSDKListenerID);

    CometChatGroupEvents.removeGroupsListener(groupUIListenerID);
    if (disableUsersPresence == false) {
      CometChat.removeUserListener(userSDKListenerID);
    }
    super.onClose();
  }

  @override
  bool match(GroupMember elementA, GroupMember elementB) {
    return elementA.uid == elementB.uid;
  }

  @override
  String getKey(GroupMember element) {
    return element.uid;
  }

  ///[onGroupMemberBanned] will get triggered when a group member is banned from group by someone other than the logged in user
  @override
  void onGroupMemberBanned(
      Action action, User bannedUser, User bannedBy, Group bannedFrom) {
    if (bannedFrom.guid == group.guid) {
      addElement(GroupMember.fromUid(
          scope: bannedFrom.scope, uid: bannedUser.uid, name: bannedUser.name));
      material.debugPrint('onGroupMemberBanned got triggered');
    }
  }

  /// [onGroupMemberUnbanned] will get triggered when a group member is unbanned from group by someone other than the logged in user
  @override
  void onGroupMemberUnbanned(
      Action action, User unbannedUser, User unbannedBy, Group unbannedFrom) {
    if (unbannedFrom.guid == group.guid) {
      removeElement(GroupMember.fromUid(
          scope: unbannedFrom.scope,
          uid: unbannedUser.uid,
          name: unbannedUser.name));
    }
  }

  /// [ccGroupMemberBanned] will get triggered when a group member is banned from group by logged in user
  @override
  void ccGroupMemberBanned(
      Action message, User bannedUser, User bannedBy, Group bannedFrom) {
    if (bannedFrom.guid == group.guid) {
      addElement(GroupMember.fromUid(
          scope: bannedFrom.scope, uid: bannedUser.uid, name: bannedUser.name));
    }
  }

  /// [ccGroupMemberUnbanned] will get triggered when a banned group member is unbanned from group by logged in user
  @override
  void ccGroupMemberUnbanned(
      Action action, User unbannedUser, User unbannedBy, Group unbannedFrom) {
    if (unbannedFrom.guid == group.guid) {
      removeElement(GroupMember.fromUid(
          scope: unbannedFrom.scope,
          uid: unbannedUser.uid,
          name: unbannedUser.name));
    }
  }

  @override
  loadMoreElements({bool Function(GroupMember element)? isIncluded}) async {
    if (loggedInUser == null) {
      loggedInUser = await CometChat.getLoggedInUser();
      if (loggedInUser?.uid == group.owner) {
        isOwner = true;
      }
    }
    await super.loadMoreElements(isIncluded: isIncluded);
  }

  @override
  void onUserOffline(User user) {
    int index = getMatchingIndexFromKey(user.uid);
    if (index != -1) {
      list[index].status = user.status;
      update();
      material.debugPrint('user down ${user.status}');
    }
  }

  @override
  void onUserOnline(User user) {
    int index = getMatchingIndexFromKey(user.uid);
    if (index != -1) {
      list[index].status = UserStatusConstants.online;
      update();
      material.debugPrint('user up ${user.status}');
    }
  }

  void unBanMember(context, Group group, GroupMember member,
      cc.CometChatColorPalette colorPalette, cc.CometChatTypography typography, cc.CometChatSpacing spacing) async {

    showConfirmDialog(context, colorPalette, typography, spacing,
        title: "Unban ${member.name}?",
        icon: material.Icon(
          material.Icons.not_interested,
          size: 48,
          color: colorPalette.error,
        ),
        messageText: "Are you sure you want to unban ${member.name} from ${group.name}?",
        onConfirm: () {
          isActionRunning.value=true;
          CometChat.unbanGroupMember(
            guid: group.guid,
            uid: member.uid,
            onSuccess: (String result) async {
              CometChatGroupEvents.ccGroupMemberUnbanned(
                  cc.Action(
                    conversationId: _conversationId!,
                    message: '${loggedInUser?.name} unbanned ${member.name}',
                    oldScope: '',
                    newScope: '',
                    muid: DateTime.now().microsecondsSinceEpoch.toString(),
                    sender: loggedInUser!,
                    receiverUid: group.guid,
                    type: MessageTypeConstants.groupActions,
                    receiverType: ReceiverTypeConstants.group,
                    parentMessageId: 0,
                    receiver: group,
                  ),
                  member,
                  loggedInUser!,
                  group);
              removeElement(member);
              isActionRunning.value=false;
              material.Navigator.of(context).pop();
            },
            onError: (excep) {
              if(onError!=null){
                onError!(excep);
              }
              isActionRunning.value=false;
              material.Navigator.of(context).pop();
            },
          );
        },
        confirmButtonText: cc.Translations.of(context).unban.toUpperCase()
    );
  }


  var isActionRunning=false.obs;

  // TODO: Implement the retry logic later.
  // Method to load groups
  void retryUsers() async {
    try {
      request = bannedMemberBuilderProtocol.getRequest();
      list = [];
      isLoading = true;
      await loadMoreElements();
      isLoading = false;
      _currentRetryCount = 0; // Reset retries on success
    } catch (e) {
      isLoading = false;
      _handleError(e);
    }
  }

  // TODO: Implement the retry logic later.
  // Retry logic on error
  void _handleError(dynamic error) {
    if (_currentRetryCount < maxRetries) {
      _currentRetryCount++;
      Future.delayed(retryDelay, () {
        retryUsers();
      });
    } else {
      if (onError != null) {
        onError!(error);
      }
    }
  }

  showConfirmDialog(material.BuildContext context, CometChatColorPalette colorPalette,
      CometChatTypography typography, CometChatSpacing spacing,
      {Function()? onConfirm,material.Widget? icon, String? title, String? messageText,String? confirmButtonText}) {
    CometChatConfirmDialog(
      context: context,
      confirmButtonText: cc.Translations.of(context).deleteCapital,
      cancelButtonText: cc.Translations.of(context).cancelCapital,
      icon: icon,
      title: material.Text(
        title ?? "",
        textAlign: material.TextAlign.center,
      ),
      messageText: material.Text(
        messageText ?? "",
        textAlign: material.TextAlign.center,
      ),
      onCancel: () {
        if (!material.Navigator.canPop(context)) {
          material.debugPrint("Error: Cannot pop the navigator. Invalid context.");
          return;
        }
        isActionRunning.value=false;
        material.Navigator.pop(context);
      },
      style: CometChatConfirmDialogStyle(
        iconColor:  colorPalette.error,
        cancelButtonBackground:colorPalette.borderLight,
        confirmButtonBackground: colorPalette.error,
        titleTextStyle: material.TextStyle(
          color: colorPalette.textPrimary,
          fontSize: typography.heading2?.medium?.fontSize,
          fontWeight: typography.heading2?.medium?.fontWeight,
          fontFamily: typography.heading2?.medium?.fontFamily,
        ),
        messageTextStyle: material.TextStyle(
          color: colorPalette.textSecondary,
          fontSize: typography.body?.regular?.fontSize,
          fontWeight: typography.body?.regular?.fontWeight,
          fontFamily: typography.body?.regular?.fontFamily,
        ),
        confirmButtonTextStyle: material.TextStyle(
          color: colorPalette.white,
          fontSize: typography.button?.medium?.fontSize,
          fontWeight: typography.button?.medium?.fontWeight,
          fontFamily: typography.button?.medium?.fontFamily,
        ),
        cancelButtonTextStyle: material.TextStyle(
          color: colorPalette.textPrimary,
          fontSize: typography.button?.medium?.fontSize,
          fontWeight: typography.button?.medium?.fontWeight,
          fontFamily: typography.button?.medium?.fontFamily,
        ),
      ),
      onConfirm: onConfirm,
      confirmButtonTextWidget: Obx(
            () => isActionRunning.value
            ? material.SizedBox(
          height: 25,
          width: 25,
          child: material.CircularProgressIndicator(
            color: colorPalette.white,
          ),
        )
            : material.Text(
          confirmButtonText ?? "",
          style: material.TextStyle(
            color: colorPalette.white,
            fontSize: typography.button?.medium?.fontSize,
            fontWeight: typography.button?.medium?.fontWeight,
            fontFamily: typography.button?.medium?.fontFamily,
          ),
        ),
      ),

    ).show();
  }

}
