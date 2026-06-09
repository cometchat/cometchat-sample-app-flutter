import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

/// Native (mobile/desktop) implementation of platform file utilities.

bool isLocalFileAvailable(String path) {
  final decodedPath = Uri.decodeFull(path);
  return decodedPath.isNotEmpty && File(decodedPath).existsSync();
}

bool platformIsIOS() => Platform.isIOS;

bool platformIsAndroid() => Platform.isAndroid;

String _fileDownloadPath = "";

Future<void> _setDownloadFilePath() async {
  if (Platform.isIOS) {
    _fileDownloadPath = (await getTemporaryDirectory()).path;
  } else {
    _fileDownloadPath = (await getExternalStorageDirectory())!.path;
  }
}

Future<String?> downloadFileToLocal(String fileUrl, String fileName) async {
  try {
    if (_fileDownloadPath.isEmpty) {
      await _setDownloadFilePath();
    }
    if (_fileDownloadPath.isEmpty) return null;

    String filePath = "$_fileDownloadPath/$fileName";
    final request = await HttpClient().getUrl(Uri.parse(fileUrl));
    final response = await request.close();
    await response.pipe(File(filePath).openWrite());
    debugPrint("Download path $filePath");
    return filePath;
  } catch (e) {
    debugPrint("File download failed: $e");
    return null;
  }
}

Future<String?> getDownloadedFilePath(String fileName) async {
  if (_fileDownloadPath.isEmpty) {
    await _setDownloadFilePath();
  }
  String filePath = "$_fileDownloadPath/$fileName";
  if (File(filePath).existsSync()) {
    return filePath;
  }
  return null;
}

bool fileExistsSync(String path) {
  return File(path).existsSync();
}

/// Write bytes to a temporary file and return the path.
Future<String?> writeBytesToTempFile(List<int> bytes, String fileName) async {
  try {
    final tempDir = Directory.systemTemp;
    final file = File('${tempDir.path}/$fileName');
    await file.writeAsBytes(bytes);
    return file.path;
  } catch (e) {
    debugPrint("writeBytesToTempFile failed: $e");
    return null;
  }
}
