import '../domain/repositories/message_header_repository.dart';
import '../domain/usecases/get_user_usecase.dart';
import '../domain/usecases/get_group_usecase.dart';
import '../domain/usecases/get_logged_in_user_usecase.dart';
import '../data/repositories/message_header_repository_impl.dart';

/// Service Locator for Message Header module
/// Provides dependency injection for message header clean architecture
/// Follows singleton pattern for consistent dependency resolution
class MessageHeaderServiceLocator {
  static final MessageHeaderServiceLocator _instance =
      MessageHeaderServiceLocator._internal();

  MessageHeaderServiceLocator._internal();

  /// Get singleton instance
  static MessageHeaderServiceLocator get instance => _instance;

  // Repository
  late MessageHeaderRepository _repository;

  // Use cases
  late GetUserUseCase _getUserUseCase;
  late GetGroupUseCase _getGroupUseCase;
  late GetMessageHeaderLoggedInUserUseCase _getLoggedInUserUseCase;

  bool _isInitialized = false;

  /// Initialize all dependencies synchronously
  /// Call this once during app startup or before using message header module
  void setup({MessageHeaderRepository? repository}) {
    if (_isInitialized) {
      return; // Already initialized
    }

    // Initialize repository
    _repository = repository ?? MessageHeaderRepositoryImpl();

    // Initialize use cases
    _getUserUseCase = GetUserUseCase(_repository);
    _getGroupUseCase = GetGroupUseCase(_repository);
    _getLoggedInUserUseCase = GetMessageHeaderLoggedInUserUseCase(_repository);

    _isInitialized = true;
  }

  /// Check if service locator is initialized
  bool get isInitialized => _isInitialized;

  // Use case getters

  /// Get use case for fetching a user
  GetUserUseCase get getUserUseCase {
    _ensureInitialized();
    return _getUserUseCase;
  }

  /// Get use case for fetching a group
  GetGroupUseCase get getGroupUseCase {
    _ensureInitialized();
    return _getGroupUseCase;
  }

  /// Get use case for getting logged-in user
  GetMessageHeaderLoggedInUserUseCase get getLoggedInUserUseCase {
    _ensureInitialized();
    return _getLoggedInUserUseCase;
  }

  // Repository getter (for advanced use cases)

  /// Get message header repository
  MessageHeaderRepository get repository {
    _ensureInitialized();
    return _repository;
  }

  /// Ensure service locator is initialized before accessing dependencies
  void _ensureInitialized() {
    if (!_isInitialized) {
      throw StateError(
        'MessageHeaderServiceLocator is not initialized. '
        'Call setup() before accessing dependencies.',
      );
    }
  }

  /// Reset all services (useful for testing)
  Future<void> reset() async {
    _isInitialized = false;
    // Dependencies will be re-initialized on next setup() call
  }
}
