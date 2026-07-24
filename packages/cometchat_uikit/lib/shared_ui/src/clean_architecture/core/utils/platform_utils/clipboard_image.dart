import 'dart:typed_data';

/// A file read off the system clipboard: the raw encoded bytes, the MIME type
/// reported by the platform (e.g. `image/png`, `video/mp4`, `application/pdf`),
/// and the original filename when the platform exposes one. Despite the name,
/// this now carries any pasted file kind — image, video, audio or document.
class ClipboardImage {
  const ClipboardImage(this.bytes, this.mimeType, [this.fileName]);

  final Uint8List bytes;
  final String mimeType;

  /// The source filename when the platform provides one (Android display name,
  /// or a synthesized name on iOS); null otherwise.
  final String? fileName;
}
