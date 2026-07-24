import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

/// Called with a pasted file's bytes, MIME type, and original filename (when
/// the browser provides one — documents/audio/video carry it; a raw pasted
/// image may not).
typedef ClipboardPasteCallback =
    void Function(Uint8List bytes, String mimeType, String? fileName);

/// Holds the JS listener so it can be removed with the exact same reference.
class _PasteHandle {
  _PasteHandle(this.listener);
  final web.EventListener listener;
}

/// Registers a document-level `paste` listener that pulls a file off the
/// clipboard — image, video, audio OR document — and forwards its bytes. Only
/// acts while [isActive] returns true (the composer is focused) so it doesn't
/// steal pastes meant for other fields; a plain-text paste (no file) is left
/// to the default handler.
///
/// Uses `package:web` + `dart:js_interop` (WASM-compatible). Returns a handle
/// to pass to [unregisterClipboardPasteListener].
Object? registerClipboardPasteListener(
  ClipboardPasteCallback onFile,
  bool Function() isActive,
) {
  void handler(web.Event event) {
    if (!event.isA<web.ClipboardEvent>()) return;
    if (!isActive()) return;
    final data = (event as web.ClipboardEvent).clipboardData;
    if (data == null) return;

    // Prefer the item list (correct across browsers); fall back to `files`
    // which Safari populates. Any file kind is accepted regardless of MIME —
    // the tray renders it by kind (image/video/audio/file).
    final items = data.items;
    final count = items.length;
    for (var i = 0; i < count; i++) {
      final item = items[i];
      if (item.kind == 'file') {
        final file = item.getAsFile();
        if (file == null) continue;
        event.preventDefault();
        _readAsBytes(file, onFile);
        return;
      }
    }

    final files = data.files;
    if (files.length > 0) {
      final file = files.item(0);
      if (file != null) {
        event.preventDefault();
        _readAsBytes(file, onFile);
      }
    }
  }

  final listener = handler.toJS;
  web.document.addEventListener('paste', listener);
  return _PasteHandle(listener);
}

/// Removes a listener registered by [registerClipboardPasteListener].
void unregisterClipboardPasteListener(Object? handle) {
  if (handle is _PasteHandle) {
    web.document.removeEventListener('paste', handle.listener);
  }
}

void _readAsBytes(web.File file, ClipboardPasteCallback onFile) {
  final mimeType = file.type;
  final name = file.name.isNotEmpty ? file.name : null;
  final reader = web.FileReader();
  reader.addEventListener(
    'loadend',
    (web.Event _) {
      final result = reader.result;
      if (result != null && result.isA<JSArrayBuffer>()) {
        final bytes = (result as JSArrayBuffer).toDart.asUint8List();
        if (bytes.isNotEmpty) onFile(bytes, mimeType, name);
      }
    }.toJS,
  );
  reader.readAsArrayBuffer(file);
}
