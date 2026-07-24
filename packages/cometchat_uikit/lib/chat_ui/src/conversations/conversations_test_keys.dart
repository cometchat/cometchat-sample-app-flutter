import 'package:flutter/foundation.dart';

/// Test keys for CometChatConversations widget.
///
/// These keys are applied to specific widget slots so that integration tests
/// and E2E tests can reliably find and assert on custom views, styles, and
/// structural elements without depending on fragile text/type finders.
///
/// Usage in E2E:
/// ```dart
/// expect(find.byKey(ConversationsTestKeys.customListItem), findsWidgets);
/// ```
class ConversationsTestKeys {
  ConversationsTestKeys._();

  // ─── Structural ────────────────────────────────────────────────────────────
  /// The main conversations list (ListView/SliverList)
  static const conversationsList = Key('cometchat_conversations_list');

  /// The app bar area
  static const appBar = Key('cometchat_conversations_appbar');

  /// The search field
  static const searchField = Key('cometchat_conversations_search');

  /// The back button
  static const backButton = Key('cometchat_conversations_back_button');

  // ─── Custom View Slots ─────────────────────────────────────────────────────
  /// Applied to the wrapper of custom listItemView when provided
  static const customListItem = Key('cometchat_conversations_custom_list_item');

  /// Applied to the wrapper of custom subtitleView when provided
  static const customSubtitle = Key('cometchat_conversations_custom_subtitle');

  /// Applied to the wrapper of custom trailingView when provided
  static const customTrailing = Key('cometchat_conversations_custom_trailing');

  /// Applied to the wrapper of custom leadingView when provided
  static const customLeading = Key('cometchat_conversations_custom_leading');

  /// Applied to the wrapper of custom titleView when provided
  static const customTitle = Key('cometchat_conversations_custom_title');

  /// Applied to the custom emptyStateView when provided
  static const customEmptyState = Key('cometchat_conversations_custom_empty');

  /// Applied to the custom errorStateView when provided
  static const customErrorState = Key('cometchat_conversations_custom_error');

  /// Applied to the custom loadingStateView when provided
  static const customLoadingState = Key(
    'cometchat_conversations_custom_loading',
  );

  // ─── Style Verification ────────────────────────────────────────────────────
  /// Applied to the title text widget (for style verification)
  static const titleText = Key('cometchat_conversations_title_text');

  /// Applied to each conversation list item row
  static const listItemRow = Key('cometchat_conversations_list_item_row');
}
