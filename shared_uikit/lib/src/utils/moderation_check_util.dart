import 'package:cometchat_sdk/utils/enums/moderation_status_enum.dart';
import '../../cometchat_uikit_shared.dart';

class ModerationCheckUtil {
  // Private constructor
  ModerationCheckUtil._();

  // Singleton instance
  static final ModerationCheckUtil instance = ModerationCheckUtil._();

  // Whether to hide moderation status (defaults to false)
  bool hideModerationStatus = false;

  // Method to check if message is disapproved (respects hideModerationStatus flag)
  bool isMessageDisapprovedFromModeration(BaseMessage message) {
    return (message is TextMessage &&
        message.moderationStatus?.value ==
            ModerationStatusEnum.DISAPPROVED.value) ||
        (message is MediaMessage &&
            message.moderationStatus?.value == ModerationStatusEnum.DISAPPROVED.value);
  }
}
