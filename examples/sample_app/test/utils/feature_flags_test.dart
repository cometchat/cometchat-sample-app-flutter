import 'package:flutter_test/flutter_test.dart';

import 'package:sample_app/utils/feature_flags.dart';

void main() {
  group('FeatureFlags', () {
    // -----------------------------------------------------------------------
    // Tab defaults
    // -----------------------------------------------------------------------

    test('tab flags default to true', () {
      expect(FeatureFlags.showConversationsTab, isTrue);
      expect(FeatureFlags.showCallLogsTab, isTrue);
      expect(FeatureFlags.showUsersTab, isTrue);
      expect(FeatureFlags.showGroupsTab, isTrue);
    });

    // -----------------------------------------------------------------------
    // Calling defaults
    // -----------------------------------------------------------------------

    test('calling flags default to true', () {
      expect(FeatureFlags.enableVoiceCalling, isTrue);
      expect(FeatureFlags.enableVideoCalling, isTrue);
    });

    // -----------------------------------------------------------------------
    // User feature defaults
    // -----------------------------------------------------------------------

    test('user feature flags default to true', () {
      expect(FeatureFlags.showUserPresence, isTrue);
      expect(FeatureFlags.enableBlockUser, isTrue);
      expect(FeatureFlags.enableDeleteChat, isTrue);
    });

    // -----------------------------------------------------------------------
    // Group feature defaults
    // -----------------------------------------------------------------------

    test('group feature flags default to true', () {
      expect(FeatureFlags.enableCreateGroup, isTrue);
      expect(FeatureFlags.enableGroupInfo, isTrue);
    });

    // -----------------------------------------------------------------------
    // Message feature defaults
    // -----------------------------------------------------------------------

    test('message feature flags default to true', () {
      expect(FeatureFlags.enableThreadedMessages, isTrue);
      expect(FeatureFlags.enableRichTextFormatting, isTrue);
      expect(FeatureFlags.enableSearch, isTrue);
    });

    // -----------------------------------------------------------------------
    // Navigation defaults
    // -----------------------------------------------------------------------

    test('navigation flags default to true', () {
      expect(FeatureFlags.showNewChatButton, isTrue);
      expect(FeatureFlags.showProfileMenu, isTrue);
    });

    // -----------------------------------------------------------------------
    // Mutability
    // -----------------------------------------------------------------------

    test('flags are mutable static fields', () {
      // Save originals
      final original = FeatureFlags.showConversationsTab;

      // Mutate
      FeatureFlags.showConversationsTab = false;
      expect(FeatureFlags.showConversationsTab, isFalse);

      // Restore
      FeatureFlags.showConversationsTab = original;
    });
  });
}
