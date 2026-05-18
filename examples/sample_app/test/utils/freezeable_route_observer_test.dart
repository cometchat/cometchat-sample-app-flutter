import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sample_app/utils/freezeable_route_observer.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Minimal Route stub for testing the observer
class FakeRoute extends PageRoute<void> {
  final String? routeName;

  FakeRoute([this.routeName]);

  @override
  RouteSettings get settings => RouteSettings(name: routeName);

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => Duration.zero;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return const SizedBox();
  }
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('FreezeableRouteObserver', () {
    late FreezeableRouteObserver observer;

    setUp(() {
      observer = FreezeableRouteObserver.instance;
      // Reset freeze state — pop enough times to clear any lingering count
      while (observer.shouldFreeze.value) {
        observer.didPop(FakeRoute('messages'), null);
      }
    });

    // -----------------------------------------------------------------------
    // Singleton
    // -----------------------------------------------------------------------

    test('instance returns the same singleton', () {
      final a = FreezeableRouteObserver.instance;
      final b = FreezeableRouteObserver.instance;
      expect(identical(a, b), isTrue);
    });

    // -----------------------------------------------------------------------
    // Initial state
    // -----------------------------------------------------------------------

    test('shouldFreeze starts as false', () {
      expect(observer.shouldFreeze.value, isFalse);
    });

    // -----------------------------------------------------------------------
    // addFreezeTriggerRoute
    // -----------------------------------------------------------------------

    test('addFreezeTriggerRoute registers custom route name', () {
      observer.addFreezeTriggerRoute('custom_route');

      // Push a route with that name
      observer.didPush(FakeRoute('custom_route'), null);
      expect(observer.shouldFreeze.value, isTrue);

      // Pop it
      observer.didPop(FakeRoute('custom_route'), null);
      expect(observer.shouldFreeze.value, isFalse);
    });

    // -----------------------------------------------------------------------
    // didPush / didPop with freeze trigger
    // -----------------------------------------------------------------------

    test('pushing messages route sets shouldFreeze to true', () {
      observer.didPush(FakeRoute('messages'), null);
      expect(observer.shouldFreeze.value, isTrue);
    });

    test('popping messages route sets shouldFreeze back to false', () {
      observer.didPush(FakeRoute('messages'), null);
      expect(observer.shouldFreeze.value, isTrue);

      observer.didPop(FakeRoute('messages'), null);
      expect(observer.shouldFreeze.value, isFalse);
    });

    // -----------------------------------------------------------------------
    // Non-freeze routes
    // -----------------------------------------------------------------------

    test('pushing non-freeze route does not change shouldFreeze', () {
      observer.didPush(FakeRoute('settings'), null);
      expect(observer.shouldFreeze.value, isFalse);
    });

    test('pushing route with null name does not change shouldFreeze', () {
      observer.didPush(FakeRoute(null), null);
      expect(observer.shouldFreeze.value, isFalse);
    });

    // -----------------------------------------------------------------------
    // Multiple pushes
    // -----------------------------------------------------------------------

    test('multiple freeze route pushes keep shouldFreeze true', () {
      observer.didPush(FakeRoute('messages'), null);
      observer.didPush(FakeRoute('messages'), null);
      expect(observer.shouldFreeze.value, isTrue);

      // Pop one — still frozen (count > 0)
      observer.didPop(FakeRoute('messages'), null);
      expect(observer.shouldFreeze.value, isTrue);

      // Pop second — unfrozen
      observer.didPop(FakeRoute('messages'), null);
      expect(observer.shouldFreeze.value, isFalse);
    });

    // -----------------------------------------------------------------------
    // Pop without push (edge case)
    // -----------------------------------------------------------------------

    test('popping without prior push does not go negative', () {
      observer.didPop(FakeRoute('messages'), null);
      expect(observer.shouldFreeze.value, isFalse);

      // Should still work normally after
      observer.didPush(FakeRoute('messages'), null);
      expect(observer.shouldFreeze.value, isTrue);
    });

    // -----------------------------------------------------------------------
    // ValueNotifier reactivity
    // -----------------------------------------------------------------------

    test('shouldFreeze notifier fires on state change', () {
      int notifyCount = 0;
      void listener() => notifyCount++;
      observer.shouldFreeze.addListener(listener);

      observer.didPush(FakeRoute('messages'), null);
      expect(notifyCount, greaterThanOrEqualTo(1));

      final countAfterPush = notifyCount;
      observer.didPop(FakeRoute('messages'), null);
      expect(notifyCount, greaterThan(countAfterPush));

      observer.shouldFreeze.removeListener(listener);
    });
  });
}
