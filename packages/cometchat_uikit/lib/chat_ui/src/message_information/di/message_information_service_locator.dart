import '../domain/repositories/message_information_repository.dart';
import '../domain/usecases/fetch_message_receipts_usecase.dart';
import '../data/datasources/message_information_datasource.dart';
import '../data/repositories/message_information_repository_impl.dart';

/// Service Locator for Message Information module
/// Provides dependency injection for message information clean architecture
/// Follows singleton pattern for consistent dependency resolution
///
/// Requirements: 4.3, 4.5
class MessageInformationServiceLocator {
  static final MessageInformationServiceLocator _instance =
      MessageInformationServiceLocator._internal();

  MessageInformationServiceLocator._internal();

  /// Get singleton instance
  static MessageInformationServiceLocator get instance => _instance;

  // Data sources
  late MessageInformationDataSource _dataSource;

  // Repositories
  late MessageInformationRepository _repository;

  // Use cases
  late FetchMessageReceiptsUseCase _fetchMessageReceiptsUseCase;

  bool _isInitialized = false;

  /// Initialize all dependencies synchronously
  /// Call this once during app startup or before using message information module
  void setup() {
    if (_isInitialized) {
      return; // Already initialized
    }

    // Initialize data source
    _dataSource = MessageInformationDataSourceImpl();

    // Initialize repository
    _repository = MessageInformationRepositoryImpl(dataSource: _dataSource);

    // Initialize use cases
    _fetchMessageReceiptsUseCase = FetchMessageReceiptsUseCase(_repository);

    _isInitialized = true;
  }

  /// Check if service locator is initialized
  bool get isInitialized => _isInitialized;

  // Use case getters

  /// Get use case for fetching message receipts
  FetchMessageReceiptsUseCase get fetchMessageReceiptsUseCase {
    _ensureInitialized();
    return _fetchMessageReceiptsUseCase;
  }

  // Repository getter (for advanced use cases)

  /// Get message information repository
  MessageInformationRepository get repository {
    _ensureInitialized();
    return _repository;
  }

  /// Ensure service locator is initialized before accessing dependencies
  void _ensureInitialized() {
    if (!_isInitialized) {
      throw StateError(
        'MessageInformationServiceLocator is not initialized. '
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
