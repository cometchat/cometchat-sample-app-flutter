import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cometchat_chat_uikit/src/message_list/messages_builder_protocol.dart';
import 'package:get/get.dart';
import '../../cometchat_chat_uikit.dart';
import '../../cometchat_chat_uikit.dart' as cc;

///[CometChatAIAssistantChatHistoryController] is the view model for [CometChatAIAssistantChatHistory]
///it contains all the business logic involved in changing the state of the UI of [CometChatAIAssistantChatHistory]
class CometChatAIAssistantChatHistoryController
    extends CometChatSearchListController<BaseMessage, int>
    with
        CometChatMessageEventListener,
        CometChatUIEventListener,
        ConnectionListener
    implements CometChatMessageListControllerProtocol {
  //--------------------Constructor-----------------------
  CometChatAIAssistantChatHistoryController({
    required this.messagesBuilderProtocol,
    this.user,
    this.group,
    super.onError,
    super.onEmpty,
    super.onLoad,
    this.dateSeparatorPattern,
    this.hideStickyDate = false,
    this.chatHistoryStyle,
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
    _uiMessageListener = "${dateStamp}UI_message_listener";
    _uiEventListener = "${dateStamp}UI_Event_listener";

    if (user != null) {
      conversationWithId = user!.uid;
      conversationType = ReceiverTypeConstants.user;
    } else {
      conversationWithId = group!.guid;
      conversationType = ReceiverTypeConstants.group;
    }

    tag = "tag$counter";
    counter++;

    messageListScrollController = ScrollController();
    messageListScrollController.addListener(_scrollControllerListener);

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
  }

  //-------------------------Variable Declaration-----------------------------
  late MessagesBuilderProtocol messagesBuilderProtocol;

  ///[user] user object  for user message list
  late final User? user;

  ///[group] group object  for group message list
  late final Group? group;

  ///[hideStickyDate] Hide the sticky date separator
  final bool? hideStickyDate;

  ///[dateSeparatorPattern] pattern for  date separator
  final String Function(DateTime dateTime)? dateSeparatorPattern;

  ///[chatHistoryStyle] is a [CometChatAIAssistantChatHistoryStyle] which is used to style the chat history
  final CometChatAIAssistantChatHistoryStyle? chatHistoryStyle;

  late String dateStamp;
  late String _messageListenerId;

  User? loggedInUser;
  String conversationWithId = "";
  String conversationType = "";
  String? conversationId;
  Conversation? conversation;
  int threadMessageParentId = 0;
  int newUnreadMessageCount = 0;
  static int counter = 0;
  late String tag;
  bool isThread = false;
  late String _uiMessageListener;
  late BuildContext context;

  late Map<String, dynamic> messageListId;

  bool inInitialized = false;

  late String _uiEventListener;

  bool isScrolled = false;

  int? initialUnreadCount;

  late ScrollController messageListScrollController;

  CometChatColorPalette? colorPalette;
  CometChatSpacing? spacing;
  CometChatTypography? typography;

  //-------------------------LifeCycle Methods-----------------------------
  @override
  void onInit() {
    CometChatMessageEvents.addMessagesListener(_uiMessageListener, this);
    CometChatUIEvents.addUiListener(_uiEventListener, this);
    CometChat.addConnectionListener(_messageListenerId, this);
    super.onInit();
  }

  @override
  void onClose() {
    CometChatMessageEvents.removeMessagesListener(_uiMessageListener);
    CometChatUIEvents.removeUiListener(_uiEventListener);
    CometChat.removeConnectionListener(_messageListenerId);
    super.onClose();
  }

  ValueNotifier<DateTime?> stickyDateNotifier = ValueNotifier<DateTime?>(null);

  final Map<int, GlobalKey> keys = {};
  final GlobalKey listViewKey = GlobalKey();

  String? stickyDateString;
  var isDeleteLoading = false.obs;

  void _scrollControllerListener() {
    double offset = messageListScrollController.offset;

    bool hasScrolled = offset > 100;

    if (hasScrolled != isScrolled) {
      isScrolled = hasScrolled;
      update();
    }

    if (hideStickyDate == true || list.isEmpty) return;

    final listBox =
        listViewKey.currentContext?.findRenderObject() as RenderBox?;
    if (listBox == null) return;
    final listTop = listBox.localToGlobal(Offset.zero).dy;

    DateTime? topDate;
    double minY = double.infinity;
    int topIndex = 0;
    keys.forEach((index, key) {
      if (list[index].deletedAt != null) return;
      final ctx = key.currentContext;
      if (ctx != null) {
        final box = ctx.findRenderObject() as RenderBox;
        final y = box.localToGlobal(Offset.zero).dy - listTop;

        // As soon as any part is visible at the top, this will trigger an update
        if (y >= 0 && y < minY) {
          minY = y;
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
    /// "Fetching again"

    isLoading = true;
    BaseMessage? lastMessage;
    getLoggedInUser();
    await getUnreadCount();
    conversation ??= (await CometChat.getConversation(
        conversationWithId, conversationType, onSuccess: (conversation) {
      if (conversation.lastMessage != null) {
        /// "Marking as read"
        if (kDebugMode) {
          debugPrint("Marking as read from here");
        }
      }
    }, onError: (_) {}));
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
    }
  }

  getLoggedInUser() async {
    loggedInUser ??= await CometChat.getLoggedInUser();
  }

  //------------------------UI Message Event Listeners------------------------------

  @override
  void onTextMessageReceived(TextMessage textMessage) async {
    if (_messageCategoryTypeCheck(textMessage)) {
      _onMessageReceived(textMessage);
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

  //------------------------UI Message Event Listeners------------------------------

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
    addElement(message);
  }

  @override
  updateMessageWithMuid(BaseMessage message) {
    int matchingIndex =
        list.indexWhere((element) => (element.muid == message.muid));
    if (matchingIndex != -1) {
      list[matchingIndex] = message;
      update();
    }
  }

  @override
  deleteMessage(BaseMessage message) async {
    showDeleteOptions(message);
  }

  @override
  updateMessageThreadCount(int parentMessageId) {
    int matchingIndex = list.indexWhere((item) => item.id == parentMessageId);
    if (matchingIndex != -1) {
      list[matchingIndex].replyCount++;
      update();
    }
  }

  _onMessageReceived(BaseMessage message) {
    if ((message.conversationId == conversationId ||
            _checkIfSameConversationForReceivedMessage(message) ||
            _checkIfSameConversationForSenderMessage(message)) &&
        message.parentMessageId == threadMessageParentId) {
      addElement(message);
    } else if (message.conversationId == conversationId ||
        _checkIfSameConversationForReceivedMessage(message)) {
      int matchingIndex =
          list.indexWhere((element) => (element.id == message.parentMessageId));
      if (matchingIndex != -1) {
        list[matchingIndex].replyCount++;
      }
      update();
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
//----------------- UI Call Listeners---------------

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
    return ScrollController();
  }

  @override
  Map<String, CometChatMessageTemplate> getTemplateMap() {
    return {};
  }

  @override
  User? getUser() {
    return user;
  }

  @override
  void onConnected() {
    getLoggedInUser();
    _updateUserAndGroup();
    _fetchNewMessages();
  }

  /// [_fetchNewMessages] method fetches the new messages from the server after a web socket connection is re-established.
  void _fetchNewMessages() async {
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
  void onMessageReactionAdded(ReactionEvent reactionEvent) {}

  @override
  void onMessageReactionRemoved(ReactionEvent reactionEvent) {}

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

  double getRandomSize(double min, double max) {
    return min + Random().nextDouble() * (max - min);
  }

  AlignmentGeometry getRandomAlignment() {
    return Random().nextBool() ? Alignment.centerLeft : Alignment.centerRight;
  }

  @override
  initializeHeaderAndFooterView() {
    throw UnimplementedError();
  }

  // Function to show pop-up menu on long press
  void showPopupMenu(
      BuildContext context,
      List<CometChatOption> options,
      GlobalKey widgetKey,
      BaseMessage message,
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

  showDeleteOptions(BaseMessage message) {
    if (context != null) {
      final colorPalette = CometChatThemeHelper.getColorPalette(context);
      final typography = CometChatThemeHelper.getTypography(context);
      final style = CometChatThemeHelper.getTheme<CometChatAIAssistantChatHistoryStyle>(
          context: context, defaultTheme: CometChatAIAssistantChatHistoryStyle.of)
          .merge(chatHistoryStyle);
      final confirmDialogStyle =
      CometChatThemeHelper.getTheme<CometChatConfirmDialogStyle>(
          context: context!,
          defaultTheme: CometChatConfirmDialogStyle.of)
          .merge(style.deleteChatHistoryDialogStyle);
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
          await CometChat.deleteMessage(
            message.id,
            onSuccess: (updatedMessage) {
              isDeleteLoading.value = false;
              updatedMessage.deletedAt ??= DateTime.now();
              message.deletedAt = DateTime.now();
              message.deletedBy = loggedInUser?.uid;
              CometChatMessageEvents.ccMessageDeleted(
                  updatedMessage, EventStatus.success);
            },
            onError: (onError) {
              isDeleteLoading.value = false;
              try {
                var snackBar = SnackBar(
                  backgroundColor: colorPalette.error,
                  content: Text(
                    cc.Translations.of(context!)
                        .somethingWentWrongError,
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
          Navigator.pop(context);
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
}
