import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    localizationsDelegates: Translations.localizationsDelegates,
    supportedLocales: const [Locale('en')],
    home: Scaffold(body: child),
  );
}

void main() {
  group('ConversationsErrorView', () {
    testWidgets(
      'renders default error UI: image + "Oops" title + subtitle line',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            Builder(
              builder: (context) {
                return ConversationsErrorView(
                  errorMessage: 'Network failure',
                  style: const CometChatConversationsStyle(),
                  colorPalette: CometChatThemeHelper.getColorPalette(context),
                  spacing: CometChatThemeHelper.getSpacing(context),
                  typography: CometChatThemeHelper.getTypography(context),
                );
              },
            ),
          ),
        );
        await tester.pump();

        // Default error view is image + 2 text nodes (title + subtitle).
        expect(find.byType(Text), findsNWidgets(2));
        expect(find.byType(Image), findsOneWidget);
      },
    );

    testWidgets('renders customView when provided and skips the default UI', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          Builder(
            builder: (context) {
              return ConversationsErrorView(
                errorMessage: 'x',
                style: const CometChatConversationsStyle(),
                colorPalette: CometChatThemeHelper.getColorPalette(context),
                spacing: CometChatThemeHelper.getSpacing(context),
                typography: CometChatThemeHelper.getTypography(context),
                customView: (_) =>
                    const Text('Custom error', key: Key('custom-err')),
              );
            },
          ),
        ),
      );
      await tester.pump();

      expect(find.byKey(const Key('custom-err')), findsOneWidget);
      expect(find.byType(Image), findsNothing);
    });

    testWidgets('applies style.errorStateTextColor to the title', (
      tester,
    ) async {
      const customColor = Color(0xFF123456);

      await tester.pumpWidget(
        _wrap(
          Builder(
            builder: (context) {
              return ConversationsErrorView(
                errorMessage: 'x',
                style: const CometChatConversationsStyle(
                  errorStateTextColor: customColor,
                ),
                colorPalette: CometChatThemeHelper.getColorPalette(context),
                spacing: CometChatThemeHelper.getSpacing(context),
                typography: CometChatThemeHelper.getTypography(context),
              );
            },
          ),
        ),
      );
      await tester.pump();

      final titleText = tester.widgetList<Text>(find.byType(Text)).first;
      expect(titleText.style?.color, customColor);
    });
  });
}
