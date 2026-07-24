import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

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
/// region (see [registerFileDropListener]'s [isActive]).
typedef DragActiveCallback = void Function(bool active);

class _DropHandle {
  _DropHandle(this.listeners);
  final Map<String, web.EventListener> listeners;
}

bool _isFileDrag(web.Event event) {
  if (!event.isA<web.DragEvent>()) return false;
  final types = (event as web.DragEvent).dataTransfer?.types;
  if (types == null) return false;
  for (var i = 0; i < types.length; i++) {
    if (types[i].toDart == 'Files') return true;
  }
  return false;
}

/// Registers document drag/drop listeners, scoped to a target region: [isActive]
/// receives the pointer's viewport coordinates (`clientX`/`clientY`, in CSS
/// pixels — the same space as a Flutter widget's global [Offset] when the
/// Flutter view fills the browser viewport) and returns whether that point is
/// over the drop target (e.g. the composer). Flutter web has no nested DOM
/// structure for `dragenter`/`dragleave` to bubble through per-widget, so
/// containment is computed continuously from `dragover`'s live position
/// instead of an enter/leave depth counter.
///
/// `dragover` is always default-prevented while a file drag is in progress
/// (anywhere on the page) so the browser never navigates to the dropped file;
/// [onDragActive] fires true/false only as the pointer crosses in/out of the
/// target region, driving the "drop here" overlay. A drop's files are read to
/// bytes and forwarded to [onFiles] only when the drop itself lands inside the
/// target region — a drop elsewhere on the page is ignored (but still
/// prevented from navigating the tab).
/// Uses `package:web` + `dart:js_interop` (WASM-compatible).
Object? registerFileDropListener(
  DroppedFilesCallback onFiles,
  bool Function(double clientX, double clientY) isActive, {
  DragActiveCallback? onDragActive,
}) {
  var dragging = false;
  var overTarget = false;

  void setOverTarget(bool inside) {
    if (overTarget == inside) return;
    overTarget = inside;
    onDragActive?.call(inside);
  }

  void onDragEnter(web.Event event) {
    if (_isFileDrag(event)) dragging = true;
  }

  void onDragOver(web.Event event) {
    if (!dragging || !_isFileDrag(event)) return;
    // Required so `drop` fires (and the browser doesn't open the file in a
    // new tab) — applied page-wide regardless of target containment.
    event.preventDefault();
    final e = event as web.DragEvent;
    setOverTarget(isActive(e.clientX.toDouble(), e.clientY.toDouble()));
  }

  // `dragleave` fires with a null relatedTarget when the pointer leaves the
  // browser window/tab entirely — the standard cross-browser signal for
  // "the drag left the page" (as opposed to moving between elements, which
  // isn't meaningful here since Flutter web has no per-widget DOM nodes).
  void onDragLeave(web.Event event) {
    if (!dragging || !event.isA<web.DragEvent>()) return;
    if ((event as web.DragEvent).relatedTarget == null) {
      dragging = false;
      setOverTarget(false);
    }
  }

  void onDrop(web.Event event) {
    final wasOverTarget = overTarget;
    dragging = false;
    setOverTarget(false);
    if (!_isFileDrag(event)) return;
    event.preventDefault();
    if (!wasOverTarget) return; // Dropped outside the target — ignore.
    final data = (event as web.DragEvent).dataTransfer;
    final fileList = data?.files;
    if (fileList == null || fileList.length == 0) return;

    final files = <web.File>[];
    for (var i = 0; i < fileList.length; i++) {
      final f = fileList.item(i);
      if (f != null) files.add(f);
    }

    Future.wait(files.map(_readOne)).then((results) {
      final dropped = results.whereType<DroppedFile>().toList();
      if (dropped.isNotEmpty) onFiles(dropped);
    });
  }

  void onDragEnd(web.Event event) {
    dragging = false;
    setOverTarget(false);
  }

  final listeners = <String, web.EventListener>{
    'dragenter': onDragEnter.toJS,
    'dragover': onDragOver.toJS,
    'dragleave': onDragLeave.toJS,
    'drop': onDrop.toJS,
    'dragend': onDragEnd.toJS,
  };
  // Closures, not tear-offs: dart2js/dart2wasm disallow tear-offs of external
  // extension-type interop members like addEventListener.
  listeners.forEach(
    (type, listener) => web.document.addEventListener(type, listener),
  );
  return _DropHandle(listeners);
}

/// Removes listeners registered by [registerFileDropListener].
void unregisterFileDropListener(Object? handle) {
  if (handle is _DropHandle) {
    handle.listeners.forEach(
      (type, listener) => web.document.removeEventListener(type, listener),
    );
  }
}

Future<DroppedFile?> _readOne(web.File file) {
  final completer = Completer<DroppedFile?>();
  final reader = web.FileReader();
  reader.addEventListener(
    'loadend',
    (web.Event _) {
      final result = reader.result;
      Uint8List? bytes;
      if (result != null && result.isA<JSArrayBuffer>()) {
        bytes = (result as JSArrayBuffer).toDart.asUint8List();
      }
      completer.complete(
        bytes != null && bytes.isNotEmpty
            ? DroppedFile(bytes, file.name, file.type)
            : null,
      );
    }.toJS,
  );
  reader.addEventListener(
    'error',
    (web.Event _) {
      completer.complete(null);
    }.toJS,
  );
  reader.readAsArrayBuffer(file);
  return completer.future;
}
