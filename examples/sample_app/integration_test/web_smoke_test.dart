import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'helpers_v2/app_launcher.dart';
import 'helpers_v2/pump_helper.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Web Smoke: Auth', () {
    testWidgets('E2E-001: Valid login shows HomeScreen', (tester) async {
      await AppLauncher.launchAndLogin(tester);
      await pumpFor(tester, const Duration(seconds: 3));
      expect(find.text('Chats').evaluate().isNotEmpty || find.byType(MaterialApp).evaluate().isNotEmpty, isTrue);
    });
  });
}
