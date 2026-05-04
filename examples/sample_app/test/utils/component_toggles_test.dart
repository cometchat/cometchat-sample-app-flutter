import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sample_app/utils/component_toggles.dart';

void main() {
  group('ComponentToggles', () {
    late ComponentToggles toggles;

    setUp(() {
      toggles = ComponentToggles.instance;
    });

    // -----------------------------------------------------------------------
    // Singleton
    // -----------------------------------------------------------------------

    test('instance returns the same singleton', () {
      final a = ComponentToggles.instance;
      final b = ComponentToggles.instance;
      expect(identical(a, b), isTrue);
    });

    // -----------------------------------------------------------------------
    // Default values
    // -----------------------------------------------------------------------

    test('conversation toggles have correct defaults', () {
      expect(toggles.receiptsVisibility.value, isTrue);
      expect(toggles.usersStatusVisibility.value, isTrue);
      expect(toggles.deleteConversationOption.value, isTrue);
      expect(toggles.groupTypeVisibility.value, isTrue);
      expect(toggles.disableSoundForMessages.value, isFalse);
      expect(toggles.conversationsHideSearch.value, isFalse);
      expect(toggles.conversationsSearchReadOnly.value, isTrue);
    });

    test('message list toggles have correct defaults', () {
      expect(toggles.hideDeletedMessages.value, isFalse);
      expect(toggles.disableReceipts.value, isFalse);
      expect(toggles.avatarVisibility.value, isTrue);
      expect(toggles.hideDateSeparator.value, isFalse);
      expect(toggles.hideStickyDate.value, isFalse);
      expect(toggles.disableReactions.value, isFalse);
      expect(toggles.enableSwipeToReply.value, isTrue);
      expect(toggles.hideGroupActionMessages.value, isFalse);
      expect(toggles.enableSmartReplies.value, isFalse);
      expect(toggles.enableConversationStarters.value, isFalse);
      expect(toggles.startFromUnreadMessages.value, isTrue);
      expect(toggles.showMarkAsUnreadOption.value, isTrue);
    });

    test('message list hide options have correct defaults', () {
      expect(toggles.hideCopyMessageOption.value, isFalse);
      expect(toggles.hideDeleteMessageOption.value, isFalse);
      expect(toggles.hideEditMessageOption.value, isFalse);
      expect(toggles.hideMessageInfoOption.value, isFalse);
      expect(toggles.hideReplyInThreadOption.value, isFalse);
      expect(toggles.hideReactionOption.value, isFalse);
      expect(toggles.hideTranslateMessageOption.value, isFalse);
      expect(toggles.hideShareMessageOption.value, isFalse);
    });

    test('message composer toggles have correct defaults', () {
      expect(toggles.disableTypingEvents.value, isFalse);
      expect(toggles.hideVoiceRecordingButton.value, isFalse);
      expect(toggles.hideSendButton.value, isFalse);
      expect(toggles.hideAttachmentButton.value, isFalse);
      expect(toggles.hideStickersButton.value, isFalse);
      expect(toggles.disableMentions.value, isFalse);
      expect(toggles.hideBottomSafeArea.value, isFalse);
    });

    test('message header toggles have correct defaults', () {
      expect(toggles.hideVideoCallButton.value, isFalse);
      expect(toggles.hideVoiceCallButton.value, isFalse);
      expect(toggles.headerUsersStatusVisibility.value, isTrue);
    });

    // -----------------------------------------------------------------------
    // ValueNotifier reactivity
    // -----------------------------------------------------------------------

    test('toggles are ValueNotifiers that notify on change', () {
      int notifyCount = 0;
      toggles.disableReceipts.addListener(() => notifyCount++);

      toggles.disableReceipts.value = true;
      expect(notifyCount, 1);

      toggles.disableReceipts.value = false;
      expect(notifyCount, 2);

      // Setting same value should not notify
      toggles.disableReceipts.value = false;
      expect(notifyCount, 2);
    });

    // -----------------------------------------------------------------------
    // notifyAll / revision
    // -----------------------------------------------------------------------

    test('notifyAll bumps revision', () {
      final initialRevision = toggles.revision.value;
      toggles.notifyAll();
      expect(toggles.revision.value, initialRevision + 1);
    });

    test('revision notifier fires on notifyAll', () {
      int notifyCount = 0;
      toggles.revision.addListener(() => notifyCount++);

      toggles.notifyAll();
      expect(notifyCount, 1);

      toggles.notifyAll();
      expect(notifyCount, 2);
    });
  });
}
