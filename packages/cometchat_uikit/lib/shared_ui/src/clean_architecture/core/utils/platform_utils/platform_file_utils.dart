/// Platform-agnostic file utilities.
///
/// Uses conditional imports to provide native (dart:io) implementation on
/// mobile/desktop and a no-op/web-safe implementation on web.
export 'platform_file_utils_stub.dart'
    if (dart.library.io) 'platform_file_utils_native.dart'
    if (dart.library.html) 'platform_file_utils_web.dart';
