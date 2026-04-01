/// [EnterKeyBehavior] is an enum defining the behavior when the Enter key
/// is pressed in the [CometChatCompactMessageComposer].
///
/// This allows users to configure whether pressing Enter sends the message
/// immediately or inserts a new line for multi-line input.
enum EnterKeyBehavior {
  /// Pressing Enter sends the message immediately.
  ///
  /// This is the default behavior, optimized for quick messaging.
  /// Users can use Shift+Enter to insert a new line when this mode is active.
  sendMessage,

  /// Pressing Enter inserts a new line character.
  ///
  /// This mode is useful for composing longer messages with multiple paragraphs.
  /// Users must tap the send button to send the message.
  newLine,
}
