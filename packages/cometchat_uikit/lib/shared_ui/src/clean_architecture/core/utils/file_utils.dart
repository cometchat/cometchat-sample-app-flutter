import 'dart:io';

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
}