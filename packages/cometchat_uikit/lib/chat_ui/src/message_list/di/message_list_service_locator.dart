import '../domain/repositories/message_list_repository.dart';
import '../domain/usecases/get_messages_usecase.dart';
import '../domain/usecases/load_older_messages_usecase.dart';
import '../domain/usecases/load_newer_messages_usecase.dart';
import '../domain/usecases/mark_as_read_usecase.dart';
import '../domain/usecases/mark_as_delivered_usecase.dart';
import '../domain/usecases/mark_as_unread_usecase.dart';
import '../domain/usecases/get_logged_in_user_usecase.dart';
import '../data/datasources/message_list_remote_datasource.dart';
import '../data/datasources/message_list_local_datasource.dart';
import '../data/repositories/message_list_repository_impl.dart';

/// Service Locator for Message List module.
///
/// Provides dependency injection for message list clean architecture.
/// Follows singleton pattern for consistent dependency resolution.
///
/// Example usage:
/// ```dart
/// // Initialize during app startup
/// MessageListServiceLocator.instance.setup();
///
/// // Access use cases
/// final getMessagesUseCase = MessageListServiceLocator.instance.getMessagesUseCase;
/// ```
class MessageListServiceLocator {
  static final MessageListServiceLocator _instance =
      MessageListServiceLocator._internal();

  MessageListServiceLocator._internal();

  /// Get singleton instance.
  static MessageListServiceLocator get instance => _instance;

  // Data sources
  late MessageListRemoteDataSource _remoteDataSource;
  late MessageListLocalDataSource _localDataSource;

  // Repository
  late MessageListRepository _repository;

  // Use cases
  late GetMessagesUseCase _getMessagesUseCase;
  late LoadOlderMessagesUseCase _loadOlderMessagesUseCase;
  late LoadNewerMessagesUseCase _loadNewerMessagesUseCase;
  late MarkAsReadUseCase _markAsReadUseCase;
  late MarkAsDeliveredUseCase _markAsDeliveredUseCase;
  late MarkAsUnreadUseCase _markAsUnreadUseCase;
  late GetLoggedInUserUseCase _getLoggedInUserUseCase;

  bool _isInitialized = false;

  /// Initialize all dependencies synchronously.
  void setup() {
    if (_isInitialized) return;

    _remoteDataSource = MessageListRemoteDataSourceImpl();
    _localDataSource = MessageListLocalDataSourceImpl();

    _repository = MessageListRepositoryImpl(
      remoteDataSource: _remoteDataSource,
      localDataSource: _localDataSource,
    );

    _getMessagesUseCase = GetMessagesUseCase(_repository);
    _loadOlderMessagesUseCase = LoadOlderMessagesUseCase(_repository);
    _loadNewerMessagesUseCase = LoadNewerMessagesUseCase(_repository);
    _markAsReadUseCase = MarkAsReadUseCase(_repository);
    _markAsDeliveredUseCase = MarkAsDeliveredUseCase(_repository);
    _markAsUnreadUseCase = MarkAsUnreadUseCase(_repository);
    _getLoggedInUserUseCase = GetLoggedInUserUseCase(_repository);

    _isInitialized = true;
  }

  /// Check if service locator is initialized.
  bool get isInitialized => _isInitialized;

  GetMessagesUseCase get getMessagesUseCase {
    _ensureInitialized();
    return _getMessagesUseCase;
  }

  LoadOlderMessagesUseCase get loadOlderMessagesUseCase {
    _ensureInitialized();
    return _loadOlderMessagesUseCase;
  }

  LoadNewerMessagesUseCase get loadNewerMessagesUseCase {
    _ensureInitialized();
    return _loadNewerMessagesUseCase;
  }

  MarkAsReadUseCase get markAsReadUseCase {
    _ensureInitialized();
    return _markAsReadUseCase;
  }

  MarkAsDeliveredUseCase get markAsDeliveredUseCase {
    _ensureInitialized();
    return _markAsDeliveredUseCase;
  }

  MarkAsUnreadUseCase get markAsUnreadUseCase {
    _ensureInitialized();
    return _markAsUnreadUseCase;
  }

  GetLoggedInUserUseCase get getLoggedInUserUseCase {
    _ensureInitialized();
    return _getLoggedInUserUseCase;
  }

  MessageListRepository get repository {
    _ensureInitialized();
    return _repository;
  }

  void _ensureInitialized() {
    if (!_isInitialized) {
      throw StateError(
        'MessageListServiceLocator is not initialized. '
        'Call setup() before accessing dependencies.',
      );
    }
  }

  /// Reset all services (useful for testing).
  Future<void> reset() async {
    _isInitialized = false;
  }
}
