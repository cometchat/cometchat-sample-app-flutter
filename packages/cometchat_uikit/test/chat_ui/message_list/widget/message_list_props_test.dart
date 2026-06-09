import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cometchat_sdk/cometchat_sdk.dart';

import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';
import 'package:cometchat_chat_uikit/chat_ui/src/message_list/bloc/message_list_bloc.dart';
import 'package:cometchat_chat_uikit/chat_ui/src/message_list/bloc/message_list_event.dart';
import 'package:cometchat_chat_uikit/chat_ui/src/message_list/bloc/message_list_state.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class MockMessageListBloc extends MockBloc<MessageListEvent, MessageListState>
    implements MessageListBloc {}

class FakeUser extends Fake implements User {
  @override
  String get uid => 'test_user';

  @override
  String get name => 'Test User';
}

class FakeGroup extends Fake implements Group {
  @override
  String get guid => 'test_group';

  @override
  String get name => 'Test Group';

  @override
  int get membersCount => 5;
}

class FakeTextMessage extends Fake implements TextMessage {
  final int _id;
  final String _text;

  FakeTextMessage(this._id, {String text = 'Hello'}) : _text = text;

  @override
  int get id => _id;

  @override
  String get text => _text;

  @override
  String get muid => 'muid_$_id';

  @override
  int get parentMessageId => 0;

  @override
  String get type => 'text';

  @override
  String get category => 'message';

  @override
  User? get sender => FakeUser();

  @override
  DateTime? get sentAt => DateTime(2024, 1, 1, 12, 0);

  @override
  DateTime? get readAt => null;

  @override
  DateTime? get deliveredAt => null;

  @override
  int get replyCount => 0;

  @override
  set replyCount(int value) {}
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('CometChatMessageList Props', () {
    // -----------------------------------------------------------------------
    // Constructor assertions
    // -----------------------------------------------------------------------

    test('asserts when neither user nor group is provided', () {
      expect(
        () => CometChatMessageList(),
        throwsA(isA<AssertionError>()),
      );
    });

    test('asserts when both user and group are provided', () {
      expect(
        () => CometChatMessageList(user: FakeUser(), group: FakeGroup()),
        throwsA(isA<AssertionError>()),
      );
    });

    test('creates successfully with user only', () {
      final widget = CometChatMessageList(user: FakeUser());
      expect(widget.user, isNotNull);
      expect(widget.group, isNull);
    });

    test('creates successfully with group only', () {
      final widget = CometChatMessageList(group: FakeGroup());
      expect(widget.group, isNotNull);
      expect(widget.user, isNull);
    });

    // -----------------------------------------------------------------------
    // Default values
    // -----------------------------------------------------------------------

    test('default values are correct', () {
      final widget = CometChatMessageList(user: FakeUser());

      expect(widget.hideDeletedMessages, isFalse);
      expect(widget.disableSoundForMessages, isFalse);
      expect(widget.disableReceipts, isFalse);
      expect(widget.hideReplies, isTrue);
      expect(widget.withParent, isTrue);
      expect(widget.hideDateSeparator, isFalse);
      expect(widget.hideStickyDate, isFalse);
      expect(widget.avatarVisibility, isTrue);
      expect(widget.receiptsVisibility, isTrue);
      expect(widget.disableReactions, isFalse);
      expect(widget.enableSwipeToReply, isTrue);
      expect(widget.hideCopyMessageOption, isFalse);
      expect(widget.hideDeleteMessageOption, isFalse);
      expect(widget.hideEditMessageOption, isFalse);
      expect(widget.hideGroupActionMessages, isFalse);
      expect(widget.hideMessageInfoOption, isFalse);
      expect(widget.hideReplyInThreadOption, isFalse);
      expect(widget.hideReplyOption, isFalse);
      expect(widget.hideTranslateMessageOption, isFalse);
      expect(widget.hideShareMessageOption, isFalse);
      expect(widget.enableConversationStarters, isFalse);
      expect(widget.enableSmartReplies, isFalse);
      expect(widget.hideSuggestedMessages, isFalse);
      expect(widget.startFromUnreadMessages, isFalse);
      expect(widget.showMarkAsUnreadOption, isFalse);
      expect(widget.hideFlagOption, isFalse);
      expect(widget.hideFlagRemarkField, isFalse);
    });

    // -----------------------------------------------------------------------
    // Custom props
    // -----------------------------------------------------------------------

    test('accepts custom parentMessageId', () {
      final widget = CometChatMessageList(
        user: FakeUser(),
        parentMessageId: 42,
      );
      expect(widget.parentMessageId, 42);
    });

    test('accepts custom alignment', () {
      final widget = CometChatMessageList(
        user: FakeUser(),
        alignment: ChatAlignment.leftAligned,
      );
      expect(widget.alignment, ChatAlignment.leftAligned);
    });

    test('accepts external messageListBloc', () {
      final bloc = MockMessageListBloc();
      final widget = CometChatMessageList(
        user: FakeUser(),
        messageListBloc: bloc,
      );
      expect(widget.messageListBloc, bloc);
    });

    test('accepts custom style', () {
      final style = CometChatMessageListStyle();
      final widget = CometChatMessageList(
        user: FakeUser(),
        style: style,
      );
      expect(widget.style, style);
    });

    // -----------------------------------------------------------------------
    // Visibility flags
    // -----------------------------------------------------------------------

    test('hideDeletedMessages can be set to true', () {
      final widget = CometChatMessageList(
        user: FakeUser(),
        hideDeletedMessages: true,
      );
      expect(widget.hideDeletedMessages, isTrue);
    });

    test('disableReceipts can be set to true', () {
      final widget = CometChatMessageList(
        user: FakeUser(),
        disableReceipts: true,
      );
      expect(widget.disableReceipts, isTrue);
    });

    test('hideDateSeparator can be set to true', () {
      final widget = CometChatMessageList(
        user: FakeUser(),
        hideDateSeparator: true,
      );
      expect(widget.hideDateSeparator, isTrue);
    });

    test('disableReactions can be set to true', () {
      final widget = CometChatMessageList(
        user: FakeUser(),
        disableReactions: true,
      );
      expect(widget.disableReactions, isTrue);
    });

    test('enableSwipeToReply can be set to false', () {
      final widget = CometChatMessageList(
        user: FakeUser(),
        enableSwipeToReply: false,
      );
      expect(widget.enableSwipeToReply, isFalse);
    });

    // -----------------------------------------------------------------------
    // Custom views
    // -----------------------------------------------------------------------

    test('accepts custom emptyStateView', () {
      final widget = CometChatMessageList(
        user: FakeUser(),
        emptyStateView: (context) => const Text('Empty'),
      );
      expect(widget.emptyStateView, isNotNull);
    });

    test('accepts custom errorStateView', () {
      final widget = CometChatMessageList(
        user: FakeUser(),
        errorStateView: (context) => const Text('Error'),
      );
      expect(widget.errorStateView, isNotNull);
    });

    test('accepts custom loadingStateView', () {
      final widget = CometChatMessageList(
        user: FakeUser(),
        loadingStateView: (context) => const CircularProgressIndicator(),
      );
      expect(widget.loadingStateView, isNotNull);
    });

    test('accepts custom headerView', () {
      final widget = CometChatMessageList(
        user: FakeUser(),
        headerView: (context, {user, group, parentMessageId}) =>
            const Text('Header'),
      );
      expect(widget.headerView, isNotNull);
    });

    test('accepts custom footerView', () {
      final widget = CometChatMessageList(
        user: FakeUser(),
        footerView: (context, {user, group, parentMessageId}) =>
            const Text('Footer'),
      );
      expect(widget.footerView, isNotNull);
    });

    // -----------------------------------------------------------------------
    // Callbacks
    // -----------------------------------------------------------------------

    test('accepts onError callback', () {
      var called = false;
      final widget = CometChatMessageList(
        user: FakeUser(),
        onError: (e, st) => called = true,
      );
      expect(widget.onError, isNotNull);
    });

    test('accepts onThreadRepliesClick callback', () {
      final widget = CometChatMessageList(
        user: FakeUser(),
        onThreadRepliesClick: (msg, ctx, {template}) {},
      );
      expect(widget.onThreadRepliesClick, isNotNull);
    });

    // -----------------------------------------------------------------------
    // Message action options
    // -----------------------------------------------------------------------

    test('hide options flags work', () {
      final widget = CometChatMessageList(
        user: FakeUser(),
        hideCopyMessageOption: true,
        hideDeleteMessageOption: true,
        hideEditMessageOption: true,
        hideReplyOption: true,
        hideReplyInThreadOption: true,
        hideTranslateMessageOption: true,
        hideShareMessageOption: true,
        hideMessageInfoOption: true,
        hideReactionOption: true,
        hideMessagePrivatelyOption: true,
      );

      expect(widget.hideCopyMessageOption, isTrue);
      expect(widget.hideDeleteMessageOption, isTrue);
      expect(widget.hideEditMessageOption, isTrue);
      expect(widget.hideReplyOption, isTrue);
      expect(widget.hideReplyInThreadOption, isTrue);
      expect(widget.hideTranslateMessageOption, isTrue);
      expect(widget.hideShareMessageOption, isTrue);
      expect(widget.hideMessageInfoOption, isTrue);
      expect(widget.hideReactionOption, isTrue);
      expect(widget.hideMessagePrivatelyOption, isTrue);
    });

    // -----------------------------------------------------------------------
    // Smart features
    // -----------------------------------------------------------------------

    test('smart replies configuration', () {
      final widget = CometChatMessageList(
        user: FakeUser(),
        enableSmartReplies: true,
        smartRepliesDelayDuration: 5000,
        smartRepliesKeywords: const ['hello', 'help'],
      );

      expect(widget.enableSmartReplies, isTrue);
      expect(widget.smartRepliesDelayDuration, 5000);
      expect(widget.smartRepliesKeywords, ['hello', 'help']);
    });

    test('conversation starters configuration', () {
      final widget = CometChatMessageList(
        user: FakeUser(),
        enableConversationStarters: true,
      );
      expect(widget.enableConversationStarters, isTrue);
    });

    // -----------------------------------------------------------------------
    // Mark as unread / Flag
    // -----------------------------------------------------------------------

    test('mark as unread option configuration', () {
      final widget = CometChatMessageList(
        user: FakeUser(),
        showMarkAsUnreadOption: true,
        startFromUnreadMessages: true,
      );
      expect(widget.showMarkAsUnreadOption, isTrue);
      expect(widget.startFromUnreadMessages, isTrue);
    });

    test('flag option configuration', () {
      final widget = CometChatMessageList(
        user: FakeUser(),
        hideFlagOption: true,
        hideFlagRemarkField: true,
      );
      expect(widget.hideFlagOption, isTrue);
      expect(widget.hideFlagRemarkField, isTrue);
    });

    // -----------------------------------------------------------------------
    // Sizing
    // -----------------------------------------------------------------------

    test('accepts custom dimensions', () {
      final widget = CometChatMessageList(
        user: FakeUser(),
        width: 400,
        height: 600,
        padding: const EdgeInsets.all(8),
        margin: const EdgeInsets.all(4),
      );
      expect(widget.width, 400);
      expect(widget.height, 600);
      expect(widget.padding, const EdgeInsets.all(8));
      expect(widget.margin, const EdgeInsets.all(4));
    });
  });
}
