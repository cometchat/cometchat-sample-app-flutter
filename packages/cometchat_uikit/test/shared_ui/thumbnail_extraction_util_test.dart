import 'package:flutter_test/flutter_test.dart';
import 'package:cometchat_chat_uikit/shared_ui/src/clean_architecture/core/utils/thumbnail_extraction_util.dart';

/// Covers [ThumbnailExtractionUtil.thumbnailForAttachment] (R7). Fixtures mirror
/// the real `@injected.extensions.thumbnail-generation` shape observed on the
/// wire: each entry carries `data.url` (mirroring the attachment URL, signed
/// query included) and `data.thumbnails` (`url_medium/large/small`, or null with
/// an `error` for unsupported types). Posters are matched by the URL **path**
/// (query stripped) so a reordered or re-signed list can't mis-place a poster.
Map<String, dynamic> _meta(List<Map<String, dynamic>> attachments) => {
  '@injected': {
    'extensions': {
      'thumbnail-generation': {'attachments': attachments},
    },
  },
};

Map<String, dynamic> _entry(String url, {String? thumb, bool error = false}) =>
    {
      'data': {
        'url': url,
        'thumbnails': thumb == null ? null : {'url_medium': thumb},
      },
      'error': error ? {'code': 'ERR_FILETYPE_NOT_SUPPORTED'} : null,
    };

void main() {
  group('thumbnailForAttachment — keyed by URL path', () {
    test('matches on the path even when the signed query differs', () {
      final metadata = _meta([
        _entry(
          'https://cdn.example/media/imgA.png?Expires=1&Signature=AAA',
          thumb: 'thumbA',
        ),
      ]);
      // Same storage path, DIFFERENT Expires/Signature — must still match.
      expect(
        ThumbnailExtractionUtil.thumbnailForAttachment(
          metadata,
          url: 'https://cdn.example/media/imgA.png?Expires=9&Signature=ZZZ',
          index: 0,
        ),
        'thumbA',
      );
    });

    test('resolves the right poster despite a reordered extension list', () {
      // Extension order [B, A] is the reverse of message order [A, B].
      final metadata = _meta([
        _entry('https://cdn.example/media/B.png?Signature=x', thumb: 'thumbB'),
        _entry('https://cdn.example/media/A.png?Signature=y', thumb: 'thumbA'),
      ]);
      expect(
        ThumbnailExtractionUtil.thumbnailForAttachment(
          metadata,
          url: 'https://cdn.example/media/A.png?Signature=live',
          index: 0, // positional would wrongly return thumbB
        ),
        'thumbA',
      );
    });

    test(
      'matched entry with no server thumbnail returns null, not a neighbour',
      () {
        // Mixed: image B (has thumb) reordered ahead of video A (error, no thumb).
        final metadata = _meta([
          _entry(
            'https://cdn.example/media/B.png?Signature=x',
            thumb: 'thumbB',
          ),
          _entry('https://cdn.example/media/A.mp4?Signature=y', error: true),
        ]);
        // A is message-index 0; positional would bleed thumbB onto the video cell.
        expect(
          ThumbnailExtractionUtil.thumbnailForAttachment(
            metadata,
            url: 'https://cdn.example/media/A.mp4?Signature=live',
            index: 0,
          ),
          isNull,
        );
      },
    );
  });

  group('thumbnailForAttachment — positional fallback', () {
    test('falls back to index when no entry exposes a matchable URL', () {
      final metadata = _meta([
        {
          'data': {
            'thumbnails': {'url_medium': 'thumb0'},
          },
        },
        {
          'data': {
            'thumbnails': {'url_medium': 'thumb1'},
          },
        },
      ]);
      expect(
        ThumbnailExtractionUtil.thumbnailForAttachment(
          metadata,
          url: 'https://cdn.example/media/unknown.png',
          index: 1,
        ),
        'thumb1',
      );
    });

    test('null metadata yields null', () {
      expect(
        ThumbnailExtractionUtil.thumbnailForAttachment(
          null,
          url: 'https://cdn.example/media/x.png',
          index: 0,
        ),
        isNull,
      );
    });
  });
}
