/// Utility for extracting thumbnail URLs from a message's metadata,
/// typically populated by the CometChat `thumbnail-generation` extension
/// for image and video attachments.
///
/// The extension writes data at
/// `metadata['@injected']['extensions']['thumbnail-generation']`
/// and exposes thumbnail URLs either at the root of that map
/// (`url_small` / `url_medium` / `url_large`) or nested under an
/// `attachments` list (`attachments[*].data.thumbnails.*`).
///
/// Some legacy producers populate `metadata['thumbnail']` directly —
/// that simple key is checked as a final fallback so older clients
/// keep working.
class ThumbnailExtractionUtil {
  ThumbnailExtractionUtil._();

  static const String _injectedKey = '@injected';
  static const String _extensionsKey = 'extensions';
  static const String _thumbnailGenerationKey = 'thumbnail-generation';
  static const String _simpleThumbnailKey = 'thumbnail';

  /// Returns the best-available thumbnail URL found in [metadata],
  /// or `null` if none is present.
  ///
  /// Lookup order:
  /// 1. `metadata['@injected']['extensions']['thumbnail-generation']`
  ///    — root keys `url_small` → `url_medium` → `url_large`.
  /// 2. Same extension object, nested under `attachments[*].data.thumbnails`.
  /// 3. `metadata['thumbnail']` (legacy fallback).
  ///
  /// The [tag] parameter is unused in production; it's kept for call-site
  /// clarity and for potential future instrumentation.
  static String? extractFromMetadata(
    Map<String, dynamic>? metadata, {
    String? tag,
  }) {
    if (metadata == null) return null;

    final injected = metadata[_injectedKey];
    if (injected is Map) {
      final extensions = injected[_extensionsKey];
      if (extensions is Map) {
        final thumbnailData = extensions[_thumbnailGenerationKey];
        if (thumbnailData is Map) {
          final rootUrl = _pickSize(thumbnailData);
          if (rootUrl != null && rootUrl.isNotEmpty) return rootUrl;

          final attachments = thumbnailData['attachments'];
          if (attachments is List) {
            for (final attachment in attachments) {
              if (attachment is Map &&
                  attachment['error'] == null &&
                  attachment['data'] is Map) {
                final thumbnails = (attachment['data'] as Map)['thumbnails'];
                if (thumbnails is Map) {
                  final nestedUrl = _pickSize(thumbnails);
                  if (nestedUrl != null && nestedUrl.isNotEmpty) {
                    return nestedUrl;
                  }
                }
              }
            }
          }
        }
      }
    }

    final legacy = metadata[_simpleThumbnailKey];
    if (legacy is String && legacy.isNotEmpty) return legacy;

    return null;
  }

  static String? _pickSize(Map map) {
    final small = map['url_small'];
    if (small is String && small.isNotEmpty) return small;
    final medium = map['url_medium'];
    if (medium is String && medium.isNotEmpty) return medium;
    final large = map['url_large'];
    if (large is String && large.isNotEmpty) return large;
    return null;
  }
}
