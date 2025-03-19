import 'package:cometchat_uikit_shared/cometchat_uikit_shared.dart';
import 'package:flutter/material.dart';

enum TimeFormat { twelveHour, twentyFourHour }

class CometChatTimeSlotSelector extends StatefulWidget {
  const CometChatTimeSlotSelector(
      {super.key,
      this.from,
      this.to,
      required this.duration,
      this.onSelection,
      this.buffer,
      this.style,
      this.blockedTime,
      this.timeFormat = TimeFormat.twelveHour,
      this.availableSlots,
      required this.selectedDay,
      this.nextDayBlockedTime,
      this.nextDayAvailableSlots});

  ///[from] is a string which sets the start time for the time slot selector
  final DateTime? from;

  ///[to] is a string which sets the end time for the time slot selector
  final DateTime? to;

  ///[duration] is a Duration which sets the duration of the time slot selector
  final Duration duration;

  ///[onSelection] is a callback which gets called when a time slot is selected
  final Function(DateTime selectedTime)? onSelection;

  ///[buffer] is a Duration which sets the buffer time for the time slot selector
  final Duration? buffer;

  ///[style] is a object of [TimeSlotSelectorStyle] which is used to set the style for the time slot selector
  final TimeSlotSelectorStyle? style;

  ///[blockedTime] is a list of [TimeRange] which is used to block the time slots
  final List<DateTimeRange>? blockedTime;

  ///[availableSlots] is a list of [TimeRange] which is used to set the available time slots
  final List<DateTimeRange>? availableSlots;

  ///[timeFormat] is a enum of [TimeFormat] which is used to set the time format for the time slot selector
  final TimeFormat timeFormat;

  ///[selectedDay] is a DateTime which is used to set the selected day for the time slot selector`
  final DateTime selectedDay;

  ///[nextDayBlockedTime] is a list of [TimeRange] which is used to block the time slots
  final List<DateTimeRange>? nextDayBlockedTime;

  ///[nextDayAvailableSlots] is a list of [TimeRange] which is used to set the available time slots
  final List<DateTimeRange>? nextDayAvailableSlots;

  @override
  State<CometChatTimeSlotSelector> createState() =>
      _CometChatTimeSlotSelectorState();
}

class _CometChatTimeSlotSelectorState extends State<CometChatTimeSlotSelector> {
  List<DateTime> timeList = [];

  late DateTime selectedTime;


  @override
  void initState() {
    selectedTime = widget.selectedDay;
    if (widget.availableSlots != null && widget.availableSlots!.isNotEmpty) {
      timeList = SchedulerUtils.generateTimeStamps(
          widget.selectedDay,
          widget.availableSlots!,
          widget.blockedTime ?? [],
          widget.duration.inMinutes,
          widget.buffer ?? Duration.zero,
          widget.timeFormat,
          widget.nextDayAvailableSlots ?? [],
          widget.nextDayBlockedTime ?? []);
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return timeList.isEmpty
        ? Text(Translations.of(context).timeSlotUnavailable)
        : SizedBox(
            child: getTimeSegment(
              itemCount:
                  getTimeSlots().length, // Number of items you want to generate
              crossAxisCount: 3,
              slots: getTimeSlots(), // Number of columns
            ),
          );
  }

  List<Widget> getTimeSlots() {
    return timeList.map((time) {
      return GestureDetector(
        onTap: () {
          if (widget.onSelection != null) {
            widget.onSelection!(time);
          }
          setState(() {
            selectedTime = time;
          });
        },
        child: Container(
          height: widget.style?.height ?? 32,
          width: widget.style?.width ?? 85,
          key: ValueKey(time),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selectedTime == time
                ? widget.style?.selectedSlotBackgroundColor
                : widget.style?.slotBackgroundColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(SchedulerUtils.getFormattedTime(time, widget.timeFormat),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w400,
              ).merge(selectedTime == time
                  ? widget.style?.selectedSlotTextStyle
                  : widget.style?.slotTextStyle)),
        ),
      );
    }).toList();
  }

  Widget getTimeSegment({
    required int itemCount,
    required int crossAxisCount,
    required List<Widget> slots,
  }) {
    return Wrap(
      direction: Axis.vertical,
      spacing: 9,
      children: List.generate(
        (itemCount / crossAxisCount).ceil(), // Number of rows
        (colIndex) {
          return Wrap(
            spacing: 9,
            children: slots.sublist(
              colIndex * crossAxisCount,
              (colIndex + 1) * crossAxisCount < itemCount
                  ? (colIndex + 1) * crossAxisCount
                  : itemCount,
            ),
          );
        },
      ),
    );
  }
}
