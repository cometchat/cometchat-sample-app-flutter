import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:cometchat_sdk/cometchat_sdk.dart';

/// Status of the search operation
enum SearchStatus {
  initial,
  loading,
  loaded,
  empty,
  error,
}

/// Scope of what the search should show
enum SearchScope {
  conversations,
  messages,
  both,
}

/// A filter chip definition with optional icon
class SearchFilter extends Equatable {
  final String label;
  final int group;
  final IconData? icon;

  const SearchFilter({
    required this.label,
    required this.group,
    this.icon,
  });

  @override
  List<Object?> get props => [label, group, icon];
}

/// Immutable state for the search BLoC
class SearchState extends Equatable {
  final String searchText;
  final Set<String> selectedFilters;
  final List<SearchFilter> visibleFilters;

  final SearchStatus conversationsStatus;
  final List<Conversation> conversations;
  final bool hasMoreConversations;

  final SearchStatus messagesStatus;
  final List<BaseMessage> messages;
  final bool hasMoreMessages;

  final SearchScope scope;
  final bool showConversations;
  final bool showMessages;

  final String? errorMessage;

  const SearchState({
    this.searchText = '',
    this.selectedFilters = const {},
    this.visibleFilters = const [],
    this.conversationsStatus = SearchStatus.initial,
    this.conversations = const [],
    this.hasMoreConversations = false,
    this.messagesStatus = SearchStatus.initial,
    this.messages = const [],
    this.hasMoreMessages = false,
    this.scope = SearchScope.both,
    this.showConversations = true,
    this.showMessages = true,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [
        searchText,
        selectedFilters,
        visibleFilters,
        conversationsStatus,
        conversations,
        hasMoreConversations,
        messagesStatus,
        messages,
        hasMoreMessages,
        scope,
        showConversations,
        showMessages,
        errorMessage,
      ];

  SearchState copyWith({
    String? searchText,
    Set<String>? selectedFilters,
    List<SearchFilter>? visibleFilters,
    SearchStatus? conversationsStatus,
    List<Conversation>? conversations,
    bool? hasMoreConversations,
    SearchStatus? messagesStatus,
    List<BaseMessage>? messages,
    bool? hasMoreMessages,
    SearchScope? scope,
    bool? showConversations,
    bool? showMessages,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SearchState(
      searchText: searchText ?? this.searchText,
      selectedFilters: selectedFilters ?? this.selectedFilters,
      visibleFilters: visibleFilters ?? this.visibleFilters,
      conversationsStatus: conversationsStatus ?? this.conversationsStatus,
      conversations: conversations ?? this.conversations,
      hasMoreConversations: hasMoreConversations ?? this.hasMoreConversations,
      messagesStatus: messagesStatus ?? this.messagesStatus,
      messages: messages ?? this.messages,
      hasMoreMessages: hasMoreMessages ?? this.hasMoreMessages,
      scope: scope ?? this.scope,
      showConversations: showConversations ?? this.showConversations,
      showMessages: showMessages ?? this.showMessages,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  bool get bothActive =>
      showConversations && showMessages && scope == SearchScope.both;

  bool get isInitial => searchText.isEmpty && selectedFilters.isEmpty;

  bool get allEmpty {
    final convEmpty = !showConversations ||
        conversationsStatus == SearchStatus.empty ||
        (conversationsStatus == SearchStatus.loaded && conversations.isEmpty);
    final msgEmpty = !showMessages ||
        messagesStatus == SearchStatus.empty ||
        (messagesStatus == SearchStatus.loaded && messages.isEmpty);
    return convEmpty && msgEmpty;
  }

  bool get allLoading {
    final convLoading =
        !showConversations || conversationsStatus == SearchStatus.loading;
    final msgLoading =
        !showMessages || messagesStatus == SearchStatus.loading;
    return convLoading && msgLoading;
  }

  bool get allError {
    final convError =
        !showConversations || conversationsStatus == SearchStatus.error;
    final msgError =
        !showMessages || messagesStatus == SearchStatus.error;
    return convError && msgError;
  }

  /// Whether we should show the no-results screen
  bool shouldShowNoResults() {
    if (searchText.isEmpty && selectedFilters.isEmpty) return false;
    return allEmpty &&
        conversationsStatus != SearchStatus.loading &&
        messagesStatus != SearchStatus.loading;
  }
}
