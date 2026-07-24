class FileSizeCheckUtil {
  // Private constructor
  FileSizeCheckUtil._();

  // Singleton instance
  static final FileSizeCheckUtil instance = FileSizeCheckUtil._();

  // Whether to hide moderation status (defaults to false)
  String errorMessage = "";

  // Method to check if exception is shown
  String isFileSizeException(String exception) {
    String sizeLimit = _extractFileSize(exception);
    errorMessage = "File exceeds the $sizeLimit limit - try a smaller one.";
    return errorMessage;
  }

  // Helper method to extract file size from exception message
  String _extractFileSize(String exception) {
    RegExp regex = RegExp(r'(\d+)\s*(MB|GB|KB|TB)', caseSensitive: false);
    Match? match = regex.firstMatch(exception);

    if (match != null) {
      String size = match.group(0)!; // "100 MB"
      return size;
    }
    return '100 MB';
  }
}
