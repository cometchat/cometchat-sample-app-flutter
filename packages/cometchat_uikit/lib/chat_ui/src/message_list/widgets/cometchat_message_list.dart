import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';
import 'cometchat_message_action_overlay.dart';
import 'cometchat_message_swipe.dart';

/// Callback for thread replies click
typedef ThreadRepliesClick = void Function(
  BaseMessage message,
  BuildContext context, {
  CometChatMessageTemplate? template,
});

/// Builder function for message items with animation support
typedef MessageItemBuilder = Widget Function(
  BuildContext context,
  BaseMessage message,
  int index,
  Animation<double> animation,
);

/// Builder function for header and footer views
typedef HeaderFooterBuilder = Widget? Function(
  BuildContext context, {
  User? user,
  Group? group,
  int? parentMessageId,
});

/// Builder function for state views (empty, error, loading)
typedef StateViewBuilder = Widget Function(BuildContext context);

/// [CometChatMessageList] is a Clean Architecture + BLoC based message list widget.
class CometChatMessageList extends StatefulWidget {
  const CometChatMessageList({
    super.key,
    this.user,
    this.group,
    this.messageListBloc,
    this.messagesRequestBuilder,
    this.templates,
    this.addTemplate,
    this.parentMessageId,
    this.hideDeletedMessages = false,
    this.disableSoundForMessages = false,
    this.disableReceipts = false,
    this.hideReplies = true,
    this.headerView,
    this.footerView,
    this.loadingStateView,
    this.emptyStateView,
    this.errorStateView,
    this.emptyChatGreetingView,
    this.style,
    this.scrollController,
    this.alignment = ChatAlignment.standard,
    this.onError,
    this.onLoad,
    this.onEmpty,
    this.stateCallBack,
    this.customSoundForMessages,
    this.customSoundForMessagePackage,
    this.readIcon,
    this.deliveredIcon,
    this.sentIcon,
    this.waitIcon,
    this.avatarVisibility = true,
    this.hideTimestamp,
    this.datePattern,
    this.dateSeparatorPattern,
    this.dateSeparatorStyle,
    this.hideDateSeparator = false,
    this.hideStickyDate = false,
    this.onThreadRepliesClick,
    this.hideThreadView,
    this.receiptsVisibility = true,
    this.disableReactions = false,
    this.addReactionIcon,
    this.addMoreReactionTap,
    this.favoriteReactions,
    this.onReactionClick,
    this.onReactionLongPress,
    this.onReactionListItemClick,
    this.reactionsRequestBuilder,
    this.textFormatters,
    this.additionalConfigurations,
    this.disableMentions,
    this.mentionAllLabel,
    this.mentionAllLabelId,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.hideCopyMessageOption = false,
    this.hideDeleteMessageOption = false,
    this.hideEditMessageOption = false,
    this.hideGroupActionMessages = false,
    this.hideMessageInfoOption = false,
    this.hideMessagePrivatelyOption = false,
    this.hideReactionOption = false,
    this.hideReplyInThreadOption = false,
    this.hideTranslateMessageOption = false,
    this.hideShareMessageOption = false,
    this.hideModerationView,
    this.enableConversationStarters = false,
    this.enableSmartReplies = false,
    this.smartRepliesDelayDuration = 10000,
    this.smartRepliesKeywords = const ['what', 'when', 'why', 'who', 'where', 'how', '?'],
    this.suggestedMessages,
    this.hideSuggestedMessages = false,
    this.emptyStateText,
    this.errorStateText,
    this.dateTimeFormatterCallback,
    this.enableSwipeToReply = true,
    this.goToMessageId,
    this.showMarkAsUnreadOption = false,
    this.startFromUnreadMessages = false,
  }) : assert(user != null || group != null, "One of user or group should be passed"),
       assert(user == null || group == null, "Only one of user or group should be passed");

  final User? user;
  final Group? group;
  final MessageListBloc? messageListBloc;
  final MessagesRequestBuilder? messagesRequestBuilder;
  final List<CometChatMessageTemplate>? templates;
  final List<CometChatMessageTemplate>? addTemplate;
  final int? parentMessageId;
  final bool hideDeletedMessages;
  final bool disableSoundForMessages;
  final bool disableReceipts;
  final bool hideReplies;
  final HeaderFooterBuilder? headerView;
  final HeaderFooterBuilder? footerView;
  final WidgetBuilder? loadingStateView;
  final WidgetBuilder? emptyStateView;
  final WidgetBuilder? errorStateView;
  final WidgetBuilder? emptyChatGreetingView;
  final CometChatMessageListStyle? style;
  final ScrollController? scrollController;
  final ChatAlignment alignment;
  final OnError? onError;
  final OnLoad<BaseMessage>? onLoad;
  final OnEmpty? onEmpty;
  final Function(CometChatMessageListControllerProtocol controller)? stateCallBack;
  final String? customSoundForMessages;
  final String? customSoundForMessagePackage;
  final Widget? readIcon;
  final Widget? deliveredIcon;
  final Widget? sentIcon;
  final Widget? waitIcon;
  final bool? avatarVisibility;
  final bool? hideTimestamp;
  final String Function(BaseMessage message)? datePattern;
  final String Function(DateTime dateTime)? dateSeparatorPattern;
  final CometChatDateStyle? dateSeparatorStyle;
  final bool? hideDateSeparator;
  final bool? hideStickyDate;
  final ThreadRepliesClick? onThreadRepliesClick;
  final bool? hideThreadView;
  final bool? receiptsVisibility;
  final bool? disableReactions;
  final Widget? addReactionIcon;
  final Function(BaseMessage message)? addMoreReactionTap;
  final List<String>? favoriteReactions;
  final Function(String? emoji, BaseMessage message)? onReactionClick;
  final Function(String? emoji, BaseMessage message)? onReactionLongPress;
  final Function(String? reaction, BaseMessage? message)? onReactionListItemClick;
  final ReactionsRequestBuilder? reactionsRequestBuilder;
  final List<CometChatTextFormatter>? textFormatters;
  final AdditionalConfigurations? additionalConfigurations;
  final bool? disableMentions;
  final String? mentionAllLabel;
  final String? mentionAllLabelId;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final bool? hideCopyMessageOption;
  final bool? hideDeleteMessageOption;
  final bool? hideEditMessageOption;
  final bool? hideGroupActionMessages;
  final bool? hideMessageInfoOption;
  final bool? hideMessagePrivatelyOption;
  final bool? hideReactionOption;
  final bool? hideReplyInThreadOption;
  final bool? hideTranslateMessageOption;
  final bool? hideShareMessageOption;
  final bool? hideModerationView;
  final bool? enableConversationStarters;
  final bool? enableSmartReplies;
  final int? smartRepliesDelayDuration;
  final List<String>? smartRepliesKeywords;
  final List<String>? suggestedMessages;
  final bool? hideSuggestedMessages;
  final String? emptyStateText;
  final String? errorStateText;
  final DateTimeFormatterCallback? dateTimeFormatterCallback;

  /// Whether swipe-to-reply is enabled. Defaults to true.
  final bool enableSwipeToReply;

  /// If set, the message list will scroll to this message after initial load.
  /// Shows a shimmer overlay while fetching and scrolling.
  final int? goToMessageId;

  /// Shows the "Mark as Unread" option in the long-press message options sheet.
  /// Default: false
  final bool showMarkAsUnreadOption;

  /// When true, the message list scrolls to the first unread message on open.
  /// Default: false
  final bool startFromUnreadMessages;

  @override
  State<CometChatMessageList> createState() => _CometChatMessageListState();
}

class _CometChatMessageListState extends State<CometChatMessageList>
    with WidgetsBindingObserver {
  late MessageListBloc _messageListBloc;
  late AnimatedMessageListBloc _animatedBloc;
  bool _isExternalBloc = false;
  late MessageListBlocAdapter _blocAdapter;
  late CometChatMessageListStyle _style;
  late CometChatColorPalette _colorPalette;
  late CometChatTypography _typography;
  late CometChatSpacing _spacing;
  Map<String, CometChatMessageTemplate> _templateMap = {};
  late ScrollController _scrollController;
  StreamSubscription<MessageOperation>? _operationsSubscription;
  
  // Cached bubble styles to avoid expensive lookups during rebuilds
  CometChatOutgoingMessageBubbleStyle? _cachedOutgoingStyle;
  CometChatIncomingMessageBubbleStyle? _cachedIncomingStyle;
  
  // Flag to track if theme has been initialized
  bool _themeInitialized = false;
  
  // Track brightness to detect theme changes
  Brightness? _cachedBrightness;

  // Sticky date notifier for the floating date header
  final ValueNotifier<DateTime?> _stickyDateNotifier = ValueNotifier<DateTime?>(null);

  // Jump-to-message shimmer overlay
  final ValueNotifier<bool> _isJumpingToMessage = ValueNotifier<bool>(false);

  // Highlighted message ID for glow effect after jump-to-message
  final ValueNotifier<int?> _highlightedMessageId = ValueNotifier<int?>(null);
  Timer? _highlightTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scrollController = widget.scrollController ?? ScrollController();
    _initializeBlocs();
    _initializeTemplates();
    _initializeAdapter();
    _subscribeToOperations();
    // When goToMessageId is set, skip normal load — jump directly
    if (widget.goToMessageId != null) {
      _isJumpingToMessage.value = true;
      _messageListBloc.add(JumpToMessage(messageId: widget.goToMessageId!));
      _waitForJumpTarget(widget.goToMessageId!);
    } else {
      // Show shimmer overlay while loading from unread position
      if (widget.startFromUnreadMessages && widget.parentMessageId == null) {
        _isJumpingToMessage.value = true;
      }
      _loadMessages();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Check if brightness has changed (dark mode toggle)
    final currentBrightness = MediaQuery.platformBrightnessOf(context);
    final brightnessChanged = _cachedBrightness != null && _cachedBrightness != currentBrightness;
    
    // Initialize theme on first run or when brightness changes
    if (!_themeInitialized || brightnessChanged) {
      _cachedBrightness = currentBrightness;
      _initializeTheme();
      _themeInitialized = true;
    }
    _blocAdapter.updateContext(context);
  }

  void _initializeTheme() {
    _colorPalette = CometChatThemeHelper.getColorPalette(context);
    _typography = CometChatThemeHelper.getTypography(context);
    _spacing = CometChatThemeHelper.getSpacing(context);
    _style = CometChatThemeHelper.getTheme<CometChatMessageListStyle>(
      context: context,
      defaultTheme: CometChatMessageListStyle.of,
    ).merge(widget.style);
    
    // Cache bubble styles to avoid expensive lookups during rebuilds
    _cachedOutgoingStyle = CometChatThemeHelper.getTheme<CometChatOutgoingMessageBubbleStyle>(
      context: context,
      defaultTheme: CometChatOutgoingMessageBubbleStyle.of,
    ).merge(_style.outgoingMessageBubbleStyle);
    
    _cachedIncomingStyle = CometChatThemeHelper.getTheme<CometChatIncomingMessageBubbleStyle>(
      context: context,
      defaultTheme: CometChatIncomingMessageBubbleStyle.of,
    ).merge(_style.incomingMessageBubbleStyle);
  }

  void _initializeBlocs() {
    if (widget.messageListBloc != null) {
      _messageListBloc = widget.messageListBloc!;
      _isExternalBloc = true;
    } else {
      if (!MessageListServiceLocator.instance.isInitialized) {
        MessageListServiceLocator.instance.setup();
      }
      List<String>? types;
      List<String>? categories;
      if (widget.messagesRequestBuilder == null) {
        categories = MessageTemplateUtils.getAllMessageCategories();
        types = MessageTemplateUtils.getAllMessageTypes();
      }
      _messageListBloc = MessageListBloc(
        user: widget.user,
        group: widget.group,
        parentMessageId: widget.parentMessageId ?? widget.messagesRequestBuilder?.parentMessageId,
        types: types,
        categories: categories,
        hideDeletedMessages: widget.hideDeletedMessages,
        disableSoundForMessages: widget.disableSoundForMessages,
        disableReceipts: widget.disableReceipts,
        hideReplies: widget.hideReplies,
      );
      _isExternalBloc = false;
    }
    _animatedBloc = AnimatedMessageListBloc();
  }

  void _initializeTemplates() {
    List<CometChatMessageTemplate> templates = widget.templates ?? 
        MessageTemplateUtils.getAllMessageTemplates();
    if (widget.addTemplate != null && widget.addTemplate!.isNotEmpty) {
      templates = [...templates, ...widget.addTemplate!];
    }
    _templateMap = {};
    for (final template in templates) {
      final key = '${template.category}_${template.type}';
      _templateMap[key] = template;
    }
  }

  void _initializeAdapter() {
    _blocAdapter = MessageListBlocAdapter(
      bloc: _messageListBloc,
      templateMap: _templateMap,
      scrollController: _scrollController,
      context: context,
    );
    if (widget.stateCallBack != null) {
      widget.stateCallBack!(_blocAdapter);
    }
  }

  void _loadMessages() {
    final conversationWith = widget.user?.uid ?? widget.group?.guid;
    final conversationType = widget.user != null ? 'user' : 'group';
    if (conversationWith != null) {
      if (widget.startFromUnreadMessages && widget.parentMessageId == null) {
        _messageListBloc.add(LoadFromUnread(
          conversationWith: conversationWith,
          conversationType: conversationType,
        ));
      } else {
        _messageListBloc.add(LoadMessages(
          conversationWith: conversationWith,
          conversationType: conversationType,
          parentMessageId: widget.parentMessageId ?? widget.messagesRequestBuilder?.parentMessageId,
        ));
      }
    }
  }

  void _subscribeToOperations() {
    _operationsSubscription = _messageListBloc.operationsStream.listen((op) {
      switch (op.type) {
        case MessageOperationType.insert:
          if (op.message != null) {
            _animatedBloc.add(InsertMessage(op.message!, index: op.index, animated: op.animated));
          }
          break;
        case MessageOperationType.insertAll:
          if (op.messages != null && op.messages!.isNotEmpty) {
            _animatedBloc.add(InsertAllMessages(op.messages!, index: op.index, animated: op.animated));
          }
          break;
        case MessageOperationType.update:
          if (op.message != null && op.oldMessage != null) {
            _animatedBloc.add(UpdateMessage(op.oldMessage!, op.message!));
          }
          break;
        case MessageOperationType.remove:
          if (op.message != null) {
            _animatedBloc.add(RemoveMessage(op.message!, animated: op.animated));
          }
          break;
        case MessageOperationType.set:
          if (op.messages != null) {
            _animatedBloc.add(SetMessages(op.messages!, animated: op.animated));
          }
          break;
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // Silently sync any messages that arrived while the app was in the background
      _messageListBloc.add(const SyncMessages());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _operationsSubscription?.cancel();
    // Clear all audio states and release memory
    AudioStateManager().clearAll();
    if (!_isExternalBloc) {
      _messageListBloc.close();
    }
    _animatedBloc.close();
    _stickyDateNotifier.dispose();
    _isJumpingToMessage.dispose();
    _highlightTimer?.cancel();
    _highlightedMessageId.dispose();
    if (widget.scrollController == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MessageListBloc>.value(
      value: _messageListBloc,
      child: Container(
        padding: widget.padding,
        margin: widget.margin,
        height: widget.height,
        width: widget.width,
        decoration: BoxDecoration(
          color: _style.backgroundColor ?? _colorPalette.background3,
          border: _style.border,
          borderRadius: _style.borderRadius ?? BorderRadius.circular(0),
        ),
        child: BlocConsumer<MessageListBloc, MessageListState>(
          listener: _handleStateChanges,
          listenWhen: (previous, current) =>
              previous.status != current.status ||
              (!previous.markedAsUnreadInSession && current.markedAsUnreadInSession),
          // Only rebuild when status changes, not on every state update
          buildWhen: (previous, current) => previous.status != current.status,
          builder: (context, state) => _buildContent(context, state),
        ),
      ),
    );
  }

  void _handleStateChanges(BuildContext context, MessageListState state) {
    if (state.status == MessageListStatus.error && widget.onError != null) {
      widget.onError!(CometChatException(
        'MESSAGE_LIST_ERROR',
        state.errorMessage ?? 'An error occurred',
        state.errorMessage ?? 'An error occurred',
      ));
    }
    if (state.status == MessageListStatus.loaded && widget.onLoad != null) {
      widget.onLoad!(state.messages);
    }
    if (state.status == MessageListStatus.empty && widget.onEmpty != null) {
      widget.onEmpty!();
    }
    // When mark-as-unread succeeds, trigger a re-render of the animated list
    // so the "New Messages" indicator appears above the marked message.
    if (state.markedAsUnreadInSession && mounted) {
      _messageListBloc.notifyListChanged();
    }
    // When LoadFromUnread finishes, scroll to the unread anchor message
    // so the "New Messages" indicator is visible on screen.
    // The shimmer overlay (set in initState) hides the scroll jump.
    if (state.status == MessageListStatus.loaded &&
        state.unreadMessageAnchorId != null &&
        !state.markedAsUnreadInSession &&
        mounted) {
      _scrollToMessageAfterLayout(state.unreadMessageAnchorId!);
    }
    // If LoadFromUnread fell back to normal load (no anchor), hide shimmer
    // But NOT when goToMessageId is set — _waitForJumpTarget handles that
    if (state.status == MessageListStatus.loaded &&
        state.unreadMessageAnchorId == null &&
        widget.goToMessageId == null &&
        _isJumpingToMessage.value &&
        mounted) {
      _isJumpingToMessage.value = false;
    }
  }

  /// Wait for JumpToMessage to load the target, then scroll to it.
  void _waitForJumpTarget(int messageId) {
    late StreamSubscription<MessageListState> sub;
    sub = _messageListBloc.stream.listen((state) {
      if (_messageListBloc.findMessageIndex(messageId) != null) {
        sub.cancel();
        _scrollToMessageAfterLayout(messageId);
      }
    });
    // Safety timeout
    Future.delayed(const Duration(seconds: 5), () {
      sub.cancel();
      if (mounted) _isJumpingToMessage.value = false;
    });
  }

  /// Handle scroll-to-bottom button tap.
  /// If the list already has the latest messages (hasMoreNewer == false),
  /// just scroll to offset 0. Otherwise, refresh to load from the latest.
  void _handleScrollToBottomTap() {
    if (_messageListBloc.state.hasMoreNewer) {
      // List doesn't have the latest messages — refresh from the latest
      _messageListBloc.add(const RefreshMessages());
    } else {
      // List has the latest messages — just scroll to bottom
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 250),
          curve: Curves.linearToEaseOut,
        );
      }
    }
  }

  Widget _buildContent(BuildContext context, MessageListState state) {
    switch (state.status) {
      case MessageListStatus.initial:
      case MessageListStatus.loading:
        // When jumping to a message, show shimmer instead of circular loader
        if (widget.goToMessageId != null) {
          return _buildJumpShimmer();
        }
        return _buildLoadingState(context);
      case MessageListStatus.empty:
        return _buildEmptyState(context);
      case MessageListStatus.error:
        return _buildErrorState(context, state.errorMessage);
      case MessageListStatus.loaded:
        return _buildMessageListContent(context, state);
    }
  }

  Widget _buildLoadingState(BuildContext context) {
    if (widget.loadingStateView != null) {
      return Center(child: widget.loadingStateView!(context));
    }
    return _buildJumpShimmer();
  }

  Widget _buildEmptyState(BuildContext context) {
    if (widget.emptyChatGreetingView != null) {
      return Center(child: widget.emptyChatGreetingView!(context));
    }
    if (widget.emptyStateView != null) {
      return Center(child: widget.emptyStateView!(context));
    }
    return const SizedBox(width: double.infinity);
  }

  Widget _buildErrorState(BuildContext context, String? errorMessage) {
    if (widget.errorStateView != null) {
      return Center(child: widget.errorStateView!(context));
    }
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 48, color: _colorPalette.error),
          SizedBox(height: _spacing.padding3 ?? 12),
          Text(
            widget.errorStateText ?? Translations.of(context).somethingWentWrongError,
            style: TextStyle(color: _colorPalette.textPrimary),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: _spacing.padding4 ?? 16),
          ElevatedButton(
            onPressed: _loadMessages,
            child: Text(Translations.of(context).tryAgain),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageListContent(BuildContext context, MessageListState state) {
    return Column(
      children: [
        // Header view
        if (widget.headerView != null)
          widget.headerView!(
            context,
            user: widget.user,
            group: widget.group,
            parentMessageId: widget.parentMessageId,
          ) ?? const SizedBox.shrink(),
        // Main message list content
        Expanded(
          child: Stack(
            children: [
              CometChatAnimatedMessageList(
                bloc: _animatedBloc,
                itemBuilder: _buildMessageItem,
                scrollController: _scrollController,
                reversed: true,
                keyboardDismissBehavior: defaultTargetPlatform == TargetPlatform.iOS
                    ? ScrollViewKeyboardDismissBehavior.onDrag
                    : ScrollViewKeyboardDismissBehavior.manual,
                findMessageIndex: _messageListBloc.findMessageIndex,
                loggedInUserId: _messageListBloc.state.loggedInUser?.uid,
                onTopVisibleDateChanged: widget.hideStickyDate == true
                    ? null
                    : (date) {
                        _stickyDateNotifier.value = date;
                      },
                onLoadOlder: () async {
                  _messageListBloc.add(const LoadOlderMessages());
                },
                onLoadNewer: () async {
                  // Skip if no more newer messages to avoid hanging await
                  if (!_messageListBloc.state.hasMoreNewer) return;
                  _messageListBloc.add(const LoadNewerMessages());
                  // Wait for the bloc to finish loading newer messages.
                  // Complete when either:
                  // - isLoadingNewer becomes false (fetch completed)
                  // - hasMoreNewer becomes false (no more messages to fetch)
                  await _messageListBloc.stream.firstWhere(
                    (state) => !state.isLoadingNewer || !state.hasMoreNewer,
                  ).timeout(
                    const Duration(seconds: 10),
                    onTimeout: () => _messageListBloc.state,
                  );
                },
                onScrollToBottomTap: _handleScrollToBottomTap,
              ),
              // Sticky date header
              if (widget.hideStickyDate != true)
                _buildStickyDateHeader(),
              // Shimmer overlay during jump-to-message (fades out smoothly)
              Positioned.fill(
          child: ValueListenableBuilder<bool>(
            valueListenable: _isJumpingToMessage,
            builder: (context, isJumping, child) {
              return IgnorePointer(
                ignoring: !isJumping,
                child: AnimatedOpacity(
                  opacity: isJumping ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: child!,
                ),
              );
            },
            child: Container(
              color: _colorPalette.background3 ?? Colors.white,
              child: _buildJumpShimmer(),
            ),
          ),
        ),
      ],
    ),
        ),
        // Footer view
        if (widget.footerView != null)
          widget.footerView!(
            context,
            user: widget.user,
            group: widget.group,
            parentMessageId: widget.parentMessageId,
          ) ?? const SizedBox.shrink(),
      ],
    );
  }

  Widget _buildStickyDateHeader() {
    return Positioned(
      top: 8,
      left: 0,
      right: 0,
      child: Center(
        child: ValueListenableBuilder<DateTime?>(
          valueListenable: _stickyDateNotifier,
          builder: (context, date, _) {
            if (date == null) return const SizedBox.shrink();

            String? customDateString;
            if (widget.dateSeparatorPattern != null) {
              customDateString = widget.dateSeparatorPattern!(date);
            }

            return IgnorePointer(
              child: CometChatDate(
                date: date,
                pattern: DateTimePattern.dayDateFormat,
                customDateString: customDateString,
                style: widget.dateSeparatorStyle ?? const CometChatDateStyle(),
                dateTimeFormatterCallback: widget.dateTimeFormatterCallback,
              ),
            );
          },
        ),
      ),
    );
  }

  /// Build shimmer placeholder shown during jump-to-message fetch
  Widget _buildJumpShimmer() {
    return CometChatShimmerEffect(
      colorPalette: _colorPalette,
      child: ListView.builder(
        reverse: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 8,
        padding: EdgeInsets.symmetric(
          horizontal: _spacing.padding4 ?? 16,
          vertical: _spacing.padding3 ?? 12,
        ),
        itemBuilder: (context, index) {
          // Alternate left/right to mimic chat bubbles
          final isRight = index % 3 == 0;
          return Align(
            alignment: isRight ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              margin: EdgeInsets.only(bottom: _spacing.padding3 ?? 12),
              width: isRight ? 200 : 240,
              height: 48 + (index % 2 == 0 ? 16.0 : 0.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMessageItem(
    BuildContext context,
    BaseMessage message,
    int index,
    Animation<double> animation,
  ) {
    // Hide group action messages if configured
    if (message.receiver is Group &&
        message.category == MessageCategoryConstants.action &&
        widget.hideGroupActionMessages == true) {
      return const SizedBox.shrink();
    }

    // Hide action messages that have no visual template (e.g. mark-as-unread
    // actions). Group actions are handled above; other action-category messages
    // with type "message" are internal SDK actions with no content view.
    if (message.category == MessageCategoryConstants.action) {
      final templateKey = '${message.category}_${message.type}';
      final template = _templateMap[templateKey];
      if (template?.contentView == null) {
        return const SizedBox.shrink();
      }
    }

    final isOutgoing = message.sender?.uid == _messageListBloc.state.loggedInUser?.uid;
    final bool isCenterAligned = message.category == MessageCategoryConstants.action ||
        message.category == MessageCategoryConstants.call;
    final alignment = isCenterAligned
        ? BubbleAlignment.center
        : isOutgoing
            ? BubbleAlignment.right
            : BubbleAlignment.left;

    // Use cached bubble styles instead of expensive lookups
    final outgoingMessageBubbleStyle = _cachedOutgoingStyle;
    final incomingMessageBubbleStyle = _cachedIncomingStyle;

    // Get bubble style data using BubbleUIBuilder
    final bubbleStyleData = BubbleUIBuilder.getBubbleStyle(
      message,
      outgoingMessageBubbleStyle,
      incomingMessageBubbleStyle,
      _colorPalette,
      _typography,
      _spacing,
    );

    Color? backgroundColor = bubbleStyleData?.backgroundColor;

    // Sticker messages with a reply need a solid background so the reply
    // text (white for outgoing) is visible against the sticker's normally
    // transparent background.
    final bool isStickerWithReply = message.category == MessageCategoryConstants.custom &&
        message.type == ExtensionType.sticker &&
        message.quotedMessage != null;
    if (isStickerWithReply) {
      backgroundColor = isOutgoing
          ? _colorPalette.primary
          : (_colorPalette.neutral300 ?? _colorPalette.background2);
    }

    // Check if template has custom bubbleView
    final templateKey = '${message.category}_${message.type}';
    final template = _templateMap[templateKey];

    Widget bubbleView;
    if (message.deletedAt == null && template?.bubbleView != null) {
      bubbleView = template!.bubbleView!(message, context, alignment) ?? const SizedBox();
    } else {
      // Build content view from template
      Widget? contentView = _getContentView(message, context, backgroundColor, alignment);

      final bool isDeleted = message.deletedAt != null;

      // Build header view (sender name for group messages)
      Widget? headerView;
      if (!isDeleted && !isCenterAligned && !isOutgoing && widget.group != null) {
        headerView = _getHeaderView(message, bubbleStyleData);
      }

      // Build leading view (avatar) — only in group chats
      Widget? leadingView;
      if (!isCenterAligned && !isOutgoing && widget.avatarVisibility == true && widget.group != null) {
        leadingView = _getAvatar(message.sender, bubbleStyleData?.messageBubbleAvatarStyle);
      }

      // Build footer view (timestamp, receipts) — skip for center-aligned messages
      Widget? footerView;
      if (!isCenterAligned) {
        footerView = _getFooterView(message, alignment, bubbleStyleData);
      }

      // Build status info view — skip for center-aligned messages
      Widget? statusInfoView;
      if (!isCenterAligned) {
        statusInfoView = _getStatusInfoView(message, alignment, bubbleStyleData);
      }

      // contentPadding is no longer needed — each bubble handles its own padding
      // For sticker messages with a reply, wrap the content in Align so the
      // sticker image stays its natural size instead of stretching to match
      // the reply preview width (CrossAxisAlignment.stretch in the bubble).
      Widget? finalContentView = contentView;
      if (isStickerWithReply && contentView != null) {
        finalContentView = Align(
          alignment: Alignment.center,
          child: contentView,
        );
      }

      bubbleView = CometChatMessageBubble(
        style: CometChatMessageBubbleStyle(
          backgroundColor: backgroundColor,
          backgroundImage: isDeleted ? null : bubbleStyleData?.messageBubbleBackgroundImage,
          border: bubbleStyleData?.border,
          borderRadius: bubbleStyleData?.borderRadius,
        ),
        alignment: alignment,
        headerView: headerView,
        replyView: isDeleted ? null : _getReplyView(message, alignment),
        contentView: finalContentView,
        footerView: footerView,
        leadingView: leadingView,
        statusInfoView: statusInfoView,
        threadView: !isDeleted && widget.hideThreadView != true
            ? _getThreadView(message, alignment, bubbleStyleData)
            : null,
      );
    }

    // Date separator logic
    Widget? dateSeparator;
    if (widget.hideDateSeparator != true) {
      final messageDate = message.sentAt ?? message.updatedAt;
      if (messageDate != null) {
        bool showSeparator = false;
        if (index == 0) {
          // First (oldest) message always gets a separator
          showSeparator = true;
        } else {
          // Compare with previous message's date
          final messages = _animatedBloc.state.messages;
          if (index < messages.length) {
            final prevMessage = messages[index - 1];
            final prevDate = prevMessage.sentAt ?? prevMessage.updatedAt;
            if (prevDate == null ||
                prevDate.year != messageDate.year ||
                prevDate.month != messageDate.month ||
                prevDate.day != messageDate.day) {
              showSeparator = true;
            }
          }
        }
        if (showSeparator) {
          String? customDateString;
          if (widget.dateSeparatorPattern != null) {
            customDateString = widget.dateSeparatorPattern!(messageDate);
          }
          dateSeparator = Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: _spacing.padding3 ?? 12),
              child: CometChatDate(
                date: messageDate,
                pattern: DateTimePattern.dayDateFormat,
                customDateString: customDateString,
                style: widget.dateSeparatorStyle ?? const CometChatDateStyle(),
                dateTimeFormatterCallback: widget.dateTimeFormatterCallback,
              ),
            ),
          );
        }
      }
    }

    // Generate hero tag for the message bubble
    final heroTag = 'message_bubble_${message.id > 0 ? message.id : message.muid.hashCode}';

    // Generate a unique key that changes when message content changes
    // This forces SliverAnimatedList to rebuild the item when edits occur
    // Note: reactions are NOT included in the key because CometChatReactions
    // updates itself via ReactionsBloc. Including reactions here would force
    // a full teardown/rebuild of expensive content widgets (image, video, etc.)
    final messageKey = message.id > 0 ? message.id : message.muid.hashCode;
    final editedHash = message.editedAt?.millisecondsSinceEpoch ?? 0;
    final compositeKey = '$messageKey-$editedHash';

    // Create a GlobalKey to measure the bubble size for the action overlay
    final bubbleKey = GlobalKey();

    // RepaintBoundary isolates each message item's repaints for better scroll performance
    // ValueKey with composite key ensures rebuild when message content changes
    final messageWidget = RepaintBoundary(
      child: SizeTransition(
        sizeFactor: animation,
        child: FadeTransition(
          opacity: animation,
          child: ValueListenableBuilder<int?>(
            valueListenable: _highlightedMessageId,
            builder: (context, highlightedId, child) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                color: highlightedId == message.id
                    ? (_colorPalette.primary?.withOpacity(0.3) ?? Colors.transparent)
                    : Colors.transparent,
                child: child!,
              );
            },
            child: GestureDetector(
            onLongPress: () {
              // Measure the actual bubble size using the GlobalKey
              Size? bubbleSize;
              bool isFullyVisible = false;
              final renderBox = bubbleKey.currentContext?.findRenderObject() as RenderBox?;
              if (renderBox != null && renderBox.hasSize) {
                bubbleSize = renderBox.size;
                
                // Check if bubble is fully visible in viewport
                // Get the bubble's position relative to the screen
                final bubblePosition = renderBox.localToGlobal(Offset.zero);
                final bubbleTop = bubblePosition.dy;
                final bubbleBottom = bubbleTop + bubbleSize.height;
                
                // Get viewport bounds (screen height minus safe areas)
                final screenHeight = MediaQuery.sizeOf(context).height;
                final safeAreaTop = MediaQuery.paddingOf(context).top;
                final viewportTop = safeAreaTop + 60; // Account for header (~60px)
                final viewportBottom = screenHeight - 80; // Account for composer (~80px)
                
                // Bubble is fully visible if entirely within viewport bounds
                isFullyVisible = bubbleTop >= viewportTop && bubbleBottom <= viewportBottom;
              }
              
              // Only pass heroTag if bubble is fully visible, otherwise pass null
              _showMessageActions(
                message, 
                bubbleView, 
                alignment, 
                isFullyVisible ? heroTag : null, 
                bubbleSize,
              );
            },
            child: Row(
              mainAxisAlignment: alignment == BubbleAlignment.left
                  ? MainAxisAlignment.start
                  : alignment == BubbleAlignment.center
                      ? MainAxisAlignment.center
                      : MainAxisAlignment.end,
              children: [
                // Wrap in Hero only when bubble is fully visible in viewport
                // heroTag is set to the actual tag only when fully visible, null otherwise
                Builder(
                  builder: (context) {
                    final bubbleWidget = Material(
                      key: bubbleKey,
                      color: Colors.transparent,
                      child: bubbleView,
                    );
                    
                    // Hero is always present but tag changes based on visibility
                    // When not fully visible, we use a unique non-matching tag
                    return Hero(
                      tag: heroTag,
                      flightShuttleBuilder: (
                        BuildContext flightContext,
                        Animation<double> animation,
                        HeroFlightDirection flightDirection,
                        BuildContext fromHeroContext,
                        BuildContext toHeroContext,
                      ) {
                        return OverflowBox(
                          alignment: Alignment.center,
                          minWidth: 0,
                          minHeight: 0,
                          maxWidth: double.infinity,
                          maxHeight: double.infinity,
                          child: Material(
                            color: Colors.transparent,
                            child: bubbleView,
                          ),
                        );
                      },
                      child: bubbleWidget,
                    );
                  },
                ),
              ],
            ),
          ),
          ),
        ),
      ),
    );

    // Wrap with swipe-to-reply
    final swipeableWidget = CometChatMessageSwipe(
      enabled: _canSwipe(message),
      onSwipe: () => CometChatMessageEvents.ccReplyToMessage(message),
      child: messageWidget,
    );

    // Build the new message indicator if this is the unread anchor
    final newMessageIndicator = _getNewMessageIndicator(message);

    // Wrap with date separator if needed
    if (dateSeparator != null || newMessageIndicator != null) {
      return Column(
        key: ValueKey<String>(compositeKey),
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dateSeparator != null) dateSeparator,
          if (newMessageIndicator != null) newMessageIndicator,
          swipeableWidget,
        ],
      );
    }

    return KeyedSubtree(
      key: ValueKey<String>(compositeKey),
      child: swipeableWidget,
    );
  }

  /// Whether swipe-to-reply is allowed for this message
  bool _canSwipe(BaseMessage message) {
    if (!widget.enableSwipeToReply) return false;
    if (message.id <= 0) return false;
    if (message.deletedAt != null) return false;
    if (message.category == MessageCategoryConstants.action) return false;
    if (message.category == MessageCategoryConstants.call) return false;
    return true;
  }

  /// Returns the "New Messages" indicator if this message is the unread anchor.
  /// Works for both initial-load unread (startFromUnreadMessages) and
  /// in-session mark-as-unread.
  Widget? _getNewMessageIndicator(BaseMessage message) {
    final anchorId = _messageListBloc.state.unreadMessageAnchorId;
    if (anchorId == null || message.id != anchorId) return null;

    return CometChatNewMessageIndicator(
      colorPalette: _colorPalette,
      typography: _typography,
      spacing: _spacing,
    );
  }

  /// Get avatar widget for incoming messages
  Widget _getAvatar(User? user, CometChatAvatarStyle? avatarStyle) {
    if (user == null) return const SizedBox();
    return Padding(
      padding: EdgeInsets.only(right: _spacing.padding2 ?? 8),
      child: CometChatAvatar(
        image: user.avatar,
        name: user.name,
        width: 36,
        height: 36,
        style: _style.avatarStyle ?? avatarStyle,
      ),
    );
  }

  /// Get header view (sender name)
  Widget? _getHeaderView(BaseMessage message, CometChatMessageBubbleStyleData? bubbleStyleData) {
    final templateKey = '${message.category}_${message.type}';
    final template = _templateMap[templateKey];

    if (template?.headerView != null) {
      return template!.headerView!(message, context, BubbleAlignment.left);
    }

    return Padding(
      padding: EdgeInsets.only(bottom: _spacing.padding1 ?? 4),
      child: Text(
        message.sender?.name ?? '',
        style: TextStyle(
          fontSize: _typography.caption1?.medium?.fontSize,
          color: _colorPalette.primary,
          fontWeight: _typography.caption1?.medium?.fontWeight,
          fontFamily: _typography.caption1?.medium?.fontFamily,
        ).merge(bubbleStyleData?.senderNameTextStyle),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  /// Returns a human-readable subtitle for a quoted/reply message type.
  String _getReplySubtitleForType(String type, BuildContext context) {
    switch (type) {
      case MessageTypeConstants.image:
        return Translations.of(context).messageImage;
      case MessageTypeConstants.video:
        return Translations.of(context).messageVideo;
      case MessageTypeConstants.audio:
        return Translations.of(context).messageAudio;
      case MessageTypeConstants.file:
        return Translations.of(context).messageFile;
      case ExtensionType.extensionPoll:
        return Translations.of(context).poll;
      case ExtensionType.document:
        return Translations.of(context).collaborativeDocument;
      case ExtensionType.whiteboard:
        return Translations.of(context).collaborativeWhiteboard;
      default:
        return type;
    }
  }

  /// Build the quoted reply preview shown inside a bubble when a message is a reply.
  /// Reads the `quotedMessage` field from the BaseMessage model.
  Widget? _getReplyView(BaseMessage message, BubbleAlignment alignment) {
    final BaseMessage? quoted = message.quotedMessage;
    if (quoted == null) return null;

    final String title = quoted.sender?.name ?? '';
    final String type = quoted.type;

    // For stickers, show a thumbnail image inside the reply bubble
    final bool isSticker = type == ExtensionType.sticker;
    String? stickerUrl;
    if (isSticker && quoted is CustomMessage) {
      stickerUrl = quoted.customData?['sticker_url'] as String?;
    }

    final String subtitle = type == MessageTypeConstants.text
        ? ConversationUtils.stripMarkdownSyntax(
            (quoted is TextMessage) ? quoted.text : '')
        : isSticker
            ? Translations.of(context).customMessageSticker
            : _getReplySubtitleForType(type, context);

    // Build a formatted single-line RichText for text message reply previews
    Widget? formattedSubtitleWidget;
    if (type == MessageTypeConstants.text && quoted is TextMessage) {
      final rawText = quoted.text;
      final formatters = FormatterUtils.ensureMarkdownFormatter(widget.textFormatters);
      final isOutgoing = alignment == BubbleAlignment.right;
      final subtitleTextStyle = TextStyle(
        fontSize: _typography.caption1?.regular?.fontSize,
        fontWeight: _typography.caption1?.regular?.fontWeight,
        color: isOutgoing
            ? Colors.white.withValues(alpha: 0.85)
            : _colorPalette.textSecondary,
      );
      formattedSubtitleWidget = RichText(
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        text: TextSpan(
          style: subtitleTextStyle,
          children: FormatterUtils.buildTextSpan(
            rawText,
            formatters,
            context,
            alignment,
            forConversation: true,
            textStyle: subtitleTextStyle,
          ),
        ),
        textScaler: MediaQuery.textScalerOf(context),
      );
    }

    // Extract the replied message ID for jump-to functionality
    final int? repliedMessageId = quoted.id > 0 ? quoted.id : null;

    // Use the quoted message directly for the media icon in ComposerUtils
    BaseMessage? repliedMessage;
    if (type != MessageTypeConstants.text && !isSticker) {
      repliedMessage = quoted;
    }

    final isOutgoing = alignment == BubbleAlignment.right;
    // Use semi-transparent white overlay for outgoing (shows on purple bubble)
    // Use neutral background for incoming (shows on white/light bubble)
    final bgColor = isOutgoing
        ? Colors.white.withValues(alpha: 0.15)
        : _colorPalette.neutral100?.withValues(alpha: 0.5) ?? _colorPalette.background2;

    return GestureDetector(
      onTap: repliedMessageId != null && repliedMessageId > 0
          ? () => _jumpToMessage(repliedMessageId)
          : null,
      child: CometChatMessagePreview(
        messagePreviewTitle: title,
        messagePreviewSubtitle: subtitle,
        subtitleWidget: formattedSubtitleWidget,
        message: repliedMessage,
        hideCloseButton: true,
        stickerUrl: stickerUrl,
        messagePreviewStyle: CometChatMessagePreviewStyle(
          messagePreviewBackground: bgColor,
          messagePreviewBorder: isOutgoing
              ? Border(
                  left: BorderSide(
                    color: Colors.white.withValues(alpha: 0.5),
                    width: 2,
                  ),
                )
              : null,
          messagePreviewTitleStyle: isOutgoing
              ? const TextStyle(color: Colors.white)
              : null,
          messagePreviewTitleColor: isOutgoing
              ? Colors.white
              : _colorPalette.textPrimary,
          messagePreviewSubtitleStyle: isOutgoing
              ? TextStyle(color: Colors.white.withValues(alpha: 0.85))
              : null,
          messagePreviewSubtitleColor: isOutgoing
              ? Colors.white.withValues(alpha: 0.85)
              : _colorPalette.textSecondary,
          replyMessagePreviewCloseIconColor: isOutgoing
              ? Colors.white
              : _colorPalette.iconSecondary,
        ),
      ),
    );
  }

  /// Jump to a specific message by ID and highlight it briefly.
  /// If the message is not in the current list, dispatches JumpToMessage
  /// to the bloc which fetches messages around the target, then scrolls.
  /// Shows a shimmer overlay while fetching + scrolling.
  void _jumpToMessage(int messageId) async {
    // Check if message exists in current list
    final messageIndex = _messageListBloc.findMessageIndex(messageId);

    if (messageIndex == null || messageIndex < 0) {
      // Show shimmer while fetching
      _isJumpingToMessage.value = true;

      // Message not in list — dispatch JumpToMessage to the bloc
      _messageListBloc.add(JumpToMessage(messageId: messageId));

      // Wait for the bloc to load messages around the target, then scroll
      late StreamSubscription<MessageListState> sub;
      sub = _messageListBloc.stream.listen((state) {
        if (_messageListBloc.findMessageIndex(messageId) != null) {
          sub.cancel();
          _scrollToMessageAfterLayout(messageId);
        }
      });

      // Safety timeout — cancel listener and hide shimmer after 5 seconds
      Future.delayed(const Duration(seconds: 5), () {
        sub.cancel();
        if (mounted) _isJumpingToMessage.value = false;
      });
      return;
    }

    // Message exists in list — smooth animated scroll (no shimmer needed)
    await _animatedBloc.scrollToMessage(
      messageId,
      alignment: 0.0,
      duration: const Duration(milliseconds: 300),
    );
    _triggerHighlight(messageId);
  }

  /// Wait for the animated list to be fully laid out, then scroll to message.
  /// Hides the shimmer overlay once the scroll succeeds.
  void _scrollToMessageAfterLayout(int messageId, [int framesWaited = 0]) {
    if (!mounted || framesWaited > 15) {
      // Give up — hide shimmer
      if (mounted) _isJumpingToMessage.value = false;
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final index = _animatedBloc.state.messages.indexWhere((m) => m.id == messageId);
      if (index == -1 || !_scrollController.hasClients) {
        _scrollToMessageAfterLayout(messageId, framesWaited + 1);
        return;
      }
      final success = await _animatedBloc.scrollToMessage(
        messageId,
        alignment: 0.0,
        duration: Duration.zero,
      );
      if (!success && mounted) {
        _scrollToMessageAfterLayout(messageId, framesWaited + 1);
      } else if (mounted) {
        // Scroll succeeded — hide shimmer and highlight the target message
        _isJumpingToMessage.value = false;
        _triggerHighlight(messageId);
      }
    });
  }

  /// Briefly highlight a message with a glow effect, then fade out.
  void _triggerHighlight(int messageId) {
    _highlightTimer?.cancel();
    _highlightedMessageId.value = messageId;
    _highlightTimer = Timer(const Duration(milliseconds: 1500), () {
      if (mounted) _highlightedMessageId.value = null;
    });
  }

  /// Get content view based on message type
  Widget? _getContentView(
    BaseMessage message,
    BuildContext context,
    Color? backgroundColor,
    BubbleAlignment alignment,
  ) {
    // Deleted messages always show the deleted bubble — return early to avoid
    // type-cast failures (SDK returns a plain BaseMessage after deletion).
    if (message.deletedAt != null) {
      return MessageTemplateUtils.getDeleteMessageBubble(
        message,
        context,
        widget.additionalConfigurations?.deletedBubbleStyle,
      );
    }

    final templateKey = '${message.category}_${message.type}';
    final template = _templateMap[templateKey];

    if (template?.contentView != null) {
      // Use provided additionalConfigurations, or build one from textFormatters
      // null = use defaults, empty list = no formatters
      AdditionalConfigurations? configurations = widget.additionalConfigurations;
      if (configurations == null) {
        final formatters = widget.textFormatters ??
            MessageTemplateUtils.getDefaultTextFormatters();
        if (formatters.isNotEmpty) {
          if (message is TextMessage) {
            for (final formatter in formatters) {
              formatter.message = message;
            }
          }
          configurations = AdditionalConfigurations(
            textFormatters: formatters,
            showMarkAsUnreadOption: widget.showMarkAsUnreadOption,
          );
        } else {
          configurations = AdditionalConfigurations(
            showMarkAsUnreadOption: widget.showMarkAsUnreadOption,
          );
        }
      }
      return template!.contentView!(message, context, alignment,
          additionalConfigurations: configurations);
    }

    // Default content views for common message types
    if (message is TextMessage) {
      return _buildTextContent(message, alignment);
    } else if (message is MediaMessage) {
      return _buildMediaContent(message, alignment);
    }

    return Text(
      '[${message.type}]',
      style: TextStyle(color: _colorPalette.textPrimary),
    );
  }

  /// Build text message content
  Widget _buildTextContent(TextMessage message, BubbleAlignment alignment) {
    final isOutgoing = alignment == BubbleAlignment.right;
    final outgoingStyle = _style.outgoingMessageBubbleStyle?.textBubbleStyle;
    final incomingStyle = _style.incomingMessageBubbleStyle?.textBubbleStyle;
    final textBubbleStyle = isOutgoing ? outgoingStyle : incomingStyle;

    return CometChatTextBubble(
      text: message.text,
      style: textBubbleStyle,
      alignment: alignment,
      formatters: FormatterUtils.ensureMarkdownFormatter(widget.textFormatters),
    );
  }

  /// Build media message content (image, video, file, audio)
  Widget _buildMediaContent(MediaMessage message, BubbleAlignment alignment) {
    switch (message.type) {
      case MessageTypeConstants.image:
        return CometChatImageBubble(
          imageUrl: message.attachment?.fileUrl,
          style: alignment == BubbleAlignment.right
              ? _style.outgoingMessageBubbleStyle?.imageBubbleStyle
              : _style.incomingMessageBubbleStyle?.imageBubbleStyle,
          metadata: message.metadata,
        );
      case MessageTypeConstants.video:
        return CometChatVideoBubble(
          videoUrl: message.attachment?.fileUrl,
          style: alignment == BubbleAlignment.right
              ? _style.outgoingMessageBubbleStyle?.videoBubbleStyle
              : _style.incomingMessageBubbleStyle?.videoBubbleStyle,
        );
      case MessageTypeConstants.file:
        return CometChatFileBubble(
          fileUrl: message.attachment?.fileUrl,
          title: message.attachment?.fileName,
          subtitle: message.attachment?.fileExtension,
          fileMimeType: message.attachment?.fileMimeType,
          id: message.id,
          fileExtension: message.attachment?.fileExtension,
          fileSize: message.attachment?.fileSize,
          dateTime: message.sentAt,
          metadata: message.metadata,
          alignment: alignment,
          style: alignment == BubbleAlignment.right
              ? _style.outgoingMessageBubbleStyle?.fileBubbleStyle
              : _style.incomingMessageBubbleStyle?.fileBubbleStyle,
        );
      case MessageTypeConstants.audio:
        return CometChatAudioBubbleV2(
          audioUrl: message.attachment?.fileUrl,
          title: message.attachment?.fileName,
          style: alignment == BubbleAlignment.right
              ? _style.outgoingMessageBubbleStyle?.audioBubbleStyle
              : _style.incomingMessageBubbleStyle?.audioBubbleStyle,
          alignment: alignment,
          id: message.id,
          metadata: message.metadata,
          colorPalette: _colorPalette,
          spacing: _spacing,
          typography: _typography,
        );
      default:
        return Text('[${message.type}]');
    }
  }

  /// Get footer view (reactions)
  Widget? _getFooterView(
    BaseMessage message,
    BubbleAlignment alignment,
    CometChatMessageBubbleStyleData? bubbleStyleData,
  ) {
    final templateKey = '${message.category}_${message.type}';
    final template = _templateMap[templateKey];

    if (template?.footerView != null) {
      return template!.footerView!(message, context, alignment);
    }

    // Show reactions if available
    if (widget.disableReactions != true && message.reactions.isNotEmpty) {
      return _getReactionsView(message, alignment);
    }

    return null;
  }

  /// Get reactions view
  Widget? _getReactionsView(BaseMessage message, BubbleAlignment alignment) {
    final isOutgoing = alignment == BubbleAlignment.right;
    final reactionsStyle = isOutgoing
        ? _style.outgoingMessageBubbleStyle?.messageBubbleReactionStyle
        : _style.incomingMessageBubbleStyle?.messageBubbleReactionStyle;

    return Transform.translate(
      offset: const Offset(0, -5),
      child: CometChatReactions(
        reactionList: message.reactions,
        alignment: alignment,
        style: reactionsStyle ?? _style.reactionsStyle,
        onReactionTap: (reaction) {
          if (widget.onReactionClick != null) {
            widget.onReactionClick!(reaction, message);
          } else if (reaction != null) {
            // Default: toggle reaction (remove if already reacted, add if not)
            final reactedByMe = message.reactions.any(
              (r) => r.reaction == reaction && r.reactedByMe == true,
            );
            if (reactedByMe) {
              _messageListBloc.add(RemoveReaction(message: message, reaction: reaction));
            } else {
              _handleReactionTap(message, reaction);
            }
          }
        },
        onReactionLongPress: (reaction) {
          if (widget.onReactionLongPress != null) {
            widget.onReactionLongPress!(reaction, message);
          } else {
            _showReactionInfoSheet(message, reaction);
          }
        },
      ),
    );
  }

  /// Get status info view (timestamp, read receipts)
  Widget? _getStatusInfoView(
    BaseMessage message,
    BubbleAlignment alignment,
    CometChatMessageBubbleStyleData? bubbleStyleData,
  ) {
    final templateKey = '${message.category}_${message.type}';
    final template = _templateMap[templateKey];

    if (template?.statusInfoView != null) {
      return template!.statusInfoView!(message, context, alignment);
    }

    if (widget.hideTimestamp == true && widget.receiptsVisibility != true) {
      return null;
    }

    final isOutgoing = alignment == BubbleAlignment.right;
    final dateStyle = bubbleStyleData?.messageBubbleDateStyle;
    final dateColor = _getDateColor(message, isOutgoing);

    // Build status info items
    final List<Widget> statusItems = [];
    
    // Show "Edited" label for edited text messages
    if (message.editedAt != null &&
        message.category == MessageCategoryConstants.message &&
        message.type == MessageTypeConstants.text) {
      if (statusItems.isNotEmpty) {
        statusItems.add(SizedBox(width: _spacing.padding1 ?? 4));
      }
      statusItems.add(
        Flexible(
          child: Text(
            Translations.of(context).edited,
            style: TextStyle(
              color: dateColor,
              fontSize: _typography.caption2?.regular?.fontSize,
              fontWeight: _typography.caption2?.regular?.fontWeight,
              fontFamily: _typography.caption2?.regular?.fontFamily,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );
    }
    
    if (widget.hideTimestamp != true && message.sentAt != null) {
      if (statusItems.isNotEmpty) {
        statusItems.add(SizedBox(width: _spacing.padding1 ?? 4));
      }
      statusItems.add(
        Text(
          _formatTime(message.sentAt!),
          style: TextStyle(
            fontSize: _typography.caption2?.regular?.fontSize ?? 10,
            color: dateStyle?.textStyle?.color ?? dateColor,
            fontWeight: _typography.caption2?.regular?.fontWeight,
          ),
        ),
      );
    }
    
    if (isOutgoing && widget.receiptsVisibility == true) {
      if (statusItems.isNotEmpty) {
        statusItems.add(SizedBox(width: _spacing.padding1 ?? 4));
      }
      statusItems.add(
        _getReceiptIcon(message, bubbleStyleData),
      );
    }

    if (statusItems.isEmpty) return null;

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: statusItems,
    );
  }

  /// Get date color based on message alignment and type
  Color? _getDateColor(BaseMessage message, bool isOutgoing) {
    // Stickers with a reply have a solid background — use normal date colors
    // Stickers without a reply have transparent background — use neutral color
    if (message.category == MessageCategoryConstants.custom &&
        message.type == ExtensionType.sticker &&
        message.quotedMessage == null) {
      return _colorPalette.neutral600;
    }
    if (isOutgoing) {
      return _colorPalette.white;
    } else {
      return _colorPalette.neutral600;
    }
  }

  /// Get receipt icon based on message status
  /// Uses ValueListenableBuilder for isolated rebuilds when receipt status changes
  Widget _getReceiptIcon(BaseMessage message, CometChatMessageBubbleStyleData? bubbleStyleData) {
    return ValueListenableBuilder<MessageReceiptStatus>(
      valueListenable: _messageListBloc.getReceiptNotifierForMessage(message),
      builder: (context, notifierStatus, child) {
        final ReceiptStatus status;
        switch (notifierStatus) {
          case MessageReceiptStatus.sending:
            status = ReceiptStatus.waiting;
            break;
          case MessageReceiptStatus.sent:
            status = ReceiptStatus.sent;
            break;
          case MessageReceiptStatus.delivered:
            status = ReceiptStatus.delivered;
            break;
          case MessageReceiptStatus.read:
            status = ReceiptStatus.read;
            break;
          case MessageReceiptStatus.error:
            status = ReceiptStatus.error;
            break;
        }
        return CometChatReceipt(
          status: status,
          size: 16,
          style: bubbleStyleData?.messageReceiptStyle,
          deliveredIcon: widget.deliveredIcon,
          readIcon: widget.readIcon,
          sentIcon: widget.sentIcon,
          waitIcon: widget.waitIcon,
        );
      },
    );
  }

  /// Get thread view for replies
  Widget? _getThreadView(
    BaseMessage message,
    BubbleAlignment alignment,
    CometChatMessageBubbleStyleData? bubbleStyleData,
  ) {
    // Seed the notifier with the model's current count so it has the right
    // baseline before any live increments arrive.
    if (message.replyCount > 0) {
      _messageListBloc.initializeThreadReplyCount(
          message.id, message.replyCount);
    }

    final notifier =
        _messageListBloc.getThreadReplyCountNotifier(message.id);

    // Thread view sits OUTSIDE the bubble background (below it), so it renders
    // against the chat screen background — not the bubble color.  Use primary
    // for both incoming and outgoing so the text/icon is always visible.
    final iconColor = bubbleStyleData?.threadedMessageIndicatorIconColor ??
        _colorPalette.primary;
    final textStyle = bubbleStyleData?.threadedMessageIndicatorTextStyle ??
        TextStyle(
          fontSize: _typography.caption1?.medium?.fontSize,
          color: _colorPalette.primary,
          fontWeight: _typography.caption1?.medium?.fontWeight,
        );

    // Always return a ValueListenableBuilder so that when the reply count
    // goes from 0 → 1 the widget is already mounted and can react.
    return ValueListenableBuilder<int>(
      valueListenable: notifier,
      builder: (context, replyCount, _) {
        if (replyCount == 0) return const SizedBox.shrink();
        return GestureDetector(
          onTap: () {
            if (widget.onThreadRepliesClick != null) {
              widget.onThreadRepliesClick!(message, context,
                  template: _templateMap[
                      '${message.category}_${message.type}']);
            }
          },
          child: Padding(
            padding: EdgeInsets.only(top: _spacing.padding2 ?? 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.subdirectory_arrow_right,
                    size: 16, color: iconColor),
                SizedBox(width: _spacing.padding1 ?? 4),
                Text(
                  '$replyCount ${replyCount == 1 ? Translations.of(context).reply : Translations.of(context).replies}',
                  style: textStyle,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Format timestamp
  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'pm' : 'am';
    final hour12 = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$hour12:$minute $period';
  }

  /// Show message action overlay on long press
  Future<void> _showMessageActions(
    BaseMessage message,
    Widget bubbleWidget,
    BubbleAlignment alignment,
    String? heroTag,
    Size? bubbleSize,
  ) async {
    // Don't show actions for deleted messages
    if (message.deletedAt != null) return;

    // Unfocus the current focus (e.g. composer text field) before pushing the overlay.
    // This prevents Flutter from restoring focus to the text field when the overlay
    // is dismissed, which would cause the keyboard to open unexpectedly.
    FocusManager.instance.primaryFocus?.unfocus();

    // Get action items from template
    final templateKey = '${message.category}_${message.type}';
    final template = _templateMap[templateKey];
    
    List<ActionItem> actionItems = [];
    if (template?.options != null) {
      final loggedInUser = _messageListBloc.state.loggedInUser;
      if (loggedInUser != null) {
        // Build AdditionalConfigurations with showMarkAsUnreadOption if not provided externally
        final configurations = widget.additionalConfigurations ??
            AdditionalConfigurations(
              showMarkAsUnreadOption: widget.showMarkAsUnreadOption,
              hideCopyMessageOption: widget.hideCopyMessageOption,
              hideDeleteMessageOption: widget.hideDeleteMessageOption,
              hideEditMessageOption: widget.hideEditMessageOption,
              hideMessageInfoOption: widget.hideMessageInfoOption,
              hideMessagePrivatelyOption: widget.hideMessagePrivatelyOption,
              hideReplyInThreadOption: widget.hideReplyInThreadOption,
              hideShareMessageOption: widget.hideShareMessageOption,
              hideReactionOption: widget.hideReactionOption,
              hideTranslateMessageOption: widget.hideTranslateMessageOption,
            );
        final options = template!.options!(
          loggedInUser,
          message,
          context,
          widget.group,
          configurations,
        );
        // Convert CometChatMessageOption to ActionItem and filter
        actionItems = _filterAndConvertOptions(options, message);
      }
    }

    final result = await showMessageActionOverlay(
      context: context,
      message: message,
      bubbleWidget: bubbleWidget,
      actionItems: actionItems,
      bubbleAlignment: alignment,
      heroTag: heroTag,
      bubbleSize: bubbleSize,
      favoriteReactions: widget.favoriteReactions,
      hideReactions: widget.disableReactions == true || widget.hideReactionOption == true,
      onReactionTap: (msg, reaction) {
        _handleReactionTap(msg, reaction);
      },
      onAddReactionTap: (msg) {
        if (widget.addMoreReactionTap != null) {
          widget.addMoreReactionTap!(msg);
        }
      },
      addReactionIcon: widget.addReactionIcon,
    );

    if (result != null && result.onItemClick != null) {
      debugPrint('[MessageList] _showMessageActions: result received, id=${result.id}');
      // Wait for Hero animation to complete and UI to settle before executing action
      // This prevents issues when navigating to thread screen
      // Only delay if Hero animation was used (heroTag was provided)
      if (heroTag != null) {
        await Future.delayed(const Duration(milliseconds: 300));
        // Ensure the frame is rendered before proceeding
        await WidgetsBinding.instance.endOfFrame;
      }
      if (mounted) {
        result.onItemClick();
      }
    } else {
      debugPrint('[MessageList] _showMessageActions: result is null or onItemClick is null');
    }
  }

  /// Filter and convert CometChatMessageOption to ActionItem based on widget configuration
  List<ActionItem> _filterAndConvertOptions(List<CometChatMessageOption>? options, BaseMessage message) {
    if (options == null) return [];
    
    debugPrint('[MessageList] _filterAndConvertOptions: options count=${options.length}');
    for (final opt in options) {
      debugPrint('[MessageList] Option: id=${opt.id}, title=${opt.title}');
    }
    
    final filtered = options.where((option) {
      switch (option.id) {
        case MessageOptionConstants.copyMessage:
          return widget.hideCopyMessageOption != true;
        case MessageOptionConstants.deleteMessage:
          return widget.hideDeleteMessageOption != true;
        case MessageOptionConstants.editMessage:
          return widget.hideEditMessageOption != true;
        case MessageOptionConstants.messageInformation:
          return widget.hideMessageInfoOption != true;
        case MessageOptionConstants.sendMessagePrivately:
          return widget.hideMessagePrivatelyOption != true;
        case MessageOptionConstants.replyInThreadMessage:
          debugPrint('[MessageList] replyInThreadMessage filter: hideReplyInThreadOption=${widget.hideReplyInThreadOption}');
          return widget.hideReplyInThreadOption != true;
        case MessageOptionConstants.shareMessage:
          return widget.hideShareMessageOption != true;
        case MessageOptionConstants.markAsUnread:
          return widget.showMarkAsUnreadOption == true;
        default:
          return true;
      }
    }).toList();
    
    debugPrint('[MessageList] Filtered options count=${filtered.length}');
    
    return filtered.map((option) {
      // Create ActionItem with no-argument onItemClick (since ActionItem.onItemClick is called without args)
      return ActionItem(
        id: option.id,
        title: option.title,
        icon: option.icon,
        style: CometChatAttachmentOptionSheetStyle(
          titleTextStyle: option.messageOptionSheetStyle?.titleTextStyle,
          iconColor: option.messageOptionSheetStyle?.iconColor,
          backgroundColor: option.messageOptionSheetStyle?.backgroundColor,
          border: option.messageOptionSheetStyle?.border,
          borderRadius: option.messageOptionSheetStyle?.borderRadius,
          titleColor: option.messageOptionSheetStyle?.titleColor,
        ),
        onItemClick: () {
          debugPrint('[MessageList] Option clicked: ${option.id}');
          // Handle reply in thread option specially
          if (option.id == MessageOptionConstants.replyInThreadMessage) {
            debugPrint('[MessageList] Reply in thread clicked, onThreadRepliesClick: ${widget.onThreadRepliesClick != null}, mounted: $mounted');
            if (widget.onThreadRepliesClick != null && mounted) {
              final templateKey = '${message.category}_${message.type}';
              debugPrint('[MessageList] Navigating to thread with templateKey: $templateKey');
              widget.onThreadRepliesClick!(message, context, template: _templateMap[templateKey]);
            } else {
              debugPrint('[MessageList] Cannot navigate: onThreadRepliesClick=${widget.onThreadRepliesClick != null}, mounted=$mounted');
            }
            return;
          }
          
          // Handle copy message option
          if (option.id == MessageOptionConstants.copyMessage) {
            _handleCopyMessage(message);
            return;
          }
          
          // Handle share message option
          if (option.id == MessageOptionConstants.shareMessage) {
            _handleShareMessage(message);
            return;
          }
          
          // Handle mark as unread option
          if (option.id == MessageOptionConstants.markAsUnread) {
            _blocAdapter.markMessageAsUnread(message);
            return;
          }
          
          // Handle edit message option
          if (option.id == MessageOptionConstants.editMessage) {
            // Fire the edit event with the message - composer listens to this
            CometChatMessageEvents.ccMessageEdited(message, MessageEditStatus.inProgress);
            return;
          }

          // Handle delete message option
          if (option.id == MessageOptionConstants.deleteMessage) {
            _handleDeleteMessage(message);
            return;
          }

          // Handle message information option
          if (option.id == MessageOptionConstants.messageInformation) {
            _handleMessageInformation(message);
            return;
          }
          
          if (option.onItemClick != null) {
            option.onItemClick!(message, _blocAdapter);
          }
        },
      );
    }).toList();
  }

  /// Handle copy message action
  void _handleCopyMessage(BaseMessage message) {
    String textToCopy = '';
    if (message is TextMessage) {
      textToCopy = message.text;
    }
    if (textToCopy.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: textToCopy));
      // Show a snackbar to confirm copy
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(Translations.of(context).copyText),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  /// Handle share message action
  void _handleShareMessage(BaseMessage message) {
    String textToShare = '';
    String? fileUrl;
    String? mimeType;
    String? mediaName;
    
    if (message is TextMessage) {
      textToShare = message.text;
    } else if (message is MediaMessage) {
      fileUrl = message.attachment?.fileUrl;
      mimeType = message.attachment?.fileMimeType;
      mediaName = message.attachment?.fileName;
    }
    
    // Use platform share functionality via MethodChannel
    const channel = MethodChannel('cometchat_chat_uikit');
    try {
      if (message is TextMessage && textToShare.isNotEmpty) {
        channel.invokeMethod('shareMessage', {
          'type': 'text',
          'message': textToShare,
        });
      } else if (message is MediaMessage && fileUrl != null) {
        channel.invokeMethod('shareMessage', {
          'type': 'media',
          'fileUrl': fileUrl,
          'mimeType': mimeType ?? 'application/octet-stream',
          'mediaName': mediaName ?? 'media',
        });
      }
    } catch (e) {
      debugPrint('[MessageList] Share failed: $e');
    }
  }

  /// Handle delete message action with confirmation dialog
  void _handleDeleteMessage(BaseMessage message) {
    if (!mounted) return;

    CometChatConfirmDialog(
      context: context,
      icon: Icon(
        Icons.delete_outline,
        color: _colorPalette.error,
        size: 48,
      ),
      title: Text(
        Translations.of(context).delete,
        textAlign: TextAlign.center,
      ),
      messageText: Text(
        Translations.of(context).deleteMessageWarning,
        textAlign: TextAlign.center,
      ),
      confirmButtonText: Translations.of(context).delete,
      cancelButtonText: Translations.of(context).cancel,
      style: CometChatConfirmDialogStyle(
        confirmButtonBackground: _colorPalette.error,
        confirmButtonTextColor: _colorPalette.white,
      ),
      onConfirm: () {
        Navigator.of(context).pop();
        CometChat.deleteMessage(
          message.id,
          onSuccess: (updatedMessage) {
            // The API returns an action message (different ID, category=action)
            // instead of the original message. Use the original message object
            // and just stamp deletedAt on it so the BLoC can find it by ID
            // and the bubble type is preserved.
            message.deletedAt = updatedMessage.deletedAt ?? DateTime.now();
            message.deletedBy = updatedMessage.deletedBy;
            CometChatMessageEvents.ccMessageDeleted(
              message,
              EventStatus.success,
            );
          },
          onError: (error) {
            debugPrint('[MessageList] Delete failed: $error');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: _colorPalette.error,
                  content: Text(
                    Translations.of(context).somethingWentWrongError,
                  ),
                ),
              );
            }
          },
        );
      },
    ).show();
  }

  /// Handle message information option
  void _handleMessageInformation(BaseMessage message) {
    if (!mounted) return;
    final templateKey = '${message.category}_${message.type}';
    final template = _templateMap[templateKey];
    showMessageInformation(
      context: context,
      message: message,
      template: template,
      messageInformationStyle: _style.messageInformationStyle,
      textFormatters: widget.textFormatters,
    );
  }

  /// Show reaction info bottom sheet with participant details
  void _showReactionInfoSheet(BaseMessage message, String? selectedReaction) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return CometChatReactionList(
          message: message,
          selectedReaction: selectedReaction,
          reactionRequestBuilder: widget.reactionsRequestBuilder,
          onReactionListItemClick: widget.onReactionListItemClick,
        );
      },
    );
  }

  /// Handle reaction tap
  void _handleReactionTap(BaseMessage message, String reaction) {
    _messageListBloc.add(AddReaction(message: message, reaction: reaction));
  }
}
