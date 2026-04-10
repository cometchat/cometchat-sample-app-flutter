import 'dart:async';
import 'package:cometchat_sdk/cometchat_sdk.dart';

/// Exception thrown when remote data source operations fail
class GroupsRemoteDataSourceException implements Exception {
  final String message;
  final String? code;
  final Exception? originalException;

  const GroupsRemoteDataSourceException({
    required this.message,
    this.code,
    this.originalException,
  });

  @override
  String toString() =>
      'GroupsRemoteDataSourceException(message: $message, code: $code)';
}

/// Abstract interface for groups remote data source
/// Handles all interactions with CometChat SDK for groups
abstract class GroupsRemoteDataSource {
  /// Get groups with optional pagination and search
  /// 
  /// [limit] - Maximum number of groups to fetch (default: 30)
  /// [searchKeyword] - Optional keyword to filter groups by name
  /// [joinedOnly] - If true, only returns groups the user has joined
  Future<List<Group>> getGroups({
    int limit = 30,
    String? searchKeyword,
    bool? joinedOnly,
  });

  /// Get a specific group by GUID
  /// 
  /// [guid] - The unique identifier of the group
  Future<Group> getGroupById(String guid);

  /// Join a group
  /// 
  /// [guid] - The unique identifier of the group to join
  /// [groupType] - The type of group (public, private, password)
  /// [password] - Required for password-protected groups
  Future<Group> joinGroup({
    required String guid,
    required String groupType,
    String? password,
  });

  /// Leave a group
  /// 
  /// [guid] - The unique identifier of the group to leave
  Future<void> leaveGroup(String guid);

  /// Get the currently logged in user
  Future<User?> getLoggedInUser();
}


/// Implementation of GroupsRemoteDataSource using CometChat SDK
class GroupsRemoteDataSourceImpl implements GroupsRemoteDataSource {
  GroupsRequest? _currentRequest;

  @override
  Future<List<Group>> getGroups({
    int limit = 30,
    String? searchKeyword,
    bool? joinedOnly,
  }) async {
    try {
      final requestBuilder = GroupsRequestBuilder()..limit = limit;

      if (searchKeyword != null && searchKeyword.isNotEmpty) {
        requestBuilder.searchKeyword = searchKeyword;
      }

      if (joinedOnly != null) {
        requestBuilder.joinedOnly = joinedOnly;
      }

      _currentRequest = requestBuilder.build();

      final completer = Completer<List<Group>>();

      _currentRequest!.fetchNext(
        onSuccess: (List<Group> groups) {
          if (!completer.isCompleted) {
            completer.complete(groups);
          }
        },
        onError: (CometChatException exception) {
          if (!completer.isCompleted) {
            completer.completeError(
              GroupsRemoteDataSourceException(
                message: exception.message ?? 'Failed to fetch groups',
                code: exception.code,
                originalException: exception,
              ),
            );
          }
        },
      );

      return await completer.future;
    } on CometChatException catch (e) {
      throw GroupsRemoteDataSourceException(
        message: e.message ?? 'Failed to fetch groups',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw GroupsRemoteDataSourceException(
        message: 'Unexpected error while fetching groups: ${e.toString()}',
        originalException: e is Exception ? e : null,
      );
    }
  }

  @override
  Future<Group> getGroupById(String guid) async {
    try {
      final completer = Completer<Group>();

      await CometChat.getGroup(
        guid,
        onSuccess: (Group group) {
          completer.complete(group);
        },
        onError: (CometChatException exception) {
          completer.completeError(
            GroupsRemoteDataSourceException(
              message: exception.message ?? 'Failed to get group',
              code: exception.code,
              originalException: exception,
            ),
          );
        },
      );

      return await completer.future;
    } on CometChatException catch (e) {
      throw GroupsRemoteDataSourceException(
        message: e.message ?? 'Failed to get group',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw GroupsRemoteDataSourceException(
        message: 'Unexpected error while getting group: ${e.toString()}',
        originalException: e is Exception ? e : null,
      );
    }
  }


  @override
  Future<Group> joinGroup({
    required String guid,
    required String groupType,
    String? password,
  }) async {
    try {
      final completer = Completer<Group>();

      await CometChat.joinGroup(
        guid,
        groupType,
        password: password ?? '',
        onSuccess: (Group group) {
          completer.complete(group);
        },
        onError: (CometChatException exception) {
          completer.completeError(
            GroupsRemoteDataSourceException(
              message: exception.message ?? 'Failed to join group',
              code: exception.code,
              originalException: exception,
            ),
          );
        },
      );

      return await completer.future;
    } on CometChatException catch (e) {
      throw GroupsRemoteDataSourceException(
        message: e.message ?? 'Failed to join group',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw GroupsRemoteDataSourceException(
        message: 'Unexpected error while joining group: ${e.toString()}',
        originalException: e is Exception ? e : null,
      );
    }
  }

  @override
  Future<void> leaveGroup(String guid) async {
    try {
      final completer = Completer<void>();

      await CometChat.leaveGroup(
        guid,
        onSuccess: (String response) {
          completer.complete();
        },
        onError: (CometChatException exception) {
          completer.completeError(
            GroupsRemoteDataSourceException(
              message: exception.message ?? 'Failed to leave group',
              code: exception.code,
              originalException: exception,
            ),
          );
        },
      );

      return await completer.future;
    } on CometChatException catch (e) {
      throw GroupsRemoteDataSourceException(
        message: e.message ?? 'Failed to leave group',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw GroupsRemoteDataSourceException(
        message: 'Unexpected error while leaving group: ${e.toString()}',
        originalException: e is Exception ? e : null,
      );
    }
  }

  @override
  Future<User?> getLoggedInUser() async {
    try {
      final completer = Completer<User?>();

      await CometChat.getLoggedInUser(
        onSuccess: (User user) {
          completer.complete(user);
        },
        onError: (CometChatException exception) {
          completer.completeError(
            GroupsRemoteDataSourceException(
              message: exception.message ?? 'Failed to get logged in user',
              code: exception.code,
              originalException: exception,
            ),
          );
        },
      );

      return await completer.future;
    } on CometChatException catch (e) {
      throw GroupsRemoteDataSourceException(
        message: e.message ?? 'Failed to get logged in user',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw GroupsRemoteDataSourceException(
        message: 'Unexpected error while getting logged in user: ${e.toString()}',
        originalException: e is Exception ? e : null,
      );
    }
  }
}
