/// Configuration for dual-device E2E testing.
///
/// Device A (primary): Runs the main test suite, logged in as [userA].
/// Device B (companion): Runs the companion app, logged in as [userB].
///
/// The two devices communicate via CometChat's real-time messaging.
/// The host orchestrator coordinates startup timing.
class DualDeviceConfig {
  // --- Device A: Primary test user ---
  static const String userAUid = String.fromEnvironment(
    'TEST_USER_A_UID',
    defaultValue: 'cometchat-uid-2',
  );
  static const String userAName = String.fromEnvironment(
    'TEST_USER_A_NAME',
    defaultValue: 'Test User A',
  );

  // --- Device B: Companion/peer user ---
  static const String userBUid = String.fromEnvironment(
    'TEST_USER_B_UID',
    defaultValue: 'cometchat-uid-3',
  );
  static const String userBName = String.fromEnvironment(
    'TEST_USER_B_NAME',
    defaultValue: 'Test User B',
  );

  // --- Shared CometChat credentials ---
  static const String appId = String.fromEnvironment(
    'COMETCHAT_APP_ID',
    defaultValue: '26580020f03ff346',
  );
  static const String region = String.fromEnvironment(
    'COMETCHAT_REGION',
    defaultValue: 'in',
  );
  static const String authKey = String.fromEnvironment(
    'COMETCHAT_AUTH_KEY',
    defaultValue: '4152b0366478871f0fa8d19a287dd6f5ed5f8eff',
  );
  static const String restApiKey = String.fromEnvironment(
    'COMETCHAT_REST_API_KEY',
    defaultValue: '783d3494689f233993c6c1916da3f888684df358',
  );

  // --- Test group ---
  static const String testGroupGuid = String.fromEnvironment(
    'TEST_GROUP_GUID',
    defaultValue: 'supergroup',
  );
  static const String testGroupName = String.fromEnvironment(
    'TEST_GROUP_NAME',
    defaultValue: 'SuperGroup',
  );

  // --- Signal message prefix ---
  // Used by companion app to identify coordination messages.
  static const String signalPrefix = '__E2E_SIGNAL__';

  // --- Signal commands ---
  static const String cmdSendTextMessage = 'SEND_TEXT_MESSAGE';
  static const String cmdStartTyping = 'START_TYPING';
  static const String cmdStopTyping = 'STOP_TYPING';
  static const String cmdInitiateCall = 'INITIATE_CALL';
  static const String cmdAcceptCall = 'ACCEPT_CALL';
  static const String cmdRejectCall = 'REJECT_CALL';
  static const String cmdSendMediaMessage = 'SEND_MEDIA_MESSAGE';
  static const String cmdReady = 'READY';
  static const String cmdDone = 'DONE';
}
