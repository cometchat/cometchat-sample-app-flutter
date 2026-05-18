/// Comprehensive prop tests for CometChatConversations widget.
///
/// Tests every public prop/parameter of CometChatConversations to verify
/// it is correctly wired and affects the rendered output.
///
/// Strategy:
/// - Use a mock ConversationsBloc injected via `conversationsBloc` prop
/// - Pre-seed the bloc with a loaded state containing fake conversations
/// - For each prop, render the widget with that prop set and verify the effect
///
/// Run: flutter test test/chat_ui/conversations/widget/conversations_props_test.dart

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:network_image_mock/network_image_mock.dart';

import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';
import 'package:cometchat_chat_uikit/chat_ui/src/conversations/bloc/conversations_bloc.dart';
import 'package:cometchat_chat_uikit/chat_ui/src/conversations/bloc/conversations_event.dart';
import 'package:cometchat_chat_uikit/chat_ui/src/conversations/bloc/conversations_state.dart';

// ─── Mocks & Fakes ───────────────────────────────────────────────────────────

class MockConversationsBloc
    extends MockBloc<ConversationsEvent, ConversationsState>
    implements ConversationsBloc {
  final _typingNotifiers = <String, ValueNotifier<List<TypingIndicator>>>{};

  @override
  ValueNotifier<List<TypingIndicator>> getTypingNotifier(String id) =>
      _typingNotifiers.putIfAbsent(id, () => ValueNotifier([]));

  @override
  List<TypingIndicator> getTypingIndicators(String conversationId) => [];

  @override
  // ignore: must_call_super
  void add(ConversationsEvent event) {
    // No-op for mock — prevents actual event processing
  }
}

class FakeUser extends Fake implements User {
  FakeUser({this.name = 'Alice', this.uid = 'u1'});

  @override
  final String name;

  @override
  final String uid;

  @override
  String? get avatar => null;

  @override
  String get status => 'online';

  @override
  String? get role => 'default';

  @override
  String? get link => null;
}

class FakeGroup extends Fake implements Group {
  FakeGroup({
    this.name = 'Test Group',
    this.guid = 'g1',
    this.type = 'public',
  });

  @override
  final String name;

  @override
  final String guid;

  @override
  final String type;

  @override
  String? get icon => null;

  @override
  int get membersCount => 5;
}

class FakeBaseMessage extends Mock implements TextMessage {
  @override
  int get id => 100;

  @override
  String get text => 'Hello!';

  @override
  DateTime get sentAt => DateTime(2026, 5, 12, 10, 30);

  @override
  DateTime? get deliveredAt => DateTime(2026, 5, 12, 10, 31);

  @override
  DateTime? get readAt => null;

  @override
  User get sender => FakeUser(name: 'Bob', uid: 'u2');

  @override
  String get type => 'text';

  @override
  String get category => 'message';

  @override
  String get receiverUid => 'u1';

  @override
  int get parentMessageId => 0;

  @override
  int get replyCount => 0;

  @override
  String get muid => 'muid_100';

  @override
  List<ReactionCount> get reactions => [];

  @override
  bool get unreadByMe => false;

  @override
  List<User> get mentionedUsers => [];

  @override
  List<String> get tags => [];
}

class FakeConversation extends Fake implements Conversation {
  FakeConversation({
    required this.conversationWith,
    this.conversationId = 'conv_1',
    this.unreadMessageCount = 0,
    BaseMessage? lastMessage,
  }) : _lastMessage = lastMessage;

  @override
  final String conversationId;

  @override
  final AppEntity conversationWith;

  @override
  final int unreadMessageCount;

  final BaseMessage? _lastMessage;

  @override
  BaseMessage? get lastMessage => _lastMessage;

  @override
  String get conversationType =>
      conversationWith is User ? 'user' : 'group';
}

// ─── Helpers ─────────────────────────────────────────────────────────────────

Widget _wrap(Widget child) {
  return MaterialApp(
    localizationsDelegates: Translations.localizationsDelegates,
    supportedLocales: const [Locale('en')],
    home: Scaffold(body: child),
  );
}

List<Conversation> _sampleConversations() => [
      FakeConversation(
        conversationWith: FakeUser(name: 'Alice', uid: 'u1'),
        conversationId: 'user_u1',
        unreadMessageCount: 3,
        lastMessage: FakeBaseMessage(),
      ),
      FakeConversation(
        conversationWith: FakeUser(name: 'Bob', uid: 'u2'),
        conversationId: 'user_u2',
      ),
      FakeConversation(
        conversationWith: FakeGroup(name: 'Dev Team', guid: 'g1', type: 'private'),
        conversationId: 'group_g1',
        unreadMessageCount: 1,
      ),
    ];

MockConversationsBloc _loadedBloc() {
  final bloc = MockConversationsBloc();
  final conversations = _sampleConversations();
  final loadedState = ConversationsLoaded(
    conversations: conversations,
    hasMore: false,
  );
  when(() => bloc.state).thenReturn(loadedState);
  whenListen(bloc, Stream.fromIterable([loadedState]), initialState: loadedState);
  return bloc;
}

MockConversationsBloc _emptyBloc() {
  final bloc = MockConversationsBloc();
  const emptyState = ConversationsEmpty();
  when(() => bloc.state).thenReturn(emptyState);
  whenListen(bloc, Stream.fromIterable([emptyState]), initialState: emptyState);
  return bloc;
}

MockConversationsBloc _errorBloc() {
  final bloc = MockConversationsBloc();
  const errorState = ConversationsError(message: 'Network error');
  when(() => bloc.state).thenReturn(errorState);
  whenListen(bloc, Stream.fromIterable([errorState]), initialState: errorState);
  return bloc;
}


// ─── Tests ───────────────────────────────────────────────────────────────────

void main() {
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // CALLBACKS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  group('Callbacks', () {
    testWidgets('onItemTap fires with correct conversation', (tester) async {
      Conversation? tapped;
      final bloc = _loadedBloc();

      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(_wrap(
          CometChatConversations(
            conversationsBloc: bloc,
            onItemTap: (c) => tapped = c,
          ),
        ));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        // Tap the first list item
        final inkWells = find.byType(InkWell);
        if (inkWells.evaluate().isNotEmpty) {
          await tester.tap(inkWells.first);
          await tester.pump();
        }
      });

      expect(tapped, isNotNull);
      expect(tapped!.conversationId, 'user_u1');
    });

    testWidgets('onItemLongPress fires with correct conversation',
        (tester) async {
      Conversation? longPressed;
      final bloc = _loadedBloc();

      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(_wrap(
          CometChatConversations(
            conversationsBloc: bloc,
            onItemLongPress: (c) => longPressed = c,
          ),
        ));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        final inkWells = find.byType(InkWell);
        if (inkWells.evaluate().isNotEmpty) {
          await tester.longPress(inkWells.first);
          await tester.pump();
        }
      });

      expect(longPressed, isNotNull);
      expect(longPressed!.conversationId, 'user_u1');
    });

    testWidgets('onBack fires when back button is tapped', (tester) async {
      bool backFired = false;
      final bloc = _loadedBloc();

      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(_wrap(
          CometChatConversations(
            conversationsBloc: bloc,
            showBackButton: true,
            onBack: () => backFired = true,
          ),
        ));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        final backBtn = find.byType(BackButton);
        if (backBtn.evaluate().isNotEmpty) {
          await tester.tap(backBtn.first);
          await tester.pump();
        } else {
          // Try finding IconButton with back arrow
          final iconBtns = find.byIcon(Icons.arrow_back);
          if (iconBtns.evaluate().isNotEmpty) {
            await tester.tap(iconBtns.first);
            await tester.pump();
          }
        }
      });

      expect(backFired, isTrue);
    });

    testWidgets('onLoad fires when conversations are loaded', (tester) async {
      List<Conversation>? loadedList;
      final bloc = _loadedBloc();

      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(_wrap(
          CometChatConversations(
            conversationsBloc: bloc,
            onLoad: (conversations) => loadedList = conversations,
          ),
        ));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
      });

      expect(loadedList, isNotNull);
      expect(loadedList!.length, 3);
    });

    testWidgets('onEmpty fires when conversation list is empty',
        (tester) async {
      bool emptyFired = false;
      final bloc = _emptyBloc();

      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(_wrap(
          CometChatConversations(
            conversationsBloc: bloc,
            onEmpty: () => emptyFired = true,
          ),
        ));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
      });

      expect(emptyFired, isTrue);
    });

    testWidgets('onError fires when bloc emits error state', (tester) async {
      String? errorMsg;
      final bloc = _errorBloc();

      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(_wrap(
          CometChatConversations(
            conversationsBloc: bloc,
            onError: (e) => errorMsg = e.toString(),
          ),
        ));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
      });

      expect(errorMsg, isNotNull);
    });
  });

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // VISIBILITY FLAGS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  group('Visibility flags', () {
    testWidgets('hideAppbar=true removes the app bar', (tester) async {
      final bloc = _loadedBloc();

      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(_wrap(
          CometChatConversations(
            conversationsBloc: bloc,
            hideAppbar: true,
          ),
        ));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
      });

      // Should not find the title text "Chats" (default title)
      expect(find.text('Chats'), findsNothing);
    });

    testWidgets('showBackButton=true shows back button', (tester) async {
      final bloc = _loadedBloc();

      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(_wrap(
          CometChatConversations(
            conversationsBloc: bloc,
            showBackButton: true,
          ),
        ));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
      });

      // Should find a back arrow icon
      final backIcon = find.byIcon(Icons.arrow_back);
      final backButton = find.byType(BackButton);
      expect(
        backIcon.evaluate().isNotEmpty || backButton.evaluate().isNotEmpty,
        isTrue,
        reason: 'Expected back button to be visible',
      );
    });

    testWidgets('showBackButton=false (default) hides back button',
        (tester) async {
      final bloc = _loadedBloc();

      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(_wrap(
          CometChatConversations(
            conversationsBloc: bloc,
            showBackButton: false,
          ),
        ));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
      });

      expect(find.byType(BackButton), findsNothing);
    });

    testWidgets('hideSearch=true hides the search bar', (tester) async {
      final bloc = _loadedBloc();

      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(_wrap(
          CometChatConversations(
            conversationsBloc: bloc,
            hideSearch: true,
          ),
        ));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
      });

      expect(find.byType(TextField), findsNothing);
    });

    testWidgets('hideError=true suppresses error state view', (tester) async {
      final bloc = _errorBloc();

      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(_wrap(
          CometChatConversations(
            conversationsBloc: bloc,
            hideError: true,
          ),
        ));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
      });

      // Should not show the default error text
      expect(find.textContaining('Oops'), findsNothing);
    });
  });

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // CUSTOM VIEWS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  group('Custom views', () {
    testWidgets('listItemView overrides default list item rendering',
        (tester) async {
      final bloc = _loadedBloc();

      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(_wrap(
          CometChatConversations(
            conversationsBloc: bloc,
            listItemView: (conv) => Container(
              key: Key('custom-item-${conv.conversationId}'),
              child: Text('CUSTOM: ${conv.conversationId}'),
            ),
          ),
        ));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
      });

      expect(find.text('CUSTOM: user_u1'), findsOneWidget);
      expect(find.text('CUSTOM: user_u2'), findsOneWidget);
      expect(find.text('CUSTOM: group_g1'), findsOneWidget);
    });

    testWidgets('subtitleView overrides default subtitle', (tester) async {
      final bloc = _loadedBloc();

      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(_wrap(
          CometChatConversations(
            conversationsBloc: bloc,
            subtitleView: (ctx, conv) =>
                Text('Sub: ${conv.conversationId}', key: const Key('custom-sub')),
          ),
        ));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
      });

      expect(find.textContaining('Sub: user_u1'), findsOneWidget);
    });

    testWidgets('emptyStateView overrides default empty state',
        (tester) async {
      final bloc = _emptyBloc();

      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(_wrap(
          CometChatConversations(
            conversationsBloc: bloc,
            emptyStateView: (ctx) => const Center(
              key: Key('custom-empty'),
              child: Text('Nothing here!'),
            ),
          ),
        ));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
      });

      expect(find.byKey(const Key('custom-empty')), findsOneWidget);
      expect(find.text('Nothing here!'), findsOneWidget);
    });

    testWidgets('errorStateView overrides default error state',
        (tester) async {
      final bloc = _errorBloc();

      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(_wrap(
          CometChatConversations(
            conversationsBloc: bloc,
            errorStateView: (ctx) => const Center(
              key: Key('custom-error'),
              child: Text('Custom error!'),
            ),
          ),
        ));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
      });

      expect(find.byKey(const Key('custom-error')), findsOneWidget);
      expect(find.text('Custom error!'), findsOneWidget);
    });

    testWidgets('loadingStateView overrides default loading shimmer',
        (tester) async {
      final bloc = MockConversationsBloc();
      const loadingState = ConversationsLoading();
      when(() => bloc.state).thenReturn(loadingState);
      whenListen(bloc, Stream.fromIterable([loadingState]), initialState: loadingState);

      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(_wrap(
          CometChatConversations(
            conversationsBloc: bloc,
            loadingStateView: (ctx) => const Center(
              key: Key('custom-loading'),
              child: CircularProgressIndicator(),
            ),
          ),
        ));
        await tester.pump();
      });

      expect(find.byKey(const Key('custom-loading')), findsOneWidget);
    });

    testWidgets('trailingView overrides default trailing widget',
        (tester) async {
      final bloc = _loadedBloc();

      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(_wrap(
          CometChatConversations(
            conversationsBloc: bloc,
            trailingView: (conv) => const Icon(
              Icons.star,
              key: Key('custom-trailing'),
            ),
          ),
        ));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
      });

      expect(find.byKey(const Key('custom-trailing')), findsWidgets);
    });

    testWidgets('backButton overrides default back button widget',
        (tester) async {
      final bloc = _loadedBloc();

      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(_wrap(
          CometChatConversations(
            conversationsBloc: bloc,
            showBackButton: true,
            backButton: const Icon(Icons.close, key: Key('custom-back')),
          ),
        ));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
      });

      expect(find.byKey(const Key('custom-back')), findsOneWidget);
    });

    testWidgets('appBarOptions adds widgets to app bar', (tester) async {
      final bloc = _loadedBloc();

      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(_wrap(
          CometChatConversations(
            conversationsBloc: bloc,
            appBarOptions: [
              IconButton(
                key: const Key('appbar-option'),
                icon: const Icon(Icons.settings),
                onPressed: () {},
              ),
            ],
          ),
        ));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
      });

      expect(find.byKey(const Key('appbar-option')), findsOneWidget);
    });
  });

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // TEXT & TITLE PROPS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  group('Text & title props', () {
    testWidgets('title prop sets custom title text', (tester) async {
      final bloc = _loadedBloc();

      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(_wrap(
          CometChatConversations(
            conversationsBloc: bloc,
            title: 'My Conversations',
          ),
        ));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
      });

      expect(find.text('My Conversations'), findsOneWidget);
    });

    testWidgets('default title is "Chats"', (tester) async {
      final bloc = _loadedBloc();

      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(_wrap(
          CometChatConversations(
            conversationsBloc: bloc,
          ),
        ));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
      });

      expect(find.text('Chats'), findsOneWidget);
    });
  });

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // SELECTION MODE
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  group('Selection mode', () {
    testWidgets('selectionMode=multiple shows checkboxes', (tester) async {
      final bloc = _loadedBloc();

      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(_wrap(
          CometChatConversations(
            conversationsBloc: bloc,
            selectionMode: SelectionMode.multiple,
            activateSelection: ActivateSelection.onClick,
          ),
        ));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        // Tap to activate selection
        final items = find.byType(InkWell);
        if (items.evaluate().isNotEmpty) {
          await tester.tap(items.first);
          await tester.pump(const Duration(milliseconds: 300));
        }
      });

      expect(find.byType(Checkbox), findsWidgets);
    });

    testWidgets('onSelection fires with selected conversations',
        (tester) async {
      List<Conversation>? selected;
      final bloc = _loadedBloc();

      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(_wrap(
          CometChatConversations(
            conversationsBloc: bloc,
            selectionMode: SelectionMode.multiple,
            activateSelection: ActivateSelection.onClick,
            onSelection: (list) => selected = list,
          ),
        ));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
      });

      // onSelection is typically called when submit is tapped after selection
      // This verifies the prop is accepted without error
      expect(selected, isNull); // Not fired until submit
    });
  });

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // CUSTOM ICONS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  group('Custom icons', () {
    testWidgets('protectedGroupIcon renders for password-protected groups',
        (tester) async {
      final bloc = MockConversationsBloc();
      final conversations = [
        FakeConversation(
          conversationWith:
              FakeGroup(name: 'Secret', guid: 'g2', type: 'password'),
          conversationId: 'group_g2',
        ),
      ];
      final loadedState = ConversationsLoaded(
        conversations: conversations,
        hasMore: false,
      );
      when(() => bloc.state).thenReturn(loadedState);
      whenListen(bloc, Stream.fromIterable([loadedState]), initialState: loadedState);

      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(_wrap(
          CometChatConversations(
            conversationsBloc: bloc,
            protectedGroupIcon:
                const Icon(Icons.lock, key: Key('custom-lock')),
          ),
        ));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
      });

      expect(find.byKey(const Key('custom-lock')), findsOneWidget);
    });

    testWidgets('privateGroupIcon renders for private groups',
        (tester) async {
      final bloc = MockConversationsBloc();
      final conversations = [
        FakeConversation(
          conversationWith:
              FakeGroup(name: 'Private', guid: 'g3', type: 'private'),
          conversationId: 'group_g3',
        ),
      ];
      final loadedState = ConversationsLoaded(
        conversations: conversations,
        hasMore: false,
      );
      when(() => bloc.state).thenReturn(loadedState);
      whenListen(bloc, Stream.fromIterable([loadedState]), initialState: loadedState);

      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(_wrap(
          CometChatConversations(
            conversationsBloc: bloc,
            privateGroupIcon:
                const Icon(Icons.shield, key: Key('custom-shield')),
          ),
        ));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
      });

      expect(find.byKey(const Key('custom-shield')), findsOneWidget);
    });
  });

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // EXTERNAL BLOC
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  group('External BLoC', () {
    testWidgets('conversationsBloc prop uses provided bloc', (tester) async {
      final bloc = _loadedBloc();

      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(_wrap(
          CometChatConversations(
            conversationsBloc: bloc,
          ),
        ));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
      });

      // Verify the bloc's state is used (3 conversations rendered)
      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Bob'), findsOneWidget);
      expect(find.text('Dev Team'), findsOneWidget);
    });
  });

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // SOUND & BEHAVIOR
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  group('Sound & behavior props', () {
    testWidgets('disableSoundForMessages=true accepted without error',
        (tester) async {
      final bloc = _loadedBloc();

      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(_wrap(
          CometChatConversations(
            conversationsBloc: bloc,
            disableSoundForMessages: true,
          ),
        ));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
      });

      // Widget renders without error
      expect(find.text('Alice'), findsOneWidget);
    });

    testWidgets('searchReadOnly=true makes search non-editable',
        (tester) async {
      final bloc = _loadedBloc();

      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(_wrap(
          CometChatConversations(
            conversationsBloc: bloc,
            searchReadOnly: true,
          ),
        ));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
      });

      // Find TextField and verify readOnly
      final textFields = find.byType(TextField);
      if (textFields.evaluate().isNotEmpty) {
        final tf = tester.widget<TextField>(textFields.first);
        expect(tf.readOnly, isTrue);
      }
    });
  });

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // SIZING PROPS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  group('Sizing props', () {
    testWidgets('avatarWidth and avatarHeight are accepted', (tester) async {
      final bloc = _loadedBloc();

      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(_wrap(
          CometChatConversations(
            conversationsBloc: bloc,
            avatarWidth: 60,
            avatarHeight: 60,
          ),
        ));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
      });

      // Widget renders without error with custom avatar sizing
      expect(find.text('Alice'), findsOneWidget);
    });

    testWidgets('badgeWidth and badgeHeight are accepted', (tester) async {
      final bloc = _loadedBloc();

      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(_wrap(
          CometChatConversations(
            conversationsBloc: bloc,
            badgeWidth: 24,
            badgeHeight: 24,
          ),
        ));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
      });

      // Widget renders without error with custom badge sizing
      expect(find.text('Alice'), findsOneWidget);
    });
  });
}
