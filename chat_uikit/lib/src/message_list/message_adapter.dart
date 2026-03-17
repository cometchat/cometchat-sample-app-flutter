import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';
import 'package:cometchat_uikit_shared/src/cometchat_message_list/chatwidget/flutter_chat_core/flutter_chat_core.dart' as core;

/// Adapter to convert CometChat BaseMessage to flutter_chat_ui Message
class MessageAdapter {
  /// Generate a hash string representing the current state of reactions
  /// This is used to detect when reactions change on a message
  static String _getReactionsHash(List<ReactionCount> reactions) {
    if (reactions.isEmpty) return '';
    // Create a deterministic string from reactions
    final sortedReactions = List<ReactionCount>.from(reactions)
      ..sort((a, b) => (a.reaction ?? '').compareTo(b.reaction ?? ''));
    return sortedReactions
        .map((r) => '${r.reaction}:${r.count}:${r.reactedByMe}')
        .join('|');
  }

  /// Convert CometChat BaseMessage to flutter_chat_ui Message
  static core.Message toFlutterChatMessage(BaseMessage baseMessage) {
    final authorId = baseMessage.sender?.uid ?? 'unknown';
    // sentAt is already a DateTime object in CometChat SDK
    final createdAt = baseMessage.sentAt ?? DateTime.now();

    // Generate reactions hash to detect reaction changes
    final reactionsHash = _getReactionsHash(baseMessage.reactions);

    // Store the original message as metadata
    // Include the baseMessage.id and updatedAt in metadata so the Message changes when they change
    final metadata = <String, dynamic>{
      'originalMessage': baseMessage,
      'messageType': baseMessage.type,
      'category': baseMessage.category,
      'baseMessageId': baseMessage.id, // Add this so equality check detects changes
      'updatedAt': baseMessage.updatedAt?.millisecondsSinceEpoch, // Add this for poll updates
      'deletedAt': baseMessage.deletedAt?.millisecondsSinceEpoch, // Add this to detect deletion
      'reactionsHash': reactionsHash, // Add this to detect reaction changes
      'hasError': baseMessage.metadata?.containsKey('fileSizeError') == true ||
                  baseMessage.metadata?.containsKey('error') == true, // Detect error state changes
    };

    // For now, convert all messages to text messages to simplify
    // This ensures compatibility while we can render with custom builders
    String displayText = '';

    if (baseMessage is TextMessage) {
      displayText = baseMessage.text;
    } else if (baseMessage is MediaMessage) {
      displayText = '[${baseMessage.type} message]';
    } else if (baseMessage is CustomMessage) {
      metadata['customType'] = baseMessage.type;
      metadata['customData'] = baseMessage.customData;
      displayText = baseMessage.customData?['message']?.toString() ?? '[Custom message]';
    } else {
      displayText = '[Unsupported message]';
    }

    // Use muid as the stable ID when available (for messages in progress)
    // This ensures the Message ID stays the same when baseMessage.id changes (pending→sent)
    // Fall back to id.toString() for messages loaded from server that don't have muid
    final messageId = baseMessage.muid.isNotEmpty
        ? baseMessage.muid
        : baseMessage.id.toString();

    return core.Message.text(
      id: messageId,
      authorId: authorId,
      createdAt: createdAt,
      text: displayText,
      metadata: metadata,
    );
  }

  /// Convert a list of CometChat BaseMessages to flutter_chat_ui Messages
  static List<core.Message> toFlutterChatMessages(List<BaseMessage> baseMessages) {
    return baseMessages.map((msg) => toFlutterChatMessage(msg)).toList();
  }

  /// Get the original BaseMessage from flutter_chat_ui Message metadata
  static BaseMessage? getOriginalMessage(core.Message message) {
    return message.metadata?['originalMessage'] as BaseMessage?;
  }
}