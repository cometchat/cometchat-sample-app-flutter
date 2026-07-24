import '../domain/repositories/conversations_repository.dart';
import '../domain/usecases/get_conversations_usecase.dart';
import '../domain/usecases/load_more_conversations_usecase.dart';
import '../domain/usecases/delete_conversation_usecase.dart';
import '../domain/usecases/get_logged_in_user_usecase.dart';
import '../domain/usecases/get_conversation_usecase.dart';
import '../domain/usecases/mark_as_delivered_usecase.dart';
import '../data/datasources/conversations_remote_datasource.dart';
import '../data/datasources/conversations_local_datasource.dart';
import '../data/repositories/conversations_repository_impl.dart';

/// Service Locator for Conversations module
/// Provides dependency injection for conversations clean architecture
/// Follows singleton pattern for consistent dependency resolution
class ConversationsServiceLocator {
  static final ConversationsServiceLocator _instance =
      ConversationsServiceLocator._internal();

  ConversationsServiceLocator._internal();

  /// Get singleton instance
  static ConversationsServiceLocator get instance => _instance;

  // Data sources
  late ConversationsRemoteDataSource _remoteDataSource;
  late ConversationsLocalDataSource _localDataSource;

  // Repositories
  late ConversationsRepository _repository;

  // Use cases
  late GetConversationsUseCase _getConversationsUseCase;
  late LoadMoreConversationsUseCase _loadMoreConversationsUseCase;
  late DeleteConversationUseCase _deleteConversationUseCase;
  late GetLoggedInUserUseCase _getLoggedInUserUseCase;
  late GetConversationUseCase _getConversationUseCase;
  late MarkAsDeliveredUseCase _markAsDeliveredUseCase;

  bool _isInitialized = false;

  /// Initialize all dependencies synchronously
  /// Call this once during app startup or before using conversations module
  void setup() {
    if (_isInitialized) {
      return; // Already initialized
    }

    // Initialize data sources
    _remoteDataSource = ConversationsRemoteDataSourceImpl();
    _localDataSource = ConversationsLocalDataSourceImpl();

    // Initialize repository
    _repository = ConversationsRepositoryImpl(
      remoteDataSource: _remoteDataSource,
      localDataSource: _localDataSource,
    );

    // Initialize use cases
    _getConversationsUseCase = GetConversationsUseCase(_repository);
    _loadMoreConversationsUseCase = LoadMoreConversationsUseCase(_repository);
    _deleteConversationUseCase = DeleteConversationUseCase(_repository);
    _getLoggedInUserUseCase = GetLoggedInUserUseCase(_repository);
    _getConversationUseCase = GetConversationUseCase(_repository);
    _markAsDeliveredUseCase = MarkAsDeliveredUseCase(_repository);

    _isInitialized = true;
  }

  /// Initialize all dependencies asynchronously
  /// Use this when you need to ensure all async initialization is complete
  Future<void> setupAsync() async {
    if (_isInitialized) {
      return; // Already initialized
    }

    // Initialize data sources
    _remoteDataSource = ConversationsRemoteDataSourceImpl();
    _localDataSource = ConversationsLocalDataSourceImpl();

    // Initialize repository
    _repository = ConversationsRepositoryImpl(
      remoteDataSource: _remoteDataSource,
      localDataSource: _localDataSource,
    );

    // Initialize use cases
    _getConversationsUseCase = GetConversationsUseCase(_repository);
    _loadMoreConversationsUseCase = LoadMoreConversationsUseCase(_repository);
    _deleteConversationUseCase = DeleteConversationUseCase(_repository);
    _getLoggedInUserUseCase = GetLoggedInUserUseCase(_repository);
    _getConversationUseCase = GetConversationUseCase(_repository);
    _markAsDeliveredUseCase = MarkAsDeliveredUseCase(_repository);

    _isInitialized = true;
  }

  /// Check if service locator is initialized
  bool get isInitialized => _isInitialized;

  // Use case getters

  /// Get use case for fetching conversations
  GetConversationsUseCase get getConversationsUseCase {
    _ensureInitialized();
    return _getConversationsUseCase;
  }

  /// Get use case for loading more conversations (pagination)
  LoadMoreConversationsUseCase get loadMoreConversationsUseCase {
    _ensureInitialized();
    return _loadMoreConversationsUseCase;
  }

  /// Get use case for deleting a conversation
  DeleteConversationUseCase get deleteConversationUseCase {
    _ensureInitialized();
    return _deleteConversationUseCase;
  }

  /// Get use case for getting logged-in user
  GetLoggedInUserUseCase get getLoggedInUserUseCase {
    _ensureInitialized();
    return _getLoggedInUserUseCase;
  }

  /// Get use case for getting a single conversation
  GetConversationUseCase get getConversationUseCase {
    _ensureInitialized();
    return _getConversationUseCase;
  }

  /// Get use case for marking messages as delivered
  MarkAsDeliveredUseCase get markAsDeliveredUseCase {
    _ensureInitialized();
    return _markAsDeliveredUseCase;
  }

  // Repository getter (for advanced use cases)

  /// Get conversations repository
  ConversationsRepository get repository {
    _ensureInitialized();
    return _repository;
  }

  /// Ensure service locator is initialized before accessing dependencies
  void _ensureInitialized() {
    if (!_isInitialized) {
      throw StateError(
        'ConversationsServiceLocator is not initialized. '
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
