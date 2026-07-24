import 'package:flutter/material.dart';

/// Fixed per-file-type accent color + glyph shared by the files bubble and the
/// composer attachment tray. These are data-type colors (a PDF is red in light
/// and dark mode alike), not theme tokens.
class FileTypeStyle {
  const FileTypeStyle(this.color, this.icon);

  final Color color;
  final IconData icon;

  /// Tinted fill for a glyph-on-tint icon box. 12 % alpha reads as the pastel
  /// chip of the reference design on light backgrounds; dark mode needs more
  /// presence to survive compositing over a dark surface.
  Color tint(Brightness brightness) =>
      color.withValues(alpha: brightness == Brightness.dark ? 0.22 : 0.12);

  /// Lower-cased extension taken from the last dot segment of [fileName];
  /// empty string when the name has no extension.
  static String extOf(String fileName) =>
      fileName.contains('.') ? fileName.split('.').last.toLowerCase() : '';

  /// Resolves the style from whatever identity is available: an explicit
  /// [extension] wins, else the extension is taken from [fileName]; audio is
  /// recognized by [mimeType] when the extension is unknown.
  static FileTypeStyle of({
    String? fileName,
    String? extension,
    String? mimeType,
  }) {
    final ext =
        (extension != null && extension.isNotEmpty
                ? extension.toLowerCase()
                : extOf(fileName ?? ''))
            .trim();
    switch (ext) {
      case 'pdf':
        return const FileTypeStyle(Color(0xFFE53935), Icons.picture_as_pdf);
      case 'doc':
      case 'docx':
        return const FileTypeStyle(Color(0xFF1E88E5), Icons.description);
      case 'xls':
      case 'xlsx':
      case 'csv':
        return const FileTypeStyle(Color(0xFF43A047), Icons.table_chart);
      case 'ppt':
      case 'pptx':
        return const FileTypeStyle(Color(0xFFE64A19), Icons.slideshow);
      case 'zip':
      case 'rar':
      case '7z':
        return const FileTypeStyle(Color(0xFF8E24AA), Icons.folder_zip);
    }
    if ((mimeType ?? '').startsWith('audio/')) {
      return const FileTypeStyle(Color(0xFFFF7043), Icons.audiotrack);
    }
    return const FileTypeStyle(Color(0xFF607D8B), Icons.insert_drive_file);
  }
}
