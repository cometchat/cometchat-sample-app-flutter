import 'package:cometchat_sdk/cometchat_sdk.dart';
import '../../../../../shared_ui/src/clean_architecture/core/result.dart';

/// Repository interface for users data operations
/// Defines the contract for user data access
abstract class UsersRepository {
  /// Get users with optional pagination and search
  Future<Result<List<User>>> getUsers({
    int limit = 30,
    String? searchKeyword,
    UsersRequestBuilder? usersRequestBuilder,
  });

  /// Get a specific user by UID
  Future<Result<User>> getUserById(String uid);

  /// Get the currently logged-in user
  Future<Result<User?>> getLoggedInUser();

  /// Block a user
  Future<Result<void>> blockUser(String uid);

  /// Unblock a user
  Future<Result<void>> unblockUser(String uid);
}
