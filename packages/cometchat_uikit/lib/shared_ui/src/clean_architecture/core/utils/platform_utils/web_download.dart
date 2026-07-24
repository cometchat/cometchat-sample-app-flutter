/// Web file download utility.
/// Uses conditional imports to provide web-only download via HTML anchor.
library;

export 'web_download_stub.dart'
    if (dart.library.js_interop) 'web_download_web.dart';
