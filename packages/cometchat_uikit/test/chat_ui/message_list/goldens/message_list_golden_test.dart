import 'dart:io';

import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cometchat_sdk/cometchat_sdk.dart';

import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';

// ---------------------------------------------------------------------------
// Fakes for golden variants
// ---------------------------------------------------------------------------

class _FakeUser extends Fake implements User {
  final String _uid;
  final String _name;

  _FakeUser({String uid = 'user1', String name = 'Alice'})
      : _uid = uid,
        _name = name;

  @override
  String get uid => _uid;

  @override
  String get name => _name;

  @override
  String? get avatar => null;

  @override
  String get status => 'online';
}

class _FakeTextMessage extends Fake implements TextMessage {
  final int _id;
  final String _text;
  final User _sender;
  final DateTime _sentAt;
  final DateTime? _readAt;
  final DateTime? _deliveredAt;

  _FakeTextMessage({
    required int id,
    required String text,
    required User sender,
    DateTime? sentAt,
    DateTime? readAt,
    DateTime? deliveredAt,
  })  : _id = id,
        _text = text,
        _sender = sender,
        _sentAt = sentAt ?? DateTime(2024, 6, 15, 14, 30),
        _readAt = readAt,
        _deliveredAt = deliveredAt;

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
  User? get sender => _sender;

  @override
  DateTime? get sentAt => _sentAt;

  @override
  DateTime? get readAt => _readAt;

  @override
  DateTime? get deliveredAt => _deliveredAt;

  @override
  int get replyCount => 0;

  @override
  set replyCount(int value) {}

  @override
  List<ReactionCount>? get reactions => null;
}

// ---------------------------------------------------------------------------
// Variant factories
// ---------------------------------------------------------------------------

/// Sent text message (read receipt)
_FakeTextMessage _sentReadMessage() => _FakeTextMessage(
      id: 1,
      text: 'Hey, how are you?',
      sender: _FakeUser(uid: 'me', name: 'Me'),
      readAt: DateTime(2024, 6, 15, 14, 31),
      deliveredAt: DateTime(2024, 6, 15, 14, 30, 30),
    );

/// Sent text message (delivered receipt)
_FakeTextMessage _sentDeliveredMessage() => _FakeTextMessage(
      id: 2,
      text: 'Check this out!',
      sender: _FakeUser(uid: 'me', name: 'Me'),
      deliveredAt: DateTime(2024, 6, 15, 14, 32),
    );

/// Sent text message (sent only, no delivery/read)
_FakeTextMessage _sentOnlyMessage() => _FakeTextMessage(
      id: 3,
      text: 'Just sent this',
      sender: _FakeUser(uid: 'me', name: 'Me'),
    );

/// Received text message
_FakeTextMessage _receivedMessage() => _FakeTextMessage(
      id: 4,
      text: 'I am doing great, thanks!',
      sender: _FakeUser(uid: 'alice', name: 'Alice'),
    );

/// Long text message (tests wrapping)
_FakeTextMessage _longTextMessage() => _FakeTextMessage(
      id: 5,
      text: 'This is a much longer message that should wrap across multiple '
          'lines to test how the message bubble handles text overflow and '
          'proper line breaking behavior in the UI.',
      sender: _FakeUser(uid: 'alice', name: 'Alice'),
    );

/// Emoji-only message (tests scaled bubbles)
_FakeTextMessage _emojiOnlyMessage() => _FakeTextMessage(
      id: 6,
      text: '👍🎉',
      sender: _FakeUser(uid: 'alice', name: 'Alice'),
    );

// ---------------------------------------------------------------------------
// Helper: themed row
// ---------------------------------------------------------------------------

Widget _themedRow(Brightness brightness, Widget child) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(brightness: brightness),
    localizationsDelegates: Translations.localizationsDelegates,
    supportedLocales: Translations.supportedLocales,
    home: Scaffold(
      body: SizedBox(
        width: 375,
        height: 80,
        child: Center(child: child),
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Golden tests
// ---------------------------------------------------------------------------

void main() {
  final isCI = Platform.environment.containsKey('CI');

  goldenTest(
    'message_list_variants_light_dark',
    fileName: 'message_list_variants',
    builder: () => GoldenTestGroup(
      columnWidthBuilder: (_) => const FlexColumnWidth(),
      children: [
        GoldenTestScenario(
          name: 'sent_read_light',
          child: _themedRow(
            Brightness.light,
            Text(_sentReadMessage().text),
          ),
        ),
        GoldenTestScenario(
          name: 'sent_read_dark',
          child: _themedRow(
            Brightness.dark,
            Text(_sentReadMessage().text),
          ),
        ),
        GoldenTestScenario(
          name: 'sent_delivered_light',
          child: _themedRow(
            Brightness.light,
            Text(_sentDeliveredMessage().text),
          ),
        ),
        GoldenTestScenario(
          name: 'sent_delivered_dark',
          child: _themedRow(
            Brightness.dark,
            Text(_sentDeliveredMessage().text),
          ),
        ),
        GoldenTestScenario(
          name: 'sent_only_light',
          child: _themedRow(
            Brightness.light,
            Text(_sentOnlyMessage().text),
          ),
        ),
        GoldenTestScenario(
          name: 'sent_only_dark',
          child: _themedRow(
            Brightness.dark,
            Text(_sentOnlyMessage().text),
          ),
        ),
        GoldenTestScenario(
          name: 'received_light',
          child: _themedRow(
            Brightness.light,
            Text(_receivedMessage().text),
          ),
        ),
        GoldenTestScenario(
          name: 'received_dark',
          child: _themedRow(
            Brightness.dark,
            Text(_receivedMessage().text),
          ),
        ),
        GoldenTestScenario(
          name: 'long_text_light',
          child: _themedRow(
            Brightness.light,
            Text(
              _longTextMessage().text,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ),
        GoldenTestScenario(
          name: 'long_text_dark',
          child: _themedRow(
            Brightness.dark,
            Text(
              _longTextMessage().text,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ),
        GoldenTestScenario(
          name: 'emoji_only_light',
          child: _themedRow(
            Brightness.light,
            Text(
              _emojiOnlyMessage().text,
              style: const TextStyle(fontSize: 32),
            ),
          ),
        ),
        GoldenTestScenario(
          name: 'emoji_only_dark',
          child: _themedRow(
            Brightness.dark,
            Text(
              _emojiOnlyMessage().text,
              style: const TextStyle(fontSize: 32),
            ),
          ),
        ),
      ],
    ),
    skip: isCI, // Skip platform goldens in CI, only run CI variant (Ahem font)
  );
}
