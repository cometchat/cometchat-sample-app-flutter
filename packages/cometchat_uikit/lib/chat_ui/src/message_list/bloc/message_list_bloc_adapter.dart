import 'package:flutter/material.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';

/// Adapter that wraps [MessageListBloc] to implement [CometChatMessageListControllerProtocol].
///
/// This adapter allows the BLoC-based message list to work with existing
/// message templates and extensions that expect the controller protocol.
///
/// Example usage:
/// ```dart
/// final bloc = MessageListBloc(user: targetUser);
/// final adapter = MessageListBlocAdapter(
///   bloc: bloc,
///   templateMap: myTemplateMap,
///   scrollController: myScrollController,
///   context: context,
/// );
///
/// // Use adapter with message options
/// template.options!(loggedInUser, message, context, group, additionalConfigurations);
/// ```
class MessageListBlocAdapter implements CometChatMessageListControllerProtocol {
  /// The underlying BLoC instance
  final MessageListBloc bloc;

  /// Map of message templates for O(1) lookup
  final Map<String, CometChatMessageTemplate> _templateMap;

  /// Scroll controller for the message list
  final ScrollController _scrollController;

  /// Current build context
  BuildContext _context;

  /// Creates a [MessageListBlocAdapter].
  ///
  /// [bloc] - The MessageListBloc to wrap
  /// [templateMap] - Map of message templates
  /// [scrollController] - Scroll controller for the list
  /// [context] - Current build context
  MessageListBlocAdapter({
    required this.bloc,
    required Map<String, CometChatMessageTemplate> templateMap,
    required ScrollController scrollController,
    required BuildContext context,
  }) : _templateMap = templateMap,
       _scrollController = scrollController,
       _context = context;

  /// Update the context (call this in didChangeDependencies)
  void updateContext(BuildContext context) {
    _context = context;
  }

  // ============================================================
  // CometChatMessageListControllerProtocol Implementation
  // ============================================================

  @override
  Map<String, CometChatMessageTemplate> getTemplateMap() => _templateMap;

  @override
  ScrollController getScrollController() => _scrollController;

  @override
  int? getParentMessageId() => bloc.parentMessageId;

  @override
  Group? getGroup() => bloc.group;

  @override
  User? getUser() => bloc.user;

  @override
  BuildContext getCurrentContext() => _context;

  @override
  String getConversationId() => bloc.conversationId ?? '';

  @override
  initializeHeaderAndFooterView() {
    // No-op for BLoC - header/footer are managed by the widget
  }

  @override
  addMessage(BaseMessage message) {
    bloc.add(MessageReceived(message));
  }

  @override
  updateMessageWithMuid(BaseMessage message) {
    // Find by muid and update
    final index = bloc.findMessageIndexByMuid(message.muid);
    if (index != null) {
      bloc.add(MessageEdited(message));
    } else {
      // If not found by muid, try adding as new
      bloc.add(MessageReceived(message));
    }
  }

  @override
  deleteMessage(BaseMessage message) {
    bloc.add(MessageDeleted(message));
  }

  @override
  updateMessageThreadCount(int parentMessageId) {
    // Update thread reply count via the notifier
    final currentCount = bloc.getThreadReplyCount(parentMessageId);
    bloc.initializeThreadReplyCount(parentMessageId, currentCount + 1);
  }

  // ============================================================
  // CometChatSearchListControllerProtocol Implementation
  // ============================================================

  @override
  onSearch(String val) {
    // Message list doesn't support search - no-op
  }

  // ============================================================
  // CometChatListProtocol Implementation
  // ============================================================

  @override
  bool match(BaseMessage elementA, BaseMessage elementB) {
    return elementA.id == elementB.id;
  }

  @override
  loadMoreElements({bool Function(BaseMessage element)? isIncluded}) {
    bloc.add(const LoadOlderMessages());
  }

  @override
  int getMatchingIndex(BaseMessage element) {
    return bloc.findMessageIndex(element.id) ?? -1;
  }

  @override
  updateElement(BaseMessage element, {int? index}) {
    bloc.add(MessageEdited(element));
  }

  @override
  addElement(BaseMessage element, {int index = 0}) {
    bloc.add(MessageReceived(element));
  }

  @override
  removeElement(BaseMessage element) {
    bloc.add(MessageDeleted(element));
  }

  @override
  int getMatchingIndexFromKey(String key) {
    // Try to parse key as message ID
    final id = int.tryParse(key);
    if (id != null) {
      return bloc.findMessageIndex(id) ?? -1;
    }
    // Try as muid
    return bloc.findMessageIndexByMuid(key) ?? -1;
  }

  @override
  removeElementAt(int index) {
    if (index >= 0 && index < bloc.state.messages.length) {
      final message = bloc.state.messages[index];
      bloc.add(MessageDeleted(message));
    }
  }

  @override
  List<BaseMessage> getList() => bloc.state.messages;

  // ============================================================
  // Mark as Unread
  // ============================================================

  /// Delegates mark-as-unread to the BLoC via event dispatch
  void markMessageAsUnread(BaseMessage message) {
    bloc.add(MarkMessageAsUnread(message));
  }

  /// Delegates reset-unread-state to the BLoC via event dispatch
  void resetUnreadState() {
    bloc.add(const ResetUnreadState());
  }
}
