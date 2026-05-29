import 'package:equatable/equatable.dart';
import 'package:cometchat_sdk/cometchat_sdk.dart';

/// Screen state enum for the notification feed.
enum NotificationFeedScreenState {
  loading,
  loaded,
  empty,
  error,
}

/// Immutable state class for the NotificationFeedBloc.
///
/// Uses a monotonically increasing [_version] counter to ensure every state
/// emission is unique, even when list contents haven't changed by Equatable
/// comparison (e.g., when item properties like readAt change but the item
/// ID remains the same).
class NotificationFeedState extends Equatable {
  /// Current list of feed items.
  final List<NotificationFeedItem> items;

  /// Available notification categories from the server.
  final List<NotificationCategory> categories;

  /// Currently selected category filter (null = "All").
  final String? activeCategory;

  /// Total unread count across all categories.
  final int totalUnreadCount;

  /// Per-category unread counts (computed locally from items).
  final Map<String, int> categoryUnreadCounts;

  /// Current screen state.
  final NotificationFeedScreenState screenState;

  /// Whether more items are being loaded (pagination).
  final bool isLoadingMore;

  /// Whether a pull-to-refresh is in progress.
  final bool isRefreshing;

  /// Whether there are more pages to load.
  final bool hasMorePages;

  /// Error message (when screenState is error).
  final String? error;

  /// Whether the device is offline.
  final bool isOffline;

  /// Monotonically increasing version to ensure every state emission is unique.
  final int _version;

  /// Global counter shared across all [NotificationFeedState] instances.
  static int _nextVersion = 0;

  NotificationFeedState({
    this.items = const [],
    this.categories = const [],
    this.activeCategory,
    this.totalUnreadCount = 0,
    this.categoryUnreadCounts = const {},
    this.screenState = NotificationFeedScreenState.loading,
    this.isLoadingMore = false,
    this.isRefreshing = false,
    this.hasMorePages = true,
    this.error,
    this.isOffline = false,
  }) : _version = _nextVersion++;

  @override
  List<Object?> get props => [
        _version,
        items,
        categories,
        activeCategory,
        totalUnreadCount,
        categoryUnreadCounts,
        screenState,
        isLoadingMore,
        isRefreshing,
        hasMorePages,
        error,
        isOffline,
      ];

  /// Create a copy of this state with updated fields.
  NotificationFeedState copyWith({
    List<NotificationFeedItem>? items,
    List<NotificationCategory>? categories,
    String? activeCategory,
    bool clearActiveCategory = false,
    int? totalUnreadCount,
    Map<String, int>? categoryUnreadCounts,
    NotificationFeedScreenState? screenState,
    bool? isLoadingMore,
    bool? isRefreshing,
    bool? hasMorePages,
    String? error,
    bool clearError = false,
    bool? isOffline,
  }) {
    return NotificationFeedState(
      items: items ?? this.items,
      categories: categories ?? this.categories,
      activeCategory:
          clearActiveCategory ? null : (activeCategory ?? this.activeCategory),
      totalUnreadCount: totalUnreadCount ?? this.totalUnreadCount,
      categoryUnreadCounts:
          categoryUnreadCounts ?? this.categoryUnreadCounts,
      screenState: screenState ?? this.screenState,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      hasMorePages: hasMorePages ?? this.hasMorePages,
      error: clearError ? null : (error ?? this.error),
      isOffline: isOffline ?? this.isOffline,
    );
  }
}
