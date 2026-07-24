import 'package:cometchat_calls_sdk/cometchat_calls_sdk.dart' hide User;
import 'package:cometchat_sdk/cometchat_sdk.dart' hide CardMessage;

import '../../../../../shared_ui/src/clean_architecture/core/result.dart';

/// Repository interface for call logs data operations.
/// Defines the contract for call logs data access following Clean Architecture.
///
/// This interface abstracts all CometChat Calls SDK operations,
/// allowing for easy testing and potential alternative implementations.
abstract class CallLogsRepository {
  /// Fetches call logs with optional pagination support.
  ///
  /// [limit] - Maximum number of call logs to fetch (default: 30)
  ///
  /// Returns [Result<List<CallLog>>] containing the list of call logs on success,
  /// or a [Failure] with error details on failure.
  Future<Result<List<CallLog>>> getCallLogs({int limit = 30});

  /// Gets the currently logged-in user.
  ///
  /// Returns [Result<User?>] containing the logged-in user on success,
  /// or null if no user is logged in.
  Future<Result<User?>> getLoggedInUser();

  /// Initiates a call with the specified call object.
  ///
  /// [call] - The call object containing receiver details and call type
  ///
  /// Returns [Result<Call>] containing the initiated call on success,
  /// or a [Failure] with error details on failure.
  Future<Result<Call>> initiateCall(Call call);

  /// Gets the authentication token for the current user.
  ///
  /// Returns [Result<String?>] containing the auth token on success,
  /// or null if not available.
  Future<Result<String?>> getUserAuthToken();
}
