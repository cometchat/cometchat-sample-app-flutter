import '../domain/repositories/call_logs_repository.dart';
import '../domain/usecases/get_call_logs_usecase.dart';
import '../domain/usecases/load_more_call_logs_usecase.dart';
import '../domain/usecases/initiate_call_usecase.dart';
import '../domain/usecases/get_logged_in_user_usecase.dart';
import '../data/datasources/call_logs_remote_datasource.dart';
import '../data/datasources/call_logs_local_datasource.dart';
import '../data/repositories/call_logs_repository_impl.dart';

/// Service Locator for CallLogs module
/// Provides dependency injection for call logs clean architecture
/// Follows singleton pattern for consistent dependency resolution
class CallLogsServiceLocator {
  static final CallLogsServiceLocator _instance =
      CallLogsServiceLocator._internal();

  CallLogsServiceLocator._internal();

  /// Get singleton instance
  static CallLogsServiceLocator get instance => _instance;

  // Data sources
  late CallLogsRemoteDataSource _remoteDataSource;
  late CallLogsLocalDataSource _localDataSource;

  // Repositories
  late CallLogsRepository _repository;

  // Use cases
  late GetCallLogsUseCase _getCallLogsUseCase;
  late LoadMoreCallLogsUseCase _loadMoreCallLogsUseCase;
  late InitiateCallUseCase _initiateCallUseCase;
  late GetLoggedInUserUseCase _getLoggedInUserUseCase;

  bool _isInitialized = false;

  /// Initialize all dependencies synchronously
  /// Call this once during app startup or before using call logs module
  void setup() {
    if (_isInitialized) {
      return; // Already initialized
    }

    // Initialize data sources
    _remoteDataSource = CallLogsRemoteDataSourceImpl();
    _localDataSource = CallLogsLocalDataSourceImpl();

    // Initialize repository
    _repository = CallLogsRepositoryImpl(
      remoteDataSource: _remoteDataSource,
      localDataSource: _localDataSource,
    );

    // Initialize use cases
    _getCallLogsUseCase = GetCallLogsUseCase(_repository);
    _loadMoreCallLogsUseCase = LoadMoreCallLogsUseCase(_repository);
    _initiateCallUseCase = InitiateCallUseCase(_repository);
    _getLoggedInUserUseCase = GetLoggedInUserUseCase(_repository);

    _isInitialized = true;
  }

  /// Check if service locator is initialized
  bool get isInitialized => _isInitialized;

  // Use case getters

  /// Get use case for fetching call logs
  GetCallLogsUseCase get getCallLogsUseCase {
    _ensureInitialized();
    return _getCallLogsUseCase;
  }

  /// Get use case for loading more call logs (pagination)
  LoadMoreCallLogsUseCase get loadMoreCallLogsUseCase {
    _ensureInitialized();
    return _loadMoreCallLogsUseCase;
  }

  /// Get use case for initiating a call from a call log
  InitiateCallUseCase get initiateCallUseCase {
    _ensureInitialized();
    return _initiateCallUseCase;
  }

  /// Get use case for getting logged-in user
  GetLoggedInUserUseCase get getLoggedInUserUseCase {
    _ensureInitialized();
    return _getLoggedInUserUseCase;
  }

  // Repository getter (for advanced use cases)

  /// Get call logs repository
  CallLogsRepository get repository {
    _ensureInitialized();
    return _repository;
  }

  /// Ensure service locator is initialized before accessing dependencies.
  /// Auto-initializes with default datasources on first access.
  void _ensureInitialized() {
    if (!_isInitialized) {
      setup();
    }
  }

  /// Reset all services (useful for testing)
  Future<void> reset() async {
    _isInitialized = false;
  }
}
