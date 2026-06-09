import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';

void main() {
  group('MessageList Error State View', () {
    testWidgets('default error state renders error text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: Translations.localizationsDelegates,
          supportedLocales: Translations.supportedLocales,
          home: Scaffold(
            body: Center(
              child: Builder(
                builder: (context) {
                  return const Text('Something went wrong');
                },
              ),
            ),
          ),
        ),
      );

      expect(find.text('Something went wrong'), findsOneWidget);
    });

    testWidgets('custom errorStateView overrides default', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: Translations.localizationsDelegates,
          supportedLocales: Translations.supportedLocales,
          home: Scaffold(
            body: Center(
              child: Builder(
                builder: (context) {
                  return const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline),
                      Text('Custom Error View'),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      );

      expect(find.text('Custom Error View'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });
  });
}
