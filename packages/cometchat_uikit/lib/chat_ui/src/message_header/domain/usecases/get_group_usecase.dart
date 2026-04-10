import 'package:cometchat_sdk/cometchat_sdk.dart';
import '../../../../../../shared_ui/src/clean_architecture/core/result.dart';
import '../repositories/message_header_repository.dart';

/// Use case for getting a group by GUID
class GetGroupUseCase {
  final MessageHeaderRepository repository;

  const GetGroupUseCase(this.repository);

  /// Execute the use case to get a group
  ///
  /// [guid] - The group ID to fetch
  ///
  /// Returns Result<Group> containing group or failure
  Future<Result<Group>> call(String guid) async {
    if (guid.isEmpty) {
      return const Failure(
        message: 'Group ID cannot be empty',
        code: 'INVALID_GUID',
      );
    }

    return await repository.getGroup(guid);
  }
}
