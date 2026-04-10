import 'package:cometchat_sdk/cometchat_sdk.dart';

/// Exception thrown when local data source operations fail
class UsersLocalDataSourceException implements Exception {
  final String message;

  const UsersLocalDataSourceException({required this.message});

  @override
  String toString() => 'UsersLocalDataSourceException(message: $message)';
}

/// Abstract interface for users local data source
/// Handles local caching of users
abstract class UsersLocalDataSource {
  /// Get cached users
  Future<List<User>> getCachedUsers();

  /// Get a cached user by UID
  Future<User?> getCachedUser(String uid);

  /// Cache users
  Future<void> cacheUsers(List<User> users);

  /// Cache a single user
  Future<void> cacheUser(User user);

  /// Remove a cached user
  Future<void> removeCachedUser(String uid);

  /// Clear all cached users
  Future<void> clearCache();
}

/// In-memory implementation of UsersLocalDataSource
class UsersLocalDataSourceImpl implements UsersLocalDataSource {
  final Map<String, User> _cache = {};

  @override
  Future<List<User>> getCachedUsers() async {
    return _cache.values.toList();
  }

  @override
  Future<User?> getCachedUser(String uid) async {
    return _cache[uid];
  }

  @override
  Future<void> cacheUsers(List<User> users) async {
    for (final user in users) {
      _cache[user.uid] = user;
    }
  }

  @override
  Future<void> cacheUser(User user) async {
    _cache[user.uid] = user;
  }

  @override
  Future<void> removeCachedUser(String uid) async {
    _cache.remove(uid);
  }

  @override
  Future<void> clearCache() async {
    _cache.clear();
  }
}
