import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// Hide the legacy CometChatMessageListStyle to avoid naming conflict
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart' hide CometChatMessageListStyle;

import '../cometchat_message_list_style.dart';
import 'cometchat_new_message_indicator.dart';

// Re-export MessageItemBuilder from animated message list for convenience
// (it's already defined there, so we don't duplicate it)

/// Builder function for header and footer views
typedef HeaderFooterBuilder = Widget? Function(BuildContext context);

/// Builder function for state views (empty, error, loading)
typedef StateViewBuilder = Widget Function(BuildContext context);

/// [CometChatMessageList] is a widget that displays a list of messages
/// using Clean Architecture with BLoC pattern.
///
/// This widget integrates with [MessageListBloc] for state management and
/// [CometChatAnimatedMessageList] for smooth animations.
///
/// ## Features
/// - Accepts a [MessageListBloc] via BlocProvider or creates one internally
/// - Supports custom message item builders
/// - Supports custom header and footer views
/// - Supports custom state views (empty, error, loading)
/// - Integrates with [CometChatAnimatedMessageList] for animations
/// - Supports pagination (older/newer messages)
/// - Supports scroll-to-bottom functionality
///
/// ## Example
/// ```dart
/// CometChatMessageList(
///   user: targetUser,
///   messageItemBuilder: (context, message, index, animation) {
///     return MessageBubble(message: message);
///   },
///   emptyStateView: (context) => Text('No messages yet'),
/// )
/// ```
///
/// **Validates: Requirements 13.1, 13.2, 13.3, 13.4, 13.5**
class CometChatMessageList extends StatefulWidget {
  const CometChatMessageList({
    super.key,
    this.user,
    this.group,
    this.messageListBloc,
    this.messageItemBuilder,
    this.headerView,
    this.footerView,
    this.emptyStateView,
    this.errorStateView,
    this.loadingStateView,
    this.style,
    this.scrollController,
    this.parentMessageId,
    this.types,
    this.categories,
    this.hideDeletedMessages = false,
    this.disableSoundForMessages = false,
    this.disableReceipts = false,
    this.hideReplies = true,
    this.reversed = true,
    this.insertAnimationDuration = const Duration(milliseconds: 250),
    this.removeAnimationDuration = const Duration(milliseconds: 250),
    this.scrollToEndAnimationDuration = const Duration(milliseconds: 250),
    this.scrollToBottomAppearanceDelay = const Duration(milliseconds: 250),
    this.scrollToBottomAppearanceThreshold = 0,
    this.olderPaginationThreshold = 0.01,
    this.newerPaginationThreshold = 0.8,
    this.shouldScrollToEndWhenSendingMessage = true,
    this.shouldScrollToEndWhenAtBottom = true,
    this.initialScrollToEndMode = InitialScrollToEndMode.jump,
    this.topPadding = 8,
    this.bottomPadding = 20,
    this.handleSafeArea = true,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.onDrag,
    this.physics,
    this.composerHeightNotifier,
    this.loadMoreBuilder,
    this.scrollToBottomBuilder,
    this.onError,
    this.onLoad,
    this.onEmpty,
    this.showMarkAsUnreadOption = false,
    this.startFromUnreadMessages = false,
    this.newMessageIndicatorView,
  });

  // ============================================================
  // CONVERSATION TARGET
  // ============================================================

  /// Target user for 1-on-1 conversation (mutually exclusive with [group])
  final User? user;

  /// Target group for group conversation (mutually exclusive with [user])
  final Group? group;

  // ============================================================
  // BLOC
  // ============================================================

  /// Optional external [MessageListBloc] instance.
  /// 
  /// If provided, this bloc will be used instead of creating a new one internally.
  /// This allows for custom bloc implementations with overridden hooks.
  /// 
  /// When providing an external bloc, you are responsible for:
  /// - Initializing the bloc with proper configuration
  /// - Closing the bloc when no longer needed
  final MessageListBloc? messageListBloc;

  // ============================================================
  // CUSTOM VIEW SLOTS
  // ============================================================

  /// Custom builder for message items.
  /// 
  /// If provided, this builder will be used to create widgets for each message.
  /// If not provided, a default message bubble will be used.
  /// 
  /// **Validates: Requirements 13.1**
  final MessageItemBuilder? messageItemBuilder;

  /// Custom header view displayed above the message list.
  /// 
  /// **Validates: Requirements 13.2**
  final HeaderFooterBuilder? headerView;

  /// Custom footer view displayed below the message list.
  /// 
  /// **Validates: Requirements 13.2**
  final HeaderFooterBuilder? footerView;

  // ============================================================
  // STATE VIEWS
  // ============================================================

  /// Custom view for empty state (no messages).
  /// 
  /// If not provided, a default empty state view will be shown.
  /// 
  /// **Validates: Requirements 13.3**
  final StateViewBuilder? emptyStateView;

  /// Custom view for error state.
  /// 
  /// If not provided, a default error state view will be shown.
  /// 
  /// **Validates: Requirements 13.4**
  final StateViewBuilder? errorStateView;

  /// Custom view for loading state.
  /// 
  /// If not provided, a default loading indicator will be shown.
  /// 
  /// **Validates: Requirements 13.5**
  final StateViewBuilder? loadingStateView;

  // ============================================================
  // STYLING
  // ============================================================

  /// Style configuration for the message list.
  final CometChatMessageListStyle? style;

  // ============================================================
  // SCROLL CONFIGURATION
  // ============================================================

  /// Optional scroll controller for the message list.
  final ScrollController? scrollController;

  /// Whether the list is reversed (newest at bottom, grows upward).
  final bool reversed;

  /// Scroll physics for the list.
  final ScrollPhysics? physics;

  /// Keyboard dismiss behavior.
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;

  /// Whether to handle safe area.
  final bool handleSafeArea;

  /// Padding at the top of the list.
  final double? topPadding;

  /// Padding at the bottom of the list.
  final double? bottomPadding;

  // ============================================================
  // ANIMATION CONFIGURATION
  // ============================================================

  /// Duration for message insertion animations.
  final Duration insertAnimationDuration;

  /// Duration for message removal animations.
  final Duration removeAnimationDuration;

  /// Duration for scrolling to the end.
  final Duration scrollToEndAnimationDuration;

  /// Delay before scroll-to-bottom button appears.
  final Duration scrollToBottomAppearanceDelay;

  /// Threshold for scroll-to-bottom button appearance.
  final double scrollToBottomAppearanceThreshold;

  /// Initial scroll behavior.
  final InitialScrollToEndMode initialScrollToEndMode;

  // ============================================================
  // PAGINATION CONFIGURATION
  // ============================================================

  /// Threshold for triggering older message pagination (0.0 to 1.0).
  final double olderPaginationThreshold;

  /// Threshold for triggering newer message pagination (0.0 to 1.0).
  final double newerPaginationThreshold;

  // ============================================================
  // SCROLL BEHAVIOR
  // ============================================================

  /// Whether to scroll to end when sending a message.
  final bool shouldScrollToEndWhenSendingMessage;

  /// Whether to scroll to end when at bottom and new message arrives.
  final bool shouldScrollToEndWhenAtBottom;

  // ============================================================
  // MESSAGE CONFIGURATION
  // ============================================================

  /// Parent message ID for thread replies (null for main conversation).
  final int? parentMessageId;

  /// Message types to include (null means all types).
  final List<String>? types;

  /// Message categories to include (null means all categories).
  final List<String>? categories;

  /// Whether to hide deleted messages.
  final bool hideDeletedMessages;

  /// Whether to disable sound for incoming messages.
  final bool disableSoundForMessages;

  /// Whether to disable read/delivery receipts.
  final bool disableReceipts;

  /// Whether to hide thread replies in main conversation.
  final bool hideReplies;

  // ============================================================
  // CUSTOM BUILDERS
  // ============================================================

  /// Custom builder for load more indicator.
  final LoadMoreBuilder? loadMoreBuilder;

  /// Custom builder for scroll-to-bottom button.
  final ScrollToBottomBuilder? scrollToBottomBuilder;

  /// Notifier for composer height changes.
  final ComposerHeightNotifier? composerHeightNotifier;

  // ============================================================
  // CALLBACKS
  // ============================================================

  /// Callback when an error occurs.
  final void Function(CometChatException)? onError;

  /// Callback when messages are loaded.
  final void Function(List<BaseMessage>)? onLoad;

  /// Callback when the message list is empty.
  final VoidCallback? onEmpty;

  // ============================================================
  // MARK AS UNREAD CONFIGURATION
  // ============================================================

  /// Shows the "Mark as Unread" option in the long-press message options sheet.
  /// Default: false
  final bool showMarkAsUnreadOption;

  /// When true, the message list scrolls to the first unread message on open.
  /// Default: false
  final bool startFromUnreadMessages;

  /// Optional custom widget for the unread separator.
  /// If not provided, the default [CometChatNewMessageIndicator] is used.
  final WidgetBuilder? newMessageIndicatorView;

  @override
  State<CometChatMessageList> createState() => _CometChatMessageListState();
}

class _CometChatMessageListState extends State<CometChatMessageList> {
  /// BLoC for managing message list state
  late MessageListBloc _messageListBloc;

  /// AnimatedMessageListBloc for animation support
  late AnimatedMessageListBloc _animatedBloc;

  /// Track if bloc is external (should not be closed by this widget)
  bool _isExternalBloc = false;

  /// Style configuration
  late CometChatMessageListStyle _style;

  /// Theme helpers
  late CometChatColorPalette _colorPalette;
  late CometChatTypography _typography;
  late CometChatSpacing _spacing;
  
  /// Cached width to avoid MediaQuery in build()
  double _cachedMaxBubbleWidth = 300;
  bool _themeInitialized = false;
  
  /// Track brightness to detect theme changes
  Brightness? _cachedBrightness;

  /// Subscription to MessageListBloc operations stream
  /// Used to forward operations to AnimatedMessageListBloc
  /// **Validates: Requirements 10.6**
  StreamSubscription<MessageOperation>? _operationsSubscription;

  @override
  void initState() {
    super.initState();
    _initializeBlocs();
    _subscribeToOperations();
    _loadMessages();
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
      _themeInitialized = true;
      _initializeTheme();
    }
  }

  /// Initialize theme helpers and style
  void _initializeTheme() {
    _colorPalette = CometChatThemeHelper.getColorPalette(context);
    _typography = CometChatThemeHelper.getTypography(context);
    _spacing = CometChatThemeHelper.getSpacing(context);
    _style = CometChatThemeHelper.getTheme<CometChatMessageListStyle>(
      context: context,
      defaultTheme: CometChatMessageListStyle.of,
    ).merge(widget.style);
    
    // Cache width to avoid MediaQuery in build()
    _cachedMaxBubbleWidth = MediaQuery.sizeOf(context).width * 0.75;
  }

  /// Initialize BLoCs
  void _initializeBlocs() {
    // Use external bloc if provided, otherwise create a new one
    if (widget.messageListBloc != null) {
      _messageListBloc = widget.messageListBloc!;
      _isExternalBloc = true;
    } else {
      // Initialize service locator if not already initialized
      if (!MessageListServiceLocator.instance.isInitialized) {
        MessageListServiceLocator.instance.setup();
      }

      // Create BLoC with configuration
      _messageListBloc = MessageListBloc(
        user: widget.user,
        group: widget.group,
        parentMessageId: widget.parentMessageId,
        types: widget.types,
        categories: widget.categories,
        hideDeletedMessages: widget.hideDeletedMessages,
        disableSoundForMessages: widget.disableSoundForMessages,
        disableReceipts: widget.disableReceipts,
        hideReplies: widget.hideReplies,
      );
      _isExternalBloc = false;
    }

    // Create animated bloc for animation support
    _animatedBloc = AnimatedMessageListBloc();
  }

  /// Load initial messages
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
          parentMessageId: widget.parentMessageId,
          types: widget.types,
          categories: widget.categories,
        ));
      }
    }
  }

  /// Subscribe to MessageListBloc operations stream and forward to AnimatedMessageListBloc
  /// 
  /// This bridges the gap between the Clean Architecture MessageListBloc and the
  /// AnimatedMessageListBloc that handles list animations.
  /// 
  /// **Validates: Requirements 10.6**
  void _subscribeToOperations() {
    _operationsSubscription = _messageListBloc.operationsStream.listen((operation) {
      // Forward operations to AnimatedMessageListBloc based on operation type
      switch (operation.type) {
        case MessageOperationType.insert:
          if (operation.message != null) {
            _animatedBloc.add(InsertMessage(
              operation.message!,
              index: operation.index,
              animated: operation.animated,
            ));
          }
          break;
        case MessageOperationType.insertAll:
          if (operation.messages != null && operation.messages!.isNotEmpty) {
            _animatedBloc.add(InsertAllMessages(
              operation.messages!,
              index: operation.index,
              animated: operation.animated,
            ));
          }
          break;
        case MessageOperationType.update:
          if (operation.message != null && operation.oldMessage != null) {
            _animatedBloc.add(UpdateMessage(
              operation.oldMessage!,
              operation.message!,
            ));
          }
          break;
        case MessageOperationType.remove:
          if (operation.message != null) {
            _animatedBloc.add(RemoveMessage(
              operation.message!,
              animated: operation.animated,
            ));
          }
          break;
        case MessageOperationType.set:
          if (operation.messages != null) {
            _animatedBloc.add(SetMessages(
              operation.messages!,
              animated: operation.animated,
            ));
          }
          break;
      }
    });
  }

  @override
  void dispose() {
    // Cancel operations subscription
    _operationsSubscription?.cancel();
    
    // Clear all audio states and release memory
    AudioStateManager().clearAll();
    
    // Only close the bloc if we created it internally
    if (!_isExternalBloc) {
      _messageListBloc.close();
    }
    _animatedBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MessageListBloc>.value(
      value: _messageListBloc,
      child: Container(
        decoration: BoxDecoration(
          color: _style.backgroundColor ?? _colorPalette.background1,
          border: _style.border,
          borderRadius: _style.borderRadius,
        ),
        child: Column(
          children: [
            // Header view
            if (widget.headerView != null)
              widget.headerView!(context) ?? const SizedBox.shrink(),

            // Message list content
            Expanded(
              child: BlocConsumer<MessageListBloc, MessageListState>(
                buildWhen: (previous, current) =>
                    previous.status != current.status,
                listener: _handleStateChanges,
                builder: (context, state) {
                  return _buildContent(context, state);
                },
              ),
            ),

            // Footer view
            if (widget.footerView != null)
              widget.footerView!(context) ?? const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  /// Handle state changes for callbacks
  void _handleStateChanges(BuildContext context, MessageListState state) {
    // Handle error callback
    if (state.status == MessageListStatus.error && widget.onError != null) {
      widget.onError!(CometChatException(
        'MESSAGE_LIST_ERROR',
        state.errorMessage ?? 'An error occurred',
        state.errorMessage ?? 'An error occurred',
      ));
    }

    // Handle load callback
    if (state.status == MessageListStatus.loaded && widget.onLoad != null) {
      widget.onLoad!(state.messages);
    }

    // Handle empty callback
    if (state.status == MessageListStatus.empty && widget.onEmpty != null) {
      widget.onEmpty!();
    }
  }

  /// Build content based on state
  Widget _buildContent(BuildContext context, MessageListState state) {
    switch (state.status) {
      case MessageListStatus.initial:
      case MessageListStatus.loading:
        return _buildLoadingState(context);

      case MessageListStatus.empty:
        return _buildEmptyState(context);

      case MessageListStatus.error:
        return _buildErrorState(context, state.errorMessage);

      case MessageListStatus.loaded:
        return _buildMessageList(context, state);
    }
  }

  /// Build loading state view
  /// 
  /// **Validates: Requirements 13.5**
  Widget _buildLoadingState(BuildContext context) {
    if (widget.loadingStateView != null) {
      return widget.loadingStateView!(context);
    }

    return Center(
      child: CircularProgressIndicator(
        color: _colorPalette.primary,
      ),
    );
  }

  /// Build empty state view
  /// 
  /// **Validates: Requirements 13.3**
  Widget _buildEmptyState(BuildContext context) {
    if (widget.emptyStateView != null) {
      return widget.emptyStateView!(context);
    }

    return EmptyMessageList(
      text: Translations.of(context).noMessagesFound,
      textStyle: TextStyle(
        color: _style.emptyStateTextColor ?? _colorPalette.textSecondary,
        fontSize: _typography.body?.regular?.fontSize,
        fontWeight: _typography.body?.regular?.fontWeight,
      ).merge(_style.emptyStateTextStyle),
      icon: Icons.chat_bubble_outline,
      iconColor: _style.emptyStateTextColor ?? _colorPalette.textSecondary,
    );
  }

  /// Build error state view
  /// 
  /// **Validates: Requirements 13.4**
  Widget _buildErrorState(BuildContext context, String? errorMessage) {
    if (widget.errorStateView != null) {
      return widget.errorStateView!(context);
    }

    return Center(
      child: Padding(
        padding: EdgeInsets.all(_spacing.padding4 ?? 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: _style.errorStateTextColor ?? _colorPalette.error,
            ),
            SizedBox(height: _spacing.padding3 ?? 12),
            Text(
              Translations.of(context).somethingWentWrongError,
              style: TextStyle(
                color: _style.errorStateTextColor ?? _colorPalette.textPrimary,
                fontSize: _typography.heading4?.medium?.fontSize,
                fontWeight: _typography.heading4?.medium?.fontWeight,
              ).merge(_style.errorStateTextStyle),
              textAlign: TextAlign.center,
            ),
            if (errorMessage != null) ...[
              SizedBox(height: _spacing.padding2 ?? 8),
              Text(
                errorMessage,
                style: TextStyle(
                  color: _style.errorStateSubtitleColor ?? _colorPalette.textSecondary,
                  fontSize: _typography.body?.regular?.fontSize,
                  fontWeight: _typography.body?.regular?.fontWeight,
                ).merge(_style.errorStateSubtitleStyle),
                textAlign: TextAlign.center,
              ),
            ],
            SizedBox(height: _spacing.padding4 ?? 16),
            ElevatedButton(
              onPressed: _loadMessages,
              style: ElevatedButton.styleFrom(
                backgroundColor: _colorPalette.primary,
                foregroundColor: _colorPalette.white,
              ),
              child: Text(Translations.of(context).tryAgain),
            ),
          ],
        ),
      ),
    );
  }

  /// Compute the display count for the unread badge per feature doc Section 2.3
  int _computeUnreadBadgeCount(MessageListState s) {
    if (s.markedAsUnreadInSession) {
      return s.unreadCount + s.newUnreadMessageCount;
    } else if (s.newUnreadMessageCount > 0) {
      return s.newUnreadMessageCount;
    }
    return s.unreadCount;
  }

  /// Build message list with animated list
  Widget _buildMessageList(BuildContext context, MessageListState state) {
    return CometChatAnimatedMessageList(
      bloc: _animatedBloc,
      itemBuilder: _buildMessageItem,
      scrollController: widget.scrollController,
      reversed: widget.reversed,
      insertAnimationDuration: widget.insertAnimationDuration,
      removeAnimationDuration: widget.removeAnimationDuration,
      scrollToEndAnimationDuration: widget.scrollToEndAnimationDuration,
      scrollToBottomAppearanceDelay: widget.scrollToBottomAppearanceDelay,
      scrollToBottomAppearanceThreshold: widget.scrollToBottomAppearanceThreshold,
      olderPaginationThreshold: widget.olderPaginationThreshold,
      newerPaginationThreshold: widget.newerPaginationThreshold,
      shouldScrollToEndWhenSendingMessage: widget.shouldScrollToEndWhenSendingMessage,
      shouldScrollToEndWhenAtBottom: widget.shouldScrollToEndWhenAtBottom,
      initialScrollToEndMode: widget.initialScrollToEndMode,
      topPadding: widget.topPadding,
      bottomPadding: widget.bottomPadding,
      handleSafeArea: widget.handleSafeArea,
      keyboardDismissBehavior: widget.keyboardDismissBehavior,
      physics: widget.physics,
      composerHeightNotifier: widget.composerHeightNotifier,
      loadMoreBuilder: widget.loadMoreBuilder,
      scrollToBottomBuilder: widget.scrollToBottomBuilder ?? _defaultScrollToBottomBuilder,
      loggedInUserId: state.loggedInUser?.uid,
      onLoadOlder: _handleLoadOlder,
      onLoadNewer: _handleLoadNewer,
      onScrollToBottomTap: _handleScrollToBottomTap,
      hasMoreNewer: state.hasMoreNewer,
    );
  }

  /// Default scroll-to-bottom builder that includes unread badge count.
  ///
  /// Uses [BlocSelector] to only rebuild when the badge count changes,
  /// avoiding unnecessary rebuilds during other state updates.
  Widget _defaultScrollToBottomBuilder(
    BuildContext context,
    Animation<double> animation,
    VoidCallback onPressed,
  ) {
    return BlocSelector<MessageListBloc, MessageListState, int>(
      selector: (state) => _computeUnreadBadgeCount(state),
      builder: (context, badgeCount) {
        return ScrollToBottomButton(
          animation: animation,
          onPressed: onPressed,
          unreadCount: badgeCount,
          badgeColor: _colorPalette.error,
          badgeTextColor: _colorPalette.white,
        );
      },
    );
  }

  /// Handle scroll-to-bottom tap: reset unread state and reload from latest.
  void _handleScrollToBottomTap() {
    _messageListBloc.add(const ResetUnreadState());

    final conversationWith = widget.user?.uid ?? widget.group?.guid;
    final conversationType = widget.user != null ? 'user' : 'group';

    if (conversationWith != null) {
      _messageListBloc.add(LoadMessages(
        conversationWith: conversationWith,
        conversationType: conversationType,
        parentMessageId: widget.parentMessageId,
        types: widget.types,
        categories: widget.categories,
      ));
    }
  }

  /// Build individual message item
  /// 
  /// **Validates: Requirements 13.1**
  Widget _buildMessageItem(
    BuildContext context,
    BaseMessage message,
    int index,
    Animation<double> animation,
  ) {
    // Use custom builder if provided
    if (widget.messageItemBuilder != null) {
      return RepaintBoundary(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _getNewMessageIndicator(message),
            widget.messageItemBuilder!(context, message, index, animation),
          ],
        ),
      );
    }

    // Default message item with RepaintBoundary to isolate repaints
    return RepaintBoundary(
      child: SizeTransition(
        sizeFactor: animation,
        child: FadeTransition(
          opacity: animation,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _getNewMessageIndicator(message),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: _spacing.padding3 ?? 12,
                  vertical: _spacing.padding1 ?? 4,
                ),
                child: _buildDefaultMessageBubble(context, message),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Returns the new message indicator widget if this message is the unread anchor.
  Widget _getNewMessageIndicator(BaseMessage message) {
    if (!widget.startFromUnreadMessages) return const SizedBox.shrink();

    final anchorId = _messageListBloc.state.unreadMessageAnchorId;
    if (anchorId == null || message.id != anchorId) {
      return const SizedBox.shrink();
    }

    if (widget.newMessageIndicatorView != null) {
      return widget.newMessageIndicatorView!(context);
    }

    return CometChatNewMessageIndicator(
      style: _style.newMessageIndicatorStyle,
      colorPalette: _colorPalette,
      typography: _typography,
      spacing: _spacing,
    );
  }

  /// Build default message bubble (placeholder)
  Widget _buildDefaultMessageBubble(BuildContext context, BaseMessage message) {
    final isOutgoing = message.sender?.uid == _messageListBloc.state.loggedInUser?.uid;

    // Deleted messages always show the deleted bubble
    if (message.deletedAt != null) {
      return Align(
        alignment: isOutgoing ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: _cachedMaxBubbleWidth,
          ),
          child: CometChatDeletedBubble(),
        ),
      );
    }

    return Align(
      alignment: isOutgoing ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: _cachedMaxBubbleWidth,
        ),
        padding: EdgeInsets.all(_spacing.padding3 ?? 12),
        decoration: BoxDecoration(
          color: isOutgoing 
              ? _colorPalette.primary 
              : _colorPalette.background2,
          borderRadius: BorderRadius.circular(_spacing.radius3 ?? 12),
        ),
        child: Text(
          message is TextMessage ? message.text : '[${message.type}]',
          style: TextStyle(
            color: isOutgoing 
                ? _colorPalette.white 
                : _colorPalette.textPrimary,
            fontSize: _typography.body?.regular?.fontSize,
          ),
        ),
      ),
    );
  }

  /// Handle loading older messages
  Future<void> _handleLoadOlder() async {
    _messageListBloc.add(const LoadOlderMessages());
  }

  /// Handle loading newer messages
  Future<void> _handleLoadNewer() async {
    _messageListBloc.add(const LoadNewerMessages());
  }
}
