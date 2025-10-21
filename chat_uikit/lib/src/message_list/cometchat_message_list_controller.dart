import 'dart:async';
import 'dart:collection';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cometchat_chat_uikit/src/message_list/messages_builder_protocol.dart';
import 'package:get/get.dart';

import '../../cometchat_chat_uikit.dart';
import '../../cometchat_chat_uikit.dart' as cc;

///[CometChatMessageListController] is the view model for [CometChatMessageList]
///it contains all the business logic involved in changing the state of the UI of [CometChatMessageList]
class CometChatMessageListController
    extends CometChatSearchListController<BaseMessage, int>
    with
        GroupListener,
        CometChatGroupEventListener,
        CometChatMessageEventListener,
        CometChatUIEventListener,
        CometChatCallEventListener,
        CallListener,
        ConnectionListener,
        AIAssistantListener
    implements CometChatMessageListControllerProtocol, QueueCompletionCallback {
  //--------------------Constructor-----------------------
  CometChatMessageListController({
    required this.messagesBuilderProtocol,
    this.user,
    this.group,
    this.customIncomingMessageSound,
    this.customIncomingMessageSoundPackage,
    this.disableSoundForMessages = false,
    this.hideDeletedMessage = false,
    this.scrollToBottomOnNewMessage = false,
    ScrollController? scrollController,
    this.stateCallBack,
    super.onError,
    super.onEmpty,
    super.onLoad,
    this.messageTypes,
    this.receiptsVisibility,
    this.messageListStyle,
    this.disableReactions,
    this.textFormatters,
    this.disableMentions,
    this.mentionsStyle,
    this.headerView,
    this.footerView,
    this.onReactionClick,
    this.smartRepliesDelayDuration,
    this.enableConversationStarters,
    this.enableSmartReplies,
    this.smartRepliesKeywords,
    this.addTemplate,
    this.dateSeparatorPattern,
    this.hideModerationView,
    this.suggestedMessages,
    this.setAiAssistantTools,
    this.streamingSpeed,
    this.hideStickyDate,
  }) : super(
            builderProtocol: user != null
                ? (messagesBuilderProtocol
                  ..requestBuilder.uid = user.uid
                  ..requestBuilder.guid = '')
                : (messagesBuilderProtocol
                  ..requestBuilder.guid = group!.guid
                  ..requestBuilder.uid = '')) {
    dateStamp = DateTime.now().microsecondsSinceEpoch.toString();
    _messageListenerId = "${dateStamp}user_listener";
    _groupListenerId = "${dateStamp}group_listener";
    _uiGroupListener = "${dateStamp}UIGroupListener";
    _uiMessageListener = "${dateStamp}UI_message_listener";
    _uiEventListener = "${dateStamp}UI_Event_listener";
    _uiCallListener = "${dateStamp}UI_Call_listener";
    _sdkCallListenerId = "${dateStamp}sdk_Call_listener";
    _sdkAIAssistantListenerId = "${dateStamp}sdk_Stream_listener";

    createTemplateMap();

    if (user != null) {
      conversationWithId = user!.uid;
      conversationType = ReceiverTypeConstants.user;
    } else {
      conversationWithId = group!.guid;
      conversationType = ReceiverTypeConstants.group;
    }

    if (scrollController != null) {
      messageListScrollController = scrollController;
    } else {
      messageListScrollController = ScrollController();
    }
    messageListScrollController.addListener(_scrollControllerListener);
    tag = "tag$counter";
    counter++;

    threadMessageParentId =
        messagesBuilderProtocol.getRequest().parentMessageId ?? 0;
    isThread = threadMessageParentId > 0;

    messageListId = {};

    if (user != null) {
      messageListId['uid'] = user?.uid;
    }
    if (group != null) {
      messageListId['guid'] = group?.guid;
    }

    if (threadMessageParentId > 0) {
      messageListId['parentMessageId'] = threadMessageParentId;
    }

    initializeTextFormatters();
  }

  //-------------------------Variable Declaration-----------------------------
  late MessagesBuilderProtocol messagesBuilderProtocol;
  late String dateStamp;
  late String _messageListenerId;
  late String _groupListenerId;

  User? loggedInUser;
  User? user;
  Group? group;
  Map<String, CometChatMessageTemplate> templateMap = {};
  List<CometChatMessageTemplate>? messageTypes;
  String conversationWithId = "";
  String conversationType = "";
  String? conversationId;
  Conversation? conversation;
  String? customIncomingMessageSound;
  String? customIncomingMessageSoundPackage;
  late bool disableSoundForMessages;
  int threadMessageParentId = 0;
  late bool hideDeletedMessage;
  late bool scrollToBottomOnNewMessage;
  late ScrollController messageListScrollController;
  int newUnreadMessageCount = 0;
  Function(CometChatMessageListController controller)? stateCallBack;
  static int counter = 0;
  late String tag;
  bool isThread = false;
  late String _uiGroupListener;
  late String _uiMessageListener;
  late String _uiStreamCallbackListener;
  late BuildContext context;

  /// [addTemplate] Add Custom message templates on the existing templated.
  final List<CometChatMessageTemplate>? addTemplate;

  ///[dateSeparatorPattern] pattern for  date separator
  final String Function(DateTime dateTime)? dateSeparatorPattern;

  late Map<String, dynamic> messageListId;

  ///[messageListStyle] that can be used to style message list
  final CometChatMessageListStyle? messageListStyle;

  bool inInitialized = false;

  ///[receiptsVisibility] controls visibility of read receipts
  final bool? receiptsVisibility;

  ///[onReactionClick] This is to override the click of a reaction pill.
  final Function(String? emoji, BaseMessage message)? onReactionClick;

  ///[suggestedMessages] is a list of predefined replies for the AI assistant.
  final List<String>? suggestedMessages;

  /// [setAiAssistantTools] This map contains the tool name as key and a function that takes a string argument and returns void as value. This function will be called when the AI assistant invokes a tool.
  final Map<String, Function(String? args)>? setAiAssistantTools;

  ///[streamingSpeed] sets the speed of streaming for AI assistant
  final int? streamingSpeed;

  late String _uiEventListener;
  late String _uiCallListener;
  late String _sdkCallListenerId;
  late String _sdkAIAssistantListenerId;

  ///[headerView] shown in header view
  Widget? Function(BuildContext,
      {User? user, Group? group, int? parentMessageId})? headerView;

  ///[footerView] shown in footer view
  Widget? Function(BuildContext,
      {User? user, Group? group, int? parentMessageId})? footerView;

  final bool? disableReactions;

  /// [smartRepliesDelayDuration] The number of milliseconds after which Smart Replies will be triggered.  If set to `0` smart replies will be fetched instantly without any delay.
  final int? smartRepliesDelayDuration;

  ///[enableConversationStarters] This will not generate conversation starter in new conversations.
  final bool? enableConversationStarters;

  ///[enableSmartReplies] This will not generate smart replies in the chat.
  final bool? enableSmartReplies;

  /// [smartRepliesKeywords] The keywords present in the incoming message that will trigger Smart Replies. If set to `[]` smart replies will be fetched for all messages.
  final List<String>? smartRepliesKeywords;

  /// [hideModerationView] This prop defines whether the moderation view of a message should be hidden or not.
  final bool? hideModerationView;

  ///[hideStickyDate] Hide the sticky date separator
  final bool? hideStickyDate;

  bool isScrolled = false;

  Widget? header;
  Widget? footer;
  Widget? defaultHeader;
  Widget? defaultFooter;

  int? initialUnreadCount;

  List<CometChatTextFormatter>? textFormatters;
  bool? disableMentions;

  final CometChatMentionsStyle? mentionsStyle;

  final moderationUtil = ModerationCheckUtil.instance;

  final CometChatStreamService _queueManager = CometChatStreamService();

  void _scrollControllerListener() {
    double offset = messageListScrollController.offset;

    if (offset <= 10 && newUnreadMessageCount != 0) {
      markAsRead(list[0]);
      newUnreadMessageCount = 0;
    }

    bool hasScrolled = offset > 100;

    if (hasScrolled != isScrolled) {
      isScrolled = hasScrolled;
      update();
    }

    if (hideStickyDate == true || list.isEmpty) return;

    final listBox = context.findRenderObject() as RenderBox?;
    if (listBox == null) return;

    final listTop = listBox.localToGlobal(Offset.zero).dy;

    DateTime? topDate;
    double maxY = double.negativeInfinity;
    int topIndex = 0;

    keys.forEach((index, key) {
      final ctx = key.currentContext;
      if (ctx != null) {
        final box = ctx.findRenderObject() as RenderBox;
        // position relative to list top
        final y = box.localToGlobal(Offset.zero).dy - listTop;

        // find the element closest to the top but still visible
        if (y <= 0 && y > maxY) {
          maxY = y;
          topIndex = index;
        }
      }
    });

    topDate = list[topIndex].sentAt;

    if (topDate != null && stickyDateNotifier.value != topDate) {
      stickyDateNotifier.value = topDate;
      stickyDateString =
          dateSeparatorPattern != null ? dateSeparatorPattern!(topDate) : null;
    }
  }

  createTemplateMap() {
    List<CometChatMessageTemplate> localTypes =
        CometChatUIKit.getDataSource().getAllMessageTemplates();
    if (addTemplate != null && addTemplate!.isNotEmpty) {
      localTypes.addAll(addTemplate!);
    }
    messageTypes?.forEach((element) {
      templateMap["${element.category}_${element.type}"] = element;
    });

    for (var element in localTypes) {
      String key = "${element.category}_${element.type}";

      CometChatMessageTemplate? localTemplate = templateMap[key];

      if (localTemplate == null) {
        templateMap[key] = element;
      } else {
        if (localTemplate.footerView == null) {
          templateMap[key]?.footerView = element.footerView;
        }

        if (localTemplate.headerView == null) {
          templateMap[key]?.headerView = element.headerView;
        }

        if (localTemplate.bottomView == null) {
          templateMap[key]?.bottomView = element.bottomView;
        }

        if (localTemplate.bubbleView == null) {
          templateMap[key]?.bubbleView = element.bubbleView;
        }

        if (localTemplate.contentView == null) {
          templateMap[key]?.contentView = element.contentView;
        }

        if (localTemplate.options == null) {
          templateMap[key]?.options = element.options;
        }
      }
    }
  }

  //-------------------------LifeCycle Methods-----------------------------
  @override
  void onInit() {
    CometChat.addGroupListener(_groupListenerId, this);
    CometChatGroupEvents.addGroupsListener(_uiGroupListener, this);
    CometChatMessageEvents.addMessagesListener(_uiMessageListener, this);
    CometChatUIEvents.addUiListener(_uiEventListener, this);
    CometChatCallEvents.addCallEventsListener(_uiCallListener, this);
    CometChat.addCallListener(_sdkCallListenerId, this);
    CometChat.addConnectionListener(_messageListenerId, this);
    CometChat.addAIAssistantListener(_sdkAIAssistantListenerId, this);
    initializeHeaderAndFooterView();
    moderationUtil.hideModerationStatus = hideModerationView ?? false;
    getLoggedInUser();

    if (isUserAgentic()) {
      if (streamingSpeed != null) {
        _queueManager.streamDelay = Duration(milliseconds: streamingSpeed!);
      }
      if (threadMessageParentId == 0) {
        CometChatUIEvents.ccActiveChatChanged(
            messageListId, null, user, group, initialUnreadCount ?? 0);
        isLoading = false;
        list.clear();
        return;
      }
    }
    super.onInit();
  }

  ValueNotifier<DateTime?> stickyDateNotifier = ValueNotifier<DateTime?>(null);

  final Map<int, GlobalKey> keys = {};

  String? stickyDateString;

  @override
  void onClose() {
    CometChat.removeGroupListener(_groupListenerId);
    CometChatGroupEvents.removeGroupsListener(_uiGroupListener);
    CometChatMessageEvents.removeMessagesListener(_uiMessageListener);
    CometChatUIEvents.removeUiListener(_uiEventListener);
    CometChatCallEvents.removeCallEventsListener(_uiCallListener);
    CometChat.removeCallListener(_sdkCallListenerId);
    CometChat.removeConnectionListener(_messageListenerId);
    CometChat.removeAIAssistantListener(_sdkAIAssistantListenerId);
    if (isUserAgentic()) {
      CometChatStreamCallBackEvents.ccStreamCompleted(true);
      _queueManager.cleanupAll();
    }
    super.onClose();
  }

  //-------------------------Parent List overriding Methods-----------------------------
  @override
  bool match(BaseMessage elementA, BaseMessage elementB) {
    return elementA.id == elementB.id;
  }

  @override
  int getKey(BaseMessage element) {
    return element.id;
  }

  Future<void> getUnreadCount() async {
    if (initialUnreadCount == null) {
      Map<String, Map<String, int>>? resultMap =
          await CometChat.getUnreadMessageCount();

      if (resultMap != null) {
        Map<String, int> countMap = {};

        if (user != null) {
          countMap = resultMap["user"] ?? {};
        } else if (group != null) {
          countMap = resultMap["group"] ?? {};
        }
        if (countMap[user?.uid ?? group?.guid] != null) {
          initialUnreadCount = (countMap[user?.uid ?? group?.guid] as int);
        } else {
          initialUnreadCount = 0;
        }
      }
    }
  }

  BaseMessage? lastParticipantMessage;

  @override
  loadMoreElements({bool Function(BaseMessage element)? isIncluded}) async {
    if (isUserAgentic() && threadMessageParentId == 0) {
      return;
    }
    isLoading = true;
    BaseMessage? lastMessage;
    getLoggedInUser();
    await getUnreadCount();
    conversation ??= (await CometChat.getConversation(
        conversationWithId, conversationType,
        onSuccess: (conversation) {}, onError: (_) {}));
    conversationId ??= conversation?.conversationId;

    try {
      await request.fetchPrevious(onSuccess: (List<BaseMessage> fetchedList) {
        if (fetchedList.isEmpty) {
          isLoading = false;
          hasMoreItems = false;
          onEmpty?.call();
          update();
        } else {
          isLoading = false;
          hasMoreItems = true;
          for (var element in fetchedList.reversed) {
            if (element is InteractiveMessage) {
              element = InteractiveMessageUtils
                  .getSpecificMessageFromInteractiveMessage(element);
            }

            list.add(element);

            if (lastParticipantMessage == null) {
              if (element.sender?.uid != loggedInUser?.uid) {
                lastParticipantMessage = element;
                markAsRead(element);
              }
            }
          }
          if (inInitialized == false && list.isNotEmpty) {
            lastMessage = list[0];
          }
          onLoad?.call(list);
        }
        update();
      }, onError: (CometChatException e) {
        onError?.call(e);
        error = e;
        hasError = true;
        update();
      });
    } catch (e, s) {
      error = CometChatException("ERR", s.toString(), "Error");
      hasError = true;
      isLoading = false;
      hasMoreItems = false;
      update();
    }

    if (inInitialized == false) {
      inInitialized = true;
      CometChatUIEvents.ccActiveChatChanged(
          messageListId, lastMessage, user, group, initialUnreadCount ?? 0);
      if (list.isEmpty &&
          enableConversationStarters == true &&
          messageListId["parentMessageId"] == null) {
        getConversationStarter(user, group);
      }
    }
  }

  getLoggedInUser() async {
    loggedInUser ??= await CometChat.getLoggedInUser();
  }

  //------------------------UI Message Event Listeners------------------------------

  @override
  void onTextMessageReceived(TextMessage textMessage) async {
    if (enableSmartReplies == true) {
      _checkForSmartReplies(textMessage: textMessage);
    }
    if (_messageCategoryTypeCheck(textMessage)) {
      _onMessageReceived(textMessage);
    }
  }

  @override
  void onMediaMessageReceived(MediaMessage mediaMessage) {
    hidePanelReceivedMessage(mediaMessage);
    if (_messageCategoryTypeCheck(mediaMessage)) {
      _onMessageReceived(mediaMessage);
    }
  }

  @override
  void onCustomMessageReceived(CustomMessage customMessage) {
    hidePanelReceivedMessage(customMessage);
    if (_messageCategoryTypeCheck(customMessage)) {
      _onMessageReceived(customMessage);
    }
  }

  @override
  void onSchedulerMessageReceived(SchedulerMessage schedulerMessage) {
    hidePanelReceivedMessage(schedulerMessage);
    if (_messageCategoryTypeCheck(schedulerMessage)) {
      _onMessageReceived(schedulerMessage);
    }
  }

  @override
  void onMessagesDelivered(MessageReceipt messageReceipt) {
    if (user != null) {
      for (int i = 0; i < list.length; i++) {
        if (messageReceipt.receiptType == ReceiptTypeConstants.delivered &&
            list[i].sender?.uid == loggedInUser?.uid) {
          if (i == 0 || list[i].deliveredAt == null) {
            list[i].deliveredAt = messageReceipt.deliveredAt;
          } else {
            break;
          }
        }
      }
      update();
    }
  }

  @override
  void onMessagesRead(MessageReceipt messageReceipt) {
    if (user != null) {
      for (int i = 0; i < list.length; i++) {
        if (messageReceipt.receiptType == ReceiptTypeConstants.read &&
            list[i].sender?.uid == loggedInUser?.uid) {
          if (i == 0 || list[i].readAt == null) {
            list[i].readAt = messageReceipt.readAt;
            list[i].deliveredAt ??= messageReceipt.readAt;
          } else {
            break;
          }
        }
      }
      update();
    }
  }

  @override
  void onMessagesDeliveredToAll(MessageReceipt messageReceipt) {
    if (messageReceipt.receiverType == ReceiverTypeConstants.group) {
      for (int i = 0; i < list.length; i++) {
        if (list[i].id == messageReceipt.messageId &&
            messageReceipt.receiptType == ReceiptTypeConstants.deliveredToAll) {
          if (i == 0 || list[i].deliveredAt == null) {
            list[i].deliveredAt = messageReceipt.deliveredAt;
          } else {
            break;
          }
        }
      }
      update();
    }
  }

  @override
  void onMessagesReadByAll(MessageReceipt messageReceipt) {
    if (messageReceipt.receiverType == ReceiverTypeConstants.group) {
      for (int i = 0; i < list.length; i++) {
        if (list[i].sender?.uid == loggedInUser?.uid &&
            messageReceipt.receiptType == ReceiptTypeConstants.readByAll) {
          if (i == 0 || list[i].readAt == null) {
            list[i].readAt = messageReceipt.readAt;
          } else {
            break;
          }
        }
      }
      update();
    }
  }

  @override
  void onMessageEdited(BaseMessage message) {
    if (conversationId == message.conversationId ||
        _checkIfSameConversationForReceivedMessage(message)) {
      updateElement(message);
    }
  }

  @override
  void onMessageDeleted(BaseMessage message) {
    if (conversationId == message.conversationId ||
        _checkIfSameConversationForReceivedMessage(message)) {
      if (request.hideDeleted == true) {
        removeElement(message);
      } else {
        updateElement(message);
      }
    }
  }

  @override
  void onFormMessageReceived(FormMessage formMessage) {
    hidePanelReceivedMessage(formMessage);
    if (_messageCategoryTypeCheck(formMessage)) {
      _onMessageReceived(formMessage);
    }
  }

  @override
  void onCardMessageReceived(CardMessage cardMessage) {
    hidePanelReceivedMessage(cardMessage);
    if (_messageCategoryTypeCheck(cardMessage)) {
      _onMessageReceived(cardMessage);
    }
  }

  @override
  void onCustomInteractiveMessageReceived(
      CustomInteractiveMessage customInteractiveMessage) {
    hidePanelReceivedMessage(customInteractiveMessage);
    if (_messageCategoryTypeCheck(customInteractiveMessage)) {
      _onMessageReceived(customInteractiveMessage);
    }
  }

  @override
  void onInteractionGoalCompleted(InteractionReceipt receipt) {
    debugPrint("interaction completed $receipt");
    if (receipt.sender.uid == loggedInUser?.uid) {
      for (int i = 0; i < list.length; i++) {
        if (list[i].id == receipt.messageId) {
          try {
            (list[i] as InteractiveMessage).interactions = receipt.interactions;
          } on Exception {
            debugPrint("error in converting interactin receipt");
          }
        }
      }
      update();
    }
  }

  @override
  void onMessageModerated(BaseMessage message) {
    if (_checkIfSentByMeInCurrentConversation(message)) {
      if (message is TextMessage || message is MediaMessage) {
        updateModerationStatus(message);
      }
    }
  }

  void updateModerationStatus(BaseMessage message) {
    final matchingIndex = list.indexWhere((e) => e.muid == message.muid);
    if (matchingIndex == -1) {
      return;
    }

    final existingMessage = list[matchingIndex];

    if (message is TextMessage && existingMessage is TextMessage) {
      existingMessage.moderationStatus = message.moderationStatus;
      list[matchingIndex] = existingMessage;
    } else if (message is MediaMessage && existingMessage is MediaMessage) {
      existingMessage.moderationStatus = message.moderationStatus;
      list[matchingIndex] = existingMessage;
    }
    update();
  }

  //------------------------SDK Group Event Listeners------------------------------
  @override
  void onMemberAddedToGroup(
      cc.Action action, User addedby, User userAdded, Group addedTo) {
    if (_messageCategoryTypeCheck(action)) {
      if (group?.guid == addedTo.guid) {
        _onMessageReceived(action);
      }
    }
  }

  @override
  void onGroupMemberJoined(
      cc.Action action, User joinedUser, Group joinedGroup) {
    if (_messageCategoryTypeCheck(action)) {
      if (group?.guid == joinedGroup.guid) {
        _onMessageReceived(action);
      }
    }
  }

  @override
  void onGroupMemberLeft(cc.Action action, User leftUser, Group leftGroup) {
    if (_messageCategoryTypeCheck(action)) {
      if (group?.guid == leftGroup.guid) {
        _onMessageReceived(action, markRead: false, playSound: false);
      }
    }
  }

  @override
  void onGroupMemberKicked(
      cc.Action action, User kickedUser, User kickedBy, Group kickedFrom) {
    if (_messageCategoryTypeCheck(action)) {
      if (group?.guid == kickedFrom.guid) {
        _onMessageReceived(action, markRead: false, playSound: false);
      }
    }
  }

  @override
  void onGroupMemberBanned(
      cc.Action action, User bannedUser, User bannedBy, Group bannedFrom) {
    if (_messageCategoryTypeCheck(action)) {
      if (group?.guid == bannedFrom.guid) {
        _onMessageReceived(action, markRead: false, playSound: false);
      }
    }
  }

  @override
  void ccGroupMemberBanned(
      cc.Action message, User bannedUser, User bannedBy, Group bannedFrom) {
    if (_messageCategoryTypeCheck(message)) {
      if (group?.guid == bannedFrom.guid) {
        _onMessageFromLoggedInUser(message);
      }
    }
  }

  @override
  void ccGroupMemberKicked(
      cc.Action message, User kickedUser, User kickedBy, Group kickedFrom) {
    if (_messageCategoryTypeCheck(message)) {
      if (group?.guid == kickedFrom.guid) {
        _onMessageFromLoggedInUser(message);
      }
    }
  }

  @override
  void ccGroupMemberAdded(List<cc.Action> messages, List<User> usersAdded,
      Group groupAddedIn, User addedBy) {
    if (group?.guid == groupAddedIn.guid) {
      for (var message in messages) {
        if (_messageCategoryTypeCheck(message)) {
          _onMessageFromLoggedInUser(message);
        }
      }
    }
  }

  @override
  void ccGroupMemberUnbanned(cc.Action message, User unbannedUser,
      User unbannedBy, Group unbannedFrom) {
    if (_messageCategoryTypeCheck(message)) {
      if (group?.guid == unbannedFrom.guid) {
        _onMessageFromLoggedInUser(message);
      }
    }
  }

  @override
  void onGroupMemberUnbanned(cc.Action action, User unbannedUser,
      User unbannedBy, Group unbannedFrom) {
    if (_messageCategoryTypeCheck(action)) {
      if (group?.guid == unbannedFrom.guid) {
        _onMessageReceived(action);
      }
    }
  }

  @override
  void onGroupMemberScopeChanged(
      cc.Action action,
      User updatedBy,
      User updatedUser,
      String scopeChangedTo,
      String scopeChangedFrom,
      Group group) {
    if (_messageCategoryTypeCheck(action)) {
      if (group.guid == this.group?.guid) {
        if (loggedInUser?.uid == updatedUser.uid) {
          //TODO: use scopeChangedTo instead of scopeChangedFrom when the bug in SDK is fixed
          this.group?.scope = scopeChangedFrom;
          debugPrint(
              'scope of ${updatedUser.name} changed to $scopeChangedFrom from $scopeChangedTo');
        }
        _onMessageReceived(action);
      }
    }
  }

  //------------------------UI Message Event Listeners------------------------------

  @override
  ccMessageSent(BaseMessage message, MessageStatus messageStatus) {
    // For agentic user, set parent id on first sent message
    if (_checkIfSameConversationForSenderMessage(message)) {
      if (isUserAgentic() && message is TextMessage) {
        if (threadMessageParentId == 0 && message.parentMessageId == 0) {
          threadMessageParentId = message.parentMessageId;
        } else if (messageStatus == MessageStatus.sent &&
            threadMessageParentId == 0 &&
            message.parentMessageId != 0 &&
            list.isNotEmpty) {
          threadMessageParentId = message.parentMessageId;
          messagesBuilderProtocol.requestBuilder.parentMessageId =
              threadMessageParentId;
          request = messagesBuilderProtocol.getRequest();
          if (threadMessageParentId > 0) {
            messageListId['parentMessageId'] = threadMessageParentId;
          }
        }
      }

      hidePanelSentMessage(message);

      if (message.parentMessageId == threadMessageParentId) {
        if (messageStatus == MessageStatus.inProgress) {
          addMessage(message);
          if (isUserAgentic() && message is TextMessage) {
            CometChatStreamCallBackEvents.ccStreamInProgress(true);
          }
        } else if (messageStatus == MessageStatus.sent) {
          updateMessageWithMuid(message);
          if (isUserAgentic() && message is TextMessage) {
            addStreamMessage(message);
          }
        } else if (messageStatus == MessageStatus.error) {
          updateMessageWithMuid(message);
        }
      } else {
        if (messageStatus == MessageStatus.sent) {
          updateMessageThreadCount(message.parentMessageId);
        }
      }
    }
  }

  @override
  void ccMessageEdited(BaseMessage message, MessageEditStatus status) {
    if ((_checkIfSameConversationForReceivedMessage(message) ||
            _checkIfSameConversationForSenderMessage(message)) &&
        status == MessageEditStatus.success) {
      updateElement(message);
    }
  }

  @override
  void ccMessageDeleted(BaseMessage message, EventStatus messageStatus) {
    if (_checkIfSameConversationForSenderMessage(message) &&
        messageStatus == EventStatus.success) {
      if (request.hideDeleted == true) {
        removeElement(message);
      } else {
        updateElement(message);
      }
    }
  }

  //---------------Public Methods----------------------
  @override
  addMessage(BaseMessage message) {
    if (list.isNotEmpty) {
      markAsRead(list[0]);
    }
    if (messageListScrollController.hasClients) {
      messageListScrollController.jumpTo(0.0);
    }
    addElement(message);
  }

  @override
  updateMessageWithMuid(BaseMessage message) {
    int matchingIndex =
        list.indexWhere((element) => element.muid == message.muid);
    if (matchingIndex == -1) return;

    BaseMessage existingMessage = list[matchingIndex];

    if (existingMessage is TextMessage || existingMessage is MediaMessage) {
      bool isDisapproved =
          moderationUtil.isMessageDisapprovedFromModeration(existingMessage);
      if (!isDisapproved) {
        list[matchingIndex] = message;
        update();
      } else {
        if (existingMessage is TextMessage) {
          TextMessage textMessage = message as TextMessage;
          textMessage.moderationStatus = ModerationStatusEnum.DISAPPROVED;
        } else {
          MediaMessage mediaMessage = message as MediaMessage;
          mediaMessage.moderationStatus = ModerationStatusEnum.DISAPPROVED;
        }
      }
    } else {
      list[matchingIndex] = message;
      update();
    }
  }

  @override
  deleteMessage(BaseMessage message) async {
    await CometChat.deleteMessage(message.id, onSuccess: (updatedMessage) {
      updatedMessage.deletedAt ??= DateTime.now();
      message.deletedAt = DateTime.now();
      message.deletedBy = loggedInUser?.uid;
      CometChatMessageEvents.ccMessageDeleted(
          updatedMessage, EventStatus.success);
    }, onError: (_) {});
  }

  @override
  updateMessageThreadCount(int parentMessageId) {
    int matchingIndex = list.indexWhere((item) => item.id == parentMessageId);
    if (matchingIndex != -1) {
      list[matchingIndex].replyCount++;
      update();
    }
  }

  _playSound() {
    if (!disableSoundForMessages) {
      CometChatUIKit.soundManager.play(
          sound: Sound.incomingMessage,
          customSound: customIncomingMessageSound,
          packageName: customIncomingMessageSound == null ||
                  customIncomingMessageSound == ""
              ? UIConstants.packageName
              : customIncomingMessageSoundPackage);
    }
  }

  markAsRead(BaseMessage message) {
    if (message.sender?.uid != loggedInUser?.uid && message.readAt == null) {
      CometChat.markAsRead(message, onSuccess: (String res) {
        CometChatMessageEvents.ccMessageRead(message);
      }, onError: (e) {});
    }
  }

  _onMessageReceived(BaseMessage message,
      {bool playSound = true, bool markRead = true}) {
    // For agentic user, set parent id on first received message
    if (isUserAgentic() && threadMessageParentId == 0) {
      if (message.parentMessageId > 0) {
        threadMessageParentId = message.parentMessageId;
      } else {
        threadMessageParentId = message.id;
      }
      messagesBuilderProtocol.requestBuilder.parentMessageId =
          threadMessageParentId;
      request = messagesBuilderProtocol.getRequest();
      if (threadMessageParentId > 0) {
        messageListId['parentMessageId'] = threadMessageParentId;
      }
    }

    // For agentic user, set parentMessageId for subsequent messages
    if (isUserAgentic() && threadMessageParentId > 0) {
      message.parentMessageId = threadMessageParentId;
    }

    if ((message.conversationId == conversationId ||
            _checkIfSameConversationForReceivedMessage(message) ||
            _checkIfSameConversationForSenderMessage(message)) &&
        message.parentMessageId == threadMessageParentId) {
      addElement(message);
      if (playSound) {
        _playSound();
      }

      if (scrollToBottomOnNewMessage) {
        markAsRead(message);
        if (messageListScrollController.hasClients) {
          messageListScrollController.jumpTo(0.0);
        }
      } else {
        if (messageListScrollController.hasClients &&
            messageListScrollController.offset > 100) {
          newUnreadMessageCount++;
        } else {
          markAsRead(message);
        }
      }
    } else if (message.conversationId == conversationId ||
        _checkIfSameConversationForReceivedMessage(message)) {
      //incrementing reply count
      if (playSound) {
        _playSound();
      }
      int matchingIndex =
          list.indexWhere((element) => (element.id == message.parentMessageId));
      if (matchingIndex != -1) {
        list[matchingIndex].replyCount++;
      }
      update();
    }
  }

  _onMessageFromLoggedInUser(BaseMessage message,
      {bool playSound = true, bool markRead = true}) {
    if ((message.conversationId == conversationId ||
            _checkIfSameConversationForSenderMessage(message)) &&
        message.parentMessageId == threadMessageParentId) {
      addElement(message);
      debugPrint("playSound  = $playSound");
      if (playSound) {
        _playSound();
      }

      if (scrollToBottomOnNewMessage) {
        if (markRead) {
          markAsRead(message);
        }

        if (messageListScrollController.hasClients) {
          messageListScrollController.jumpTo(0.0);
        }
      } else if (markRead) {
        if (messageListScrollController.hasClients &&
            messageListScrollController.offset > 100) {
          newUnreadMessageCount++;
        } else {
          markAsRead(message);
        }
      }
    } else if (message.conversationId == conversationId ||
        _checkIfSameConversationForSenderMessage(message)) {
      //incrementing reply count
      if (playSound) {
        _playSound();
      }

      int matchingIndex =
          list.indexWhere((element) => (element.id == message.parentMessageId));
      if (matchingIndex != -1) {
        list[matchingIndex].replyCount++;
      }
      update();
    }
  }

  //-----message option methods-----

  _messageEdit(
      BaseMessage message, CometChatMessageListControllerProtocol state) {
    if (message.deletedAt == null) {
      CometChatMessageEvents.ccMessageEdited(
          message, MessageEditStatus.inProgress);
    }
  }

  _delete(BaseMessage message, CometChatMessageListControllerProtocol state) {
    final colorPalette = CometChatThemeHelper.getColorPalette(context);
    final typography = CometChatThemeHelper.getTypography(context);

    CometChatConfirmDialog(
      context: context,
      confirmButtonText: cc.Translations.of(context).delete,
      cancelButtonText: cc.Translations.of(context).cancel,
      icon: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Image.asset(
          AssetConstants.deleteIcon,
          package: UIConstants.packageName,
          height: 48,
          width: 48,
          color: colorPalette.error,
        ),
      ),
      title: Text(
        cc.Translations.of(context).deleteMessage,
        textAlign: TextAlign.center,
      ),
      messageText: Text(
        cc.Translations.of(context).deleteMessageWarning,
        textAlign: TextAlign.center,
      ),
      onCancel: () {
        FocusScope.of(context).unfocus();
        Navigator.pop(context);
      },
      style: CometChatConfirmDialogStyle(
        iconColor: colorPalette.error,
        confirmButtonBackground: colorPalette.error,
        titleTextStyle: TextStyle(
          color: colorPalette.textPrimary,
          fontSize: typography.heading2?.medium?.fontSize,
          fontWeight: typography.heading2?.medium?.fontWeight,
          fontFamily: typography.heading2?.medium?.fontFamily,
        ),
        messageTextStyle: TextStyle(
          color: colorPalette.textSecondary,
          fontSize: typography.body?.regular?.fontSize,
          fontWeight: typography.body?.regular?.fontWeight,
          fontFamily: typography.body?.regular?.fontFamily,
        ),
        confirmButtonTextStyle: TextStyle(
          color: colorPalette.white,
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
      onConfirm: () async {
        FocusScope.of(context).unfocus();
        if (message.deletedAt == null) {
          CometChatMessageEvents.ccMessageDeleted(
              message, EventStatus.inProgress);
          Navigator.pop(context);
          deleteMessage(message);
        }
      },
      confirmButtonTextWidget: Text(
        cc.Translations.of(context).delete,
        style: TextStyle(
          color: colorPalette.white,
          fontSize: typography.button?.medium?.fontSize,
          fontWeight: typography.button?.medium?.fontWeight,
          fontFamily: typography.button?.medium?.fontFamily,
        ),
      ),
    ).show();
  }

  _shareMessage(
      BaseMessage message, CometChatMessageListControllerProtocol state) async {
    //share
    if (message is TextMessage) {
      String text = message.text;
      //if message has mentions we need to send the text with mentions and not the original text
      if (message.mentionedUsers.isNotEmpty) {
        text = CometChatMentionsFormatter.getTextWithMentions(
            message.text, message.mentionedUsers);
      }
      await UIConstants.channel.invokeMethod(
        "shareMessage",
        {'message': text, "type": "text"},
      );
    } else if (message is MediaMessage) {
      await UIConstants.channel.invokeMethod(
        "shareMessage",
        {
          "message": message.attachment?.fileName, // For ios
          'mediaName': message.attachment?.fileName,
          "type": "media",
          "subtype": message.type.toString(),
          "fileUrl": message.attachment?.fileUrl,
          "mimeType": message.attachment?.fileMimeType
        },
      );
    }
  }

  _copyMessage(
      BaseMessage message, CometChatMessageListControllerProtocol state) {
    if (message is TextMessage) {
      String text = message.text;
      if (message.mentionedUsers.isNotEmpty) {
        text = CometChatMentionsFormatter.getTextWithMentions(
            message.text, message.mentionedUsers);
      }
      Clipboard.setData(ClipboardData(text: text));
    } else if (message is AIAssistantMessage) {
      String text = message.text ?? "";
      Clipboard.setData(ClipboardData(text: text));
    }
  }

  _messageInformation(
      BaseMessage message, CometChatMessageListControllerProtocol state) {
    final listStyle = CometChatThemeHelper.getTheme<CometChatMessageListStyle>(
            context: context, defaultTheme: CometChatMessageListStyle.of)
        .merge(messageListStyle);

    final messageInfoStyle =
        CometChatThemeHelper.getTheme<CometChatMessageInformationStyle>(
                context: context,
                defaultTheme: CometChatMessageInformationStyle.of)
            .merge(listStyle.messageInformationStyle);
    showMessageInformation(
      context: context,
      message: message,
      template: templateMap["${message.category}_${message.type}"],
      messageInformationStyle: messageInfoStyle,
    );
  }

  _sendMessagePrivately(
      BaseMessage message, CometChatMessageListControllerProtocol state) async {
    if (message.receiver is Group) {
      User? user = await CometChat.getUser(
        message.sender!.uid,
        onSuccess: (user) {
          debugPrint("User fetched successfully $user");
        },
        onError: (excep) {
          debugPrint("Error fetching user ${excep.message}");
        },
      );
      if (context.mounted) {
        if (message.parentMessageId != 0) {
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        } else {
          Navigator.of(context).pop();
        }
      }
      CometChatUIEvents.openChat(user, null);
    }
  }

  createMessage(BaseMessage copyFromMessage, User? user, Group? group) async {
    if (copyFromMessage is TextMessage) {
      TextMessage message = TextMessage(
        text: copyFromMessage.text,
        receiverUid: user?.uid ?? group?.guid ?? "",
        type: MessageTypeConstants.text,
        category: MessageCategoryConstants.message,
        receiverType: user != null
            ? ReceiverTypeConstants.user
            : ReceiverTypeConstants.group,
        muid: DateTime.now().microsecondsSinceEpoch.toString(),
        sender: loggedInUser,
        parentMessageId: 0,
      );
      await CometChatUIKit.sendTextMessage(message,
          onSuccess: (BaseMessage returnedMessage) {},
          onError: (CometChatException excep) {});
    } else if (copyFromMessage is MediaMessage) {
      if (copyFromMessage.attachment == null) return;

      String fileUrl = copyFromMessage.attachment!.fileUrl;
      String fileName = copyFromMessage.attachment!.fileName;
      String fileExtension = copyFromMessage.attachment!.fileExtension;
      String fileMimeType = copyFromMessage.attachment!.fileMimeType;

      Attachment attachment =
          Attachment(fileUrl, fileName, fileExtension, fileMimeType, null);

      MediaMessage message = MediaMessage(
          receiverUid: user?.uid ?? group?.guid ?? "",
          type: copyFromMessage.type,
          category: MessageCategoryConstants.message,
          receiverType: user != null
              ? ReceiverTypeConstants.user
              : ReceiverTypeConstants.group,
          muid: DateTime.now().microsecondsSinceEpoch.toString(),
          sender: loggedInUser,
          parentMessageId: 0,
          attachment: attachment);

      await CometChatUIKit.sendMediaMessage(message,
          onSuccess: (BaseMessage returnedMessage) {},
          onError: (CometChatException excep) {});
    } else if (copyFromMessage is CustomMessage) {
      CustomMessage message = CustomMessage(
        customData: copyFromMessage.customData,
        receiverUid: user?.uid ?? group?.guid ?? "",
        type: copyFromMessage.type,
        category: MessageCategoryConstants.custom,
        receiverType: user != null
            ? ReceiverTypeConstants.user
            : ReceiverTypeConstants.group,
        muid: DateTime.now().microsecondsSinceEpoch.toString(),
        sender: loggedInUser,
        parentMessageId: 0,
      );

      await CometChatUIKit.sendCustomMessage(message,
          onSuccess: (BaseMessage returnedMessage) {},
          onError: (CometChatException excep) {});
    }
  }

  Function(BaseMessage message, CometChatMessageListControllerProtocol state)?
      getActionFunction(String id) {
    switch (id) {
      case MessageOptionConstants.editMessage:
        {
          return _messageEdit;
        }
      case MessageOptionConstants.deleteMessage:
        {
          return _delete;
        }
      case MessageOptionConstants.shareMessage:
        {
          return _shareMessage;
        }
      case MessageOptionConstants.copyMessage:
        {
          return _copyMessage;
        }
      case MessageOptionConstants.messageInformation:
        {
          return _messageInformation;
        }
      case MessageOptionConstants.sendMessagePrivately:
        {
          return _sendMessagePrivately;
        }

      default:
        {
          return null;
        }
    }
  }

  @override
  void ccGroupMemberScopeChanged(cc.Action message, User updatedUser,
      String scopeChangedTo, String scopeChangedFrom, Group group) {
    if (group.guid == this.group?.guid) {
      if (loggedInUser?.uid == updatedUser.uid) {
        this.group?.scope = scopeChangedTo;
      }
      debugPrint(
          'scope of ${updatedUser.name} changed to $scopeChangedTo from $scopeChangedFrom');
      _onMessageFromLoggedInUser(message);
    }
  }

  bool _checkIfSameConversationForReceivedMessage(BaseMessage message) {
    return (message.receiverType == CometChatReceiverType.user &&
            user?.uid == message.sender?.uid) ||
        (message.receiverType == CometChatReceiverType.group &&
            group?.guid == message.receiverUid);
  }

  bool _checkIfSameConversationForSenderMessage(BaseMessage message) {
    return (message.sender?.role == AIConstants.aiRole &&
            conversationId == message.conversationId) ||
        (message.receiverType == CometChatReceiverType.user &&
            user?.uid == message.receiverUid) ||
        (message.receiverType == CometChatReceiverType.group &&
            group?.guid == message.receiverUid);
  }

  bool _checkIfSentByMeInCurrentConversation(BaseMessage message) {
    if (message.sender?.uid != loggedInUser?.uid) {
      return false;
    }

    return (message.receiverType == CometChatReceiverType.user &&
            user?.uid == message.receiverUid) ||
        (message.receiverType == CometChatReceiverType.group &&
            group?.guid == message.receiverUid);
  }

  BubbleContentVerifier checkBubbleContent(
      BaseMessage messageObject, ChatAlignment alignment) {
    bool isMessageSentByMe = messageObject.sender?.uid == loggedInUser?.uid;

    BubbleAlignment alignment0 = BubbleAlignment.right;
    bool thumbnail = false;
    bool name = false;
    bool readReceipt = true;
    bool showTime = true;

    if (alignment == ChatAlignment.standard) {
      //-----if message is group action-----
      if ((messageObject.category == MessageCategoryConstants.action) ||
          (messageObject.category == MessageCategoryConstants.call)) {
        thumbnail = false;
        name = false;
        readReceipt = false;
        showTime = false;
        alignment0 = BubbleAlignment.center;
      }
      //-----if message sent by me-----
      else if (isMessageSentByMe) {
        thumbnail = false;
        name = false;
        readReceipt = true;
        alignment0 = BubbleAlignment.right;
      }
      //-----if message received in user conversation-----
      else if (user != null) {
        thumbnail = false;
        name = false;
        readReceipt = false;
        alignment0 = BubbleAlignment.left;
      }
      //-----if message received in group conversation-----
      else if (group != null) {
        thumbnail = true;
        name = true;
        readReceipt = false;
        alignment0 = BubbleAlignment.left;
      }
    } else if (alignment == ChatAlignment.leftAligned) {
      //-----if message is  action message -----
      if ((messageObject.category == MessageCategoryConstants.action) ||
          (messageObject.category == MessageCategoryConstants.call &&
              messageObject.receiver is User)) {
        thumbnail = false;
        name = false;
        readReceipt = false;
        alignment0 = BubbleAlignment.center;
        showTime = false;
      }
      //-----if message sent by me-----
      else if (isMessageSentByMe) {
        thumbnail = true;
        name = true;
        readReceipt = true;
        alignment0 = BubbleAlignment.left;
      }
      //-----if message received in user conversation-----
      else if (user != null) {
        thumbnail = true;
        name = true;
        readReceipt = false;
        alignment0 = BubbleAlignment.left;
      }
      //-----if message received in group conversation-----
      else if (group != null) {
        thumbnail = true;
        name = true;
        readReceipt = false;
        alignment0 = BubbleAlignment.left;
      }
    }

    if (messageObject.category == MessageCategoryConstants.agentic &&
        (messageObject.type == MessageTypeConstants.toolResult ||
            messageObject.type == MessageTypeConstants.toolArguments)) {
      name = false;
      thumbnail = false;
      readReceipt = false;
      showTime = false;
    }

    if (messageObject.category == MessageCategoryConstants.agentic &&
        messageObject.type == MessageTypeConstants.assistant) {
      alignment0 = BubbleAlignment.left;
      name = false;
      thumbnail = true;
      readReceipt = false;
      showTime = false;
    }

    if (messageObject.category == MessageCategoryConstants.streamMessage &&
        messageObject.type == MessageTypeConstants.runStarted) {
      alignment0 = BubbleAlignment.left;
      name = false;
      thumbnail = true;
      readReceipt = false;
      showTime = false;
    }

    if (receiptsVisibility == false) {
      readReceipt = false;
    }

    if (messageObject.type == MessageTypeConstants.meeting) {
      readReceipt = false;
      showTime = false;
    }

    if (messageObject.deletedAt != null) {
      readReceipt = false;
    }

    return BubbleContentVerifier(
      showThumbnail: thumbnail,
      showTime: showTime,
      showName: name,
      showReadReceipt: readReceipt,
      alignment: alignment0,
    );
  }

  @override
  initializeHeaderAndFooterView() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (headerView != null) {
        defaultHeader = headerView!(context,
            user: user, group: group, parentMessageId: threadMessageParentId);
      }

      if (footerView != null) {
        defaultFooter = footerView!(context,
            user: user, group: group, parentMessageId: threadMessageParentId);
      }
    });
  }

  Widget? getHeaderView() {
    return header ?? defaultHeader;
  }

  Widget? getFooterView() {
    return footer ?? defaultFooter;
  }

  @override
  void showPanel(Map<String, dynamic>? id, CustomUIPosition uiPosition,
      WidgetBuilder child) {
    if (isForThisWidget(id) == false) return;
    if (uiPosition == CustomUIPosition.messageListBottom) {
      footer = child(context);
    } else if (uiPosition == CustomUIPosition.messageListTop) {
      header = child(context);
    }
    update();
  }

  @override
  void hidePanel(Map<String, dynamic>? id, CustomUIPosition uiPosition) {
    if (isForThisWidget(id) == false) return;
    if (uiPosition == CustomUIPosition.messageListBottom) {
      footer = null;
    } else if (uiPosition == CustomUIPosition.messageListBottom) {
      header = null;
    }
    update();
  }

  bool isForThisWidget(Map<String, dynamic>? id) {
    if (id == null) {
      return true; //if passed id is null , that means for all composer
    }
    if ((id['uid'] != null &&
            id['uid'] ==
                user?.uid) //checking if uid or guid match composer's uid or guid
        ||
        (id['guid'] != null && id['guid'] == group?.guid)) {
      if (id['parentMessageId'] != null) {
        return (threadMessageParentId == id['parentMessageId']);
      }

      return true;
    }
    return false;
  }

//--------------SDK Call listeners-----------------------------------------------

  @override
  void onIncomingCallReceived(Call call) {
    call.category = MessageCategoryConstants.call;
    _onMessageReceived(call, playSound: false, markRead: false);
  }

  @override
  void onOutgoingCallAccepted(Call call) {
    call.category = MessageCategoryConstants.call;
    _onMessageReceived(call, playSound: false, markRead: false);
  }

  @override
  void onOutgoingCallRejected(Call call) {
    call.category = MessageCategoryConstants.call;
    _onMessageReceived(call, playSound: false, markRead: false);
  }

  @override
  void onIncomingCallCancelled(Call call) {
    call.category = MessageCategoryConstants.call;
    _onMessageReceived(call);
  }

  @override
  void onCallEndedMessageReceived(Call call) {
    call.category = MessageCategoryConstants.call;
    _onMessageReceived(call);
  }

//----------------- UI Call Listeners---------------

  bool _checkCallInSameConversation(Call call) {
    if (kDebugMode) {
      print(" $threadMessageParentId ${user?.uid} ${call.receiverUid} ");
    }

    return (threadMessageParentId == 0 &&
        user != null &&
        (call.sender?.uid == user?.uid || call.receiverUid == user?.uid));
  }

  @override
  void ccOutgoingCall(Call call) {
    if (_checkCallInSameConversation(call)) {
      _onMessageFromLoggedInUser(call, markRead: false, playSound: false);
    }
  }

  @override
  void ccCallAccepted(Call call) {
    if (_checkCallInSameConversation(call)) {
      _onMessageFromLoggedInUser(call, markRead: false, playSound: false);
    }
  }

  @override
  void ccCallRejected(Call call) {
    if (_checkCallInSameConversation(call)) {
      _onMessageFromLoggedInUser(call, markRead: false, playSound: false);
    }
  }

  @override
  void ccCallEnded(Call call) {
    if (_checkCallInSameConversation(call)) {
      _onMessageFromLoggedInUser(call, markRead: false, playSound: false);
    }
  }

  @override
  String getConversationId() {
    return conversationWithId;
  }

  @override
  BuildContext getCurrentContext() {
    return context;
  }

  @override
  Group? getGroup() {
    return group;
  }

  @override
  int? getParentMessageId() {
    return threadMessageParentId;
  }

  @override
  ScrollController getScrollController() {
    return messageListScrollController;
  }

  @override
  Map<String, CometChatMessageTemplate> getTemplateMap() {
    return templateMap;
  }

  @override
  User? getUser() {
    return user;
  }

  @override
  void onConnected() {
    getLoggedInUser();

    if (isUserAgentic()) {
      // Clear all queues on reconnection
      CometChatStreamCallBackEvents.ccStreamCompleted(true);
      _queueManager.onConnected();

      // Handle any runs that were interrupted during disconnection
      _handleInterruptedRuns();
    }

    if (!isUserAgentic() && !isLoading) {
      _updateUserAndGroup();
      _fetchNewMessages();
    }
  }

  @override
  void onDisconnected() {
    if (isUserAgentic()) {
      CometChatStreamCallBackEvents.ccStreamInterrupted(true);
      _queueManager.onDisconnected(context);
    }
  }

  @override
  void onConnectionError(CometChatException e) {
    if (isUserAgentic()) {
      CometChatStreamCallBackEvents.ccStreamInterrupted(true);
      _queueManager.onConnectionError(e, context);
    }
  }

  void _handleInterruptedRuns() {
    list
        .whereType<StreamMessage>()
        .toList()
        .forEach((msg) => removeElement(msg));
  }

  /// [_fetchNewMessages] method fetches the new messages from the server after a web socket connection is re-established.
  void _fetchNewMessages() async {
    if (isUserAgentic()) {
      return;
    }
    int? lastMessageId;
    for (int i = 0; i < list.length; i++) {
      if (list[i].id != 0) {
        lastMessageId = list[i].id;
        break;
      }
    }
    bool hasMoreItems = true;
    int messageId = lastMessageId ?? 1;
    List<String> categories =
        messagesBuilderProtocol.requestBuilder.categories ??
            CometChatUIKit.getDataSource().getAllMessageCategories();
    List<String> types = messagesBuilderProtocol.requestBuilder.types ??
        CometChatUIKit.getDataSource().getAllMessageTypes();
    bool hideReplies =
        messagesBuilderProtocol.requestBuilder.hideReplies ?? true;
    int parentMessageId =
        messagesBuilderProtocol.requestBuilder.parentMessageId ?? 0;

    /// used to fetch the old messages from the server starting from the last message in the list that have been edited or deleted
    types.add(MessageTypeConstants.message);

    while (hasMoreItems) {
      ///The following message request fetches the new messages received after the last message sent or received recorded in the list.
      MessagesRequest messageRequest = (MessagesRequestBuilder()
            ..uid = user?.uid
            ..guid = group?.guid
            ..categories = categories
            ..types = types
            ..messageId = messageId
            ..parentMessageId = parentMessageId
            ..hideReplies = hideReplies)
          .build();
      try {
        await messageRequest.fetchNext(
            onSuccess: (List<BaseMessage> fetchedList) {
          //if fetched messages list is empty, it means there are no new messages and hence stop proceeding.
          if (fetchedList.isNotEmpty) {
            hasMoreItems = true;
            for (BaseMessage message in fetchedList) {
              if (message is InteractiveMessage) {
                message = InteractiveMessageUtils
                    .getSpecificMessageFromInteractiveMessage(message);
              }
              if (message.parentMessageId != 0) {
                updateMessageThreadCount(message.parentMessageId);
              } else if (message is cc.Action) {
                if (message.type == MessageTypeConstants.message &&
                    (message.action == ActionMessageTypeConstants.edited ||
                        message.action == ActionMessageTypeConstants.deleted) &&
                    message.actionOn is BaseMessage) {
                  BaseMessage actionOn = message.actionOn as BaseMessage;
                  int matchingIndex =
                      list.indexWhere((element) => (element.id == actionOn.id));
                  if (matchingIndex != -1) {
                    list[matchingIndex] = actionOn;
                    update();
                  }
                } else if (message.sender?.uid != null &&
                    loggedInUser?.uid != null &&
                    message.sender?.uid == loggedInUser?.uid) {
                  updateMessageWithMuid(message);
                } else {
                  addElement(message);
                  newUnreadMessageCount++;
                  update();
                }
              } else {
                for (int i = 0; i < list.length; i++) {
                  if (list[i].muid == message.muid) {
                    removeElementAt(i);
                    update();
                    break;
                  }
                }
                addElement(message);
                newUnreadMessageCount++;
                update();
              }
            }
            messageId = fetchedList.last.id;
            return;
          } else {
            hasMoreItems = false;
            update();
          }
        }, onError: (CometChatException e) {
          hasMoreItems = false;
        });
      } catch (e, _) {
        hasMoreItems = false;
      }
    }
  }

  ///[_updateUserAndGroup] method updates the user and group details if the user or group is updated while the web socket connection is lost.
  _updateUserAndGroup() async {
    if (user != null) {
      user = await CometChat.getUser(
        user!.uid,
        onSuccess: (user) {},
        onError: (excep) {},
      );
    }
    if (group != null) {
      group = await CometChat.getGroup(
        group!.guid,
        onSuccess: (group) {},
        onError: (excep) {},
      );
    }
    update();
  }

  //  event listeners for message reaction

  @override
  void onMessageReactionAdded(ReactionEvent reactionEvent) {
    if (disableReactions != true) {
      _updateMessageOnReaction(reactionEvent, ReactionAction.reactionAdded);
    }
  }

  @override
  void onMessageReactionRemoved(ReactionEvent reactionEvent) {
    if (disableReactions != true) {
      _updateMessageOnReaction(reactionEvent, ReactionAction.reactionRemoved);
    }
  }

  _updateMessageOnReaction(ReactionEvent reactionEvent, String reactionAction) {
    Reaction? messageReaction = reactionEvent.reaction;
    if (messageReaction != null) {
      int? messageId = messageReaction.messageId;
      if (messageId == null) return;
      BaseMessage? message =
          list.firstWhereOrNull((element) => element.id == messageId);
      if (message == null) return;
      CometChatHelper.updateMessageWithReactionInfo(
              message, messageReaction, reactionAction)
          .then((reactedMessage) {
        if (reactedMessage == null) return;

        updateElement(reactedMessage);
      });
    }
  }

  handleReactionPress(
      BaseMessage message, String? reaction, List<ReactionCount> reactionList) {
    if (reaction == null || reaction.isEmpty) return;
    int reactionIndex = reactionList.indexWhere((reactionCount) =>
        reactionCount.reaction == reaction &&
        reactionCount.reactedByMe == true);
    if (reactionIndex != -1) {
      updateElement(updateReactionsOnMessage(message, reaction, false));

      /// remove reaction
      CometChat.removeReaction(
        message.id,
        reaction,
        onError: (error) {
          updateElement(updateReactionsOnMessage(message, reaction, true));
        },
        onSuccess: (message) {},
      );
    } else {
      /// add reaction
      updateElement(updateReactionsOnMessage(message, reaction, true));
      CometChat.addReaction(
        message.id,
        reaction,
        onError: (error) {
          updateElement(updateReactionsOnMessage(message, reaction, false));
        },
        onSuccess: (message) {},
      );
    }
  }

  void addReactionIconTap(
      BaseMessage message, CometChatColorPalette colorPalette) async {
    Navigator.of(context).pop();
    String? reaction = await showCometChatEmojiKeyboard(
      context: context,
      colorPalette: colorPalette,
    );

    if (onReactionClick != null) {
      onReactionClick!(reaction, message);
    } else {
      if (reaction != null) {
        handleReactionPress(message, reaction, message.reactions);
      }
    }
  }

  void onReactionTap(BaseMessage message, String? reaction) async {
    if (reaction == null || reaction.isEmpty) return;

    handleReactionPress(message, reaction, message.reactions);
  }

  BaseMessage updateReactionsOnMessage(
      BaseMessage message, String reaction, bool add) {
    ReactionCount reactionCount =
        ReactionCount(reaction: reaction, count: 1, reactedByMe: true);
    int match =
        message.reactions.indexWhere((element) => element.reaction == reaction);
    if (add) {
      if (match == -1) {
        message.reactions.add(reactionCount);
      } else if (message.reactions[match].reactedByMe != true) {
        message.reactions[match].reactedByMe = true;

        if (message.reactions[match].count != null) {
          message.reactions[match].count = message.reactions[match].count! + 1;
        }
      }
    } else {
      if (match != -1 && message.reactions[match].reactedByMe == true) {
        if (message.reactions[match].count == 1) {
          message.reactions.removeAt(match);
        } else {
          message.reactions[match].reactedByMe = false;
          if (message.reactions[match].count != null) {
            message.reactions[match].count =
                message.reactions[match].count! - 1;
          }
        }
      }
    }

    return message;
  }

  /// Validates if the message's category and type match allowed values.
  /// This method checks against categories and types from the request builder,
  /// falling back to default values from the data source if none are provided.
  /// @param message The message to validate.
  /// @return True if both category and type are allowed, false otherwise.
  bool _messageCategoryTypeCheck(BaseMessage message) {
    List<String> categories =
        messagesBuilderProtocol.requestBuilder.categories ??
            CometChatUIKit.getDataSource().getAllMessageCategories();
    List<String> types = messagesBuilderProtocol.requestBuilder.types ??
        CometChatUIKit.getDataSource().getAllMessageTypes();

    return categories.contains(message.category) &&
        types.contains(message.type);
  }

  void initializeTextFormatters() {
    List<CometChatTextFormatter> textFormatters = this.textFormatters ?? [];

    if (textFormatters.isEmpty) {
      textFormatters =
          CometChatUIKit.getDataSource().getDefaultTextFormatters();
      int indexOfMentionsFormatter = textFormatters
          .indexWhere((element) => element is CometChatMentionsFormatter);
      if (indexOfMentionsFormatter != -1) {
        textFormatters[indexOfMentionsFormatter] =
            CometChatMentionsFormatter(style: mentionsStyle);
      }
    } else if (textFormatters.indexWhere(
                (element) => element is CometChatMentionsFormatter) ==
            -1 &&
        disableMentions != true) {
      textFormatters.add(CometChatMentionsFormatter(style: mentionsStyle));
    }

    if (disableMentions == true) {
      textFormatters
          .removeWhere((element) => element is CometChatMentionsFormatter);
    }

    this.textFormatters = textFormatters;
  }

  double getRandomSize(double min, double max) {
    return min + Random().nextDouble() * (max - min);
  }

  AlignmentGeometry getRandomAlignment() {
    return Random().nextBool() ? Alignment.centerLeft : Alignment.centerRight;
  }

  checkAndShowReplies(User? user, Group? group) async {
    Map<String, dynamic>? apiMap;

    Map<String, dynamic> id = {};
    String receiverId = "";
    id[AIUtils.extensionKey] = AIFeatureConstants.aiSmartReplies;
    if (user != null) {
      receiverId = user.uid;
      id['uid'] = receiverId;
    } else if (group != null) {
      receiverId = group.guid;
      id['guid'] = receiverId;
    }

    final listStyle = CometChatThemeHelper.getTheme<CometChatMessageListStyle>(
            context: context, defaultTheme: CometChatMessageListStyle.of)
        .merge(messageListStyle);

    CometChatUIEvents.showPanel(
      id,
      CustomUIPosition.messageListBottom,
      (context) => CometChatAISmartRepliesView(
        user: user,
        group: group,
        apiConfiguration: apiMap,
        style: listStyle.aiSmartRepliesStyle,
      ),
    );
  }

  _checkForSmartReplies({
    TextMessage? textMessage,
  }) {
    User? user;
    Group? group;
    if (textMessage != null) {
      if (textMessage.receiverType == ReceiverTypeConstants.user) {
        user = textMessage.sender as User;
      } else {
        group = textMessage.receiver as Group;
      }

      Debouncer debounce =
          Debouncer(milliseconds: smartRepliesDelayDuration ?? 10000);

      debounce.run(
        () {
          if (smartRepliesKeywords != null &&
              smartRepliesKeywords!.isNotEmpty) {
            for (String keyword in smartRepliesKeywords!) {
              if (textMessage.text
                  .toLowerCase()
                  .contains(keyword.toLowerCase())) {
                checkAndShowReplies(user, group);
                break;
              }
            }
          } else {
            checkAndShowReplies(user, group);
          }
        },
      );
    }
  }

  hideSummaryPanel(Map<String, dynamic>? id) {
    CometChatUIEvents.hidePanel(id, CustomUIPosition.messageListBottom);
  }

  void hidePanelSentMessage(BaseMessage message) {
    String? uid;
    String? guid;
    if (message.receiverType == ReceiverTypeConstants.user) {
      uid = message.receiverUid;
    } else {
      guid = message.receiverUid;
    }
    Map<String, dynamic> idMap = UIEventUtils.createMap(uid, guid, 0);
    hidePanel(idMap, CustomUIPosition.messageListBottom);
  }

  void hidePanelReceivedMessage(BaseMessage message) {
    String? uid;
    String? guid;
    if (message.receiverType == ReceiverTypeConstants.user) {
      uid = message.sender!.uid;
    } else {
      guid = message.receiverUid;
    }
    Map<String, dynamic> idMap = UIEventUtils.createMap(uid, guid, 0);
    hidePanel(idMap, CustomUIPosition.messageListBottom);
  }

  getConversationStarter(User? user, Group? group) async {
    final listStyle = CometChatThemeHelper.getTheme<CometChatMessageListStyle>(
            context: context, defaultTheme: CometChatMessageListStyle.of)
        .merge(messageListStyle);
    Map<String, dynamic>? apiMap;

    Map<String, dynamic> id = {};
    String receiverId = "";
    if (user != null) {
      receiverId = user.uid;
      id['uid'] = receiverId;
    } else if (group != null) {
      receiverId = group.guid;
      id['guid'] = receiverId;
    }

    CometChatUIEvents.showPanel(
      id,
      CustomUIPosition.messageListBottom,
      (context) => CometChatAIConversationStarterView(
        style: listStyle.aiConversationStarterStyle,
        user: user,
        group: group,
        apiConfiguration: apiMap,
      ),
    );
  }

// ----------------- AI Assistant Event Listeners -----------------
  @override
  void onAIAssistantEventReceived(AIAssistantBaseEvent aiAssistantBaseEvent) {
    debugPrint(
        "Received AI Event: ${aiAssistantBaseEvent.type} for Run ID: ${aiAssistantBaseEvent.id}");

    final runId = aiAssistantBaseEvent.id;

    if (runId == null) return;

    _queueManager.handleIncomingEvent(runId, aiAssistantBaseEvent);
    if (_queueManager.runExists(runId)) {
      _processNextEvent(runId, aiAssistantBaseEvent);
    }
  }

// Process all events for a specific run
  Future<void> _processNextEvent(
      int runId, AIAssistantBaseEvent aiAssistantBaseEvent) async {
    if (runId == aiAssistantBaseEvent.id) {
      await Future.delayed(_queueManager.streamDelay);
      if (aiAssistantBaseEvent.type == AgenticKeys.runStarted) {
        _handleRunStarted(aiAssistantBaseEvent as AIAssistantRunStartedEvent);
      } else if (aiAssistantBaseEvent.type == AgenticKeys.runFinished) {
        _handleRunFinished(aiAssistantBaseEvent as AIAssistantRunFinishedEvent);
      } else if (aiAssistantBaseEvent.type == AgenticKeys.toolCallEnd) {
        _handleToolCallEnd(aiAssistantBaseEvent as AIAssistantToolEndedEvent);
      }
    }
  }

  void _createThinkingMessage(int runId) {
    // Create a thinking bubble for new run
    final thinkingMessage = StreamMessage(
      id: runId,
      text: cc.Translations.of(context).thinking,
      sender: user,
      receiver: loggedInUser,
      receiverUid: loggedInUser?.uid ?? '',
      receiverType: ReceiverTypeConstants.user,
      sentAt: DateTime.now(),
      runId: runId,
      muid: "run_$runId",
      metadata: {AIConstants.aiShimmer: true},
    );
    // Use queue manager instead of direct map access
    _queueManager.setMessageIdForRun(runId, thinkingMessage.id);
    _queueManager.getOrCreateBuffer(runId); // Initialize buffer
    if (!_queueManager.checkMessageExists(runId)) {
      _queueManager.registerMessage(thinkingMessage);
      addElement(thinkingMessage);
    }
  }

  Future<void> _handleRunStarted(AIAssistantRunStartedEvent event) async {
    final runId = event.id;
    if (runId == null) return;
  }

  Future<void> _handleToolCallEnd(AIAssistantToolEndedEvent event) async {
    final runId = event.id;
    if (runId == null) return;

    final messageId = _queueManager.getMessageIdForRun(runId);
    if (messageId == null) return;

    if (setAiAssistantTools != null &&
        setAiAssistantTools!.containsKey(event.toolCallName)) {
      setAiAssistantTools?[event.toolCallName]?.call(event.arguments);
    }
  }

  Future<void> _handleRunFinished(AIAssistantRunFinishedEvent event) async {
    final runId = event.id;
    if (runId == null) return;
    CometChatStreamCallBackEvents.ccStreamCompleted(true);

    _queueManager.setQueueCompletionCallback(runId, this);
  }

  @override
  void onAIAssistantMessageReceived(AIAssistantMessage aiAssistantMessage) {
    final runId = aiAssistantMessage.runId;

    debugPrint(
        "AI Assistant Message Received: $threadMessageParentId && ${aiAssistantMessage.parentMessageId}");

    if (threadMessageParentId != aiAssistantMessage.parentMessageId ||
        runId == null) {
      return;
    }

    _queueManager.aiAssistantMessages[runId] = aiAssistantMessage;
    _queueManager.checkAndTriggerQueueCompletion(runId);
  }

  void _cleanupRun(int runId) {
    _queueManager.stopStreamingForRunId(runId);
  }

// Modify your existing addStreamMessage method
  void addStreamMessage(TextMessage textMessage) {
    if (_queueManager.getMessageIdForRun(textMessage.id) == null) {
      _createThinkingMessage(textMessage.id);
    }
  }

  bool isUserAgentic() {
    return user?.role == AIConstants.aiRole;
  }

  String getGreetingMessage() {
    print(user?.metadata);
    return user?.metadata?[AIConstants.greetingMessage] ?? "";
  }

  String getGreetingSubTitleMessage() {
    return user?.metadata?[AIConstants.introductoryMessage] ?? "";
  }

  List<String> getSuggestedMessages() {
    if (suggestedMessages != null && suggestedMessages!.isNotEmpty) {
      return suggestedMessages!;
    }
    return List<String>.from(
        user?.metadata?[AIConstants.suggestedMessages] ?? []);
  }

  String getDisconnectionState(AIAssistantMessage? streamMessage) {
    return streamMessage?.metadata?[AIConstants.disconnection] ?? "";
  }

  void onAiSuggestionTap(String suggestion) {
    if (suggestion.isNotEmpty) {
      CometChatUIEvents.ccComposeMessage(
        suggestion,
        MessageEditStatus.inProgress,
      );
    }
  }

  bool isMessageAgentic(BaseMessage message) {
    return (message.category == MessageCategoryConstants.agentic &&
        message.type == MessageTypeConstants.assistant);
  }

  @override
  void onQueueCompleted(
    AIAssistantMessage? aiAssistantMessage,
    AIToolResultMessage? aiToolResultMessage,
    AIToolArgumentMessage? aiToolArgumentMessage,
  ) {
    CometChatStreamCallBackEvents.ccStreamCompleted(true);
    if (aiAssistantMessage != null) {
      updateStreamMessageIntoAssistantMessage(aiAssistantMessage);
    }

    if (aiToolResultMessage != null) {
      // Handle tool results
    }

    if (aiToolArgumentMessage != null) {
      // Handle tool arguments
    }
  }

  void updateStreamMessageIntoAssistantMessage(
      AIAssistantMessage aiAssistantMessage) {
    for (int i = list.length - 1; i >= 0; i--) {
      if (list[i].id == aiAssistantMessage.runId && list[i] is StreamMessage) {
        list.removeAt(i);
        addElement(aiAssistantMessage);
        break;
      }
    }
  }
}

class BubbleContentVerifier {
  bool showThumbnail;
  bool showName;
  bool showReadReceipt;
  bool showFooterView;
  BubbleAlignment alignment;
  bool showTime;

  BubbleContentVerifier(
      {this.showThumbnail = false,
      this.showName = false,
      this.showReadReceipt = true,
      this.showFooterView = true,
      this.alignment = BubbleAlignment.right,
      this.showTime = true});
}
