// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

/// Triggers a browser file download using an HTML anchor element.
/// This forces the browser to download the file instead of opening it.
void triggerBrowserDownload(String url, String fileName) {
  final anchor = html.AnchorElement(href: url)
    ..setAttribute('download', fileName)
    ..setAttribute('target', '_blank')
    ..style.display = 'none';
  html.document.body?.append(anchor);
  anchor.click();
  anchor.remove();
}
