import 'package:cometchat_sdk/cometchat_sdk.dart' hide CardMessage;
import '../../../../../shared_ui/src/clean_architecture/core/result.dart';
import '../repositories/notification_feed_repository.dart';

/// Use case for fetching notification categories.
class GetCategoriesUseCase {
  final NotificationFeedRepository repository;

  const GetCategoriesUseCase(this.repository);

  /// Execute the use case to fetch categories.
  ///
  /// [request] - The built NotificationCategoriesRequest.
  Future<Result<List<NotificationCategory>>> call(
    NotificationCategoriesRequest request,
  ) async {
    return await repository.fetchCategories(request);
  }
}
