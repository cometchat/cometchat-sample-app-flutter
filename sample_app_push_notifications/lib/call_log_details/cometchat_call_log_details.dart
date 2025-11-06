import 'package:cometchat_calls_uikit/cometchat_calls_uikit.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';
import 'package:flutter/material.dart';
import 'package:sample_app_push_notifications/call_log_details/call_log_history/cometchat_call_log_history.dart';
import 'package:sample_app_push_notifications/call_log_details/call_log_participants/cometchat_call_log_participants.dart';

import 'call_log_detail_utils.dart';
import 'call_log_recordings/cometchat_call_log_recordings.dart';
import 'cometchat_call_log_details_controller.dart';

class CometChatCallLogDetails extends StatefulWidget {
  const CometChatCallLogDetails({required this.callLog, super.key});

  final CallLog callLog;

  @override
  State<CometChatCallLogDetails> createState() => _CometChatCallLogDetailsState();
}

class _CometChatCallLogDetailsState extends State<CometChatCallLogDetails> {
  late CometChatColorPalette colorPalette;
  late CometChatTypography typography;
  late CometChatSpacing spacing;

  @override
  void initState() {
    initializeUser(widget.callLog);
    super.initState();
  }

  User? userObj;


  void initializeUser(CallLog callLog) async {
    await CometChat.getUser(
      CallLogsUtils.returnReceiverId(CometChatUIKit.loggedInUser, callLog),
      onSuccess: (user) {
        userObj = user;
        setState(() {});
      },
      onError: (CometChatException e) {},
    );
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
    return CometChatListBase(
      title: 'Call Detail',
      hideSearch: true,
      showBackButton: true,
      style: ListBaseStyle(
        background: colorPalette.background1,
        titleStyle: TextStyle(
          color: colorPalette.textPrimary,
          fontSize: typography.heading1?.bold?.fontSize,
          fontWeight: typography.heading1?.bold?.fontWeight,
          fontFamily: typography.heading1?.bold?.fontFamily,
        ),
        backIconTint: colorPalette.iconPrimary,
      ),
      container: Column(
        children: [
          Divider(
            color: colorPalette.borderLight,
            height: 1,
          ),
          Padding(
            padding: EdgeInsets.only(
              right: spacing.padding4 ?? 16,
              top: spacing.padding5 ?? 20,
              bottom: spacing.padding5 ?? 20,
            ),
            child: (userObj == null) ? CometChatShimmerEffect(
              colorPalette: colorPalette,
              child: Padding(
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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title shimmer bar
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                height: 19.0,
                                width: MediaQuery.of(context).size.width * 0.4,
                                decoration: BoxDecoration(
                                  color: Colors.grey,
                                  borderRadius: BorderRadius.circular(
                                    spacing.radius2 ?? 0,
                                  ),
                                ),
                              ),
                              Container(
                                height: 19.0,
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
                          const SizedBox(height: 8.0),
                          // Subtitle shimmer bar
                          Container(
                            height: 16.0,
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(
                                spacing.radius2 ?? 0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ) :
            CometChatMessageHeader(
              user: userObj,
              showBackButton: false,
              avatarHeight: 48,
              avatarWidth: 48,
              padding: EdgeInsets.zero,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: colorPalette.background2,
              border: Border.all(
                color: colorPalette.borderLight ?? Colors.transparent,
                width: 1,
              ),
            ),
            child: ListTile(
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
                  widget.callLog,
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
                CometChatCallLogDetailsController.getCallType(
                  context,
                  widget.callLog,
                  CometChatUIKit.loggedInUser,
                ),
                style: TextStyle(
                  color: colorPalette.textPrimary,
                  fontSize: typography.heading4?.medium?.fontSize,
                  fontWeight: typography.heading4?.medium?.fontWeight,
                  fontFamily: typography.heading4?.medium?.fontFamily,
                ),
              ),
              subtitle: CometChatDate(
                pattern: DateTimePattern.dayDateFormat,
                customDateString: CometChatCallLogDetailsController.getDate(
                    widget.callLog.initiatedAt),
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
              ),
              trailing: Text(
                CallLogDetailUtils.convertMinutesToHMS(
                    widget.callLog.totalDurationInMinutes),
                style: TextStyle(
                  overflow: TextOverflow.ellipsis,
                  color: colorPalette.textPrimary,
                  fontSize: typography.caption1?.medium?.fontSize,
                  fontWeight: typography.caption1?.medium?.fontWeight,
                  fontFamily: typography.caption1?.medium?.fontFamily,
                ),
              ),
            ),
          ),
          Expanded(
            child: DefaultTabController(
              length: 3, // Number of tabs
              child: Scaffold(
                backgroundColor: colorPalette.background1,
                appBar: AppBar(
                  backgroundColor: colorPalette.background1,
                  toolbarHeight: 0,
                  bottom: TabBar(
                    indicatorPadding: EdgeInsets.zero,
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelPadding: EdgeInsets.symmetric(
                      horizontal: spacing.padding2 ?? 8,
                    ),
                    labelStyle: TextStyle(
                      color: colorPalette.textHighlight,
                      fontSize: typography.heading4?.medium?.fontSize,
                      fontWeight: typography.heading4?.medium?.fontWeight,
                      fontFamily: typography.heading4?.medium?.fontFamily,
                    ),
                    unselectedLabelStyle: TextStyle(
                      color: colorPalette.textSecondary,
                      fontSize: typography.heading4?.medium?.fontSize,
                      fontWeight: typography.heading4?.medium?.fontWeight,
                      fontFamily: typography.heading4?.medium?.fontFamily,
                    ),
                    tabs:
                    CometChatCallLogDetailsController.tabs("Participants"),
                  ),
                ),
                body: TabBarView(
                  children: [
                    CometChatCallLogParticipants(callLog: widget.callLog),
                    CometChatCallLogRecordings(callLog: widget.callLog),
                    CometChatCallLogHistory(
                      callUser: CometChatCallLogDetailsController.getCallUser(
                        widget.callLog,
                      ),
                      callGroup: CometChatCallLogDetailsController.getCallGroup(
                        widget.callLog,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}