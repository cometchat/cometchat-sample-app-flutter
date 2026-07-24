import '../domain/repositories/groups_repository.dart';
import '../domain/usecases/get_groups_usecase.dart';
import '../domain/usecases/load_more_groups_usecase.dart';
import '../domain/usecases/join_group_usecase.dart';
import '../domain/usecases/leave_group_usecase.dart';
import '../domain/usecases/get_logged_in_user_usecase.dart';
import '../data/datasources/groups_remote_datasource.dart';
import '../data/repositories/groups_repository_impl.dart';

/// Service locator for Groups module dependency injection
///
/// Provides singleton access to all groups-related dependencies.
/// Must call [setup] before accessing any dependencies.
///
/// Requirements: 4.1, 4.2, 4.3, 4.4, 4.5
class GroupsServiceLocator {
  // Singleton pattern with private constructor (Requirement 4.1)
  static final GroupsServiceLocator _instance =
      GroupsServiceLocator._internal();
  GroupsServiceLocator._internal();
  static GroupsServiceLocator get instance => _instance;

  // Dependencies
  late GroupsRemoteDataSource _remoteDataSource;
  late GroupsRepository _repository;
  late GetGroupsUseCase _getGroupsUseCase;
  late LoadMoreGroupsUseCase _loadMoreGroupsUseCase;
  late JoinGroupUseCase _joinGroupUseCase;
  late LeaveGroupUseCase _leaveGroupUseCase;
  late GetLoggedInUserUseCase _getLoggedInUserUseCase;

  bool _isInitialized = false;

  /// Whether the service locator has been initialized
  bool get isInitialized => _isInitialized;

  /// Initialize all dependencies (Requirement 4.2)
  ///
  /// Must be called before accessing any dependencies.
  /// Safe to call multiple times - subsequent calls are no-ops.
  void setup() {
    if (_isInitialized) return;

    // Initialize data sources
    _remoteDataSource = GroupsRemoteDataSourceImpl();

    // Initialize repository
    _repository = GroupsRepositoryImpl(remoteDataSource: _remoteDataSource);

    // Initialize use cases
    _getGroupsUseCase = GetGroupsUseCase(_repository);
    _loadMoreGroupsUseCase = LoadMoreGroupsUseCase(_repository);
    _joinGroupUseCase = JoinGroupUseCase(_repository);
    _leaveGroupUseCase = LeaveGroupUseCase(_repository);
    _getLoggedInUserUseCase = GetLoggedInUserUseCase(_repository);

    _isInitialized = true;
  }

  /// Ensure the service locator is initialized before accessing dependencies
  ///
  /// Throws [StateError] if accessed before [setup] is called (Requirement 4.4)
  void _ensureInitialized() {
    if (!_isInitialized) {
      throw StateError(
        'GroupsServiceLocator is not initialized. Call setup() first.',
      );
    }
  }

  // Getters for all use cases and repository (Requirement 4.3)

  /// Get the groups repository
  GroupsRepository get repository {
    _ensureInitialized();
    return _repository;
  }

  /// Get the GetGroupsUseCase for fetching groups
  GetGroupsUseCase get getGroupsUseCase {
    _ensureInitialized();
    return _getGroupsUseCase;
  }

  /// Get the LoadMoreGroupsUseCase for pagination
  LoadMoreGroupsUseCase get loadMoreGroupsUseCase {
    _ensureInitialized();
    return _loadMoreGroupsUseCase;
  }

  /// Get the JoinGroupUseCase for joining groups
  JoinGroupUseCase get joinGroupUseCase {
    _ensureInitialized();
    return _joinGroupUseCase;
  }

  /// Get the LeaveGroupUseCase for leaving groups
  LeaveGroupUseCase get leaveGroupUseCase {
    _ensureInitialized();
    return _leaveGroupUseCase;
  }

  /// Get the GetLoggedInUserUseCase for retrieving the current user
  GetLoggedInUserUseCase get getLoggedInUserUseCase {
    _ensureInitialized();
    return _getLoggedInUserUseCase;
  }

  /// Reset the service locator for testing purposes (Requirement 4.5)
  ///
  /// After calling this method, [setup] must be called again before
  /// accessing any dependencies.
  Future<void> reset() async {
    _isInitialized = false;
  }
}
