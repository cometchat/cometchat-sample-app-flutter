import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart' as cc;
import 'package:intl/intl.dart';

///[CometChatMessageHeaderController] is the view model for [CometChatMessageHeader]
///it contains all the business logic involved in changing the state of the UI of [CometChatMessageHeader]
class CometChatMessageHeaderController extends GetxController
    with
        CometChatMessageEventListener,
        UserListener,
        GroupListener,
        CometChatGroupEventListener,
        CometChatUserEventListener {
  User? userObject;
  Group? groupObject;
  bool? isTyping;
  User? typingUser;

  ///[usersStatusVisibility] controls visibility of status indicator shown if a user is online
  final bool? usersStatusVisibility;

  /// [dateTimeFormatterCallback] is a callback that can be used to format the date and time
  final DateTimeFormatterCallback? dateTimeFormatterCallback;

  late String dateStamp;
  late String messageListenerId;
  late String groupListenerId;
  late String userListenerId;
  static int counter = 0;
  late String tag;
  late String _uiGroupListener;
  late String _dateString;

  int? membersCount;

  User? loggedInUser;

  CometChatMessageHeaderController({
    this.userObject,
    this.groupObject,
    this.usersStatusVisibility = true,
    this.dateTimeFormatterCallback,
  }) {
    dateStamp = DateTime.now().microsecondsSinceEpoch.toString();
    messageListenerId = "${dateStamp}_message_listener";
    groupListenerId = "${dateStamp}_group_listener";
    userListenerId = "${dateStamp}_user_listener";
    if (groupObject != null) {
      membersCount = groupObject?.membersCount;
    }

    tag = "tag$counter";
    counter++;
  }

  @override
  void onInit() {
    _dateString = DateTime.now().millisecondsSinceEpoch.toString();
    _uiGroupListener = "${_dateString}UIGroupListener";
    CometChatMessageEvents.addMessagesListener(messageListenerId, this);
    if (userObject != null) {
      CometChat.addUserListener(groupListenerId, this);
      CometChatUserEvents.addUsersListener(groupListenerId, this);
    } else if (groupObject != null) {
      CometChat.addGroupListener(userListenerId, this);
      CometChatGroupEvents.addGroupsListener(_uiGroupListener, this);
    }
    super.onInit();
  }

  @override
  void onClose() {
    CometChatMessageEvents.removeMessagesListener(messageListenerId);
    CometChat.removeUserListener(userListenerId);
    CometChatUserEvents.removeUsersListener(groupListenerId);
    CometChat.removeGroupListener(groupListenerId);
    CometChatGroupEvents.removeGroupsListener(_uiGroupListener);
    super.onClose();
  }

  initializeLoggedInUser() async {
    if (loggedInUser == null) {
      loggedInUser = await CometChat.getLoggedInUser();
      update();
    }
  }

  @override
  void onUserOnline(User user) {
    if (userObject != null &&
        userObject!.uid == user.uid &&
        userIsNotBlocked(userObject!)) {
      userObject!.status = UserStatusConstants.online;
      update();
    }
  }

  @override
  void onUserOffline(User user) {
    if (userObject != null &&
        userObject!.uid == user.uid &&
        userIsNotBlocked(userObject!)) {
      userObject!.status = UserStatusConstants.offline;
      userObject!.lastActiveAt = user.lastActiveAt;
      update();
    }
  }

  @override
  void onTypingStarted(TypingIndicator typingIndicator) {
    if (userObject != null &&
        typingIndicator.receiverType == ReceiverTypeConstants.user &&
        typingIndicator.sender.uid == userObject!.uid &&
        userIsNotBlocked(userObject!)) {
      isTyping = true;
      typingUser = typingIndicator.sender;
      update();
    } else if (groupObject != null &&
        typingIndicator.receiverType == ReceiverTypeConstants.group &&
        typingIndicator.receiverId == groupObject!.guid &&
        userIsNotBlocked(typingIndicator.sender)) {
      isTyping = true;
      typingUser = typingIndicator.sender;
      update();
    }
  }

  @override
  void onTypingEnded(TypingIndicator typingIndicator) {
    if (userObject != null &&
        typingIndicator.receiverType == ReceiverTypeConstants.user &&
        typingIndicator.sender.uid == userObject!.uid) {
      isTyping = false;
      typingUser = null;
      update();
    } else if (groupObject != null &&
        typingIndicator.receiverType == ReceiverTypeConstants.group &&
        typingIndicator.receiverId == groupObject!.guid) {
      isTyping = false;
      typingUser = typingIndicator.sender;
      update();
    }
  }

  updateMemberCount(Group group) {
    if (groupObject != null && groupObject!.guid == group.guid) {
      membersCount = group.membersCount;
      groupObject?.membersCount = membersCount ?? 1;
      update();
    }
  }

  @override
  void onGroupMemberJoined(
      cc.Action action, User joinedUser, Group joinedGroup) {
    updateMemberCount(joinedGroup);
  }

  @override
  void onGroupMemberLeft(cc.Action action, User leftUser, Group leftGroup) {
    updateMemberCount(leftGroup);
  }

  @override
  void onGroupMemberKicked(
      cc.Action action, User kickedUser, User kickedBy, Group kickedFrom) {
    updateMemberCount(kickedFrom);
  }

  @override
  void onGroupMemberBanned(
      cc.Action action, User bannedUser, User bannedBy, Group bannedFrom) {
    updateMemberCount(bannedFrom);
  }

  @override
  void onGroupMemberUnbanned(cc.Action action, User unbannedUser,
      User unbannedBy, Group unbannedFrom) {}

  @override
  void onGroupMemberScopeChanged(
      cc.Action action,
      User updatedBy,
      User updatedUser,
      String scopeChangedTo,
      String scopeChangedFrom,
      Group group) {
    if (group.guid == groupObject?.guid &&
        updatedUser.uid == loggedInUser?.uid) {
      groupObject?.scope = scopeChangedTo;
      update();
    }
  }

  @override
  void onMemberAddedToGroup(
      cc.Action action, User addedby, User userAdded, Group addedTo) {
    updateMemberCount(addedTo);
  }

  @override
  void ccGroupMemberBanned(
      cc.Action message, User bannedUser, User bannedBy, Group bannedFrom) {
    updateMemberCount(bannedFrom);
  }

  @override
  void ccOwnershipChanged(Group group, GroupMember newOwner) {
    if (groupObject?.guid == group.guid) {
      groupObject?.owner = group.owner;
      update();
    }
  }

  @override
  void ccGroupMemberKicked(
      cc.Action message, User kickedUser, User kickedBy, Group kickedFrom) {
    updateMemberCount(kickedFrom);
  }

  @override
  void ccGroupMemberAdded(List<cc.Action> messages, List<User> usersAdded,
      Group groupAddedIn, User addedBy) {
    if (groupObject != null && groupAddedIn.guid == groupObject?.guid) {
      updateMemberCount(groupAddedIn);
    }
  }

  bool hideUserPresence() {
    return userObject != null &&
        (usersStatusVisibility == false || !userIsNotBlocked(userObject!));
  }

  bool userIsNotBlocked(User user) {
    return user.blockedByMe != true && user.hasBlockedMe != true;
  }

  @override
  void ccUserBlocked(User user) {
    if (user.uid == userObject?.uid) {
      userObject?.blockedByMe = true;
      update();
    }
  }

  @override
  void ccUserUnblocked(User user) {
    if (user.uid == userObject?.uid) {
      userObject?.blockedByMe = false;
      update();
    }
  }

  String getUserActivityStatus(BuildContext context) {
    if (userObject == null || userObject?.lastActiveAt == null) {
      return "";
    }
    return _getLastSeenText(userObject!.lastActiveAt!, context);
  }

  String _getLastSeenText(DateTime lastActiveAt, BuildContext context) {
    final DateTime now = DateTime.now();
    final Duration difference = now.difference(lastActiveAt);

    if (difference.inMinutes <= 1) {
      // Less than or equal to a minute ago
      return getMinute(lastActiveAt, context);
    } else if (difference.inMinutes < 60) {
      // Less than an hour ago
      return getMinutes(difference, lastActiveAt, context);
    } else if (difference.inHours < 2) {
      // More than an hour ago
      return getHour(difference, lastActiveAt, context);
    } else if (difference.inHours < 24) {
      // More than an hour ago
      int diffInHours = difference.inHours;
      return getHours(difference, diffInHours, lastActiveAt, context);
    } else {
      return getFormattedDateWithTime(lastActiveAt, context);
    }
  }

  String getMinute(DateTime date, BuildContext context) {
    if (dateTimeFormatterCallback?.minute(date.millisecondsSinceEpoch) !=
        null) {
      return dateTimeFormatterCallback?.minute(date.millisecondsSinceEpoch) ??
          "${cc.Translations.of(context).lastSeen} 1 ${cc.Translations.of(context).minuteAgo}";
    } else {
      return CometChatUIKit.authenticationSettings?.dateTimeFormatterCallback
              ?.minute(date.millisecondsSinceEpoch) ??
          "${cc.Translations.of(context).lastSeen} 1 ${cc.Translations.of(context).minuteAgo}";
    }
  }

  String getMinutes(Duration difference, DateTime date, BuildContext context) {
    int diffInMinutes = difference.inMinutes;
    if (dateTimeFormatterCallback?.minutes(
            diffInMinutes, date.millisecondsSinceEpoch) !=
        null) {
      return dateTimeFormatterCallback?.minutes(
              diffInMinutes, date.millisecondsSinceEpoch) ??
          "${cc.Translations.of(context).lastSeen} ${difference.inMinutes} ${cc.Translations.of(context).minutesAgo}";
    } else {
      return CometChatUIKit.authenticationSettings?.dateTimeFormatterCallback
              ?.minutes(diffInMinutes, date.millisecondsSinceEpoch) ??
          "${cc.Translations.of(context).lastSeen} ${difference.inMinutes} ${cc.Translations.of(context).minutesAgo}";
    }
  }

  String getHour(Duration difference, DateTime date, BuildContext context) {
    if (dateTimeFormatterCallback?.hour(date.millisecondsSinceEpoch) != null) {
      return dateTimeFormatterCallback?.hour(date.millisecondsSinceEpoch) ??
          "${cc.Translations.of(context).lastSeen} ${difference.inHours} ${cc.Translations.of(context).hourAgo}";
    } else {
      return CometChatUIKit.authenticationSettings?.dateTimeFormatterCallback
              ?.hour(date.millisecondsSinceEpoch) ??
          "${cc.Translations.of(context).lastSeen} ${difference.inHours} ${cc.Translations.of(context).hourAgo}";
    }
  }

  String getHours(Duration difference, int diffInHours, DateTime date,
      BuildContext context) {
    if (dateTimeFormatterCallback?.hours(
            diffInHours, date.millisecondsSinceEpoch) !=
        null) {
      return dateTimeFormatterCallback?.hours(
              diffInHours, date.millisecondsSinceEpoch) ??
          "${cc.Translations.of(context).lastSeen} ${difference.inHours} ${cc.Translations.of(context).hoursAgo}";
    } else {
      return CometChatUIKit.authenticationSettings?.dateTimeFormatterCallback
              ?.hours(diffInHours, date.millisecondsSinceEpoch) ??
          "${cc.Translations.of(context).lastSeen} ${difference.inHours} ${cc.Translations.of(context).hoursAgo}";
    }
  }

  String getFormattedDateWithTime(DateTime lastActiveAt, BuildContext context) {
    final now = DateTime.now();
    final isSameYear = now.year == lastActiveAt.year;

    String datePattern = isSameYear ? 'dd MMM' : 'dd MMM yyyy';
    String formattedDate = DateFormat(datePattern).format(lastActiveAt);
    String formattedTime = DateFormat.jm().format(lastActiveAt);

    if (dateTimeFormatterCallback
            ?.otherDays(lastActiveAt.millisecondsSinceEpoch) !=
        null) {
      return dateTimeFormatterCallback
              ?.otherDays(lastActiveAt.millisecondsSinceEpoch) ??
          "${cc.Translations.of(context).lastSeen} $formattedDate ${cc.Translations.of(context).at} $formattedTime";
    } else {
      return CometChatUIKit.authenticationSettings?.dateTimeFormatterCallback
              ?.otherDays(lastActiveAt.millisecondsSinceEpoch) ??
          "${cc.Translations.of(context).lastSeen} $formattedDate ${cc.Translations.of(context).at} $formattedTime";
    }
  }
}
