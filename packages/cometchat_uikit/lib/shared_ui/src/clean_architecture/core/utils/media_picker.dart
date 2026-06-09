import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../constants/ui_kit_constants.dart';
import 'platform_utils/platform_file_utils.dart' as platform;

enum FileType { image, video, audio, any, custom }

class PickedFile {
  PickedFile(
      {required this.name,
      required this.path,
      this.size,
      this.extension,
      this.fileType,
      this.bytes});

  final String name;
  final String path;
  final int? size;
  final String? extension;
  final String? fileType;

  /// File bytes — populated on web where file paths aren't real filesystem paths.
  final List<int>? bytes;
}

class MediaPicker {
  static final ImagePicker _picker = ImagePicker();

  static Future<PickedFile?> takePhoto() async {
    if (kIsWeb) {
      // Camera not available on web — use image picker gallery instead
      return _pickFileWeb(type: "image");
    }
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);

      if (image != null) {
        return PickedFile(name: image.name, path: image.path);
      } else {
        checkForPhotoPermission();
        return null;
      }
    } catch (e, stack) {
      debugPrint("Exception in takePhoto: $e");
      debugPrint("$stack");
      checkForPhotoPermission();
      return null;
    }
  }

  static Future<PickedFile?> pickAnyFile() async {
    if (kIsWeb) {
      return _pickFileWeb(type: "any");
    }
    return await _getFilesFromMethodChannel(type: "any");
  }

  static Future<PickedFile?> pickAudio() async {
    if (kIsWeb) {
      return _pickFileWeb(type: "audio");
    }
    return _getFilesFromMethodChannel(type: "audio");
  }

  /// Web-safe file picker using image_picker (for images/videos) or
  /// falling back to XFile-based picking.
  static Future<PickedFile?> _pickFileWeb({String type = "any"}) async {
    try {
      XFile? file;
      if (type == "image") {
        file = await _picker.pickImage(source: ImageSource.gallery);
      } else if (type == "video") {
        file = await _picker.pickVideo(source: ImageSource.gallery);
      } else if (type == "imagevideo") {
        // On web, pick image as default for combined picker
        file = await _picker.pickImage(source: ImageSource.gallery);
      } else {
        // For audio/any/custom — use pickImage as fallback on web
        // A more complete solution would use file_picker package
        file = await _picker.pickImage(source: ImageSource.gallery);
      }

      if (file != null) {
        final name = file.name;
        final ext = name.contains('.')
            ? name.substring(name.lastIndexOf('.') + 1).toLowerCase()
            : '';
        // On web, read the file bytes since file paths are blob URLs
        final bytes = await file.readAsBytes();
        return PickedFile(
          name: name,
          path: file.path,
          size: bytes.length,
          extension: ext,
          fileType: _getFileType(ext),
          bytes: bytes,
        );
      }
      return null;
    } catch (e) {
      debugPrint("Web file pick failed: $e");
      return null;
    }
  }

  // static pickCustomFile() async {
  //   try {
  //     var result = await UIConstants.channel.invokeListMethod("pickFile",
  //         {"allowMultipleSelection": true, "withData": false, "type": "any"});
  //     print(result);
  //     if (result != null && result.first["path"] != null) {
  //       Map<String, dynamic> file = Map<String, dynamic>.from(result.first);
  //       return PickedFile(
  //         name: file["name"],
  //         path: file["path"],
  //         size: file["size"],
  //       );
  //     } else {
  //       return null;
  //     }
  //   } on PlatformException catch (e, stack) {
  //     debugPrint("$stack");
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

  static Future<PickedFile?> pickImage() async {
    if (kIsWeb) {
      return _pickFileWeb(type: "image");
    }
    if (platform.platformIsAndroid()) {
      return _getFilesFromMethodChannel(type: "image");
    }
    return await _getFilesFromMethodChannel(
        type: platform.platformIsIOS() ? "image" : "custom",
        allowedExtensions: imageExtensions + videoExtensions);
  }

  static Future<PickedFile?> pickVideo() async {
    if (kIsWeb) {
      return _pickFileWeb(type: "video");
    }
    if (platform.platformIsAndroid()) {
      return _getFilesFromMethodChannel(type: "video");
    }
    return await _getFilesFromMethodChannel(
        type: platform.platformIsIOS() ? "video" : "custom",
        allowedExtensions: imageExtensions + videoExtensions);
  }

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
  static Future<PickedFile?> pickImageVideo() async {
    if (kIsWeb) {
      return _pickFileWeb(type: "imagevideo");
    }
    return await _getFilesFromMethodChannel(
        type: platform.platformIsIOS() ? "imagevideo" : "custom",
        allowedExtensions: imageExtensions + videoExtensions);
  }

  static Future<PickedFile?> _getFilesFromMethodChannel(
      {String type = "any",
      bool? allowMultipleSelection = false,
      bool? withData = false,
      List<String>? allowedExtensions}) async {
    try {
      var result = await UIConstants.channel.invokeListMethod("pickFile", {
        "allowMultipleSelection": allowMultipleSelection,
        "withData": withData,
        "type": type,
        "allowedExtensions": allowedExtensions
      });
      if (result != null && result.first["path"] != null) {
        Map<String, dynamic> file = Map<String, dynamic>.from(result.first);
        String name = file["name"];
        String extension =
            name.substring(name.lastIndexOf(".") + 1).toLowerCase();
        String? fileType = _getFileType(extension);
        String path = file["path"];
        if (platform.platformIsIOS() && path.contains(" ")) {
          path = Uri.encodeFull(path);
        }
        return PickedFile(
            name: name,
            path: path,
            size: file["size"],
            extension: extension,
            fileType: fileType);
      } else {
        return null;
      }
    } on PlatformException catch (e, stack) {
      debugPrint("$stack");
    } catch (e) {
      rethrow;
    }
    return null;
  }

  static String? _getFileType(String extension) {
    if (imageExtensions.contains(extension)) {
      return MessageTypeConstants.image;
    } else if (videoExtensions.contains(extension)) {
      return MessageTypeConstants.video;
    } else if (audioExtensions.contains(extension)) {
      return MessageTypeConstants.audio;
    } else {
      return null;
    }
  }

  static checkForPhotoPermission() async {
    if (kIsWeb) return; // Browser handles permissions natively
    final bool granted =
        await UIConstants.channel.invokeMethod("checkCameraPermission");
    if (!granted) {
      debugPrint("Camera permission not granted");
    }
  }
}
