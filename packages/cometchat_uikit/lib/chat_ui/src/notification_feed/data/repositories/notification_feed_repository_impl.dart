import 'package:cometchat_sdk/cometchat_sdk.dart' hide CardMessage;
import '../../../../../shared_ui/src/clean_architecture/core/result.dart';
import '../../domain/repositories/notification_feed_repository.dart';
import '../datasources/notification_feed_remote_datasource.dart';

/// Implementation of [NotificationFeedRepository].
/// Delegates to the remote data source and wraps results in [Result].
class NotificationFeedRepositoryImpl implements NotificationFeedRepository {
  final NotificationFeedRemoteDataSource remoteDataSource;

  const NotificationFeedRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Result<List<NotificationFeedItem>>> fetchFeedItems(
    NotificationFeedRequest request,
  ) async {
    try {
      final items = await remoteDataSource.fetchFeedItems(request);
      return Success(items);
    } on NotificationFeedRemoteException catch (e) {
      return Failure(
        message: e.message,
        code: e.code,
        exception: e.originalException,
      );
    } catch (e) {
      return Failure(
        message: 'Unexpected error while fetching feed items: ${e.toString()}',
        exception: e is Exception ? e : null,
      );
    }
  }

  @override
  Future<Result<List<NotificationCategory>>> fetchCategories(
    NotificationCategoriesRequest request,
  ) async {
    try {
      final categories = await remoteDataSource.fetchCategories(request);
      return Success(categories);
    } on NotificationFeedRemoteException catch (e) {
      return Failure(
        message: e.message,
        code: e.code,
        exception: e.originalException,
      );
    } catch (e) {
      return Failure(
        message: 'Unexpected error while fetching categories: ${e.toString()}',
        exception: e is Exception ? e : null,
      );
    }
  }

  @override
  Future<Result<void>> markAsDelivered(NotificationFeedItem feedItem) async {
    try {
      await remoteDataSource.markAsDelivered(feedItem);
      return const Success(null);
    } on NotificationFeedRemoteException catch (e) {
      return Failure(
        message: e.message,
        code: e.code,
        exception: e.originalException,
      );
    } catch (e) {
      return Failure(
        message: 'Unexpected error while marking as delivered: ${e.toString()}',
        exception: e is Exception ? e : null,
      );
    }
  }

  @override
  Future<Result<void>> markAsRead(NotificationFeedItem feedItem) async {
    try {
      await remoteDataSource.markAsRead(feedItem);
      return const Success(null);
    } on NotificationFeedRemoteException catch (e) {
      return Failure(
        message: e.message,
        code: e.code,
        exception: e.originalException,
      );
    } catch (e) {
      return Failure(
        message: 'Unexpected error while marking as read: ${e.toString()}',
        exception: e is Exception ? e : null,
      );
    }
  }

  @override
  Future<Result<void>> reportEngagement(
    NotificationFeedItem feedItem,
    String interactionString,
  ) async {
    try {
      await remoteDataSource.reportEngagement(feedItem, interactionString);
      return const Success(null);
    } on NotificationFeedRemoteException catch (e) {
      return Failure(
        message: e.message,
        code: e.code,
        exception: e.originalException,
      );
    } catch (e) {
      return Failure(
        message: 'Unexpected error while reporting engagement: ${e.toString()}',
        exception: e is Exception ? e : null,
      );
    }
  }

  @override
  Future<Result<int>> getUnreadCount() async {
    try {
      final count = await remoteDataSource.getUnreadCount();
      return Success(count);
    } on NotificationFeedRemoteException catch (e) {
      return Failure(
        message: e.message,
        code: e.code,
        exception: e.originalException,
      );
    } catch (e) {
      return Failure(
        message: 'Unexpected error while getting unread count: ${e.toString()}',
        exception: e is Exception ? e : null,
      );
    }
  }

  @override
  Future<Result<NotificationFeedItem>> getItem(String id) async {
    try {
      final item = await remoteDataSource.getItem(id);
      return Success(item);
    } on NotificationFeedRemoteException catch (e) {
      return Failure(
        message: e.message,
        code: e.code,
        exception: e.originalException,
      );
    } catch (e) {
      return Failure(
        message: 'Unexpected error while getting feed item: ${e.toString()}',
        exception: e is Exception ? e : null,
      );
    }
  }
}
