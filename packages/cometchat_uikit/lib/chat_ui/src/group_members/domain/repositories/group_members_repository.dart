import 'package:cometchat_sdk/cometchat_sdk.dart' hide CardMessage;
import '../../../../../shared_ui/src/clean_architecture/core/result.dart';

/// Repository interface for group members data operations.
/// Defines the contract for group member data access.
abstract class GroupMembersRepository {
  /// Get group members with pagination.
  ///
  /// [guid] - The group ID to fetch members for.
  /// [limit] - Maximum number of members to fetch (default: 30).
  /// [searchKeyword] - Optional keyword to filter members by name.
  ///
  /// Returns [Result<List<GroupMember>>] containing the list of members
  /// or a [Failure] with error details.
  Future<Result<List<GroupMember>>> getGroupMembers({
    required String guid,
    int limit = 30,
    String? searchKeyword,
  });

  /// Kick a member from the group.
  ///
  /// [guid] - The group ID.
  /// [uid] - The user ID of the member to kick.
  ///
  /// Returns [Result<void>] indicating success or [Failure] with error details.
  Future<Result<void>> kickGroupMember({
    required String guid,
    required String uid,
  });

  /// Ban a member from the group.
  ///
  /// [guid] - The group ID.
  /// [uid] - The user ID of the member to ban.
  ///
  /// Returns [Result<void>] indicating success or [Failure] with error details.
  Future<Result<void>> banGroupMember({
    required String guid,
    required String uid,
  });

  /// Update member scope (role) within the group.
  ///
  /// [guid] - The group ID.
  /// [uid] - The user ID of the member.
  /// [scope] - The new scope ('admin', 'moderator', 'participant').
  ///
  /// Returns [Result<void>] indicating success or [Failure] with error details.
  Future<Result<void>> updateMemberScope({
    required String guid,
    required String uid,
    required String scope,
  });

  /// Get the currently logged-in user.
  ///
  /// Returns [Result<User?>] containing the logged-in user or null,
  /// or a [Failure] with error details.
  Future<Result<User?>> getLoggedInUser();

  /// Get conversation for the group.
  ///
  /// Used for creating action messages after member operations.
  ///
  /// [guid] - The group ID.
  ///
  /// Returns [Result<Conversation?>] containing the conversation or null,
  /// or a [Failure] with error details.
  Future<Result<Conversation?>> getConversation(String guid);

  /// Reset pagination cursor so the next [getGroupMembers] call starts from
  /// the beginning. Must be called before every initial / refresh load.
  void resetPagination();
}
