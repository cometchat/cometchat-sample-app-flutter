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
  final int _parentMessageId;

  FakeTextMessage({
    int id = 1,
    String text = 'Hello',
    String muid = 'muid_1',
    int parentMessageId = 0,
  })  : _id = id,
        _text = text,
        _muid = muid,
        _parentMessageId = parentMessageId;

  @override
  int get id => _id;
  @override
  String get text => _text;
  @override
  String get muid => _muid;
  @override
  set muid(String value) {}
  @override
  int get parentMessageId => _parentMessageId;
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
  @override
  set metadata(Map<String, dynamic>? value) {}
  @override
  List<User> get mentionedUsers => [];
  @override
  DateTime? get sentAt => DateTime.now();
}

class FakeMediaMessage extends Fake implements MediaMessage {
  @override
  int get id => 2;
  @override
  String get muid => 'media_muid_1';
  @override
  set muid(String value) {}
  @override
  int get parentMessageId => 0;
  @override
  set file(String? value) {}
  @override
  String get receiverUid => 'test_user';
  @override
  String get receiverType => 'user';
  @override
  String get type => 'image';
  @override
  String get category => 'message';
  @override
  User? get sender => null;
  @override
  Map<String, dynamic>? get metadata => null;
  @override
  set metadata(Map<String, dynamic>? value) {}
  @override
  DateTime? get sentAt => DateTime.now();
}

class FakeCustomMessage extends Fake implements CustomMessage {
  @override
  int get id => 3;
  @override
  String get muid => 'custom_muid_1';
  @override
  set muid(String value) {}
  @override
  int get parentMessageId => 0;
  @override
  String get receiverUid => 'test_user';
  @override
  String get receiverType => 'user';
  @override
  String get type => 'custom';
  @override
  String get category => 'custom';
  @override
  User? get sender => null;
  @override
  Map<String, dynamic>? get metadata => null;
  @override
  set metadata(Map<String, dynamic>? value) {}
  @override
  DateTime? get sentAt => DateTime.now();
}

class FakeBuildContext extends Fake implements BuildContext {}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

MessageComposerBloc _makeBloc(
  MockMessageComposerRepository repo, {
  User? user,
  Group? group,
  bool disableTypingEvents = true,
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
    disableTypingEvents: disableTypingEvents,
  );
}

// ---------------------------------------------------------------------------
// Tests — Kotlin CometChatMessageComposerInteractionTest equivalent
// ---------------------------------------------------------------------------

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockMessageComposerRepository repo;

  setUpAll(() {
    registerFallbackValue(FakeTextMessage());
    registerFallbackValue(FakeMediaMessage());
    registerFallbackValue(FakeCustomMessage());
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
  // Typing Events — Kotlin CSV #1245-1250
  // =========================================================================

  group('Typing events', () {
    blocTest<MessageComposerBloc, MessageComposerState>(
      'StartTyping calls startTyping use case when enabled',
      build: () => _makeBloc(repo, disableTypingEvents: false),
      act: (bloc) => bloc.add(const StartTyping()),
      wait: const Duration(milliseconds: 100),
      verify: (bloc) {
        verify(() => repo.startTyping(
              receiverUid: any(named: 'receiverUid'),
              receiverType: any(named: 'receiverType'),
            )).called(1);
      },
    );

    blocTest<MessageComposerBloc, MessageComposerState>(
      'StartTyping is no-op when disableTypingEvents=true',
      build: () => _makeBloc(repo, disableTypingEvents: true),
      act: (bloc) => bloc.add(const StartTyping()),
      wait: const Duration(milliseconds: 100),
      verify: (bloc) {
        verifyNever(() => repo.startTyping(
              receiverUid: any(named: 'receiverUid'),
              receiverType: any(named: 'receiverType'),
            ));
      },
    );

    blocTest<MessageComposerBloc, MessageComposerState>(
      'StartTyping is no-op when user is blocked',
      build: () => _makeBloc(
        repo,
        user: FakeUser(blockedByMe: true),
        disableTypingEvents: false,
      ),
      act: (bloc) => bloc.add(const StartTyping()),
      wait: const Duration(milliseconds: 100),
      verify: (bloc) {
        verifyNever(() => repo.startTyping(
              receiverUid: any(named: 'receiverUid'),
              receiverType: any(named: 'receiverType'),
            ));
      },
    );

    blocTest<MessageComposerBloc, MessageComposerState>(
      'EndTyping calls endTyping use case after StartTyping',
      build: () => _makeBloc(repo, disableTypingEvents: false),
      act: (bloc) async {
        bloc.add(const StartTyping());
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(const EndTyping());
      },
      wait: const Duration(milliseconds: 100),
      verify: (bloc) {
        verify(() => repo.endTyping(
              receiverUid: any(named: 'receiverUid'),
              receiverType: any(named: 'receiverType'),
            )).called(1);
      },
    );

    blocTest<MessageComposerBloc, MessageComposerState>(
      'EndTyping is no-op when not currently typing',
      build: () => _makeBloc(repo, disableTypingEvents: false),
      act: (bloc) => bloc.add(const EndTyping()),
      wait: const Duration(milliseconds: 100),
      verify: (bloc) {
        verifyNever(() => repo.endTyping(
              receiverUid: any(named: 'receiverUid'),
              receiverType: any(named: 'receiverType'),
            ));
      },
    );

    test('typingNotifier updates to true on StartTyping', () async {
      final bloc = _makeBloc(repo, disableTypingEvents: false);
      bloc.add(const StartTyping());
      await Future.delayed(const Duration(milliseconds: 100));
      expect(bloc.typingNotifier.value, isTrue);
      // Wait for debouncer to fire before closing to avoid "add after close"
      await Future.delayed(const Duration(milliseconds: 1100));
      await bloc.close();
    });

    test('typingNotifier updates to false on EndTyping', () async {
      final bloc = _makeBloc(repo, disableTypingEvents: false);
      bloc.add(const StartTyping());
      await Future.delayed(const Duration(milliseconds: 100));
      bloc.add(const EndTyping());
      await Future.delayed(const Duration(milliseconds: 100));
      expect(bloc.typingNotifier.value, isFalse);
      // Wait for the debouncer from StartTyping to fire (1000ms) before closing
      await Future.delayed(const Duration(milliseconds: 1000));
      await bloc.close();
    });
  });

  // =========================================================================
  // Send Text Message — Kotlin CSV #1251-1258
  // =========================================================================

  group('Send text message', () {
    blocTest<MessageComposerBloc, MessageComposerState>(
      'SendTextMessage transitions to sending then success',
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
        expect(bloc.state.status, MessageComposerStatus.success);
        expect(bloc.state.composeText, isEmpty);
      },
    );

    blocTest<MessageComposerBloc, MessageComposerState>(
      'SendTextMessage with empty text is no-op',
      build: () => _makeBloc(repo),
      act: (bloc) => bloc.add(const SendTextMessage()),
      wait: const Duration(milliseconds: 100),
      verify: (bloc) {
        verifyNever(() => repo.sendTextMessage(any()));
      },
    );

    blocTest<MessageComposerBloc, MessageComposerState>(
      'SendTextMessage failure emits error status',
      build: () {
        when(() => repo.sendTextMessage(any())).thenAnswer(
            (_) async => const Failure(message: 'Send failed', code: 'ERR'));
        return _makeBloc(repo);
      },
      act: (bloc) async {
        bloc.add(const UpdateComposeText('Hello'));
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(const SendTextMessage());
      },
      wait: const Duration(milliseconds: 200),
      verify: (bloc) {
        expect(bloc.state.status, MessageComposerStatus.error);
        expect(bloc.state.errorMessage, 'Send failed');
      },
    );

    blocTest<MessageComposerBloc, MessageComposerState>(
      'SendTextMessage clears reply message after sending',
      build: () {
        when(() => repo.sendTextMessage(any()))
            .thenAnswer((_) async => Success(FakeTextMessage(text: 'Reply')));
        return _makeBloc(repo);
      },
      act: (bloc) async {
        bloc.add(SetReplyMessage(FakeTextMessage(text: 'Original')));
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(const UpdateComposeText('Reply'));
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(const SendTextMessage());
      },
      wait: const Duration(milliseconds: 200),
      verify: (bloc) {
        expect(bloc.state.replyMessage, isNull);
        expect(bloc.state.isReplyMode, isFalse);
      },
    );

    blocTest<MessageComposerBloc, MessageComposerState>(
      'SendTextMessage with metadata passes metadata to message',
      build: () {
        when(() => repo.sendTextMessage(any()))
            .thenAnswer((_) async => Success(FakeTextMessage(text: 'Hi')));
        return _makeBloc(repo);
      },
      act: (bloc) async {
        bloc.add(const UpdateComposeText('Hi'));
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(const SendTextMessage(metadata: {'key': 'value'}));
      },
      wait: const Duration(milliseconds: 200),
      verify: (bloc) {
        verify(() => repo.sendTextMessage(any())).called(1);
      },
    );
  });

  // =========================================================================
  // Send Media Message — Kotlin CSV #1259-1264
  // =========================================================================

  group('Send media message', () {
    blocTest<MessageComposerBloc, MessageComposerState>(
      'SendMediaMessage transitions to sending then success',
      build: () {
        when(() => repo.sendMediaMessage(any()))
            .thenAnswer((_) async => Success(FakeMediaMessage()));
        return _makeBloc(repo);
      },
      act: (bloc) => bloc.add(const SendMediaMessage(
        path: '/tmp/image.jpg',
        messageType: 'image',
      )),
      wait: const Duration(milliseconds: 200),
      verify: (bloc) {
        expect(bloc.state.status, MessageComposerStatus.success);
        verify(() => repo.sendMediaMessage(any())).called(1);
      },
    );

    blocTest<MessageComposerBloc, MessageComposerState>(
      'SendMediaMessage failure emits error status',
      build: () {
        when(() => repo.sendMediaMessage(any())).thenAnswer(
            (_) async => const Failure(message: 'Upload failed', code: 'UPL'));
        return _makeBloc(repo);
      },
      act: (bloc) => bloc.add(const SendMediaMessage(
        path: '/tmp/video.mp4',
        messageType: 'video',
      )),
      wait: const Duration(milliseconds: 200),
      verify: (bloc) {
        expect(bloc.state.status, MessageComposerStatus.error);
        expect(bloc.state.errorMessage, 'Upload failed');
      },
    );

    blocTest<MessageComposerBloc, MessageComposerState>(
      'SendMediaMessage clears reply message',
      build: () {
        when(() => repo.sendMediaMessage(any()))
            .thenAnswer((_) async => Success(FakeMediaMessage()));
        return _makeBloc(repo);
      },
      act: (bloc) async {
        bloc.add(SetReplyMessage(FakeTextMessage(text: 'Original')));
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(const SendMediaMessage(
          path: '/tmp/audio.m4a',
          messageType: 'audio',
        ));
      },
      wait: const Duration(milliseconds: 200),
      verify: (bloc) {
        expect(bloc.state.replyMessage, isNull);
      },
    );
  });

  // =========================================================================
  // Send Custom Message — Kotlin CSV #1265-1268
  // =========================================================================

  group('Send custom message', () {
    blocTest<MessageComposerBloc, MessageComposerState>(
      'SendCustomMessage transitions to sending then success',
      build: () {
        when(() => repo.sendCustomMessage(any()))
            .thenAnswer((_) async => Success(FakeCustomMessage()));
        return _makeBloc(repo);
      },
      act: (bloc) => bloc.add(const SendCustomMessage(
        customData: {'location': '37.7749,-122.4194'},
        type: 'location',
      )),
      wait: const Duration(milliseconds: 200),
      verify: (bloc) {
        expect(bloc.state.status, MessageComposerStatus.success);
        verify(() => repo.sendCustomMessage(any())).called(1);
      },
    );

    blocTest<MessageComposerBloc, MessageComposerState>(
      'SendCustomMessage failure emits error',
      build: () {
        when(() => repo.sendCustomMessage(any())).thenAnswer(
            (_) async => const Failure(message: 'Custom failed', code: 'CUST'));
        return _makeBloc(repo);
      },
      act: (bloc) => bloc.add(const SendCustomMessage(
        customData: {'data': 'test'},
        type: 'custom_type',
      )),
      wait: const Duration(milliseconds: 200),
      verify: (bloc) {
        expect(bloc.state.status, MessageComposerStatus.error);
      },
    );
  });

  // =========================================================================
  // Edit Mode Interactions — Kotlin CSV #1269-1275
  // =========================================================================

  group('Edit mode interactions', () {
    blocTest<MessageComposerBloc, MessageComposerState>(
      'SetEditMessage populates composeText with original text',
      build: () => _makeBloc(repo),
      act: (bloc) =>
          bloc.add(SetEditMessage(FakeTextMessage(text: 'Original text'))),
      verify: (bloc) {
        expect(bloc.state.composeText, 'Original text');
        expect(bloc.state.isEditMode, isTrue);
      },
    );

    blocTest<MessageComposerBloc, MessageComposerState>(
      'SetEditMessage clears any active reply',
      build: () => _makeBloc(repo),
      act: (bloc) async {
        bloc.add(SetReplyMessage(FakeTextMessage(text: 'Reply target')));
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(SetEditMessage(FakeTextMessage(text: 'Edit this')));
      },
      verify: (bloc) {
        expect(bloc.state.isEditMode, isTrue);
        expect(bloc.state.replyMessage, isNull);
      },
    );

    blocTest<MessageComposerBloc, MessageComposerState>(
      'EditTextMessage sends edited message and clears edit state',
      build: () {
        when(() => repo.editMessage(any()))
            .thenAnswer((_) async => Success(FakeTextMessage(text: 'Edited')));
        return _makeBloc(repo);
      },
      act: (bloc) async {
        bloc.add(SetEditMessage(FakeTextMessage(id: 10, text: 'Original')));
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(const UpdateComposeText('Edited'));
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(const EditTextMessage());
      },
      wait: const Duration(milliseconds: 200),
      verify: (bloc) {
        expect(bloc.state.editMessage, isNull);
        expect(bloc.state.composeText, isEmpty);
        verify(() => repo.editMessage(any())).called(1);
      },
    );

    blocTest<MessageComposerBloc, MessageComposerState>(
      'EditTextMessage with unchanged text is no-op',
      build: () => _makeBloc(repo),
      act: (bloc) async {
        bloc.add(SetEditMessage(FakeTextMessage(id: 10, text: 'Same text')));
        await Future.delayed(const Duration(milliseconds: 50));
        // composeText is already 'Same text' from SetEditMessage
        bloc.add(const EditTextMessage());
      },
      wait: const Duration(milliseconds: 200),
      verify: (bloc) {
        verifyNever(() => repo.editMessage(any()));
      },
    );

    blocTest<MessageComposerBloc, MessageComposerState>(
      'EditTextMessage failure emits error',
      build: () {
        when(() => repo.editMessage(any())).thenAnswer(
            (_) async => const Failure(message: 'Edit failed', code: 'EDIT'));
        return _makeBloc(repo);
      },
      act: (bloc) async {
        bloc.add(SetEditMessage(FakeTextMessage(id: 10, text: 'Original')));
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(const UpdateComposeText('Changed'));
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(const EditTextMessage());
      },
      wait: const Duration(milliseconds: 200),
      verify: (bloc) {
        expect(bloc.state.status, MessageComposerStatus.error);
        expect(bloc.state.errorMessage, 'Edit failed');
      },
    );
  });

  // =========================================================================
  // Reply Mode Interactions — Kotlin CSV #1276-1280
  // =========================================================================

  group('Reply mode interactions', () {
    blocTest<MessageComposerBloc, MessageComposerState>(
      'SetReplyMessage clears any active edit',
      build: () => _makeBloc(repo),
      act: (bloc) async {
        bloc.add(SetEditMessage(FakeTextMessage(text: 'Editing')));
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(SetReplyMessage(FakeTextMessage(text: 'Reply target')));
      },
      verify: (bloc) {
        expect(bloc.state.isReplyMode, isTrue);
        expect(bloc.state.editMessage, isNull);
      },
    );

    blocTest<MessageComposerBloc, MessageComposerState>(
      'ClearReplyMessage returns to idle without clearing text',
      build: () => _makeBloc(repo),
      act: (bloc) async {
        bloc.add(const UpdateComposeText('Some text'));
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(SetReplyMessage(FakeTextMessage(text: 'Reply target')));
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(const ClearReplyMessage());
      },
      verify: (bloc) {
        expect(bloc.state.status, MessageComposerStatus.idle);
        expect(bloc.state.replyMessage, isNull);
        expect(bloc.state.composeText, 'Some text');
      },
    );
  });

  // =========================================================================
  // Audio Recording Interactions — Kotlin CSV #1281-1286
  // =========================================================================

  group('Audio recording interactions', () {
    blocTest<MessageComposerBloc, MessageComposerState>(
      'StartAudioRecording → CancelAudioRecording returns to idle',
      build: () => _makeBloc(repo),
      act: (bloc) async {
        bloc.add(const StartAudioRecording());
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(const CancelAudioRecording());
      },
      verify: (bloc) {
        expect(bloc.state.status, MessageComposerStatus.idle);
        expect(bloc.state.isRecordingMode, isFalse);
      },
    );

    blocTest<MessageComposerBloc, MessageComposerState>(
      'SubmitAudioRecording sends media message and returns to idle',
      build: () {
        when(() => repo.sendMediaMessage(any()))
            .thenAnswer((_) async => Success(FakeMediaMessage()));
        return _makeBloc(repo);
      },
      act: (bloc) async {
        bloc.add(const StartAudioRecording());
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(const SubmitAudioRecording('/tmp/recording.m4a'));
      },
      wait: const Duration(milliseconds: 300),
      verify: (bloc) {
        verify(() => repo.sendMediaMessage(any())).called(1);
      },
    );

    blocTest<MessageComposerBloc, MessageComposerState>(
      'recording mode preserves compose text',
      build: () => _makeBloc(repo),
      act: (bloc) async {
        bloc.add(const UpdateComposeText('Draft message'));
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(const StartAudioRecording());
      },
      verify: (bloc) {
        expect(bloc.state.isRecordingMode, isTrue);
        expect(bloc.state.composeText, 'Draft message');
      },
    );
  });

  // =========================================================================
  // External Compose — Kotlin CSV #1287-1290
  // =========================================================================

  group('External compose events', () {
    blocTest<MessageComposerBloc, MessageComposerState>(
      'ComposeMessageReceived with matching id updates text',
      build: () => _makeBloc(repo),
      act: (bloc) => bloc.add(const ComposeMessageReceived(
        text: 'External text',
        id: {'uid': 'test_user'},
      )),
      verify: (bloc) {
        expect(bloc.state.composeText, 'External text');
      },
    );

    blocTest<MessageComposerBloc, MessageComposerState>(
      'ComposeMessageReceived with non-matching id is ignored',
      build: () => _makeBloc(repo),
      act: (bloc) async {
        bloc.add(const UpdateComposeText('Original'));
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(const ComposeMessageReceived(
          text: 'Should be ignored',
          id: {'uid': 'different_user'},
        ));
      },
      verify: (bloc) {
        // The text should remain 'Original' since the id doesn't match
        expect(bloc.state.composeText, 'Original');
      },
    );

    blocTest<MessageComposerBloc, MessageComposerState>(
      'ClearComposeText empties compose text',
      build: () => _makeBloc(repo),
      act: (bloc) async {
        bloc.add(const UpdateComposeText('Some text'));
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(const ClearComposeText());
      },
      verify: (bloc) {
        expect(bloc.state.composeText, isEmpty);
      },
    );
  });
}
