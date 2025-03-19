import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../cometchat_chat_uikit.dart';
import '../../../cometchat_chat_uikit.dart' as cc;

///[CometChatConversationsController] is the view model for [CometChatConversations]
///it contains all the business logic involved in changing the state of the UI of [CometChatConversations]
class CometChatConversationsController
    extends CometChatListController<Conversation, String>
    with
        CometChatSelectable,
        CometChatMessageEventListener,
        CometChatGroupEventListener,
        UserListener,
        GroupListener,
        CometChatUserEventListener,
        CallListener,
        CometChatCallEventListener,
        ConnectionListener,
        CometChatConversationEventListener
    implements CometChatConversationsControllerProtocol {
  //Constructor
  CometChatConversationsController({
    required this.conversationsBuilderProtocol,
    SelectionMode? mode,
    this.disableSoundForMessages = false,
    this.customSoundForMessages,
    this.usersStatusVisibility = true,
    this.groupTypeVisibility = true,
    this.receiptsVisibility = true,
    OnError? onError,
    OnLoad<Conversation>? onLoad,
    OnEmpty? onEmpty,
    this.textFormatters,
    this.mentionsStyle,
    this.conversationsStyle,
  }) : super(conversationsBuilderProtocol.getRequest(), onError: onError, onLoad: onLoad, onEmpty: onEmpty) {
    selectionMode = mode ?? SelectionMode.none;
    dateStamp = DateTime.now().microsecondsSinceEpoch.toString();

    groupSDKListenerID = "${dateStamp}_group_sdk_listener";
    groupUIListenerID = "${dateStamp}_ui_group_listener";
    messageSDKListenerID = "${dateStamp}_message_sdk_listener";
    messageUIListenerID = "${dateStamp}_ui_message_listener";
    userSDKListenerID = "${dateStamp}_user_sdk_listener";
    _uiUserListener = "${dateStamp}UI_user_listener";
    _conversationListenerId = "${dateStamp}_conversation_listener";
    _conversationEventListenerId = "${dateStamp}_conversation_event_listener";
  }

  late ConversationsBuilderProtocol conversationsBuilderProtocol;
  late String dateStamp;
  BuildContext? context;
  late String groupSDKListenerID;
  late String groupUIListenerID;
  late String messageSDKListenerID;
  late String messageUIListenerID;
  late String userSDKListenerID;
  late String _uiUserListener;
  late String _conversationListenerId;
  late String _conversationEventListenerId;
  CometChatColorPalette? colorPalette;
  CometChatSpacing? spacing;
  CometChatTypography? typography;

  Map<String, TypingIndicator> typingMap = {};
  User? loggedInUser;

  ///[disableSoundForMessages] if true will disable sound for messages
  final bool? disableSoundForMessages;

  ///[customSoundForMessages] URL of the audio file to be played upon receiving messages
  final String? customSoundForMessages;

  ///[receiptsVisibility] controls visibility of read receipts
  final bool? receiptsVisibility;

  String loggedInUserId = "";
  String?
      activeConversation; //active user or groupID, null when no message list is active

  CometChatConversationsStyle? style;

  bool? usersStatusVisibility;

  bool? groupTypeVisibility;

  ///[textFormatters] is a list of [CometChatTextFormatter] which is used to format the text
  List<CometChatTextFormatter>? textFormatters;

  ///[mentionsStyle] is a [CometChatMentionsStyle] which is used to style the mentions
  final CometChatMentionsStyle? mentionsStyle;

  ///[conversationsStyle] is a [CometChatConversationsStyle] which is used to style the conversations
  final CometChatConversationsStyle? conversationsStyle;

  var isDeleteLoading = false.obs;

  @override
  void onInit() {
    CometChatMessageEvents.addMessagesListener(messageUIListenerID, this);
    CometChatGroupEvents.addGroupsListener(groupUIListenerID, this);
    if (usersStatusVisibility == true) {
      CometChat.addUserListener(userSDKListenerID, this);
    }
    CometChat.addGroupListener(groupSDKListenerID, this);

    CometChatUserEvents.addUsersListener(_uiUserListener, this);
    CometChatCallEvents.addCallEventsListener(_conversationListenerId, this);
    CometChat.addCallListener(_conversationListenerId, this);
    CometChat.addConnectionListener(_conversationListenerId, this);
    CometChatConversationEvents.addConversationListListener(
        _conversationEventListenerId, this);
    initializeTextFormatters();
    super.onInit();
  }

  @override
  void onClose() {
    CometChatMessageEvents.removeMessagesListener(messageUIListenerID);
    CometChatGroupEvents.removeGroupsListener(groupUIListenerID);
    CometChat.removeMessageListener(messageSDKListenerID);
    if (usersStatusVisibility == true) {
      CometChat.removeUserListener(userSDKListenerID);
    }
    //CometChat.removeGroupListener(groupSDKListenerID);
    CometChatUserEvents.removeUsersListener(_uiUserListener);
    CometChatCallEvents.removeCallEventsListener(_conversationListenerId);
    CometChat.removeCallListener(_conversationListenerId);
    CometChat.removeConnectionListener(_conversationListenerId);
    CometChatConversationEvents.removeConversationListListener(
        _conversationEventListenerId);
    super.onClose();
  }

  @override
  bool match(Conversation elementA, Conversation elementB) {
    return elementA.conversationId == elementB.conversationId;
  }

  @override
  String getKey(Conversation element) {
    return element.conversationId!;
  }

  @override
  loadMoreElements({bool Function(Conversation element)? isIncluded}) async {
    loggedInUser ??= await CometChat.getLoggedInUser();
    if (loggedInUser != null) {
      loggedInUserId = loggedInUser!.uid;
    }
    await super.loadMoreElements();
  }

  @override
  void ccMessageRead(BaseMessage message) {
    resetUnreadCount(message);
  }

  @override
  void ccMessageSent(BaseMessage message, MessageStatus messageStatus) {
    if (_checkMessageSettings(message)) {
      return;
    }
    if (messageStatus == MessageStatus.sent) {
      updateLastMessage(message);
    }
  }

  @override
  void ccConversationDeleted(Conversation conversation) {
    removeElement(conversation);
  }

  @override
  void ccMessageEdited(BaseMessage message, MessageEditStatus status) {
    if (status == MessageEditStatus.success) {
      updateLastMessageOnEdited(message);
    }
  }

  @override
  void onMessageDeleted(BaseMessage message) {
    updateLastMessageOnEdited(message);
  }

  @override
  void ccMessageDeleted(BaseMessage message, EventStatus messageStatus) {
    if (messageStatus == EventStatus.success) {
      updateLastMessageOnEdited(message);
    }
  }

  @override
  ccOwnershipChanged(Group group, GroupMember newOwner) {
    updateGroup(group);
  }

  @override
  ccGroupLeft(cc.Action message, User leftUser, Group leftGroup) {
    removeGroup(leftGroup.guid);
  }

  @override
  void ccGroupDeleted(Group group) {
    removeGroup(group.guid);
  }

  @override
  void ccGroupMemberAdded(List<cc.Action> messages, List<User> usersAdded,
      Group groupAddedIn, User addedBy) {
    if (_checkGroupSettings() == false) {
      return;
    }
    if(messages.isNotEmpty) {
      refreshSingleConversation(messages.last, true);
    }
  }

  //-----------Message Listeners------------------------------------------------

  _onMessageReceived(BaseMessage message, bool isActionMessage) {
    if (message.sender!.uid != loggedInUserId) {
      CometChat.markAsDelivered(message, onSuccess: (_) {}, onError: (_) {});
    }

    if (disableSoundForMessages == false) {
      playNotificationSound(message);
    }

    refreshSingleConversation(message, isActionMessage);
  }

  @override
  void onTextMessageReceived(TextMessage textMessage) async {
    if (_checkMessageSettings(textMessage)) {
      return;
    }
    _onMessageReceived(textMessage, false);
  }

  @override
  void onMediaMessageReceived(MediaMessage mediaMessage) async {
    if (_checkMessageSettings(mediaMessage)) {
      return;
    }
    _onMessageReceived(mediaMessage, false);
  }

  @override
  void onCustomMessageReceived(CustomMessage customMessage) async {
    if (_checkMessageSettings(customMessage)) {
      return;
    }
    _onMessageReceived(customMessage, false);
  }

  @override
  void onMessagesDelivered(MessageReceipt messageReceipt) {
    if (messageReceipt.receiverType == ReceiverTypeConstants.user &&
        receiptsVisibility == true) {
      setReceipts(messageReceipt);
    }
  }

  @override
  void onMessagesRead(MessageReceipt messageReceipt) {
    if (messageReceipt.receiverType == ReceiverTypeConstants.user &&
        receiptsVisibility == true) {
      setReceipts(messageReceipt);
    }
  }

  @override
  void onMessageEdited(BaseMessage message) {
    updateLastMessageOnEdited(message);
  }

  @override
  void onMessagesDeliveredToAll(MessageReceipt messageReceipt) {
    if (receiptsVisibility == true &&
        messageReceipt.receiverType == ReceiverTypeConstants.group) {
      setReceipts(messageReceipt);
    }
  }

  @override
  void onMessagesReadByAll(MessageReceipt messageReceipt) {
    if (receiptsVisibility == true &&
        messageReceipt.receiverType == ReceiverTypeConstants.group) {
      setReceipts(messageReceipt);
    }
  }

  @override
  void onTypingStarted(TypingIndicator typingIndicator) {
    if (userIsNotBlocked(typingIndicator.sender)) {
      setTypingIndicator(typingIndicator, true);
    }
  }

  @override
  void onTypingEnded(TypingIndicator typingIndicator) {
    if (userIsNotBlocked(typingIndicator.sender)) {
      setTypingIndicator(typingIndicator, false);
    }
  }

  @override
  void onFormMessageReceived(FormMessage formMessage) {
    if (_checkMessageSettings(formMessage)) {
      return;
    }
    _onMessageReceived(formMessage, false);
  }

  @override
  void onCardMessageReceived(CardMessage cardMessage) {
    if (_checkMessageSettings(cardMessage)) {
      return;
    }
    _onMessageReceived(cardMessage, false);
  }

  @override
  void onCustomInteractiveMessageReceived(
      CustomInteractiveMessage customInteractiveMessage) {
    if (_checkMessageSettings(customInteractiveMessage)) {
      return;
    }
    _onMessageReceived(customInteractiveMessage, false);
  }

  //----------------Message Listeners end----------------------------------------------

  //----------------User Listeners-----------------------------------------------------
  @override
  void onUserOnline(User user) {
    if (userIsNotBlocked(user)) {
      updateUserStatus(user, UserStatusConstants.online);
    }
  }

  @override
  void onUserOffline(User user) {
    if (userIsNotBlocked(user)) {
      updateUserStatus(user, UserStatusConstants.offline);
    }
  }

  bool userIsNotBlocked(User user) {
    return user.blockedByMe != true && user.hasBlockedMe != true;
  }

  @override
  void ccUserBlocked(User user) {
    if (conversationsBuilderProtocol.requestBuilder.includeBlockedUsers ==
        true) {
      return;
    }
    int matchingIndex = list.indexWhere((Conversation conversation) =>
        (conversation.conversationType == ReceiverTypeConstants.user &&
            (conversation.conversationWith as User).uid == user.uid));
    if (matchingIndex >= 0 && matchingIndex < list.length) {
      removeElementAt(matchingIndex);
    } else {
      debugPrint("No matching conversation found for user ${user.uid}");
    }
  }

  //----------------User Listeners end----------------------------------------------
  //----------------Group Listeners-----------------------------------------------------

  @override
  onGroupMemberJoined(cc.Action action, User joinedUser, Group joinedGroup) {
    if (_checkGroupSettings() == false) {
      return;
    }
    refreshSingleConversation(action, true);
  }

  @override
  onGroupMemberLeft(cc.Action action, User leftUser, Group leftGroup) {
    if (_checkGroupSettings() == false) {
      return;
    }
    if (loggedInUserId == leftUser.uid) {
      refreshSingleConversation(action, true, remove: true);
    } else {
      refreshSingleConversation(action, true);
    }
  }

  @override
  onGroupMemberKicked(
      cc.Action action, User kickedUser, User kickedBy, Group kickedFrom) {
    if (_checkGroupSettings() == false) {
      return;
    }
    if (loggedInUserId == kickedUser.uid) {
      refreshSingleConversation(action, true, remove: true);
    } else {
      refreshSingleConversation(action, true);
    }
  }

  @override
  void ccGroupMemberKicked(
      cc.Action message, User kickedUser, User kickedBy, Group kickedFrom) {
    if (_checkGroupSettings() == false) {
      return;
    }
    if (loggedInUserId == kickedUser.uid) {
      refreshSingleConversation(message, true, remove: true);
    } else {
      refreshSingleConversation(message, true);
    }
  }

  @override
  onGroupMemberBanned(
      cc.Action action, User bannedUser, User bannedBy, Group bannedFrom) {
    if (_checkGroupSettings() == false) {
      return;
    }
    if (loggedInUserId == bannedUser.uid) {
      refreshSingleConversation(action, true, remove: true);
    } else {
      refreshSingleConversation(action, true);
    }
  }

  @override
  onGroupMemberUnbanned(cc.Action action, User unbannedUser, User unbannedBy,
      Group unbannedFrom) {
    if (_checkGroupSettings() == false) {
      return;
    }
    refreshSingleConversation(action, true);
  }

  @override
  onGroupMemberScopeChanged(cc.Action action, User updatedBy, User updatedUser,
      String scopeChangedTo, String scopeChangedFrom, Group group) {
    if (_checkGroupSettings() == false) {
      return;
    }
    refreshSingleConversation(action, true);
  }

  @override
  onMemberAddedToGroup(
      cc.Action action, User addedby, User userAdded, Group addedTo) {
    if (_checkGroupSettings() == false) {
      return;
    }
    refreshSingleConversation(action, true);
  }

  @override
  void ccGroupMemberBanned(
      cc.Action message, User bannedUser, User bannedBy, Group bannedFrom) {
    if (_checkGroupSettings() == false) {
      return;
    }

    if (loggedInUserId == bannedUser.uid) {
      refreshSingleConversation(message, true, remove: true);
    } else {
      refreshSingleConversation(message, true);
    }
  }
  //----------------Group Listeners end----------------------------------------------

  @override
  updateUserStatus(User user, String status) {
    int matchingIndex = list.indexWhere((element) =>
        (element.conversationType == ReceiverTypeConstants.user &&
            (element.conversationWith as User).uid == user.uid));

    if (matchingIndex != -1) {
      (list[matchingIndex].conversationWith as User).status = status;
      update();
    }
  }

  //------------------------------------------------------------------------

  //----------------Public Methods -----------------------------------------------------

  @override
  deleteConversation(Conversation conversation) {
    int matchingIndex = getMatchingIndex(conversation);

    deleteConversationFromIndex(matchingIndex);
  }

  @override
  resetUnreadCount(BaseMessage message) {
    int matchingIndex = getMatchingIndexFromKey(message.conversationId!);
    if (matchingIndex != -1) {
      list[matchingIndex].unreadMessageCount = 0;
      update();
    }
  }

  @override
  updateLastMessage(BaseMessage message) async {
    int matchingIndex = getMatchingIndexFromKey(message.conversationId!);
    if (matchingIndex != -1) {
      Conversation conversation = list[matchingIndex];
      conversation.lastMessage = message;
      conversation.unreadMessageCount = 0;
      removeElementAt(matchingIndex);
      addElement(conversation);
    } else {
      final conversation =
          await CometChatHelper.getConversationFromMessage(message);
      if (conversation != null) {
        addElement(conversation);
      }
    }
  }

  @override
  updateGroup(Group group) {
    int matchingIndex = list.indexWhere((element) =>
        ((element.conversationWith is Group) &&
            ((element.conversationWith as Group).guid == group.guid)));

    if (matchingIndex != -1) {
      list[matchingIndex].conversationWith = group;
      update();
    }
  }

  @override
  removeGroup(String guid) {
    int matchingIndex = list.indexWhere((element) =>
        ((element.conversationWith is Group) &&
            ((element.conversationWith as Group).guid == guid)));

    if (matchingIndex != -1) {
      removeElementAt(matchingIndex);
    }
  }

  @override
  updateLastMessageOnEdited(BaseMessage message) async {
    int matchingIndex = getMatchingIndexFromKey(message.conversationId!);

    if (matchingIndex != -1) {
      if (list[matchingIndex].lastMessage?.id == message.id) {
        list[matchingIndex].lastMessage = message;
        update();
      }
    }
  }

  @override
  refreshSingleConversation(BaseMessage message, bool isActionMessage,
      {bool? remove}) async {
    if (checkMessageIsAllowed(message)) {
      final conversation =
          await CometChatHelper.getConversationFromMessage(message);
      if (conversation != null) {
        conversation.lastMessage = message;
        conversation.updatedAt = message.updatedAt;
        if (remove == true) {
          removeElement(conversation);
        } else {
          updateConversation(conversation);
        }
      }
    }
  }

  ///Update the conversation with new conversation Object matched according to conversation id ,  if not matched inserted at top
  @override
  updateConversation(Conversation conversation) {
    int matchingIndex = getMatchingIndex(conversation);

    bool incrementUnreadCount = false;
    bool isCategoryMessage = (conversation.lastMessage!.category ==
            MessageCategoryConstants.message) ||
        (conversation.lastMessage!.category ==
            MessageCategoryConstants.interactive) ||
        (conversation.lastMessage!.category == MessageCategoryConstants.call);
    if (conversation.lastMessage is CustomMessage) {
      final message = conversation.lastMessage as CustomMessage;
      if (message.updateConversation == true ||
          (conversation.lastMessage?.metadata?[
                      UpdateSettingsConstant.incrementUnreadCount] ??
                  false) ==
              true ||
          (CometChatUIKit.conversationUpdateSettings?.customMessages ??
              true == true)) {
        incrementUnreadCount = true;
      }
    }

    if (matchingIndex != -1) {
      Conversation oldConversation = list[matchingIndex];

      if ((incrementUnreadCount || isCategoryMessage) &&
          conversation.lastMessage?.sender?.uid != loggedInUserId) {
        conversation.unreadMessageCount =
            (oldConversation.unreadMessageCount ?? 0) + 1;
      } else {
        conversation.unreadMessageCount = oldConversation.unreadMessageCount;
      }
      removeElementAt(matchingIndex);
      addElement(conversation);
    } else {
      if ((incrementUnreadCount || isCategoryMessage) &&
          conversation.lastMessage?.sender?.uid != loggedInUserId) {
        int oldCount = conversation.unreadMessageCount ?? 0;
        conversation.unreadMessageCount = oldCount + 1;
      }
      addElement(conversation);
    }

    update();
  }

//Set Receipt for
  @override
  setReceipts(MessageReceipt receipt) {
    for (int i = 0; i < list.length; i++) {
      Conversation conversation = list[i];
      if (conversation.conversationType == ReceiverTypeConstants.user &&
          receipt.sender.uid == ((conversation.conversationWith as User).uid)) {
        BaseMessage? lastMessage = conversation.lastMessage;

        //Check if receipt type is delivered
        if (lastMessage != null &&
            lastMessage.deliveredAt == null &&
            receipt.receiptType == ReceiptTypeConstants.delivered &&
            receipt.messageId == lastMessage.id) {
          lastMessage.deliveredAt = receipt.deliveredAt;
          list[i].lastMessage = lastMessage;
          update();
          break;
        } else if (lastMessage != null &&
            lastMessage.readAt == null &&
            receipt.receiptType == ReceiptTypeConstants.read &&
            receipt.messageId == lastMessage.id) {
          //if receipt type is read
          lastMessage.readAt = receipt.readAt;
          list[i].lastMessage = lastMessage;
          update();

          break;
        }
      } else if (conversation.conversationType == ReceiverTypeConstants.group) {
        BaseMessage? lastMessage = conversation.lastMessage;

        //Check if receipt type is delivered to all
        if (lastMessage != null &&
            lastMessage.deliveredAt == null &&
            receipt.receiptType == ReceiptTypeConstants.deliveredToAll &&
            receipt.messageId == lastMessage.id) {
          lastMessage.deliveredAt = receipt.deliveredAt;
          list[i].lastMessage = lastMessage;
          update();
          break;
        } else if (lastMessage != null &&
            lastMessage.readAt == null &&
            receipt.receiptType == ReceiptTypeConstants.readByAll &&
            receipt.messageId == lastMessage.id) {
          //if receipt type is read by all
          lastMessage.readAt = receipt.readAt;
          list[i].lastMessage = lastMessage;
          update();
          break;
        }
      }
    }
  }

  @override
  setTypingIndicator(
      TypingIndicator typingIndicator, bool isTypingStarted) async {
    int matchingIndex;
    if (typingIndicator.receiverType == ReceiverTypeConstants.user) {
      matchingIndex = list.indexWhere((Conversation conversation) =>
          (conversation.conversationType == ReceiverTypeConstants.user &&
              (conversation.conversationWith as User).uid ==
                  typingIndicator.sender.uid));
    } else {
      matchingIndex = list.indexWhere((Conversation conversation) =>
          (conversation.conversationType == ReceiverTypeConstants.group &&
              (conversation.conversationWith as Group).guid ==
                  typingIndicator.receiverId));
    }
    if (matchingIndex != -1) {
      if (isTypingStarted == true) {
        typingMap[list[matchingIndex].conversationId!] = typingIndicator;
      } else {
        if (typingMap.containsKey(list[matchingIndex].conversationId!)) {
          typingMap.remove(list[matchingIndex].conversationId!);
        }
      }
      update();
    }
  }

  @override
  void deleteConversationFromIndex(int index) async {
    late String conversationWith;
    late String conversationType;
    if (list[index].conversationType.toLowerCase() ==
        ReceiverTypeConstants.group.toLowerCase()) {
      conversationWith = (list[index].conversationWith as Group).guid;
      conversationType = ReceiverTypeConstants.group;
    } else {
      conversationWith = (list[index].conversationWith as User).uid;
      conversationType = ReceiverTypeConstants.user;
    }
    if (context != null) {
      final colorPalette = CometChatThemeHelper.getColorPalette(context!);
      final typography = CometChatThemeHelper.getTypography(context!);
      final style = CometChatThemeHelper.getTheme<CometChatConversationsStyle>(
              context: context!, defaultTheme: CometChatConversationsStyle.of)
          .merge(conversationsStyle);
      final confirmDialogStyle =
          CometChatThemeHelper.getTheme<CometChatConfirmDialogStyle>(
                  context: context!,
                  defaultTheme: CometChatConfirmDialogStyle.of)
              .merge(style.deleteConversationDialogStyle);
      CometChatConfirmDialog(
        context: context!,
        confirmButtonText: cc.Translations.of(context!).delete,
        cancelButtonText: cc.Translations.of(context!).cancel,
        icon: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Image.asset(
            AssetConstants.deleteIcon,
            package: UIConstants.packageName,
            height: 48,
            width: 48,
            color: confirmDialogStyle.iconColor ?? colorPalette.error,
          ),
        ),
        title: Text(
          cc.Translations.of(context!).deleteConversation,
          textAlign: TextAlign.center,
        ),
        messageText: Text(
          cc.Translations.of(context!).confirmDeleteConversation,
          textAlign: TextAlign.center,
        ),
        onCancel: () {
          Navigator.pop(context!);
        },
        style: CometChatConfirmDialogStyle(
          iconColor: confirmDialogStyle.iconColor ?? colorPalette.error,
          backgroundColor: confirmDialogStyle.backgroundColor,
          shadow: confirmDialogStyle.shadow,
          iconBackgroundColor: confirmDialogStyle.iconBackgroundColor,
          borderRadius: confirmDialogStyle.borderRadius,
          border: confirmDialogStyle.border,
          cancelButtonBackground: confirmDialogStyle.cancelButtonBackground ??
              colorPalette.transparent,
          confirmButtonBackground:
              confirmDialogStyle.confirmButtonBackground ?? colorPalette.error,
          cancelButtonTextColor: confirmDialogStyle.cancelButtonTextColor,
          confirmButtonTextColor: confirmDialogStyle.confirmButtonTextColor,
          messageTextColor: confirmDialogStyle.messageTextColor,
          titleTextColor: confirmDialogStyle.titleTextColor,
          titleTextStyle: TextStyle(
            color:
                confirmDialogStyle.titleTextColor ?? colorPalette.textPrimary,
            fontSize: typography.heading2?.medium?.fontSize,
            fontWeight: typography.heading2?.medium?.fontWeight,
            fontFamily: typography.heading2?.medium?.fontFamily,
          )
              .merge(
                confirmDialogStyle.titleTextStyle,
              )
              .copyWith(
                color: confirmDialogStyle.titleTextColor,
              ),
          messageTextStyle: TextStyle(
            color: confirmDialogStyle.messageTextColor ??
                colorPalette.textSecondary,
            fontSize: typography.body?.regular?.fontSize,
            fontWeight: typography.body?.regular?.fontWeight,
            fontFamily: typography.body?.regular?.fontFamily,
          )
              .merge(
                confirmDialogStyle.messageTextStyle,
              )
              .copyWith(
                color: confirmDialogStyle.messageTextColor,
              ),
          confirmButtonTextStyle: TextStyle(
            color:
                confirmDialogStyle.confirmButtonTextColor ?? colorPalette.white,
            fontSize: typography.button?.medium?.fontSize,
            fontWeight: typography.button?.medium?.fontWeight,
            fontFamily: typography.button?.medium?.fontFamily,
          )
              .merge(
                confirmDialogStyle.confirmButtonTextStyle,
              )
              .copyWith(
                color: confirmDialogStyle.confirmButtonTextColor,
              ),
          cancelButtonTextStyle: TextStyle(
            color: confirmDialogStyle.cancelButtonTextColor ??
                colorPalette.textPrimary,
            fontSize: typography.button?.medium?.fontSize,
            fontWeight: typography.button?.medium?.fontWeight,
            fontFamily: typography.button?.medium?.fontFamily,
          )
              .merge(
                confirmDialogStyle.cancelButtonTextStyle,
              )
              .copyWith(
                color: confirmDialogStyle.cancelButtonTextColor,
              ),
        ),
        onConfirm: () async {
          isDeleteLoading.value = true;
          await CometChat.deleteConversation(
            conversationWith,
            conversationType,
            onSuccess: (_) {
              isDeleteLoading.value = false;
              CometChatConversationEvents.ccConversationDeleted(list[index]);
            },
            onError: (onError) {
              isDeleteLoading.value = false;
              try {
                var snackBar = SnackBar(
                  backgroundColor: colorPalette.error,
                  content: Text(
                    cc.Translations.of(context!)
                        .errorUnableToDeleteConversation,
                    style: TextStyle(
                      color: colorPalette.white,
                      fontSize: typography.button?.medium?.fontSize,
                      fontWeight: typography.button?.medium?.fontWeight,
                      fontFamily: typography.button?.medium?.fontFamily,
                    ),
                  ),
                );
                ScaffoldMessenger.of(context!).showSnackBar(snackBar);
              } catch (e) {
                if (kDebugMode) {
                  debugPrint("Error while displaying snackBar: $e");
                }
              }
            },
          );
          Navigator.pop(context!);
          update();
        },
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
                  cc.Translations.of(context!).delete,
                  style: TextStyle(
                    color: confirmDialogStyle.confirmButtonTextColor ??
                        colorPalette.white,
                    fontSize: typography.button?.medium?.fontSize,
                    fontWeight: typography.button?.medium?.fontWeight,
                    fontFamily: typography.button?.medium?.fontFamily,
                  )
                      .merge(
                        confirmDialogStyle.confirmButtonTextStyle,
                      )
                      .copyWith(
                        color: confirmDialogStyle.confirmButtonTextColor,
                      ),
                ),
        ),
      ).show();
    }
  }

  @override
  playNotificationSound(BaseMessage message) {
    //Write all conditions here to stop sound
    if (message.type == MessageTypeConstants.custom &&
        (message.metadata?[UpdateSettingsConstant.incrementUnreadCount] !=
            true)) {
      return;
    } //not playing sound in case message type is custom and increment counter is not true

    ///checking if [CometChatConversations] is at the top of the navigation stack
    if (context != null && ModalRoute.of(context!)!.isCurrent) {
      //reset active conversation
      if (activeConversation != null) {
        activeConversation = null;
      }
    }
    if (activeConversation == null) {
      //if no message list is open
      CometChatUIKit.soundManager.play(
          sound: Sound.incomingMessageFromOther,
          customSound: customSoundForMessages);
    } else {
      if (activeConversation != message.conversationId) {
        //if open message list has different conversation id then message received conversation id
        CometChatUIKit.soundManager.play(
            sound: Sound.incomingMessage, customSound: customSoundForMessages);
      }
    }
  }

  @override
  bool getHideThreadIndicator(Conversation conversation) {
    if (conversation.lastMessage?.parentMessageId == null) {
      return true;
    } else if (conversation.lastMessage?.parentMessageId == 0) {
      return true;
    } else {
      return false;
    }
  }

  @override
  bool getHideReceipt(Conversation conversation, bool? receiptsVisibility) {
    if (receiptsVisibility == false || conversation.lastMessage == null) {
      return true;
    } else if (conversation.lastMessage!.category ==
        MessageCategoryConstants.call) {
      return true;
    } else if (conversation.lastMessage!.sender!.uid == loggedInUser?.uid) {
      return false;
    } else {
      return true;
    }
  }

  //----------- get last message text-----------

  void initializeTextFormatters() {
    CometChatConversationsStyle? style;
    CometChatMentionsStyle? ccMentionStyle;
    if (context != null) {
      style = CometChatThemeHelper.getTheme<CometChatConversationsStyle>(
              context: context!, defaultTheme: CometChatConversationsStyle.of)
          .merge(conversationsStyle);
      ccMentionStyle = CometChatThemeHelper.getTheme<CometChatMentionsStyle>(
              context: context!, defaultTheme: CometChatMentionsStyle.of)
          .merge(style.mentionsStyle);
    }
    List<CometChatTextFormatter> textFormatters = this.textFormatters ?? [];

    if ((textFormatters.isEmpty ||
            textFormatters.indexWhere(
                    (element) => element is CometChatMentionsFormatter) ==
                -1)) {
      textFormatters.add(
          CometChatMentionsFormatter(style: ccMentionStyle ?? mentionsStyle));
    }

    this.textFormatters = textFormatters;
  }

  List<CometChatTextFormatter> getTextFormatters(BaseMessage message) {
    List<CometChatTextFormatter> textFormatters = this.textFormatters ?? [];
    if (message is TextMessage) {
      for (CometChatTextFormatter textFormatter in textFormatters) {
        textFormatter.message = message;
      }
    }
    return textFormatters;
  }

  /// ----------------------------EVENT LISTENERS -----------------------------------

  @override
  void onConnected() {
    if (!isLoading) {
      request = conversationsBuilderProtocol.getRequest();
      list = [];
      loadMoreElements(
        isIncluded: (element) => getMatchingIndex(element) != -1,
      );
    }
  }

  @override
  void ccCallAccepted(Call call) {
    if (_checkCallSettings() == false) {
      return;
    }
    refreshSingleConversation(call, true);
  }

  @override
  void ccOutgoingCall(Call call) {
    if (_checkCallSettings() == false) {
      return;
    }
    refreshSingleConversation(call, true);
  }

  @override
  void ccCallRejected(Call call) {
    if (_checkCallSettings() == false) {
      return;
    }
    refreshSingleConversation(call, true);
  }

  @override
  void ccCallEnded(Call call) {
    if (_checkCallSettings() == false) {
      return;
    }
    refreshSingleConversation(call, true);
  }

  @override
  void onIncomingCallReceived(Call call) {
    if (_checkCallSettings() == false) {
      return;
    }
    refreshSingleConversation(call, true);
  }

  @override
  void onOutgoingCallAccepted(Call call) {
    if (_checkCallSettings() == false) {
      return;
    }
    refreshSingleConversation(call, true);
  }

  @override
  void onOutgoingCallRejected(Call call) {
    if (_checkCallSettings() == false) {
      return;
    }
    refreshSingleConversation(call, true);
  }

  @override
  void onIncomingCallCancelled(Call call) {
    if (_checkCallSettings() == false) {
      return;
    }
    refreshSingleConversation(call, true);
  }

  @override
  void onCallEndedMessageReceived(Call call) {
    if (_checkCallSettings() == false) {
      return;
    }
    refreshSingleConversation(call, true);
  }

  @override
  void onSchedulerMessageReceived(SchedulerMessage schedulerMessage) {
    if (_checkMessageSettings(schedulerMessage)) {
      return;
    }
    _onMessageReceived(schedulerMessage, false);
  }

  // Check settings for custom message and thread message condition
  bool _checkMessageSettings(BaseMessage message) {
    if (message.parentMessageId != 0 &&
        CometChatUIKit.conversationUpdateSettings != null &&
        !CometChatUIKit.conversationUpdateSettings!.messageReplies) {
      return true;
    } else if (message is CustomMessage &&
        (message.updateConversation == false) &&
        ((message.metadata?[UpdateSettingsConstant.incrementUnreadCount] ??
                false) ==
            false) &&
        (CometChatUIKit.conversationUpdateSettings?.customMessages == false)) {
      return true;
    } else {
      return false;
    }
  }

  // Check settings for call
  bool _checkCallSettings() {
    if (CometChatUIKit.conversationUpdateSettings != null) {
      return CometChatUIKit.conversationUpdateSettings!.callActivities;
    }
    return true;
  }

// Check settings for Group Actions
  bool _checkGroupSettings() {
    if (CometChatUIKit.conversationUpdateSettings != null) {
      return CometChatUIKit.conversationUpdateSettings!.groupActions;
    }
    return true;
  }

  // checking if the message received is permitted under the type of conversations mentioned in the request builder
  bool checkMessageIsAllowed(BaseMessage message) {
    return conversationsBuilderProtocol.requestBuilder.conversationType ==
            null ||
        message.receiverType ==
            conversationsBuilderProtocol.requestBuilder.conversationType;
  }

  bool hideUserPresence(User? user) {
    return user != null &&
        (usersStatusVisibility == false || !userIsNotBlocked(user));
  }

  bool hideGroupIconVisibility(Group? group) {
    return group != null &&
        (groupTypeVisibility != true);
  }

  void clearSelection() {
    selectionMap.clear();
    update();
  }

  // Function to show pop-up menu on long press
  void showPopupMenu(
    BuildContext context,
    List<CometChatOption> options,
    GlobalKey widgetKey,
  ) {
    if(options.isEmpty) {
      return;
    }
    RelativeRect? position = WidgetPositionUtil.getWidgetPosition(context, widgetKey);
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
            child: GetMenuView(
              option: option,
            ));
      }).toList(),
    ).then((selectedOption) {
      if (selectedOption != null) {
        selectedOption.onClick?.call();
      }
    });
  }
}
