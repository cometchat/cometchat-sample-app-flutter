import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sample_app/widgets/freezeable_widget.dart';
import 'package:sample_app/utils/freezeable_route_observer.dart';

void main() {
  group('FreezeableWidget', () {
    setUp(() {
      // Reset freeze state
      FreezeableRouteObserver.instance.shouldFreeze.value = false;
    });

    testWidgets('renders child when not frozen', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FreezeableWidget(
              child: Text('Hello'),
            ),
          ),
        ),
      );

      expect(find.text('Hello'), findsOneWidget);
    });

    testWidgets('child becomes non-interactive when frozen', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FreezeableWidget(
              child: GestureDetector(
                onTap: () => tapped = true,
                child: const Text('Tap me'),
              ),
            ),
          ),
        ),
      );

      // Tap works when not frozen
      await tester.tap(find.text('Tap me'));
      expect(tapped, isTrue);

      // Reset and freeze
      tapped = false;
      FreezeableRouteObserver.instance.shouldFreeze.value = true;
      await tester.pump();

      // Tap should be ignored when frozen (IgnorePointer)
      await tester.tap(find.text('Tap me'), warnIfMissed: false);
      expect(tapped, isFalse);
    });

    testWidgets('child becomes interactive again when unfrozen',
        (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FreezeableWidget(
              child: GestureDetector(
                onTap: () => tapped = true,
                child: const Text('Tap me'),
              ),
            ),
          ),
        ),
      );

      // Freeze
      FreezeableRouteObserver.instance.shouldFreeze.value = true;
      await tester.pump();

      await tester.tap(find.text('Tap me'), warnIfMissed: false);
      expect(tapped, isFalse);

      // Unfreeze
      FreezeableRouteObserver.instance.shouldFreeze.value = false;
      await tester.pump();

      await tester.tap(find.text('Tap me'));
      expect(tapped, isTrue);
    });

    testWidgets('applies dim opacity when dimWhenFrozen is true',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FreezeableWidget(
              dimWhenFrozen: true,
              dimOpacity: 0.3,
              child: Text('Hello'),
            ),
          ),
        ),
      );

      // Freeze
      FreezeableRouteObserver.instance.shouldFreeze.value = true;
      await tester.pump();

      // Find the Opacity widget that's a descendant of FreezeableWidget
      final opacityFinder = find.descendant(
        of: find.byType(FreezeableWidget),
        matching: find.byType(Opacity),
      );
      expect(opacityFinder, findsOneWidget);

      final opacity = tester.widget<Opacity>(opacityFinder);
      expect(opacity.opacity, 0.3);
    });
  });
}
