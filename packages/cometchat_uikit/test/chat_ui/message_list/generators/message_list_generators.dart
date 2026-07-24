import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart';
import 'package:cometchat_sdk/cometchat_sdk.dart';

/// Reusable generators for message-list-layer property-based tests.
///
/// `cometchat_sdk` types are not directly constructible in tests — they come
/// from the SDK as domain DTOs. We provide lightweight [Fake] subclasses with
/// just enough surface area to drive the properties we care about.

// ---------------------------------------------------------------------------
// Fakes — domain doubles
// ---------------------------------------------------------------------------

class FakeTextMessage extends Fake implements TextMessage {
  final int _id;
  final String _muid;
  final String _text;
  final int _parentMessageId;

  FakeTextMessage(
    this._id, {
    String? muid,
    String text = 'hello',
    int parentMessageId = 0,
  }) : _muid = muid ?? 'muid_$_id',
       _text = text,
       _parentMessageId = parentMessageId;

  @override
  int get id => _id;

  @override
  String get muid => _muid;

  @override
  String get text => _text;

  @override
  int get parentMessageId => _parentMessageId;

  @override
  String get type => 'text';

  @override
  String get category => 'message';

  @override
  DateTime? get sentAt => DateTime.now();

  @override
  DateTime? get readAt => null;

  @override
  DateTime? get deliveredAt => null;

  @override
  User? get sender => null;

  @override
  int get replyCount => 0;

  @override
  set replyCount(int value) {}

  // Bloc routes events through these getters during real-time message
  // handling. The properties test uses User('pbt_user') as the target.
  @override
  String get receiverUid => 'pbt_user';

  @override
  String get receiverType => 'user';

  @override
  ModerationStatusEnum? get moderationStatus => null;

  @override
  set moderationStatus(ModerationStatusEnum? value) {}

  @override
  BaseMessage? get quotedMessage => null;

  @override
  set quotedMessage(BaseMessage? value) {}

  @override
  int get quotedMessageId => 0;

  @override
  set quotedMessageId(int value) {}

  @override
  List<ReactionCount> get reactions => const [];

  @override
  Map<String, dynamic>? get metadata => null;

  @override
  DateTime? get deletedAt => null;

  @override
  set deletedAt(DateTime? value) {}

  @override
  String? get deletedBy => null;

  @override
  set deletedBy(String? value) {}

  @override
  String toString() => 'FakeTextMessage(id=$_id, muid=$_muid)';
}

class FakeBaseMessage extends Fake implements BaseMessage {
  final int _id;
  final String _muid;
  final int _parentMessageId;

  FakeBaseMessage(this._id, {String? muid, int parentMessageId = 0})
    : _muid = muid ?? 'muid_$_id',
      _parentMessageId = parentMessageId;

  @override
  int get id => _id;

  @override
  String get muid => _muid;

  @override
  int get parentMessageId => _parentMessageId;

  @override
  String get type => 'text';

  @override
  String get category => 'message';

  @override
  DateTime? get sentAt => DateTime.now();

  @override
  DateTime? get readAt => null;

  @override
  DateTime? get deliveredAt => null;

  @override
  User? get sender => null;

  @override
  int get replyCount => 0;

  @override
  set replyCount(int value) {}

  // Real-time event filtering uses these getters; safe defaults for tests.
  @override
  String get receiverUid => 'pbt_user';

  @override
  String get receiverType => 'user';

  @override
  BaseMessage? get quotedMessage => null;

  @override
  set quotedMessage(BaseMessage? value) {}

  @override
  int get quotedMessageId => 0;

  @override
  set quotedMessageId(int value) {}

  @override
  List<ReactionCount> get reactions => const [];

  @override
  Map<String, dynamic>? get metadata => null;

  @override
  DateTime? get deletedAt => null;

  @override
  set deletedAt(DateTime? value) {}

  @override
  String? get deletedBy => null;

  @override
  set deletedBy(String? value) {}

  @override
  String toString() => 'FakeBaseMessage(id=$_id, muid=$_muid)';
}

// ---------------------------------------------------------------------------
// Generators
// ---------------------------------------------------------------------------

/// Generates a positive message ID in range [1, 99999].
Generator<int> messageIdGen() => any.intInRange(1, 100000);

/// Short alphanumeric muids bounded to 1..8 chars.
Generator<String> muidGen() => any.letterOrDigits
    .map((s) => s.isEmpty ? 'a' : s)
    .map((s) => s.length > 8 ? s.substring(0, 8) : s)
    .map((s) => 'muid_$s');

/// Generates a single [BaseMessage] with a unique id.
Generator<BaseMessage> messageGen() =>
    messageIdGen().map((id) => FakeBaseMessage(id));

/// Generates a list of messages with potentially duplicate ids.
Generator<List<BaseMessage>> messagesGen({int maxLength = 20}) =>
    any.listWithLengthInRange(0, maxLength, messageGen());

/// Generates a list of messages with unique ids (deduplicated by id,
/// order preserved).
Generator<List<BaseMessage>> distinctMessagesGen({int maxLength = 20}) =>
    messagesGen(maxLength: maxLength).map((list) {
      final seen = <int>{};
      final out = <BaseMessage>[];
      for (final m in list) {
        if (m.id > 0 && seen.add(m.id)) out.add(m);
      }
      return out;
    });

// ---------------------------------------------------------------------------
// Pair helpers — for properties that need two related inputs
// ---------------------------------------------------------------------------

/// A non-empty list and a valid index into it.
class IndexedMessageList {
  final List<BaseMessage> list;
  final int index;
  const IndexedMessageList(this.list, this.index);

  BaseMessage get selected => list[index];
  int get selectedId => selected.id;

  @override
  String toString() =>
      'IndexedMessageList(len=${list.length}, idx=$index, id=$selectedId)';
}

Generator<IndexedMessageList> indexedMessageListGen({int maxLength = 20}) {
  return any
      .listWithLengthInRange(1, maxLength, messageGen())
      .bind((list) {
        return any.intInRange(0, list.length).map((i) {
          return IndexedMessageList(list, i);
        });
      })
      .map((il) {
        // Ensure the selected message has a unique id so removal by id is unambiguous.
        final targetId = il.list[il.index].id;
        final dedup = <BaseMessage>[];
        for (var i = 0; i < il.list.length; i++) {
          final m = il.list[i];
          if (i == il.index) {
            dedup.add(m);
          } else if (m.id == targetId) {
            // Replace duplicate with a fresh unique id
            dedup.add(FakeBaseMessage(targetId + 100000 + i));
          } else {
            dedup.add(m);
          }
        }
        return IndexedMessageList(dedup, il.index);
      });
}
