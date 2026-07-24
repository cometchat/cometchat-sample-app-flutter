import 'platform_utils/platform_file_utils.dart' as platform;

class FileUtils {
  static bool isLocalFileAvailable(String path) {
    return platform.isLocalFileAvailable(path);
  }

  static String? getLocalFilePath(Map<String, dynamic>? metadata) {
    return metadata != null && metadata.containsKey("localPath")
        ? metadata["localPath"] ?? ""
        : null;
  }
}
