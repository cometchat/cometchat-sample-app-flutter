import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../cometchat_chat_uikit.dart';
import '../../cometchat_chat_uikit.dart' as cc;

class CometChatSearchController extends GetxController {
  CometChatSearchController({this.searchFilters, this.searchScopes});

  /// [searchFilters] list of filters to be shown in the search screen
  final List<SearchFilter>? searchFilters;

  ///[SearchScope] list of scopes to be shown in the search result
  final List<SearchScope>? searchScopes;

  TextEditingController searchEditingController = TextEditingController();

  var selectedFilters = <String>{}.obs;

  BuildContext? context;

  String get searchText => searchEditingController.text;

  /// Default label-to-icon mapping
  final Map<String, IconData> filterIcons = {
    SearchConstants.unread: Icons.mark_unread_chat_alt_outlined,
    SearchConstants.groups: Icons.group_outlined,
    SearchConstants.photos: Icons.image_outlined,
    SearchConstants.videos: Icons.videocam_outlined,
    SearchConstants.links: Icons.link,
    SearchConstants.documents: Icons.article_outlined,
    SearchConstants.audio: Icons.headset_outlined,
  };

  /// Default filter labels (used if `searchFilters` is null)
  final List<SearchFilter> defaultFilterLabels = [
    SearchFilter.unread,
    SearchFilter.groups,
    SearchFilter.photos,
    SearchFilter.videos,
    SearchFilter.links,
    SearchFilter.documents,
    SearchFilter.audio,
  ];

  // For conversations:
  static const Map<String, String> filterLabelToConversationType = {
    SearchConstants.groups: "group",
    SearchConstants.unread: "unread",
  };

  // Map filter chip label to AttachmentType value string
  static const Map<String, String> filterLabelToAttachmentType = {
    SearchConstants.photos: "image",
    SearchConstants.videos: "video",
    SearchConstants.audio: "audio",
    SearchConstants.documents: "file",
    SearchConstants.links: "link",
  };

  List<FilterItem> filters = [];

  List<SearchScope> defaultSearchScopes = [
    SearchScope.conversations,
    SearchScope.messages,
  ];

  bool showConversationsSearch = false;
  bool showMessagesSearch = false;

  /// Guard flag to prevent concurrent filter tap processing
  bool _isProcessingTap = false;

  // Determine which filters are allowed based on scope
  List<String> allowedFilterLabels = [];

  // Indicate if both scopes are active
  bool? bothActive = false;

  @override
  void onInit() {
    getScope();

    getAllowedLabels();

    // Build filters from provided searchFilters or defaults
    final baseFilters = searchFilters ?? defaultFilterLabels;

    filters = baseFilters
        .map((filter) {
          final id = filterIds[filter] ?? "";
          final label = _mapEnumToLabel(filter);
          final icon = filterIcons[id] ?? Icons.filter_alt_outlined;

          return FilterItem(id, label, icon);
        })
        .where((item) {
          return allowedFilterLabels.contains(item.id);
        })
        .toList();

    super.onInit();
  }

  @override
  void onClose() {
    searchEditingController.dispose();
    selectedFilters.clear();
    super.onClose();
  }

  bool get isUnreadOrGroupsSelected =>
      selectedFilters.contains("Unread") || selectedFilters.contains("Groups");

  List<Set<String>> get filterGroups => [
    {SearchConstants.unread, SearchConstants.groups},
    {SearchConstants.photos, SearchConstants.videos},
    {SearchConstants.audio, SearchConstants.documents},
    {SearchConstants.links},
  ];

  List<FilterItem> get visibleFilters {
    if (selectedFilters.isEmpty) {
      return filters;
    }

    // Find all groups that intersect with selected filters
    final matchedGroups = filterGroups
        .where((group) => group.any((label) => selectedFilters.contains(label)))
        .toList();

    // If matchedGroups is empty, return all (should not happen)
    if (matchedGroups.isEmpty) {
      return filters;
    }

    // Show only the matched groups
    final visibleLabels = matchedGroups.expand((group) => group).toSet();

    return filters.where((f) => visibleLabels.contains(f.label)).toList();
  }

  dynamic getScope() {
    final List<SearchScope> effectiveScopes;
    if (searchScopes != null && searchScopes!.isNotEmpty) {
      effectiveScopes = searchScopes!;
    } else {
      effectiveScopes = defaultSearchScopes;
    }

    if (effectiveScopes.isNotEmpty) {
      showConversationsSearch = effectiveScopes.contains(
        SearchScope.conversations,
      );
      showMessagesSearch = effectiveScopes.contains(SearchScope.messages);
    }
    if (showConversationsSearch && showMessagesSearch) {
      bothActive = true;
      update();
    }
  }

  dynamic getAllowedLabels() {
    if (showConversationsSearch && showMessagesSearch) {
      // Both scopes — show all filters
      allowedFilterLabels = [
        SearchConstants.unread,
        SearchConstants.groups,
        SearchConstants.photos,
        SearchConstants.videos,
        SearchConstants.links,
        SearchConstants.documents,
        SearchConstants.audio,
      ];
    } else if (showConversationsSearch) {
      // Only conversations — show unread + groups
      allowedFilterLabels = [SearchConstants.unread, SearchConstants.groups];
    } else if (showMessagesSearch) {
      // Only messages — show media filters
      allowedFilterLabels = [
        SearchConstants.photos,
        SearchConstants.videos,
        SearchConstants.links,
        SearchConstants.documents,
        SearchConstants.audio,
      ];
    }
  }

  void onFilterTap(String label) {
    // Guard against concurrent taps
    if (_isProcessingTap) {
      return;
    }
    _isProcessingTap = true;

    try {
      // Find which group this filter belongs to
      final group = filterGroups.firstWhere(
        (g) => g.contains(label),
        orElse: () => {label},
      );

      // Check if we should reorder
      bool shouldReorder = true;

      if (group.length > 1) {
        // If any other filter from the same group is already selected
        final otherSelectedInGroup = group.any(
          (gLabel) => gLabel != label && selectedFilters.contains(gLabel),
        );

        if (otherSelectedInGroup) {
          shouldReorder = false; // Prevent reordering
        }
      }

      if (shouldReorder) {
        filters = filters.toList();
        int index = filters.indexWhere((f) => f.label == label);
        if (index != -1) {
          final tappedFilter = filters[index];
          final reordered = [
            tappedFilter,
            ...filters.where((f) => f.label != label),
          ];
          filters
            ..clear()
            ..addAll(reordered);
        }
      }

      // Check if tapped filter is already selected (toggle off)
      if (selectedFilters.contains(label)) {
        selectedFilters.remove(label);
      } else {
        // Check if any currently selected filter is from a DIFFERENT group
        final currentGroup = selectedFilters.isNotEmpty
            ? filterGroups.firstWhere(
                (g) => g.any((l) => selectedFilters.contains(l)),
                orElse: () => <String>{},
              )
            : <String>{};

        // If selecting from a different group, clear all previous selections
        if (currentGroup.isNotEmpty && !currentGroup.contains(label)) {
          selectedFilters.clear();
        }

        // Add the new filter
        selectedFilters.add(label);
      }

      _toggleConversationOrMessages();
    } finally {
      _isProcessingTap = false;
    }
  }

  void _toggleConversationOrMessages() {
    final filters = selectedFilters.toList();

    final hasConversationFilters =
        filters.contains(SearchConstants.unread) ||
        filters.contains(SearchConstants.groups);

    final hasMessageFilters = filters.any(
      (filter) => [
        SearchConstants.photos,
        SearchConstants.videos,
        SearchConstants.links,
        SearchConstants.documents,
        SearchConstants.audio,
      ].contains(filter),
    );

    if (hasConversationFilters && !hasMessageFilters) {
      showConversationsSearch = true;
      showMessagesSearch = false;
      bothActive = false;
    } else if (hasMessageFilters) {
      showConversationsSearch = false;
      showMessagesSearch = true;
      bothActive = false;
    } else {
      getScope();
      bothActive =
          ((showMessagesSearch == true) && (showConversationsSearch == true));
    }
    update();
  }

  static const Map<SearchFilter, String> filterIds = {
    SearchFilter.unread: "Unread",
    SearchFilter.groups: "Groups",
    SearchFilter.photos: "Photos",
    SearchFilter.videos: "Videos",
    SearchFilter.links: "Links",
    SearchFilter.documents: "Documents",
    SearchFilter.audio: "Audio",
  };

  /// Map enum to display label
  String _mapEnumToLabel(SearchFilter filter) {
    if (context == null) {
      return filterIds[filter] ?? "";
    }
    switch (filter) {
      case SearchFilter.unread:
        return cc.Translations.of(context!).unread;
      case SearchFilter.groups:
        return cc.Translations.of(context!).groups;
      case SearchFilter.photos:
        return cc.Translations.of(context!).photos;
      case SearchFilter.videos:
        return cc.Translations.of(context!).videos;
      case SearchFilter.links:
        return cc.Translations.of(context!).links;
      case SearchFilter.documents:
        return cc.Translations.of(context!).documents;
      case SearchFilter.audio:
        return cc.Translations.of(context!).audio;
    }
  }

  /// Determines if the conversation list should be visible
  bool shouldShowConversationList() {
    final hasSearchText = searchText.trim().isNotEmpty;
    final hasConversationFilters =
        selectedFilters.isNotEmpty &&
        (selectedFilters.contains(SearchConstants.unread) ||
            selectedFilters.contains(SearchConstants.groups));

    // Show conversation list if:
    // 1. Conversation filters are selected, OR
    // 2. Search text is entered and results are loading
    if (hasConversationFilters) {
      return true;
    }

    if (hasSearchText && showConversationsSearch) {
      return true;
    }

    return false;
  }

  /// Determines if the message list should be visible
  bool shouldShowMessageList() {
    final hasSearchText = searchText.trim().isNotEmpty;
    final hasMessageFilters =
        selectedFilters.isNotEmpty &&
        (selectedFilters.contains(SearchConstants.photos) ||
            selectedFilters.contains(SearchConstants.videos) ||
            selectedFilters.contains(SearchConstants.audio) ||
            selectedFilters.contains(SearchConstants.documents) ||
            selectedFilters.contains(SearchConstants.links));

    // Show message list if:
    // 1. Message filters are selected, OR
    // 2. Search text is entered and results are loading
    if (hasMessageFilters) {
      return true;
    }

    if (hasSearchText && showMessagesSearch) {
      return true;
    }

    return false;
  }

  /// Determines if the no-results screen should be visible
  bool shouldShowNoResultsScreen() {
    final hasSearchText = searchText.trim().isNotEmpty;
    final hasFilters = selectedFilters.isNotEmpty;

    // Show no-results screen if:
    // 1. No search text and no filters (initial state)
    if (!hasSearchText && !hasFilters) {
      return true;
    }

    return false;
  }
}
