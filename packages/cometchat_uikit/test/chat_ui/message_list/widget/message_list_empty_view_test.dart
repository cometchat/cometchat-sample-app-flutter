import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';

void main() {
  group('MessageList Empty State View', () {
    testWidgets('default empty state renders text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: Translations.localizationsDelegates,
          supportedLocales: Translations.supportedLocales,
          home: Scaffold(
            body: Center(
              child: Builder(
                builder: (context) {
                  return const Text('No messages yet');
                },
              ),
            ),
          ),
        ),
      );

      expect(find.text('No messages yet'), findsOneWidget);
    });

    testWidgets('custom emptyStateView overrides default', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: Translations.localizationsDelegates,
          supportedLocales: Translations.supportedLocales,
          home: Scaffold(
            body: Center(
              child: Builder(
                builder: (context) {
                  return const Text('Custom Empty');
                },
              ),
            ),
          ),
        ),
      );

      expect(find.text('Custom Empty'), findsOneWidget);
    });
  });
}
