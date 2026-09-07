import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cometchat_chat_uikit/shared_ui/cometchat_uikit_shared.dart';

// ---------------------------------------------------------------------------
// Fakes
// ---------------------------------------------------------------------------

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

  @override
  String get scope => 'admin';

  @override
  String get owner => 'test_user';
}

class FakeCardMessage extends Fake implements CardMessage {
  final int _id;
  final Map<String, dynamic>? _card;
  final String _senderUid;

  FakeCardMessage(
    this._id, {
    Map<String, dynamic>? card,
    String senderUid = 'other_user',
  }) : _card = card,
       _senderUid = senderUid;

  @override
  int get id => _id;

  @override
  String get muid => 'muid_$_id';

  @override
  String get type => 'card';

  @override
  String get category => 'card';

  @override
  Map<String, dynamic>? getCard() => _card;

  @override
  String? getText() => null;

  @override
  String? getFallbackText() => 'Fallback';

  @override
  User? get sender => _FakeMessageSender(_senderUid);

  @override
  DateTime? get sentAt => DateTime(2026, 6, 19, 10, 0);

  @override
  DateTime? get readAt => null;

  @override
  DateTime? get deliveredAt => null;

  @override
  DateTime? get deletedAt => null;

  // Pin & Save fields — read by the option assembly and status row.
  @override
  DateTime? get pinnedAt => null;

  @override
  String? get pinnedBy => null;

  @override
  DateTime? get savedAt => null;

  @override
  int get parentMessageId => 0;

  @override
  String get receiverUid => 'test_user';

  @override
  String get receiverType => 'user';

  @override
  List<ReactionCount> get reactions => [];

  @override
  Map<String, dynamic>? get metadata => null;

  @override
  int get replyCount => 0;

  @override
  set replyCount(int value) {}
}

class _FakeMessageSender extends Fake implements User {
  final String _uid;
  _FakeMessageSender(this._uid);

  @override
  String get uid => _uid;

  @override
  String get name => 'User $_uid';
}

// ---------------------------------------------------------------------------
// Tests: Card Message Template Registration & Options
// ---------------------------------------------------------------------------

void main() {
  group('Card Message Template — Registration', () {
    test('getCardBubbleTemplate returns template with category "card"', () {
      final template = MessageTemplateUtils.getCardBubbleTemplate();

      expect(template.category, MessageCategoryConstants.card);
      expect(template.type, MessageTypeConstants.card);
    });

    test(
      'legacy getCardMessageTemplate returns template with category "interactive"',
      () {
        final template = MessageTemplateUtils.getCardMessageTemplate();

        expect(template.category, MessageCategoryConstants.interactive);
        expect(template.type, MessageTypeConstants.card);
      },
    );

    test('both card templates are registered in getAllMessageTemplates', () {
      final templates = MessageTemplateUtils.getAllMessageTemplates();

      // Find the new card bubble template (category: card)
      final cardBubbleTemplates = templates.where(
        (t) =>
            t.type == MessageTypeConstants.card &&
            t.category == MessageCategoryConstants.card,
      );
      expect(
        cardBubbleTemplates.length,
        1,
        reason: 'New card bubble template should be registered',
      );

      // Find the legacy card template (category: interactive)
      final legacyCardTemplates = templates.where(
        (t) =>
            t.type == MessageTypeConstants.card &&
            t.category == MessageCategoryConstants.interactive,
      );
      expect(
        legacyCardTemplates.length,
        1,
        reason: 'Legacy card template should still be registered',
      );
    });

    test('getAllMessageTypes includes card type', () {
      final types = MessageTemplateUtils.getAllMessageTypes();
      expect(types, contains(MessageTypeConstants.card));
    });

    test('getAllMessageCategories includes card category', () {
      final categories = MessageTemplateUtils.getAllMessageCategories();
      expect(categories, contains(MessageCategoryConstants.card));
    });
  });

  group('Card Message Template — Content View', () {
    test('contentView is not null for card bubble template', () {
      final template = MessageTemplateUtils.getCardBubbleTemplate();
      expect(template.contentView, isNotNull);
    });

    test('contentView is not null for legacy card template', () {
      final template = MessageTemplateUtils.getCardMessageTemplate();
      expect(template.contentView, isNotNull);
    });
  });

  group('Card Message Template — Options (getCardBubbleOptions)', () {
    testWidgets('card options exclude edit and copy', (tester) async {
      late List<CometChatMessageOption> options;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              options = MessageTemplateUtils.getCardBubbleOptions(
                FakeUser(),
                FakeCardMessage(1, senderUid: 'other_user'),
                context,
                null,
                null,
              );
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      final optionIds = options.map((o) => o.id).toList();
      expect(
        optionIds,
        isNot(contains(MessageOptionConstants.editMessage)),
        reason: 'Card messages should not have edit option',
      );
      expect(
        optionIds,
        isNot(contains(MessageOptionConstants.copyMessage)),
        reason: 'Card messages should not have copy option',
      );
    });

    testWidgets('card options include reply', (tester) async {
      late List<CometChatMessageOption> options;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              options = MessageTemplateUtils.getCardBubbleOptions(
                FakeUser(),
                FakeCardMessage(1, senderUid: 'other_user'),
                context,
                null,
                null,
              );
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      final optionIds = options.map((o) => o.id).toList();
      expect(optionIds, contains(MessageOptionConstants.replyMessage));
    });

    testWidgets('card options include delete for own messages', (tester) async {
      late List<CometChatMessageOption> options;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              options = MessageTemplateUtils.getCardBubbleOptions(
                FakeUser(), // uid: 'test_user'
                FakeCardMessage(
                  1,
                  senderUid: 'test_user',
                ), // sender = logged in
                context,
                null,
                null,
              );
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      final optionIds = options.map((o) => o.id).toList();
      expect(optionIds, contains(MessageOptionConstants.deleteMessage));
    });

    testWidgets('card options include message info for own messages', (
      tester,
    ) async {
      late List<CometChatMessageOption> options;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              options = MessageTemplateUtils.getCardBubbleOptions(
                FakeUser(),
                FakeCardMessage(1, senderUid: 'test_user'),
                context,
                null,
                null,
              );
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      final optionIds = options.map((o) => o.id).toList();
      expect(optionIds, contains(MessageOptionConstants.messageInformation));
    });

    testWidgets('card options include reply in thread for 1:1 chat', (
      tester,
    ) async {
      late List<CometChatMessageOption> options;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              options = MessageTemplateUtils.getCardBubbleOptions(
                FakeUser(),
                FakeCardMessage(1, senderUid: 'other_user'),
                context,
                null, // no group = 1:1 chat
                null,
              );
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      final optionIds = options.map((o) => o.id).toList();
      expect(optionIds, contains(MessageOptionConstants.replyInThreadMessage));
    });

    testWidgets('card options never include edit even for own messages', (
      tester,
    ) async {
      late List<CometChatMessageOption> options;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              options = MessageTemplateUtils.getCardBubbleOptions(
                FakeUser(),
                FakeCardMessage(1, senderUid: 'test_user'), // own message
                context,
                null,
                null,
              );
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      final optionIds = options.map((o) => o.id).toList();
      expect(
        optionIds,
        isNot(contains(MessageOptionConstants.editMessage)),
        reason: 'Card messages cannot be edited even by sender',
      );
    });

    testWidgets('card options never include copy even for own messages', (
      tester,
    ) async {
      late List<CometChatMessageOption> options;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              options = MessageTemplateUtils.getCardBubbleOptions(
                FakeUser(),
                FakeCardMessage(1, senderUid: 'test_user'),
                context,
                null,
                null,
              );
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      final optionIds = options.map((o) => o.id).toList();
      expect(
        optionIds,
        isNot(contains(MessageOptionConstants.copyMessage)),
        reason: 'Card messages cannot be copied',
      );
    });

    testWidgets(
      'card options respect additionalConfigurations.hideReplyOption',
      (tester) async {
        late List<CometChatMessageOption> options;

        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                options = MessageTemplateUtils.getCardBubbleOptions(
                  FakeUser(),
                  FakeCardMessage(1, senderUid: 'other_user'),
                  context,
                  null,
                  AdditionalConfigurations(hideReplyOption: true),
                );
                return const SizedBox.shrink();
              },
            ),
          ),
        );

        final optionIds = options.map((o) => o.id).toList();
        expect(optionIds, isNot(contains(MessageOptionConstants.replyMessage)));
      },
    );

    testWidgets(
      'card options respect additionalConfigurations.hideDeleteMessageOption',
      (tester) async {
        late List<CometChatMessageOption> options;

        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                options = MessageTemplateUtils.getCardBubbleOptions(
                  FakeUser(),
                  FakeCardMessage(1, senderUid: 'test_user'),
                  context,
                  null,
                  AdditionalConfigurations(hideDeleteMessageOption: true),
                );
                return const SizedBox.shrink();
              },
            ),
          ),
        );

        final optionIds = options.map((o) => o.id).toList();
        expect(
          optionIds,
          isNot(contains(MessageOptionConstants.deleteMessage)),
        );
      },
    );

    testWidgets('card options include sendMessagePrivately in group chat', (
      tester,
    ) async {
      late List<CometChatMessageOption> options;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              options = MessageTemplateUtils.getCardBubbleOptions(
                FakeUser(),
                FakeCardMessage(1, senderUid: 'other_user'),
                context,
                FakeGroup(), // Group context
                null,
              );
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      final optionIds = options.map((o) => o.id).toList();
      expect(optionIds, contains(MessageOptionConstants.sendMessagePrivately));
    });
  });

  group('Card Message Template — Deleted Card Handling', () {
    testWidgets('contentView shows deleted bubble for deleted card message', (
      tester,
    ) async {
      final template = MessageTemplateUtils.getCardBubbleTemplate();
      final deletedCard = _DeletedFakeCardMessage(1);

      Widget? contentWidget;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              contentWidget = template.contentView?.call(
                deletedCard,
                context,
                BubbleAlignment.right,
              );
              return contentWidget ?? const SizedBox.shrink();
            },
          ),
        ),
      );
      await tester.pump();

      // Should render the deleted bubble
      expect(find.byType(CometChatDeletedBubble), findsOneWidget);
    });
  });
}

// ---------------------------------------------------------------------------
// Additional Fakes for Specific Tests
// ---------------------------------------------------------------------------

class _DeletedFakeCardMessage extends Fake implements CardMessage {
  final int _id;
  _DeletedFakeCardMessage(this._id);

  @override
  int get id => _id;

  @override
  String get type => 'card';

  @override
  String get category => 'card';

  @override
  DateTime? get deletedAt => DateTime(2026, 6, 19, 11, 0);

  @override
  User? get sender => FakeUser();

  @override
  Map<String, dynamic>? getCard() => null;

  @override
  String? getText() => null;

  @override
  String? getFallbackText() => null;

  @override
  String get receiverUid => 'test_user';

  @override
  String get receiverType => 'user';

  @override
  int get parentMessageId => 0;
}
