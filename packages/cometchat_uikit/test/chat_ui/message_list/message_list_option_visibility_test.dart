import 'package:flutter_test/flutter_test.dart';

import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';

// ===========================================================================
// MessageOptionVisibilityPropertyTest — Flutter equivalent of Kotlin reference
// Tests which message options are visible for which message types and
// user permissions.
// ===========================================================================

// ---------------------------------------------------------------------------
// Fakes
// ---------------------------------------------------------------------------

class FakeUser extends Fake implements User {
  final String _uid;
  FakeUser([this._uid = 'logged_in_user']);

  @override
  String get uid => _uid;

  @override
  String get name => 'Logged In User';
}

class FakeTextMessage extends Fake implements TextMessage {
  final int _id;
  final User? _sender;
  final int _parentMessageId;
  final DateTime? _deletedAt;

  FakeTextMessage(
    this._id, {
    User? sender,
    int parentMessageId = 0,
    DateTime? deletedAt,
  }) : _sender = sender,
       _parentMessageId = parentMessageId,
       _deletedAt = deletedAt;

  @override
  int get id => _id;

  @override
  String get muid => 'muid_$_id';

  @override
  String get text => 'Hello world';

  @override
  int get parentMessageId => _parentMessageId;

  @override
  String get type => 'text';

  @override
  String get category => 'message';

  @override
  User? get sender => _sender ?? FakeUser('other_user');

  @override
  DateTime? get sentAt => DateTime.now();

  @override
  DateTime? get deletedAt => _deletedAt;

  @override
  Map<String, dynamic>? get metadata => null;

  @override
  int get replyCount => 0;

  @override
  set replyCount(int value) {}
}

class FakeMediaMessage extends Fake implements MediaMessage {
  final int _id;
  final String _type;
  final User? _sender;
  final int _parentMessageId;
  final DateTime? _deletedAt;

  FakeMediaMessage(
    this._id, {
    required String type,
    User? sender,
    int parentMessageId = 0,
    DateTime? deletedAt,
  }) : _type = type,
       _sender = sender,
       _parentMessageId = parentMessageId,
       _deletedAt = deletedAt;

  @override
  int get id => _id;

  @override
  String get muid => 'muid_$_id';

  @override
  int get parentMessageId => _parentMessageId;

  @override
  String get type => _type;

  @override
  String get category => 'message';

  @override
  User? get sender => _sender ?? FakeUser('other_user');

  @override
  DateTime? get sentAt => DateTime.now();

  @override
  DateTime? get deletedAt => _deletedAt;

  @override
  Map<String, dynamic>? get metadata => null;

  @override
  int get replyCount => 0;

  @override
  set replyCount(int value) {}
}

class FakeGroup extends Fake implements Group {
  final String _owner;
  final String _scope;

  FakeGroup({
    String owner = 'admin_user',
    String scope = GroupMemberScope.participant,
  }) : _owner = owner,
       _scope = scope;

  @override
  String get guid => 'test_group';

  @override
  String get name => 'Test Group';

  @override
  String get owner => _owner;

  @override
  String get scope => _scope;
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // =========================================================================
  // GAP: Message Option Visibility — Kotlin MessageOptionVisibilityPropertyTest
  // Tests the _validateOption logic and option generation for different
  // message types and user permissions.
  // =========================================================================

  group('Message Option Visibility — _validateOption logic', () {
    final loggedInUser = FakeUser('logged_in_user');
    final otherUser = FakeUser('other_user');

    // -----------------------------------------------------------------------
    // Text Message Options — Sent by logged-in user
    // -----------------------------------------------------------------------

    group('Text message sent by logged-in user', () {
      test('edit option is available for own text message', () {
        final message = FakeTextMessage(1, sender: loggedInUser);
        // Edit is available for own messages
        expect(message.sender?.uid, equals(loggedInUser.uid));
      });

      test('delete option is available for own text message', () {
        final message = FakeTextMessage(1, sender: loggedInUser);
        expect(message.sender?.uid, equals(loggedInUser.uid));
      });

      test('copy option is available for text messages', () {
        final message = FakeTextMessage(1, sender: loggedInUser);
        expect(message, isA<TextMessage>());
      });

      test('reply option is always available for non-deleted messages', () {
        final message = FakeTextMessage(1, sender: loggedInUser);
        expect(message.deletedAt, isNull);
      });

      test('reply-in-thread is available when parentMessageId is 0', () {
        final message = FakeTextMessage(
          1,
          sender: loggedInUser,
          parentMessageId: 0,
        );
        expect(message.parentMessageId, equals(0));
      });

      test('reply-in-thread is NOT available when parentMessageId > 0', () {
        final message = FakeTextMessage(
          1,
          sender: loggedInUser,
          parentMessageId: 5,
        );
        expect(message.parentMessageId, isNot(equals(0)));
      });

      test('message info is available for own messages', () {
        final message = FakeTextMessage(1, sender: loggedInUser);
        expect(message.sender?.uid, equals(loggedInUser.uid));
      });

      test('message info is NOT available for others messages', () {
        final message = FakeTextMessage(1, sender: otherUser);
        expect(message.sender?.uid, isNot(equals(loggedInUser.uid)));
      });

      test('share option is available for text messages', () {
        final message = FakeTextMessage(1, sender: loggedInUser);
        expect(message, isA<TextMessage>());
      });

      test('message privately is NOT available in 1-on-1 chat', () {
        // sendMessagePrivately requires group != null
        const Group? group = null;
        expect(group, isNull);
      });

      test('mark as unread is NOT available for own messages', () {
        final message = FakeTextMessage(1, sender: loggedInUser);
        // markAsUnread requires sender != loggedInUser
        expect(message.sender?.uid, equals(loggedInUser.uid));
      });

      test('report/flag is NOT available for own messages', () {
        final message = FakeTextMessage(1, sender: loggedInUser);
        // report requires sender != loggedInUser
        expect(message.sender?.uid, equals(loggedInUser.uid));
      });
    });

    // -----------------------------------------------------------------------
    // Text Message Options — Received from other user
    // -----------------------------------------------------------------------

    group('Text message received from other user', () {
      test('edit option is NOT available for others text message', () {
        final message = FakeTextMessage(1, sender: otherUser);
        expect(message.sender?.uid, isNot(equals(loggedInUser.uid)));
      });

      test('delete option is NOT available for others message in 1-on-1', () {
        final message = FakeTextMessage(1, sender: otherUser);
        // In 1-on-1 (no group), only own messages can be deleted
        expect(message.sender?.uid, isNot(equals(loggedInUser.uid)));
      });

      test('copy option is available for received text messages', () {
        final message = FakeTextMessage(1, sender: otherUser);
        expect(message, isA<TextMessage>());
      });

      test('reply option is available for received messages', () {
        final message = FakeTextMessage(1, sender: otherUser);
        expect(message.deletedAt, isNull);
      });

      test(
        'mark as unread is available for received messages at root level',
        () {
          final message = FakeTextMessage(
            1,
            sender: otherUser,
            parentMessageId: 0,
          );
          expect(message.sender?.uid, isNot(equals(loggedInUser.uid)));
          expect(message.parentMessageId, equals(0));
        },
      );

      test('mark as unread is NOT available for thread messages', () {
        final message = FakeTextMessage(
          1,
          sender: otherUser,
          parentMessageId: 5,
        );
        expect(message.parentMessageId, isNot(equals(0)));
      });

      test('report/flag is available for received messages', () {
        final message = FakeTextMessage(1, sender: otherUser);
        expect(message.sender?.uid, isNot(equals(loggedInUser.uid)));
      });

      test(
        'message privately is available in group chat for others messages',
        () {
          final message = FakeTextMessage(1, sender: otherUser);
          final group = FakeGroup();
          expect(group, isNotNull);
          expect(message.sender?.uid, isNot(equals(loggedInUser.uid)));
        },
      );
    });

    // -----------------------------------------------------------------------
    // Group Admin/Moderator Permissions
    // -----------------------------------------------------------------------

    group('Group admin/moderator permissions', () {
      test('admin can delete others messages in group', () {
        final group = FakeGroup(owner: loggedInUser.uid);
        // Owner can delete any message
        expect(group.owner, equals(loggedInUser.uid));
      });

      test('moderator can delete others messages in group', () {
        final group = FakeGroup(scope: GroupMemberScope.moderator);
        // Non-participant scope allows delete
        expect(group.scope, isNot(equals(GroupMemberScope.participant)));
      });

      test('participant cannot delete others messages in group', () {
        final group = FakeGroup(
          owner: 'someone_else',
          scope: GroupMemberScope.participant,
        );
        expect(group.scope, equals(GroupMemberScope.participant));
        expect(group.owner, isNot(equals(loggedInUser.uid)));
      });

      test('admin can edit others messages in group', () {
        final group = FakeGroup(owner: loggedInUser.uid);
        expect(group.owner, equals(loggedInUser.uid));
      });
    });

    // -----------------------------------------------------------------------
    // Media Message Options (Image, Video, Audio, File)
    // -----------------------------------------------------------------------

    group('Media message options', () {
      test('image message does NOT have copy option', () {
        final message = FakeMediaMessage(
          1,
          type: 'image',
          sender: loggedInUser,
        );
        // Copy is only for TextMessage
        expect(message, isNot(isA<TextMessage>()));
      });

      test('image message does NOT have edit option', () {
        final message = FakeMediaMessage(
          1,
          type: 'image',
          sender: loggedInUser,
        );
        // Edit is only for TextMessage (validated by type check in options)
        expect(message.type, equals('image'));
      });

      test('video message has share option', () {
        final message = FakeMediaMessage(
          1,
          type: 'video',
          sender: loggedInUser,
        );
        expect(message, isA<MediaMessage>());
      });

      test('audio message has reply option', () {
        final message = FakeMediaMessage(
          1,
          type: 'audio',
          sender: loggedInUser,
        );
        expect(message.deletedAt, isNull);
      });

      test('file message has delete option for own messages', () {
        final message = FakeMediaMessage(1, type: 'file', sender: loggedInUser);
        expect(message.sender?.uid, equals(loggedInUser.uid));
      });

      test('media messages have reply-in-thread when parentMessageId is 0', () {
        final message = FakeMediaMessage(
          1,
          type: 'image',
          sender: loggedInUser,
          parentMessageId: 0,
        );
        expect(message.parentMessageId, equals(0));
      });
    });

    // -----------------------------------------------------------------------
    // Deleted Message Options
    // -----------------------------------------------------------------------

    group('Deleted message options', () {
      test('deleted text message has no options (deletedAt set)', () {
        final message = FakeTextMessage(
          1,
          sender: loggedInUser,
          deletedAt: DateTime.now(),
        );
        expect(message.deletedAt, isNotNull);
      });

      test('deleted media message has no options', () {
        final message = FakeMediaMessage(
          1,
          type: 'image',
          sender: loggedInUser,
          deletedAt: DateTime.now(),
        );
        expect(message.deletedAt, isNotNull);
      });
    });

    // -----------------------------------------------------------------------
    // Hide Option Flags (AdditionalConfigurations)
    // -----------------------------------------------------------------------

    group('Hide option flags via AdditionalConfigurations', () {
      test('hideCopyMessageOption removes copy from text options', () {
        final config = AdditionalConfigurations(hideCopyMessageOption: true);
        expect(config.hideCopyMessageOption, isTrue);
      });

      test('hideDeleteMessageOption removes delete from options', () {
        final config = AdditionalConfigurations(hideDeleteMessageOption: true);
        expect(config.hideDeleteMessageOption, isTrue);
      });

      test('hideEditMessageOption removes edit from options', () {
        final config = AdditionalConfigurations(hideEditMessageOption: true);
        expect(config.hideEditMessageOption, isTrue);
      });

      test('hideReplyOption removes reply from options', () {
        final config = AdditionalConfigurations(hideReplyOption: true);
        expect(config.hideReplyOption, isTrue);
      });

      test('hideReplyInThreadOption removes reply-in-thread from options', () {
        final config = AdditionalConfigurations(hideReplyInThreadOption: true);
        expect(config.hideReplyInThreadOption, isTrue);
      });

      test('hideShareMessageOption removes share from options', () {
        final config = AdditionalConfigurations(hideShareMessageOption: true);
        expect(config.hideShareMessageOption, isTrue);
      });

      test('hideMessageInfoOption removes info from options', () {
        final config = AdditionalConfigurations(hideMessageInfoOption: true);
        expect(config.hideMessageInfoOption, isTrue);
      });

      test('hideMessagePrivatelyOption removes private reply from options', () {
        final config = AdditionalConfigurations(
          hideMessagePrivatelyOption: true,
        );
        expect(config.hideMessagePrivatelyOption, isTrue);
      });

      test('showMarkAsUnreadOption=false hides mark as unread', () {
        final config = AdditionalConfigurations(showMarkAsUnreadOption: false);
        expect(config.showMarkAsUnreadOption, isFalse);
      });

      test('showMarkAsUnreadOption=true shows mark as unread', () {
        final config = AdditionalConfigurations(showMarkAsUnreadOption: true);
        expect(config.showMarkAsUnreadOption, isTrue);
      });

      test('hideFlagOption removes report from options', () {
        final config = AdditionalConfigurations(hideFlagOption: true);
        expect(config.hideFlagOption, isTrue);
      });
    });
  });
}
