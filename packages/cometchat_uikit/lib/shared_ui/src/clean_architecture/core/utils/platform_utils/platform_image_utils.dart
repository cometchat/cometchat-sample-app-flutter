/// Platform-agnostic image widget utilities.
///
/// Uses conditional imports to provide native Image.file on mobile/desktop
/// and a placeholder on web (since local file images aren't available).
export 'platform_image_utils_stub.dart'
    if (dart.library.io) 'platform_image_utils_native.dart'
    if (dart.library.html) 'platform_image_utils_web.dart';
