import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:cometchat_chat_uikit/shared_ui/src/clean_architecture/core/utils/platform_utils/clipboard_paste.dart';

/// On native (VM) the paste-event listener resolves to the no-op stub: it must
/// register/unregister without touching a DOM or invoking the callback. The
/// real web behaviour is exercised by the web build compile.
void main() {
  test('registerClipboardPasteListener is a no-op on native', () {
    var called = false;
    final handle = registerClipboardPasteListener(
      (Uint8List bytes, String mime, String? name) => called = true,
      () => true,
    );
    expect(handle, isNull);
    expect(called, isFalse);
    // Unregistering a null handle must not throw.
    unregisterClipboardPasteListener(handle);
  });
}
