import 'dart:io';

import '../../cometchat_uikit_shared.dart';

class FileUtils {
  static bool isLocalFileAvailable(String path) {
    // Ensure that we are decoding the URL to get the correct file path
    final decodedPath = Uri.decodeFull(path);
    return decodedPath.isNotEmpty && File(decodedPath).existsSync();
  }

  static String? getLocalFilePath(Map<String, dynamic>? metadata) {
    return metadata != null && metadata.containsKey("localPath")
        ? metadata["localPath"] ?? ""
        : null;
  }

  static String getFileSize(int size, {String unit = 'B'}) {
    if (size > 1024) {
      size = size ~/ 1024;
      if (unit == 'B') {
        unit = 'KB';
      } else if (unit == 'KB') {
        unit = 'MB';
      } else if (unit == 'MB') {
        unit = 'GB';
      } else if (unit == 'GB') {
        unit = 'TB';
      } else {
        return "$size $unit";
      }
      return getFileSize(size, unit: unit);
    }
    return "$size $unit";
  }

  static String? getFileExtension(String? fileUrl) {
    // Decode file URL to handle encoded paths
    String decodedFileUrl = Uri.decodeFull(fileUrl ?? '');
    String fileName = decodedFileUrl.split('/').last;

    String extension = fileName.split('.').last.toLowerCase();
    return extension;
  }

  static String getFileIcon(String? fileExtension) {
    String fileIcon = AssetConstants.fileUnknown;

    if (fileExtension != null) {
      if (documentExtensions.contains(fileExtension)) {
        fileIcon = AssetConstants.fileDoc;
      } else if (spreadsheetExtensions.contains(fileExtension)) {
        fileIcon = AssetConstants.fileSpreadsheet;
      } else if (imageExtensions.contains(fileExtension)) {
        fileIcon = AssetConstants.fileImage;
      } else if (audioExtensions.contains(fileExtension)) {
        fileIcon = AssetConstants.fileAudio;
      } else if (videoExtensions.contains(fileExtension)) {
        fileIcon = AssetConstants.fileVideo;
      } else if (pdfExtensions.contains(fileExtension)) {
        fileIcon = AssetConstants.filePdf;
      } else if (zipExtensions.contains(fileExtension)) {
        fileIcon = AssetConstants.fileZip;
      } else if (presentationExtensions.contains(fileExtension)) {
        fileIcon = AssetConstants.filePresentation;
      } else if (textExtensions.contains(fileExtension)) {
        fileIcon = AssetConstants.fileText;
      }
    }
    return fileIcon;
  }

  static List<String> documentExtensions = ["doc", "docx", "md", "odt", "abw", "dot", "dotx"];
  static List<String> spreadsheetExtensions = ["csv", "xls", "xlsx", "ods", "tsv", "xlt", "xltx", "numbers"];
  static List<String> imageExtensions = [
    "jpg",
    "jpeg",
    "png",
    "gif",
    "bmp",
    "svg",
    "webp",
    "tiff",
    "psd",
    "heif",
    "heic",
    "icns",
    "eps"
  ];
  static List<String> audioExtensions = [
    "mp3",
    "wav",
    "ogg",
    "flac",
    "aac",
    "wma",
    "aiff",
    "m4a",
    "mid",
    "midi",
    "opus",
    "amr"
  ];
  static List<String> videoExtensions = [
    "mp4",
    "avi",
    "mov",
    "mkv",
    "flv",
    "wmv",
    "webm",
    "mpg",
    "mpeg",
    "3gp",
    "mts",
    "m2ts",
    "vob",
    "mxf",
    "f4v"
  ];
  static List<String> pdfExtensions = ["pdf", "ps", "eps", "ai"];
  static List<String> zipExtensions = ["zip", "rar", "7z", "tar", "gz", "bz2", "xz"];
  static List<String> presentationExtensions = ["ppt", "pptx", "odp", "key", "pps", "ppsx", "pot", "potx", "sxi"];
  static List<String> textExtensions = ["txt", "wps", "rtf", "tex", "log", "csv", "tsv", "json", "xml", "yaml", "yml"];

}