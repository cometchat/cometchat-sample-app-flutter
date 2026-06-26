import 'sdk_user_b.dart';

/// User B read/delivery receipt actions via REST API.
///
/// These trigger real WebSocket events:
///   - markAsDelivered → onMessagesDelivered on A's SDK listener
///   - markAsRead → onMessagesRead on A's SDK listener
///
/// Receipts are cumulative: marking message X as read means all messages
/// with ID ≤ X are also considered read.
class UserBReceipts {
  UserBReceipts._();

  /// Mark a message as delivered by User B.
  ///
  /// Triggers: onMessagesDelivered on A's SDK → A sees double tick.
  static Future<void> markAsDelivered(int messageId) async {
    try {
      await SdkUserB.post(
        '/messages/$messageId/delivered',
        body: {},
      );
    } catch (_) {
      // Non-fatal — some API versions handle this differently.
    }
  }

  /// Mark a message as read by User B.
  ///
  /// Triggers: onMessagesRead on A's SDK → A sees blue ticks.
  /// This is cumulative: all messages up to [messageId] are marked read.
  static Future<void> markAsRead(int messageId) async {
    try {
      await SdkUserB.post(
        '/messages/$messageId/read',
        body: {},
      );
    } catch (_) {
      // Non-fatal — receipt handling varies by SDK version.
    }
  }

  /// Mark multiple messages as read (uses the latest message ID).
  /// Cumulative behavior means only the last ID needs to be marked.
  static Future<void> markAllAsRead(List<int> messageIds) async {
    if (messageIds.isEmpty) return;
    // Sort ascending and mark the latest one — cumulative covers the rest.
    final sorted = [...messageIds]..sort();
    await markAsRead(sorted.last);
  }
}
