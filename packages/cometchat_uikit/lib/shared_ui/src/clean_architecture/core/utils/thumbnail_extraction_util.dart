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
  ///    — root keys, preferring `url_medium` → `url_large` → `url_small`.
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

  /// Returns the thumbnail URL for the attachment at [index] in the
  /// `thumbnail-generation` extension's `attachments` list (that list is aligned
  /// with the message's attachments order), or `null`. For the first item it
  /// falls back to the single root/legacy thumbnail so single-attachment
  /// messages keep working.
  static String? thumbnailForIndex(Map<String, dynamic>? metadata, int index) {
    if (metadata == null || index < 0) return null;
    final injected = metadata[_injectedKey];
    if (injected is Map) {
      final extensions = injected[_extensionsKey];
      if (extensions is Map) {
        final thumbnailData = extensions[_thumbnailGenerationKey];
        if (thumbnailData is Map) {
          final attachments = thumbnailData['attachments'];
          if (attachments is List && index < attachments.length) {
            final entry = attachments[index];
            if (entry is Map &&
                entry['error'] == null &&
                entry['data'] is Map) {
              final thumbnails = (entry['data'] as Map)['thumbnails'];
              if (thumbnails is Map) {
                final url = _pickSize(thumbnails);
                if (url != null && url.isNotEmpty) return url;
              }
            }
          }
        }
      }
    }
    // No per-attachment entry — use the single root/legacy thumbnail only for the
    // first item so we don't repeat one thumbnail across many cells.
    if (index == 0) return extractFromMetadata(metadata);
    return null;
  }

  /// Resolves the poster for a specific attachment. Prefers a **stable match**
  /// on the source [url]/[name] against the `thumbnail-generation` entry, so a
  /// reordered or partially-populated extension list can't land a poster on the
  /// wrong grid cell. Falls back to positional [index] matching (the legacy
  /// behaviour) when the server exposes no matchable key — nothing regresses
  /// (R7).
  static String? thumbnailForAttachment(
    Map<String, dynamic>? metadata, {
    String? url,
    String? name,
    required int index,
  }) {
    final targetPath = _urlPath(url);
    final entries = _thumbnailEntries(metadata);
    // Keyed matching needs at least a URL path (preferred) or a name.
    if (entries != null &&
        (targetPath != null || (name != null && name.isNotEmpty))) {
      for (final entry in entries) {
        if (entry is! Map) continue;
        final data = entry['data'] is Map ? entry['data'] as Map : null;
        if (!_entryMatches(entry, data, targetPath, name)) continue;
        // Found THIS attachment's entry. Return its thumbnail, or null when the
        // server produced none (unsupported type → `error` set, `thumbnails`
        // null). We match even error entries so a reordered mixed success/error
        // list can't bleed a neighbour's poster into this cell via the
        // positional fallback.
        final thumbnails = data?['thumbnails'];
        return thumbnails is Map ? _pickSize(thumbnails) : null;
      }
    }
    // No keyed entry matched (server exposed no matchable key) — fall back to
    // legacy positional matching so nothing regresses.
    return thumbnailForIndex(metadata, index);
  }

  /// The `thumbnail-generation` extension's `attachments` list, or null.
  static List? _thumbnailEntries(Map<String, dynamic>? metadata) {
    if (metadata == null) return null;
    final injected = metadata[_injectedKey];
    if (injected is! Map) return null;
    final extensions = injected[_extensionsKey];
    if (extensions is! Map) return null;
    final thumbnailData = extensions[_thumbnailGenerationKey];
    if (thumbnailData is! Map) return null;
    final attachments = thumbnailData['attachments'];
    return attachments is List ? attachments : null;
  }

  /// True when [entry] describes the attachment identified by [targetPath] (a
  /// query-stripped URL path) or [name]. Confirmed against real `@injected`
  /// payloads: the entry's `data.url` mirrors the attachment `url`, so we match
  /// on the **path** (the signed query can be regenerated independently). Name
  /// is a weak fallback only — the server sanitizes it (spaces → underscores).
  static bool _entryMatches(
    Map entry,
    Map? data,
    String? targetPath,
    String? name,
  ) {
    String? s(Object? v) => v is String && v.isNotEmpty ? v : null;
    if (targetPath != null) {
      final paths = <String?>[
        _urlPath(s(entry['url'])),
        _urlPath(s(entry['fileUrl'])),
        if (data != null) ...[
          _urlPath(s(data['url'])),
          _urlPath(s(data['fileUrl'])),
        ],
      ];
      if (paths.any((p) => p != null && p == targetPath)) return true;
    }
    if (name != null && name.isNotEmpty) {
      final names = <String?>[
        s(entry['name']),
        if (data != null) s(data['name']),
      ];
      if (names.any((n) => n == name)) return true;
    }
    return false;
  }

  /// The path portion of [url] with any `?query` stripped, or null.
  static String? _urlPath(String? url) {
    if (url == null || url.isEmpty) return null;
    final q = url.indexOf('?');
    return q == -1 ? url : url.substring(0, q);
  }

  static String? _pickSize(Map map) {
    // Prefer url_medium (the shipped master-v5 poster resolution) → url_large →
    // url_small. Preferring url_small first upscaled a ~100px image with
    // BoxFit.cover on 2–3x DPR screens, degrading every video/image poster
    // (ENG-36976).
    final medium = map['url_medium'];
    if (medium is String && medium.isNotEmpty) return medium;
    final large = map['url_large'];
    if (large is String && large.isNotEmpty) return large;
    final small = map['url_small'];
    if (small is String && small.isNotEmpty) return small;
    return null;
  }
}
