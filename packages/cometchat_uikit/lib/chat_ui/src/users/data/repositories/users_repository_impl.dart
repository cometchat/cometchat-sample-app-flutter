import 'package:cometchat_sdk/cometchat_sdk.dart' hide CardMessage;
import '../../../../../shared_ui/src/clean_architecture/core/result.dart';
import '../../domain/repositories/users_repository.dart';
import '../datasources/users_remote_datasource.dart';
import '../datasources/users_local_datasource.dart';

/// Implementation of UsersRepository
/// Coordinates between remote and local data sources
class UsersRepositoryImpl implements UsersRepository {
  final UsersRemoteDataSource remoteDataSource;
  final UsersLocalDataSource localDataSource;

  const UsersRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  void resetRequest() {
    remoteDataSource.resetRequest();
  }

  @override
  Future<Result<List<User>>> getUsers({
    int limit = 30,
    String? searchKeyword,
    UsersRequestBuilder? usersRequestBuilder,
  }) async {
    try {
      final users = await remoteDataSource.getUsers(
        limit: limit,
        searchKeyword: searchKeyword,
        usersRequestBuilder: usersRequestBuilder,
      );

      // Cache the results locally
      await localDataSource.cacheUsers(users);

      return Success(users);
    } on UsersRemoteDataSourceException catch (e) {
      // If remote fetch fails, try to return cached data
      try {
        final cachedUsers = await localDataSource.getCachedUsers();
        return Success(cachedUsers);
      } on UsersLocalDataSourceException {
        return Failure(
          message: 'Failed to load users: ${e.message}',
          code: e.code,
          exception: e.originalException,
        );
      }
    } catch (e) {
      return Failure(
        message: 'Unexpected error while loading users: ${e.toString()}',
        exception: e is Exception ? e : null,
      );
    }
  }

  @override
  Future<Result<User>> getUserById(String uid) async {
    try {
      // Try to get from cache first
      final cachedUser = await localDataSource.getCachedUser(uid);

      if (cachedUser != null) {
        return Success(cachedUser);
      }

      // If not in cache, fetch from remote
      final user = await remoteDataSource.getUser(uid);

      // Cache it
      await localDataSource.cacheUser(user);

      return Success(user);
    } on UsersRemoteDataSourceException catch (e) {
      return Failure(
        message: 'Failed to get user: ${e.message}',
        code: e.code,
        exception: e.originalException,
      );
    } catch (e) {
      return Failure(
        message: 'Unexpected error while getting user: ${e.toString()}',
        exception: e is Exception ? e : null,
      );
    }
  }

  @override
  Future<Result<User?>> getLoggedInUser() async {
    try {
      final user = await CometChat.getLoggedInUser();
      return Success(user);
    } on CometChatException catch (e) {
      return Failure(
        message: 'Failed to get logged-in user: ${e.message}',
        code: e.code,
        exception: e,
      );
    } catch (e) {
      return Failure(
        message:
            'Unexpected error while getting logged-in user: ${e.toString()}',
        exception: e is Exception ? e : null,
      );
    }
  }

  @override
  Future<Result<void>> blockUser(String uid) async {
    try {
      await remoteDataSource.blockUser(uid);
      return const Success(null);
    } on UsersRemoteDataSourceException catch (e) {
      return Failure(
        message: 'Failed to block user: ${e.message}',
        code: e.code,
        exception: e.originalException,
      );
    } catch (e) {
      return Failure(
        message: 'Unexpected error while blocking user: ${e.toString()}',
        exception: e is Exception ? e : null,
      );
    }
  }

  @override
  Future<Result<void>> unblockUser(String uid) async {
    try {
      await remoteDataSource.unblockUser(uid);
      return const Success(null);
    } on UsersRemoteDataSourceException catch (e) {
      return Failure(
        message: 'Failed to unblock user: ${e.message}',
        code: e.code,
        exception: e.originalException,
      );
    } catch (e) {
      return Failure(
        message: 'Unexpected error while unblocking user: ${e.toString()}',
        exception: e is Exception ? e : null,
      );
    }
  }
}
