import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cometchat_sdk/cometchat_sdk.dart';

import 'package:cometchat_chat_uikit/chat_ui/src/notification_feed/bloc/notification_feed_bloc.dart';
import 'package:cometchat_chat_uikit/chat_ui/src/notification_feed/bloc/notification_feed_event.dart';
import 'package:cometchat_chat_uikit/chat_ui/src/notification_feed/bloc/notification_feed_state.dart';
import 'package:cometchat_chat_uikit/chat_ui/src/notification_feed/utils/feed_visibility_tracker.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class MockNotificationFeedBloc
    extends MockBloc<NotificationFeedEvent, NotificationFeedState>
    implements NotificationFeedBloc {}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

NotificationFeedItem _makeItem({
  required String id,
  int? readAt,
  String category = 'promotions',
}) {
  return NotificationFeedItem(
    id: id,
    category: category,
    content: const {'type': 'test'},
    readAt: readAt,
    sentAt: 1700000000,
    sender: 'server',
    receiver: 'user1',
    receiverType: 'user',
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late MockNotificationFeedBloc mockBloc;
  late FeedVisibilityTracker tracker;

  setUpAll(() {
    registerFallbackValue(ReportViewed(_makeItem(id: 'fallback')));
    registerFallbackValue(MarkItemAsRead(_makeItem(id: 'fallback')));
  });

  setUp(() {
    mockBloc = MockNotificationFeedBloc();
    when(() => mockBloc.isClosed).thenReturn(false);
    tracker = FeedVisibilityTracker(bloc: mockBloc);
  });

  tearDown(() {
    tracker.dispose();
  });

  group('FeedVisibilityTracker', () {
    // -----------------------------------------------------------------------
    // Viewed engagement
    // -----------------------------------------------------------------------

    test('reports "viewed" immediately when item becomes visible', () {
      final item = _makeItem(id: 'item_1');

      tracker.onItemVisible(item);

      verify(() => mockBloc.add(any(that: isA<ReportViewed>()))).called(1);
    });

    test('does not re-report "viewed" for same item on subsequent visibility', () {
      final item = _makeItem(id: 'item_1');

      tracker.onItemVisible(item);
      tracker.onItemHidden(item);
      tracker.onItemVisible(item);

      // Should only be called once (deduplicated)
      verify(() => mockBloc.add(any(that: isA<ReportViewed>()))).called(1);
    });

    // -----------------------------------------------------------------------
    // Read timer
    // -----------------------------------------------------------------------

    test('dispatches MarkItemAsRead after 1 second of visibility', () async {
      final item = _makeItem(id: 'item_1');

      tracker.onItemVisible(item);

      // Before timer fires
      verifyNever(() => mockBloc.add(any(that: isA<MarkItemAsRead>())));

      // Wait for the read threshold (1 second)
      await Future.delayed(const Duration(milliseconds: 1100));

      verify(() => mockBloc.add(any(that: isA<MarkItemAsRead>()))).called(1);
    });

    test('does NOT dispatch MarkItemAsRead if item hidden before 1 second', () async {
      final item = _makeItem(id: 'item_1');

      tracker.onItemVisible(item);

      // Hide after 500ms (before the 1s threshold)
      await Future.delayed(const Duration(milliseconds: 500));
      tracker.onItemHidden(item);

      // Wait past the threshold
      await Future.delayed(const Duration(milliseconds: 700));

      verifyNever(() => mockBloc.add(any(that: isA<MarkItemAsRead>())));
    });

    test('does not start read timer for already-read items', () async {
      final item = _makeItem(id: 'item_1', readAt: 1700000100);

      tracker.onItemVisible(item);

      await Future.delayed(const Duration(milliseconds: 1100));

      // Should report viewed but NOT mark as read
      verify(() => mockBloc.add(any(that: isA<ReportViewed>()))).called(1);
      verifyNever(() => mockBloc.add(any(that: isA<MarkItemAsRead>())));
    });

    test('does not re-dispatch MarkItemAsRead for already-marked items', () async {
      final item = _makeItem(id: 'item_1');

      // First visibility cycle — should mark as read
      tracker.onItemVisible(item);
      await Future.delayed(const Duration(milliseconds: 1100));
      verify(() => mockBloc.add(any(that: isA<MarkItemAsRead>()))).called(1);

      // Second visibility cycle — should NOT mark as read again
      tracker.onItemHidden(item);
      tracker.onItemVisible(item);
      await Future.delayed(const Duration(milliseconds: 1100));

      // Still only 1 call total
      verifyNever(() => mockBloc.add(any(that: isA<MarkItemAsRead>())));
    });

    // -----------------------------------------------------------------------
    // markAsAlreadyRead
    // -----------------------------------------------------------------------

    test('markAsAlreadyRead prevents read timer from firing', () async {
      final item = _makeItem(id: 'item_1');

      tracker.markAsAlreadyRead('item_1');
      tracker.onItemVisible(item);

      await Future.delayed(const Duration(milliseconds: 1100));

      // Viewed should still be reported
      verify(() => mockBloc.add(any(that: isA<ReportViewed>()))).called(1);
      // But read should not
      verifyNever(() => mockBloc.add(any(that: isA<MarkItemAsRead>())));
    });

    // -----------------------------------------------------------------------
    // Dispose
    // -----------------------------------------------------------------------

    test('dispose cancels all active timers', () async {
      final item1 = _makeItem(id: 'item_1');
      final item2 = _makeItem(id: 'item_2');

      tracker.onItemVisible(item1);
      tracker.onItemVisible(item2);

      // Dispose before timers fire
      tracker.dispose();

      await Future.delayed(const Duration(milliseconds: 1100));

      // No MarkItemAsRead should have been dispatched
      verifyNever(() => mockBloc.add(any(that: isA<MarkItemAsRead>())));
    });

    // -----------------------------------------------------------------------
    // Multiple items
    // -----------------------------------------------------------------------

    test('tracks multiple items independently', () async {
      final item1 = _makeItem(id: 'item_1');
      final item2 = _makeItem(id: 'item_2');

      tracker.onItemVisible(item1);
      tracker.onItemVisible(item2);

      // Verify both get "viewed"
      verify(() => mockBloc.add(any(that: isA<ReportViewed>()))).called(2);

      // Hide item1 before threshold, keep item2 visible
      await Future.delayed(const Duration(milliseconds: 500));
      tracker.onItemHidden(item1);

      await Future.delayed(const Duration(milliseconds: 700));

      // Only item2 should be marked as read
      final captured = verify(
        () => mockBloc.add(captureAny(that: isA<MarkItemAsRead>())),
      ).captured;

      expect(captured.length, 1);
      expect((captured[0] as MarkItemAsRead).feedItem.id, 'item_2');
    });

    // -----------------------------------------------------------------------
    // Bloc closed
    // -----------------------------------------------------------------------

    test('does not dispatch events when bloc is closed', () {
      when(() => mockBloc.isClosed).thenReturn(true);

      final item = _makeItem(id: 'item_1');
      tracker.onItemVisible(item);

      verifyNever(() => mockBloc.add(any()));
    });
  });
}
