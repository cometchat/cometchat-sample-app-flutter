import 'package:flutter_test/flutter_test.dart';

/// Pump utilities for E2E tests that hit real backends.
///
/// Flutter's test framework uses a fake async clock. For integration tests
/// that talk to real CometChat servers (login, SDK events, REST calls),
/// we need to advance real wall-clock time while still pumping frames so
/// the widget tree processes incoming events.
///
/// Key principle: NO explicit long timers. We pump until the UI stabilizes
/// or a finder matches — whichever comes first.

/// Pump frames for a short real-time duration.
///
/// Use this after SDK/REST actions that fire WebSocket events. The event
/// needs a moment to traverse: REST → server → WebSocket → SDK listener → UI.
///
/// Typical usage: `await pumpForRealtime(tester);` (defaults to 5s)
Future<void> pumpForRealtime(
  WidgetTester tester, {
  Duration duration = const Duration(seconds: 5),
}) async {
  final end = DateTime.now().add(duration);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 100));
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }
}

/// Pump frames until [finder] finds at least one widget, or [timeout] expires.
///
/// Returns true if the finder matched, false if timed out.
/// Does NOT throw on timeout — caller decides how to handle.
Future<bool> pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 10),
}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 200));
    if (finder.evaluate().isNotEmpty) return true;
    await Future<void>.delayed(const Duration(milliseconds: 200));
  }
  // One final pump
  await tester.pump();
  return finder.evaluate().isNotEmpty;
}

/// Pump frames until [finder] finds NO widgets, or [timeout] expires.
///
/// Useful for waiting until a loading indicator disappears, or a deleted
/// message is removed from the UI.
Future<bool> pumpUntilGone(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 10),
}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 200));
    if (finder.evaluate().isEmpty) return true;
    await Future<void>.delayed(const Duration(milliseconds: 200));
  }
  await tester.pump();
  return finder.evaluate().isEmpty;
}

/// Pump frames for a fixed duration (real wall-clock time).
///
/// Use sparingly — prefer [pumpUntilFound] or [pumpForRealtime].
/// This is for cases where you need the app to process background events
/// without a specific widget to wait for (e.g., letting SDK init complete).
Future<void> pumpFor(WidgetTester tester, Duration duration) async {
  final end = DateTime.now().add(duration);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 100));
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }
}
