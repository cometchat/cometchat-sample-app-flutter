import '../../../../shared_ui/cometchat_uikit_shared.dart';

/// Three-tier ordering for the conversations list:
/// `[system pins][user pins][normal rows]`.
///
/// A system pin is a server/admin-placed pin whose `pinnedBy` carries the
/// `app_system` sentinel; a user pin is any other pinned row. Every
/// socket-driven insertion or move places the conversation at the **top of
/// its own tier only** — activity never lifts a normal row above a pin, or
/// a user pin above a system pin.
class ConversationTierOrdering {
  ConversationTierOrdering._();

  /// `pinnedBy` sentinel the backend stamps on admin/system pins.
  static const String appSystemPinner = 'app_system';

  static const int systemPinTier = 0;
  static const int userPinTier = 1;
  static const int normalTier = 2;

  /// The tier a conversation belongs to. An unpinned row is [normalTier]
  /// regardless of any stale `pinnedBy` remnant — `pinnedAt` is the pin's
  /// source of truth.
  static int tierOf(Conversation conversation) {
    if (conversation.pinnedAt == null) return normalTier;
    return conversation.pinnedBy == appSystemPinner
        ? systemPinTier
        : userPinTier;
  }

  /// Index where a row of [tier] enters [rows] — the top of its own tier:
  /// skip every leading row belonging to a higher tier.
  ///
  /// Counts leading rows only: if interleaving ever happens (it shouldn't),
  /// stray higher-tier rows below the boundary don't push the insert down,
  /// which degrades gracefully instead of scattering inserts.
  static int tierTopIndex(int tier, List<Conversation> rows) {
    var index = 0;
    while (index < rows.length && tierOf(rows[index]) < tier) {
      index++;
    }
    return index;
  }
}
