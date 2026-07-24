// Regression guards for the two structural migrations made while clearing
// analyzer lints:
//   1. Radio(groupValue/onChanged) -> RadioGroup ancestor  (cometchat_change_scope)
//   2. ReorderableListView.onReorder -> onReorderItem      (cometchat_create_poll)
// Both changed how selection/index state is delivered, and neither is covered
// by a compile-time check.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';

Widget _host(Widget child) => MaterialApp(
  localizationsDelegates: Translations.localizationsDelegates,
  home: Scaffold(body: child),
);

void main() {
  testWidgets('change-scope radios select via RadioGroup ancestor', (
    tester,
  ) async {
    final group = Group(guid: 'g1', name: 'Group', type: 'public');
    final member = GroupMember(
      uid: 'u1',
      name: 'Member',
      scope: 'participant',
      role: 'default',
      status: 'offline',
      joinedAt: DateTime.now(),
    );

    await tester.pumpWidget(
      _host(CometChatChangeScope(group: group, member: member)),
    );
    await tester.pumpAndSettle();

    // The RadioGroup ancestor must exist and hold the member's current scope.
    final radioGroup = tester.widget<RadioGroup<String>>(
      find.byType(RadioGroup<String>),
    );
    expect(radioGroup.groupValue, 'participant');

    final radios = find.byType(Radio<String>);
    expect(radios, findsNWidgets(3));

    // Tapping "Admin" must move the group selection.
    await tester.tap(radios.first);
    await tester.pumpAndSettle();

    final after = tester.widget<RadioGroup<String>>(
      find.byType(RadioGroup<String>),
    );
    expect(after.groupValue, 'admin', reason: 'tap must update groupValue');
  });

  // The poll composer's handler no longer decrements newIndex itself. That is
  // only correct if onReorderItem reports an index already shifted for the
  // removal at oldIndex. Drive the identical downward drag through both
  // callbacks and compare what each reports.
  testWidgets('onReorderItem reports newIndex already shifted vs onReorder', (
    tester,
  ) async {
    Future<List<int>> report({required bool useOnReorderItem}) async {
      final seen = <int>[];
      void record(int oldIndex, int newIndex) => seen
        ..add(oldIndex)
        ..add(newIndex);

      final rows = [
        for (final i in ['a', 'b', 'c'])
          ListTile(key: ValueKey(i), title: Text(i.toUpperCase())),
      ];
      await tester.pumpWidget(
        _host(
          ReorderableListView(
            // Deliberately exercising the deprecated callback as the baseline.
            // ignore: deprecated_member_use
            onReorder: useOnReorderItem ? null : record,
            onReorderItem: useOnReorderItem ? record : null,
            children: rows,
          ),
        ),
      );

      final rowHeight = tester.getSize(find.byType(ListTile).first).height;
      final drag = await tester.startGesture(
        tester.getCenter(find.byKey(const ValueKey('a'))),
      );
      await tester.pump(const Duration(seconds: 1));
      for (var i = 0; i < 6; i++) {
        await drag.moveBy(Offset(0, rowHeight / 4));
        await tester.pump(const Duration(milliseconds: 16));
      }
      await drag.up();
      await tester.pumpAndSettle();
      return seen;
    }

    final legacy = await report(useOnReorderItem: false);
    final migrated = await report(useOnReorderItem: true);

    expect(legacy, isNotEmpty, reason: 'onReorder should have fired');
    expect(migrated, isNotEmpty, reason: 'onReorderItem should have fired');

    // Same gesture, same oldIndex.
    expect(migrated[0], legacy[0]);
    // Dragging downward, onReorderItem's newIndex is exactly one less — the
    // decrement the old handler used to apply by hand.
    expect(legacy[1], greaterThan(legacy[0]));
    expect(migrated[1], legacy[1] - 1);
  });
}
