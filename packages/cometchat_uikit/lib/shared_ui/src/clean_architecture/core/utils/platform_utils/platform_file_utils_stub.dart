/// Stub implementation — should never be reached at runtime.
/// Exists only to satisfy the conditional import contract.

bool isLocalFileAvailable(String path) => false;

bool platformIsIOS() => false;

bool platformIsAndroid() => false;

Future<String?> downloadFileToLocal(String fileUrl, String fileName) async {
  return null;
}

Future<String?> getDownloadedFilePath(String fileName) async {
  return null;
}

bool fileExistsSync(String path) => false;

Future<String?> writeBytesToTempFile(List<int> bytes, String fileName) async {
  return null;
}
