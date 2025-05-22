import 'dart:core';

import 'package:cometchat_uikit_shared/cometchat_uikit_shared.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cometchat_uikit_shared/cometchat_uikit_shared.dart' as cc;

class CometChatDateTimeFormField extends StatefulWidget {
  const CometChatDateTimeFormField(
      {super.key,
      this.initialDate,
      this.controller,
      this.onChanged,
      this.fromDate,
      this.toDate,
      this.initialTime,
      required this.theme,
      this.placeholder,
      this.textInputStyle,
      this.formatterString,
      this.placeholderStyle,
      this.mode = DateTimeVisibilityMode.dateTime,
      this.value,
      this.dateTimeElementStyle,
      this.cancelText,
      this.confirmText});
  final TextEditingController? controller;
  final DateTime? initialDate;
  final TimeOfDay? initialTime;
  final DateTime? fromDate;
  final DateTime? toDate;
  final ValueChanged<DateTime?>? onChanged;
  final DateTime? value;
  final CometChatTheme theme;
  final TextStyle? textInputStyle;
  final String? placeholder;
  final TextStyle? placeholderStyle;
  final String? formatterString;
  final DateTimeVisibilityMode mode;
  final DateTimeElementStyle? dateTimeElementStyle;
  final String? cancelText;
  final String? confirmText;

  @override
  State<CometChatDateTimeFormField> createState() =>
      _CometChatDateTimeFormFieldState();
}

class _CometChatDateTimeFormFieldState
    extends State<CometChatDateTimeFormField> {
  late TextEditingController controller;
  late DateFormat formatter;
  late String formatterString;
  late DateTime todayDate;
  late TextStyle inputTextStyle;

  setDateToController(DateTime date) {
    setState(() {
      controller.text = _getFormattedString(date);
    });
  }

  String _getFormattedString(DateTime date) {
    return formatter.format(date);
  }

  @override
  void initState() {
    todayDate = DateTime.now();
    inputTextStyle = TextStyle(
      fontSize: widget.theme.typography.subtitle1.fontSize,
      fontWeight: widget.theme.typography.subtitle1.fontWeight,
      fontFamily: widget.theme.typography.subtitle1.fontFamily,
      color: widget.theme.palette.getAccent(),
    ).merge(widget.textInputStyle);

    if (widget.formatterString != null) {
      formatterString = widget.formatterString!;
    } else {
      if (widget.mode == DateTimeVisibilityMode.time) {
        formatterString = "hh:mm a";
      } else if (widget.mode == DateTimeVisibilityMode.date) {
        formatterString = "yyyy-MM-DD";
      } else {
        formatterString = "yyyy-MM-DD , hh:mm a";
      }
    }

    controller = TextEditingController(text: "");
    formatter = DateFormat(formatterString);
    if (widget.value != null) {
      if (widget.value is! TimeOfDay) {
        controller.text = _getFormattedString(widget.value!);
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration.collapsed(
        hintText: widget.placeholder,
        hintStyle: TextStyle(
                fontWeight: cometChatTheme.typography.subtitle1.fontWeight)
            .merge(widget.placeholderStyle),
      ),
      controller: controller,
      readOnly: true,
      onTap: () {
        pickDateTime();
      },
      style: inputTextStyle,
    );
  }

  pickDateTime() async {
    // String addLeadingZeroIfNeeded(int value) {
    //   if (value < 10) {
    //     return '0$value';
    //   }
    //   return value.toString();
    // }
    if (widget.mode == DateTimeVisibilityMode.time) {
      TimeOfDay? time = await pickTime();
      if (time != null) {
        DateTime localDate = DateTime(todayDate.year, todayDate.month,
            todayDate.day, time.hour, time.minute);
        setDateToController(localDate);
        if (widget.onChanged != null) {
          widget.onChanged!(DateTime(todayDate.year, todayDate.month,
              todayDate.day, time.hour, time.minute));
        }
      }
    } else if (widget.mode == DateTimeVisibilityMode.date) {
      DateTime? date = await pickDate();
      if (date != null) {
        setDateToController(date);
        if (widget.onChanged != null) {
          widget.onChanged!(date);
        }
      }
    } else {
      DateTime? date = await pickDate();
      if (date != null) {
        TimeOfDay? time = await pickTime();
        if (time != null) {
          DateTime newDate =
              DateTime(date.year, date.month, date.day, time.hour, time.minute);
          setDateToController(newDate);

          widget.onChanged!(newDate);
        }
      }
    }
  }

  Future<DateTime?> pickDate() async {
    DateTime? pickedDate;
    pickedDate = await showDatePicker(
      confirmText: cc.Translations.of(context).ok,
      cancelText: cc.Translations.of(context).cancel,
      context: context,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: widget.theme.palette.mode == PaletteThemeModes.dark
                ? ColorScheme.dark(
                    primary: widget.theme.palette.getPrimary(),
                    onPrimary: widget.theme.palette.backGroundColor.light,
                    onSurface: widget.theme.palette.getAccent(),
                    brightness: Brightness.light)
                : ColorScheme.light(
                    primary: widget.theme.palette.getPrimary(),
                    onPrimary: widget.theme.palette.backGroundColor.light,
                    onSurface: widget.theme.palette.getAccent(),
                    brightness: Brightness.light),
            dialogBackgroundColor: widget.theme.palette.getBackground(),
            datePickerTheme: DatePickerThemeData(
              headerForegroundColor: widget.theme.palette.backGroundColor.light,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor:
                    widget.theme.palette.getAccent(), // button text color
              ),
            ),
          ),
          child: child!,
        );
      },
      initialDate: widget.initialDate ?? DateTime.now(),
      firstDate: widget.fromDate ?? DateTime.now(),
      lastDate: widget.toDate ?? DateTime.now().add(const Duration(days: 60)),
    );
    return pickedDate;
  }

  Future<TimeOfDay?> pickTime() async {
    TimeOfDay? pickedTime;
    pickedTime = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 0, minute: 0),
      cancelText: widget.cancelText ?? cc.Translations.of(context).cancel,
      confirmText: widget.confirmText ?? cc.Translations.of(context).ok,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: widget.theme.palette.mode == PaletteThemeModes.dark
                ? ColorScheme.dark(
                    primary: widget.theme.palette.getPrimary(),
                    onPrimary: widget.theme.palette.getAccent(),
                    onSurface: widget.theme.palette.getAccent(),
                    brightness: Brightness.light)
                : ColorScheme.light(
                    primary: widget.theme.palette.getPrimary(),
                    onPrimary: widget.theme.palette.getAccent(),
                    onSurface: widget.theme.palette.getAccent(),
                    brightness: Brightness.light),
            dialogBackgroundColor: widget.theme.palette.getBackground(),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor:
                    widget.theme.palette.getAccent(), // button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    return pickedTime;
  }
}
