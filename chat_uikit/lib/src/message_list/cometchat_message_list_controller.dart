import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:cometchat_chat_uikit/src/message_list/messages_builder_protocol.dart';
import 'package:cometchat_chat_uikit/src/message_list/message_adapter.dart';
import 'package:get/get.dart';
// Not re-exported from cometchat_uikit_shared's public barrel; see
// cometchat_message_list.dart for the same workaround.
// ignore: implementation_imports
import 'package:cometchat_uikit_shared/src/cometchat_message_list/chatwidget/flutter_chat_core/flutter_chat_core.dart'
    as core;

import '../../cometchat_chat_uikit.dart';
import '../../cometchat_chat_uikit.dart' as cc;

///[CometChatMessageListController] is the view model for [CometChatMessageList]
///it contains all the business logic involved in changing the state of the UI of [CometChatMessageList]
class CometChatMessageListController
    extends CometChatMessageSearchListController<BaseMessage, int>
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
    this.messageId,
    this.suggestedMessages,
    this.setAiAssistantTools,
    this.streamingSpeed,
    this.hideStickyDate,
    this.enableConversationSummary,
    this.flagReasonLocalizer,
    this.hideFlagRemarkField,
    this.mentionAllLabel,
    this.mentionAllLabelId,
  }) : super(
         builderProtocol: user != null
             ? (messagesBuilderProtocol
                 ..requestBuilder.uid = user.uid
                 ..requestBuilder.guid = '')
             : (messagesBuilderProtocol
                 ..requestBuilder.guid = group!.guid
                 ..requestBuilder.uid = ''),
       ) {
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
  String? mentionAllLabel;
  String? mentionAllLabelId;
  int threadMessageParentId = 0;
  late bool hideDeletedMessage;
  late bool scrollToBottomOnNewMessage;
  late ScrollController messageListScrollController;
  late core.InMemoryChatController chatController;
  int newUnreadMessageCount = 0;
  Function(CometChatMessageListController controller)? stateCallBack;
  static int counter = 0;
  late String tag;
  bool isThread = false;
  late String _uiGroupListener;

  /// Cancellable retry timer for connection recovery
  Timer? _retryTimer;
  late String _uiMessageListener;
  late BuildContext context;

  /// Set in [onClose]. Guards async continuations (e.g. a fetchPrevious callback
  /// that lands after the chat screen is popped) from touching the disposed
  /// chatController, which would throw
  /// "Bad state: Cannot add new events after calling close".
  bool _isDisposed = false;

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

  /// Timer for debouncing sync operations to chatController
  Timer? _syncDebounceTimer;

  ///[headerView] shown in header view
  Widget? Function(
    BuildContext, {
    User? user,
    Group? group,
    int? parentMessageId,
  })?
  headerView;

  ///[footerView] shown in footer view
  Widget? Function(
    BuildContext, {
    User? user,
    Group? group,
    int? parentMessageId,
  })?
  footerView;

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

  /// [messageId] This prop is used to identify a particular message in the list of messages.
  final int? messageId;

  ///[hideStickyDate] Hide the sticky date separator
  final bool? hideStickyDate;

  ///[enableConversationSummary] This will generate conversation summary.
  final bool? enableConversationSummary;

  ///[generateConversationSummary] This will enable conversation summary.
  RxBool generateConversationSummary = false.obs;

  /// [flagReasonLocalizer] This function is used to localize the reason IDs to the desired language.
  final String Function(String reasonId)? flagReasonLocalizer;

  /// [hideFlagRemarkField] This prop defines whether to hide the remark field in the flag message option.
  final bool? hideFlagRemarkField;

  bool isScrolled = false;

  Widget? header;
  Widget? footer;
  Widget? defaultHeader;
  Widget? defaultFooter;

  int? initialUnreadCount;

  //-------------------------Mark as Unread Properties-----------------------------
  /// [startFromUnreadMessages] when true, the message list will initially
  /// scroll to position the first unread message in view
  bool startFromUnreadMessages = false;

  /// [lastReadMessageId] the last read message ID from the conversation
  int? lastReadMessageId;

  /// [unreadMessageAnchor] the first unread message (anchor for the indicator)
  BaseMessage? unreadMessageAnchor;

  /// [unreadMessageAnchorId] the ID of the first unread message (used to find anchor after list reload)
  int? unreadMessageAnchorId;

  /// [unreadCount] current unread count for the conversation
  int unreadCount = 0;

  /// [highlightScroll] whether to highlight the scroll target (false when scrolling to unread)
  bool highlightScroll = true;

  /// [markedAsUnreadInSession] tracks if user manually marked a message as unread in current session
  /// When true, scrolling to bottom will NOT auto-mark as read
  /// This resets when user leaves and comes back to the chat
  bool markedAsUnreadInSession = false;

  /// [isTargetAboveIndicator] tracks if the current goto target is above the unread indicator
  /// When true, we should preserve the badge count until indicator comes into view
  bool isTargetAboveIndicator = false;

  List<CometChatTextFormatter>? textFormatters;
  bool? disableMentions;

  final CometChatMentionsStyle? mentionsStyle;

  final moderationUtil = ModerationCheckUtil.instance;

  final CometChatStreamService _queueManager = CometChatStreamService();

  bool? isScrollMessageToBottom = false;

  /// [isFetchingNextForQuotedMessage] indicates if fetchNext is being called after going to a quoted message
  bool isFetchingNextForQuotedMessage = false;

  /// [hasJumpedToQuotedMessage] tracks if user has jumped to a quoted message
  bool hasJumpedToQuotedMessage = false;

  /// [isJumpingToMessage] indicates if we're in the process of jumping to a message (includes API + scroll)
  /// This flag is used to show shimmer during the entire goto message process:
  /// 1. API calls to fetch messages around target message
  /// 2. Processing and adding messages to the list
  /// 3. Scrolling/jumping to the target message
  /// The shimmer will be shown until the scroll animation completes
  bool isJumpingToMessage = false;

  /// [isInGoToMessageCooldown] prevents immediate pagination after goToMessage completes
  /// This gives the user time to orient themselves before loading triggers
  bool isInGoToMessageCooldown = false;

  /// [_recentlyAddedMessageIds] tracks message IDs that have been recently added
  /// to prevent duplicate additions from rapid event firing
  final Set<int> _recentlyAddedMessageIds = {};

  /// [_recentlyAddedMessageMuids] tracks message MUIDs that have been recently added
  /// to prevent duplicate additions (used when ID is not yet assigned)
  final Set<String> _recentlyAddedMessageMuids = {};

  /// [_previousScrollOffset] tracks the previous scroll offset for direction detection
  double _previousScrollOffset = 0.0;

  /// [_hasCompletedGoToMessage] tracks if we just completed a goToMessage operation
  /// Used to enable scroll direction logging after jumping to a message
  bool _hasCompletedGoToMessage = false;

  /// [_goToMessageTargetId] stores the message ID we jumped to for logging context
  int? _goToMessageTargetId;

  /// [maxMessagesInMemory] Maximum number of messages to keep in memory at once.
  /// When this limit is exceeded, messages from the opposite end are removed.
  /// This prevents ANR (Application Not Responding) errors when scrolling through
  /// very long message histories.
  static const int maxMessagesInMemory = 600;

  /// [windowBuffer] Number of messages to remove when trimming the list.
  /// We remove more than just the excess to avoid frequent trimming operations.
  static const int windowBuffer = 300;

  /// [isTrimmingWindow] indicates if we're in the process of trimming the message window
  /// This flag is used to show shimmer during the trim + scroll process
  bool isTrimmingWindow = false;

  void _scrollControllerListener() {
    double offset = messageListScrollController.offset;

    // Log scroll direction after goToMessage completion
    if (_hasCompletedGoToMessage) {
      final scrollDelta = offset - _previousScrollOffset;
      if (scrollDelta.abs() > 1.0) {
        // Only log meaningful scroll changes
        final direction = scrollDelta > 0 ? 'DOWN' : 'UP';
        if (kDebugMode) {
          print(
            '📜 [GoToMessage Scroll] Direction: $direction | Delta: ${scrollDelta.toStringAsFixed(2)} | Offset: ${offset.toStringAsFixed(2)} | Target Message ID: $_goToMessageTargetId',
          );
        }
      }
    }

    _previousScrollOffset = offset;

    // Only auto-reset unread count when scrolling to bottom if NOT marked as unread in this session
    // When markedAsUnreadInSession is true, user must tap the scroll-to-bottom button to clear
    if (offset <= 10 &&
        newUnreadMessageCount != 0 &&
        !markedAsUnreadInSession) {
      markAsRead(list[0]);
      newUnreadMessageCount = 0;
    }

    // Auto-mark conversation as read when scrolling to bottom ONLY if:
    // - User did NOT manually mark as unread in this session
    // - There are unread messages (from a previous session/re-entry)
    // When user marks as unread in current session, they must tap the button to mark as read
    if (offset <= 10 &&
        unreadMessageAnchor != null &&
        !markedAsUnreadInSession) {
      markConversationAsRead();
    }

    // Check if unread indicator is visible in viewport
    // If visible, clear the badge count but keep the indicator
    _checkUnreadIndicatorVisibility();

    bool hasScrolled = offset > 100;

    if (hasScrolled != isScrolled) {
      isScrolled = hasScrolled;
      update();
    }

    _updateStickyDate();
  }

  /// Checks if the unread message indicator is visible in the viewport
  /// If visible, clears the badge count (unreadCount) but keeps the indicator
  /// Does NOT auto-clear if user manually marked as unread in this session
  void _checkUnreadIndicatorVisibility() {
    // Don't auto-clear if user manually marked as unread in this session
    // They must tap the scroll-to-bottom button to mark as read
    if (markedAsUnreadInSession) return;

    // Don't check during jump animation - wait until jump completes
    if (isJumpingToMessage) return;

    if (unreadMessageAnchor == null || unreadCount == 0) return;

    final anchorId = unreadMessageAnchor!.id;
    final key = messageKeys[anchorId];
    if (key == null) return;

    final ctx = key.currentContext;
    if (ctx == null) return;

    final renderBox = ctx.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final listBox = context.findRenderObject() as RenderBox?;
    if (listBox == null) return;

    final listTop = listBox.localToGlobal(Offset.zero).dy;
    final listBottom = listTop + listBox.size.height;

    final indicatorPosition = renderBox.localToGlobal(Offset.zero).dy;
    final indicatorBottom = indicatorPosition + renderBox.size.height;

    // Check if indicator is within the visible viewport
    final isVisible =
        indicatorBottom > listTop && indicatorPosition < listBottom;

    if (isVisible) {
      unreadCount = 0;
      isTargetAboveIndicator = false; // Reset the flag
      markConversationAsRead();
      update();
    }
  }

  void _updateStickyDate() {
    if (hideStickyDate == true || list.isEmpty) return;

    final listBox = context.findRenderObject() as RenderBox?;
    if (listBox == null) return;

    final listTop = listBox.localToGlobal(Offset.zero).dy;

    DateTime? topDate;
    double maxY = double.negativeInfinity;
    int? topMessageId;
    bool foundVisibleMessage = false;
    double minPositiveY = double.infinity;
    int? firstVisibleMessageId;

    // Track all messages with their Y positions
    Map<int, double> messagePositions = {};

    indexToMessageKey.forEach((index, msgKey) {
      final ctx = msgKey.currentContext;
      if (ctx != null) {
        try {
          final box = ctx.findRenderObject() as RenderBox;
          final y = box.localToGlobal(Offset.zero).dy - listTop;

          // Find the message by index
          if (index >= 0 && index < list.length) {
            final msg = list[index];
            messagePositions[msg.id] = y;

            // Track the closest message to the top (either scrolled past or at top)
            if (y <= 0 && y > maxY) {
              maxY = y;
              topMessageId = msg.id;
              foundVisibleMessage = true;
            }

            // Also track the first visible message (positive Y closest to 0)
            if (y > 0 && y < minPositiveY) {
              minPositiveY = y;
              firstVisibleMessageId = msg.id;
            }
          }
        } catch (e) {
          // Widget not mounted yet, skip
        }
      }
    });

    // If no message with y <= 0, use the first visible message (smallest positive Y)
    if (!foundVisibleMessage && firstVisibleMessageId != null) {
      topMessageId = firstVisibleMessageId;
      foundVisibleMessage = true;
    }

    // Fallback: If still no visible message found (e.g., after fetch but before render),
    // use the first message in the list
    if (!foundVisibleMessage && list.isNotEmpty) {
      topMessageId = list[0].id;
    }

    // Find the message by ID in the list
    if (topMessageId != null) {
      try {
        final message = list.firstWhere((msg) => msg.id == topMessageId);
        final messageDate = message.sentAt;

        // Check if this is the first message of its date in the visible area
        // by looking at messages above it (higher in list, which means lower index since reversed)
        bool isFirstOfDate = true;
        final messageIndex = list.indexWhere((m) => m.id == topMessageId);

        if (messageIndex > 0 && messageDate != null) {
          // Check previous message (visually below, higher index)
          for (int i = messageIndex - 1; i >= 0; i--) {
            final prevMsg = list[i];
            final prevDate = prevMsg.sentAt;

            // Check if previous message is visible and has position info
            if (messagePositions.containsKey(prevMsg.id)) {
              final prevY = messagePositions[prevMsg.id]!;

              // If previous message is also at/past top (y <= 0), check its date
              if (prevY <= 0) {
                if (prevDate != null &&
                    prevDate.year == messageDate.year &&
                    prevDate.month == messageDate.month &&
                    prevDate.day == messageDate.day) {
                  // Previous message has same date and is also at/past top
                  isFirstOfDate = false;
                }
                break; // Stop at first visible message above
              }
            }
          }
        }

        // Only update if this is the first message of its date at the top
        if (isFirstOfDate) {
          topDate = messageDate;
        } else {
          // Keep current sticky date if we're still in the same date group
          topDate = stickyDateNotifier.value;
        }
      } catch (e) {
        // Message not found in list, use first message as fallback
        if (list.isNotEmpty) {
          topDate = list[0].sentAt;
        }
      }
    }

    if (topDate != null) {
      // Compare only the date part (year, month, day), not the time
      final currentStickyDate = stickyDateNotifier.value;
      final shouldUpdate =
          currentStickyDate == null ||
          topDate.year != currentStickyDate.year ||
          topDate.month != currentStickyDate.month ||
          topDate.day != currentStickyDate.day;

      if (shouldUpdate) {
        stickyDateNotifier.value = topDate;
        stickyDateString = dateSeparatorPattern != null
            ? dateSeparatorPattern!(topDate)
            : null;
      }
    }
  }

  dynamic createTemplateMap() {
    List<CometChatMessageTemplate> localTypes = CometChatUIKit.getDataSource()
        .getAllMessageTemplates();
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
    // Initialize flutter_chat_ui controller
    chatController = core.InMemoryChatController();

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
          messageListId,
          null,
          user,
          group,
          initialUnreadCount ?? 0,
        );
        isLoading = false;
        list.clear();
        return;
      }
    }
    if (messageId != null && messageId! > 0) {
      // Fetch conversation to get unread count before navigating to message
      _fetchConversationAndGotoMessage(messageId!);
      return;
    }

    // Register conversation summary listener before any early returns
    ever(generateConversationSummary, (bool isTrue) {
      if (isTrue) {
        getConversationsSummary(user, group);
      }
    });

    // If startFromUnreadMessages is true, use fetchMessagesWithUnreadCount
    if (startFromUnreadMessages) {
      fetchMessagesWithUnreadCount();
      return;
    }

    super.onInit();
  }

  ValueNotifier<DateTime?> stickyDateNotifier = ValueNotifier<DateTime?>(null);

  final Map<int, GlobalKey> indexToMessageKey = {};

  final Map<int, GlobalKey> messageKeys = {};

  /// Get or create a GlobalKey for a message using its ID
  /// This ensures each message has a unique, stable key
  GlobalKey getOrCreateKey(int index, int messageId) {
    // Only create keys for messages with valid IDs (not pending messages with id=0)
    if (messageId <= 0) {
      // For pending messages, create a temporary key that won't be reused
      return GlobalKey();
    }

    final existingKey = messageKeys[messageId];
    if (existingKey != null) {
      indexToMessageKey[index] = existingKey;
      return existingKey;
    }

    final newKey = GlobalKey();
    messageKeys[messageId] = newKey;
    indexToMessageKey[index] = newKey;
    return newKey;
  }

  /// Clean up keys for messages that no longer exist in the list
  void _cleanupStaleKeys() {
    // Get all valid message IDs from current list (excluding pending messages with id=0)
    final validIds = list
        .where((msg) => msg.id > 0)
        .map((msg) => msg.id)
        .toSet();

    // Check for duplicates in the list and remove them
    final seenIds = <int>{};
    final duplicateIds = <int>[];
    for (final msg in list) {
      if (msg.id > 0) {
        if (seenIds.contains(msg.id)) {
          duplicateIds.add(msg.id);
        } else {
          seenIds.add(msg.id);
        }
      }
    }

    if (duplicateIds.isNotEmpty) {
      // Remove duplicates - keep the first occurrence
      for (final duplicateId in duplicateIds) {
        bool foundFirst = false;
        list.removeWhere((msg) {
          if (msg.id == duplicateId) {
            if (!foundFirst) {
              foundFirst = true;
              return false; // Keep the first occurrence
            }
            return true; // Remove subsequent occurrences
          }
          return false;
        });
      }
    }

    // Remove keys that are no longer in the list
    messageKeys.removeWhere((id, value) => !validIds.contains(id));
    indexToMessageKey.removeWhere(
      (index, key) => !messageKeys.containsValue(key),
    );
  }

  /// Trims the message list to stay within [maxMessagesInMemory] limit.
  /// When fetching older messages (scrolling up), removes newer messages from the top.
  /// When fetching newer messages (scrolling down), removes older messages from the bottom.
  ///
  /// Returns true if trimming was performed, false otherwise.
  /// When trimming happens, shows shimmer and scrolls to the last visible message.
  ///
  /// [trimFromTop] - if true, removes newer messages (when scrolling up to fetch older)
  ///                 if false, removes older messages (when scrolling down to fetch newer)
  Future<bool> _trimMessageWindow({required bool trimFromTop}) async {
    // Check if we need to trim (approaching the limit)
    if (list.length < maxMessagesInMemory - 50) {
      return false;
    }

    // Show shimmer before trimming
    isTrimmingWindow = true;
    update();

    // Get the last visible message before trimming (the one we'll scroll to after trim)
    BaseMessage? anchorMessage;
    if (trimFromTop) {
      // When trimming from top (scrolling up), anchor to the oldest message currently visible
      // which will be near the end of the list after trim
      if (list.length > windowBuffer) {
        anchorMessage =
            list[windowBuffer]; // First message that will remain after trim
      }
    } else {
      // When trimming from bottom (scrolling down), anchor to the newest message
      if (list.isNotEmpty) {
        anchorMessage = list[0];
      }
    }

    List<BaseMessage> removedMessages = [];

    if (trimFromTop) {
      // Remove newer messages from the beginning of the list (index 0)
      // list structure: [newest...oldest], so index 0 = newest
      removedMessages = list.sublist(0, windowBuffer);
      list.removeRange(0, windowBuffer);
      hasMoreNext = true; // Allow fetching newer messages again
    } else {
      // Remove older messages from the end of the list
      // list structure: [newest...oldest], so end = oldest
      final startIndex = list.length - windowBuffer;
      if (startIndex > 0) {
        removedMessages = list.sublist(startIndex);
        list.removeRange(startIndex, list.length);
        hasMoreItems = true; // Allow fetching older messages again
      }
    }

    // Clean up keys for removed messages
    for (final msg in removedMessages) {
      if (msg.id > 0) {
        messageKeys.remove(msg.id);
      }
    }
    indexToMessageKey.clear(); // Will be rebuilt on next render

    // Sync the trimmed list to chatController
    await syncMessagesToChatController();
    update();

    // Scroll to the anchor message after a short delay to let UI rebuild
    if (anchorMessage != null) {
      await Future.delayed(const Duration(milliseconds: 100));
      await _scrollToMessage(anchorMessage.id);
    }

    return true;
  }

  /// Scrolls to a specific message by ID
  Future<void> _scrollToMessage(int messageId) async {
    final messageIndex = list.indexWhere((msg) => msg.id == messageId);
    if (messageIndex == -1) {
      isTrimmingWindow = false;
      update();
      return;
    }

    // Get the GlobalKey for this message
    final key = messageKeys[messageId];
    if (key?.currentContext != null) {
      try {
        await Scrollable.ensureVisible(
          key!.currentContext!,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
        );
      } catch (e) {
        // Error scrolling to message
      }
    }

    // Hide shimmer after scroll completes
    await Future.delayed(const Duration(milliseconds: 100));
    isTrimmingWindow = false;
    update();
  }

  String? stickyDateString;

  @override
  void onClose() {
    // Mark disposed BEFORE tearing anything down, so any in-flight async
    // callback (e.g. a fetchPrevious that completes after the screen is popped)
    // bails out instead of touching the disposed chatController.
    _isDisposed = true;
    _retryTimer?.cancel();
    _syncDebounceTimer?.cancel(); // Cancel any pending sync
    chatController.dispose();
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

  /// Sync CometChat messages to flutter_chat_ui chatController
  /// Uses updateMessage for existing messages to trigger ChatOperationType.update
  /// which causes ChatMessageInternal to rebuild without GlobalKey conflicts
  Future<void> syncMessagesToChatController() async {
    // Guard: the screen may have been popped while a fetch was in flight.
    if (_isDisposed) return;
    final reversedList = list.reversed.toList();
    var newFlutterMessages = MessageAdapter.toFlutterChatMessages(reversedList);

    // Remove duplicates from flutter_chat_ui messages
    final seenIds = <String>{};
    newFlutterMessages = newFlutterMessages.where((msg) {
      if (seenIds.contains(msg.id)) {
        return false;
      }
      seenIds.add(msg.id);
      return true;
    }).toList();

    // Get current messages in chatController
    final currentMessages = chatController.messages;
    final currentMessageIds = currentMessages.map((m) => m.id).toSet();
    final newMessageIds = newFlutterMessages.map((m) => m.id).toSet();

    final messagesToUpdate = <core.Message>[];
    final messagesToInsert = <core.Message>[];
    final messagesToRemove = <core.Message>[];

    // Check for updates and inserts
    for (final newMsg in newFlutterMessages) {
      if (currentMessageIds.contains(newMsg.id)) {
        // Message exists, check if it needs update by comparing metadata
        final currentMsg = currentMessages.firstWhere((m) => m.id == newMsg.id);
        final currentUpdatedAt = currentMsg.metadata?['updatedAt'];
        final newUpdatedAt = newMsg.metadata?['updatedAt'];
        final currentDeletedAt = currentMsg.metadata?['deletedAt'];
        final newDeletedAt = newMsg.metadata?['deletedAt'];
        final currentReactionsHash = currentMsg.metadata?['reactionsHash'];
        final newReactionsHash = newMsg.metadata?['reactionsHash'];
        final currentBaseMessageId = currentMsg.metadata?['baseMessageId'];
        final newBaseMessageId = newMsg.metadata?['baseMessageId'];
        final currentHasError = currentMsg.metadata?['hasError'];
        final newHasError = newMsg.metadata?['hasError'];

        // Update if updatedAt, deletedAt, reactionsHash, baseMessageId, or hasError changed
        // baseMessageId changes when message goes from pending (id=0) to sent (real id)
        // deletedAt changes when a message is deleted
        // hasError changes when a send error occurs (e.g. file size or MIME type error)
        if (currentUpdatedAt != newUpdatedAt ||
            currentDeletedAt != newDeletedAt ||
            currentReactionsHash != newReactionsHash ||
            currentBaseMessageId != newBaseMessageId ||
            currentHasError != newHasError) {
          debugPrint(
            '🔄 [SYNC] Message needs update - id: ${newMsg.id}, deletedAt: $currentDeletedAt -> $newDeletedAt',
          );
          messagesToUpdate.add(newMsg);
        }
      } else {
        messagesToInsert.add(newMsg);
      }
    }

    // Check for removals
    for (final currentMsg in currentMessages) {
      if (!newMessageIds.contains(currentMsg.id)) {
        messagesToRemove.add(currentMsg);
      }
    }

    // Determine if we need structural changes (inserts/removals) or just updates
    final hasStructuralChanges =
        messagesToInsert.isNotEmpty || messagesToRemove.isNotEmpty;

    if (hasStructuralChanges) {
      // For structural changes, use setMessages for a clean atomic sync
      // This avoids race conditions from mixing individual operations with setMessages
      await chatController.setMessages(newFlutterMessages);
    } else {
      // For updates only, apply them individually to trigger ChatOperationType.update
      // This allows ChatMessageInternal to rebuild without full list replacement
      for (final newMsg in messagesToUpdate) {
        final oldMsg = currentMessages.firstWhere((m) => m.id == newMsg.id);
        await chatController.updateMessage(oldMsg, newMsg);
      }
    }

    update();
  }

  /// Override addElement to auto-sync with chatController
  /// Returns true if the message was actually added (new message), false if skipped (duplicate) or updated
  @override
  bool addElement(BaseMessage element, {int index = 0}) {
    _cleanupStaleKeys();

    // Fast duplicate check using tracking sets for rapid event handling
    // Only skip if the message has a valid ID (sent messages) - inProgress messages need to be added
    if (element.id > 0) {
      if (_recentlyAddedMessageIds.contains(element.id)) {
        // Check if it actually exists in the list before skipping
        // This handles edge cases where tracking set has stale data
        final existsInList = list.any((msg) => msg.id == element.id);
        if (existsInList) {
          return false; // Duplicate - not added
        }
        // Not in list, remove from tracking set and continue
        _recentlyAddedMessageIds.remove(element.id);
      }
    }

    // For inProgress messages (id <= 0), check by muid
    // But don't skip - just check if we need to update instead of insert
    if (element.id <= 0 && element.muid.isNotEmpty) {
      if (_recentlyAddedMessageMuids.contains(element.muid)) {
        // Check if it actually exists in the list
        final existsInList = list.any((msg) => msg.muid == element.muid);
        if (existsInList) {
          return false; // Duplicate - not added
        }
        // Not in list, remove from tracking set and continue
        _recentlyAddedMessageMuids.remove(element.muid);
      }
    }

    // Check if message already exists by id or muid
    final matchingIndex = list.indexWhere((msg) {
      if (element.id > 0 && msg.id == element.id) {
        return true;
      }
      if (element.muid.isNotEmpty &&
          msg.muid.isNotEmpty &&
          msg.muid == element.muid) {
        return true;
      }
      return false;
    });

    if (matchingIndex != -1) {
      // Message already exists, update it instead
      final oldMessage = list[matchingIndex];

      // If the message ID changed (pending -> sent), clean up old key
      if (oldMessage.id != element.id && oldMessage.id > 0) {
        messageKeys.remove(oldMessage.id);
        indexToMessageKey.removeWhere(
          (idx, key) => key == messageKeys[oldMessage.id],
        );
      }

      // Preserve reactions from old message if new message has no reactions
      if (element.reactions.isEmpty && oldMessage.reactions.isNotEmpty) {
        element.reactions.addAll(oldMessage.reactions);
      } else if (element.reactions.isNotEmpty &&
          oldMessage.reactions.isNotEmpty) {
        // Merge reactions - preserve local reactedByMe state
        for (final oldReaction in oldMessage.reactions) {
          final newReactionIdx = element.reactions.indexWhere(
            (r) => r.reaction == oldReaction.reaction,
          );
          if (newReactionIdx == -1 && oldReaction.reactedByMe == true) {
            element.reactions.add(oldReaction);
          }
        }
      }

      list[matchingIndex] = element;

      // Update tracking sets
      if (element.id > 0) {
        _recentlyAddedMessageIds.add(element.id);
      }
      if (element.muid.isNotEmpty) {
        _recentlyAddedMessageMuids.add(element.muid);
      }

      _cleanupStaleKeys();
      _scheduleSyncToChatController();
      update();
      return false; // Updated existing message - not a new addition
    }

    // Message doesn't exist in list - add it

    // Track the IDs to prevent duplicate events from rapid callbacks
    if (element.id > 0) {
      _recentlyAddedMessageIds.add(element.id);
      // Clean up old IDs to prevent memory leak (keep last 200)
      if (_recentlyAddedMessageIds.length > 200) {
        final oldestIds = _recentlyAddedMessageIds.take(100).toList();
        for (final id in oldestIds) {
          _recentlyAddedMessageIds.remove(id);
        }
      }
    }

    if (element.muid.isNotEmpty) {
      _recentlyAddedMessageMuids.add(element.muid);
      // Clean up old MUIDs to prevent memory leak (keep last 200)
      if (_recentlyAddedMessageMuids.length > 200) {
        final oldestMuids = _recentlyAddedMessageMuids.take(100).toList();
        for (final muid in oldestMuids) {
          _recentlyAddedMessageMuids.remove(muid);
        }
      }
    }

    list.insert(index, element);

    // Trim older messages if list exceeds memory limit
    // This prevents memory accumulation when sending many messages
    _trimIfNeeded();

    _cleanupStaleKeys();
    _scheduleSyncToChatController();
    update();
    return true; // New message added successfully
  }

  /// Trims older messages from the list if it exceeds the memory limit.
  /// Called after adding new messages to prevent unbounded memory growth.
  void _trimIfNeeded() {
    if (list.length <= maxMessagesInMemory) {
      return;
    }

    // Remove older messages from the end of the list
    // list structure: [newest...oldest], so end = oldest
    final messagesToRemove = list.length - maxMessagesInMemory + windowBuffer;
    if (messagesToRemove > 0 && messagesToRemove < list.length) {
      final startIndex = list.length - messagesToRemove;
      final removedMessages = list.sublist(startIndex);
      list.removeRange(startIndex, list.length);

      // Clean up keys for removed messages
      for (final msg in removedMessages) {
        if (msg.id > 0) {
          messageKeys.remove(msg.id);
          _recentlyAddedMessageIds.remove(msg.id);
        }
        if (msg.muid.isNotEmpty) {
          _recentlyAddedMessageMuids.remove(msg.muid);
        }
      }
      indexToMessageKey.clear();

      // Allow fetching older messages again since we trimmed them
      hasMoreItems = true;
    }
  }

  /// Override updateElement to auto-sync with chatController
  @override
  updateElement(BaseMessage element, {int? index}) {
    super.updateElement(element, index: index);
    _cleanupStaleKeys();
    _scheduleSyncToChatController();
  }

  /// Override removeElement to auto-sync with chatController
  @override
  removeElement(BaseMessage element) {
    // Clean up tracking sets for the removed message
    if (element.id > 0) {
      _recentlyAddedMessageIds.remove(element.id);
      messageKeys.remove(element.id);
    }
    if (element.muid.isNotEmpty) {
      _recentlyAddedMessageMuids.remove(element.muid);
    }

    // Remove from the chatController directly to avoid full sync
    // This prevents scroll position issues from setMessages diff
    // Try both muid and id.toString() since the flutter message ID could be either
    final muidId = element.muid.isNotEmpty ? element.muid : null;
    final numericId = element.id.toString();

    int chatControllerIndex = -1;

    // First try muid
    if (muidId != null) {
      chatControllerIndex = chatController.messages.indexWhere(
        (m) => m.id == muidId,
      );
    }

    // If not found by muid, try numeric id
    if (chatControllerIndex == -1) {
      chatControllerIndex = chatController.messages.indexWhere(
        (m) => m.id == numericId,
      );
    }

    if (chatControllerIndex != -1) {
      chatController.removeMessage(
        chatController.messages[chatControllerIndex],
      );
    } else {
      // Message not found - trigger a full sync to ensure consistency
      _scheduleSyncToChatController();
    }

    super.removeElement(element);
    _cleanupStaleKeys();
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
  List<BaseMessage> tempList = [];

  @override
  loadMoreElements({
    bool Function(BaseMessage element)? isIncluded,
    bool fetchPrevious = true,
    BuildContext? context,
  }) async {
    if (isUserAgentic() && threadMessageParentId == 0) {
      return;
    }

    if (isFetching) {
      return;
    }

    isFetching = true;
    isLoading = true;

    BaseMessage? lastMessage;
    getLoggedInUser();
    await getUnreadCount();

    conversation ??= (await CometChat.getConversation(
      conversationWithId,
      conversationType,
      onSuccess: (_) {},
      onError: (_) {},
    ));
    conversationId ??= conversation?.conversationId;

    // Store lastReadMessageId and unreadCount from conversation for indicator
    // We need unreadCount to find the indicator position, even if startFromUnreadMessages is false
    // Skip this for thread views - thread views should not show the main conversation's unread count
    if (conversation != null && lastReadMessageId == null && !isThread) {
      lastReadMessageId = conversation!.lastReadMessageId;
      unreadCount = conversation!.unreadMessageCount ?? 0;

      // If the last message is a thread reply and we're in main message list (not thread view),
      // we need to check if there are any non-thread unread messages
      // This will be done after messages are loaded in the anchor finding logic
    }

    if (fetchPrevious) {
      try {
        // Check if we need to trim before fetching more messages
        // This happens when approaching the memory limit
        final didTrim = await _trimMessageWindow(trimFromTop: true);
        if (didTrim) {}

        await request.fetchPrevious(
          onSuccess: (List<BaseMessage> fetchedList) {
            isFetching = false;
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
                  element =
                      InteractiveMessageUtils.getSpecificMessageFromInteractiveMessage(
                        element,
                      );
                }

                // Restore saved reactions if any
                _restoreSavedReactions(element);

                // Use addElement to handle duplicates and preserve reactions
                addElement(element, index: list.length);

                if (lastParticipantMessage == null) {
                  if (element.sender?.uid != loggedInUser?.uid) {
                    lastParticipantMessage = element;
                    // Only mark as read if there are no unread messages to show indicator for
                    // If unreadCount > 0, we want to show the indicator first
                    if (unreadCount == 0) {
                      markAsRead(element);
                    }
                  }
                }
              }
              if (inInitialized == false && list.isNotEmpty) {
                lastMessage = list[0];
              }
              onLoad?.call(list);

              // Sync to chatController
              syncMessagesToChatController();

              // Set unread message anchor if there are unread messages (unreadCount > 0)
              // This must happen BEFORE marking as read so the indicator is preserved
              // Skip anchor recalculation if user manually marked as unread in this session
              // The anchor was already set correctly by markMessageAsUnread
              if (unreadCount > 0 && !markedAsUnreadInSession) {
                // First try to find using lastReadMessageId
                if (unreadMessageAnchor == null &&
                    lastReadMessageId != null &&
                    lastReadMessageId! > 0) {
                  unreadMessageAnchor = _findFirstUnreadAfterLastRead();
                  unreadMessageAnchorId = unreadMessageAnchor?.id;
                }
                // If still not found, try getFirstUnreadMessage
                if (unreadMessageAnchor == null) {
                  unreadMessageAnchor = getFirstUnreadMessage();
                  unreadMessageAnchorId = unreadMessageAnchor?.id;
                }

                // If no anchor found (all unread messages are thread replies), clear unreadCount
                // Thread replies shouldn't trigger unread indicator in main message list
                if (unreadMessageAnchor == null) {
                  unreadCount = 0;
                  markConversationAsRead();
                }
              }

              // When startFromUnreadMessages is false, mark conversation as read (default behavior)
              // This clears the badge but keeps the indicator (set above)
              // Only do this on first load (inInitialized == false) and if there are messages
              if (!startFromUnreadMessages &&
                  !inInitialized &&
                  list.isNotEmpty) {
                // Clear badge immediately
                unreadCount = 0;
                markConversationAsRead();
              } else if (startFromUnreadMessages &&
                  unreadMessageAnchor != null) {
                // When startFromUnreadMessages is true, check if indicator is visible
                Future.delayed(const Duration(milliseconds: 100), () {
                  _checkUnreadIndicatorVisibility();
                });
              }
            }
            update();
          },
          onError: (CometChatException e) {
            isFetching = false;
            isLoading = false;
            onError?.call(e);
            error = e;
            hasError = true;
            update();
          },
        );
      } catch (e, s) {
        error = CometChatException("ERR", s.toString(), "Error");
        isFetching = false;
        hasError = true;
        isLoading = false;
        hasMoreItems = false;
        update();
      }
    } else {
      // Fetch newer messages
      try {
        // Check if we need to trim before fetching more messages
        final didTrim = await _trimMessageWindow(trimFromTop: false);
        if (didTrim) {}

        // Show overlay if user has jumped to a quoted message and is now scrolling down
        // Only show if not already showing to prevent multiple overlays
        if (hasJumpedToQuotedMessage && !isFetchingNextForQuotedMessage) {
          isFetchingNextForQuotedMessage = true;
          // Don't reset hasJumpedToQuotedMessage here - keep it for subsequent fetches
          update();
        }

        if (list.isEmpty) {
          isFetching = false;
          isLoading = false;
          update();
          return;
        }

        // After goto message, use the highest (most recent) message ID
        // Otherwise use the first message (oldest in the current view)
        BaseMessage fetchNextLastMessage;
        if (hasJumpedToQuotedMessage) {
          // Find the message with the highest ID
          fetchNextLastMessage = list.reduce((a, b) => a.id > b.id ? a : b);
        } else {
          fetchNextLastMessage = list[0];
        }

        if (fetchNextLastMessage.id <= 0) {
          isFetching = false;
          isLoading = false;
          update();
          return;
        }

        MessagesRequest messageRequest =
            ((messagesBuilderProtocol.requestBuilder
                  ..messageId = fetchNextLastMessage.id))
                .build();

        final completer = Completer<void>();

        messageRequest.fetchNext(
          onSuccess: (fetchedList) async {
            if (fetchedList.isEmpty) {
              isFetching = false;
              isLoading = false;
              hasMoreNext = false;

              // No more messages - reset both flags
              if (isFetchingNextForQuotedMessage) {
                isFetchingNextForQuotedMessage = false;
                hasJumpedToQuotedMessage =
                    false; // Reset since we've reached the end
              }

              onEmpty?.call();
              update();
            } else {
              isLoading = false;
              // Get the limit from the request builder (default is 30 if not set)
              final limit = messagesBuilderProtocol.requestBuilder.limit ?? 30;
              // If fetched count is less than limit, no more newer messages exist
              hasMoreNext = fetchedList.length >= limit;

              // Clear tempList and add new messages
              tempList.clear();

              // Process fetched messages
              for (var element in fetchedList) {
                if (element is InteractiveMessage) {
                  element =
                      InteractiveMessageUtils.getSpecificMessageFromInteractiveMessage(
                        element,
                      );
                }

                tempList.add(element);

                if (lastParticipantMessage == null) {
                  if (element.sender?.uid != loggedInUser?.uid) {
                    lastParticipantMessage = element;
                    // Only mark as read if there are no unread messages to show indicator for
                    if (unreadCount == 0) {
                      markAsRead(element);
                    }
                  }
                }
              }

              // Insert new messages at the beginning of the list (only if not already present)
              final existingIds = list.map((m) => m.id).toSet();
              final newMessages = tempList
                  .where((m) => !existingIds.contains(m.id))
                  .toList();

              // Restore saved reactions for new messages
              for (final msg in newMessages) {
                _restoreSavedReactions(msg);
              }

              if (newMessages.isNotEmpty) {
                // Sort new messages by ID in descending order (highest ID first)
                // Internal list structure: [newest...oldest] so newest goes at index 0
                newMessages.sort((a, b) => b.id.compareTo(a.id));

                list.insertAll(0, newMessages);

                // ChatAnimatedList expects [oldest...newest] order (opposite of internal list)
                // So we reverse before inserting at the end of chatController.messages
                // Filter out any messages that already exist in chatController to prevent duplicates
                final chatControllerIds = chatController.messages
                    .map((m) => m.id)
                    .toSet();
                final flutterMessages = MessageAdapter.toFlutterChatMessages(
                  newMessages.reversed.toList(),
                ).where((m) => !chatControllerIds.contains(m.id)).toList();

                if (flutterMessages.isNotEmpty) {
                  await chatController.insertAllMessages(
                    flutterMessages,
                    index: chatController.messages.length,
                    animated: false,
                  );
                }
              }

              tempList.clear();
              onLoad?.call(list);
              isFetching = false;

              // Force update sticky date after new messages are rendered
              Future.delayed(const Duration(milliseconds: 100), () {
                if (messageListScrollController.hasClients) {
                  _updateStickyDate();
                }
              });

              // Dismiss overlay after 1 second if it was shown
              if (isFetchingNextForQuotedMessage) {
                Future.delayed(const Duration(milliseconds: 1000), () {
                  isFetchingNextForQuotedMessage = false;
                  update();
                });
              }
            }
            completer.complete();
          },
          onError: (CometChatException excep) async {
            isFetching = false;

            // Dismiss overlay immediately on error
            if (isFetchingNextForQuotedMessage) {
              isFetchingNextForQuotedMessage = false;
            }

            onError?.call(excep);
            error = excep;
            hasError = true;
            isLoading = false;
            completer.complete();
            update();
          },
        );

        await completer.future;
      } catch (e, s) {
        isFetching = false;
        error = CometChatException("ERR", s.toString(), "Error");
        hasError = true;
        isLoading = false;
        hasMoreNext = false;
        update();
      }
    }

    /// 🔹 Initialize after first fetch
    if (!inInitialized) {
      inInitialized = true;

      CometChatUIEvents.ccActiveChatChanged(
        messageListId,
        lastMessage,
        user,
        group,
        initialUnreadCount ?? 0,
      );

      if (list.isEmpty &&
          enableConversationStarters == true &&
          messageListId["parentMessageId"] == null) {
        getConversationStarter(user, group);
      }

      if (initialUnreadCount != null &&
          initialUnreadCount! > 30 &&
          enableConversationSummary == true &&
          messageListId["parentMessageId"] == null) {
        getConversationsSummary(user, group);
      }
    }
  }

  dynamic getLoggedInUser() async {
    loggedInUser ??= await CometChat.getLoggedInUser();
  }

  int? highlightedMessageId;
  BaseMessage? highlightedMessage;

  Future<void> gotoMessageId(int targetMessageId) async {
    try {
      // Reset scroll tracking from previous goToMessage
      _hasCompletedGoToMessage = false;
      _goToMessageTargetId = null;

      // Start the jumping process - show shimmer
      isJumpingToMessage = true;
      update();

      messagesBuilderProtocol.requestBuilder.messageId = targetMessageId;

      request = ((messagesBuilderProtocol.requestBuilder).build());

      await request.fetchPrevious(
        onSuccess: (List<BaseMessage> fetchedList) async {
          if (fetchedList.isEmpty) {
            hasMoreItems = false;
          } else {
            hasMoreItems = true;
          }
          await CometChatHelper.getMessageDetails(
            targetMessageId,
            onSuccess: (message) async {
              if (message == null) return _showError();
              await fetchNextMessagesForGotoMessages(fetchedList, message);
            },
            onError: (_) => _showError(),
          );
        },
        onError: (CometChatException e) {
          // Stop jumping process on error
          isJumpingToMessage = false;
          onError?.call(e);
          error = e;
          isLoading = false;
          hasError = true;
          update();
        },
      );
    } catch (e) {
      _showError();
    }
  }

  void _showError() {
    // Stop jumping process on error
    isJumpingToMessage = false;
    isLoading = false;
    hasError = true;
    update();
    if (kDebugMode) print("❌ gotoMessageId");
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
    // Skip if this message was already added via ccMessageSent (by checking our tracking Sets)
    // This handles stickers and other custom messages sent via sendCustomMessage
    // But allows polls (sent via callExtension) to be added since they don't go through ccMessageSent
    if (customMessage.id > 0 &&
        _recentlyAddedMessageIds.contains(customMessage.id)) {
      return;
    }
    if (customMessage.muid.isNotEmpty &&
        _recentlyAddedMessageMuids.contains(customMessage.muid)) {
      return;
    }

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
    CustomInteractiveMessage customInteractiveMessage,
  ) {
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
    cc.Action action,
    User addedby,
    User userAdded,
    Group addedTo,
  ) {
    if (_messageCategoryTypeCheck(action)) {
      if (group?.guid == addedTo.guid) {
        _onMessageReceived(action);
      }
    }
  }

  @override
  void onGroupMemberJoined(
    cc.Action action,
    User joinedUser,
    Group joinedGroup,
  ) {
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
    cc.Action action,
    User kickedUser,
    User kickedBy,
    Group kickedFrom,
  ) {
    if (_messageCategoryTypeCheck(action)) {
      if (group?.guid == kickedFrom.guid) {
        _onMessageReceived(action, markRead: false, playSound: false);
      }
    }
  }

  @override
  void onGroupMemberBanned(
    cc.Action action,
    User bannedUser,
    User bannedBy,
    Group bannedFrom,
  ) {
    if (_messageCategoryTypeCheck(action)) {
      if (group?.guid == bannedFrom.guid) {
        _onMessageReceived(action, markRead: false, playSound: false);
      }
    }
  }

  @override
  void ccGroupMemberBanned(
    cc.Action message,
    User bannedUser,
    User bannedBy,
    Group bannedFrom,
  ) {
    if (_messageCategoryTypeCheck(message)) {
      if (group?.guid == bannedFrom.guid) {
        _onMessageFromLoggedInUser(message);
      }
    }
  }

  @override
  void ccGroupMemberKicked(
    cc.Action message,
    User kickedUser,
    User kickedBy,
    Group kickedFrom,
  ) {
    if (_messageCategoryTypeCheck(message)) {
      if (group?.guid == kickedFrom.guid) {
        _onMessageFromLoggedInUser(message);
      }
    }
  }

  @override
  void ccGroupMemberAdded(
    List<cc.Action> messages,
    List<User> usersAdded,
    Group groupAddedIn,
    User addedBy,
  ) {
    if (group?.guid == groupAddedIn.guid) {
      for (var message in messages) {
        if (_messageCategoryTypeCheck(message)) {
          _onMessageFromLoggedInUser(message);
        }
      }
    }
  }

  @override
  void ccGroupMemberUnbanned(
    cc.Action message,
    User unbannedUser,
    User unbannedBy,
    Group unbannedFrom,
  ) {
    if (_messageCategoryTypeCheck(message)) {
      if (group?.guid == unbannedFrom.guid) {
        _onMessageFromLoggedInUser(message);
      }
    }
  }

  @override
  void onGroupMemberUnbanned(
    cc.Action action,
    User unbannedUser,
    User unbannedBy,
    Group unbannedFrom,
  ) {
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
    Group group,
  ) {
    if (_messageCategoryTypeCheck(action)) {
      if (group.guid == this.group?.guid) {
        if (loggedInUser?.uid == updatedUser.uid) {
          //TODO: use scopeChangedTo instead of scopeChangedFrom when the bug in SDK is fixed
          this.group?.scope = scopeChangedFrom;
          debugPrint(
            'scope of ${updatedUser.name} changed to $scopeChangedFrom from $scopeChangedTo',
          );
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

  // Schedule a sync to chatController (debounced to batch rapid updates)
  void _scheduleSyncToChatController() {
    _syncDebounceTimer?.cancel();
    _syncDebounceTimer = Timer(const Duration(milliseconds: 100), () {
      syncMessagesToChatController();
    });
  }

  @override
  updateMessageWithMuid(BaseMessage message) async {
    int matchingIndex = list.indexWhere(
      (element) => element.muid == message.muid,
    );
    if (matchingIndex == -1) {
      return;
    }

    BaseMessage existingMessage = list[matchingIndex];

    // Track the new message ID to prevent duplicates from onCustomMessageReceived
    if (message.id > 0) {
      _recentlyAddedMessageIds.add(message.id);
    }

    // If the message ID changed (pending -> sent), clean up old key
    if (existingMessage.id != message.id && existingMessage.id > 0) {
      messageKeys.remove(existingMessage.id);
      indexToMessageKey.removeWhere(
        (idx, key) => key == messageKeys[existingMessage.id],
      );
    }

    if (existingMessage is TextMessage || existingMessage is MediaMessage) {
      bool isDisapproved = moderationUtil.isMessageDisapprovedFromModeration(
        existingMessage,
      );
      if (!isDisapproved) {
        list[matchingIndex] = message;
        _cleanupStaleKeys();

        // Handle the update in chatController
        final oldFlutterMessage = MessageAdapter.toFlutterChatMessage(
          existingMessage,
        );
        final newFlutterMessage = MessageAdapter.toFlutterChatMessage(message);

        final chatControllerIndex = chatController.messages.indexWhere(
          (m) => m.id == oldFlutterMessage.id,
        );
        if (chatControllerIndex != -1) {
          // Use updateMessage to trigger UI refresh
          await chatController.updateMessage(
            chatController.messages[chatControllerIndex],
            newFlutterMessage,
          );
        }

        update();
        syncMessagesToChatController();
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
      // Handle CustomMessage and other types
      list[matchingIndex] = message;
      _cleanupStaleKeys();
      _scheduleSyncToChatController();
      update();
      syncMessagesToChatController();
    }
  }

  @override
  deleteMessage(BaseMessage message) async {
    await CometChat.deleteMessage(
      message.id,
      onSuccess: (updatedMessage) {
        updatedMessage.deletedAt ??= DateTime.now();
        message.deletedAt = DateTime.now();
        message.deletedBy = loggedInUser?.uid;
        CometChatMessageEvents.ccMessageDeleted(
          updatedMessage,
          EventStatus.success,
        );
      },
      onError: (_) {},
    );
  }

  @override
  updateMessageThreadCount(int parentMessageId) {
    int matchingIndex = list.indexWhere((item) => item.id == parentMessageId);
    if (matchingIndex != -1) {
      list[matchingIndex].replyCount++;
      update();
    }
  }

  /// Marks a message as unread using the SDK
  Future<void> markMessageAsUnread(BaseMessage message) async {
    await CometChat.markMessageAsUnread(
      message,
      onSuccess: (Conversation updatedConversation) {
        CometChatUIKitHelper.onConversationUpdate(updatedConversation);

        unreadMessageAnchor = message;
        unreadMessageAnchorId = message.id;

        if (updatedConversation.lastReadMessageId != null &&
            updatedConversation.lastReadMessageId! > 0) {
          lastReadMessageId = updatedConversation.lastReadMessageId;
        }

        unreadCount = updatedConversation.unreadMessageCount ?? 0;
        markedAsUnreadInSession = true;
        update();
      },
      onError: (CometChatException e) {
        debugPrint('[markMessageAsUnread] ERROR: ${e.message}');
      },
    );
  }

  /// Marks the entire conversation as read
  Future<void> markConversationAsRead() async {
    final uid = user?.uid ?? group?.guid;
    if (uid == null) return;

    final completer = Completer<void>();

    await CometChat.markConversationAsRead(
      uid,
      conversationType,
      onSuccess: (String success) {
        if (list.isNotEmpty) {
          CometChatUIKitHelper.onMessageRead(list.first);
        }
        unreadCount = 0;
        // Keep unreadMessageAnchor and unreadMessageAnchorId so the indicator stays visible
        // Only clear the badge (unreadCount), not the indicator
        markedAsUnreadInSession = false;
        update();
        completer.complete();
      },
      onError: (CometChatException e) {
        debugPrint('Error marking conversation as read: ${e.message}');
        completer.complete(); // Complete even on error to not block
      },
    );

    return completer.future;
  }

  /// Gets the first unread message from the list
  /// Uses lastReadMessageId to determine which messages are actually unread
  /// The first unread message is the oldest among the unread messages
  /// Returns null if all unread messages are thread replies (shouldn't show indicator in main list)
  BaseMessage? getFirstUnreadMessage() {
    if (list.isEmpty || unreadCount <= 0) {
      return null;
    }

    final loggedInUid = loggedInUser?.uid;
    if (loggedInUid == null) {
      return null;
    }

    // A message is unread if:
    // 1. It's not from the logged-in user
    // 2. It's not deleted
    // 3. It's not a thread reply (parentMessageId == 0)
    // 4. Its ID > lastReadMessageId (if lastReadMessageId is available)

    // List is ordered newest first (index 0 = newest)
    // We need to find the OLDEST unread message (highest index that meets criteria)
    BaseMessage? firstUnreadMessage;

    for (int i = list.length - 1; i >= 0; i--) {
      final message = list[i];

      // Skip messages from logged-in user
      if (message.sender?.uid == loggedInUid) continue;

      // Skip deleted messages
      if (message.deletedAt != null) continue;

      // Skip thread replies - they shouldn't trigger unread indicator in main list
      if (message.parentMessageId != 0) continue;

      // If we have lastReadMessageId, only count messages with ID > lastReadMessageId as unread
      if (lastReadMessageId != null && lastReadMessageId! > 0) {
        if (message.id <= lastReadMessageId!) {
          // This message and all older ones are already read
          break;
        }
      }

      // This is an unread non-thread message
      firstUnreadMessage = message;
      break; // Found the oldest unread message
    }

    if (firstUnreadMessage != null) {
      return firstUnreadMessage;
    }

    // If no non-thread unread messages found, return null (no indicator should be shown)
    return null;
  }

  /// Finds the first unread message after lastReadMessageId
  /// Skips deleted messages - indicator should appear BELOW deleted messages
  /// Skips thread replies, action messages, and messages from logged-in user
  BaseMessage? _findFirstUnreadAfterLastRead() {
    if (list.isEmpty || lastReadMessageId == null || lastReadMessageId! <= 0) {
      return null;
    }

    final loggedInUid = loggedInUser?.uid;
    if (loggedInUid == null) {
      return null;
    }

    // List is ordered newest first (index 0 = newest)
    // Find the message with smallest ID > lastReadMessageId that is:
    // - NOT deleted (skip deleted, show indicator below them)
    // - NOT from logged-in user
    // - NOT a thread reply
    // - NOT an action message (system messages)

    BaseMessage? firstUnreadMessage;
    int? smallestValidId;

    for (int i = 0; i < list.length; i++) {
      final message = list[i];

      // Skip messages at or before lastReadMessageId
      if (message.id <= lastReadMessageId!) continue;

      // Skip deleted messages - indicator should appear BELOW deleted messages
      if (message.deletedAt != null) {
        continue;
      }

      // Skip thread replies
      if (message.parentMessageId != 0) continue;

      // Skip messages from logged-in user
      if (message.sender?.uid == loggedInUid) continue;

      // Skip ACTION messages (system messages like "user joined", "user left", etc.)
      if (message.category == MessageCategoryConstants.action) {
        continue;
      }

      // This message is a candidate - check if it has the smallest ID
      if (smallestValidId == null || message.id < smallestValidId) {
        smallestValidId = message.id;
        firstUnreadMessage = message;
      }
    }

    if (firstUnreadMessage != null) {
      return firstUnreadMessage;
    }

    return null;
  }

  /// Fetches messages with unread count consideration
  /// When startFromUnreadMessages is true, this method fetches the conversation
  /// to get lastReadMessageId and navigates to the first unread message
  Future<void> fetchMessagesWithUnreadCount() async {
    // Skip unread count handling for thread views
    if (isThread) {
      loadMoreElements();
      return;
    }

    final uid = user?.uid ?? group?.guid;
    if (uid == null) return;

    isLoading = true;
    update();

    await CometChat.getConversation(
      uid,
      conversationType,
      onSuccess: (Conversation fetchedConversation) async {
        conversation = fetchedConversation;
        lastReadMessageId = fetchedConversation.lastReadMessageId;
        unreadCount = fetchedConversation.unreadMessageCount ?? 0;

        if (startFromUnreadMessages &&
            lastReadMessageId != null &&
            lastReadMessageId! > 0 &&
            unreadCount > 0) {
          // Fetch the first unread message (message after lastReadMessageId)
          await _fetchFirstUnreadAndGoto();
        } else {
          // Normal fetch - latest messages
          loadMoreElements();
        }
      },
      onError: (CometChatException e) {
        debugPrint('Error fetching conversation: ${e.message}');
        loadMoreElements();
      },
    );
  }

  /// Fetches conversation to get unread count, then navigates to the specified message
  /// Used when opening chat from conversation search
  Future<void> _fetchConversationAndGotoMessage(int targetMessageId) async {
    // Skip unread count handling for thread views
    if (isThread) {
      gotoMessageId(targetMessageId);
      return;
    }

    final uid = user?.uid ?? group?.guid;
    if (uid == null) {
      gotoMessageId(targetMessageId);
      return;
    }

    isLoading = true;
    update();

    await CometChat.getConversation(
      uid,
      conversationType,
      onSuccess: (Conversation fetchedConversation) async {
        conversation = fetchedConversation;
        lastReadMessageId = fetchedConversation.lastReadMessageId;
        unreadCount = fetchedConversation.unreadMessageCount ?? 0;

        // Navigate to the target message
        gotoMessageId(targetMessageId);
      },
      onError: (CometChatException e) {
        // Still navigate to message even if conversation fetch fails
        gotoMessageId(targetMessageId);
      },
    );
  }

  /// Fetches the first unread message and navigates to it using gotoMessageId
  Future<void> _fetchFirstUnreadAndGoto() async {
    if (lastReadMessageId == null) {
      loadMoreElements();
      return;
    }

    // Build a request to fetch messages after lastReadMessageId
    // Cap the limit at 30 (SDK max limit) - we only need to find the first unread message
    final fetchLimit = unreadCount > 0
        ? (unreadCount > 30 ? 30 : unreadCount)
        : 30;

    MessagesRequest messageRequest =
        (MessagesRequestBuilder()
              ..uid = user?.uid
              ..guid = group?.guid
              ..messageId = lastReadMessageId
              ..limit = fetchLimit)
            .build();

    await messageRequest.fetchNext(
      onSuccess: (List<BaseMessage> fetchedList) async {
        if (fetchedList.isEmpty) {
          // No messages after lastReadMessageId, load from latest
          loadMoreElements();
          return;
        }

        // Find the first unread message that is:
        // 1. NOT from logged-in user
        // 2. NOT deleted (skip deleted messages)
        // 3. NOT a thread reply
        //
        // This ensures if the first message after lastReadMessageId is deleted,
        // we skip it and show indicator at the next non-deleted message (below the deleted one)

        BaseMessage? firstUnreadMessage;

        for (int i = 0; i < fetchedList.length; i++) {
          final message = fetchedList[i];

          // Skip messages from logged-in user
          if (message.sender?.uid == loggedInUser?.uid) {
            continue;
          }

          // Skip deleted messages - indicator should appear BELOW deleted messages
          if (message.deletedAt != null) {
            continue;
          }

          // Skip thread replies
          if (message.parentMessageId != 0) {
            continue;
          }

          // Skip ACTION messages (system messages like "user joined", "user left", etc.)
          if (message.category == MessageCategoryConstants.action) {
            continue;
          }

          // Found the first valid unread message
          firstUnreadMessage = message;
          break;
        }

        if (firstUnreadMessage == null) {
          loadMoreElements();
          return;
        }

        unreadMessageAnchorId = firstUnreadMessage.id;
        unreadMessageAnchor = firstUnreadMessage;

        unreadCount = 0;
        await markConversationAsRead();
        highlightScroll = false;
        gotoMessageId(firstUnreadMessage.id);
      },
      onError: (CometChatException e) {
        loadMoreElements();
      },
    );
  }

  void _playSound() {
    if (!disableSoundForMessages) {
      CometChatUIKit.soundManager.play(
        sound: Sound.incomingMessage,
        customSound: customIncomingMessageSound,
        packageName:
            customIncomingMessageSound == null ||
                customIncomingMessageSound == ""
            ? UIConstants.packageName
            : customIncomingMessageSoundPackage,
      );
    }
  }

  dynamic markAsRead(BaseMessage message) {
    if (message.sender?.uid != loggedInUser?.uid && message.readAt == null) {
      CometChat.markAsRead(
        message,
        onSuccess: (String res) {
          CometChatMessageEvents.ccMessageRead(message);
        },
        onError: (e) {},
      );
    }
  }

  void _onMessageReceived(
    BaseMessage message, {
    bool playSound = true,
    bool markRead = true,
  }) {
    // Check for duplicate message event early - SDK fires multiple events for same message
    if (message.id > 0 && _recentlyAddedMessageIds.contains(message.id)) {
      return;
    }

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
      // Track message ID to prevent duplicates
      if (message.id > 0) {
        _recentlyAddedMessageIds.add(message.id);
      }

      // If hasMoreNext is true and user is NOT at the bottom of the list,
      // we're not at the latest messages yet - don't add the message to avoid wrong ordering
      // Only increment the badge count
      // But if user is at the bottom (offset <= 100), add the message regardless of hasMoreNext
      final isAtBottom =
          !messageListScrollController.hasClients ||
          messageListScrollController.offset <= 100;
      if (hasMoreNext && !isAtBottom) {
        if (playSound) {
          _playSound();
        }
        // Increment unread count for badge
        if (markedAsUnreadInSession) {
          unreadCount++;
        } else {
          newUnreadMessageCount++;
        }
        update();
        return;
      }

      // addElement returns true only if message was actually added (not a duplicate)
      final wasAdded = addElement(message);

      if (playSound) {
        _playSound();
      }

      // Only increment unread count if message was actually added (not a duplicate)
      // This fixes the issue where duplicate SDK events caused incorrect unread counts
      if (!wasAdded) {
        return;
      }

      // Don't auto-mark as read if user manually marked messages as unread in this session
      // This fixes ENG-28434: unread count resets to 1 instead of incrementing
      if (markedAsUnreadInSession) {
        unreadCount++; // Increment unreadCount so badge shows correct total
        update();
      } else if (scrollToBottomOnNewMessage) {
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
      // Check for duplicate thread message - SDK fires multiple events
      if (message.id > 0 && _recentlyAddedMessageIds.contains(message.id)) {
        return;
      }

      // Track thread message ID to prevent duplicates
      if (message.id > 0) {
        _recentlyAddedMessageIds.add(message.id);
      }

      //incrementing reply count
      if (playSound) {
        _playSound();
      }
      int matchingIndex = list.indexWhere(
        (element) => (element.id == message.parentMessageId),
      );
      if (matchingIndex != -1) {
        list[matchingIndex].replyCount++;
      }

      // Also increment unread count for thread messages when markedAsUnreadInSession
      if (markedAsUnreadInSession) {
        unreadCount++;
      }

      update();
    }
  }

  void _onMessageFromLoggedInUser(
    BaseMessage message, {
    bool playSound = true,
    bool markRead = true,
  }) {
    if ((message.conversationId == conversationId ||
            _checkIfSameConversationForSenderMessage(message)) &&
        message.parentMessageId == threadMessageParentId) {
      addElement(message);
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

      int matchingIndex = list.indexWhere(
        (element) => (element.id == message.parentMessageId),
      );
      if (matchingIndex != -1) {
        list[matchingIndex].replyCount++;
      }
      update();
    }
  }

  //-----message option methods-----

  void _messageEdit(
    BaseMessage message,
    CometChatMessageListControllerProtocol state,
  ) {
    if (message.deletedAt == null) {
      CometChatMessageEvents.ccMessageEdited(
        message,
        MessageEditStatus.inProgress,
      );
    }
  }

  dynamic clearOverlayView(BaseMessage message) {
    CometChatMessageEvents.ccReplyToMessage(message, MessageStatus.error);
  }

  void _delete(
    BaseMessage message,
    CometChatMessageListControllerProtocol state,
  ) {
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
        // Dismiss the dialog on the navigator it was shown on. showDialog defaults to
        // the root navigator, so a plain Navigator.pop(context) would pop the nearest
        // navigator instead - which pops the chat screen (not the dialog) when the
        // screen is hosted inside a nested Navigator.
        Navigator.of(context, rootNavigator: true).pop();
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
            message,
            EventStatus.inProgress,
          );
          // Dismiss the confirm dialog on the root navigator (where showDialog placed
          // it), not the nearest one - otherwise a nested Navigator setup pops the
          // chat screen instead of the dialog.
          Navigator.of(context, rootNavigator: true).pop();
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

  void _markAsUnread(
    BaseMessage message,
    CometChatMessageListControllerProtocol state,
  ) {
    markMessageAsUnread(message);
  }

  Future<void> _shareMessage(
    BaseMessage message,
    CometChatMessageListControllerProtocol state,
  ) async {
    //share
    if (message is TextMessage) {
      String text = message.text;
      //if message has mentions we need to send the text with mentions and not the original text
      if (message.mentionedUsers.isNotEmpty) {
        text = CometChatMentionsFormatter.getTextWithMentions(
          message.text,
          message.mentionedUsers,
        );
      }
      await UIConstants.channel.invokeMethod("shareMessage", {
        'message': text,
        "type": "text",
      });
    } else if (message is MediaMessage) {
      await UIConstants.channel.invokeMethod("shareMessage", {
        "message": message.attachment?.fileName, // For ios
        'mediaName': message.attachment?.fileName,
        "type": "media",
        "subtype": message.type.toString(),
        "fileUrl": message.attachment?.fileUrl,
        "mimeType": message.attachment?.fileMimeType,
      });
    }
  }

  void _copyMessage(
    BaseMessage message,
    CometChatMessageListControllerProtocol state,
  ) {
    if (message is TextMessage) {
      String text = message.text;
      if (message.mentionedUsers.isNotEmpty) {
        text = CometChatMentionsFormatter.getTextWithMentions(
          message.text,
          message.mentionedUsers,
        );
      }
      Clipboard.setData(ClipboardData(text: text));
    } else if (message is AIAssistantMessage) {
      String text = message.text ?? "";
      Clipboard.setData(ClipboardData(text: text));
    }
  }

  void _reportMessage(
    BaseMessage message,
    CometChatMessageListControllerProtocol state,
  ) {
    showConfirmationDialog(context, message);
  }

  Future<bool?> showConfirmationDialog(
    BuildContext context,
    BaseMessage message,
  ) {
    final listStyle = CometChatThemeHelper.getTheme<CometChatMessageListStyle>(
      context: context,
      defaultTheme: CometChatMessageListStyle.of,
    ).merge(messageListStyle);

    final flagMessageStyle =
        CometChatThemeHelper.getTheme<CometchatFlagMessageStyle>(
          context: context,
          defaultTheme: CometchatFlagMessageStyle.of,
        ).merge(listStyle.flagMessageStyle);

    return showDialog<bool>(
      context: context,
      builder: (context) {
        return CometChatFlagMessage(
          message: message,
          style: flagMessageStyle,
          flagReasonLocalizer: flagReasonLocalizer,
          hideFlagRemarkField: hideFlagRemarkField,
        );
      },
    );
  }

  void _messageInformation(
    BaseMessage message,
    CometChatMessageListControllerProtocol state,
  ) {
    final listStyle = CometChatThemeHelper.getTheme<CometChatMessageListStyle>(
      context: context,
      defaultTheme: CometChatMessageListStyle.of,
    ).merge(messageListStyle);

    final messageInfoStyle =
        CometChatThemeHelper.getTheme<CometChatMessageInformationStyle>(
          context: context,
          defaultTheme: CometChatMessageInformationStyle.of,
        ).merge(listStyle.messageInformationStyle);
    showMessageInformation(
      context: context,
      message: message,
      template: templateMap["${message.category}_${message.type}"],
      messageInformationStyle: messageInfoStyle,
    );
  }

  Future<void> _sendMessagePrivately(
    BaseMessage message,
    CometChatMessageListControllerProtocol state,
  ) async {
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

  dynamic replyToMessage(
    BaseMessage message,
    CometChatMessageListControllerProtocol state,
  ) async {
    if (message.deletedAt == null) {
      CometChatMessageEvents.ccReplyToMessage(
        message,
        MessageStatus.inProgress,
      );
    }
  }

  dynamic createMessage(
    BaseMessage copyFromMessage,
    User? user,
    Group? group,
  ) async {
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
      await CometChatUIKit.sendTextMessage(
        message,
        onSuccess: (BaseMessage returnedMessage) {},
        onError: (CometChatException excep) {},
      );
    } else if (copyFromMessage is MediaMessage) {
      if (copyFromMessage.attachment == null) return;

      String fileUrl = copyFromMessage.attachment!.fileUrl;
      String fileName = copyFromMessage.attachment!.fileName;
      String fileExtension = copyFromMessage.attachment!.fileExtension;
      String fileMimeType = copyFromMessage.attachment!.fileMimeType;

      Attachment attachment = Attachment(
        fileUrl,
        fileName,
        fileExtension,
        fileMimeType,
        null,
      );

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
        attachment: attachment,
      );

      await CometChatUIKit.sendMediaMessage(
        message,
        onSuccess: (BaseMessage returnedMessage) {},
        onError: (CometChatException excep) {},
      );
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

      await CometChatUIKit.sendCustomMessage(
        message,
        onSuccess: (BaseMessage returnedMessage) {},
        onError: (CometChatException excep) {},
      );
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
      case MessageOptionConstants.replyMessage:
        {
          return replyToMessage;
        }
      case MessageOptionConstants.reportMessage:
        {
          return _reportMessage;
        }
      case MessageOptionConstants.markAsUnread:
        {
          return _markAsUnread;
        }

      default:
        {
          return null;
        }
    }
  }

  @override
  void ccGroupMemberScopeChanged(
    cc.Action message,
    User updatedUser,
    String scopeChangedTo,
    String scopeChangedFrom,
    Group group,
  ) {
    if (group.guid == this.group?.guid) {
      if (loggedInUser?.uid == updatedUser.uid) {
        this.group?.scope = scopeChangedTo;
      }
      debugPrint(
        'scope of ${updatedUser.name} changed to $scopeChangedTo from $scopeChangedFrom',
      );
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
    BaseMessage messageObject,
    ChatAlignment alignment,
  ) {
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
      showTime = messageObject.deletedAt != null ? true : false;
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
        defaultHeader = headerView!(
          context,
          user: user,
          group: group,
          parentMessageId: threadMessageParentId,
        );
      }

      if (footerView != null) {
        defaultFooter = footerView!(
          context,
          user: user,
          group: group,
          parentMessageId: threadMessageParentId,
        );
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
  void showPanel(
    Map<String, dynamic>? id,
    CustomUIPosition uiPosition,
    WidgetBuilder child,
  ) {
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
      debugPrint(
        " $threadMessageParentId ${user?.uid} ${group?.guid} ${call.receiverUid} ",
      );
    }

    // Check for thread - calls should not appear in threads
    if (threadMessageParentId != 0) {
      return false;
    }

    // Check for 1:1 user calls
    if (user != null) {
      return call.sender?.uid == user?.uid || call.receiverUid == user?.uid;
    }

    // Check for group calls
    if (group != null) {
      return call.receiverUid == group?.guid;
    }

    return false;
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
      CometChatStreamCallBackEvents.ccStreamCompleted(true);
      _queueManager.onConnected();
      _handleInterruptedRuns();
    }

    if (!isUserAgentic()) {
      if (hasError) {
        resetMessageList();
      } else if (!isLoading && !isScrolled) {
        _updateUserAndGroup();
        _fetchNewMessages();
      }
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
  void onConnectionError(CometChatException error) {
    if (isUserAgentic()) {
      CometChatStreamCallBackEvents.ccStreamInterrupted(true);
      _queueManager.onConnectionError(error, context);
    }
  }

  void _handleInterruptedRuns() {
    list.whereType<StreamMessage>().toList().forEach(
      (msg) => removeElement(msg),
    );
  }

  final registeredElements = ValueNotifier<Set<Element>?>(null);

  Future<void> jumpToMessageId(int messageId) async {
    if (kDebugMode) {
      print("🔍 jumpToMessageId called with messageId: $messageId");
    }

    // Find the message in the list
    final messageIndex = list.indexWhere((msg) => msg.id == messageId);

    if (messageIndex == -1) {
      if (kDebugMode) print("❌ Message with id $messageId not found in list");
      // Stop jumping process if message not found
      isJumpingToMessage = false;
      update();
      return;
    }

    if (kDebugMode) {
      print(
        "✅ Message found at index $messageIndex in list of ${list.length} messages",
      );
    }

    // Get the actual message to construct the correct flutter_chat_ui ID
    final message = list[messageIndex];
    final flutterChatMessage = MessageAdapter.toFlutterChatMessage(message);
    final flutterChatMessageId = flutterChatMessage.id;

    if (kDebugMode) {
      print(
        "🔍 Looking for flutter_chat_ui message with ID: $flutterChatMessageId",
      );
    }

    try {
      await chatController.scrollToMessage(
        flutterChatMessageId,
        duration: const Duration(milliseconds: 0),
        curve: Curves.fastLinearToSlowEaseIn,
      );
      if (kDebugMode) print("✅ scrollToMessage completed");

      // Add a small delay to ensure scroll animation completes
      await Future.delayed(const Duration(milliseconds: 100));

      // Enable scroll direction logging after goToMessage
      _hasCompletedGoToMessage = true;
      _goToMessageTargetId = messageId;
      _previousScrollOffset = messageListScrollController.offset;
      if (kDebugMode) {
        print(
          '📜 [GoToMessage] Scroll tracking enabled for message ID: $messageId | Initial offset: ${_previousScrollOffset.toStringAsFixed(2)}',
        );
      }

      // Start cooldown period to prevent immediate pagination
      isInGoToMessageCooldown = true;
      if (kDebugMode) {
        print('📜 [GoToMessage] Cooldown started - pagination blocked');
      }

      // Stop jumping process after successful scroll
      isJumpingToMessage = false;
      update();

      // Clear cooldown after 500ms to allow normal pagination
      Future.delayed(const Duration(milliseconds: 500), () {
        isInGoToMessageCooldown = false;
        if (kDebugMode) {
          print('📜 [GoToMessage] Cooldown ended - pagination allowed');
        }
      });
    } catch (e) {
      if (kDebugMode) print("❌ Error scrolling to message: $e");
      // Stop jumping process on error
      isJumpingToMessage = false;
      isInGoToMessageCooldown = false;
      update();
    }
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
    List<String> types =
        messagesBuilderProtocol.requestBuilder.types ??
        CometChatUIKit.getDataSource().getAllMessageTypes();
    bool hideReplies =
        messagesBuilderProtocol.requestBuilder.hideReplies ?? true;
    int parentMessageId =
        messagesBuilderProtocol.requestBuilder.parentMessageId ?? 0;

    /// used to fetch the old messages from the server starting from the last message in the list that have been edited or deleted
    types.add(MessageTypeConstants.message);

    while (hasMoreItems) {
      ///The following message request fetches the new messages received after the last message sent or received recorded in the list.
      MessagesRequest messageRequest =
          (MessagesRequestBuilder()
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
                  message =
                      InteractiveMessageUtils.getSpecificMessageFromInteractiveMessage(
                        message,
                      );
                }
                if (message.parentMessageId != 0) {
                  updateMessageThreadCount(message.parentMessageId);
                } else if (message is cc.Action) {
                  if (message.type == MessageTypeConstants.message &&
                      (message.action == ActionMessageTypeConstants.edited ||
                          message.action ==
                              ActionMessageTypeConstants.deleted) &&
                      message.actionOn is BaseMessage) {
                    BaseMessage actionOn = message.actionOn as BaseMessage;
                    int matchingIndex = list.indexWhere(
                      (element) => (element.id == actionOn.id),
                    );
                    if (matchingIndex != -1) {
                      list[matchingIndex] = actionOn;
                      update();
                    }
                  } else if (message.sender?.uid != null &&
                      loggedInUser?.uid != null &&
                      message.sender?.uid == loggedInUser?.uid) {
                    updateMessageWithMuid(message);
                  } else {
                    final wasAdded = addElement(message);
                    if (wasAdded) {
                      newUnreadMessageCount++;
                    }
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
                  final wasAdded = addElement(message);
                  if (wasAdded) {
                    newUnreadMessageCount++;
                  }
                  update();
                }
              }
              messageId = fetchedList.last.id;
              return;
            } else {
              hasMoreItems = false;
              update();
            }
          },
          onError: (CometChatException e) {
            hasMoreItems = false;
          },
        );
      } catch (e, _) {
        hasMoreItems = false;
      }
    }
  }

  Future<void> fetchNextMessagesForGotoMessages(
    List<BaseMessage> previousMessages,
    BaseMessage targetedMessage,
  ) async {
    fetchNextCall(previousMessages, targetedMessage);
  }

  dynamic fetchNextCall(
    List<BaseMessage> previousMessages,
    BaseMessage targetedMessage,
  ) async {
    int messageId = targetedMessage.id;

    // Mark that user has jumped to a quoted message (don't show overlay yet)
    hasJumpedToQuotedMessage = true;

    MessagesRequest messageRequest =
        ((messagesBuilderProtocol.requestBuilder..messageId = messageId))
            .build();

    final completer = Completer<void>();

    await messageRequest.fetchNext(
      onSuccess: (List<BaseMessage> fetchedList) async {
        isLoading = false;

        // Get the limit from the request builder (default is 30 if not set)
        final limit = messagesBuilderProtocol.requestBuilder.limit ?? 30;

        if (fetchedList.isEmpty) {
          hasMoreNext = false;
        } else {
          // If fetched count equals or exceeds limit, more newer messages may exist
          hasMoreNext = fetchedList.length >= limit;
        }

        // Add previous messages, but skip if it's the targeted message (to avoid duplicates)
        for (var element in previousMessages.reversed) {
          if (element is InteractiveMessage) {
            element =
                InteractiveMessageUtils.getSpecificMessageFromInteractiveMessage(
                  element,
                );
          }

          // Skip if this is the targeted message - it will be added separately
          if (element.id == targetedMessage.id) {
            continue;
          }

          // Restore saved reactions for this message if any
          _restoreSavedReactions(element);

          // Use addElement to prevent duplicates
          addElement(element, index: list.length);

          if (lastParticipantMessage == null) {
            if (element.sender?.uid != loggedInUser?.uid) {
              lastParticipantMessage = element;
              // Only mark as read if there are no unread messages to show indicator for
              if (unreadCount == 0) {
                markAsRead(element);
              }
            }
          }
        }

        // Restore saved reactions for the targeted message
        _restoreSavedReactions(targetedMessage);

        addElement(targetedMessage);

        // Only highlight if highlightScroll is true
        if (highlightScroll) {
          highlightedMessage = targetedMessage;
          highlightedMessageId = targetedMessage.id;
        }

        for (var element in fetchedList) {
          if (element is InteractiveMessage) {
            element =
                InteractiveMessageUtils.getSpecificMessageFromInteractiveMessage(
                  element,
                );
          }
          // Skip if this is the targeted message (already added)
          if (element.id == targetedMessage.id) {
            continue;
          }
          // Restore saved reactions for this message
          _restoreSavedReactions(element);
          addElement(element);
        }

        // DON'T clear the reactions cache - it should persist across jumps
        // The cache is only cleared when the controller is disposed or when
        // reactions are explicitly removed from a message

        // Ensure sync completes and UI is built before scrolling
        await syncMessagesToChatController();
        update();

        // Wait for multiple frames to ensure the list is fully built
        await Future.delayed(const Duration(milliseconds: 300));

        SchedulerBinding.instance.addPostFrameCallback((_) async {
          await jumpToMessageId(targetedMessage.id);
          // Don't check indicator visibility here - it will be checked after determining
          // if target is above or below the indicator
        });

        // Only clear highlight after delay if highlighting was enabled
        if (highlightScroll) {
          Future.delayed(const Duration(seconds: 5), () {
            highlightedMessage = null;
            highlightedMessageId = null;
            update();
          });
        }

        // Reset highlightScroll to default for next navigation
        highlightScroll = true;

        // Set unread message anchor ONLY if there are unread messages (unreadCount > 0)
        // Don't show indicator if unreadCount is 0 (all messages are read)
        // Skip anchor recalculation if user manually marked as unread in this session
        if (unreadCount > 0 && !markedAsUnreadInSession) {
          // If we have a stored anchor ID (from _fetchFirstUnreadAndGoto), find it in the list
          // Skip if it's a thread reply (parentMessageId > 0)
          if (unreadMessageAnchorId != null && unreadMessageAnchor == null) {
            final foundMessage = list.firstWhereOrNull(
              (m) => m.id == unreadMessageAnchorId,
            );
            // Only set as anchor if it's not a thread reply
            if (foundMessage != null && foundMessage.parentMessageId == 0) {
              unreadMessageAnchor = foundMessage;
            } else if (foundMessage != null) {
              unreadMessageAnchorId =
                  null; // Clear the ID so we try other methods
            }
          }
          // If not found, try to find using lastReadMessageId
          // The first unread message is the first message after lastReadMessageId that's not from logged-in user
          if (unreadMessageAnchor == null &&
              lastReadMessageId != null &&
              lastReadMessageId! > 0) {
            unreadMessageAnchor = _findFirstUnreadAfterLastRead();
            unreadMessageAnchorId = unreadMessageAnchor?.id;
          }
          // If still not found, try to find using getFirstUnreadMessage (only if unreadCount > 0)
          if (unreadMessageAnchor == null) {
            unreadMessageAnchor = getFirstUnreadMessage();
            unreadMessageAnchorId = unreadMessageAnchor?.id;
          }

          // If no anchor found (all unread messages are thread replies), clear unreadCount
          // Thread replies shouldn't trigger unread indicator in main message list
          if (unreadMessageAnchor == null) {
            unreadCount = 0;
            markConversationAsRead();
          } else {
            // Check if target message is above or below the unread indicator
            // Target message ID > unread anchor ID means target is BELOW (newer) the indicator
            // Target message ID < unread anchor ID means target is ABOVE (older) the indicator
            isTargetAboveIndicator =
                targetedMessage.id < unreadMessageAnchor!.id;

            if (!isTargetAboveIndicator) {
              // Target is BELOW or AT the indicator (newer message)
              // Mark as read immediately, keep indicator visible
              unreadCount = 0;
              markConversationAsRead();
            }
            // Target is ABOVE the indicator (older message)
            // Keep the badge count - it will be cleared when indicator comes into viewport
          }
        }

        update();
        completer.complete();
      },
      onError: (CometChatException e) {
        // Stop jumping process on error
        isJumpingToMessage = false;
        _showError();
        completer.complete();
      },
    );

    return completer.future;
  }

  ///[_updateUserAndGroup] method updates the user and group details if the user or group is updated while the web socket connection is lost.
  Future<void> _updateUserAndGroup() async {
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

  void _updateMessageOnReaction(
    ReactionEvent reactionEvent,
    String reactionAction,
  ) {
    Reaction? messageReaction = reactionEvent.reaction;
    if (messageReaction != null) {
      int? messageId = messageReaction.messageId;
      if (messageId == null) {
        return;
      }

      BaseMessage? message = list.firstWhereOrNull(
        (element) => element.id == messageId,
      );
      if (message == null) {
        return;
      }

      CometChatHelper.updateMessageWithReactionInfo(
        message,
        messageReaction,
        reactionAction,
      ).then((reactedMessage) {
        if (reactedMessage == null) {
          return;
        }

        // CRITICAL: Save reactions to global cache whenever they change
        // This ensures reactions persist even if the list gets replaced by loadMoreElements
        _saveReactionsToCache(reactedMessage);

        updateElement(reactedMessage);
      });
    }
  }

  /// Save reactions for a message to the global cache
  /// This is called whenever reactions change to ensure they persist across list replacements
  void _saveReactionsToCache(BaseMessage message) {
    if (message.reactions.isNotEmpty) {
      _savedReactionsForJump[message.id] = List<ReactionCount>.from(
        message.reactions,
      );
    } else {
      // Remove from cache if no reactions
      _savedReactionsForJump.remove(message.id);
    }
  }

  dynamic handleReactionPress(
    BaseMessage message,
    String? reaction,
    List<ReactionCount> reactionList,
  ) {
    if (reaction == null || reaction.isEmpty) return;
    int reactionIndex = reactionList.indexWhere(
      (reactionCount) =>
          reactionCount.reaction == reaction &&
          reactionCount.reactedByMe == true,
    );

    if (reactionIndex != -1) {
      final updatedMessage = updateReactionsOnMessage(message, reaction, false);
      // Save to global cache immediately
      _saveReactionsToCache(updatedMessage);
      updateElement(updatedMessage);

      /// remove reaction
      CometChat.removeReaction(
        message.id,
        reaction,
        onError: (error) {
          // Only revert if it's NOT a "reaction not found" error
          // If reaction not found, it means it was already removed - no need to revert
          if (error.code != 'ERR_MESSAGE_REACTION_NOT_FOUND') {
            final revertedMessage = updateReactionsOnMessage(
              message,
              reaction,
              true,
            );
            _saveReactionsToCache(revertedMessage);
            updateElement(revertedMessage);
          }
        },
        onSuccess: (message) {},
      );
    } else {
      /// add reaction
      final updatedMessage = updateReactionsOnMessage(message, reaction, true);
      // Save to global cache immediately
      _saveReactionsToCache(updatedMessage);
      updateElement(updatedMessage);
      CometChat.addReaction(
        message.id,
        reaction,
        onError: (error) {
          // Only revert if it's NOT an "already added" error
          // If already added, it means the reaction is there - no need to revert
          if (error.code != 'ERR_MESSAGE_REACTION_ALREADY_ADDED') {
            final revertedMessage = updateReactionsOnMessage(
              message,
              reaction,
              false,
            );
            _saveReactionsToCache(revertedMessage);
            updateElement(revertedMessage);
          }
          // Reaction already exists on server - keep the UI showing the reaction
        },
        onSuccess: (message) {},
      );
    }
  }

  void addReactionIconTap(
    BaseMessage message,
    CometChatColorPalette colorPalette,
  ) async {
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
    BaseMessage message,
    String reaction,
    bool add,
  ) {
    ReactionCount reactionCount = ReactionCount(
      reaction: reaction,
      count: 1,
      reactedByMe: true,
    );
    int match = message.reactions.indexWhere(
      (element) => element.reaction == reaction,
    );
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
    List<String> types =
        messagesBuilderProtocol.requestBuilder.types ??
        CometChatUIKit.getDataSource().getAllMessageTypes();

    return categories.contains(message.category) &&
        types.contains(message.type);
  }

  void initializeTextFormatters() {
    List<CometChatTextFormatter> textFormatters = this.textFormatters ?? [];

    if (textFormatters.isEmpty) {
      textFormatters = CometChatUIKit.getDataSource()
          .getDefaultTextFormatters();
      int indexOfMentionsFormatter = textFormatters.indexWhere(
        (element) => element is CometChatMentionsFormatter,
      );
      if (indexOfMentionsFormatter != -1) {
        // Only replace if it's the exact base type, not a custom subclass
        if (textFormatters[indexOfMentionsFormatter].runtimeType ==
            CometChatMentionsFormatter) {
          textFormatters[indexOfMentionsFormatter] = CometChatMentionsFormatter(
            style: mentionsStyle,
            mentionAllLabel: mentionAllLabel,
            mentionAllLabelId: mentionAllLabelId,
          );
        }
      }
    } else if (textFormatters.indexWhere(
              (element) => element is CometChatMentionsFormatter,
            ) ==
            -1 &&
        disableMentions != true) {
      textFormatters.add(
        CometChatMentionsFormatter(
          style: mentionsStyle,
          mentionAllLabel: mentionAllLabel,
          mentionAllLabelId: mentionAllLabelId,
        ),
      );
    }

    if (disableMentions == true) {
      textFormatters.removeWhere(
        (element) => element is CometChatMentionsFormatter,
      );
    }

    // Ensure rich text formatter is included for rendering formatted messages
    int indexOfRichTextFormatter = textFormatters.indexWhere(
      (element) => element is CometChatRichTextFormatter,
    );
    if (indexOfRichTextFormatter == -1) {
      textFormatters.add(CometChatRichTextFormatter());
    }

    this.textFormatters = textFormatters;
  }

  dynamic checkAndShowReplies(User? user, Group? group) async {
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
      context: context,
      defaultTheme: CometChatMessageListStyle.of,
    ).merge(messageListStyle);

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

  void _checkForSmartReplies({TextMessage? textMessage}) {
    User? user;
    Group? group;
    if (textMessage != null) {
      if (textMessage.receiverType == ReceiverTypeConstants.user) {
        user = textMessage.sender as User;
      } else {
        group = textMessage.receiver as Group;
      }

      Debouncer debounce = Debouncer(
        milliseconds: smartRepliesDelayDuration ?? 10000,
      );

      debounce.run(() {
        if (smartRepliesKeywords != null && smartRepliesKeywords!.isNotEmpty) {
          for (String keyword in smartRepliesKeywords!) {
            if (textMessage.text.toLowerCase().contains(
              keyword.toLowerCase(),
            )) {
              checkAndShowReplies(user, group);
              break;
            }
          }
        } else {
          checkAndShowReplies(user, group);
        }
      });
    }
  }

  dynamic hideSummaryPanel(Map<String, dynamic>? id) {
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

  dynamic getConversationStarter(User? user, Group? group) async {
    final listStyle = CometChatThemeHelper.getTheme<CometChatMessageListStyle>(
      context: context,
      defaultTheme: CometChatMessageListStyle.of,
    ).merge(messageListStyle);
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

  dynamic getConversationsSummary(User? user, Group? group) async {
    final listStyle = CometChatThemeHelper.getTheme<CometChatMessageListStyle>(
      context: context,
      defaultTheme: CometChatMessageListStyle.of,
    ).merge(messageListStyle);
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

    footer = CometChatAIConversationSummaryView(
      group: group,
      user: user,
      aiConversationSummaryStyle: listStyle.aiConversationSummaryStyle,
      apiConfiguration: apiMap,
      onCloseIconTap: (id) {
        footer = null;
        update();
      },
    );
    update();
  }

  // ----------------- AI Assistant Event Listeners -----------------
  @override
  void onAIAssistantEventReceived(AIAssistantBaseEvent aiAssistantBaseEvent) {
    debugPrint(
      "Received AI Event: ${aiAssistantBaseEvent.type} for Run ID: ${aiAssistantBaseEvent.id}",
    );

    final runId = aiAssistantBaseEvent.id;

    if (runId == null) return;

    _queueManager.handleIncomingEvent(runId, aiAssistantBaseEvent);
    if (_queueManager.runExists(runId)) {
      _processNextEvent(runId, aiAssistantBaseEvent);
    }
  }

  // Process all events for a specific run
  Future<void> _processNextEvent(
    int runId,
    AIAssistantBaseEvent aiAssistantBaseEvent,
  ) async {
    if (runId == aiAssistantBaseEvent.id) {
      await Future.delayed(_queueManager.streamDelay);
      if (aiAssistantBaseEvent.type == AgenticKeys.runStarted) {
        _handleRunStarted(aiAssistantBaseEvent as AIAssistantRunStartedEvent);
      } else if (aiAssistantBaseEvent.type == AgenticKeys.textMessageStart ||
          aiAssistantBaseEvent.type == AgenticKeys.textMessageContent) {
        // Ensure thinking bubble exists when streaming text events arrive
        // (run_started may not always be received before these events)
        _createThinkingMessage(runId);
      } else if (aiAssistantBaseEvent.type == AgenticKeys.runFinished) {
        _handleRunFinished(aiAssistantBaseEvent as AIAssistantRunFinishedEvent);
      } else if (aiAssistantBaseEvent.type == AgenticKeys.toolCallEnd) {
        _handleToolCallEnd(aiAssistantBaseEvent as AIAssistantToolEndedEvent);
      }
    }
  }

  void _createThinkingMessage(int runId) {
    // Create a thinking bubble for new run
    // Use negative runId to avoid collision with the parent message that has the same ID
    final thinkingMessageId = -runId;
    final thinkingMessage = StreamMessage(
      id: thinkingMessageId,
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
    if (!_queueManager.checkMessageExists(thinkingMessageId)) {
      _queueManager.registerMessage(thinkingMessage);
      addElement(thinkingMessage);
    }
  }

  Future<void> _handleRunStarted(AIAssistantRunStartedEvent event) async {
    final runId = event.id;
    if (runId == null) return;
    _createThinkingMessage(runId);
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
      "AI Assistant Message Received: $threadMessageParentId && ${aiAssistantMessage.parentMessageId}",
    );

    if (threadMessageParentId != aiAssistantMessage.parentMessageId ||
        runId == null) {
      return;
    }

    _queueManager.aiAssistantMessages[runId] = aiAssistantMessage;
    _queueManager.checkAndTriggerQueueCompletion(runId);
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
      user?.metadata?[AIConstants.suggestedMessages] ?? [],
    );
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
    AIAssistantMessage aiAssistantMessage,
  ) {
    final runId = aiAssistantMessage.runId;
    for (int i = list.length - 1; i >= 0; i--) {
      if (list[i] is StreamMessage &&
          (list[i].id == runId || list[i].id == -(runId ?? 0))) {
        list.removeAt(i);
        addElement(aiAssistantMessage);
        break;
      }
    }
  }

  bool enableSwipe(BaseMessage messageObject) {
    if (messageObject.id <= 0) {
      return false;
    }
    final isModerated = ModerationCheckUtil.instance
        .isMessageDisapprovedFromModeration(messageObject);
    if (isModerated) {
      return false;
    }
    if (messageObject.deletedAt != null) {
      return false;
    }
    if (messageObject.category == MessageCategoryConstants.action ||
        messageObject.category == MessageCategoryConstants.call) {
      return false;
    }

    return true;
  }

  dynamic swipeGotoMessageId({
    BaseMessage? quotedMessage,
    BaseMessage? message,
  }) async {
    if (quotedMessage == null || (message?.deletedAt != null)) return;

    final idx = list.indexWhere((m) => m.id == quotedMessage.id);

    if (idx >= 0) {
      // Ensure messages are synced before jumping
      await syncMessagesToChatController();
      await jumpToMessageId(quotedMessage.id);
      highlightAnchorMessage(quotedMessage);
      return;
    } else {
      // Before clearing the list, save reactions from ALL messages in the current list
      // This preserves any local reaction changes that haven't synced to server yet
      // NOTE: We DON'T clear _savedReactionsForJump here because it's a global cache
      // that should persist across multiple jumps
      for (final msg in list) {
        if (msg.reactions.isNotEmpty) {
          // Only save if not already in cache (don't overwrite newer cached reactions)
          if (!_savedReactionsForJump.containsKey(msg.id)) {
            _savedReactionsForJump[msg.id] = List<ReactionCount>.from(
              msg.reactions,
            );
          }
        }
      }

      list.clear();
      // Start jumping process for goto message
      isJumpingToMessage = true;
      isLoading = true;
      update();

      gotoMessageId(quotedMessage.id);
    }
  }

  // Map to store saved reactions when jumping to a message
  // This is a STATIC GLOBAL cache that persists reactions across controller instances
  // Reactions are saved whenever they change (add/remove) and restored when messages are fetched
  // Made static so it survives controller recreation (e.g., when navigating from conversation search)
  static final Map<int, List<ReactionCount>> _savedReactionsForJump = {};

  /// Helper method to restore saved reactions for a message
  /// This merges cached reactions with any reactions from the server
  /// NOTE: We DON'T remove from cache after restoring - the cache persists
  void _restoreSavedReactions(BaseMessage message) {
    if (_savedReactionsForJump.containsKey(message.id)) {
      final savedReactions = _savedReactionsForJump[message.id]!;

      // IMPORTANT: Replace the message's reactions entirely with the cached version
      // The cached version is the source of truth for local changes
      message.reactions.clear();
      for (final savedReaction in savedReactions) {
        // Create a copy of the saved reaction to avoid reference issues
        final reactionCopy = ReactionCount(
          reaction: savedReaction.reaction,
          count: savedReaction.count,
          reactedByMe: savedReaction.reactedByMe,
        );
        message.reactions.add(reactionCopy);
      }

      // DON'T remove from cache - keep it for future fetches
      // The cache is updated when reactions change via _saveReactionsToCache
    }
  }

  dynamic highlightAnchorMessage(BaseMessage message) {
    highlightedMessage = message;
    highlightedMessageId = message.id;
    update();
    Future.delayed(const Duration(seconds: 5), () {
      highlightedMessage = null;
      highlightedMessageId = null;
      update();
    });
  }

  dynamic updateScrollToBottom() {
    isScrollMessageToBottom = true;
    update();
  }

  /// Scrolls to the bottom of the message list without resetting/reloading messages
  /// This is used when the user clicks the scroll to bottom button
  dynamic scrollToBottomOfList() {
    // Mark conversation as read when user explicitly taps scroll-to-bottom
    if (unreadMessageAnchor != null || unreadCount > 0) {
      markConversationAsRead();
    }

    // Reset scroll state
    isScrolled = false;
    newUnreadMessageCount = 0;

    // Scroll to bottom using the scroll controller
    if (messageListScrollController.hasClients) {
      messageListScrollController.animateTo(
        0, // In reversed list, 0 is the bottom
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );

      // Mark the latest message as read
      if (list.isNotEmpty) {
        markAsRead(list[0]);
      }
    }

    update();
  }

  dynamic resetMessageList({int retryCount = 0}) async {
    _retryTimer?.cancel();
    // First clear the chatController to prevent GlobalKey conflicts
    await chatController.setMessages([]);

    // reset values
    list.clear();

    // Clear tracking sets to allow messages to be re-added after reset
    _recentlyAddedMessageIds.clear();
    _recentlyAddedMessageMuids.clear();

    // Clear message keys to prevent stale key references
    messageKeys.clear();
    indexToMessageKey.clear();

    error = null;
    hasError = false;
    hasMoreItems = true;
    hasMoreNext = true;
    isFetching = false;
    isLoading = true;

    highlightedMessage = null;
    highlightedMessageId = null;
    newUnreadMessageCount = 0;
    lastParticipantMessage = null;
    isScrollMessageToBottom = false;
    isScrolled = false;
    hasJumpedToQuotedMessage = false;
    isFetchingNextForQuotedMessage = false;

    // Clear unread anchor and session flag
    unreadMessageAnchor = null;
    unreadMessageAnchorId = null;
    markedAsUnreadInSession = false;
    isTargetAboveIndicator = false;
    unreadCount = 0; // Clear unread count when user taps scroll-to-bottom

    request = (messagesBuilderProtocol.requestBuilder..messageId = 0).build();

    update();

    // Load messages after clearing, with retry for iOS where SDK reconnection may be delayed
    await loadMoreElements();
    if (hasError && retryCount < 3) {
      _retryTimer = Timer(const Duration(seconds: 2), () {
        if (hasError) {
          resetMessageList(retryCount: retryCount + 1);
        }
      });
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

  BubbleContentVerifier({
    this.showThumbnail = false,
    this.showName = false,
    this.showReadReceipt = true,
    this.showFooterView = true,
    this.alignment = BubbleAlignment.right,
    this.showTime = true,
  });
}
