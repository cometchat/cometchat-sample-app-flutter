import 'package:cometchat_sdk/cometchat_sdk.dart';
import '../../../../../shared_ui/src/clean_architecture/core/result.dart';

/// Repository interface for users data operations
/// Defines the contract for user data access
abstract class UsersRepository {
  /// Get users with optional pagination and search.
  /// Reuses the internal SDK request for pagination; call [resetRequest]
  /// before fetching a fresh first page.
  Future<Result<List<User>>> getUsers({
    int limit = 30,
    String? searchKeyword,
    UsersRequestBuilder? usersRequestBuilder,
  });

  /// Reset the internal SDK pagination cursor.
  /// Call before a fresh load or when search keyword changes.
  void resetRequest();

  /// Get a specific user by UID
  Future<Result<User>> getUserById(String uid);

  /// Get the currently logged-in user
  Future<Result<User?>> getLoggedInUser();

  /// Block a user
  Future<Result<void>> blockUser(String uid);

  /// Unblock a user
  Future<Result<void>> unblockUser(String uid);
}
