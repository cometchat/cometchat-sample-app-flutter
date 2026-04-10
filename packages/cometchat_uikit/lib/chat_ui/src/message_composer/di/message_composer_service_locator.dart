import '../domain/repositories/message_composer_repository.dart';
import '../domain/usecases/send_text_message_usecase.dart';
import '../domain/usecases/send_media_message_usecase.dart';
import '../domain/usecases/send_custom_message_usecase.dart';
import '../domain/usecases/edit_message_usecase.dart';
import '../domain/usecases/typing_usecases.dart';
import '../domain/usecases/get_logged_in_user_usecase.dart';
import '../data/datasources/message_composer_datasource.dart';
import '../data/datasources/message_composer_datasource_impl.dart';
import '../data/repositories/message_composer_repository_impl.dart';

/// Service Locator for Message Composer module
/// Provides dependency injection for message composer clean architecture
/// Follows singleton pattern for consistent dependency resolution
class MessageComposerServiceLocator {
  static final MessageComposerServiceLocator _instance =
      MessageComposerServiceLocator._internal();

  MessageComposerServiceLocator._internal();

  /// Get singleton instance
  static MessageComposerServiceLocator get instance => _instance;

  // Data sources
  late MessageComposerDataSource _dataSource;

  // Repositories
  late MessageComposerRepository _repository;

  // Use cases
  late SendTextMessageUseCase _sendTextMessageUseCase;
  late SendMediaMessageUseCase _sendMediaMessageUseCase;
  late SendCustomMessageUseCase _sendCustomMessageUseCase;
  late EditMessageUseCase _editMessageUseCase;
  late StartTypingUseCase _startTypingUseCase;
  late EndTypingUseCase _endTypingUseCase;
  late GetMessageComposerLoggedInUserUseCase _getLoggedInUserUseCase;

  bool _isInitialized = false;

  /// Check if service locator is initialized
  bool get isInitialized => _isInitialized;

  /// Initialize all dependencies
  /// Call this once during app startup or before using message composer module
  void setup({
    MessageComposerDataSource? dataSource,
    MessageComposerRepository? repository,
  }) {
    if (_isInitialized) {
      return; // Already initialized
    }

    // Initialize data source
    _dataSource = dataSource ?? MessageComposerDataSourceImpl();

    // Initialize repository
    _repository = repository ??
        MessageComposerRepositoryImpl(
          dataSource: _dataSource,
        );

    // Initialize use cases
    _sendTextMessageUseCase = SendTextMessageUseCase(_repository);
    _sendMediaMessageUseCase = SendMediaMessageUseCase(_repository);
    _sendCustomMessageUseCase = SendCustomMessageUseCase(_repository);
    _editMessageUseCase = EditMessageUseCase(_repository);
    _startTypingUseCase = StartTypingUseCase(_repository);
    _endTypingUseCase = EndTypingUseCase(_repository);
    _getLoggedInUserUseCase = GetMessageComposerLoggedInUserUseCase(_repository);

    _isInitialized = true;
  }

  // Use case getters

  /// Get use case for sending text messages
  SendTextMessageUseCase get sendTextMessageUseCase {
    _ensureInitialized();
    return _sendTextMessageUseCase;
  }

  /// Get use case for sending media messages
  SendMediaMessageUseCase get sendMediaMessageUseCase {
    _ensureInitialized();
    return _sendMediaMessageUseCase;
  }

  /// Get use case for sending custom messages
  SendCustomMessageUseCase get sendCustomMessageUseCase {
    _ensureInitialized();
    return _sendCustomMessageUseCase;
  }

  /// Get use case for editing messages
  EditMessageUseCase get editMessageUseCase {
    _ensureInitialized();
    return _editMessageUseCase;
  }

  /// Get use case for starting typing indicator
  StartTypingUseCase get startTypingUseCase {
    _ensureInitialized();
    return _startTypingUseCase;
  }

  /// Get use case for ending typing indicator
  EndTypingUseCase get endTypingUseCase {
    _ensureInitialized();
    return _endTypingUseCase;
  }

  /// Get use case for getting logged-in user
  GetMessageComposerLoggedInUserUseCase get getLoggedInUserUseCase {
    _ensureInitialized();
    return _getLoggedInUserUseCase;
  }

  // Repository getter (for advanced use cases)

  /// Get message composer repository
  MessageComposerRepository get repository {
    _ensureInitialized();
    return _repository;
  }

  /// Ensure service locator is initialized before accessing dependencies
  /// Auto-initializes with defaults if not already initialized
  void _ensureInitialized() {
    if (!_isInitialized) {
      setup(); // Auto-initialize with defaults
    }
  }

  /// Reset all services (useful for testing)
  void reset() {
    _isInitialized = false;
  }
}
