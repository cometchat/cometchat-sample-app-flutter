import 'package:flutter/material.dart';

/// Web implementation of platform file utilities.
///
/// On web there is no local filesystem access, so file operations
/// either return false/null or use alternative web-safe approaches.

bool isLocalFileAvailable(String path) => false;

bool platformIsIOS() => false;

bool platformIsAndroid() => false;

Future<String?> downloadFileToLocal(String fileUrl, String fileName) async {
  // On web, we cannot download to a local filesystem.
  // The caller should use url_launcher or an anchor download instead.
  debugPrint('[Web] downloadFileToLocal not supported — use URL directly');
  return null;
}

Future<String?> getDownloadedFilePath(String fileName) async {
  // No local filesystem on web
  return null;
}

bool fileExistsSync(String path) => false;

Future<String?> writeBytesToTempFile(List<int> bytes, String fileName) async {
  // Not supported on web — keyboard content insertion is already guarded
  return null;
}
