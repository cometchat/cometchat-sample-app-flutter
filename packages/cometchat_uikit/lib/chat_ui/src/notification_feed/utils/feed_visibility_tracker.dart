import 'dart:async';
import 'package:cometchat_sdk/cometchat_sdk.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/notification_feed_event.dart';
import '../bloc/notification_feed_state.dart';

/// Manages visibility tracking for notification feed items.
///
/// When an item enters the viewport:
/// - Immediately reports "viewed" engagement (once per session).
/// - Starts a 1-second timer.
///
/// When the 1-second timer fires (item still visible):
/// - Dispatches [MarkItemAsRead] event to the BLoC.
///
/// When an item leaves the viewport before 1 second:
/// - Cancels the timer (don't mark as read).
/// - "viewed" was already reported (that's fine, it's idempotent).
///
/// Tracks already-viewed and already-read item IDs to avoid duplicates.
class FeedVisibilityTracker {
  final Bloc<NotificationFeedEvent, NotificationFeedState> _bloc;

  /// Items that have already been reported as "viewed" this session.
  final Set<String> _viewedItemIds = {};

  /// Items that have already been marked as read this session.
  final Set<String> _readItemIds = {};

  /// Active timers for items currently visible in the viewport.
  final Map<String, Timer> _activeTimers = {};

  /// Duration an item must remain visible before marking as read.
  static const Duration readThreshold = Duration(seconds: 1);

  FeedVisibilityTracker({
    required Bloc<NotificationFeedEvent, NotificationFeedState> bloc,
  }) : _bloc = bloc;

  /// Called when a feed item enters the viewport.
  void onItemVisible(NotificationFeedItem item) {
    // Report "viewed" engagement (once per session)
    if (!_viewedItemIds.contains(item.id)) {
      _viewedItemIds.add(item.id);
      if (!_bloc.isClosed) {
        _bloc.add(ReportViewed(item));
      }
    }

    // Don't start read timer if already read
    if (item.readAt != null || _readItemIds.contains(item.id)) return;

    // Start 1-second timer for marking as read
    _activeTimers[item.id]?.cancel();
    _activeTimers[item.id] = Timer(readThreshold, () {
      _activeTimers.remove(item.id);
      if (!_readItemIds.contains(item.id) && !_bloc.isClosed) {
        _readItemIds.add(item.id);
        _bloc.add(MarkItemAsRead(item));
      }
    });
  }

  /// Called when a feed item leaves the viewport.
  void onItemHidden(NotificationFeedItem item) {
    // Cancel the read timer if item leaves before threshold
    _activeTimers[item.id]?.cancel();
    _activeTimers.remove(item.id);
  }

  /// Mark an item as already read (e.g., when it arrives with readAt set).
  void markAsAlreadyRead(String itemId) {
    _readItemIds.add(itemId);
  }

  /// Dispose all active timers. Call this when the widget is disposed.
  void dispose() {
    for (final timer in _activeTimers.values) {
      timer.cancel();
    }
    _activeTimers.clear();
  }
}
