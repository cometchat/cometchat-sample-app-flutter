/// Web file download utility.
/// Uses conditional imports to provide web-only download via HTML anchor.
export 'web_download_stub.dart'
    if (dart.library.html) 'web_download_web.dart';
