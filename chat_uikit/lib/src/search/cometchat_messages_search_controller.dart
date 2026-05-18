import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../cometchat_chat_uikit.dart';
import '../message_list/messages_builder_protocol.dart';

class CometChatMessagesSearchController
    extends CometChatSearchListController<BaseMessage, int>
    with CometChatMessageEventListener {
  CometChatMessagesSearchController({
    required BuilderProtocol builderProtocol,
    Function(Exception)? onError,
    OnLoad<BaseMessage>? onLoad,
    OnEmpty? onEmpty,
    this.user,
    this.group,
    this.tag,
    this.textFormatters
  }) : super(
          builderProtocol: builderProtocol,
          onError: onError,
          onLoad: onLoad,
          onEmpty: onEmpty,
        );

  final String? tag;

  late String dateStamp;
  late String _messageListenerId;
  late String _groupListenerId;

  // The text formatters to be used for formatting text messages.
  List<CometChatTextFormatter>? textFormatters;

  User? loggedInUser;
  User? user;
  Group? group;
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
  int newUnreadMessageCount = 0;
  static int counter = 0;
  bool isThread = false;
  late String _uiGroupListener;
  late String _uiMessageListener;
  bool inInitialized = false;

  Set<String> selectedFilters = {};

  /// Stores the developer's original limit from the passed builder.
  /// null means no custom limit was set — defaults to 3 (preview) / 30 (filtered).
  int? _initialLimit;

  late CometChatSearchController searchController;

  @override
  void onInit() {
    isLoading = false;
    dateStamp = DateTime.now().microsecondsSinceEpoch.toString();
    _uiMessageListener = "${dateStamp}_ui_message_listener";
    // Capture the developer's limit before handleSearchAndFilters overwrites builderProtocol
    _initialLimit = builderProtocol.requestBuilder.limit;
    // Find the search controller instance
    // Listen to changes
    searchController = Get.find<CometChatSearchController>(tag: tag);
    ever<Set<String>>(searchController.selectedFilters, (filters) {
      onFilterChanged(filters);
    });
    initializeTextFormatters();
    // Register for message events to receive reaction updates
    CometChatMessageEvents.addMessagesListener(_uiMessageListener, this);
  }

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

    // Ensure rich text formatter is included for rendering formatted messages in search results
    if (textFormatters.indexWhere(
            (element) => element is CometChatRichTextFormatter) == -1) {
      textFormatters.add(CometChatRichTextFormatter());
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

  @override
  void onClose() {
    // Remove message event listener
    CometChatMessageEvents.removeMessagesListener(_uiMessageListener);
    selectedFilters.clear();
    list.clear();
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

  final deBouncer = Debouncer(milliseconds: 500);
  
  /// Request version to track and ignore stale responses
  int _requestVersion = 0;

  void onFilterChanged(Set<String> filters) {
    handleSearchAndFilters(filters: filters);
  }

  void handleSearchAndFilters(
      {String? searchText, Set<String>? filters}) async {
    final currentFilters = filters ?? selectedFilters;
    final currentSearch = (searchText ?? searchController.searchText).trim();

    // Update selected filters if passed
    if (filters != null) selectedFilters = filters;

    final validFilters = {
      SearchConstants.photos,
      SearchConstants.videos,
      SearchConstants.audio,
      SearchConstants.documents,
      SearchConstants.links
    };
    final hasValidFilter = currentFilters.any((f) => validFilters.contains(f));
    final hasInvalidFilter = currentFilters.isNotEmpty && !hasValidFilter;

    // Early return if filters are not relevant to messages search
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

    final builder = MessagesRequestBuilder()
      ..uid = user?.uid
      ..guid = group?.guid;

    if (selectedFilters.isEmpty) {
      builder.limit = _initialLimit ?? 3;
      builder.types = [
        MessageTypeConstants.text,
        MessageTypeConstants.image,
        MessageTypeConstants.video,
        MessageTypeConstants.audio,
        MessageTypeConstants.file,
      ];
    } else {
      builder.limit = _initialLimit ?? 30;
    }

    if (currentSearch.isNotEmpty) {
      builder.searchKeyword = currentSearch;
    }

    if (currentFilters.contains(SearchConstants.photos) ||
        currentFilters.contains(SearchConstants.videos) ||
        currentFilters.contains(SearchConstants.documents) ||
        currentFilters.contains(SearchConstants.audio)) {
      builder.attachmentTypes ??= [];
    }

    if (currentFilters.contains(SearchConstants.photos)) {
      builder.attachmentTypes?.add(AttachmentType.IMAGE.value);
    }

    if (currentFilters.contains(SearchConstants.videos)) {
      builder.attachmentTypes?.add(AttachmentType.VIDEO.value);
    }

    if (currentFilters.contains(SearchConstants.links)) {
      builder.hasLinks = true;
    }

    if (currentFilters.contains(SearchConstants.documents)) {
      builder.attachmentTypes?.add(AttachmentType.FILE.value);
    }

    if (currentFilters.contains(SearchConstants.audio)) {
      builder.attachmentTypes?.add(AttachmentType.AUDIO.value);
    }

    builderProtocol = UIMessagesBuilder(builder);
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

  /// Public loadMore for external callers (e.g., "See More" button)
  Future<void> loadMore() async {
    await _loadMoreWithVersionCheck(_requestVersion);
  }

  @override
  loadMoreElements({bool Function(BaseMessage element)? isIncluded}) async {
    await _loadMoreWithVersionCheck(_requestVersion);
  }

  Future<void> _loadMoreWithVersionCheck(int requestVersion) async {
    if (isFetching) return;

    isFetching = true;
    isLoading = true;
    loggedInUser ??= await CometChat.getLoggedInUser();

    try {
      await request.fetchPrevious(
        onSuccess: (List<BaseMessage> fetchedList) {
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
            final limit = builderProtocol.requestBuilder.limit ?? 30;
            hasMoreItems = fetchedList.length >= limit;
            for (var element in fetchedList.reversed) {
              if (element is InteractiveMessage) {
                element = InteractiveMessageUtils
                    .getSpecificMessageFromInteractiveMessage(element);
              }
              list.add(element);
            }
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

  @override
  void onSearch(String val) {
    handleSearchAndFilters(searchText: val);
  }

  /// Validates if the message's category and type match allowed values.
  /// This method checks against categories and types from the request builder,
  /// falling back to default values from the data source if none are provided.
  /// @param message The message to validate.
  /// @return True if both category and type are allowed, false otherwise.
  bool messageCategoryTypeCheck(BaseMessage message) {
    List<String> categories = builderProtocol.requestBuilder.categories ??
        CometChatUIKit.getDataSource().getAllMessageCategories();
    List<String> types = builderProtocol.requestBuilder.types ??
        CometChatUIKit.getDataSource().getAllMessageTypes();

    return categories.contains(message.category) &&
        types.contains(message.type);
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

  //----------------Reaction Event Handlers---------------------------------------------

  @override
  void onMessageReactionAdded(ReactionEvent reactionEvent) {
    _updateMessageOnReaction(reactionEvent, ReactionAction.reactionAdded);
  }

  @override
  void onMessageReactionRemoved(ReactionEvent reactionEvent) {
    _updateMessageOnReaction(reactionEvent, ReactionAction.reactionRemoved);
  }

  void _updateMessageOnReaction(ReactionEvent reactionEvent, String reactionAction) {
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
}
