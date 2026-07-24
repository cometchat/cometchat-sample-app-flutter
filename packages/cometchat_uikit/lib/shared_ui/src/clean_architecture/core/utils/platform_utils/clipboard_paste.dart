/// Web clipboard-paste support (any file: image, video, audio, document).
///
/// On web the clipboard is event-driven: the browser fires a `paste` DOM event
/// on Ctrl/Cmd+V (or a right-click "Paste"), and the file bytes are read from
/// that event — Flutter's [Clipboard] and an on-demand pull don't apply. This
/// registers a document-level `paste` listener; native builds get a no-op stub
/// (native paste goes through the platform channel instead).
library;

export 'clipboard_paste_stub.dart'
    if (dart.library.js_interop) 'clipboard_paste_web.dart';
