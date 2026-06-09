import 'package:flutter_test/flutter_test.dart';

/// Pumps frames in real wall-clock time until [finder] matches at least one
/// widget, or [timeout] expires.
///
/// Unlike `tester.pump(duration)` which only advances the fake clock, this
/// actually waits real time — necessary for tests hitting real backends
/// (SDK login, Calls SDK init, conversation fetch).
///
/// Usage:
/// ```dart
/// await pumpUntilFound(tester, find.byType(InkWell), timeout: Duration(seconds: 10));
/// ```
Future<void> pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 40),
  Duration interval = const Duration(milliseconds: 500),
}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(interval);
    if (finder.evaluate().isNotEmpty) return;
    await Future<void>.delayed(interval);
  }
  // One final pump to ensure the frame is rendered
  await tester.pump();
}

/// Pumps frames for [duration] of real wall-clock time.
///
/// Unlike `tester.pump(duration)` which only advances fake time,
/// this actually waits and pumps, letting real async (SDK calls) complete.
Future<void> pumpForDuration(WidgetTester tester, Duration duration) async {
  final end = DateTime.now().add(duration);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 100));
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }
}
