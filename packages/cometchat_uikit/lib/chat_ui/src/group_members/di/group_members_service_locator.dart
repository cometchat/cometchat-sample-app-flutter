import '../domain/repositories/group_members_repository.dart';
import '../domain/usecases/get_group_members_usecase.dart';
import '../domain/usecases/load_more_group_members_usecase.dart';
import '../domain/usecases/kick_group_member_usecase.dart';
import '../domain/usecases/ban_group_member_usecase.dart';
import '../domain/usecases/update_member_scope_usecase.dart';
import '../domain/usecases/get_logged_in_user_usecase.dart';
import '../data/datasources/group_members_remote_datasource.dart';
import '../data/repositories/group_members_repository_impl.dart';

/// Service Locator for Group Members module.
/// Provides dependency injection for group members clean architecture.
/// Follows singleton pattern for consistent dependency resolution.
class GroupMembersServiceLocator {
  static final GroupMembersServiceLocator _instance =
      GroupMembersServiceLocator._internal();

  GroupMembersServiceLocator._internal();

  /// Get singleton instance.
  static GroupMembersServiceLocator get instance => _instance;

  // Data sources
  late GroupMembersRemoteDataSource _remoteDataSource;

  // Repository
  late GroupMembersRepository _repository;

  // Use cases
  late GetGroupMembersUseCase _getGroupMembersUseCase;
  late LoadMoreGroupMembersUseCase _loadMoreGroupMembersUseCase;
  late KickGroupMemberUseCase _kickGroupMemberUseCase;
  late BanGroupMemberUseCase _banGroupMemberUseCase;
  late UpdateMemberScopeUseCase _updateMemberScopeUseCase;
  late GetLoggedInUserUseCase _getLoggedInUserUseCase;

  bool _isInitialized = false;

  /// Initialize all dependencies synchronously.
  /// Call this once during app startup or before using group members module.
  void setup() {
    if (_isInitialized) {
      return; // Already initialized
    }

    // Initialize data source
    _remoteDataSource = GroupMembersRemoteDataSourceImpl();

    // Initialize repository
    _repository = GroupMembersRepositoryImpl(
      remoteDataSource: _remoteDataSource,
    );

    // Initialize use cases
    _getGroupMembersUseCase = GetGroupMembersUseCase(_repository);
    _loadMoreGroupMembersUseCase = LoadMoreGroupMembersUseCase(_repository);
    _kickGroupMemberUseCase = KickGroupMemberUseCase(_repository);
    _banGroupMemberUseCase = BanGroupMemberUseCase(_repository);
    _updateMemberScopeUseCase = UpdateMemberScopeUseCase(_repository);
    _getLoggedInUserUseCase = GetLoggedInUserUseCase(_repository);

    _isInitialized = true;
  }

  /// Initialize all dependencies asynchronously.
  /// Use this when you need to ensure all async initialization is complete.
  Future<void> setupAsync() async {
    if (_isInitialized) {
      return; // Already initialized
    }

    // Initialize data source
    _remoteDataSource = GroupMembersRemoteDataSourceImpl();

    // Initialize repository
    _repository = GroupMembersRepositoryImpl(
      remoteDataSource: _remoteDataSource,
    );

    // Initialize use cases
    _getGroupMembersUseCase = GetGroupMembersUseCase(_repository);
    _loadMoreGroupMembersUseCase = LoadMoreGroupMembersUseCase(_repository);
    _kickGroupMemberUseCase = KickGroupMemberUseCase(_repository);
    _banGroupMemberUseCase = BanGroupMemberUseCase(_repository);
    _updateMemberScopeUseCase = UpdateMemberScopeUseCase(_repository);
    _getLoggedInUserUseCase = GetLoggedInUserUseCase(_repository);

    _isInitialized = true;
  }

  /// Check if service locator is initialized.
  bool get isInitialized => _isInitialized;

  // Use case getters

  /// Get use case for fetching group members.
  GetGroupMembersUseCase get getGroupMembersUseCase {
    _ensureInitialized();
    return _getGroupMembersUseCase;
  }

  /// Get use case for loading more group members (pagination).
  LoadMoreGroupMembersUseCase get loadMoreGroupMembersUseCase {
    _ensureInitialized();
    return _loadMoreGroupMembersUseCase;
  }

  /// Get use case for kicking a group member.
  KickGroupMemberUseCase get kickGroupMemberUseCase {
    _ensureInitialized();
    return _kickGroupMemberUseCase;
  }

  /// Get use case for banning a group member.
  BanGroupMemberUseCase get banGroupMemberUseCase {
    _ensureInitialized();
    return _banGroupMemberUseCase;
  }

  /// Get use case for updating member scope.
  UpdateMemberScopeUseCase get updateMemberScopeUseCase {
    _ensureInitialized();
    return _updateMemberScopeUseCase;
  }

  /// Get use case for getting logged-in user.
  GetLoggedInUserUseCase get getLoggedInUserUseCase {
    _ensureInitialized();
    return _getLoggedInUserUseCase;
  }

  // Repository getter (for advanced use cases)

  /// Get group members repository.
  GroupMembersRepository get repository {
    _ensureInitialized();
    return _repository;
  }

  /// Ensure service locator is initialized before accessing dependencies.
  void _ensureInitialized() {
    if (!_isInitialized) {
      throw StateError(
        'GroupMembersServiceLocator is not initialized. '
        'Call setup() before accessing dependencies.',
      );
    }
  }

  /// Reset all services (useful for testing).
  Future<void> reset() async {
    _isInitialized = false;
    // Dependencies will be re-initialized on next setup() call
  }
}
