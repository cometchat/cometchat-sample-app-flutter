import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

/// Screenshot capture utility for E2E tests.
///
/// Captures screenshots at key verification points. Screenshots are organized
/// by test suite and step name, stored on the device's filesystem.
///
/// Structure:
///   /sdcard/Pictures/e2e_screenshots/<suite>/<test_id>/<step>.png   (Android)
///   ~/Library/Screenshots/e2e/<suite>/<test_id>/<step>.png           (iOS Sim)
class ScreenshotHelper {
  ScreenshotHelper(this.suiteName);

  final String suiteName;
  int _stepCounter = 0;

  /// Reset step counter (call at start of each test).
  void resetSteps() => _stepCounter = 0;

  /// Take a screenshot with an auto-incrementing step number.
  ///
  /// [testId] — e.g., 'RT-MSG-001'
  /// [description] — e.g., 'message_received'
  ///
  /// Resulting filename: 001_message_received.png
  Future<void> take(
    WidgetTester tester,
    String testId,
    String description,
  ) async {
    _stepCounter++;
    final step = _stepCounter.toString().padLeft(3, '0');
    final filename = '${step}_$description';

    try {
      final binding = IntegrationTestWidgetsFlutterBinding.instance;

      // Use the binding's screenshot capability
      final bytes = await binding.takeScreenshot(filename);

      // Save to device filesystem
      if (!kIsWeb) {
        final dir = _getScreenshotDir(testId);
        final file = File('$dir/$filename.png');
        await file.parent.create(recursive: true);
        await file.writeAsBytes(bytes);
        debugPrint('[Screenshot] Saved: $dir/$filename.png');
      }
    } catch (e) {
      // Non-fatal — screenshots are nice-to-have, not blocking.
      debugPrint('[Screenshot] Failed to capture "$filename": $e');
    }
  }

  String _getScreenshotDir(String testId) {
    if (Platform.isAndroid) {
      return '/sdcard/Pictures/e2e_screenshots/$suiteName/$testId';
    } else if (Platform.isIOS || Platform.isMacOS) {
      return '${Platform.environment['HOME']}/Library/Screenshots/e2e/$suiteName/$testId';
    }
    // Fallback
    return '/tmp/e2e_screenshots/$suiteName/$testId';
  }
}
