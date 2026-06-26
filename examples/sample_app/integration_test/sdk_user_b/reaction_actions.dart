import 'sdk_user_b.dart';

/// User B reaction actions via REST API.
///
/// Triggers real WebSocket events:
///   - addReaction → onMessageReactionAdded on A's SDK listener
///   - removeReaction → onMessageReactionRemoved on A's SDK listener
class UserBReactions {
  UserBReactions._();

  /// Add a reaction to a message as User B.
  ///
  /// [messageId] — the message to react to.
  /// [emoji] — the reaction emoji (e.g., "👍", "❤️", "🔥").
  ///
  /// Triggers: onMessageReactionAdded on A's SDK.
  static Future<void> addReaction(int messageId, String emoji) async {
    final encodedEmoji = Uri.encodeComponent(emoji);
    await SdkUserB.post(
      '/messages/$messageId/reactions/$encodedEmoji',
      body: {},
    );
  }

  /// Remove a reaction from a message as User B.
  ///
  /// Triggers: onMessageReactionRemoved on A's SDK.
  static Future<void> removeReaction(int messageId, String emoji) async {
    final encodedEmoji = Uri.encodeComponent(emoji);
    await SdkUserB.delete(
      '/messages/$messageId/reactions/$encodedEmoji',
    );
  }
}
