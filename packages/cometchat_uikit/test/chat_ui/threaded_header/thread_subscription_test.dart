// Thread Subscription (ENG-37601) — kit-side unit tests: the event-bus
// channel, the threaded-header bloc state, the feature gate default, the
// option id in both constants copies, and the localization keys.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';
import 'package:cometchat_chat_uikit/shared_ui/src/constants/ui_kit_constants.dart'
    as legacy_constants;

class _RecordingListener with CometChatMessageEventListener {
  final List<(int, bool)> received = [];

  @override
  void ccThreadSubscriptionChanged(int parentMessageId, bool subscribed) {
    received.add((parentMessageId, subscribed));
  }
}

void main() {
  group('CometChatMessageEvents.ccThreadSubscriptionChanged', () {
    test('reaches registered listeners and stops after removal', () {
      final listener = _RecordingListener();
      CometChatMessageEvents.addMessagesListener('test_thread_sub', listener);

      CometChatMessageEvents.ccThreadSubscriptionChanged(42, true);
      expect(listener.received, [(42, true)]);

      CometChatMessageEvents.ccThreadSubscriptionChanged(42, false);
      expect(listener.received, [(42, true), (42, false)]);

      CometChatMessageEvents.removeMessagesListener('test_thread_sub');
      CometChatMessageEvents.ccThreadSubscriptionChanged(7, true);
      expect(listener.received.length, 2);
    });

    test('existing listeners without the new override are unaffected', () {
      // A listener that does not override ccThreadSubscriptionChanged must
      // inherit the empty default — no crash, non-breaking.
      final plain = _PlainListener();
      CometChatMessageEvents.addMessagesListener('test_plain', plain);
      expect(
        () => CometChatMessageEvents.ccThreadSubscriptionChanged(1, true),
        returnsNormally,
      );
      CometChatMessageEvents.removeMessagesListener('test_plain');
    });
  });

  group('ThreadedHeaderBloc thread-subscription state', () {
    test('initial state is false — un-followed until the message says so', () {
      expect(const ThreadedHeaderState().threadSubscribed, isFalse);
    });

    test('UpdateThreadSubscription flips the state both ways', () async {
      final bloc = ThreadedHeaderBloc();
      bloc.add(const UpdateThreadSubscription(true));
      await expectLater(
        bloc.stream,
        emits(
          isA<ThreadedHeaderState>().having(
            (state) => state.threadSubscribed,
            'threadSubscribed',
            isTrue,
          ),
        ),
      );
      bloc.add(const UpdateThreadSubscription(false));
      await expectLater(
        bloc.stream,
        emits(
          isA<ThreadedHeaderState>().having(
            (state) => state.threadSubscribed,
            'threadSubscribed',
            isFalse,
          ),
        ),
      );
      await bloc.close();
    });
  });

  group('Feature gate', () {
    test('UIKitSettings.enableThreadSubscription defaults to OFF', () {
      final settings = UIKitSettingsBuilder().build();
      expect(
        settings.enableThreadSubscription,
        isFalse,
        reason: 'both surfaces must stay dark unless the integrator opts in',
      );
    });

    test('builder opt-in carries through', () {
      final settings = (UIKitSettingsBuilder()..enableThreadSubscription = true)
          .build();
      expect(settings.enableThreadSubscription, isTrue);
    });
  });

  group('Option id', () {
    test('present and identical in both MessageOptionConstants copies', () {
      expect(MessageOptionConstants.threadSubscription, 'threadSubscription');
      expect(
        legacy_constants.MessageOptionConstants.threadSubscription,
        'threadSubscription',
      );
    });
  });

  group('Thread-id resolution (option acts on the thread)', () {
    BaseMessage message({required int id, required int parentMessageId}) =>
        BaseMessage(
          id: id,
          parentMessageId: parentMessageId,
          receiverUid: 'r1',
          type: 'text',
          receiverType: 'group',
        );

    test('a root message targets its own thread', () {
      expect(
        MessageTemplateUtils.resolveThreadId(
          message(id: 7, parentMessageId: 0),
        ),
        7,
      );
    });

    test('a reply targets its parent thread', () {
      expect(
        MessageTemplateUtils.resolveThreadId(
          message(id: 8, parentMessageId: 7),
        ),
        7,
      );
    });

    test(
      'the message object IS the subscription state (stateless redesign)',
      () {
        final root = message(id: 9, parentMessageId: 0)
          ..threadSubscribed = true;
        expect(MessageTemplateUtils.isSubscribedToThreadOf(root), isTrue);
        final unmuted = message(id: 10, parentMessageId: 0)
          ..threadSubscribed = false;
        expect(MessageTemplateUtils.isSubscribedToThreadOf(unmuted), isFalse);
        final untold = message(id: 11, parentMessageId: 0);
        expect(
          MessageTemplateUtils.isSubscribedToThreadOf(untold),
          isFalse,
          reason:
              'normalised default false renders as the actionable '
              'un-followed state — "the server did not tell me"',
        );
      },
    );
  });

  group('CometChatMessageHeader.threadSubscriptionVisibility', () {
    BaseMessage rootMessage() => BaseMessage(
      id: 42,
      receiverUid: 'g1',
      type: 'text',
      receiverType: 'group',
    )..threadSubscribed = true;

    Widget host({required bool show, required bool gateOn}) {
      CometChatUIKit.authenticationSettings =
          (UIKitSettingsBuilder()..enableThreadSubscription = gateOn).build();
      return MaterialApp(
        home: Scaffold(
          appBar: CometChatMessageHeader(
            group: Group(guid: 'g1', name: 'G', type: 'public'),
            threadSubscriptionVisibility: show,
            parentMessage: rootMessage(),
            hideVoiceCallButton: true,
            hideVideoCallButton: true,
          ),
          body: const SizedBox(),
        ),
      );
    }

    testWidgets('bell renders when parentMessage set and the gate is on', (
      tester,
    ) async {
      await tester.pumpWidget(host(show: true, gateOn: true));
      await tester.pump();
      expect(find.byIcon(Icons.notifications_outlined), findsOneWidget);
    });

    testWidgets('no bell when the feature gate is off', (tester) async {
      await tester.pumpWidget(host(show: true, gateOn: false));
      await tester.pump();
      expect(find.byIcon(Icons.notifications_outlined), findsNothing);
      expect(find.byIcon(Icons.notifications_off_outlined), findsNothing);
    });

    testWidgets('no bell when visibility is off', (tester) async {
      await tester.pumpWidget(host(show: false, gateOn: true));
      await tester.pump();
      expect(find.byIcon(Icons.notifications_outlined), findsNothing);
      expect(find.byIcon(Icons.notifications_off_outlined), findsNothing);
    });
  });

  group('Localization', () {
    test('base class ships English defaults (non-breaking for subclasses)', () {
      final en = TranslationsEn();
      expect(en.threadMute, 'Unsubscribe from thread');
      expect(en.threadUnmute, 'Subscribe to thread');
      expect(
        en.messageListOptionStopReplyNotifications,
        'Unsubscribe from thread',
      );
      expect(en.messageListOptionGetReplyNotifications, 'Subscribe to thread');
      expect(
        en.threadMutedToast,
        'Unsubscribed. Notifications are off until you reply or are '
        'mentioned.',
      );
      expect(
        en.threadUnmutedToast,
        "Subscribed. You'll be notified about new replies in this thread.",
      );
      expect(en.threadSubscriptionFailed, isNotEmpty);
      expect(en.threadUnavailable, isNotEmpty);
    });

    test('zh and zh_TW carry distinct translations', () {
      final zh = TranslationsZh();
      final zhTw = TranslationsZhTw();
      expect(zh.threadMute, isNotEmpty);
      expect(zhTw.threadMute, isNotEmpty);
      expect(
        zh.threadMute,
        isNot(zhTw.threadMute),
        reason: 'translations_zh.dart holds two classes — both were edited',
      );
    });
  });
}

class _PlainListener with CometChatMessageEventListener {}
