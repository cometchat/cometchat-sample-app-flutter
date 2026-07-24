/// Web drag-and-drop file support.
///
/// Registers document-level `dragover`/`drop` listeners so files dragged from
/// the OS onto the chat are staged in the composer's attachment tray. Native
/// builds get a no-op stub (drag-drop of OS files isn't a thing there).
library;

export 'file_drop_stub.dart' if (dart.library.js_interop) 'file_drop_web.dart';
