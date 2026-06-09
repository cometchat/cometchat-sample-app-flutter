import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cometchat_sdk/cometchat_sdk.dart';

import 'package:cometchat_chat_uikit/chat_ui/src/notification_feed/bloc/notification_feed_bloc.dart';
import 'package:cometchat_chat_uikit/chat_ui/src/notification_feed/bloc/notification_feed_event.dart';
import 'package:cometchat_chat_uikit/chat_ui/src/notification_feed/bloc/notification_feed_state.dart';
import 'package:cometchat_chat_uikit/chat_ui/src/notification_feed/domain/usecases/get_feed_items_usecase.dart';
import 'package:cometchat_chat_uikit/chat_ui/src/notification_feed/domain/usecases/get_categories_usecase.dart';
import 'package:cometchat_chat_uikit/chat_ui/src/notification_feed/domain/usecases/mark_feed_delivered_usecase.dart';
import 'package:cometchat_chat_uikit/chat_ui/src/notification_feed/domain/usecases/mark_feed_read_usecase.dart';
import 'package:cometchat_chat_uikit/chat_ui/src/notification_feed/domain/usecases/report_feed_engagement_usecase.dart';
import 'package:cometchat_chat_uikit/chat_ui/src/notification_feed/domain/usecases/get_unread_count_usecase.dart';
import 'package:cometchat_chat_uikit/chat_ui/src/notification_feed/domain/usecases/get_feed_item_usecase.dart';
import 'package:cometchat_chat_uikit/chat_ui/src/notification_feed/domain/repositories/notification_feed_repository.dart';
import 'package:cometchat_chat_uikit/chat_ui/src/notification_feed/utils/timestamp_grouper.dart';
import 'package:cometchat_chat_uikit/shared_ui/src/clean_architecture/core/result.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class MockNotificationFeedRepository extends Mock
    implements NotificationFeedRepository {}

// ---------------------------------------------------------------------------
// Random generators
// ---------------------------------------------------------------------------

final _random = Random(42); // Fixed seed for reproducibility

const _categories = ['promotions', 'updates', 'orders', 'alerts', 'social'];

NotificationFeedItem _randomItem(int index) {
  final category = _categories[_random.nextInt(_categories.length)];
  final now = DateTime.now();
  // Random sentAt within the last 30 days
  final daysAgo = _random.nextInt(30);
  final hoursAgo = _random.nextInt(24);
  final sentAt = now
      .subtract(Duration(days: daysAgo, hours: hoursAgo))
      .millisecondsSinceEpoch ~/
      1000;
  final isRead = _random.nextBool();

  return NotificationFeedItem(
    id: 'item_$index',
    category: category,
    content: const {'type': 'test'},
    readAt: isRead ? sentAt + 60 : null,
    sentAt: sentAt,
    sender: 'server',
    receiver: 'user1',
    receiverType: 'user',
  );
}

List<NotificationFeedItem> _randomItems(int count) {
  return List.generate(count, (i) => _randomItem(i));
}

List<NotificationCategory> _randomCategories(int count) {
  return List.generate(
    count,
    (i) => NotificationCategory(
      id: 'cat_$i',
      label: 'Category $i',
    ),
  );
}

NotificationFeedBloc _makeBloc(MockNotificationFeedRepository repo) {
  return NotificationFeedBloc(
    getFeedItemsUseCase: GetFeedItemsUseCase(repo),
    getCategoriesUseCase: GetCategoriesUseCase(repo),
    markFeedDeliveredUseCase: MarkFeedDeliveredUseCase(repo),
    markFeedReadUseCase: MarkFeedReadUseCase(repo),
    reportFeedEngagementUseCase: ReportFeedEngagementUseCase(repo),
    getUnreadCountUseCase: GetUnreadCountUseCase(repo),
    getFeedItemUseCase: GetFeedItemUseCase(repo),
    disableSDKListeners: true,
  );
}

// ---------------------------------------------------------------------------
// Property-Based Tests
// ---------------------------------------------------------------------------

void main() {
  late MockNotificationFeedRepository repo;

  setUpAll(() {
    registerFallbackValue(NotificationFeedRequestBuilder().build());
    registerFallbackValue(NotificationCategoriesRequestBuilder().build());
    registerFallbackValue(const NotificationFeedItem(
      id: 'fb',
      category: 'x',
      content: {},
      sentAt: 0,
      sender: 's',
      receiver: 'r',
      receiverType: 'user',
    ));
  });

  setUp(() {
    repo = MockNotificationFeedRepository();
    when(() => repo.fetchCategories(any()))
        .thenAnswer((_) async => const Success([]));
    when(() => repo.fetchFeedItems(any()))
        .thenAnswer((_) async => const Success([]));
    when(() => repo.markAsDelivered(any()))
        .thenAnswer((_) async => const Success(null));
    when(() => repo.markAsRead(any()))
        .thenAnswer((_) async => const Success(null));
    when(() => repo.reportEngagement(any(), any()))
        .thenAnswer((_) async => const Success(null));
    when(() => repo.getUnreadCount())
        .thenAnswer((_) async => const Success(0));
  });

  // =========================================================================
  // Property 1: Filter chip count = N + 1 (N categories + "All")
  // =========================================================================

  group('Property 1: chip count = N + 1', () {
    test('for 100 random category counts, categories.length is always N', () {
      // The "All" chip is hardcoded in the UI widget, not in state.
      // State holds N categories from server. UI shows N + 1 (with "All").
      // We verify the state correctly stores all N categories.
      for (int iteration = 0; iteration < 100; iteration++) {
        final n = _random.nextInt(20); // 0 to 19 categories
        final categories = _randomCategories(n);

        final state = NotificationFeedState(categories: categories);

        // State holds exactly N categories
        expect(state.categories.length, n,
            reason: 'Iteration $iteration: expected $n categories');
        // UI would show N + 1 chips (N categories + "All")
        // The +1 is a UI concern verified in widget tests
      }
    });
  });

  // =========================================================================
  // Property 2: Grouping correctness — no items lost or duplicated
  // =========================================================================

  group('Property 2: grouping correctness', () {
    test('for 100 random item lists, grouping preserves all items', () {
      for (int iteration = 0; iteration < 100; iteration++) {
        final count = _random.nextInt(50) + 1; // 1 to 50 items
        final items = _randomItems(count);

        final groups = groupByTimestamp(items, 'en_US');

        // Total items across all groups equals input count
        final totalGrouped =
            groups.fold<int>(0, (sum, g) => sum + g.items.length);
        expect(totalGrouped, count,
            reason: 'Iteration $iteration: items lost or duplicated');

        // All original IDs are present
        final groupedIds =
            groups.expand((g) => g.items).map((i) => i.id).toSet();
        final originalIds = items.map((i) => i.id).toSet();
        expect(groupedIds, originalIds,
            reason: 'Iteration $iteration: ID mismatch');
      }
    });

    test('for 100 random item lists, groups are sorted newest-first', () {
      for (int iteration = 0; iteration < 100; iteration++) {
        final count = _random.nextInt(30) + 2; // 2 to 31 items
        final items = _randomItems(count);

        final groups = groupByTimestamp(items, 'en_US');

        if (groups.length > 1) {
          // Each group's newest item should be >= next group's newest item
          for (int i = 0; i < groups.length - 1; i++) {
            final currentNewest = groups[i].items.first.sentAt;
            final nextNewest = groups[i + 1].items.first.sentAt;
            expect(currentNewest >= nextNewest, true,
                reason:
                    'Iteration $iteration: group $i not newer than group ${i + 1}');
          }
        }
      }
    });

    test('for 100 random item lists, items within groups are sorted newest-first', () {
      for (int iteration = 0; iteration < 100; iteration++) {
        final count = _random.nextInt(30) + 2;
        final items = _randomItems(count);

        final groups = groupByTimestamp(items, 'en_US');

        for (final group in groups) {
          for (int i = 0; i < group.items.length - 1; i++) {
            expect(group.items[i].sentAt >= group.items[i + 1].sentAt, true,
                reason:
                    'Iteration $iteration: items not sorted in group "${group.label}"');
          }
        }
      }
    });
  });

  // =========================================================================
  // Property 4: Unread count invariant
  // totalUnreadCount == items.where((i) => i.readAt == null).length
  // =========================================================================

  group('Property 4: unread count invariant', () {
    test('for 100 random item lists, unread count matches items with null readAt',
        () async {
      for (int iteration = 0; iteration < 100; iteration++) {
        final count = _random.nextInt(30) + 1;
        final items = _randomItems(count);

        final expectedUnread = items.where((i) => i.readAt == null).length;

        when(() => repo.fetchFeedItems(any()))
            .thenAnswer((_) async => Success(items));

        final bloc = _makeBloc(repo);

        // Wait for initial load
        await Future.delayed(const Duration(milliseconds: 50));

        expect(bloc.state.totalUnreadCount, expectedUnread,
            reason:
                'Iteration $iteration: unread count mismatch. Expected $expectedUnread, got ${bloc.state.totalUnreadCount}');

        await bloc.close();
      }
    });

    test('for 100 random item lists, per-category unread counts are correct',
        () async {
      for (int iteration = 0; iteration < 100; iteration++) {
        final count = _random.nextInt(20) + 1;
        final items = _randomItems(count);

        // Compute expected per-category unread counts
        final expectedCounts = <String, int>{};
        for (final item in items) {
          if (item.readAt == null) {
            expectedCounts[item.category] =
                (expectedCounts[item.category] ?? 0) + 1;
          }
        }

        when(() => repo.fetchFeedItems(any()))
            .thenAnswer((_) async => Success(items));

        final bloc = _makeBloc(repo);
        await Future.delayed(const Duration(milliseconds: 50));

        for (final entry in expectedCounts.entries) {
          expect(bloc.state.categoryUnreadCounts[entry.key], entry.value,
              reason:
                  'Iteration $iteration: category "${entry.key}" unread mismatch');
        }

        await bloc.close();
      }
    });
  });

  // =========================================================================
  // Property 5: Delivery on fetch/receive — every fetched item gets delivered
  // =========================================================================

  group('Property 5: delivery on fetch/receive', () {
    test('for 100 random item lists, markAsDelivered called for each item',
        () async {
      for (int iteration = 0; iteration < 100; iteration++) {
        final count = _random.nextInt(10) + 1; // Keep small for speed
        final items = _randomItems(count);

        when(() => repo.fetchFeedItems(any()))
            .thenAnswer((_) async => Success(items));

        final bloc = _makeBloc(repo);
        await Future.delayed(const Duration(milliseconds: 50));

        // Verify markAsDelivered was called for each item
        verify(() => repo.markAsDelivered(any())).called(count);

        await bloc.close();
      }
    });

    test('real-time items also get marked as delivered', () async {
      for (int iteration = 0; iteration < 100; iteration++) {
        when(() => repo.fetchFeedItems(any()))
            .thenAnswer((_) async => const Success([]));

        final bloc = _makeBloc(repo);
        await Future.delayed(const Duration(milliseconds: 50));

        // Simulate real-time item
        final realtimeItem = _randomItem(999 + iteration);
        bloc.add(FeedItemReceived(realtimeItem));
        await Future.delayed(const Duration(milliseconds: 20));

        // Should have been marked as delivered
        verify(() => repo.markAsDelivered(any())).called(1);

        await bloc.close();
      }
    });
  });

  // =========================================================================
  // Property 10: Pagination exhaustion — stops when empty page returned
  // =========================================================================

  group('Property 10: pagination exhaustion', () {
    test('for 100 iterations, hasMorePages becomes false after empty page',
        () async {
      for (int iteration = 0; iteration < 100; iteration++) {
        final pageSize = _random.nextInt(10) + 1;
        final items = _randomItems(pageSize);

        var callCount = 0;
        when(() => repo.fetchFeedItems(any())).thenAnswer((_) async {
          callCount++;
          if (callCount == 1) return Success(items);
          return const Success([]); // Empty page = exhausted
        });

        final bloc = _makeBloc(repo);
        await Future.delayed(const Duration(milliseconds: 50));

        // Before pagination
        expect(bloc.state.hasMorePages, true,
            reason: 'Iteration $iteration: should have more pages initially');

        // Trigger pagination
        bloc.add(const LoadMoreFeedItems());
        await Future.delayed(const Duration(milliseconds: 50));

        // After empty page
        expect(bloc.state.hasMorePages, false,
            reason:
                'Iteration $iteration: should be exhausted after empty page');
        expect(bloc.state.items.length, pageSize,
            reason: 'Iteration $iteration: items should not change');

        await bloc.close();
      }
    });

    test('does not fetch when already exhausted', () async {
      for (int iteration = 0; iteration < 100; iteration++) {
        var callCount = 0;
        when(() => repo.fetchFeedItems(any())).thenAnswer((_) async {
          callCount++;
          if (callCount == 1) return Success([_randomItem(0)]);
          return const Success([]);
        });

        final bloc = _makeBloc(repo);
        await Future.delayed(const Duration(milliseconds: 50));

        // First pagination — exhausts
        bloc.add(const LoadMoreFeedItems());
        await Future.delayed(const Duration(milliseconds: 50));
        expect(bloc.state.hasMorePages, false);

        final callsAfterExhaustion = callCount;

        // Second pagination — should be a no-op
        bloc.add(const LoadMoreFeedItems());
        await Future.delayed(const Duration(milliseconds: 50));

        expect(callCount, callsAfterExhaustion,
            reason:
                'Iteration $iteration: should not fetch after exhaustion');

        await bloc.close();
      }
    });
  });
}
