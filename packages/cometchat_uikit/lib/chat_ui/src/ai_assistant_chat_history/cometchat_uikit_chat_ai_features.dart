/// Utility class that provides a registry of default AI features.
///
/// This is the BLoC-era replacement for the v5 `CometChatUIKitChatAIFeatures`
/// from `apps/v5things/ai/default_ai.dart`.
///
/// Currently returns an empty list — AI feature extensions (smart replies,
/// conversation summary, etc.) can be registered here as they are implemented.
///
/// Usage:
/// ```dart
/// final aiFeatures = CometChatUIKitChatAIFeatures.getDefaultAiFeatures();
/// ```
class CometChatUIKitChatAIFeatures {
  CometChatUIKitChatAIFeatures._();

  /// Returns the list of default AI feature configurations.
  ///
  /// Each entry is a map with at minimum a `key` identifying the feature.
  /// Consumers can use this to conditionally enable AI features in the UI.
  ///
  /// Returns an empty list when no AI features are configured.
  static List<Map<String, dynamic>> getDefaultAiFeatures() {
    return [];
  }
}
