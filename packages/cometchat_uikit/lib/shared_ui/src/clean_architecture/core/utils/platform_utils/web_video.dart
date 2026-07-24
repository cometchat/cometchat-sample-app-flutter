/// Web video playback.
///
/// On web, `video_player`'s plugin marks the underlying `<video>` element
/// `crossOrigin='anonymous'`, so cross-origin CDN videos fail to load unless the
/// server sends CORS headers — producing an error instead of playback. A plain
/// HTML5 `<video controls>` element (via [HtmlElementView]) plays cross-origin
/// sources fine, so web uses that instead. Native returns null and keeps
/// `video_player`.
library;

export 'web_video_stub.dart' if (dart.library.js_interop) 'web_video_web.dart';
