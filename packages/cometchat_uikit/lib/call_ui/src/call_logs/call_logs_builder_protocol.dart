import 'package:cometchat_calls_sdk/cometchat_calls_sdk.dart' hide User;

import '../../../cometchat_chat_uikit.dart';

///[CallLogsBuilderProtocol] is an interface that defines the structure for fetching the callLogs.
///It provides a generic [requestBuilder] property and methods [getRequest] and [getSearchRequest] that needs to be overridden.
abstract class CallLogsBuilderProtocol
    extends BuilderProtocol<CallLogRequestBuilder, CallLogRequest> {
  const CallLogsBuilderProtocol(super.builder);
}

///[UICallLogsBuilder] is the default [CallLogsBuilderProtocol] used when a custom builder protocol is not passed

class UICallLogsBuilder extends CallLogsBuilderProtocol {
  const UICallLogsBuilder(super.builder);

  @override
  CallLogRequest getRequest() {
    return requestBuilder.build();
  }

  @override
  CallLogRequest getSearchRequest(String val) {
    // requestBuilder.searchKeyword = val;
    return requestBuilder.build();
  }
}
