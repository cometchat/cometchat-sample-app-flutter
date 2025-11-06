import 'package:cometchat_uikit_shared/cometchat_uikit_shared.dart';
import 'package:flutter/material.dart';

class SchedulerBubbleStyle extends BaseStyles {
  SchedulerBubbleStyle({
    this.avatarStyle,
    this.suggestedTimeTextStyle,
    this.suggestedTimeBackground,
    this.suggestedTimeBorder,
    this.scheduleButtonStyle,
    this.titleTextStyle,
    this.summaryTextStyle,
    this.durationTextStyle,
    this.calendarSelectedDayBackgroundColor,
    this.calendarSelectedDayTint,
    this.calendarWeekdayTextStyle,
    this.goalCompletionTextStyle,
    super.width,
    super.height,
    super.background,
    super.border,
    super.borderRadius,
    super.gradient,
  });

  ///[avatarStyle] is a object of [CometChatAvatarStyle] which is used to set the style for the avatar in the scheduler bubble
  final CometChatAvatarStyle? avatarStyle;

  ///[suggestedTimeTextStyle] is a object of [TextStyle] which is used to set the style for the suggested time text in the scheduler bubble
  final TextStyle? suggestedTimeTextStyle;

  ///[suggestedTimeBackground] is a object of [Color] which is used to set the background color for the suggested time text in the scheduler bubble
  final Color? suggestedTimeBackground;

  ///[suggestedTimeBorder] is a object of [BoxBorder] which is used to set the border for the suggested time text in the scheduler bubble
  final BoxBorder? suggestedTimeBorder;

  ///[scheduleButtonStyle] is a object of [ButtonElementStyle] which is used to set the style for the schedule button in the scheduler bubble
  final ButtonElementStyle? scheduleButtonStyle;

  ///[titleTextStyle] is a object of [TextStyle] which is used to set the style for the title text in the scheduler bubble
  final TextStyle? titleTextStyle;

  ///[durationTextStyle] is a object of [TextStyle] which is used to set the style for the scheduler duration text in the scheduler bubble
  final TextStyle? durationTextStyle;

  ///[summaryTextStyle] is a object of [TextStyle] which is used to set the style for the summary text in the scheduler bubble
  final TextStyle? summaryTextStyle;

  ///[calendarSelectedDayBackgroundColor] is a object of [Color] which is used to set the background color for the selected day in the calendar
  final Color? calendarSelectedDayBackgroundColor;

  ///[calendarSelectedDayTint] is a object of [Color] which is used to set the tint color for the selected day in the calendar
  final Color? calendarSelectedDayTint;

  ///[calendarWeekdayTextStyle] is a object of [TextStyle] which is used to set the style for the weekday text in the calendar
  final TextStyle? calendarWeekdayTextStyle;

  /// Style options for the goal completion text within the scheduler bubble.
  final TextStyle? goalCompletionTextStyle;
}
