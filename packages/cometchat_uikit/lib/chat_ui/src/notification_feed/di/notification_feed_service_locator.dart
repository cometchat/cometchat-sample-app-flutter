import '../domain/repositories/notification_feed_repository.dart';
import '../domain/usecases/get_feed_items_usecase.dart';
import '../domain/usecases/get_categories_usecase.dart';
import '../domain/usecases/mark_feed_delivered_usecase.dart';
import '../domain/usecases/mark_feed_read_usecase.dart';
import '../domain/usecases/report_feed_engagement_usecase.dart';
import '../domain/usecases/get_unread_count_usecase.dart';
import '../domain/usecases/get_feed_item_usecase.dart';
import '../data/datasources/notification_feed_remote_datasource.dart';
import '../data/repositories/notification_feed_repository_impl.dart';

/// Service Locator for Notification Feed module.
/// Provides dependency injection for notification feed clean architecture.
/// Follows singleton pattern for consistent dependency resolution.
class NotificationFeedServiceLocator {
  static final NotificationFeedServiceLocator _instance =
      NotificationFeedServiceLocator._internal();

  NotificationFeedServiceLocator._internal();

  /// Get singleton instance.
  static NotificationFeedServiceLocator get instance => _instance;

  // Data sources
  late NotificationFeedRemoteDataSource _remoteDataSource;

  // Repositories
  late NotificationFeedRepository _repository;

  // Use cases
  late GetFeedItemsUseCase _getFeedItemsUseCase;
  late GetCategoriesUseCase _getCategoriesUseCase;
  late MarkFeedDeliveredUseCase _markFeedDeliveredUseCase;
  late MarkFeedReadUseCase _markFeedReadUseCase;
  late ReportFeedEngagementUseCase _reportFeedEngagementUseCase;
  late GetUnreadCountUseCase _getUnreadCountUseCase;
  late GetFeedItemUseCase _getFeedItemUseCase;

  bool _isInitialized = false;

  /// Initialize all dependencies synchronously.
  /// Call this once during app startup or before using notification feed module.
  void setup() {
    if (_isInitialized) {
      return;
    }

    // Initialize data sources
    _remoteDataSource = NotificationFeedRemoteDataSourceImpl();

    // Initialize repository
    _repository = NotificationFeedRepositoryImpl(
      remoteDataSource: _remoteDataSource,
    );

    // Initialize use cases
    _getFeedItemsUseCase = GetFeedItemsUseCase(_repository);
    _getCategoriesUseCase = GetCategoriesUseCase(_repository);
    _markFeedDeliveredUseCase = MarkFeedDeliveredUseCase(_repository);
    _markFeedReadUseCase = MarkFeedReadUseCase(_repository);
    _reportFeedEngagementUseCase = ReportFeedEngagementUseCase(_repository);
    _getUnreadCountUseCase = GetUnreadCountUseCase(_repository);
    _getFeedItemUseCase = GetFeedItemUseCase(_repository);

    _isInitialized = true;
  }

  /// Check if service locator is initialized.
  bool get isInitialized => _isInitialized;

  // Use case getters

  /// Get use case for fetching feed items.
  GetFeedItemsUseCase get getFeedItemsUseCase {
    _ensureInitialized();
    return _getFeedItemsUseCase;
  }

  /// Get use case for fetching categories.
  GetCategoriesUseCase get getCategoriesUseCase {
    _ensureInitialized();
    return _getCategoriesUseCase;
  }

  /// Get use case for marking feed items as delivered.
  MarkFeedDeliveredUseCase get markFeedDeliveredUseCase {
    _ensureInitialized();
    return _markFeedDeliveredUseCase;
  }

  /// Get use case for marking feed items as read.
  MarkFeedReadUseCase get markFeedReadUseCase {
    _ensureInitialized();
    return _markFeedReadUseCase;
  }

  /// Get use case for reporting feed engagement.
  ReportFeedEngagementUseCase get reportFeedEngagementUseCase {
    _ensureInitialized();
    return _reportFeedEngagementUseCase;
  }

  /// Get use case for getting unread count.
  GetUnreadCountUseCase get getUnreadCountUseCase {
    _ensureInitialized();
    return _getUnreadCountUseCase;
  }

  /// Get use case for fetching a single feed item.
  GetFeedItemUseCase get getFeedItemUseCase {
    _ensureInitialized();
    return _getFeedItemUseCase;
  }

  // Repository getter (for advanced use cases)

  /// Get notification feed repository.
  NotificationFeedRepository get repository {
    _ensureInitialized();
    return _repository;
  }

  /// Ensure service locator is initialized before accessing dependencies.
  void _ensureInitialized() {
    if (!_isInitialized) {
      throw StateError(
        'NotificationFeedServiceLocator is not initialized. '
        'Call setup() before accessing dependencies.',
      );
    }
  }

  /// Reset all services (useful for testing).
  Future<void> reset() async {
    _isInitialized = false;
  }
}
