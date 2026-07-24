import 'package:cometchat_sdk/cometchat_sdk.dart' hide CardMessage;
import '../../../../../shared_ui/src/clean_architecture/core/result.dart';
import '../repositories/notification_feed_repository.dart';

/// Use case for reporting engagement on a notification feed item.
class ReportFeedEngagementUseCase {
  final NotificationFeedRepository repository;

  const ReportFeedEngagementUseCase(this.repository);

  /// Execute the use case to report engagement.
  ///
  /// [feedItem] - The feed item to report engagement for.
  /// [interactionString] - Free-form string describing the engagement
  /// (e.g., "viewed", "clicked").
  Future<Result<void>> call(
    NotificationFeedItem feedItem,
    String interactionString,
  ) async {
    return await repository.reportEngagement(feedItem, interactionString);
  }
}
