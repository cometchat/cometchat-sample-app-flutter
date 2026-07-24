import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'file_type_styles.dart';

/// Package that owns the attachment type-badge SVGs — needed for
/// [SvgPicture.asset]'s `package:` argument when the assets are consumed inside
/// the UIKit package.
const String kAttachmentIconPackage = 'cometchat_chat_uikit';

const String _base = 'assets/icons/svg/attachments';

/// Fixed (non-type-mapped) attachment icon assets — self-coloured SVGs,
/// rendered as-is via [SvgPicture.asset] with [kAttachmentIconPackage].
const String kAttachmentErrorIconAsset = '$_base/error-icon.svg';
const String kAttachmentRetryIconAsset = '$_base/retry-icon.svg';
const String kAttachmentDocumentSearchIconAsset =
    '$_base/document-in-search.svg';

/// Document-with-slash glyph for the "no preview available" / unsupported-media
/// state — a media attachment that can't be rendered (image/video render
/// failure, or a file whose actual type doesn't match the message type it was
/// sent as). Rendered as-is (self-coloured grey) via [SvgPicture.asset].
const String kAttachmentUnsupportedIconAsset = '$_base/unsupported.svg';

/// Resolves the full-colour type-badge asset (a red PDF, blue Word, etc.) under
/// `assets/icons/svg/attachments/` for the given file identity. Falls back to
/// `unknown.svg`. These are complete coloured icons — render them as-is (no
/// tint). Shared by the composer tray and the file message bubbles.
String attachmentSvgAsset({
  String? fileName,
  String? extension,
  String? mimeType,
}) {
  final ext =
      (extension != null && extension.isNotEmpty
              ? extension.toLowerCase()
              : FileTypeStyle.extOf(fileName ?? ''))
          .trim();
  final mime = (mimeType ?? '').toLowerCase();

  switch (ext) {
    case 'pdf':
      return '$_base/pdf.svg';
    case 'doc':
    case 'docx':
      return '$_base/word.svg';
    case 'xls':
    case 'xlsx':
    case 'csv':
      return '$_base/xlsx.svg';
    case 'ppt':
    case 'pptx':
      return '$_base/ppt.svg';
    case 'zip':
    case 'rar':
    case '7z':
    case 'tar':
    case 'gz':
      return '$_base/zip.svg';
    case 'txt':
    case 'text':
    case 'rtf':
    case 'md':
      return '$_base/text.svg';
    case 'jpg':
    case 'jpeg':
    case 'png':
    case 'gif':
    case 'webp':
    case 'heic':
    case 'heif':
    case 'bmp':
      return '$_base/jpg.svg';
    case 'mp4':
    case 'mov':
    case 'avi':
    case 'mkv':
    case 'webm':
    case 'm4v':
    case 'wmv':
    case 'flv':
    case '3gp':
      return '$_base/mov.svg';
    case 'mp3':
    case 'm4a':
    case 'wav':
    case 'aac':
    case 'ogg':
    case 'flac':
    case 'wma':
    case 'opus':
      return '$_base/mp3.svg';
  }
  if (mime.startsWith('image/')) return '$_base/jpg.svg';
  if (mime.startsWith('video/')) return '$_base/mov.svg';
  if (mime.startsWith('audio/')) return '$_base/mp3.svg';
  return '$_base/unknown.svg';
}

/// Builds the type-badge widget for a file, sized to [size].
Widget attachmentSvgIcon({
  String? fileName,
  String? extension,
  String? mimeType,
  double size = 30,
}) {
  return SvgPicture.asset(
    attachmentSvgAsset(
      fileName: fileName,
      extension: extension,
      mimeType: mimeType,
    ),
    package: kAttachmentIconPackage,
    width: size,
    height: size,
  );
}
