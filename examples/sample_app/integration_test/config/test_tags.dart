/// Tags for categorizing and filtering E2E tests.
///
/// Usage with `flutter test`:
///   flutter test integration_test/e2e_test.dart --tags smoke
///   flutter test integration_test/e2e_test.dart --tags realtime
///   flutter test integration_test/e2e_test.dart --exclude-tags edge
class TestTags {
  TestTags._();

  /// P0 smoke tests — core flows that must always pass.
  static const String smoke = 'smoke';

  /// Full regression suite including P1 tests.
  static const String full = 'full';

  /// Tests that exercise real-time WebSocket events (typing, presence, receipts).
  static const String realtime = 'realtime';

  /// Edge cases, race conditions, and stress tests.
  static const String edge = 'edge';

  /// Tests that require network manipulation (disconnect/reconnect).
  static const String network = 'network';

  /// Tests specific to group chat functionality.
  static const String group = 'group';

  /// Tests specific to calling functionality.
  static const String calling = 'calling';
}
