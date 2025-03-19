import 'package:flutter/material.dart';
import 'package:cometchat_calls_uikit/cometchat_calls_uikit.dart';
import 'package:intl/intl.dart';

import '../call_log_detail_utils.dart';

class CometChatCallLogParticipants extends StatefulWidget {
  const CometChatCallLogParticipants({
    Key? key,
    required this.callLog,
  }) : super(key: key);

  ///[callLog] callLog object for CallLog participant
  final CallLog callLog;

  @override
  State<CometChatCallLogParticipants> createState() =>
      _CometChatCallLogParticipantsState();
}

class _CometChatCallLogParticipantsState
    extends State<CometChatCallLogParticipants> {
  User? loggedInUser;

  late CometChatColorPalette colorPalette;
  late CometChatTypography typography;
  late CometChatSpacing spacing;

  @override
  void initState() {
    super.initState();
    _initializeLoggedInUser();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize typography, color palette, and spacing
    typography = CometChatThemeHelper.getTypography(context);
    colorPalette = CometChatThemeHelper.getColorPalette(context);
    spacing = CometChatThemeHelper.getSpacing(context);
  }

  _initializeLoggedInUser() async {
    loggedInUser = await CometChat.getLoggedInUser();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return (loggedInUser == null)
        ? const Scaffold()
        : (widget.callLog.participants == null ||
                widget.callLog.participants!.isEmpty)
            ? _emptyView(context)
            : ListView.builder(
                itemCount: widget.callLog.participants!.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  final participant = widget.callLog.participants![index];
                  return _getListItemView(participant, context);
                },
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
              "No Call Participants",
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
            "Make or receive calls to see call participants listed here.",
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

  // list item view
  _getListItemView(
    Participants participant,
    BuildContext context,
  ) {
    return CometChatListItem(
      hideSeparator: true,
      avatarURL: participant.avatar,
      avatarName: participant.name,
      title: participant.name,
      style: ListItemStyle(
        padding: EdgeInsets.symmetric(
          horizontal: spacing.padding4 ?? 16,
          vertical: spacing.padding3 ?? 12,
        ),
        titleStyle: TextStyle(
          color: colorPalette.textPrimary,
          fontSize: typography.heading4?.medium?.fontSize,
          fontWeight: typography.heading4?.medium?.fontWeight,
          fontFamily: typography.heading4?.medium?.fontFamily,
        ),
      ),
      subtitleView: _getSubTitleView(
        participant,
        context,
      ),
      tailView: _getTailView(
        participant,
        context,
      ),
    );
  }

  // sub title view
  _getSubTitleView(Participants participant, BuildContext context) {
    return CometChatDate(
      pattern: DateTimePattern.dayDateFormat,
      customDateString: getDate(widget.callLog.initiatedAt),
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

  // tail view
  _getTailView(Participants participant, BuildContext context) {
    return Text(
      CallLogDetailUtils.convertMinutesToHMS(participant.totalDurationInMinutes),
      style: TextStyle(
        overflow: TextOverflow.ellipsis,
        color: colorPalette.textPrimary,
        fontSize: typography.caption1?.medium?.fontSize,
        fontWeight: typography.caption1?.medium?.fontWeight,
        fontFamily: typography.caption1?.medium?.fontFamily,
      ),
    );
  }

  static String getDate(
    int? epochTimestampInSeconds,
  ) {
    String formattedDate = "";
    if (epochTimestampInSeconds == null) {
      return formattedDate;
    }
    DateTime dateTime =
        DateTime.fromMillisecondsSinceEpoch(epochTimestampInSeconds * 1000);

    return formattedDate = DateFormat('d MMMM, h:mm a').format(dateTime);
  }
}
