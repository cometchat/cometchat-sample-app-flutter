
abstract class DateTimeFormatterCallback {
  String? time(int? timestamp) => null;
  String? today(int? timestamp) => null;
  String? yesterday(int? timestamp) => null;
  String? lastWeek(int? timestamp) => null;
  String? otherDays(int? timestamp) => null;
  String? minute(int? timestamp) => null;
  String? minutes(int? diffInMinutesFromNow, int? timestamp) => null;
  String? hour(int? timestamp) => null;
  String? hours(int? diffInHourFromNow, int? timestamp) => null;
}
