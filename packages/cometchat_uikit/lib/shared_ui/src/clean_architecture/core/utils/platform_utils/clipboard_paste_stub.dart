import 'dart:typed_data';

/// Called with a pasted file's bytes, MIME type, and original filename.
typedef ClipboardPasteCallback =
    void Function(Uint8List bytes, String mimeType, String? fileName);

/// Native/default no-op — clipboard paste on mobile/desktop goes through the
/// platform channel ([readClipboardImage]), not a DOM paste event.
Object? registerClipboardPasteListener(
  ClipboardPasteCallback onFile,
  bool Function() isActive,
) => null;

/// No-op counterpart to [registerClipboardPasteListener].
void unregisterClipboardPasteListener(Object? handle) {}
