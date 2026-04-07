import 'package:flutter/material.dart';
import 'package:cometchat_calls_uikit/cometchat_calls_uikit.dart';
import 'package:get/get.dart';

import '../call_log_detail_utils.dart';
import '../cometchat_call_log_details.dart';
import 'cometchat_call_log_history_controller.dart';

class CometChatCallLogHistory extends StatefulWidget {
  const CometChatCallLogHistory({
    super.key,
    this.callUser,
    this.callGroup,
  });

  ///[callUser] CallUser object for CallLog History
  final CallUser? callUser;

  ///[callGroup] CallGroup object for CallLog History
  final CallGroup? callGroup;

  @override
  State<CometChatCallLogHistory> createState() =>
      _CometChatCallLogHistoryState();
}

class _CometChatCallLogHistoryState extends State<CometChatCallLogHistory> {
  CometChatCallLogHistoryController? cometChatCallLogHistoryController;
  late CometChatColorPalette colorPalette;
  late CometChatTypography typography;
  late CometChatSpacing spacing;

  @override
  void initState() {
    super.initState();
    initialize();
  }

  void initialize() async {
    String? userAuthToken = await CometChatUIKitCalls.getUserAuthToken();
    cometChatCallLogHistoryController = CometChatCallLogHistoryController(
      callLogsBuilderProtocol: UICallLogsBuilder(CallLogRequestBuilder()
        ..authToken = userAuthToken
        ..callCategory = CometChatCallsConstants.callCategoryCall
        ..uid = (widget.callUser != null) ? widget.callUser?.uid : null
        ..guid = (widget.callGroup != null) ? widget.callGroup?.guid : null),
    );
    setState(() {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize typography, color palette, and spacing
    typography = CometChatThemeHelper.getTypography(context);
    colorPalette = CometChatThemeHelper.getColorPalette(context);
    spacing = CometChatThemeHelper.getSpacing(context);
  }

  @override
  Widget build(BuildContext context) {
    return (cometChatCallLogHistoryController == null)
        ? const SizedBox()
        : GetBuilder(
            init: cometChatCallLogHistoryController,
            builder: (CometChatCallLogHistoryController value) {
              if (value.hasError == true) {
                return _showErrorView(context, value);
              } else if (value.isLoading == true && value.list.isEmpty) {
                return _getLoadingIndicator(context);
              } else if (value.list.isEmpty) {
                return _emptyView(context);
              } else {
                return ListView.builder(
                  itemCount: value.hasMoreItems
                      ? value.list.length + 1
                      : value.list.length,
                  itemBuilder: (context, index) {
                    if (index >= value.list.length) {
                      WidgetsBinding.instance.addPostFrameCallback(
                            (_) => value.loadMoreElements(),
                      );
                      return _getLoadingIndicator(
                        context,
                      );
                    }
                    final log = value.list[index];
                    return Container(
                      decoration: BoxDecoration(
                        color: colorPalette.background1,
                      ),
                      child: ListTile(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CometChatCallLogDetails(
                                callLog: log,
                              ),
                            ),
                          );
                        },
                        enableFeedback: false,
                        horizontalTitleGap: 0,
                        minVerticalPadding: 0,
                        minLeadingWidth: 0,
                        minTileHeight: 0,
                        contentPadding: EdgeInsets.only(
                          top: spacing.padding3 ?? 12,
                          bottom: spacing.padding3 ?? 12,
                          left: spacing.padding4 ?? 16,
                          right: spacing.padding6 ?? 24,
                        ),
                        leading: Padding(
                          padding: EdgeInsets.only(
                            right: spacing.padding3 ?? 12,
                          ),
                          child: CallUtils.getCallIcon(
                            context,
                            log,
                            CometChatUIKit.loggedInUser,
                            colorPalette,
                            typography,
                            spacing,
                            const CometChatCallLogsStyle(),
                            incomingCallIcon: null,
                            outgoingCallIcon: null,
                            missedCallIcon: null,
                          ),
                        ),
                        title: Text(
                          value.getCallType(
                            context,
                            log,
                            CometChatUIKit.loggedInUser,
                          ),
                          style: TextStyle(
                            color: colorPalette.textPrimary,
                            fontSize: typography.heading4?.medium?.fontSize,
                            fontWeight: typography.heading4?.medium?.fontWeight,
                            fontFamily: typography.heading4?.medium?.fontFamily,
                          ),
                        ),
                        subtitle: _getSubTitleView(value, log, context),
                        trailing: _getTailView(context, value, log),
                      ),
                    );
                  },
                );
              }
            },
          );
  }

  // tail widget
  Widget _getTailView(BuildContext context,
      CometChatCallLogHistoryController value, CallLog callLog) {
    return Text(
      CallLogDetailUtils.convertMinutesToHMS(callLog.totalDurationInMinutes),
      style: TextStyle(
        overflow: TextOverflow.ellipsis,
        color: colorPalette.textPrimary,
        fontSize: typography.caption1?.medium?.fontSize,
        fontWeight: typography.caption1?.medium?.fontWeight,
        fontFamily: typography.caption1?.medium?.fontFamily,
      ),
    );
  }

  // Sub title widget
  _getSubTitleView(CometChatCallLogHistoryController value, CallLog callLog,
      BuildContext context) {
    return CometChatDate(
      pattern: DateTimePattern.dayDateFormat,
      customDateString: value.getDate(callLog.initiatedAt),
      padding: EdgeInsets.zero,
      style: CometChatDateStyle(
        backgroundColor: colorPalette.transparent,
        textStyle: TextStyle(
          overflow: TextOverflow.ellipsis,
          color: colorPalette.textSecondary,
          fontSize: typography.body?.regular?.fontSize,
          fontWeight: typography.body?.regular?.fontWeight,
          fontFamily: typography.body?.regular?.fontFamily,
        ),
        border: Border.all(
          width: 0,
          color: colorPalette.transparent ?? Colors.transparent,
        ),
        borderRadius: BorderRadius.circular(0),
      ),
    );
  }

  // Loading View
  Widget _getLoadingIndicator(BuildContext context) {
    return CometChatShimmerEffect(
      colorPalette: colorPalette,
      child: ListView.builder(
        itemCount: 30,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: spacing.padding4 ?? 0,
              vertical: spacing.padding3 ?? 0,
            ),
            child: Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    right: spacing.padding3 ?? 0,
                  ),
                  child: const CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.grey,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title shimmer bar
                    Container(
                      height: 22.0,
                      width: MediaQuery.of(context).size.width * 0.4,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(
                          spacing.radius2 ?? 0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    // Subtitle shimmer bar
                    Container(
                      height: 12.0,
                      width: MediaQuery.of(context).size.width * 0.2,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(
                          spacing.radius2 ?? 0,
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Padding(
                  padding: EdgeInsets.only(
                    right: spacing.padding3 ?? 0,
                  ),
                  child: Container(
                    height: 32,
                    width: 32,
                    decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(
                          spacing.radius2 ?? 8,
                        )),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Empty Widget
  Widget _emptyView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.call,
            color: colorPalette.neutral300,
            size: 100,
          ),
          Padding(
            padding: EdgeInsets.only(
              top: spacing.padding5 ?? 20,
              bottom: spacing.padding ?? 2,
            ),
            child: Text(
              "No Call History Yet",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colorPalette.textPrimary,
                fontSize: typography.heading3?.bold?.fontSize,
                fontWeight: typography.heading3?.bold?.fontWeight,
                fontFamily: typography.heading3?.bold?.fontFamily,
              ),
            ),
          ),
          Text(
            "Make or receive calls to see your call history listed here.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colorPalette.textSecondary,
              fontSize: typography.heading3?.regular?.fontSize,
              fontWeight: typography.heading3?.regular?.fontWeight,
              fontFamily: typography.heading3?.regular?.fontFamily,
            ),
          ),
        ],
      ),
    );
  }

  Widget _showErrorView(
    BuildContext context,
    CometChatCallLogHistoryController controller,
  ) {
    return UIStateUtils.getDefaultErrorStateView(
      context,
      colorPalette,
      typography,
      spacing,
      () {
        controller.resetCallLogHistory();
      },
    );
  }
}
