import '../../../../../cometchat_chat_uikit.dart';

/// Repository interface for threaded header data operations.
/// Abstracts template resolution for testability.
abstract class ThreadedHeaderRepository {
  /// Resolve the message template for a given message category and type.
  CometChatMessageTemplate? getMessageTemplate({
    required String category,
    required String type,
  });

  /// Get all available message templates.
  List<CometChatMessageTemplate> getAllMessageTemplates();
}
