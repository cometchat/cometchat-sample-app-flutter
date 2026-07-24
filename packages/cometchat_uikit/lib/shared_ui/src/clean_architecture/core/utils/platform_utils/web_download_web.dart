import 'dart:js_interop';

import 'package:web/web.dart' as web;

/// Triggers a real browser "save" of [url] as [fileName].
///
/// The naive `<a download href=cdnUrl>` approach fails for CometChat media: the
/// `download` attribute is a same-origin-only hint, so browsers ignore it for a
/// cross-origin CDN URL and just navigate to it — and since audio/video/images/
/// PDF render natively, the file opens/plays in a tab instead of saving. So we
/// fetch the bytes and download a same-origin `blob:` URL, which DOES honour
/// `download`. Falls back to opening the URL if the fetch is blocked (CORS).
void triggerBrowserDownload(String url, String fileName) {
  _downloadViaBlob(url, fileName);
}

Future<void> _downloadViaBlob(String url, String fileName) async {
  try {
    final resp = await web.window.fetch(url.toJS).toDart;
    if (!resp.ok) {
      _openFallback(url);
      return;
    }
    final blob = await resp.blob().toDart;
    final objectUrl = web.URL.createObjectURL(blob);
    final anchor = web.document.createElement('a') as web.HTMLAnchorElement
      ..href = objectUrl
      ..download = fileName
      ..style.display = 'none';
    web.document.body?.appendChild(anchor);
    anchor.click();
    anchor.remove();
    web.URL.revokeObjectURL(objectUrl);
  } catch (_) {
    // Fetch blocked (e.g. the CDN lacks CORS headers) — opening the URL is the
    // best remaining option, even if it renders in a tab.
    _openFallback(url);
  }
}

void _openFallback(String url) {
  web.window.open(url, '_blank');
}
