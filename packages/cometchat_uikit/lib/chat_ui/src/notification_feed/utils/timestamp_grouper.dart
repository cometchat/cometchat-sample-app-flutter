import 'package:cometchat_sdk/cometchat_sdk.dart' hide CardMessage;
import 'package:intl/intl.dart';

/// Represents a group of feed items sharing the same calendar day.
class TimestampGroup {
  /// Display label for the group header (e.g., "Today", "Yesterday", "Mon, Jan 15").
  final String label;

  /// Feed items within this group, sorted newest-first.
  final List<NotificationFeedItem> items;

  const TimestampGroup({required this.label, required this.items});
}

/// Groups notification feed items by their `sentAt` timestamp into sections.
///
/// Groups are sorted newest-first. Items within each group are sorted newest-first.
/// Labels follow the pattern:
/// - sentAt is today → "Today"
/// - sentAt is yesterday → "Yesterday"
/// - sentAt is within this week → Day name (e.g., "Monday")
/// - sentAt is older → Localized date (e.g., "Jan 15, 2025")
///
/// This is a pure function with no side effects.
List<TimestampGroup> groupByTimestamp(
  List<NotificationFeedItem> items,
  String locale,
) {
  if (items.isEmpty) return [];

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));

  // Determine the start of the current week (Monday)
  final weekStart = today.subtract(Duration(days: today.weekday - 1));

  // Group items by calendar day
  final Map<String, List<NotificationFeedItem>> groupMap = {};
  final Map<String, DateTime> groupDates = {};

  for (final item in items) {
    final itemDate = DateTime.fromMillisecondsSinceEpoch(item.sentAt * 1000);
    final itemDay = DateTime(itemDate.year, itemDate.month, itemDate.day);

    final label = _getLabelForDate(
      itemDay,
      today,
      yesterday,
      weekStart,
      locale,
    );

    groupMap.putIfAbsent(label, () => []);
    groupMap[label]!.add(item);

    // Track the actual date for sorting groups
    if (!groupDates.containsKey(label) || itemDay.isAfter(groupDates[label]!)) {
      groupDates[label] = itemDay;
    }
  }

  // Sort items within each group newest-first
  for (final items in groupMap.values) {
    items.sort((a, b) => b.sentAt.compareTo(a.sentAt));
  }

  // Sort groups newest-first by their representative date
  final sortedLabels = groupMap.keys.toList()
    ..sort((a, b) {
      final dateA = groupDates[a]!;
      final dateB = groupDates[b]!;
      return dateB.compareTo(dateA);
    });

  return sortedLabels
      .map((label) => TimestampGroup(label: label, items: groupMap[label]!))
      .toList();
}

/// Determine the display label for a given date.
String _getLabelForDate(
  DateTime itemDay,
  DateTime today,
  DateTime yesterday,
  DateTime weekStart,
  String locale,
) {
  if (itemDay == today) {
    return 'Today';
  } else if (itemDay == yesterday) {
    return 'Yesterday';
  } else if (itemDay.isAfter(weekStart) || itemDay == weekStart) {
    // Within this week — show day name
    return DateFormat.EEEE(locale).format(itemDay);
  } else {
    // Older — show localized date
    return DateFormat.yMMMd(locale).format(itemDay);
  }
}

/// Get a relative time string for a single item matching CometChatDate.setDayTime:
/// - Today (< 24h): Time only (e.g., "2:35 PM")
/// - Yesterday (24–48h): "Yesterday"
/// - This week (2–7 days): Day name (e.g., "Monday")
/// - Older (> 7 days): Full date (e.g., "25/05/2026")
String getRelativeTime(int sentAtSeconds, String locale) {
  final now = DateTime.now();
  final sentAt = DateTime.fromMillisecondsSinceEpoch(sentAtSeconds * 1000);

  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));
  final sentAtDay = DateTime(sentAt.year, sentAt.month, sentAt.day);

  if (sentAtDay == today) {
    // Today — show time only (e.g., "2:35 PM")
    return DateFormat.jm(locale).format(sentAt);
  } else if (sentAtDay == yesterday) {
    // Yesterday
    return 'Yesterday';
  } else if (now.difference(sentAt).inDays < 7) {
    // Within this week — show day name (e.g., "Monday")
    return DateFormat.EEEE(locale).format(sentAt);
  } else {
    // Older — show full date (e.g., "25/05/2026")
    return DateFormat('dd/MM/yyyy').format(sentAt);
  }
}
