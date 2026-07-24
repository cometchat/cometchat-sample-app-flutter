/// A file chosen from the browser's native file dialog on web: its in-memory
/// [bytes] plus [name]/[size]/[mimeType]. Native/desktop pick through the
/// platform channel instead, so this type only carries data on web.
class WebPickedFile {
  const WebPickedFile({
    required this.name,
    required this.bytes,
    required this.size,
    required this.mimeType,
  });

  final String name;
  final List<int> bytes;
  final int size;
  final String mimeType;
}
