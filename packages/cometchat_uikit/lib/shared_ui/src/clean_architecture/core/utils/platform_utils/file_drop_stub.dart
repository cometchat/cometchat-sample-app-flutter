import 'dart:typed_data';

/// A file dropped onto the page: its bytes, filename and MIME type.
class DroppedFile {
  const DroppedFile(this.bytes, this.name, this.mimeType);

  final Uint8List bytes;
  final String name;
  final String mimeType;
}

/// Called with the batch of files from a single drop.
typedef DroppedFilesCallback = void Function(List<DroppedFile> files);

/// Called when a file drag enters (true) or leaves/drops (false) a target
/// region.
typedef DragActiveCallback = void Function(bool active);

/// Native/default no-op.
Object? registerFileDropListener(
  DroppedFilesCallback onFiles,
  bool Function(double clientX, double clientY) isActive, {
  DragActiveCallback? onDragActive,
}) => null;

/// No-op counterpart to [registerFileDropListener].
void unregisterFileDropListener(Object? handle) {}
