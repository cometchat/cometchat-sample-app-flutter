import '../domain/repositories/ai_assistant_chat_history_repository.dart';
import '../domain/usecases/fetch_chat_history_usecase.dart';
import '../domain/usecases/delete_chat_history_message_usecase.dart';
import '../domain/usecases/get_logged_in_user_usecase.dart';
import '../data/datasources/ai_assistant_chat_history_remote_datasource.dart';
import '../data/repositories/ai_assistant_chat_history_repository_impl.dart';

/// Service Locator for AI Assistant Chat History module.
///
/// Provides dependency injection following singleton pattern
/// consistent with other UIKit components.
class AIAssistantChatHistoryServiceLocator {
  static final AIAssistantChatHistoryServiceLocator _instance =
      AIAssistantChatHistoryServiceLocator._internal();

  AIAssistantChatHistoryServiceLocator._internal();

  /// Get singleton instance.
  static AIAssistantChatHistoryServiceLocator get instance => _instance;

  // Data sources
  late AIAssistantChatHistoryRemoteDataSource _remoteDataSource;

  // Repository
  late AIAssistantChatHistoryRepository _repository;

  // Use cases
  late FetchChatHistoryUseCase _fetchChatHistoryUseCase;
  late DeleteChatHistoryMessageUseCase _deleteChatHistoryMessageUseCase;
  late GetLoggedInUserUseCase _getLoggedInUserUseCase;

  bool _isInitialized = false;

  /// Initialize all dependencies synchronously.
  void setup() {
    if (_isInitialized) return;

    _remoteDataSource = AIAssistantChatHistoryRemoteDataSourceImpl();

    _repository = AIAssistantChatHistoryRepositoryImpl(
      remoteDataSource: _remoteDataSource,
    );

    _fetchChatHistoryUseCase = FetchChatHistoryUseCase(_repository);
    _deleteChatHistoryMessageUseCase =
        DeleteChatHistoryMessageUseCase(_repository);
    _getLoggedInUserUseCase = GetLoggedInUserUseCase(_repository);

    _isInitialized = true;
  }

  /// Check if service locator is initialized.
  bool get isInitialized => _isInitialized;

  FetchChatHistoryUseCase get fetchChatHistoryUseCase {
    _ensureInitialized();
    return _fetchChatHistoryUseCase;
  }

  DeleteChatHistoryMessageUseCase get deleteChatHistoryMessageUseCase {
    _ensureInitialized();
    return _deleteChatHistoryMessageUseCase;
  }

  GetLoggedInUserUseCase get getLoggedInUserUseCase {
    _ensureInitialized();
    return _getLoggedInUserUseCase;
  }

  AIAssistantChatHistoryRepository get repository {
    _ensureInitialized();
    return _repository;
  }

  void _ensureInitialized() {
    if (!_isInitialized) {
      throw StateError(
        'AIAssistantChatHistoryServiceLocator is not initialized. '
        'Call setup() before accessing dependencies.',
      );
    }
  }

  /// Reset all services (useful for testing).
  Future<void> reset() async {
    _isInitialized = false;
  }
}
