import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../cometchat_chat_uikit.dart';
import '../../cometchat_chat_uikit.dart' as cc;

class CometChatConversationsSearchController
    extends CometChatSearchListController<Conversation, String>
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
  CometChatConversationsSearchController({
    required BuilderProtocol builderProtocol,
    Function(Exception)? onError,
    OnLoad<Conversation>? onLoad,
    OnEmpty? onEmpty,
    this.usersStatusVisibility = true,
    this.groupTypeVisibility = true,
    this.receiptsVisibility = true,
    this.tag,
  }) : super(
          builderProtocol: builderProtocol,
          onError: onError,
          onLoad: onLoad,
          onEmpty: onEmpty,
        ) {
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

  final String? tag;

  // The text formatters to be used for formatting text messages.
  List<CometChatTextFormatter>? textFormatters;

  Map<String, TypingIndicator> typingMap = {};

  User? loggedInUser;

  ///[usersStatusVisibility] controls visibility of status indicator shown if a user is online
  final bool? usersStatusVisibility;

  ///[receiptsVisibility] controls visibility of receipts
  final bool? receiptsVisibility;

  ///[groupTypeVisibility] Hide the group type icon which is visible on the group icon.
  final bool? groupTypeVisibility;

  late String dateStamp;
  late String groupSDKListenerID;
  late String groupUIListenerID;
  late String messageSDKListenerID;
  late String messageUIListenerID;
  late String userSDKListenerID;
  late String _uiUserListener;
  late String _conversationListenerId;
  late String _conversationEventListenerId;

  String loggedInUserId = "";

  String? activeConversation;

  Set<String> selectedFilters = {};

  late CometChatSearchController searchController;

  @override
  void onInit() {
    isLoading = false;
    loadUtils();
    // Find the search controller instance
    // Listen to changes
    searchController = Get.find<CometChatSearchController>(tag: tag);
    ever(searchController.selectedFilters, (Set<String> filters) {
      onFilterChanged(filters);
    });
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
  }

  loadUtils() async {
    loggedInUser = await CometChat.getLoggedInUser();
    if (loggedInUser != null) {
      loggedInUserId = loggedInUser!.uid;
    }
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
    selectedFilters.clear();
    list.clear();
    super.onClose();
  }

  final deBouncer = Debouncer(milliseconds: 500);

  /// Request version to track and ignore stale responses
  int _requestVersion = 0;

  void onFilterChanged(Set<String> filters) {
    handleSearchAndFilters(filters: filters);
  }

  @override
  void onSearch(String val) {
    handleSearchAndFilters(searchText: val);
  }

  /// Public loadMore for external callers (e.g., "See More" button)
  Future<void> loadMore() async {
    await _loadMoreWithVersionCheck(_requestVersion);
  }

  @override
  loadMoreElements({bool Function(Conversation element)? isIncluded}) async {
    await _loadMoreWithVersionCheck(_requestVersion);
  }

  Future<void> _loadMoreWithVersionCheck(int requestVersion) async {
    if (isFetching) return;
    
    isFetching = true;
    isLoading = true;

    try {
      await request.fetchNext(
        onSuccess: (List<Conversation> fetchedList) {
          isFetching = false;
          
          // Ignore results if request version has changed
          if (requestVersion != _requestVersion) {
            return;
          }
          
          if (fetchedList.isEmpty) {
            isLoading = false;
            hasMoreItems = false;
            onEmpty?.call();
          } else {
            isLoading = false;
            hasMoreItems = true;
            list.addAll(fetchedList);
            onLoad?.call(list);
          }
          update();
          notifySearchController();
        },
        onError: (CometChatException e) {
          isFetching = false;
          
          // Ignore errors if request version has changed
          if (requestVersion != _requestVersion) {
            return;
          }
          
          error = e;
          hasError = true;
          isLoading = false;
          update();
          notifySearchController();
          onError?.call(e);
        },
      );
    } catch (e, s) {
      isFetching = false;
      
      // Ignore errors if request version has changed
      if (requestVersion != _requestVersion) {
        return;
      }
      
      error = CometChatException("ERR", s.toString(), "Error");
      hasError = true;
      isLoading = false;
      hasMoreItems = false;
      update();
      notifySearchController();
    }
  }

  void handleSearchAndFilters(
      {String? searchText, Set<String>? filters}) async {
    final currentFilters = filters ?? selectedFilters;
    final currentSearch = (searchText ?? searchController.searchText).trim();

    // Update selected filters if passed
    if (filters != null) selectedFilters = filters;

    final validFilters = {SearchConstants.groups, SearchConstants.unread};
    final hasValidFilter = currentFilters.any((f) => validFilters.contains(f));
    final hasInvalidFilter = currentFilters.isNotEmpty && !hasValidFilter;

    // Early return if filters are not relevant to conversations search
    // This prevents unnecessary list clearing and UI updates
    if (hasInvalidFilter) {
      isLoading = false;
      deBouncer.cancel();
      return;
    }

    // Cancel any pending debounced operations first
    deBouncer.cancel();
    
    // Increment request version to invalidate any in-flight requests
    _requestVersion++;
    final currentRequestVersion = _requestVersion;

    // Clear list immediately to prevent stale data from showing
    list.clear();
    isFetching = false;

    if (currentFilters.isEmpty && currentSearch.isEmpty) {
      isLoading = false;
      update();
      notifySearchController();
      return;
    }

    // Show loading state immediately
    isLoading = true;
    update();
    notifySearchController();

    final builder = ConversationsRequestBuilder();

    if (selectedFilters.isEmpty) {
      builder.limit = 3;
    }

    if (currentSearch.isNotEmpty) {
      builder.searchKeyword = currentSearch;
    }

    if (currentFilters.contains(SearchConstants.groups)) {
      builder.conversationType = ConversationType.group;
    }

    if (currentFilters.contains(SearchConstants.unread)) {
      builder.unread = true;
    }

    builderProtocol = UIConversationsBuilder(builder);
    request = builderProtocol.getSearchRequest(currentSearch);

    // Use debouncer for typing search
    deBouncer.run(() async {
      // Check if this request is still valid (not superseded by a newer one)
      if (currentRequestVersion != _requestVersion) {
        return;
      }
      
      await _loadMoreWithVersionCheck(currentRequestVersion);
    });
  }

  @override
  String getKey(Conversation element) {
    return element.conversationId ?? '';
  }

  @override
  bool match(Conversation elementA, Conversation elementB) {
    return getKey(elementA) == getKey(elementB);
  }

  bool hideUserPresence(User? user) {
    return user != null &&
        (usersStatusVisibility == false || !userIsNotBlocked(user));
  }

  bool hideGroupIconVisibility(Group? group) {
    return group != null && (groupTypeVisibility != true);
  }

  bool userIsNotBlocked(User user) {
    return user.blockedByMe != true && user.hasBlockedMe != true;
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
    if (messages.isNotEmpty) {
      refreshSingleConversation(messages.last, true);
    }
  }

  //-----------Message Listeners------------------------------------------------

  _onMessageReceived(BaseMessage message, bool isActionMessage) {
    if (message.sender!.uid != loggedInUserId) {
      CometChat.markAsDelivered(message, onSuccess: (_) {}, onError: (_) {});
    }

    if (list.isNotEmpty) {
      refreshSingleConversation(message, isActionMessage);
    }
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

  @override
  void ccUserBlocked(User user) {
    if (builderProtocol.requestBuilder.includeBlockedUsers == true) {
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
    if (action.actionFor is Group &&
        (action.actionFor as Group).guid == addedTo.guid) {
      Group updatedGroup = action.actionFor as Group;
      updatedGroup.hasJoined = true;

      action.actionFor = updatedGroup;

      // ✅ ALSO update receiver if it's the same group
      if (action.receiver is Group &&
          (action.receiver as Group).guid == addedTo.guid) {
        action.receiver = updatedGroup;
      }
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
    // if (context != null && ModalRoute.of(context!)!.isCurrent) {
    //   //reset active conversation
    //   if (activeConversation != null) {
    //     activeConversation = null;
    //   }
    // }
    // if (activeConversation == null) {
    //   //if no message list is open
    //   CometChatUIKit.soundManager.play(
    //       sound: Sound.incomingMessageFromOther,
    //       customSound: customSoundForMessages);
    // } else {
    //   if (activeConversation != message.conversationId) {
    //     //if open message list has different conversation id then message received conversation id
    //     CometChatUIKit.soundManager.play(
    //         sound: Sound.incomingMessage, customSound: customSoundForMessages);
    //   }
    // }
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
    // if (context != null) {
    //   style = CometChatThemeHelper.getTheme<CometChatConversationsStyle>(
    //           context: context!, defaultTheme: CometChatConversationsStyle.of)
    //       .merge(conversationsStyle);
    //   ccMentionStyle = CometChatThemeHelper.getTheme<CometChatMentionsStyle>(
    //           context: context!, defaultTheme: CometChatMentionsStyle.of)
    //       .merge(style.mentionsStyle);
    // }
    List<CometChatTextFormatter> textFormatters = this.textFormatters ?? [];

    if ((textFormatters.isEmpty ||
        textFormatters.indexWhere(
                (element) => element is CometChatMentionsFormatter) ==
            -1)) {
      textFormatters.add(CometChatMentionsFormatter(
          style: ccMentionStyle /*?? mentionsStyle*/));
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

  /// Checks if there's an active search session that should be preserved.
  /// Returns true if:
  /// - There are applied filters (selectedFilters is not empty), OR
  /// - There's a search text entered, OR
  /// - The list already has results
  bool _hasActiveSearchSession() {
    final hasFilters = selectedFilters.isNotEmpty;
    final hasSearchText = searchController.searchText.trim().isNotEmpty;
    final hasResults = list.isNotEmpty;

    return hasFilters || hasSearchText || hasResults;
  }

  @override
  void onConnected() {
    // Skip refresh if there's an active search session with results
    // This prevents losing search results when returning from background
    if (_hasActiveSearchSession()) {
      return;
    }

    if (!isLoading) {
      request = builderProtocol.getRequest();
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
    return builderProtocol.requestBuilder.conversationType == null ||
        message.receiverType == builderProtocol.requestBuilder.conversationType;
  }

  void clearSelection() {
    selectionMap.clear();
    update();
  }

  void notifySearchController() {
    if (Get.isRegistered<CometChatSearchController>(tag: tag)) {
      final searchCtrl = Get.find<CometChatSearchController>(tag: tag);

      final bool shouldUpdate =
          searchCtrl.showConversationsSearch == true ||
              searchCtrl.showMessagesSearch == true;

      if (shouldUpdate) {
        searchCtrl.update();
      }
    }
  }
}
