import 'package:flutter/foundation.dart';

/// Reactive component prop toggles. Each toggle is a [ValueNotifier] so
/// widgets can listen and rebuild instantly when a value changes.
///
/// Usage in widgets:
/// ```dart
/// ValueListenableBuilder<bool>(
///   valueListenable: ComponentToggles.instance.hideReceipts,
///   builder: (_, value, __) => CometChatMessageList(disableReceipts: value, ...),
/// )
/// ```
class ComponentToggles {
  ComponentToggles._();
  static final instance = ComponentToggles._();

  // ── Conversations ──────────────────────────────────────────────
  final receiptsVisibility = ValueNotifier<bool>(true);
  final usersStatusVisibility = ValueNotifier<bool>(true);
  final deleteConversationOption = ValueNotifier<bool>(true);
  final groupTypeVisibility = ValueNotifier<bool>(true);
  final disableSoundForMessages = ValueNotifier<bool>(false);
  final conversationsHideSearch = ValueNotifier<bool>(false);
  final conversationsSearchReadOnly = ValueNotifier<bool>(true);

  // ── Message List ───────────────────────────────────────────────
  final hideDeletedMessages = ValueNotifier<bool>(false);
  final disableReceipts = ValueNotifier<bool>(false);
  final avatarVisibility = ValueNotifier<bool>(true);
  final hideDateSeparator = ValueNotifier<bool>(false);
  final hideStickyDate = ValueNotifier<bool>(false);
  final disableReactions = ValueNotifier<bool>(false);
  final enableSwipeToReply = ValueNotifier<bool>(true);
  final hideGroupActionMessages = ValueNotifier<bool>(false);
  final enableSmartReplies = ValueNotifier<bool>(false);
  final enableConversationStarters = ValueNotifier<bool>(false);
  final startFromUnreadMessages = ValueNotifier<bool>(false);
  final showMarkAsUnreadOption = ValueNotifier<bool>(false);

  // ── Message List — hide options ────────────────────────────────
  final hideCopyMessageOption = ValueNotifier<bool>(false);
  final hideDeleteMessageOption = ValueNotifier<bool>(false);
  final hideEditMessageOption = ValueNotifier<bool>(false);
  final hideMessageInfoOption = ValueNotifier<bool>(false);
  final hideReplyInThreadOption = ValueNotifier<bool>(false);
  final hideReactionOption = ValueNotifier<bool>(false);
  final hideTranslateMessageOption = ValueNotifier<bool>(false);
  final hideShareMessageOption = ValueNotifier<bool>(false);

  // ── Message Composer ───────────────────────────────────────────
  final disableTypingEvents = ValueNotifier<bool>(false);
  final hideVoiceRecordingButton = ValueNotifier<bool>(false);
  final hideSendButton = ValueNotifier<bool>(false);
  final hideAttachmentButton = ValueNotifier<bool>(false);
  final hideStickersButton = ValueNotifier<bool>(false);
  final disableMentions = ValueNotifier<bool>(false);
  final hideBottomSafeArea = ValueNotifier<bool>(false);

  // ── Message Header ─────────────────────────────────────────────
  final hideVideoCallButton = ValueNotifier<bool>(false);
  final hideVoiceCallButton = ValueNotifier<bool>(false);
  final headerUsersStatusVisibility = ValueNotifier<bool>(true);

  // ── Users ──────────────────────────────────────────────────────
  final usersHideSearch = ValueNotifier<bool>(false);
  final usersStickyHeader = ValueNotifier<bool>(false);

  // ── Groups ─────────────────────────────────────────────────────
  final groupsHideSearch = ValueNotifier<bool>(false);
  final groupsGroupTypeVisibility = ValueNotifier<bool>(true);

  // ── Call Logs ──────────────────────────────────────────────────
  // (no boolean toggles beyond hideAppbar which is always true)

  /// Master notifier — bumped whenever any toggle changes so screens
  /// that depend on multiple toggles can do a single listen.
  final revision = ValueNotifier<int>(0);

  void _bump() => revision.value++;

  /// Convenience: call after any toggle change to notify master listeners.
  void notifyAll() => _bump();
}
