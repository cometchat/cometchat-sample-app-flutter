import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';
import 'package:cometchat_chat_uikit/chat_ui/src/conversations/widgets/conversations_loading_view.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    localizationsDelegates: Translations.localizationsDelegates,
    supportedLocales: const [Locale('en')],
    home: Scaffold(body: SizedBox(width: 400, height: 800, child: child)),
  );
}

void main() {
  group('ConversationsLoadingView', () {
    testWidgets(
      'renders default shimmer (ListView + CircleAvatar placeholders)',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            Builder(
              builder: (context) {
                return ConversationsLoadingView(
                  colorPalette: CometChatThemeHelper.getColorPalette(context),
                  spacing: CometChatThemeHelper.getSpacing(context),
                  typography: CometChatThemeHelper.getTypography(context),
                );
              },
            ),
          ),
        );
        await tester.pump();

        // Shimmer wraps a ListView.builder with 30 placeholder items; we only
        // verify that at least one row rendered (ListView lazy-builds).
        expect(find.byType(ListView), findsOneWidget);
        expect(find.byType(CircleAvatar), findsWidgets);
      },
    );

    testWidgets(
      'renders customView when provided and skips the shimmer',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            Builder(
              builder: (context) {
                return ConversationsLoadingView(
                  colorPalette: CometChatThemeHelper.getColorPalette(context),
                  spacing: CometChatThemeHelper.getSpacing(context),
                  typography: CometChatThemeHelper.getTypography(context),
                  customView: (_) => const Text(
                    'Loading…',
                    key: Key('custom-loading'),
                  ),
                );
              },
            ),
          ),
        );
        await tester.pump();

        expect(find.byKey(const Key('custom-loading')), findsOneWidget);
        expect(find.byType(ListView), findsNothing);
      },
    );
  });
}
