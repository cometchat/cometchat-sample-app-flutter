import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
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
import 'package:cometchat_chat_uikit/shared_ui/src/clean_architecture/core/result.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class MockNotificationFeedRepository extends Mock
    implements NotificationFeedRepository {}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

NotificationFeedItem _makeItem({
  required String id,
  String category = 'promotions',
  int? readAt,
  int sentAt = 1700000000,
}) {
  return NotificationFeedItem(
    id: id,
    category: category,
    content: const {'type': 'test'},
    readAt: readAt,
    sentAt: sentAt,
    sender: 'server',
    receiver: 'user1',
    receiverType: 'user',
  );
}

NotificationCategory _makeCategory({
  required String id,
  required String label,
}) {
  return NotificationCategory(id: id, label: label);
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
// Tests
// ---------------------------------------------------------------------------

void main() {
  late MockNotificationFeedRepository repo;

  setUpAll(() {
    registerFallbackValue(NotificationFeedRequestBuilder().build());
    registerFallbackValue(NotificationCategoriesRequestBuilder().build());
    registerFallbackValue(_makeItem(id: 'fallback'));
  });

  setUp(() {
    repo = MockNotificationFeedRepository();
    // Default stubs
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

  group('NotificationFeedBloc', () {
    // -----------------------------------------------------------------------
    // Initial Load — State Transitions
    // -----------------------------------------------------------------------

    group('LoadNotificationFeed', () {
      blocTest<NotificationFeedBloc, NotificationFeedState>(
        'emits loading → empty when no items returned',
        build: () => _makeBloc(repo),
        // The BLoC auto-dispatches LoadNotificationFeed in constructor
        expect: () => [
          isA<NotificationFeedState>().having(
            (s) => s.screenState,
            'screenState',
            NotificationFeedScreenState.loading,
          ),
          isA<NotificationFeedState>().having(
            (s) => s.screenState,
            'screenState',
            NotificationFeedScreenState.empty,
          ),
        ],
      );

      blocTest<NotificationFeedBloc, NotificationFeedState>(
        'emits loading → loaded when items returned',
        build: () {
          final items = [_makeItem(id: 'item_1'), _makeItem(id: 'item_2')];
          when(() => repo.fetchFeedItems(any()))
              .thenAnswer((_) async => Success(items));
          return _makeBloc(repo);
        },
        expect: () => [
          isA<NotificationFeedState>().having(
            (s) => s.screenState,
            'screenState',
            NotificationFeedScreenState.loading,
          ),
          isA<NotificationFeedState>()
              .having(
                (s) => s.screenState,
                'screenState',
                NotificationFeedScreenState.loaded,
              )
              .having((s) => s.items.length, 'items.length', 2),
        ],
      );

      blocTest<NotificationFeedBloc, NotificationFeedState>(
        'emits loading → error when fetch fails',
        build: () {
          when(() => repo.fetchFeedItems(any())).thenAnswer(
            (_) async =>
                const Failure(message: 'Network error', code: 'NET_ERR'),
          );
          return _makeBloc(repo);
        },
        expect: () => [
          isA<NotificationFeedState>().having(
            (s) => s.screenState,
            'screenState',
            NotificationFeedScreenState.loading,
          ),
          isA<NotificationFeedState>()
              .having(
                (s) => s.screenState,
                'screenState',
                NotificationFeedScreenState.error,
              )
              .having((s) => s.error, 'error', 'Network error'),
        ],
      );

      blocTest<NotificationFeedBloc, NotificationFeedState>(
        'loads categories alongside items',
        build: () {
          final categories = [
            _makeCategory(id: 'promo', label: 'Promotions'),
            _makeCategory(id: 'updates', label: 'Updates'),
          ];
          final items = [_makeItem(id: 'item_1')];
          when(() => repo.fetchCategories(any()))
              .thenAnswer((_) async => Success(categories));
          when(() => repo.fetchFeedItems(any()))
              .thenAnswer((_) async => Success(items));
          return _makeBloc(repo);
        },
        expect: () => [
          isA<NotificationFeedState>().having(
            (s) => s.screenState,
            'screenState',
            NotificationFeedScreenState.loading,
          ),
          isA<NotificationFeedState>()
              .having((s) => s.categories.length, 'categories.length', 2)
              .having(
                (s) => s.screenState,
                'screenState',
                NotificationFeedScreenState.loaded,
              ),
        ],
      );

      blocTest<NotificationFeedBloc, NotificationFeedState>(
        'gracefully handles category fetch failure (still loads items)',
        build: () {
          when(() => repo.fetchCategories(any())).thenAnswer(
            (_) async => const Failure(message: 'Cat error', code: 'ERR'),
          );
          final items = [_makeItem(id: 'item_1')];
          when(() => repo.fetchFeedItems(any()))
              .thenAnswer((_) async => Success(items));
          return _makeBloc(repo);
        },
        expect: () => [
          isA<NotificationFeedState>().having(
            (s) => s.screenState,
            'screenState',
            NotificationFeedScreenState.loading,
          ),
          isA<NotificationFeedState>()
              .having((s) => s.categories, 'categories', isEmpty)
              .having(
                (s) => s.screenState,
                'screenState',
                NotificationFeedScreenState.loaded,
              ),
        ],
      );
    });

    // -----------------------------------------------------------------------
    // Pagination
    // -----------------------------------------------------------------------

    group('LoadMoreFeedItems', () {
      blocTest<NotificationFeedBloc, NotificationFeedState>(
        'appends new items on pagination',
        build: () {
          var callCount = 0;
          when(() => repo.fetchFeedItems(any())).thenAnswer((_) async {
            callCount++;
            if (callCount == 1) {
              return Success([_makeItem(id: 'item_1')]);
            }
            return Success([_makeItem(id: 'item_2')]);
          });
          return _makeBloc(repo);
        },
        act: (bloc) async {
          // Wait for initial load
          await Future.delayed(const Duration(milliseconds: 50));
          bloc.add(const LoadMoreFeedItems());
        },
        verify: (bloc) {
          expect(bloc.state.items.length, 2);
          expect(bloc.state.items[0].id, 'item_1');
          expect(bloc.state.items[1].id, 'item_2');
        },
      );

      blocTest<NotificationFeedBloc, NotificationFeedState>(
        'stops pagination when no more items returned',
        build: () {
          var callCount = 0;
          when(() => repo.fetchFeedItems(any())).thenAnswer((_) async {
            callCount++;
            if (callCount == 1) {
              return Success([_makeItem(id: 'item_1')]);
            }
            return const Success([]);
          });
          return _makeBloc(repo);
        },
        act: (bloc) async {
          await Future.delayed(const Duration(milliseconds: 50));
          bloc.add(const LoadMoreFeedItems());
        },
        verify: (bloc) {
          expect(bloc.state.hasMorePages, false);
          expect(bloc.state.items.length, 1);
        },
      );
    });

    // -----------------------------------------------------------------------
    // Category Switch
    // -----------------------------------------------------------------------

    group('SwitchCategory', () {
      blocTest<NotificationFeedBloc, NotificationFeedState>(
        'resets items and fetches fresh on category switch',
        build: () {
          var callCount = 0;
          when(() => repo.fetchFeedItems(any())).thenAnswer((_) async {
            callCount++;
            if (callCount == 1) {
              return Success([
                _makeItem(id: 'item_1', category: 'promotions'),
                _makeItem(id: 'item_2', category: 'updates'),
              ]);
            }
            return Success([
              _makeItem(id: 'item_3', category: 'updates'),
            ]);
          });
          return _makeBloc(repo);
        },
        act: (bloc) async {
          await Future.delayed(const Duration(milliseconds: 50));
          bloc.add(const SwitchCategory('updates'));
        },
        verify: (bloc) {
          expect(bloc.state.activeCategory, 'updates');
          expect(bloc.state.items.length, 1);
          expect(bloc.state.items[0].id, 'item_3');
        },
      );

      blocTest<NotificationFeedBloc, NotificationFeedState>(
        'does nothing when switching to same category',
        build: () {
          when(() => repo.fetchFeedItems(any()))
              .thenAnswer((_) async => Success([_makeItem(id: 'item_1')]));
          return _makeBloc(repo);
        },
        act: (bloc) async {
          await Future.delayed(const Duration(milliseconds: 50));
          // Switch to null (All) which is already the default
          bloc.add(const SwitchCategory(null));
        },
        verify: (bloc) {
          // fetchFeedItems should only be called once (initial load)
          verify(() => repo.fetchFeedItems(any())).called(1);
        },
      );
    });

    // -----------------------------------------------------------------------
    // Refresh
    // -----------------------------------------------------------------------

    group('RefreshFeed', () {
      blocTest<NotificationFeedBloc, NotificationFeedState>(
        'replaces items on refresh',
        build: () {
          var callCount = 0;
          when(() => repo.fetchFeedItems(any())).thenAnswer((_) async {
            callCount++;
            if (callCount == 1) {
              return Success([_makeItem(id: 'old_item')]);
            }
            return Success([_makeItem(id: 'new_item')]);
          });
          return _makeBloc(repo);
        },
        act: (bloc) async {
          await Future.delayed(const Duration(milliseconds: 50));
          bloc.add(const RefreshFeed());
        },
        verify: (bloc) {
          expect(bloc.state.items.length, 1);
          expect(bloc.state.items[0].id, 'new_item');
          expect(bloc.state.isRefreshing, false);
        },
      );
    });

    // -----------------------------------------------------------------------
    // Real-time: FeedItemReceived
    // -----------------------------------------------------------------------

    group('FeedItemReceived', () {
      blocTest<NotificationFeedBloc, NotificationFeedState>(
        'inserts new item at top of list',
        build: () {
          when(() => repo.fetchFeedItems(any()))
              .thenAnswer((_) async => Success([_makeItem(id: 'item_1')]));
          return _makeBloc(repo);
        },
        act: (bloc) async {
          await Future.delayed(const Duration(milliseconds: 50));
          bloc.add(FeedItemReceived(_makeItem(id: 'realtime_item')));
        },
        verify: (bloc) {
          expect(bloc.state.items.length, 2);
          expect(bloc.state.items[0].id, 'realtime_item');
          expect(bloc.state.items[1].id, 'item_1');
        },
      );

      blocTest<NotificationFeedBloc, NotificationFeedState>(
        'ignores item that does not match active category',
        build: () {
          var callCount = 0;
          when(() => repo.fetchFeedItems(any())).thenAnswer((_) async {
            callCount++;
            if (callCount == 1) {
              return Success([_makeItem(id: 'item_1', category: 'updates')]);
            }
            return Success([_makeItem(id: 'item_1', category: 'updates')]);
          });
          return _makeBloc(repo);
        },
        act: (bloc) async {
          await Future.delayed(const Duration(milliseconds: 50));
          bloc.add(const SwitchCategory('updates'));
          await Future.delayed(const Duration(milliseconds: 50));
          // This item has a different category
          bloc.add(FeedItemReceived(
              _makeItem(id: 'promo_item', category: 'promotions')));
        },
        verify: (bloc) {
          expect(bloc.state.activeCategory, 'updates');
          // promo_item should not be in the list
          expect(
            bloc.state.items.any((i) => i.id == 'promo_item'),
            false,
          );
        },
      );
    });

    // -----------------------------------------------------------------------
    // Retraction
    // -----------------------------------------------------------------------

    group('FeedItemRetracted', () {
      blocTest<NotificationFeedBloc, NotificationFeedState>(
        'removes item by ID from list',
        build: () {
          when(() => repo.fetchFeedItems(any())).thenAnswer((_) async =>
              Success([_makeItem(id: 'item_1'), _makeItem(id: 'item_2')]));
          return _makeBloc(repo);
        },
        act: (bloc) async {
          await Future.delayed(const Duration(milliseconds: 50));
          bloc.add(const FeedItemRetracted('item_1'));
        },
        verify: (bloc) {
          expect(bloc.state.items.length, 1);
          expect(bloc.state.items[0].id, 'item_2');
        },
      );

      blocTest<NotificationFeedBloc, NotificationFeedState>(
        'decrements unread count when retracted item was unread',
        build: () {
          when(() => repo.fetchFeedItems(any())).thenAnswer((_) async =>
              Success([
                _makeItem(id: 'item_1'), // unread (readAt == null)
                _makeItem(id: 'item_2', readAt: 1700000100),
              ]));
          return _makeBloc(repo);
        },
        act: (bloc) async {
          await Future.delayed(const Duration(milliseconds: 50));
          final unreadBefore = bloc.state.totalUnreadCount;
          expect(unreadBefore, 1); // only item_1 is unread
          bloc.add(const FeedItemRetracted('item_1'));
        },
        verify: (bloc) {
          expect(bloc.state.totalUnreadCount, 0);
        },
      );

      blocTest<NotificationFeedBloc, NotificationFeedState>(
        'emits empty state when last item is retracted',
        build: () {
          when(() => repo.fetchFeedItems(any()))
              .thenAnswer((_) async => Success([_makeItem(id: 'item_1')]));
          return _makeBloc(repo);
        },
        act: (bloc) async {
          await Future.delayed(const Duration(milliseconds: 50));
          bloc.add(const FeedItemRetracted('item_1'));
        },
        verify: (bloc) {
          expect(bloc.state.screenState, NotificationFeedScreenState.empty);
          expect(bloc.state.items, isEmpty);
        },
      );

      blocTest<NotificationFeedBloc, NotificationFeedState>(
        'does nothing when retracting non-existent item',
        build: () {
          when(() => repo.fetchFeedItems(any()))
              .thenAnswer((_) async => Success([_makeItem(id: 'item_1')]));
          return _makeBloc(repo);
        },
        act: (bloc) async {
          await Future.delayed(const Duration(milliseconds: 50));
          bloc.add(const FeedItemRetracted('non_existent'));
        },
        verify: (bloc) {
          expect(bloc.state.items.length, 1);
        },
      );
    });

    // -----------------------------------------------------------------------
    // Unread Count Updates
    // -----------------------------------------------------------------------

    group('UpdateUnreadCounts', () {
      blocTest<NotificationFeedBloc, NotificationFeedState>(
        'updates total unread count from server',
        build: () {
          when(() => repo.fetchFeedItems(any()))
              .thenAnswer((_) async => Success([_makeItem(id: 'item_1')]));
          when(() => repo.getUnreadCount())
              .thenAnswer((_) async => const Success(5));
          return _makeBloc(repo);
        },
        act: (bloc) async {
          await Future.delayed(const Duration(milliseconds: 50));
          bloc.add(const UpdateUnreadCounts());
        },
        verify: (bloc) {
          expect(bloc.state.totalUnreadCount, 5);
        },
      );
    });

    // -----------------------------------------------------------------------
    // MarkItemAsRead
    // -----------------------------------------------------------------------

    group('MarkItemAsRead', () {
      blocTest<NotificationFeedBloc, NotificationFeedState>(
        'marks item as read and decrements unread count',
        build: () {
          final items = [
            _makeItem(id: 'item_1'), // unread
            _makeItem(id: 'item_2'), // unread
          ];
          when(() => repo.fetchFeedItems(any()))
              .thenAnswer((_) async => Success(items));
          when(() => repo.markAsRead(any()))
              .thenAnswer((_) async => const Success(null));
          return _makeBloc(repo);
        },
        act: (bloc) async {
          await Future.delayed(const Duration(milliseconds: 50));
          expect(bloc.state.totalUnreadCount, 2);
          bloc.add(MarkItemAsRead(_makeItem(id: 'item_1')));
        },
        verify: (bloc) {
          expect(bloc.state.totalUnreadCount, 1);
          expect(bloc.state.items[0].readAt, isNotNull);
        },
      );

      blocTest<NotificationFeedBloc, NotificationFeedState>(
        'skips already-read items',
        build: () {
          final items = [_makeItem(id: 'item_1', readAt: 1700000100)];
          when(() => repo.fetchFeedItems(any()))
              .thenAnswer((_) async => Success(items));
          return _makeBloc(repo);
        },
        act: (bloc) async {
          await Future.delayed(const Duration(milliseconds: 50));
          bloc.add(MarkItemAsRead(_makeItem(id: 'item_1', readAt: 1700000100)));
        },
        verify: (bloc) {
          verifyNever(() => repo.markAsRead(any()));
        },
      );
    });

    // -----------------------------------------------------------------------
    // ConnectionStateChanged
    // -----------------------------------------------------------------------

    group('ConnectionStateChanged', () {
      blocTest<NotificationFeedBloc, NotificationFeedState>(
        'sets isOffline flag on disconnect',
        build: () {
          when(() => repo.fetchFeedItems(any()))
              .thenAnswer((_) async => Success([_makeItem(id: 'item_1')]));
          return _makeBloc(repo);
        },
        act: (bloc) async {
          await Future.delayed(const Duration(milliseconds: 50));
          bloc.add(const ConnectionStateChanged(true));
        },
        verify: (bloc) {
          expect(bloc.state.isOffline, true);
        },
      );

      blocTest<NotificationFeedBloc, NotificationFeedState>(
        'triggers refresh on reconnect',
        build: () {
          var callCount = 0;
          when(() => repo.fetchFeedItems(any())).thenAnswer((_) async {
            callCount++;
            return Success([_makeItem(id: 'item_$callCount')]);
          });
          return _makeBloc(repo);
        },
        act: (bloc) async {
          await Future.delayed(const Duration(milliseconds: 50));
          bloc.add(const ConnectionStateChanged(false));
          await Future.delayed(const Duration(milliseconds: 50));
        },
        verify: (bloc) {
          // Should have fetched at least twice (initial + refresh on reconnect)
          verify(() => repo.fetchFeedItems(any())).called(greaterThanOrEqualTo(2));
        },
      );
    });
  });
}
