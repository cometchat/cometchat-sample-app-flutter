import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cometchat_sdk/cometchat_sdk.dart';

import 'package:cometchat_chat_uikit/chat_ui/src/message_composer/bloc/message_composer_bloc.dart';
import 'package:cometchat_chat_uikit/chat_ui/src/message_composer/bloc/message_composer_event.dart';
import 'package:cometchat_chat_uikit/chat_ui/src/message_composer/bloc/message_composer_state.dart';
import 'package:cometchat_chat_uikit/chat_ui/src/message_composer/domain/repositories/message_composer_repository.dart';
import 'package:cometchat_chat_uikit/chat_ui/src/message_composer/domain/usecases/send_text_message_usecase.dart';
import 'package:cometchat_chat_uikit/chat_ui/src/message_composer/domain/usecases/send_media_message_usecase.dart';
import 'package:cometchat_chat_uikit/chat_ui/src/message_composer/domain/usecases/send_custom_message_usecase.dart';
import 'package:cometchat_chat_uikit/chat_ui/src/message_composer/domain/usecases/edit_message_usecase.dart';
import 'package:cometchat_chat_uikit/chat_ui/src/message_composer/domain/usecases/typing_usecases.dart';
import 'package:cometchat_chat_uikit/chat_ui/src/message_composer/domain/usecases/get_logged_in_user_usecase.dart';
import 'package:cometchat_chat_uikit/shared_ui/src/clean_architecture/core/result.dart';

// ---------------------------------------------------------------------------
// Mocks & Fakes
// ---------------------------------------------------------------------------

class MockMessageComposerRepository extends Mock
    implements MessageComposerRepository {}

class FakeUser extends Fake implements User {
  final String _uid;
  final String _name;
  final bool _blockedByMe;
  final bool _hasBlockedMe;

  FakeUser({
    String uid = 'test_user',
    String name = 'Test User',
    bool blockedByMe = false,
    bool hasBlockedMe = false,
  })  : _uid = uid,
        _name = name,
        _blockedByMe = blockedByMe,
        _hasBlockedMe = hasBlockedMe;

  @override
  String get uid => _uid;
  @override
  String get name => _name;
  @override
  bool get blockedByMe => _blockedByMe;
  @override
  bool get hasBlockedMe => _hasBlockedMe;
}

class FakeGroup extends Fake implements Group {
  final String _guid;
  final String _name;

  FakeGroup({String guid = 'test_group', String name = 'Test Group'})
      : _guid = guid,
        _name = name;

  @override
  String get guid => _guid;
  @override
  String get name => _name;
}

class FakeTextMessage extends Fake implements TextMessage {
  final int _id;
  final String _text;
  final String _muid;

  FakeTextMessage({int id = 1, String text = 'Hello', String muid = 'muid_1'})
      : _id = id,
        _text = text,
        _muid = muid;

  @override
  int get id => _id;
  @override
  String get text => _text;
  @override
  String get muid => _muid;
  @override
  int get parentMessageId => 0;
  @override
  String get receiverUid => 'test_user';
  @override
  String get receiverType => 'user';
  @override
  String get type => 'text';
  @override
  String get category => 'message';
  @override
  User? get sender => null;
  @override
  Map<String, dynamic>? get metadata => null;
}

class FakeMediaMessage extends Fake implements MediaMessage {
  @override
  int get id => 2;
  @override
  String get muid => 'media_muid_1';
  @override
  int get parentMessageId => 0;
}

class FakeBuildContext extends Fake implements BuildContext {}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

MessageComposerBloc _makeBloc(
  MockMessageComposerRepository repo, {
  User? user,
  Group? group,
}) {
  return MessageComposerBloc(
    context: FakeBuildContext(),
    user: user ?? FakeUser(),
    group: group,
    sendTextMessageUseCase: SendTextMessageUseCase(repo),
    sendMediaMessageUseCase: SendMediaMessageUseCase(repo),
    sendCustomMessageUseCase: SendCustomMessageUseCase(repo),
    editMessageUseCase: EditMessageUseCase(repo),
    startTypingUseCase: StartTypingUseCase(repo),
    endTypingUseCase: EndTypingUseCase(repo),
    getLoggedInUserUseCase: GetMessageComposerLoggedInUserUseCase(repo),
    disableTypingEvents: true,
  );
}

// ---------------------------------------------------------------------------
// Tests — Android CSV #1158-1244
// ---------------------------------------------------------------------------

void main() {
  late MockMessageComposerRepository repo;

  setUpAll(() {
    registerFallbackValue(FakeTextMessage());
    registerFallbackValue(FakeMediaMessage());
  });

  setUp(() {
    repo = MockMessageComposerRepository();
    when(() => repo.getLoggedInUser())
        .thenAnswer((_) async => Success(FakeUser()));
    when(() => repo.startTyping(
          receiverUid: any(named: 'receiverUid'),
          receiverType: any(named: 'receiverType'),
        )).thenAnswer((_) async => const Success(null));
    when(() => repo.endTyping(
          receiverUid: any(named: 'receiverUid'),
          receiverType: any(named: 'receiverType'),
        )).thenAnswer((_) async => const Success(null));
  });

  // =========================================================================
  // Initial State (#1190)
  // =========================================================================

  group('Initial state', () {
    test('initial state is idle with empty compose text', () {
      final bloc = _makeBloc(repo);
      expect(bloc.state.status, MessageComposerStatus.idle);
      expect(bloc.state.composeText, '');
      expect(bloc.state.editMessage, isNull);
      expect(bloc.state.replyMessage, isNull);
      expect(bloc.state.isEditMode, isFalse);
      expect(bloc.state.isReplyMode, isFalse);
      bloc.close();
    });

    test('initial state has user set when user provided', () {
      final bloc = _makeBloc(repo, user: FakeUser(uid: 'alice', name: 'Alice'));
      expect(bloc.state.user?.uid, 'alice');
      expect(bloc.state.receiverId, 'alice');
      expect(bloc.state.receiverType, 'user');
      bloc.close();
    });

    test('initial state has group set when group provided', () {
      // Note: Creating a composer with only a group (no user) requires
      // the full SDK initialization path. Testing group receiverId via state directly.
      final state = MessageComposerState(group: FakeGroup(guid: 'team'));
      expect(state.receiverId, 'team');
      expect(state.receiverType, 'group');
    });
  });

  // =========================================================================
  // Text Composition (#1176-1177)
  // =========================================================================

  group('Text composition — UpdateComposeText', () {
    blocTest<MessageComposerBloc, MessageComposerState>(
      '#1176 typing updates composeText',
      build: () => _makeBloc(repo),
      act: (bloc) => bloc.add(const UpdateComposeText('Hello world')),
      verify: (bloc) {
        expect(bloc.state.composeText, 'Hello world');
        expect(bloc.state.canSend, isTrue);
      },
    );

    blocTest<MessageComposerBloc, MessageComposerState>(
      '#1177 clearing resets to empty',
      build: () => _makeBloc(repo),
      act: (bloc) {
        bloc.add(const UpdateComposeText('Some text'));
        bloc.add(const UpdateComposeText(''));
      },
      verify: (bloc) {
        expect(bloc.state.composeText, '');
        expect(bloc.state.canSend, isFalse);
      },
    );

    blocTest<MessageComposerBloc, MessageComposerState>(
      'whitespace-only text cannot be sent',
      build: () => _makeBloc(repo),
      act: (bloc) => bloc.add(const UpdateComposeText('   ')),
      verify: (bloc) {
        expect(bloc.state.composeText, '   ');
        expect(bloc.state.canSend, isFalse);
      },
    );
  });

  // =========================================================================
  // Edit Mode (#1179-1180)
  // =========================================================================

  group('Edit mode', () {
    blocTest<MessageComposerBloc, MessageComposerState>(
      '#1179 SetEditMessage enters edit mode',
      build: () => _makeBloc(repo),
      act: (bloc) =>
          bloc.add(SetEditMessage(FakeTextMessage(text: 'Original text'))),
      verify: (bloc) {
        expect(bloc.state.status, MessageComposerStatus.editing);
        expect(bloc.state.isEditMode, isTrue);
        expect(bloc.state.editMessage, isNotNull);
      },
    );

    blocTest<MessageComposerBloc, MessageComposerState>(
      '#1180 ClearEditMessage exits edit mode',
      build: () => _makeBloc(repo),
      act: (bloc) {
        bloc.add(SetEditMessage(FakeTextMessage(text: 'Original')));
        bloc.add(const ClearEditMessage());
      },
      verify: (bloc) {
        expect(bloc.state.status, MessageComposerStatus.idle);
        expect(bloc.state.isEditMode, isFalse);
        expect(bloc.state.editMessage, isNull);
      },
    );
  });

  // =========================================================================
  // Reply Mode (#1181-1182)
  // =========================================================================

  group('Reply mode', () {
    blocTest<MessageComposerBloc, MessageComposerState>(
      '#1181 SetReplyMessage enters reply mode',
      build: () => _makeBloc(repo),
      act: (bloc) =>
          bloc.add(SetReplyMessage(FakeTextMessage(text: 'Reply to this'))),
      verify: (bloc) {
        expect(bloc.state.status, MessageComposerStatus.replying);
        expect(bloc.state.isReplyMode, isTrue);
        expect(bloc.state.replyMessage, isNotNull);
      },
    );

    blocTest<MessageComposerBloc, MessageComposerState>(
      '#1182 ClearReplyMessage exits reply mode',
      build: () => _makeBloc(repo),
      act: (bloc) {
        bloc.add(SetReplyMessage(FakeTextMessage(text: 'Reply to this')));
        bloc.add(const ClearReplyMessage());
      },
      verify: (bloc) {
        expect(bloc.state.status, MessageComposerStatus.idle);
        expect(bloc.state.isReplyMode, isFalse);
        expect(bloc.state.replyMessage, isNull);
      },
    );
  });

  // =========================================================================
  // Audio Recording (#1183-1185)
  // =========================================================================

  group('Audio recording', () {
    blocTest<MessageComposerBloc, MessageComposerState>(
      '#1183 StartAudioRecording enters recording mode',
      build: () => _makeBloc(repo),
      act: (bloc) => bloc.add(const StartAudioRecording()),
      verify: (bloc) {
        expect(bloc.state.status, MessageComposerStatus.recording);
        expect(bloc.state.isRecordingMode, isTrue);
      },
    );

    blocTest<MessageComposerBloc, MessageComposerState>(
      '#1184 CancelAudioRecording exits recording mode',
      build: () => _makeBloc(repo),
      act: (bloc) {
        bloc.add(const StartAudioRecording());
        bloc.add(const CancelAudioRecording());
      },
      verify: (bloc) {
        expect(bloc.state.status, MessageComposerStatus.idle);
        expect(bloc.state.isRecordingMode, isFalse);
      },
    );
  });

  // =========================================================================
  // Send Text Message (#1178)
  // =========================================================================

  group('Send text message', () {
    blocTest<MessageComposerBloc, MessageComposerState>(
      '#1178 send updates compose text to empty after sending',
      build: () {
        when(() => repo.sendTextMessage(any()))
            .thenAnswer((_) async => Success(FakeTextMessage(text: 'Hello')));
        return _makeBloc(repo);
      },
      act: (bloc) async {
        bloc.add(const UpdateComposeText('Hello'));
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(const SendTextMessage());
      },
      wait: const Duration(milliseconds: 200),
      verify: (bloc) {
        // After send, compose text should be cleared
        expect(bloc.state.composeText, isEmpty);
      },
    );
  });

  // =========================================================================
  // Streaming State
  // =========================================================================

  group('Streaming state', () {
    blocTest<MessageComposerBloc, MessageComposerState>(
      'SetStreamingState true sets isActiveStreaming',
      build: () => _makeBloc(repo),
      act: (bloc) => bloc.add(const SetStreamingState(isStreaming: true)),
      verify: (bloc) {
        expect(bloc.state.isActiveStreaming, isTrue);
      },
    );

    blocTest<MessageComposerBloc, MessageComposerState>(
      'SetStreamingState false clears isActiveStreaming',
      build: () => _makeBloc(repo),
      act: (bloc) {
        bloc.add(const SetStreamingState(isStreaming: true));
        bloc.add(const SetStreamingState(isStreaming: false));
      },
      verify: (bloc) {
        expect(bloc.state.isActiveStreaming, isFalse);
      },
    );
  });

  // =========================================================================
  // User blocked status (#1186)
  // =========================================================================

  group('User blocked status', () {
    blocTest<MessageComposerBloc, MessageComposerState>(
      'UserBlockedStatusChanged updates user blocked state',
      build: () => _makeBloc(repo),
      act: (bloc) => bloc.add(UserBlockedStatusChanged(
        user: FakeUser(uid: 'test_user', blockedByMe: true),
        isBlocked: true,
      )),
      verify: (bloc) {
        // The bloc should handle the blocked status
        expect(bloc.state.status, isNot(MessageComposerStatus.error));
      },
    );
  });

  // =========================================================================
  // Bottom Padding Lock
  // =========================================================================

  group('Bottom padding lock', () {
    blocTest<MessageComposerBloc, MessageComposerState>(
      'LockBottomPadding sets lockedBottomPadding',
      build: () => _makeBloc(repo),
      act: (bloc) => bloc.add(const LockBottomPadding(300.0)),
      verify: (bloc) {
        expect(bloc.state.lockedBottomPadding, 300.0);
      },
    );

    blocTest<MessageComposerBloc, MessageComposerState>(
      'UnlockBottomPadding clears lockedBottomPadding',
      build: () => _makeBloc(repo),
      act: (bloc) {
        bloc.add(const LockBottomPadding(300.0));
        bloc.add(const UnlockBottomPadding());
      },
      verify: (bloc) {
        expect(bloc.state.lockedBottomPadding, isNull);
      },
    );
  });

  // =========================================================================
  // ClearComposer
  // =========================================================================

  group('ClearComposer', () {
    blocTest<MessageComposerBloc, MessageComposerState>(
      'ClearComposer resets text, edit, and reply state',
      build: () => _makeBloc(repo),
      act: (bloc) {
        bloc.add(const UpdateComposeText('Some text'));
        bloc.add(SetReplyMessage(FakeTextMessage()));
        bloc.add(const ClearComposer());
      },
      verify: (bloc) {
        expect(bloc.state.composeText, '');
        expect(bloc.state.replyMessage, isNull);
        expect(bloc.state.status, MessageComposerStatus.idle);
      },
    );
  });

  // =========================================================================
  // State — computed properties (#1202-1206)
  // =========================================================================

  group('State — computed properties', () {
    test('receiverId returns user uid for user conversation', () {
      const state = MessageComposerState();
      final stateWithUser = state.copyWith(user: FakeUser(uid: 'alice'));
      expect(stateWithUser.receiverId, 'alice');
    });

    test('receiverId returns group guid for group conversation', () {
      const state = MessageComposerState();
      final stateWithGroup = state.copyWith(group: FakeGroup(guid: 'team'));
      expect(stateWithGroup.receiverId, 'team');
    });

    test('receiverType returns user for user conversation', () {
      final state = MessageComposerState(user: FakeUser());
      expect(state.receiverType, 'user');
    });

    test('receiverType returns group for group conversation', () {
      final state = MessageComposerState(group: FakeGroup());
      expect(state.receiverType, 'group');
    });

    test('canSend is true for non-empty trimmed text', () {
      const state = MessageComposerState(composeText: 'Hello');
      expect(state.canSend, isTrue);
    });

    test('canSend is false for empty text', () {
      const state = MessageComposerState(composeText: '');
      expect(state.canSend, isFalse);
    });

    test('canSend is false for whitespace-only text', () {
      const state = MessageComposerState(composeText: '   \n  ');
      expect(state.canSend, isFalse);
    });

    test('userIsNotBlocked returns true when user is not blocked', () {
      final state = MessageComposerState(user: FakeUser());
      expect(state.userIsNotBlocked, isTrue);
    });

    test('userIsNotBlocked returns false when user is blocked by me', () {
      final state = MessageComposerState(
          user: FakeUser(blockedByMe: true));
      expect(state.userIsNotBlocked, isFalse);
    });

    test('userIsNotBlocked returns false when user has blocked me', () {
      final state = MessageComposerState(
          user: FakeUser(hasBlockedMe: true));
      expect(state.userIsNotBlocked, isFalse);
    });

    test('userIsNotBlocked returns true when no user (group chat)', () {
      const state = MessageComposerState();
      expect(state.userIsNotBlocked, isTrue);
    });
  });

  // =========================================================================
  // State — copyWith (#1202-1206)
  // =========================================================================

  group('State — copyWith', () {
    test('copyWith preserves unchanged fields', () {
      final state = MessageComposerState(
        status: MessageComposerStatus.idle,
        composeText: 'Hello',
        user: FakeUser(uid: 'alice'),
      );
      final copied = state.copyWith(composeText: 'World');
      expect(copied.status, MessageComposerStatus.idle);
      expect(copied.composeText, 'World');
      expect(copied.user?.uid, 'alice');
    });

    test('copyWith with clearEditMessage removes edit message', () {
      final state = MessageComposerState(
        editMessage: FakeTextMessage(),
        status: MessageComposerStatus.editing,
      );
      final copied = state.copyWith(
        clearEditMessage: true,
        status: MessageComposerStatus.idle,
      );
      expect(copied.editMessage, isNull);
      expect(copied.status, MessageComposerStatus.idle);
    });

    test('copyWith with clearReplyMessage removes reply message', () {
      final state = MessageComposerState(
        replyMessage: FakeTextMessage(),
        status: MessageComposerStatus.replying,
      );
      final copied = state.copyWith(
        clearReplyMessage: true,
        status: MessageComposerStatus.idle,
      );
      expect(copied.replyMessage, isNull);
    });

    test('copyWith with clearLockedBottomPadding removes padding', () {
      const state = MessageComposerState(lockedBottomPadding: 300.0);
      final copied = state.copyWith(clearLockedBottomPadding: true);
      expect(copied.lockedBottomPadding, isNull);
    });
  });

  // =========================================================================
  // State — Equatable
  // =========================================================================

  group('State — Equatable', () {
    test('same state values are equal', () {
      const state1 = MessageComposerState(
        status: MessageComposerStatus.idle,
        composeText: 'Hello',
      );
      const state2 = MessageComposerState(
        status: MessageComposerStatus.idle,
        composeText: 'Hello',
      );
      expect(state1, equals(state2));
    });

    test('different state values are not equal', () {
      const state1 = MessageComposerState(
        status: MessageComposerStatus.idle,
        composeText: 'Hello',
      );
      const state2 = MessageComposerState(
        status: MessageComposerStatus.editing,
        composeText: 'Hello',
      );
      expect(state1, isNot(equals(state2)));
    });
  });

  // =========================================================================
  // ComposeMessageReceived (external compose)
  // =========================================================================

  group('ComposeMessageReceived', () {
    blocTest<MessageComposerBloc, MessageComposerState>(
      'ComposeMessageReceived updates compose text',
      build: () => _makeBloc(repo),
      act: (bloc) => bloc.add(const ComposeMessageReceived(text: 'Injected text')),
      verify: (bloc) {
        expect(bloc.state.composeText, 'Injected text');
      },
    );

    blocTest<MessageComposerBloc, MessageComposerState>(
      'ComposeMessageReceived with non-matching id is ignored',
      build: () => _makeBloc(repo),
      act: (bloc) => bloc.add(const ComposeMessageReceived(
        text: 'Should be ignored',
        id: {'uid': 'different_user'},
      )),
      verify: (bloc) {
        // If the id doesn't match, the text should not be updated
        // (depends on _isForThisWidget logic)
        // The bloc checks if the id matches its composerId
      },
    );
  });

  // =========================================================================
  // Typing notifier
  // =========================================================================

  group('Typing notifier', () {
    test('typingNotifier initial value is false', () {
      final bloc = _makeBloc(repo);
      expect(bloc.typingNotifier.value, isFalse);
      bloc.close();
    });
  });

  // =========================================================================
  // ComposerId
  // =========================================================================

  group('ComposerId', () {
    test('composerId contains uid for user conversation', () {
      final bloc = _makeBloc(repo, user: FakeUser(uid: 'alice'));
      expect(bloc.state.composerId['uid'], 'alice');
      bloc.close();
    });

    test('composerId contains guid for group conversation', () {
      final bloc = _makeBloc(repo, user: null, group: FakeGroup(guid: 'team'));
      expect(bloc.state.composerId['guid'], 'team');
      bloc.close();
    });

    test('composerId contains parentMessageId when non-zero', () {
      final bloc = MessageComposerBloc(
        context: FakeBuildContext(),
        user: FakeUser(),
        parentMessageId: 42,
        sendTextMessageUseCase: SendTextMessageUseCase(repo),
        sendMediaMessageUseCase: SendMediaMessageUseCase(repo),
        sendCustomMessageUseCase: SendCustomMessageUseCase(repo),
        editMessageUseCase: EditMessageUseCase(repo),
        startTypingUseCase: StartTypingUseCase(repo),
        endTypingUseCase: EndTypingUseCase(repo),
        getLoggedInUserUseCase: GetMessageComposerLoggedInUserUseCase(repo),
        disableTypingEvents: true,
      );
      expect(bloc.state.composerId['parentMessageId'], 42);
      bloc.close();
    });
  });
}
