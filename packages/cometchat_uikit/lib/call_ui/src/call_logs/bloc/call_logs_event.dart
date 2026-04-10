import 'package:cometchat_calls_sdk/cometchat_calls_sdk.dart' hide User;
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

/// Base class for all call logs events
/// Uses Equatable for proper event comparison in BLoC
abstract class CallLogsEvent extends Equatable {
  const CallLogsEvent();

  @override
  List<Object?> get props => [];
}

/// Load initial call logs
class LoadCallLogs extends CallLogsEvent {
  const LoadCallLogs();
}

/// Load more call logs (pagination)
class LoadMoreCallLogs extends CallLogsEvent {
  const LoadMoreCallLogs();
}

/// Refresh call logs list
class RefreshCallLogs extends CallLogsEvent {
  const RefreshCallLogs();
}

/// Initiate a call from a call log entry
class InitiateCallFromLog extends CallLogsEvent {
  final CallLog callLog;
  final BuildContext context;

  const InitiateCallFromLog({
    required this.callLog,
    required this.context,
  });

  @override
  List<Object?> get props => [callLog, context];
}
