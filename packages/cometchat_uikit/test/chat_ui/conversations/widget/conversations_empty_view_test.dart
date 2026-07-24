import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';

/// Minimal app wrapper for widget tests.
/// Provides Material, the CometChat localizations delegate (required by
/// `Translations.of`), and the English locale.
Widget _wrap(Widget child) {
  return MaterialApp(
    localizationsDelegates: Translations.localizationsDelegates,
    supportedLocales: const [Locale('en')],
    home: Scaffold(body: child),
  );
}

void main() {
  group('ConversationsEmptyView', () {
    testWidgets(
      'renders the default empty-state copy when no custom view is provided',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            Builder(
              builder: (context) {
                return ConversationsEmptyView(
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

        // Default empty-state has an image + two Text nodes (title + subtitle).
        expect(find.byType(Text), findsNWidgets(2));
        expect(find.byType(Image), findsOneWidget);
      },
    );

    testWidgets(
      'renders customView when provided and skips the default state',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            Builder(
              builder: (context) {
                return ConversationsEmptyView(
                  style: const CometChatConversationsStyle(),
                  colorPalette: CometChatThemeHelper.getColorPalette(context),
                  spacing: CometChatThemeHelper.getSpacing(context),
                  typography: CometChatThemeHelper.getTypography(context),
                  customView: (_) =>
                      const Text('Custom empty', key: Key('custom-empty')),
                );
              },
            ),
          ),
        );
        await tester.pump();

        expect(find.byKey(const Key('custom-empty')), findsOneWidget);
        // Custom view replaces default — no default Image should be rendered.
        expect(find.byType(Image), findsNothing);
      },
    );

    testWidgets('applies style.emptyStateTextColor when provided', (
      tester,
    ) async {
      const customColor = Color(0xFFFF00FF);

      await tester.pumpWidget(
        _wrap(
          Builder(
            builder: (context) {
              return ConversationsEmptyView(
                style: const CometChatConversationsStyle(
                  emptyStateTextColor: customColor,
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

      // Title is the first Text in the default empty view.
      final titleText = tester.widgetList<Text>(find.byType(Text)).first;
      expect(titleText.style?.color, customColor);
    });
  });
}
