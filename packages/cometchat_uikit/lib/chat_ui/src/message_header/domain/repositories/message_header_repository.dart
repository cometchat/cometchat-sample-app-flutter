import 'package:cometchat_sdk/cometchat_sdk.dart';
import '../../../../../../shared_ui/src/clean_architecture/core/result.dart';

/// Repository interface for message header data operations
/// Defines the contract for message header data access
abstract class MessageHeaderRepository {
  /// Get a user by UID
  Future<Result<User>> getUser(String uid);

  /// Get a group by GUID
  Future<Result<Group>> getGroup(String guid);

  /// Get the currently logged-in user
  Future<Result<User?>> getLoggedInUser();
}
