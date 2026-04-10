/// Constants for CometChat action types.
///
/// These constants represent different types of actions that can occur
/// in group conversations (member joined, left, kicked, etc.).
class CometChatActionType {
  /// Action when a member joins a group
  static const String joined = 'joined';

  /// Action when a member leaves a group
  static const String left = 'left';

  /// Action when a member is kicked from a group
  static const String kicked = 'kicked';

  /// Action when a member is banned from a group
  static const String banned = 'banned';

  /// Action when a member is unbanned from a group
  static const String unbanned = 'unbanned';

  /// Action when a member is added to a group
  static const String added = 'added';

  /// Action when a member's scope is changed
  static const String scopeChanged = 'scopeChanged';
}
