import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cometchat_sdk/cometchat_sdk.dart';

import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart'
    show CustomUIPosition;
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
  }) : _uid = uid,
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
  }) : _id = id,
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
  String get type => 'audio';
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
// Tests — Kotlin CometChatMessageComposerRenderingTest equivalent
// State transitions: idle, editing, replying, recording, error, success
// ---------------------------------------------------------------------------

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockMessageComposerRepository repo;

  setUpAll(() {
    registerFallbackValue(FakeTextMessage());
    registerFallbackValue(FakeMediaMessage());
  });

  setUp(() {
    repo = MockMessageComposerRepository();
    when(
      () => repo.getLoggedInUser(),
    ).thenAnswer((_) async => Success(FakeUser()));
    when(
      () => repo.startTyping(
        receiverUid: any(named: 'receiverUid'),
        receiverType: any(named: 'receiverType'),
      ),
    ).thenAnswer((_) async => const Success(null));
    when(
      () => repo.endTyping(
        receiverUid: any(named: 'receiverUid'),
        receiverType: any(named: 'receiverType'),
      ),
    ).thenAnswer((_) async => const Success(null));
  });

  // =========================================================================
  // Idle State — Kotlin CSV #1300-1302
  // =========================================================================

  group('Idle state rendering', () {
    test('initial state is idle with empty compose text', () {
      final bloc = _makeBloc(repo);
      expect(bloc.state.status, MessageComposerStatus.idle);
      expect(bloc.state.composeText, '');
      expect(bloc.state.isEditMode, isFalse);
      expect(bloc.state.isReplyMode, isFalse);
      expect(bloc.state.isRecordingMode, isFalse);
      expect(bloc.state.canSend, isFalse);
      bloc.close();
    });

    blocTest<MessageComposerBloc, MessageComposerState>(
      'ClearComposer returns to idle from any state',
      build: () => _makeBloc(repo),
      act: (bloc) async {
        bloc.add(SetReplyMessage(FakeTextMessage(text: 'Reply')));
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(const UpdateComposeText('Some text'));
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(const ClearComposer());
      },
      verify: (bloc) {
        expect(bloc.state.status, MessageComposerStatus.idle);
        expect(bloc.state.composeText, '');
        expect(bloc.state.replyMessage, isNull);
        expect(bloc.state.editMessage, isNull);
      },
    );
  });

  // =========================================================================
  // Editing State — Kotlin CSV #1303-1306
  // =========================================================================

  group('Editing state rendering', () {
    blocTest<MessageComposerBloc, MessageComposerState>(
      'SetEditMessage transitions to editing status',
      build: () => _makeBloc(repo),
      act: (bloc) =>
          bloc.add(SetEditMessage(FakeTextMessage(id: 5, text: 'Edit me'))),
      verify: (bloc) {
        expect(bloc.state.status, MessageComposerStatus.editing);
        expect(bloc.state.isEditMode, isTrue);
        expect(bloc.state.editMessage, isNotNull);
        expect(bloc.state.composeText, 'Edit me');
      },
    );

    blocTest<MessageComposerBloc, MessageComposerState>(
      'ClearEditMessage transitions back to idle',
      build: () => _makeBloc(repo),
      act: (bloc) async {
        bloc.add(SetEditMessage(FakeTextMessage(text: 'Edit me')));
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(const ClearEditMessage());
      },
      verify: (bloc) {
        expect(bloc.state.status, MessageComposerStatus.idle);
        expect(bloc.state.isEditMode, isFalse);
        expect(bloc.state.editMessage, isNull);
        expect(bloc.state.composeText, '');
      },
    );

    blocTest<MessageComposerBloc, MessageComposerState>(
      'editing state shows original message text in composeText',
      build: () => _makeBloc(repo),
      act: (bloc) => bloc.add(
        SetEditMessage(
          FakeTextMessage(id: 10, text: 'Hello world, this is a long message'),
        ),
      ),
      verify: (bloc) {
        expect(bloc.state.composeText, 'Hello world, this is a long message');
      },
    );
  });

  // =========================================================================
  // Replying State — Kotlin CSV #1307-1310
  // =========================================================================

  group('Replying state rendering', () {
    blocTest<MessageComposerBloc, MessageComposerState>(
      'SetReplyMessage transitions to replying status',
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
      'ClearReplyMessage transitions back to idle',
      build: () => _makeBloc(repo),
      act: (bloc) async {
        bloc.add(SetReplyMessage(FakeTextMessage(text: 'Reply to this')));
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(const ClearReplyMessage());
      },
      verify: (bloc) {
        expect(bloc.state.status, MessageComposerStatus.idle);
        expect(bloc.state.isReplyMode, isFalse);
        expect(bloc.state.replyMessage, isNull);
      },
    );

    blocTest<MessageComposerBloc, MessageComposerState>(
      'replying state preserves existing compose text',
      build: () => _makeBloc(repo),
      act: (bloc) async {
        bloc.add(const UpdateComposeText('My reply'));
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(SetReplyMessage(FakeTextMessage(text: 'Original')));
      },
      verify: (bloc) {
        expect(bloc.state.isReplyMode, isTrue);
        expect(bloc.state.composeText, 'My reply');
      },
    );
  });

  // =========================================================================
  // Recording State — Kotlin CSV #1311-1314
  // =========================================================================

  group('Recording state rendering', () {
    blocTest<MessageComposerBloc, MessageComposerState>(
      'StartAudioRecording transitions to recording status',
      build: () => _makeBloc(repo),
      act: (bloc) => bloc.add(const StartAudioRecording()),
      verify: (bloc) {
        expect(bloc.state.status, MessageComposerStatus.recording);
        expect(bloc.state.isRecordingMode, isTrue);
      },
    );

    blocTest<MessageComposerBloc, MessageComposerState>(
      'CancelAudioRecording transitions back to idle',
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
      'SubmitAudioRecording transitions through idle then sends',
      build: () {
        when(
          () => repo.sendMediaMessage(any()),
        ).thenAnswer((_) async => Success(FakeMediaMessage()));
        return _makeBloc(repo);
      },
      act: (bloc) async {
        bloc.add(const StartAudioRecording());
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(const SubmitAudioRecording('/tmp/audio.m4a'));
      },
      wait: const Duration(milliseconds: 300),
      verify: (bloc) {
        // After submit, should have sent the media message
        expect(bloc.state.status, MessageComposerStatus.success);
      },
    );
  });

  // =========================================================================
  // Error State — Kotlin CSV #1315-1318
  // =========================================================================

  group('Error state rendering', () {
    blocTest<MessageComposerBloc, MessageComposerState>(
      'send failure transitions to error with message',
      build: () {
        when(() => repo.sendTextMessage(any())).thenAnswer(
          (_) async => const Failure(message: 'Network timeout', code: 'TMO'),
        );
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
        expect(bloc.state.errorMessage, 'Network timeout');
      },
    );

    blocTest<MessageComposerBloc, MessageComposerState>(
      'edit failure transitions to error with message',
      build: () {
        when(() => repo.editMessage(any())).thenAnswer(
          (_) async =>
              const Failure(message: 'Permission denied', code: 'PERM'),
        );
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
        expect(bloc.state.errorMessage, 'Permission denied');
      },
    );
  });

  // =========================================================================
  // Success State — Kotlin CSV #1319-1322
  // =========================================================================

  group('Success state rendering', () {
    blocTest<MessageComposerBloc, MessageComposerState>(
      'successful send transitions to success with sentMessage',
      build: () {
        when(() => repo.sendTextMessage(any())).thenAnswer(
          (_) async => Success(FakeTextMessage(id: 99, text: 'Sent')),
        );
        return _makeBloc(repo);
      },
      act: (bloc) async {
        bloc.add(const UpdateComposeText('Sent'));
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(const SendTextMessage());
      },
      wait: const Duration(milliseconds: 200),
      verify: (bloc) {
        expect(bloc.state.status, MessageComposerStatus.success);
        expect(bloc.state.sentMessage, isNotNull);
      },
    );

    blocTest<MessageComposerBloc, MessageComposerState>(
      'successful edit transitions to success',
      build: () {
        when(() => repo.editMessage(any())).thenAnswer(
          (_) async => Success(FakeTextMessage(id: 10, text: 'Edited')),
        );
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
        expect(bloc.state.status, MessageComposerStatus.success);
      },
    );
  });

  // =========================================================================
  // Streaming State — Kotlin CSV #1323-1325
  // =========================================================================

  group('Streaming state rendering', () {
    blocTest<MessageComposerBloc, MessageComposerState>(
      'SetStreamingState true marks active streaming',
      build: () => _makeBloc(repo),
      act: (bloc) => bloc.add(const SetStreamingState(isStreaming: true)),
      verify: (bloc) {
        expect(bloc.state.isActiveStreaming, isTrue);
      },
    );

    blocTest<MessageComposerBloc, MessageComposerState>(
      'SetStreamingState false clears active streaming',
      build: () => _makeBloc(repo),
      act: (bloc) async {
        bloc.add(const SetStreamingState(isStreaming: true));
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(const SetStreamingState(isStreaming: false));
      },
      verify: (bloc) {
        expect(bloc.state.isActiveStreaming, isFalse);
      },
    );
  });

  // =========================================================================
  // Panel State — Kotlin CSV #1326-1330
  // =========================================================================

  group('Panel state rendering', () {
    blocTest<MessageComposerBloc, MessageComposerState>(
      'HidePanel with composerTop clears headerPanel',
      build: () => _makeBloc(repo),
      seed: () =>
          MessageComposerState(user: FakeUser(), headerPanel: const SizedBox()),
      act: (bloc) =>
          bloc.add(const HidePanel(position: CustomUIPosition.composerTop)),
      verify: (bloc) {
        expect(bloc.state.headerPanel, isNull);
      },
    );

    blocTest<MessageComposerBloc, MessageComposerState>(
      'HidePanel with composerBottom clears footerPanel and lockedPadding',
      build: () => _makeBloc(repo),
      seed: () => MessageComposerState(
        user: FakeUser(),
        footerPanel: const SizedBox(),
        lockedBottomPadding: 300.0,
      ),
      act: (bloc) =>
          bloc.add(const HidePanel(position: CustomUIPosition.composerBottom)),
      verify: (bloc) {
        expect(bloc.state.footerPanel, isNull);
        expect(bloc.state.lockedBottomPadding, isNull);
      },
    );

    blocTest<MessageComposerBloc, MessageComposerState>(
      'HidePanel with composerPreview clears previewPanel',
      build: () => _makeBloc(repo),
      seed: () => MessageComposerState(
        user: FakeUser(),
        previewPanel: const SizedBox(),
      ),
      act: (bloc) =>
          bloc.add(const HidePanel(position: CustomUIPosition.composerPreview)),
      verify: (bloc) {
        expect(bloc.state.previewPanel, isNull);
      },
    );
  });

  // =========================================================================
  // User/Group Switch — Kotlin CSV #1331-1334
  // =========================================================================

  group('User/Group switch rendering', () {
    blocTest<MessageComposerBloc, MessageComposerState>(
      'ComposerSetUser resets composer state for new user',
      build: () => _makeBloc(repo),
      act: (bloc) async {
        bloc.add(const UpdateComposeText('Draft'));
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(ComposerSetUser(FakeUser(uid: 'new_user', name: 'New User')));
      },
      verify: (bloc) {
        expect(bloc.state.user?.uid, 'new_user');
        expect(bloc.state.composeText, '');
        expect(bloc.state.status, MessageComposerStatus.idle);
        expect(bloc.state.group, isNull);
      },
    );

    blocTest<MessageComposerBloc, MessageComposerState>(
      'ComposerSetGroup resets composer state for new group',
      build: () => _makeBloc(repo),
      act: (bloc) async {
        bloc.add(const UpdateComposeText('Draft'));
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(
          ComposerSetGroup(FakeGroup(guid: 'new_group', name: 'New Group')),
        );
      },
      verify: (bloc) {
        expect(bloc.state.group?.guid, 'new_group');
        expect(bloc.state.composeText, '');
        expect(bloc.state.status, MessageComposerStatus.idle);
        expect(bloc.state.user, isNull);
      },
    );

    blocTest<MessageComposerBloc, MessageComposerState>(
      'ComposerSetUser clears edit and reply state',
      build: () => _makeBloc(repo),
      act: (bloc) async {
        bloc.add(SetEditMessage(FakeTextMessage(text: 'Editing')));
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(ComposerSetUser(FakeUser(uid: 'other')));
      },
      verify: (bloc) {
        expect(bloc.state.editMessage, isNull);
        expect(bloc.state.replyMessage, isNull);
      },
    );
  });
}
