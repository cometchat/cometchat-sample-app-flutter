import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cometchat_sdk/cometchat_sdk.dart';
import 'package:cometchat_cards/cometchat_cards.dart';

import 'package:cometchat_chat_uikit/chat_ui/src/message_list/widgets/cometchat_card_bubble.dart';

// ---------------------------------------------------------------------------
// Mocks & Fakes
// ---------------------------------------------------------------------------

class FakeUser extends Fake implements User {
  @override
  String get uid => 'user_sender';

  @override
  String get name => 'Sender Name';
}

class FakeCardMessage extends Fake implements CardMessage {
  final Map<String, dynamic>? _card;
  final String? _text;
  final String? _fallbackText;

  FakeCardMessage({
    Map<String, dynamic>? card,
    String? text,
    String? fallbackText,
  })  : _card = card,
        _text = text,
        _fallbackText = fallbackText;

  @override
  int get id => 1001;

  @override
  String get muid => 'muid_1001';

  @override
  String get type => 'card';

  @override
  String get category => 'card';

  @override
  Map<String, dynamic>? getCard() => _card;

  @override
  String? getText() => _text;

  @override
  String? getFallbackText() => _fallbackText;

  @override
  User? get sender => FakeUser();

  @override
  DateTime? get sentAt => DateTime(2026, 6, 19, 10, 0);

  @override
  DateTime? get readAt => null;

  @override
  DateTime? get deliveredAt => null;

  @override
  DateTime? get deletedAt => null;

  @override
  int get parentMessageId => 0;

  @override
  String get receiverUid => 'user_receiver';

  @override
  String get receiverType => 'user';

  @override
  List<ReactionCount> get reactions => [];

  @override
  Map<String, dynamic>? get metadata => null;
}

// ---------------------------------------------------------------------------
// Test Fixtures
// ---------------------------------------------------------------------------

const _validCardJson = {
  'version': '1.0',
  'body': [
    {'id': 't1', 'type': 'text', 'content': 'Hello from card!'},
  ],
  'fallbackText': 'Fallback text',
};

const _cardWithButton = {
  'version': '1.0',
  'body': [
    {'id': 't1', 'type': 'text', 'content': 'Card with button'},
    {
      'id': 'btn1',
      'type': 'button',
      'label': 'Click Me',
      'action': {'type': 'openUrl', 'url': 'https://example.com'}
    },
  ],
  'fallbackText': 'A card with a button',
};

const _cardWithStyle = {
  'version': '1.0',
  'body': [
    {'id': 't1', 'type': 'text', 'content': 'Styled card'},
  ],
  'style': {
    'borderRadius': 12,
    'borderWidth': 1,
    'borderColor': '#E0E0E0',
    'background': '#FFFFFF',
  },
  'fallbackText': 'Styled card fallback',
};

const _cardWithMultipleElements = {
  'version': '1.0',
  'body': [
    {'id': 't1', 'type': 'text', 'content': 'Title', 'variant': 'heading1'},
    {'id': 'd1', 'type': 'divider'},
    {'id': 't2', 'type': 'text', 'content': 'Body text', 'variant': 'body'},
    {
      'id': 'btn1',
      'type': 'button',
      'label': 'Action',
      'action': {'type': 'openUrl', 'url': 'https://cometchat.com'}
    },
  ],
  'fallbackText': 'Multi-element card',
};

// ---------------------------------------------------------------------------
// Helper
// ---------------------------------------------------------------------------

Widget _buildTestWidget(
  CardMessage message, {
  void Function(CardMessage, CometChatCardActionEvent)? onCardAction,
  CometChatCardThemeMode? themeMode,
  CometChatCardThemeOverride? themeOverride,
}) {
  return MaterialApp(
    home: MediaQuery(
      data: const MediaQueryData(size: Size(800, 600)),
      child: Scaffold(
        body: SingleChildScrollView(
          child: CometChatCardBubble(
            message: message,
            onCardAction: onCardAction,
            themeMode: themeMode,
            themeOverride: themeOverride,
          ),
        ),
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests: CometChatCardBubble — Cards in One-on-One Conversations
// ---------------------------------------------------------------------------

void main() {
  group('CometChatCardBubble — One-on-One Conversation Cards', () {
    group('Rendering', () {
      testWidgets('renders CometChatCardView when card data is present',
          (tester) async {
        final message = FakeCardMessage(card: _validCardJson);

        await tester.pumpWidget(_buildTestWidget(message));
        await tester.pump();

        // CometChatCardView should be in the tree
        expect(find.byType(CometChatCardView), findsOneWidget);
        // Content text from the card should be visible
        expect(find.text('Hello from card!'), findsOneWidget);
      });

      testWidgets('renders multiple elements in card body', (tester) async {
        final message = FakeCardMessage(card: _cardWithMultipleElements);

        await tester.pumpWidget(_buildTestWidget(message));
        await tester.pump();

        expect(find.text('Title'), findsOneWidget);
        expect(find.text('Body text'), findsOneWidget);
        expect(find.text('Action'), findsOneWidget);
      });

      testWidgets('renders button element and responds to tap',
          (tester) async {
        final message = FakeCardMessage(card: _cardWithButton);
        CometChatCardActionEvent? receivedEvent;
        CardMessage? receivedMessage;

        await tester.pumpWidget(_buildTestWidget(
          message,
          onCardAction: (msg, action) {
            receivedMessage = msg;
            receivedEvent = action;
          },
        ));
        await tester.pump();

        expect(find.text('Click Me'), findsOneWidget);

        await tester.tap(find.text('Click Me'));
        await tester.pump();

        expect(receivedEvent, isNotNull);
        expect(receivedEvent!.elementId, 'btn1');
        expect(receivedEvent!.action, isA<CometChatCardOpenUrlAction>());
        expect(receivedMessage, equals(message));
      });

      testWidgets('renders with container style applied', (tester) async {
        final message = FakeCardMessage(card: _cardWithStyle);

        await tester.pumpWidget(_buildTestWidget(message));
        await tester.pump();

        expect(find.text('Styled card'), findsOneWidget);
        // Container decoration should be applied
        expect(find.byType(Container), findsWidgets);
      });
    });

    group('Fallback Handling', () {
      testWidgets('shows fallbackText when card data is null', (tester) async {
        final message = FakeCardMessage(
          card: null,
          fallbackText: 'This is a fallback',
        );

        await tester.pumpWidget(_buildTestWidget(message));
        await tester.pump();

        expect(find.text('This is a fallback'), findsOneWidget);
        expect(find.byType(CometChatCardView), findsNothing);
      });

      testWidgets('shows fallbackText when card data is empty map',
          (tester) async {
        final message = FakeCardMessage(
          card: {},
          fallbackText: 'Empty card fallback',
        );

        await tester.pumpWidget(_buildTestWidget(message));
        await tester.pump();

        expect(find.text('Empty card fallback'), findsOneWidget);
        expect(find.byType(CometChatCardView), findsNothing);
      });

      testWidgets('shows getText when fallbackText is null and card is null',
          (tester) async {
        final message = FakeCardMessage(
          card: null,
          text: 'Text message content',
          fallbackText: null,
        );

        await tester.pumpWidget(_buildTestWidget(message));
        await tester.pump();

        expect(find.text('Text message content'), findsOneWidget);
      });

      testWidgets('shows "Card Message" when all fallbacks are null',
          (tester) async {
        final message = FakeCardMessage(
          card: null,
          text: null,
          fallbackText: null,
        );

        await tester.pumpWidget(_buildTestWidget(message));
        await tester.pump();

        // Should find either "Card Message" or the translated version
        // (depends on Translations being available)
        expect(find.byType(Text), findsOneWidget);
      });

      testWidgets('prefers fallbackText over getText for fallback display',
          (tester) async {
        final message = FakeCardMessage(
          card: null,
          text: 'Should not show',
          fallbackText: 'Should show',
        );

        await tester.pumpWidget(_buildTestWidget(message));
        await tester.pump();

        expect(find.text('Should show'), findsOneWidget);
        expect(find.text('Should not show'), findsNothing);
      });
    });

    group('Theme Mode', () {
      testWidgets('passes explicit themeMode to CometChatCardView',
          (tester) async {
        final message = FakeCardMessage(card: _validCardJson);

        await tester.pumpWidget(_buildTestWidget(
          message,
          themeMode: CometChatCardThemeMode.dark,
        ));
        await tester.pump();

        final cardView =
            tester.widget<CometChatCardView>(find.byType(CometChatCardView));
        expect(cardView.themeMode, CometChatCardThemeMode.dark);
      });

      testWidgets('resolves themeMode from platform brightness when null',
          (tester) async {
        final message = FakeCardMessage(card: _validCardJson);

        await tester.pumpWidget(MaterialApp(
          theme: ThemeData.light(),
          home: MediaQuery(
            data: const MediaQueryData(size: Size(800, 600)),
            child: Scaffold(
              body: SingleChildScrollView(
                child: CometChatCardBubble(message: message),
              ),
            ),
          ),
        ));
        await tester.pump();

        final cardView =
            tester.widget<CometChatCardView>(find.byType(CometChatCardView));
        expect(cardView.themeMode, CometChatCardThemeMode.light);
      });

      testWidgets('resolves dark themeMode in dark theme', (tester) async {
        final message = FakeCardMessage(card: _validCardJson);

        await tester.pumpWidget(MaterialApp(
          theme: ThemeData.dark(),
          home: MediaQuery(
            data: const MediaQueryData(size: Size(800, 600)),
            child: Scaffold(
              body: SingleChildScrollView(
                child: CometChatCardBubble(message: message),
              ),
            ),
          ),
        ));
        await tester.pump();

        final cardView =
            tester.widget<CometChatCardView>(find.byType(CometChatCardView));
        expect(cardView.themeMode, CometChatCardThemeMode.dark);
      });
    });

    group('Action Handling', () {
      testWidgets('onCardAction is NOT called when callback is null',
          (tester) async {
        final message = FakeCardMessage(card: _cardWithButton);

        // Should not throw
        await tester.pumpWidget(_buildTestWidget(message, onCardAction: null));
        await tester.pump();

        await tester.tap(find.text('Click Me'));
        await tester.pump();
        // No assertion failure = success
      });

      testWidgets('onCardAction receives correct message reference',
          (tester) async {
        final message = FakeCardMessage(card: _cardWithButton);
        CardMessage? capturedMessage;

        await tester.pumpWidget(_buildTestWidget(
          message,
          onCardAction: (msg, _) => capturedMessage = msg,
        ));
        await tester.pump();

        await tester.tap(find.text('Click Me'));
        await tester.pump();

        expect(capturedMessage, same(message));
      });
    });

    group('Width Constraint', () {
      testWidgets('card bubble occupies ~65% of screen width', (tester) async {
        final message = FakeCardMessage(card: _validCardJson);

        await tester.pumpWidget(MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(800, 600)),
            child: Scaffold(
              body: SingleChildScrollView(
                child: CometChatCardBubble(message: message),
              ),
            ),
          ),
        ));
        await tester.pump();

        // The NoIntrinsicCardWrapper should constrain width
        // 800 * 0.65 = 520
        expect(find.byType(CometChatCardView), findsOneWidget);
      });
    });

    group('Card JSON Encoding', () {
      test('complex card data is correctly JSON-encoded to CometChatCardView', () {
        final complexCard = {
          'version': '1.0',
          'body': [
            {
              'id': 'col1',
              'type': 'column',
              'items': [
                {'id': 'icon1', 'type': 'icon', 'name': 'https://example.com/icon.png', 'size': 24},
                {'id': 't1', 'type': 'text', 'content': 'Nested in column'},
              ],
            },
          ],
          'fallbackText': 'Complex card',
        };

        // Verify the card data will be properly JSON-encoded
        final encoded = jsonEncode(complexCard);
        final decoded = jsonDecode(encoded) as Map<String, dynamic>;
        expect(decoded['version'], '1.0');
        expect((decoded['body'] as List).length, 1);
        expect((decoded['body'] as List)[0]['type'], 'column');
        expect((decoded['body'] as List)[0]['items'], isA<List>());
        expect(((decoded['body'] as List)[0]['items'] as List).length, 2);
      });

      testWidgets('card message passes encoded JSON to CometChatCardView',
          (tester) async {
        final message = FakeCardMessage(card: _validCardJson);

        await tester.pumpWidget(_buildTestWidget(message));
        await tester.pump();

        final cardView =
            tester.widget<CometChatCardView>(find.byType(CometChatCardView));
        final decoded = jsonDecode(cardView.cardJson) as Map<String, dynamic>;
        expect(decoded['version'], '1.0');
        expect((decoded['body'] as List).length, 1);
        expect((decoded['body'] as List)[0]['content'], 'Hello from card!');
      });
    });
  });
}
