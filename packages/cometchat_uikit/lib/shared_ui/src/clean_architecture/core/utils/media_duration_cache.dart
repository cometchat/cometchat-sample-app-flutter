import 'platform_utils/platform_file_utils.dart' as platform;

/// Caches media durations by source (an http(s) URL or a local path) so a video
/// cell probes each source at most once — even across message-list scroll and
/// rebuilds. Values (including nulls, for failures) are memoized for the app's
/// lifetime; the set of media URLs in a chat is small and stable.
class MediaDurationCache {
  MediaDurationCache._();

  static final Map<String, Future<Duration?>> _cache = {};

  /// Returns (and memoizes) the duration for [source]. Lazily probes via
  /// [platform.probeMediaDuration] — a network read on web/native, so callers
  /// should treat it as async and fail soft (null → no chip).
  static Future<Duration?> of(String source) {
    if (source.isEmpty) return Future<Duration?>.value(null);
    return _cache.putIfAbsent(
      source,
      () => platform.probeMediaDuration(source),
    );
  }
}
