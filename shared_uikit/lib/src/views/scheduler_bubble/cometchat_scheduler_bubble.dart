import 'package:cometchat_uikit_shared/cometchat_uikit_shared.dart';
import 'package:cometchat_uikit_shared/src/utils/action_element_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

///[CometChatSchedulerBubble] is a widget which is used to display a meeting bubble.
///Use this widget along with [SchedulerBubbleStyle] to customize the appearance of [CometChatSchedulerBubble].
///
/// ```dart
/// CometChatSchedulerBubble(
///  schedulerMessage: schedulerMessage,
///  onScheduleClick: (selectedDateTime, schedulerMessage) {
///  //Action on schedule button click goes here
///  },
///  style: SchedulerBubbleStyle(
///  borderRadius: 8,
///  ),
///  );
///  ```
class CometChatSchedulerBubble extends StatefulWidget {
  const CometChatSchedulerBubble(
      {super.key,
      required this.schedulerMessage,
      this.schedulerBubbleStyle,
      this.onScheduleClick,
      this.theme,
      this.timeSlotSelectorStyle,
      this.quickViewStyle});

  ///[schedulerMessage] is an object of [SchedulerMessage] which is used to create a scheduler bubble.
  final SchedulerMessage schedulerMessage;

  ///[schedulerBubbleStyle] is an object of [SchedulerBubbleStyle] which is used to customize the appearance of [CometChatSchedulerBubble]
  final SchedulerBubbleStyle? schedulerBubbleStyle;

  ///[onScheduleClick] is a callback which provides [DateTime] and [SchedulerMessage] when user clicks on schedule button.
  final Function(DateTime selectedDateTime, SchedulerMessage object)?
      onScheduleClick;

  ///[theme] is an object of [CometChatTheme] which is used to set default styling to the scheduler bubble.
  final CometChatTheme? theme;

  ///[timeSlotSelectorStyle] is an object of [TimeSlotSelectorStyle] which is used to customize the appearance of [CometChatTimeSlotSelector]
  final TimeSlotSelectorStyle? timeSlotSelectorStyle;

  ///[quickViewStyle] property represents the currently logged-in user.
  final QuickViewStyle? quickViewStyle;

  @override
  State<CometChatSchedulerBubble> createState() =>
      _CometChatSchedulerBubbleState();
}

class _CometChatSchedulerBubbleState extends State<CometChatSchedulerBubble> {
  DateTime? selectedDateTime;
  SchedulerBubbleStage currentStage = SchedulerBubbleStage.loading;
  late CometChatTheme theme;

  DateTime? from;
  DateTime? to;
  late Map<String, Map<String, dynamic>> blockedDates = {};
  String timeZone = "";
  Map<String, bool?> interactionMap = {};
  late Duration timeZoneBuffer;
  List<DateTimeRange> todaysAvailableSlots = [];
  List<DateTimeRange> nextDaysAvailableSlots = [];
  Duration meetingDuration = const Duration(minutes: 60);
  String timeZoneIdentifier = "";

  // User? loggedInUser;
  late DateTime calendarStartingDay;

  @override
  void initState() {
    initializeProps();

    super.initState();
  }

  void initializeProps() async {
    theme = widget.theme ?? cometChatTheme;

    meetingDuration = Duration(minutes: widget.schedulerMessage.duration ?? 60);
    DateTime today = DateTime.now();
    timeZoneIdentifier = CometChatUIKit.localTimeZoneIdentifier;

    timeZone = CometChatUIKit.localTimeZoneName;

    if (widget.schedulerMessage.dateRangeStart != null &&
        widget.schedulerMessage.dateRangeStart!.isNotEmpty) {
      from = DateTime.parse(widget.schedulerMessage.dateRangeStart!);
      if (widget.schedulerMessage.timezoneCode != null &&
          widget.schedulerMessage.timezoneCode != timeZoneIdentifier) {
        from = SchedulerUtils.getConvertedTime(
            SchedulerUtils.getConvertedTime(
                    from!, widget.schedulerMessage.timezoneCode!)
                .toLocal(),
            timeZoneIdentifier);
      } else {
        from = from!.toLocal();
      }
    } else {
      from = DateTime.now();
    }
    if (widget.schedulerMessage.dateRangeEnd != null &&
        widget.schedulerMessage.dateRangeEnd!.isNotEmpty) {
      to = DateTime.parse(widget.schedulerMessage.dateRangeEnd!);
      if (widget.schedulerMessage.timezoneCode != null &&
          widget.schedulerMessage.timezoneCode != timeZoneIdentifier) {
        to = SchedulerUtils.getConvertedTime(
            SchedulerUtils.getConvertedTime(
                    to!, widget.schedulerMessage.timezoneCode!)
                .toLocal(),
            timeZoneIdentifier);
      } else {
        to = to!.toLocal();
      }
    } else {
      to = DateTime.now().add(const Duration(hours: 23, minutes: 59));
    }

    if (to != null && from != null && to!.isAtSameMomentAs(from!)) {
      to = to!.add(const Duration(hours: 23, minutes: 59));
    }

    if (from!.month > today.month ||
        from!.year > today.year ||
        from!.day > today.day) {
      calendarStartingDay = from!;
    } else {
      calendarStartingDay = today;
    }
    _checkErrors();
    _populateMap();
    _checkInteractionGoals();

    if (widget.schedulerMessage.icsFileUrl != null &&
        widget.schedulerMessage.icsFileUrl!.isNotEmpty) {
      blockedDates = await SchedulerUtils.fetchICSFile(
          widget.schedulerMessage.icsFileUrl!, timeZoneIdentifier, (e) {
        if (kDebugMode) {
          print("Error in fetching ics file $e");
        }
      });
    } else {
      blockedDates = {};
    }
    currentStage = SchedulerBubbleStage.initial;
    setState(() {});
  }

  void _checkErrors() {
    if (from == null || to == null) {
      // meetingDateRangeStart and meetingDateRangeEnd cannot be null at the same time
      currentStage = SchedulerBubbleStage.error;
      return;
    }
    bool errorExists = false;
    if (widget.schedulerMessage.dateRangeStart != null &&
        widget.schedulerMessage.dateRangeEnd != null) {
      if (from == null && to == null && from!.isAfter(to!)) {
        // meetingDateRangeStart cannot be greater than meetingDateRangeEnd
        errorExists = true;
      }
    }

    if (to != null && to!.isBefore(DateTime.now())) {
      // meetingDateRangeEnd cannot be less than current time
      errorExists = true;
    }
    if (errorExists) {
      currentStage = SchedulerBubbleStage.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        // padding:currentStage == SchedulerBubbleStage.goalCompleted ?  const EdgeInsets.only(top:8,bottom: 8) : null,
        decoration: BoxDecoration(
          color: widget.schedulerBubbleStyle?.background ??
              theme.palette.getSecondary(),
          borderRadius: BorderRadius.circular(12),
          gradient: widget.schedulerBubbleStyle?.gradient,
          border: widget.schedulerBubbleStyle?.border,
        ),
        child: Wrap(
            direction: Axis.vertical,
            // crossAxisAlignment: CrossAxisAlignment.start,
            children: [getHeaderContent(), getMainContent()]));
  }

  List<Widget> getSuggestedTimeSlots() {
    bool buttonIsDisabled =
        SchedulerUtils.isScheduleButtonDisabled(widget.schedulerMessage);
    Color defaultPrimaryColor = buttonIsDisabled
        ? theme.palette.getAccent600()
        : theme.palette.getPrimary();
    List<DateTime> timeSlots = SchedulerUtils.generateCumulativeTimeSlots(
        calendarStartingDay,
        to ?? calendarStartingDay.add(const Duration(days: 2)),
        3,
        widget.schedulerMessage.availability,
        blockedDates,
        meetingDuration.inMinutes,
        Duration(minutes: widget.schedulerMessage.bufferTime ?? 0),
        widget.schedulerMessage.timezoneCode ?? timeZoneIdentifier,
        timeZoneIdentifier);

    if (timeSlots.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          currentStage = SchedulerBubbleStage.error;
        });
      });
      return [];
    }

    List<Widget> suggestedTimeSlots = timeSlots
        .map((time) => GestureDetector(
              onTap: () {
                if (!buttonIsDisabled) {
                  setState(() {
                    currentStage = SchedulerBubbleStage.schedule;
                    selectedDateTime = time;
                    todaysAvailableSlots = SchedulerUtils.getAvailableSlots(
                        selectedDateTime!,
                        widget.schedulerMessage.timezoneCode ??
                            timeZoneIdentifier,
                        timeZoneIdentifier,
                        widget.schedulerMessage.availability);
                    nextDaysAvailableSlots = SchedulerUtils.getAvailableSlots(
                        selectedDateTime!.add(const Duration(days: 1)),
                        widget.schedulerMessage.timezoneCode ??
                            timeZoneIdentifier,
                        timeZoneIdentifier,
                        widget.schedulerMessage.availability);
                  });
                }
              },
              child: Container(
                  height: 32,
                  width: 240,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color:
                        widget.schedulerBubbleStyle?.suggestedTimeBackground ??
                            theme.palette.getBackground(),
                    border: widget.schedulerBubbleStyle?.suggestedTimeBorder ??
                        Border.all(color: defaultPrimaryColor, width: .69),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "${DateFormat('E, MMM d').format(time)} at ${DateFormat.jm().format(time)}",
                    style: TextStyle(
                      color: defaultPrimaryColor,
                      fontSize: theme.typography.text2.fontSize,
                      fontWeight: theme.typography.text2.fontWeight,
                    ).merge(
                        widget.schedulerBubbleStyle?.suggestedTimeTextStyle),
                  )),
            ))
        .toList();
    return suggestedTimeSlots;
  }

  Widget getHeaderContent() {
    double? height;
    double? width;
    Widget? leading;
    Widget? title;
    Widget? subtitle;
    MainAxisAlignment? columnMainAxisAlignment;
    CrossAxisAlignment? columnCrossAxisAlignment;
    MainAxisAlignment? rowMainAxisAlignment;
    // CrossAxisAlignment? rowCrossAxisAlignment;
    MainAxisSize? rowMainAxisSize;

    switch (currentStage) {
      case SchedulerBubbleStage.error:
        height = 106;
        width = 272;
        title = Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CometChatAvatar(
              image: widget.schedulerMessage.avatarUrl,
              name: widget.schedulerMessage.sender?.name ?? '',
              style: widget.schedulerBubbleStyle?.avatarStyle ??
                  const CometChatAvatarStyle(),
            ),
          ],
        );
        subtitle = Text(
            SchedulerUtils.getSchedulerTitle(widget.schedulerMessage, context),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: theme.palette.getAccent(),
              fontSize: theme.typography.name.fontSize,
              fontWeight: theme.typography.name.fontWeight,
            ).merge(widget.schedulerBubbleStyle?.titleTextStyle));
        columnMainAxisAlignment = MainAxisAlignment.spaceEvenly;
        columnCrossAxisAlignment = CrossAxisAlignment.center;
        rowMainAxisAlignment = MainAxisAlignment.center;
        rowMainAxisSize = MainAxisSize.max;
        break;
      case SchedulerBubbleStage.loading:
      case SchedulerBubbleStage.initial:
        height = 106;
        width = 272;
        title = Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CometChatAvatar(
              image: widget.schedulerMessage.avatarUrl,
              name: widget.schedulerMessage.sender?.name ?? '',
              style: widget.schedulerBubbleStyle?.avatarStyle ??
                  const CometChatAvatarStyle(),
            ),
          ],
        );
        subtitle = Flexible(
            child: Container(
                padding: const EdgeInsets.fromLTRB(5, 10, 5, 0),
                child: Text(
                    SchedulerUtils.getSchedulerTitle(
                        widget.schedulerMessage, context),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: widget.schedulerBubbleStyle?.titleTextStyle ??
                        TextStyle(
                          color: theme.palette.getAccent(),
                          fontSize: theme.typography.name.fontSize,
                          fontWeight: theme.typography.name.fontWeight,
                        ))));
        // columnMainAxisAlignment = MainAxisAlignment.spaceEvenly;
        columnMainAxisAlignment = MainAxisAlignment.spaceEvenly;
        columnCrossAxisAlignment = CrossAxisAlignment.center;
        rowMainAxisAlignment = MainAxisAlignment.center;
        rowMainAxisSize = MainAxisSize.max;
        break;
      case SchedulerBubbleStage.datePicker:
      case SchedulerBubbleStage.timePicker:
        height = 68.5;
        width = 308;

        columnMainAxisAlignment = MainAxisAlignment.center;
        leading = getAvatarWithNavigation();
        title = Flexible(
          child: Container(
            padding: const EdgeInsets.only(right: 36.0),
            child: Text(
                SchedulerUtils.getSchedulerTitle(
                    widget.schedulerMessage, context),
                overflow: TextOverflow.ellipsis,
                style: widget.schedulerBubbleStyle?.titleTextStyle ??
                    TextStyle(
                      color: theme.palette.getAccent(),
                      fontSize: theme.typography.name.fontSize,
                      fontWeight: theme.typography.name.fontWeight,
                    )),
          ),
        );

        subtitle = Padding(
          padding: const EdgeInsets.only(top: 6.0),
          child: getTextWithIcon(
              "${meetingDuration.inMinutes} min",
              Icons.watch_later_outlined,
              theme.typography.title2.fontSize,
              theme.palette.getAccent500()),
        );

        break;
      case SchedulerBubbleStage.schedule:
        height = 68.5;
        width = 308;
        columnMainAxisAlignment = MainAxisAlignment.center;
        leading = getAvatarWithNavigation();
        title = Flexible(
            child: Container(
                padding: const EdgeInsets.only(right: 36.0),
                child: Text(
                    SchedulerUtils.getSchedulerTitle(
                        widget.schedulerMessage, context),
                    overflow: TextOverflow.ellipsis,
                    style: widget.schedulerBubbleStyle?.titleTextStyle ??
                        TextStyle(
                          color: theme.palette.getAccent(),
                          fontSize: theme.typography.name.fontSize,
                          fontWeight: theme.typography.name.fontWeight,
                        ))));

        subtitle = Padding(
          padding: const EdgeInsets.only(top: 6),
          child: getTextWithIcon(
              "${meetingDuration.inMinutes} min",
              Icons.watch_later_outlined,
              theme.typography.title2.fontSize,
              theme.palette.getAccent500()),
        );

        break;
      case SchedulerBubbleStage.goalCompleted:
        return const SizedBox();
      default:
        height = 39;
        width = 272;
    }
    return Container(
        height: height,
        width: width,
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisSize: rowMainAxisSize ?? MainAxisSize.min,
          mainAxisAlignment: rowMainAxisAlignment ?? MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (leading != null) leading,
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment:
                    columnMainAxisAlignment ?? MainAxisAlignment.center,
                crossAxisAlignment:
                    columnCrossAxisAlignment ?? CrossAxisAlignment.start,
                children: [
                  if (title != null) title,
                  if (subtitle != null) subtitle
                ],
              ),
            )
          ],
        ));
  }

  Widget getAvatarWithNavigation() {
    return SizedBox(
      width: 74,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(flex: 1, child: getBackButton()),
          Flexible(
            flex: 3,
            child: CometChatAvatar(
              image: widget.schedulerMessage.avatarUrl,
              name: widget.schedulerMessage.sender?.name ?? '',
              style: widget.schedulerBubbleStyle?.avatarStyle ??
                  const CometChatAvatarStyle(),
            ),
          ),
        ],
      ),
    );
  }

  ///[_populateMap] is a method which is used to populate the interaction map.
  _populateMap() {
    if (widget.schedulerMessage.interactions != null) {
      for (var element in widget.schedulerMessage.interactions!) {
        interactionMap[element.elementId] = true;
      }
    }
  }

  Widget getMainContent() {
    List<Widget> content = [];
    double? height;
    double? width;
    MainAxisAlignment? mainAxisAlignment;
    CrossAxisAlignment? crossAxisAlignment;
    BoxBorder? topBorder =
        Border(top: BorderSide(width: 1, color: theme.palette.getAccent200()));
    MainAxisSize mainAxisSize = MainAxisSize.max;
    switch (currentStage) {
      case SchedulerBubbleStage.loading:
        content.add(Image.asset(
          AssetConstants.spinner,
          package: UIConstants.packageName,
          color: widget
                  .schedulerBubbleStyle?.scheduleButtonStyle?.loadingIconTint ??
              theme.palette.getAccent600(),
        ));
        width = 272;
        height = 208;
        mainAxisAlignment = MainAxisAlignment.spaceEvenly;
        break;

      case SchedulerBubbleStage.error:
        content.add(Image.asset(
          AssetConstants.slotsUnavailable,
          package: UIConstants.packageName,
          // color: const Color(0xff3399FF),
          width: 48,
          height: 48,
        ));
        content.add(Text(
          Translations.of(context).meetingCannotBeScheduled,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: theme.typography.text1.fontSize,
            fontWeight: theme.typography.text1.fontWeight,
            fontFamily: theme.typography.text1.fontFamily,
            color: theme.palette.getAccent500(),
          ),
        ));

        width = 272;
        height = 160;
        mainAxisAlignment = MainAxisAlignment.center;
        break;

      case SchedulerBubbleStage.initial:
        Text slotInfo = Text(
          "${meetingDuration.inMinutes}min meeting • $timeZone",
          style: TextStyle(
            color: theme.palette.getAccent600(),
            fontSize: theme.typography.caption2.fontSize,
            fontWeight: theme.typography.subtitle2.fontWeight,
          ).merge(widget.schedulerBubbleStyle?.durationTextStyle),
        );
        Widget suggestedTimeSlots = Wrap(
          direction: Axis.vertical,
          alignment: WrapAlignment.start,
          crossAxisAlignment: WrapCrossAlignment.start,
          spacing: 4,
          children: [
            Wrap(
              direction: Axis.vertical,
              alignment: WrapAlignment.start,
              crossAxisAlignment: WrapCrossAlignment.start,
              spacing: 10,
              children: getSuggestedTimeSlots(),
            ),
            slotInfo
          ],
        );

        content.add(suggestedTimeSlots);
        bool buttonIsDisabled =
            SchedulerUtils.isScheduleButtonDisabled(widget.schedulerMessage);
        Widget nextStep = InkWell(
          child: Text(
            Translations.of(context).moreTimes,
            style: TextStyle(
              color: buttonIsDisabled
                  ? theme.palette.getAccent600()
                  : theme.palette.getPrimary(),
              fontSize: theme.typography.caption2.fontSize,
              fontWeight: theme.typography.name.fontWeight,
            ).merge(widget.schedulerBubbleStyle?.durationTextStyle),
          ),
          onTap: () {
            if (!buttonIsDisabled) {
              setState(() {
                currentStage = SchedulerBubbleStage.datePicker;
              });
            }
          },
        );
        content.add(nextStep);
        width = 272;
        height = 208;
        mainAxisAlignment = MainAxisAlignment.spaceEvenly;
        break;
      case SchedulerBubbleStage.datePicker:
        content.add(Padding(
          padding: const EdgeInsets.only(left: 20, top: 16),
          child: _getMainContentHeaderText(Translations.of(context).selectDay,
              theme.typography.heading.fontSize + 2),
        ));
        DateTime now = DateTime.now();
        content.add(SizedBox(
          height: 330,
          // color: Colors.red,
          child: Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary: widget.schedulerBubbleStyle
                          ?.calendarSelectedDayBackgroundColor ??
                      theme.palette.getPrimary(), // header background color
                  onPrimary:
                      widget.schedulerBubbleStyle?.calendarSelectedDayTint ??
                          theme.palette.accent.dark, // header text color
                ),
                datePickerTheme: DatePickerThemeData(
                  weekdayStyle:
                      widget.schedulerBubbleStyle?.calendarWeekdayTextStyle ??
                          TextStyle(color: theme.palette.getAccent()),
                ),
              ),
              child: CalendarDatePicker(
                initialDate: SchedulerUtils.nearestSelectableDate(
                    from ?? now,
                    from,
                    to,
                    blockedDates,
                    widget.schedulerMessage.availability),
                firstDate: from ?? now,
                lastDate: to ?? now,
                onDateChanged: (date) {
                  selectedDateTime = date;
                  currentStage = SchedulerBubbleStage.timePicker;

                  todaysAvailableSlots = SchedulerUtils.getAvailableSlots(
                      selectedDateTime!,
                      widget.schedulerMessage.timezoneCode ??
                          timeZoneIdentifier,
                      timeZoneIdentifier,
                      widget.schedulerMessage.availability);

                  nextDaysAvailableSlots = SchedulerUtils.getAvailableSlots(
                      selectedDateTime!.add(const Duration(days: 1)),
                      widget.schedulerMessage.timezoneCode ??
                          timeZoneIdentifier,
                      timeZoneIdentifier,
                      widget.schedulerMessage.availability);

                  setState(() {});
                },
                selectableDayPredicate: (date) {
                  return SchedulerUtils.isDateSelectable(date, from, to,
                      blockedDates, widget.schedulerMessage.availability);
                },
              )),
        ));

        if (timeZone.isNotEmpty) {
          content.add(Container(
            width: double.infinity,
            padding: const EdgeInsets.only(right: 16, bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Spacer(),
                getTextWithIcon(timeZone, Icons.public,
                    theme.typography.text2.fontSize, null),
              ],
            ),
          ));
        }

        width = 308;
        // height = 440;
        mainAxisSize = MainAxisSize.min;
        mainAxisAlignment = MainAxisAlignment.spaceEvenly;
        crossAxisAlignment = CrossAxisAlignment.start;
        break;
      case SchedulerBubbleStage.timePicker:
        DateTime now = DateTime.now();
        content.add(Container(
            margin: const EdgeInsets.only(top: 16, left: 16, right: 16),
            padding: const EdgeInsets.only(bottom: 16),
            width: double.infinity,
            decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(
                        width: 1, color: theme.palette.getAccent100()))),
            child: getTextWithIcon(
                DateFormat('d MMMM y, EEEE').format(selectedDateTime ?? now),
                Icons.calendar_month_outlined,
                16,
                null)));
        content.add(Padding(
          padding: const EdgeInsets.only(top: 16, left: 16),
          child: _getMainContentHeaderText(
              Translations.of(context).selectTime, null),
        ));

        String day = DateFormat('yMd').format(selectedDateTime!);
        List<DateTimeRange>? blockedTime;

        if (blockedDates.containsKey(day)) {
          blockedTime = blockedDates[day]!["timings"].cast<DateTimeRange>();
        }
        // String utcZone = widget.schedulerMessage.timezoneCode ?? "UTC";

        DateTime nextDay = selectedDateTime!.add(const Duration(days: 1));

        List<DateTimeRange>? nextDayBlockedTime;
        String day2 = DateFormat('yMd').format(nextDay);
        if (blockedDates.containsKey(day2)) {
          nextDayBlockedTime =
              blockedDates[day2]!["timings"].cast<DateTimeRange>();
        }

        TimeFormat timeFormat = TimeFormat.twelveHour;
        content.add(Padding(
          padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
          child: CometChatTimeSlotSelector(
            selectedDay: selectedDateTime ?? DateTime.now(),
            blockedTime: blockedTime,
            availableSlots: todaysAvailableSlots,
            duration: meetingDuration,
            buffer: Duration(minutes: widget.schedulerMessage.bufferTime ?? 0),
            timeFormat: timeFormat,
            nextDayAvailableSlots: nextDaysAvailableSlots,
            nextDayBlockedTime: nextDayBlockedTime,
            onSelection: (selectedTime) {
              selectedDateTime = selectedTime;
              setState(() {
                currentStage = SchedulerBubbleStage.schedule;
              });
            },
            theme: theme,
            style: widget.timeSlotSelectorStyle,
          ),
        ));

        if (timeZone.isNotEmpty) {
          content.add(Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 16, right: 16, bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Spacer(),
                getTextWithIcon(timeZone, Icons.public, 12.5, null),
              ],
            ),
          ));
        }

        width = 308;
        // height = 400;
        mainAxisSize = MainAxisSize.min;
        mainAxisAlignment = MainAxisAlignment.start;
        crossAxisAlignment = CrossAxisAlignment.start;

        break;
      case SchedulerBubbleStage.schedule:
        content.add(getMeetingDetails());
        content.add(Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: getScheduleElement(),
        ));
        width = 308;
        // height = 229;
        mainAxisSize = MainAxisSize.min;
        mainAxisAlignment = MainAxisAlignment.spaceEvenly;
        crossAxisAlignment = CrossAxisAlignment.start;

        break;
      case SchedulerBubbleStage.goalCompleted:
        // String receiver = widget.schedulerMessage.receiver is User ? (widget.schedulerMessage.receiver as User).name : (widget.schedulerMessage.receiver as Group).name;
        // String sender = widget.schedulerMessage.sender?.name ?? "";
        // content.add(Container(
        //   padding: const EdgeInsets.only(top: 8.0,left: 16),
        //   width: 210,
        //   child: Text(
        //     "${Translations.of(context).hi} $receiver, ${Translations.of(context).yourAppointmentIsScheduledWith} $sender. ${Translations.of(context).hereAreYourDetails} - ",
        //     style: TextStyle(
        //       color: theme.palette.getAccent(),
        //       fontSize: 17,
        //       fontWeight: FontWeight.w400,
        //     ).merge(widget.style?.summaryTextStyle),
        //   ),
        // ));
        // content.add(getMeetingDetails());
        // topBorder =null;
        // width = 277;
        // height = 268;

        // mainAxisAlignment = MainAxisAlignment.spaceEvenly;
        // crossAxisAlignment = CrossAxisAlignment.start;
        content.add(Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: theme.palette.getSecondary(),
              borderRadius: BorderRadius.circular(8)),
          constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 65 / 100),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CometChatQuickView(
                        theme: widget.theme,
                        title: widget.schedulerMessage.sender?.name ?? "",
                        subtitle: widget.schedulerMessage.title,
                        quickViewStyle: widget.quickViewStyle ??
                            (QuickViewStyle(
                              background: widget.quickViewStyle?.background ??
                                  theme.palette.getBackground(),
                              titleStyle: widget.quickViewStyle?.titleStyle ??
                                  TextStyle(
                                    fontSize: theme.typography.text2.fontSize,
                                    fontWeight:
                                        theme.typography.text2.fontWeight,
                                    fontFamily:
                                        theme.typography.text2.fontFamily,
                                    color: theme.palette.getPrimary(),
                                  ),
                              subtitleStyle: widget
                                      .quickViewStyle?.subtitleStyle ??
                                  TextStyle(
                                    fontSize:
                                        theme.typography.subtitle2.fontSize,
                                    fontWeight:
                                        theme.typography.subtitle2.fontWeight,
                                    fontFamily:
                                        theme.typography.subtitle2.fontFamily,
                                    color: theme.palette.getAccent(),
                                  ),
                            ))),
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        widget.schedulerMessage.goalCompletionText ??
                            Translations.of(context).goalAchievedSuccessfully,
                        style: TextStyle(
                                color: theme.palette.getAccent(),
                                fontWeight: theme.typography.body.fontWeight,
                                fontSize: theme.typography.body.fontSize,
                                fontFamily: theme.typography.body.fontFamily)
                            .merge(widget
                                .schedulerBubbleStyle?.goalCompletionTextStyle),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
        // height= 120;
        topBorder = null;
        mainAxisSize = MainAxisSize.min;
        break;
      default:
        content.add(Image.asset(
          AssetConstants.spinner,
          package: UIConstants.packageName,
        ));
    }
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(border: topBorder),
      child: Column(
        mainAxisAlignment: mainAxisAlignment ?? MainAxisAlignment.spaceEvenly,
        mainAxisSize: mainAxisSize,
        crossAxisAlignment: crossAxisAlignment ?? CrossAxisAlignment.center,
        children: content,
      ),
    );
  }

  ScheduleStatus _scheduleStatus = ScheduleStatus.unscheduled;
  String fromTimeSlot = "";
  Widget getScheduleElement() {
    String buttonText = "";
    Widget message = const SizedBox();
    Widget? loading;
    bool buttonIsDisabled =
        SchedulerUtils.isScheduleButtonDisabled(widget.schedulerMessage);
    Function() defaultSchedule = () {};
    switch (_scheduleStatus) {
      case ScheduleStatus.unscheduled:
        buttonText = Translations.of(context).schedule;
        defaultSchedule = _checkSlotAvailability;
        break;
      case ScheduleStatus.error:
        buttonText = Translations.of(context).tryAgain;
        message = Padding(
          padding: const EdgeInsets.only(bottom: 6.18),
          child: Text(
              "${Translations.of(context).somethingWentWrongError}. ${Translations.of(context).pleaseTryAgain}.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: theme.palette.getError(),
                fontSize: theme.typography.caption2.fontSize,
                fontWeight: theme.typography.subtitle2.fontWeight,
              )),
        );
        defaultSchedule = _checkSlotAvailability;
        break;
      case ScheduleStatus.slotUnvailable:
        buttonText = Translations.of(context).bookNewSlot;
        message = Padding(
          padding: const EdgeInsets.only(bottom: 6.18),
          child: Text(
              "${Translations.of(context).yourSlotHasBeenBooked}. ${Translations.of(context).pleaseTryNewSlot}.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: theme.palette.getError(),
                fontSize: theme.typography.caption2.fontSize,
                fontWeight: theme.typography.subtitle2.fontWeight,
              )),
        );
        defaultSchedule = _resetScheduling;
        break;
      case ScheduleStatus.loading:
        loading = Image.asset(
          AssetConstants.spinner,
          package: UIConstants.packageName,
          color: widget
                  .schedulerBubbleStyle?.scheduleButtonStyle?.loadingIconTint ??
              theme.palette.backGroundColor.light,
        );

        break;
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: widget.schedulerBubbleStyle?.scheduleButtonStyle?.width ??
                double.infinity,
            height:
                widget.schedulerBubbleStyle?.scheduleButtonStyle?.height ?? 36,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                gradient:
                    widget.schedulerBubbleStyle?.scheduleButtonStyle?.gradient,
                border:
                    widget.schedulerBubbleStyle?.scheduleButtonStyle?.border),
            child: ElevatedButton(
                onPressed: () {
                  if (!buttonIsDisabled) {
                    if (widget.onScheduleClick != null) {
                      widget.onScheduleClick!(
                          selectedDateTime ?? DateTime.now(),
                          widget.schedulerMessage);
                    }
                    setState(() {
                      _scheduleStatus = ScheduleStatus.loading;
                    });
                    defaultSchedule();
                  }
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: buttonIsDisabled
                        ? theme.palette.getAccent300()
                        : widget.schedulerBubbleStyle?.scheduleButtonStyle
                                ?.background ??
                            theme.palette.getPrimary(),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    elevation: 0),
                child: loading ?? Text(buttonText)),
          ),
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.only(top: 6.18),
            child: message,
          )
        ],
      ),
    );
  }

  _checkSlotAvailability() async {
    try {
      if (widget.schedulerMessage.icsFileUrl != null &&
          widget.schedulerMessage.icsFileUrl!.isNotEmpty) {
        blockedDates = await SchedulerUtils.fetchICSFile(
            widget.schedulerMessage.icsFileUrl!, timeZoneIdentifier, (e) {
          setState(() {
            _scheduleStatus = ScheduleStatus.error;
          });
        });
      } else {
        blockedDates = {};
      }

      if (selectedDateTime == null) return;
      String day = DateFormat('yMd').format(selectedDateTime!);

      if (blockedDates.containsKey(day)) {
        List<DateTimeRange> blockedSlots =
            blockedDates[day]!["timings"].cast<DateTimeRange>();

        if (SchedulerUtils.checkBlockedSlotStatus(
            blockedSlots, 0, selectedDateTime!)) {
          setState(() {
            _scheduleStatus = ScheduleStatus.slotUnvailable;
          });
        } else {
          _scheduleMeeting();
        }
      } else {
        _scheduleMeeting();
      }
    } catch (e) {
      setState(() {
        _scheduleStatus = ScheduleStatus.error;
      });
    }
  }

  _scheduleMeeting() async {
    if (selectedDateTime == null) return;
    try {
      bool status = await ActionElementUtils.performAction(
        element: widget.schedulerMessage.scheduleElement!,
        // body: SchedulerUtils.getActionRequestData(widget.schedulerMessage, selectedDateTime!, meetingDuration, timeZoneIdentifier),
        body: InteractiveMessageUtils.getInteractiveRequestData(
            message: widget.schedulerMessage,
            element: widget.schedulerMessage.scheduleElement!,
            interactionTimezoneCode: timeZoneIdentifier,
            interactedBy: CometChatUIKit.loggedInUser?.uid ?? "",
            body: {
              SchedulerConstants.schedulerData: {
                SchedulerConstants.meetStartAt: selectedDateTime.toString(),
                SchedulerConstants.duration: meetingDuration.inMinutes
              }
            }),
        messageId: widget.schedulerMessage.id,
        context: context,
        theme: theme,
      );

      if (status == true) {
        markInteracted(widget.schedulerMessage.scheduleElement!);
      } else {
        setState(() {
          _scheduleStatus = ScheduleStatus.error;
        });
      }
    } catch (e) {
      setState(() {
        _scheduleStatus = ScheduleStatus.error;
      });
      if (kDebugMode) {
        print("Error in scheduling meeting $e");
      }
    }
  }

  markInteracted(BaseInteractiveElement interactiveElement) async {
    InteractiveMessageUtils.markInteracted(
      interactiveElement,
      widget.schedulerMessage,
      interactionMap,
      onSuccess: (bool matched) {
        _checkInteractionGoals();
        setState(() {});
      },
      onError: (excep) {
        if (mounted) {
          setState(() {
            _scheduleStatus = ScheduleStatus.error;
          });
        }
      },
    );
  }

  _checkInteractionGoals() {
    if (widget.schedulerMessage.interactionGoal != null) {
      bool goalAchieved =
          InteractiveMessageUtils.checkInteractionGoalAchievedFromMap(
              widget.schedulerMessage.interactionGoal!, interactionMap);

      if (goalAchieved) {
        currentStage = SchedulerBubbleStage.goalCompleted;
      }
    }
  }

  _resetScheduling() {
    setState(() {
      currentStage = SchedulerBubbleStage.initial;
      selectedDateTime = null;
      _scheduleStatus = ScheduleStatus.unscheduled;
    });
  }

  Widget getMeetingDetails() {
    List<Widget> content = [];

    content.add(Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: getTextWithIcon(
          "${DateFormat.jm().format(selectedDateTime ?? DateTime.now())}, ${DateFormat('EEEE, d MMMM y').format(selectedDateTime ?? DateTime.now())}",
          Icons.calendar_month_outlined,
          16,
          null,
          crossAxisAlignment: CrossAxisAlignment.start),
    ));

    if (timeZone.isNotEmpty) {
      content.add(Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: getTextWithIcon(timeZone, Icons.public, 16, null,
              crossAxisAlignment: CrossAxisAlignment.start)));
    }

    return Padding(
      // height: 74,
      padding: const EdgeInsets.all(16),
      child: Column(
        // direction: Axis.vertical,
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: content,
      ),
    );
  }

  Widget getTextWithIcon(String text, IconData icon, double size, Color? color,
      {CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Icon(
          icon,
          size: size * 1.1618,
          color: color ?? theme.palette.getAccent(),
        ),
        const SizedBox(width: 5), // Adjust spacing
        Flexible(
          child: Text(
            text,
            style: TextStyle(
              color: color ?? theme.palette.getAccent(),
              fontSize: size,
              fontWeight: theme.typography.subtitle2.fontWeight,
            ).merge(widget.schedulerBubbleStyle?.durationTextStyle),
          ),
        ),
      ],
    );
  }

  Widget _getMainContentHeaderText(String header, double? padding) {
    return Padding(
      padding: const EdgeInsets.all(0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            header,
            style: TextStyle(
              color: theme.palette.getAccent(),
              fontSize: theme.typography.title2.fontSize,
              fontWeight: theme.typography.text2.fontWeight,
            ).merge(widget.schedulerBubbleStyle?.durationTextStyle),
          ),
        ],
      ),
    );
  }

  Widget getBackButton() {
    return IconButton(
        onPressed: () {
          setState(() {
            currentStage = SchedulerBubbleStage.values[currentStage.index - 1];
            _scheduleStatus = ScheduleStatus.unscheduled;
          });
        },
        icon: Icon(
          Icons.arrow_back_ios,
          color: theme.palette.getPrimary(),
          size: theme.typography.title2.fontSize,
        ));
  }
}
