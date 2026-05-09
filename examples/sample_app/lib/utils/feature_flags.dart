/// Simple feature flag system for the BLoC sample app.
/// Toggle features on/off without code changes.
class FeatureFlags {
  FeatureFlags._();

  // --- Tabs ---
  static bool showConversationsTab = true;
  static bool showCallLogsTab = true;
  static bool showUsersTab = true;
  static bool showGroupsTab = true;

  // --- Calling ---
  static bool enableVoiceCalling = true;
  static bool enableVideoCalling = true;

  // --- User Features ---
  static bool showUserPresence = true;
  static bool enableBlockUser = true;
  static bool enableDeleteChat = true;

  // --- Group Features ---
  static bool enableCreateGroup = true;
  static bool enableGroupInfo = true;

  // --- Messages ---
  static bool enableThreadedMessages = true;
  static bool enableRichTextFormatting = true;
  static bool enableSearch = true;

  // --- Navigation ---
  static bool showNewChatButton = true;
  static bool showProfileMenu = true;

  // --- AI ---
  static bool enableAIAgents = true;
}
