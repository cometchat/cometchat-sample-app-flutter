import '../../../../../cometchat_chat_uikit.dart';
import '../../domain/repositories/threaded_header_repository.dart';
import '../datasources/threaded_header_datasource.dart';

/// Implementation of [ThreadedHeaderRepository].
class ThreadedHeaderRepositoryImpl implements ThreadedHeaderRepository {
  final ThreadedHeaderDataSource dataSource;
  const ThreadedHeaderRepositoryImpl({required this.dataSource});

  @override
  CometChatMessageTemplate? getMessageTemplate({
    required String category,
    required String type,
  }) {
    return dataSource.getMessageTemplate(category: category, type: type);
  }

  @override
  List<CometChatMessageTemplate> getAllMessageTemplates() {
    return dataSource.getAllMessageTemplates();
  }
}
