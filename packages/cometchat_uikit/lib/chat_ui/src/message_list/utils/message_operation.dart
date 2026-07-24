import 'package:cometchat_sdk/cometchat_sdk.dart' hide CardMessage;

/// Types of operations that can be performed on the message list
enum MessageOperationType {
  /// Insert a single message
  insert,

  /// Insert multiple messages
  insertAll,

  /// Update an existing message
  update,

  /// Remove a message
  remove,

  /// Replace the entire message list
  set,
}

/// Represents an operation to be performed on the animated message list
///
/// These operations are emitted by [MessageListBloc] and consumed by
/// [CometChatAnimatedMessageList] to perform animations.
class MessageOperation {
  final MessageOperationType type;
  final BaseMessage? message;
  final BaseMessage? oldMessage;
  final List<BaseMessage>? messages;
  final List<BaseMessage>? oldMessages;
  final int? index;
  final bool animated;

  MessageOperation._({
    required this.type,
    this.message,
    this.oldMessage,
    this.messages,
    this.oldMessages,
    this.index,
    this.animated = true,
  });

  factory MessageOperation.insert(
    BaseMessage message,
    int index, {
    bool animated = true,
  }) {
    return MessageOperation._(
      type: MessageOperationType.insert,
      message: message,
      index: index,
      animated: animated,
    );
  }

  factory MessageOperation.insertAll(
    List<BaseMessage> messages,
    int index, {
    bool animated = true,
  }) {
    return MessageOperation._(
      type: MessageOperationType.insertAll,
      messages: messages,
      index: index,
      animated: animated,
    );
  }

  factory MessageOperation.update(
    BaseMessage oldMessage,
    BaseMessage newMessage,
    int index,
  ) {
    return MessageOperation._(
      type: MessageOperationType.update,
      message: newMessage,
      oldMessage: oldMessage,
      index: index,
      animated: false,
    );
  }

  factory MessageOperation.remove(
    BaseMessage message,
    int index, {
    bool animated = true,
  }) {
    return MessageOperation._(
      type: MessageOperationType.remove,
      message: message,
      index: index,
      animated: animated,
    );
  }

  factory MessageOperation.set(
    List<BaseMessage> messages, {
    List<BaseMessage>? oldMessages,
    bool animated = true,
  }) {
    return MessageOperation._(
      type: MessageOperationType.set,
      messages: messages,
      oldMessages: oldMessages,
      animated: animated,
    );
  }

  @override
  String toString() {
    return 'MessageOperation(type: $type, index: $index, animated: $animated)';
  }
}
